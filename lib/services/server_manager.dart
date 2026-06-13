import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

// ============================================================
// ServerEntry Model
// ============================================================

class ServerEntry {
  final String id;
  final String name;
  final String url;
  final DateTime addedAt;

  ServerEntry({
    required this.id,
    required this.name,
    required String url,
    DateTime? addedAt,
  })  : url = normalizeURL(url),
        addedAt = addedAt ?? DateTime.now();

  /// Нормализация URL: добавляет https:// и /api/v1 при необходимости
  static String normalizeURL(String rawURL) {
    var url = rawURL.trim();

    // Убираем trailing slash
    while (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }

    // Добавляем протокол если отсутствует
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    // Добавляем /api/v1 если отсутствует
    if (!url.endsWith('/api/v1')) {
      url = '$url/api/v1';
    }

    return url;
  }

  /// Короткое отображение URL (без протокола и /api/v1)
  String get displayURL {
    var display = url;
    display = display.replaceAll('https://', '');
    display = display.replaceAll('http://', '');
    display = display.replaceAll('/api/v1', '');
    while (display.endsWith('/')) {
      display = display.substring(0, display.length - 1);
    }
    return display;
  }

  /// WebSocket URL для данного сервера
  String get wsBaseUrl {
    final wsUrl = url
        .replaceAll('https://', 'wss://')
        .replaceAll('http://', 'ws://');
    return '$wsUrl/sync/ws';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'url': url,
        'addedAt': addedAt.toIso8601String(),
      };

  factory ServerEntry.fromJson(Map<String, dynamic> json) => ServerEntry(
        id: json['id'] as String,
        name: json['name'] as String,
        url: json['url'] as String,
        addedAt: DateTime.parse(json['addedAt'] as String),
      );

  ServerEntry copyWith({String? name, String? url}) => ServerEntry(
        id: id,
        name: name ?? this.name,
        url: url ?? this.url,
        addedAt: addedAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ServerEntry && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// ============================================================
// ServerManagerState
// ============================================================

class ServerManagerState {
  final List<ServerEntry> servers;
  final String? activeServerId;

  const ServerManagerState({
    this.servers = const [],
    this.activeServerId,
  });

  ServerEntry? get activeServer {
    if (activeServerId == null) return servers.isNotEmpty ? servers.first : null;
    return servers.cast<ServerEntry?>().firstWhere(
          (s) => s!.id == activeServerId,
          orElse: () => servers.isNotEmpty ? servers.first : null,
        );
  }

  String get currentBaseUrl =>
      activeServer?.url ?? 'https://api.teploservis05.ru/api/v1';

  String get currentWsBaseUrl =>
      activeServer?.wsBaseUrl ?? 'wss://api.teploservis05.ru/api/v1/sync/ws';

  ServerManagerState copyWith({
    List<ServerEntry>? servers,
    String? activeServerId,
  }) =>
      ServerManagerState(
        servers: servers ?? this.servers,
        activeServerId: activeServerId ?? this.activeServerId,
      );
}


class ServerManagerNotifier extends ChangeNotifier {
  final Future<String?> Function(String key) _read;
  final Future<void> Function(String key, String value) _write;
  final Future<void> Function() _onServerSwitch;

  static const _serversKey = 'ServerManager_Servers';
  static const _activeIdKey = 'ServerManager_ActiveServerId';
  static const _migrationKey = 'ServerManager_MigrationDone';

  ServerManagerState _state = const ServerManagerState();
  ServerManagerState get state => _state;

  /// Stream для реактивного обновления UI через Riverpod
  final _stateController = StreamController<ServerManagerState>.broadcast();
  Stream<ServerManagerState> get stateStream => _stateController.stream;

  ServerManagerNotifier({
    required Future<String?> Function(String key) read,
    required Future<void> Function(String key, String value) write,
    required Future<void> Function() onServerSwitch,
  })  : _read = read,
        _write = write,
        _onServerSwitch = onServerSwitch;

  void _updateState(ServerManagerState newState) {
    _state = newState;
    _stateController.add(newState);
    notifyListeners();
  }

  /// Инициализация: загрузка серверов из хранилища + миграция
  Future<void> init() async {
    final migrationDone = await _read(_migrationKey);
    final serversJson = await _read(_serversKey);
    final activeId = await _read(_activeIdKey);

    List<ServerEntry> servers = [];
    if (serversJson != null && serversJson.isNotEmpty) {
      try {
        final list = jsonDecode(serversJson) as List;
        servers =
            list.map((e) => ServerEntry.fromJson(e as Map<String, dynamic>)).toList();
      } catch (e) {
        debugPrint('🖥️ [ServerManager] Ошибка загрузки серверов: $e');
      }
    }

    // Миграция: при первом запуске создаём дефолтный сервер
    if (migrationDone != 'true' && servers.isEmpty) {
      final defaultServer = ServerEntry(
        id: 'default-teploservis05',
        name: 'Единый оператор',
        url: 'https://api.teploservis05.ru/api/v1',
      );
      servers = [defaultServer];
      await _saveServers(servers);
      await _write(_activeIdKey, defaultServer.id);
      await _write(_migrationKey, 'true');
      debugPrint('🖥️ [ServerManager] Миграция: создан дефолтный сервер');
    } else if (migrationDone != 'true') {
      await _write(_migrationKey, 'true');
    }

    _updateState(ServerManagerState(
      servers: servers,
      activeServerId: activeId,
    ));
  }

  /// Добавить новый сервер
  Future<ServerEntry> addServer(String name, String url) async {
    final entry = ServerEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      url: url,
    );

    final updated = [..._state.servers, entry];
    await _saveServers(updated);

    // Если это первый сервер, автоматически выбираем
    String? activeId = _state.activeServerId;
    if (updated.length == 1) {
      activeId = entry.id;
      await _write(_activeIdKey, activeId);
    }

    _updateState(_state.copyWith(servers: updated, activeServerId: activeId));
    debugPrint('🖥️ [ServerManager] Добавлен сервер: $name (${entry.url})');
    return entry;
  }

  /// Удалить сервер
  Future<void> deleteServer(String id) async {
    final updated = _state.servers.where((s) => s.id != id).toList();
    await _saveServers(updated);

    String? newActiveId = _state.activeServerId;
    if (_state.activeServerId == id) {
      newActiveId = updated.isNotEmpty ? updated.first.id : null;
      if (newActiveId != null) {
        await _write(_activeIdKey, newActiveId);
      }
      await _onServerSwitch();
    }

    _updateState(_state.copyWith(servers: updated, activeServerId: newActiveId));
    debugPrint('🖥️ [ServerManager] Удалён сервер (ID: $id)');
  }

  /// Выбрать активный сервер
  Future<void> selectServer(String id) async {
    if (_state.activeServerId == id) return;

    await _write(_activeIdKey, id);
    _updateState(_state.copyWith(activeServerId: id));

    await _onServerSwitch();

    final server = _state.activeServer;
    debugPrint(
        '🖥️ [ServerManager] Переключен на: ${server?.name} (${server?.url})');
  }

  /// Обновить данные сервера
  Future<void> updateServer(String id, {String? name, String? url}) async {
    final updated = _state.servers.map((s) {
      if (s.id == id) {
        return s.copyWith(name: name, url: url);
      }
      return s;
    }).toList();

    await _saveServers(updated);
    _updateState(_state.copyWith(servers: updated));
    debugPrint('🖥️ [ServerManager] Обновлён сервер (ID: $id)');
  }

  /// Проверить соединение с сервером
  static Future<(bool success, String message)> checkConnection(
      String url) async {
    final normalizedURL = ServerEntry.normalizeURL(url);

    try {
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ));

      final response = await dio.get('$normalizedURL/');

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 500) {
        return (true, 'Сервер доступен (HTTP ${response.statusCode})');
      } else {
        return (
          false,
          'Сервер вернул ошибку: HTTP ${response.statusCode}'
        );
      }
    } on DioException catch (e) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
          return (false, 'Превышено время ожидания ответа');
        case DioExceptionType.connectionError:
          return (false, 'Не удалось подключиться к серверу');
        default:
          // Для 404 и других HTTP ответов — сервер доступен
          if (e.response != null) {
            return (true, 'Сервер доступен (HTTP ${e.response!.statusCode})');
          }
          return (false, 'Ошибка сети: ${e.message}');
      }
    } catch (e) {
      return (false, 'Ошибка: $e');
    }
  }

  Future<void> _saveServers(List<ServerEntry> servers) async {
    final json = jsonEncode(servers.map((s) => s.toJson()).toList());
    await _write(_serversKey, json);
  }
}

// ============================================================
// Riverpod Providers
// ============================================================

/// Provider для доступа к ServerManagerNotifier (создаётся в main.dart, передаётся через override)
final serverManagerProvider = Provider<ServerManagerNotifier>((ref) {
  throw UnimplementedError(
    'serverManagerProvider must be overridden with a ProviderScope override',
  );
});

/// Реактивный стейт серверов — автоматически обновляется при любом изменении.
/// Виджеты должны смотреть этот provider для реактивного обновления UI.
final serverStateProvider = StreamProvider<ServerManagerState>((ref) {
  final notifier = ref.watch(serverManagerProvider);
  // Сначала отправляем текущий стейт, затем подписываемся на обновления
  return notifier.stateStream.transform(
    StreamTransformer.fromBind((stream) async* {
      yield notifier.state; // Начальное значение
      yield* stream;
    }),
  );
});

