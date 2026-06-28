// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_tile_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MapTileSourceNotifier)
final mapTileSourceProvider = MapTileSourceNotifierProvider._();

final class MapTileSourceNotifierProvider
    extends $NotifierProvider<MapTileSourceNotifier, MapTileSource> {
  MapTileSourceNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mapTileSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mapTileSourceNotifierHash();

  @$internal
  @override
  MapTileSourceNotifier create() => MapTileSourceNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MapTileSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MapTileSource>(value),
    );
  }
}

String _$mapTileSourceNotifierHash() =>
    r'56a56760de6b39cce2be21ba744612b6834159dc';

abstract class _$MapTileSourceNotifier extends $Notifier<MapTileSource> {
  MapTileSource build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<MapTileSource, MapTileSource>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MapTileSource, MapTileSource>,
              MapTileSource,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(resolvedMapTileSource)
final resolvedMapTileSourceProvider = ResolvedMapTileSourceProvider._();

final class ResolvedMapTileSourceProvider
    extends $FunctionalProvider<MapTileConfig, MapTileConfig, MapTileConfig>
    with $Provider<MapTileConfig> {
  ResolvedMapTileSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'resolvedMapTileSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$resolvedMapTileSourceHash();

  @$internal
  @override
  $ProviderElement<MapTileConfig> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MapTileConfig create(Ref ref) {
    return resolvedMapTileSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MapTileConfig value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MapTileConfig>(value),
    );
  }
}

String _$resolvedMapTileSourceHash() =>
    r'7706fc9db0dc9af4437120ab04080c77c342d4c6';
