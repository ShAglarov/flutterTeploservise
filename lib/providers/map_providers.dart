import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/boiler_house_models.dart';
import '../models/location_models.dart';
import '../services/boiler_house_service.dart';
import '../services/location_service.dart';

part 'map_providers.g.dart';

class MapDataState {
  final List<BoilerHouseResponse> boilerHouses;
  final List<SavedLocationResponse> locations;
  final bool isLoading;
  final String? error;

  MapDataState({
    this.boilerHouses = const [],
    this.locations = const [],
    this.isLoading = false,
    this.error,
  });

  MapDataState copyWith({
    List<BoilerHouseResponse>? boilerHouses,
    List<SavedLocationResponse>? locations,
    bool? isLoading,
    String? error,
  }) {
    return MapDataState(
      boilerHouses: boilerHouses ?? this.boilerHouses,
      locations: locations ?? this.locations,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class MapFilterState {
  final String? selectedSection;
  final bool showOnlyIncidents;

  MapFilterState({
    this.selectedSection,
    this.showOnlyIncidents = false,
  });

  MapFilterState copyWith({
    String? selectedSection,
    bool? showOnlyIncidents,
  }) {
    return MapFilterState(
      selectedSection: selectedSection ?? this.selectedSection,
      showOnlyIncidents: showOnlyIncidents ?? this.showOnlyIncidents,
    );
  }
}

@riverpod
class MapData extends _$MapData {
  @override
  MapDataState build() {
    // Initial load
    Future.microtask(() => loadData());
    return MapDataState(isLoading: true);
  }

  Future<void> loadData() async {
    final bhService = ref.read(boilerHouseServiceProvider);
    final locService = ref.read(locationServiceProvider);

    state = state.copyWith(isLoading: true);
    try {
      final bhs = await bhService.getAllBoilerHouses();
      final locs = await locService.getAllSavedLocations();
      state = state.copyWith(
        boilerHouses: bhs,
        locations: locs,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

@riverpod
class MapSearchQuery extends _$MapSearchQuery {
  @override
  String build() => '';

  void update(String query) => state = query;
}

@riverpod
class MapFilter extends _$MapFilter {
  @override
  MapFilterState build() => MapFilterState();

  void setSection(String? section) => state = state.copyWith(selectedSection: section);
  void toggleOnlyIncidents() => state = state.copyWith(showOnlyIncidents: !state.showOnlyIncidents);
}

@riverpod
MapDataState filteredMapData(Ref ref) {
  final dataState = ref.watch(mapDataProvider);
  final query = ref.watch(mapSearchQueryProvider).toLowerCase();
  final filter = ref.watch(mapFilterProvider);

  var boilerHouses = dataState.boilerHouses;
  var locations = dataState.locations;

  // 1. Filter by Query
  if (query.isNotEmpty) {
    boilerHouses = boilerHouses.where((bh) {
      return bh.address.toLowerCase().contains(query) ||
             (bh.siteManager?.toLowerCase().contains(query) ?? false) ||
             (bh.siteNumber?.toLowerCase().contains(query) ?? false);
    }).toList();

    locations = locations.where((loc) =>
      loc.name.toLowerCase().contains(query) ||
      (loc.managementCompanyName?.toLowerCase().contains(query) ?? false)
    ).toList();
  }

  // 2. Filter by Section
  if (filter.selectedSection != null) {
    boilerHouses = boilerHouses.where((bh) => bh.siteNumber == filter.selectedSection).toList();
    // Locations don't have a direct section link in models, but we could find them by BH association.
    // For now, only filter BH by section.
  }

  // 3. Filter by Incidents
  if (filter.showOnlyIncidents) {
    boilerHouses = boilerHouses.where((bh) => (bh.incidentCount ?? 0) > 0).toList();
    locations = []; // Assuming locations don't track incidents directly in this view
  }

  return dataState.copyWith(boilerHouses: boilerHouses, locations: locations);
}

@riverpod
List<String> mapSections(Ref ref) {
  final dataState = ref.watch(mapDataProvider);
  final sections = dataState.boilerHouses
      .map((bh) => bh.siteNumber)
      .whereType<String>()
      .toSet()
      .toList();
  sections.sort();
  return sections;
}

@riverpod
class MapController extends _$MapController {
  @override
  GoogleMapController? build() => null;

  void set(GoogleMapController controller) => state = controller;

  void move(LatLng target, {double zoom = 15}) {
    state?.animateCamera(CameraUpdate.newLatLngZoom(target, zoom));
  }
}
