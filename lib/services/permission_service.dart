import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'base_api_service.dart';
import '../utils/app_logger.dart';

/// Riverpod provider for [PermissionService].
/// Автоматически пересоздаётся при смене Dio (смена сервера).
final permissionServiceProvider = Provider<PermissionService>((ref) {
  ref.keepAlive();
  final dio = ref.watch(dioProvider);
  return PermissionService(dio);
});

/// Reactive state: текущий снэпшот прав пользователя.
/// Все виджеты подписываются через `ref.watch(permissionStateProvider)`.
final permissionStateProvider = NotifierProvider<PermissionStateNotifier, PermissionSnapshot>(
  PermissionStateNotifier.new,
);

// ─────────────────────────────────────────────
// Модель снэпшота
// ─────────────────────────────────────────────

/// Иммутабельный снэпшот прав пользователя.
class PermissionSnapshot {
  final Map<String, bool> permissions;
  final int version;
  final bool isLoaded;
  final bool isAdmin;

  const PermissionSnapshot({
    this.permissions = const {},
    this.version = 0,
    this.isLoaded = false,
    this.isAdmin = false,
  });

  /// Разрешено ли действие.
  ///
  /// Роль НЕ даёт обхода: матрица прав действует и на администратора — так
  /// же, как на сервере. Раньше здесь стояло `if (isAdmin) return true`, и
  /// у администратора UI показывал всё разрешённым независимо от матрицы:
  /// кнопка была видна, а сервер отвечал 403.
  ///
  /// `isAdmin` остаётся в снэпшоте — он про РОЛЬ (нужен для системных
  /// операций вроде полной очистки данных), но доступ к функциям не даёт.
  bool hasPermission(String key) => permissions[key] ?? false;

  PermissionSnapshot copyWith({
    Map<String, bool>? permissions,
    int? version,
    bool? isLoaded,
    bool? isAdmin,
  }) {
    return PermissionSnapshot(
      permissions: permissions ?? this.permissions,
      version: version ?? this.version,
      isLoaded: isLoaded ?? this.isLoaded,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}

// ─────────────────────────────────────────────
// Notifier (реактивный стейт, Riverpod 3.x)
// ─────────────────────────────────────────────

class PermissionStateNotifier extends Notifier<PermissionSnapshot> {
  @override
  PermissionSnapshot build() {
    // Загружаем кэшированные права при инициализации
    _loadCached();
    return const PermissionSnapshot();
  }

  Future<void> _loadCached() async {
    final service = ref.read(permissionServiceProvider);
    final cached = await service.loadCachedPermissions();
    if (cached == null) return;
    // Кэш читается асинхронно и может прийти ПОСЛЕ ответа сервера. Тогда
    // применять его нельзя: вернули бы старые права поверх свежих.
    if (state.isLoaded) return;
    state = cached;
  }

  /// Полная загрузка с сервера.
  ///
  /// Ошибку не поднимает: загрузка прав не должна валить авторизацию. Но и не
  /// теряет — причина уходит в `lastPermissionLoadError`, и экран профиля
  /// отличает «не загрузилось» от «запрещено».
  Future<void> loadFromServer() async {
    try {
      final service = ref.read(permissionServiceProvider);
      final snapshot = await service.loadFromServer();
      if (snapshot != null) {
        state = snapshot;
      }
    } catch (e) {
      lastPermissionLoadError = 'Непредвиденная ошибка: $e';
      _permLog('NOTIFIER ERROR: $e');
    }
  }

  /// Применение дельта-обновления (от WebSocket).
  ///
  /// Версия монотонно растёт на сервере (`user_permissions.version`), поэтому
  /// сообщение со версией НЕ БОЛЬШЕ текущей — это дубль или пришедшее с
  /// опозданием старое обновление. Применять его нельзя: при переподключении
  /// WebSocket сервер может повторно доставить сообщение, и права откатились
  /// бы к состоянию до правки.
  void applyDelta(Map<String, bool> changes, Map<String, bool>? full, int newVersion) {
    if (state.isLoaded && newVersion > 0 && newVersion <= state.version) {
      _permLog(
        'Пропущена устаревшая дельта: v$newVersion <= текущая v${state.version}',
      );
      return;
    }

    final service = ref.read(permissionServiceProvider);
    final current = Map<String, bool>.from(state.permissions);
    if (full != null) {
      // Полный снимок авторитетнее: он закрывает расхождения, если какая-то
      // дельта до нас не дошла.
      current
        ..clear()
        ..addAll(full);
    } else {
      current.addAll(changes);
    }
    state = state.copyWith(
      permissions: current,
      version: newVersion,
      isLoaded: true,
    );
    service.saveToCache(state);
  }

  /// Сброс при логауте.
  void clear() {
    final service = ref.read(permissionServiceProvider);
    state = const PermissionSnapshot();
    service.clearCache();
  }
}


// ─────────────────────────────────────────────
// Сервис (сеть + кэш)
// ─────────────────────────────────────────────

/// Последняя ошибка загрузки прав — чтобы UI мог сказать, ПОЧЕМУ прав нет.
///
/// Нужна потому, что `logDebug` обрезан по `kDebugMode`: в release-сборке (а
/// именно на ней и воспроизводился баг) диагностика не писалась никуда, и
/// «тихий» отказ загрузки выглядел как «админу всё запрещено».
String? lastPermissionLoadError;

void _permLog(String msg) {
  logDebug('🔐 [Permissions] $msg');
}

class PermissionService {
  final Dio _dio;

  static const _cacheKey = 'permission_cache_v1';
  static const _endpoint = '/permissions/me';

  /// Токен к запросу подставляет `AuthInterceptor` внутри Dio. Своего
  /// обращения к хранилищу здесь нет намеренно: раньше `loadFromServer()`
  /// сам читал `getAccessToken()` и при null молча возвращал null, не
  /// отправив запрос вовсе.
  PermissionService(this._dio);

  /// Загружает права с сервера: GET /permissions/me
  Future<PermissionSnapshot?> loadFromServer() async {
    _permLog('loadFromServer START, baseUrl=${_dio.options.baseUrl}');
    try {
      final response = await _dio.get(_endpoint);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final rawPerms = data['permissions'] as Map<String, dynamic>? ?? {};
        final permissions = rawPerms.map((k, v) => MapEntry(k, v == true));
        final version = data['version'] as int? ?? 1;
        final isAdmin = data['is_admin'] as bool? ?? false;

        final snapshot = PermissionSnapshot(
          permissions: permissions,
          version: version,
          isLoaded: true,
          isAdmin: isAdmin,
        );

        await saveToCache(snapshot);

        lastPermissionLoadError = null;
        _permLog('OK: ${permissions.length} perms, v$version, admin=$isAdmin');
        return snapshot;
      } else {
        lastPermissionLoadError = 'Сервер ответил ${response.statusCode}';
        _permLog('Bad response: status=${response.statusCode}');
      }
    } on DioException catch (e) {
      lastPermissionLoadError =
          'Запрос не выполнен (${e.type.name}${e.response?.statusCode != null ? ', HTTP ${e.response?.statusCode}' : ''})';
      _permLog('DioException: type=${e.type}, status=${e.response?.statusCode}, msg=${e.message}');
    } catch (e) {
      lastPermissionLoadError = 'Непредвиденная ошибка: $e';
      _permLog('UNEXPECTED: $e');
    }
    return null;
  }

  // ─── Кэш (SharedPreferences) ───

  Future<void> saveToCache(PermissionSnapshot snapshot) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode({
        'permissions': snapshot.permissions,
        'version': snapshot.version,
        'isAdmin': snapshot.isAdmin,
      });
      await prefs.setString(_cacheKey, json);
    } catch (e) {
      _permLog('saveToCache failed: $e');
    }
  }

  Future<PermissionSnapshot?> loadCachedPermissions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey);
      if (raw == null) return null;

      final data = jsonDecode(raw) as Map<String, dynamic>;
      final rawPerms = data['permissions'] as Map<String, dynamic>? ?? {};
      final permissions = rawPerms.map((k, v) => MapEntry(k, v == true));

      return PermissionSnapshot(
        permissions: permissions,
        version: data['version'] as int? ?? 0,
        isLoaded: true,
        isAdmin: data['isAdmin'] as bool? ?? false,
      );
    } catch (e) {
      _permLog('loadCachedPermissions failed: $e');
      return null;
    }
  }

  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
    } catch (_) {}
  }
}
