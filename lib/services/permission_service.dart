import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'base_api_service.dart';
import 'secure_storage_service.dart';

/// Riverpod provider for [PermissionService].
/// Автоматически пересоздаётся при смене Dio (смена сервера).
final permissionServiceProvider = Provider<PermissionService>((ref) {
  ref.keepAlive();
  final dio = ref.watch(dioProvider);
  final storage = ref.watch(secureStorageServiceProvider);
  return PermissionService(dio, storage);
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

  bool hasPermission(String key) {
    if (isAdmin) return true;
    return permissions[key] ?? false;
  }

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
    if (cached != null) {
      state = cached;
    }
  }

  /// Полная загрузка с сервера.
  Future<void> loadFromServer() async {
    final service = ref.read(permissionServiceProvider);
    final snapshot = await service.loadFromServer();
    if (snapshot != null) {
      state = snapshot;
    }
  }

  /// Применение дельта-обновления (от WebSocket).
  void applyDelta(Map<String, bool> changes, Map<String, bool>? full, int newVersion) {
    final service = ref.read(permissionServiceProvider);
    final current = Map<String, bool>.from(state.permissions);
    if (full != null) {
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

class PermissionService {
  final Dio _dio;
  final SecureStorageService _storage;

  static const _cacheKey = 'permission_cache_v1';
  static const _endpoint = '/permissions/me';

  PermissionService(this._dio, this._storage);

  /// Загружает права с сервера: GET /permissions/me
  Future<PermissionSnapshot?> loadFromServer() async {
    try {
      final token = await _storage.getAccessToken();
      if (token == null || token.isEmpty) {
        debugPrint('⚠️ [PermissionService] No access token, skipping loadFromServer');
        return null;
      }

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

        debugPrint('✅ [PermissionService] Loaded ${permissions.length} permissions (v$version, admin=$isAdmin)');
        return snapshot;
      }
    } on DioException catch (e) {
      debugPrint('❌ [PermissionService] loadFromServer failed: ${e.message}');
    } catch (e) {
      debugPrint('❌ [PermissionService] Unexpected error: $e');
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
      debugPrint('⚠️ [PermissionService] saveToCache failed: $e');
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
      debugPrint('⚠️ [PermissionService] loadCachedPermissions failed: $e');
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
