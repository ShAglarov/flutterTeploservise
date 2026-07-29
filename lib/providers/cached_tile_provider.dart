import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:flutter_map_cache/flutter_map_cache.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:path_provider/path_provider.dart';

/// Singleton that provides a cached [TileProvider] for flutter_map.
///
/// Tiles are stored on disk using Hive. HTTP cache headers from the tile
/// server are respected (ETag / Last-Modified / max-age), so tiles are
/// re-validated only when the server says they've changed.
///
/// При повреждении Hive-бокса кэш автоматически пересоздаётся.
class CachedTileProviderManager {
  CachedTileProviderManager._();
  static final instance = CachedTileProviderManager._();

  CacheStore? _store;
  bool _initialized = false;
  String? _cachePath;

  /// Кэшированный экземпляр TileProvider — создаётся один раз
  CachedTileProvider? _cachedProvider;
  TileProvider? _fallbackProvider;

  /// Must be called once at app startup (e.g., in main.dart).
  Future<void> init() async {
    if (_initialized) return;
    final dir = await getApplicationSupportDirectory();
    _cachePath = '${dir.path}/map_tile_cache';

    try {
      _store = HiveCacheStore(
        _cachePath!,
        hiveBoxName: 'map_tiles',
      );
      _cachedProvider = CachedTileProvider(
        store: _store!,
        maxStale: const Duration(days: 365),
        hitCacheOnErrorExcept: [401, 403],
      );
      _initialized = true;
    } catch (e) {
      // Hive box corrupted at init — удаляем и пересоздаём
      print('⚠️ [TileCache] Hive init failed, clearing corrupted cache: $e');
      await _clearAndReinit();
    }
  }

  /// Удаляет повреждённый кэш и пересоздаёт.
  Future<void> _clearAndReinit() async {
    try {
      final cacheDir = Directory(_cachePath!);
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
      }
      _store = HiveCacheStore(
        _cachePath!,
        hiveBoxName: 'map_tiles',
      );
      _cachedProvider = CachedTileProvider(
        store: _store!,
        maxStale: const Duration(days: 365),
        hitCacheOnErrorExcept: [401, 403],
      );
      _initialized = true;
      print('✅ [TileCache] Cache recreated successfully');
    } catch (e) {
      print('❌ [TileCache] Failed to recreate cache: $e');
      // Fallback — используем NetworkTileProvider без кэша
      _initialized = false;
    }
  }

  /// Returns a [TileProvider] that caches tiles to disk.
  /// Falls back to the default network provider if not yet initialized.
  /// ВАЖНО: возвращает один и тот же экземпляр — без этого FlutterMap
  /// перезагружает все тайлы при каждом rebuild виджета.
  TileProvider get tileProvider {
    if (!_initialized || _cachedProvider == null) {
      _fallbackProvider ??= NetworkTileProvider();
      return _fallbackProvider!;
    }
    return _cachedProvider!;
  }

  /// Pre-загружает тайл в Hive кэш (скачивает через Dio с кэш-интерцептором).
  /// Вызывается фоново для предзагрузки тайлов соседних уровней зума.
  /// Если тайл уже в кэше — Dio вернёт его мгновенно (CachePolicy.forceCache).
  Future<void> prefetchTile(String url) async {
    if (!_initialized || _cachedProvider == null) return;
    try {
      await _cachedProvider!.dio.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
    } catch (e) {
      // HiveError при чтении — кэш повреждён
      if (e.toString().contains('HiveError') || e.toString().contains('corrupted')) {
        print('⚠️ [TileCache] Corrupted cache detected, clearing...');
        _clearAndReinit(); // fire-and-forget
      }
      // Молча игнорируем остальные ошибки предзагрузки
    }
  }
}
