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
  }

  /// Returns a [TileProvider] that caches tiles to disk.
  /// Falls back to the default network provider if not yet initialized.
  TileProvider get tileProvider {
    if (!_initialized || _store == null) {
      return NetworkTileProvider();
    }
    return CachedTileProvider(
      store: _store!,
      // Tiles almost never change — keep for 1 year.
      // ETag/Last-Modified headers ensure revalidation when online,
      // so only truly updated tiles get re-downloaded.
      maxStale: const Duration(days: 365),
      hitCacheOnErrorExcept: [401, 403], // Serve from cache on network errors
    );
  }
}
