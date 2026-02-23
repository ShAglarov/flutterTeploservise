// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MapData)
final mapDataProvider = MapDataProvider._();

final class MapDataProvider extends $NotifierProvider<MapData, MapDataState> {
  MapDataProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mapDataProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mapDataHash();

  @$internal
  @override
  MapData create() => MapData();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MapDataState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MapDataState>(value),
    );
  }
}

String _$mapDataHash() => r'638d59a7252b623b07cee5ae3c14019031572129';

abstract class _$MapData extends $Notifier<MapDataState> {
  MapDataState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<MapDataState, MapDataState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MapDataState, MapDataState>,
              MapDataState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(MapSearchQuery)
final mapSearchQueryProvider = MapSearchQueryProvider._();

final class MapSearchQueryProvider
    extends $NotifierProvider<MapSearchQuery, String> {
  MapSearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mapSearchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mapSearchQueryHash();

  @$internal
  @override
  MapSearchQuery create() => MapSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$mapSearchQueryHash() => r'4fb885435253a097b940d8dd1511ccfa214ce314';

abstract class _$MapSearchQuery extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(MapFilter)
final mapFilterProvider = MapFilterProvider._();

final class MapFilterProvider
    extends $NotifierProvider<MapFilter, MapFilterState> {
  MapFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mapFilterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mapFilterHash();

  @$internal
  @override
  MapFilter create() => MapFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MapFilterState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MapFilterState>(value),
    );
  }
}

String _$mapFilterHash() => r'546fed269d2d974177e0f629d004e9a324d828ad';

abstract class _$MapFilter extends $Notifier<MapFilterState> {
  MapFilterState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<MapFilterState, MapFilterState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MapFilterState, MapFilterState>,
              MapFilterState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(filteredMapData)
final filteredMapDataProvider = FilteredMapDataProvider._();

final class FilteredMapDataProvider
    extends $FunctionalProvider<MapDataState, MapDataState, MapDataState>
    with $Provider<MapDataState> {
  FilteredMapDataProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredMapDataProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredMapDataHash();

  @$internal
  @override
  $ProviderElement<MapDataState> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MapDataState create(Ref ref) {
    return filteredMapData(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MapDataState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MapDataState>(value),
    );
  }
}

String _$filteredMapDataHash() => r'9ca0e732da4c2775333f413c7d8e93d355492f48';

@ProviderFor(mapSections)
final mapSectionsProvider = MapSectionsProvider._();

final class MapSectionsProvider
    extends $FunctionalProvider<List<String>, List<String>, List<String>>
    with $Provider<List<String>> {
  MapSectionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mapSectionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mapSectionsHash();

  @$internal
  @override
  $ProviderElement<List<String>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<String> create(Ref ref) {
    return mapSections(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$mapSectionsHash() => r'9026c7fafe752c8f692f6606d7c5f3f4875385a8';

@ProviderFor(MapController)
final mapControllerProvider = MapControllerProvider._();

final class MapControllerProvider
    extends $NotifierProvider<MapController, GoogleMapController?> {
  MapControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mapControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mapControllerHash();

  @$internal
  @override
  MapController create() => MapController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoogleMapController? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoogleMapController?>(value),
    );
  }
}

String _$mapControllerHash() => r'a8aeeab509817dcf6a2fa86bf5ea0cf5d6125a00';

abstract class _$MapController extends $Notifier<GoogleMapController?> {
  GoogleMapController? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<GoogleMapController?, GoogleMapController?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<GoogleMapController?, GoogleMapController?>,
              GoogleMapController?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
