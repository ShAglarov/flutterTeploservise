import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'theme_provider.dart';

part 'map_tile_provider.g.dart';

// ─────────────────────────────────────────────────
// Map tile source enum
// ─────────────────────────────────────────────────

/// Варианты подложки карты, доступные пользователю.
enum MapTileSource {
  openStreetMap,
  cartoVoyager,
  cartoPositron,
  esriSatellite,
  stadiaSmooth,
}

/// Внутренние варианты, включая тёмные версии (не показываются в UI).
enum _ResolvedTile {
  openStreetMap,
  cartoVoyager,
  cartoDarkMatter,
  cartoPositron,
  esriSatellite,
  stadiaSmooth,
  stadiaSmoothDark,
}

// ─────────────────────────────────────────────────
// Tile config — результат резолва
// ─────────────────────────────────────────────────

class MapTileConfig {
  final String urlTemplate;
  final List<String> subdomains;
  final bool needsDarkFilter;

  const MapTileConfig({
    required this.urlTemplate,
    this.subdomains = const [],
    this.needsDarkFilter = false,
  });
}

// ─────────────────────────────────────────────────
// Display info for UI
// ─────────────────────────────────────────────────

class MapTileDisplayInfo {
  final MapTileSource source;
  final String displayName;
  final String icon;

  const MapTileDisplayInfo({
    required this.source,
    required this.displayName,
    required this.icon,
  });
}

const mapTileDisplayOptions = [
  MapTileDisplayInfo(source: MapTileSource.openStreetMap, displayName: 'OpenStreetMap', icon: '🗺️'),
  MapTileDisplayInfo(source: MapTileSource.cartoVoyager, displayName: 'CARTO Voyager', icon: '🎨'),
  MapTileDisplayInfo(source: MapTileSource.cartoPositron, displayName: 'CARTO Positron', icon: '⬜'),
  MapTileDisplayInfo(source: MapTileSource.esriSatellite, displayName: 'Спутник', icon: '🛰️'),
  MapTileDisplayInfo(source: MapTileSource.stadiaSmooth, displayName: 'Stadia Smooth', icon: '🌊'),
];

// ─────────────────────────────────────────────────
// URL templates
// ─────────────────────────────────────────────────

MapTileConfig _configFor(_ResolvedTile tile, {required bool isDark}) {
  switch (tile) {
    case _ResolvedTile.openStreetMap:
      return MapTileConfig(
        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        needsDarkFilter: isDark,
      );
    case _ResolvedTile.cartoVoyager:
      return const MapTileConfig(
        urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
        subdomains: ['a', 'b', 'c', 'd'],
      );
    case _ResolvedTile.cartoDarkMatter:
      return const MapTileConfig(
        urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/dark_all/{z}/{x}/{y}.png',
        subdomains: ['a', 'b', 'c', 'd'],
      );
    case _ResolvedTile.cartoPositron:
      return MapTileConfig(
        urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/light_all/{z}/{x}/{y}.png',
        subdomains: const ['a', 'b', 'c', 'd'],
        needsDarkFilter: isDark,
      );
    case _ResolvedTile.esriSatellite:
      return const MapTileConfig(
        urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
      );
    case _ResolvedTile.stadiaSmooth:
      return const MapTileConfig(
        urlTemplate: 'https://tiles.stadiamaps.com/tiles/alidade_smooth/{z}/{x}/{y}.png',
      );
    case _ResolvedTile.stadiaSmoothDark:
      return const MapTileConfig(
        urlTemplate: 'https://tiles.stadiamaps.com/tiles/alidade_smooth_dark/{z}/{x}/{y}.png',
      );
  }
}

/// Резолвит пользовательский выбор → конкретный тайл с учётом темы.
_ResolvedTile _resolve(MapTileSource source, {required bool isDark}) {
  switch (source) {
    case MapTileSource.openStreetMap:
      // OSM standard is too washed out in light mode; CARTO Voyager shows buildings/streets clearly
      return isDark ? _ResolvedTile.cartoDarkMatter : _ResolvedTile.cartoVoyager;
    case MapTileSource.cartoVoyager:
      return isDark ? _ResolvedTile.cartoDarkMatter : _ResolvedTile.cartoVoyager;
    case MapTileSource.cartoPositron:
      return isDark ? _ResolvedTile.cartoDarkMatter : _ResolvedTile.cartoPositron;
    case MapTileSource.esriSatellite:
      return _ResolvedTile.esriSatellite;
    case MapTileSource.stadiaSmooth:
      return isDark ? _ResolvedTile.stadiaSmoothDark : _ResolvedTile.stadiaSmooth;
  }
}

// ─────────────────────────────────────────────────
// Notifier (persisted choice)
// ─────────────────────────────────────────────────

const String _mapTileStorageKey = 'map_tile_source';

@riverpod
class MapTileSourceNotifier extends _$MapTileSourceNotifier {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    mOptions: MacOsOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  @override
  MapTileSource build() {
    _load();
    return MapTileSource.openStreetMap;
  }

  Future<void> _load() async {
    try {
      final saved = await _storage.read(key: _mapTileStorageKey);
      if (saved != null) {
        state = MapTileSource.values.firstWhere(
          (e) => e.name == saved,
          orElse: () => MapTileSource.openStreetMap,
        );
      }
    } catch (_) {
      // Ignore read errors — keep default
    }
  }

  Future<void> setSource(MapTileSource source) async {
    state = source;
    try {
      await _storage.write(key: _mapTileStorageKey, value: source.name);
    } catch (_) {
      // Ignore write errors
    }
  }
}

// ─────────────────────────────────────────────────
// Convenience: resolved tile config
// ─────────────────────────────────────────────────

@riverpod
MapTileConfig resolvedMapTileSource(Ref ref) {
  final source = ref.watch(mapTileSourceProvider);
  final isDark = ref.watch(isDarkModeProvider);
  final resolved = _resolve(source, isDark: isDark);
  return _configFor(resolved, isDark: isDark);
}
