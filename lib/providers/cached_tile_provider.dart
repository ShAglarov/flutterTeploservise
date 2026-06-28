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
class CachedTileProviderManager {
  CachedTileProviderManager._();
  static final instance = CachedTileProviderManager._();

  CacheStore? _store;
  bool _initialized = false;

  /// Кэшированный экземпляр TileProvider — создаётся один раз
  CachedTileProvider? _cachedProvider;
  TileProvider? _fallbackProvider;

  /// Must be called once at app startup (e.g., in main.dart).
  Future<void> init() async {
    if (_initialized) return;
    final dir = await getApplicationSupportDirectory();
    final path = '${dir.path}/map_tile_cache';
    _store = HiveCacheStore(
      path,
      hiveBoxName: 'map_tiles',
    );
    _initialized = true;
    // Создаём один раз
    _cachedProvider = CachedTileProvider(
      store: _store!,
      maxStale: const Duration(days: 365),
      hitCacheOnErrorExcept: [401, 403],
    );
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
    } catch (_) {
      // Молча игнорируем ошибки предзагрузки
    }
  }
}
