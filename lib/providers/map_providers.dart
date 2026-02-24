import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/boiler_house_models.dart';
import '../models/location_models.dart';
import '../models/incident_models.dart';
import '../repositories/sync_repository.dart';
import '../services/boiler_house_service.dart';
import '../services/location_service.dart';
import '../services/incident_service.dart';

part 'map_providers.g.dart';

class MapDataState {
  final List<BoilerHouseResponse> boilerHouses;
  final List<SavedLocationResponse> locations;
  final List<IncidentResponse> incidents;
  /// Boiler house IDs that have at least one active (non-resolved/closed) incident.
  final Set<int> boilerHouseIdsWithIncidents;
  /// Location IDs that are affected by at least one active incident.
  final Set<int> locationIdsWithIncidents;
  final bool isLoading;
  final String? error;

  MapDataState({
    this.boilerHouses = const [],
    this.locations = const [],
    this.incidents = const [],
    this.boilerHouseIdsWithIncidents = const {},
    this.locationIdsWithIncidents = const {},
    this.isLoading = false,
    this.error,
  });

  MapDataState copyWith({
    List<BoilerHouseResponse>? boilerHouses,
    List<SavedLocationResponse>? locations,
    List<IncidentResponse>? incidents,
    Set<int>? boilerHouseIdsWithIncidents,
    Set<int>? locationIdsWithIncidents,
    bool? isLoading,
    String? error,
  }) {
    return MapDataState(
      boilerHouses: boilerHouses ?? this.boilerHouses,
      locations: locations ?? this.locations,
      incidents: incidents ?? this.incidents,
      boilerHouseIdsWithIncidents: boilerHouseIdsWithIncidents ?? this.boilerHouseIdsWithIncidents,
      locationIdsWithIncidents: locationIdsWithIncidents ?? this.locationIdsWithIncidents,
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

@Riverpod(keepAlive: true)
class MapData extends _$MapData {
  @override
  MapDataState build() {
    final syncRepo = ref.watch(syncRepositoryProvider);
    
    // 1. Subscribe to local DB streams for reactive updates
    final bhSub = syncRepo.watchAllBoilerHouses().listen((bhs) {
      state = state.copyWith(boilerHouses: bhs, isLoading: false);
    }, onError: (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    });
    
    final locSub = syncRepo.watchAllLocations().listen((locs) {
      state = state.copyWith(locations: locs, isLoading: false);
    }, onError: (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    });

    // 2. Subscribe to incidents stream for reactive pin coloring
    final incSub = syncRepo.watchAllIncidents().listen((incidents) {
      final activeIncidents = incidents.where((inc) =>
        inc.status != IncidentStatus.resolved &&
        inc.status != IncidentStatus.closed
      ).toList();

      // Compute which boiler houses have active incidents
      final bhIds = <int>{};
      for (final inc in activeIncidents) {
        if (inc.boilerHouseId != null) {
          bhIds.add(inc.boilerHouseId!);
        }
      }

      // Compute which locations are affected by active incidents
      final locIds = <int>{};
      for (final inc in activeIncidents) {
        if (inc.affectedHouseIds != null) {
          locIds.addAll(inc.affectedHouseIds!);
        }
      }

      state = state.copyWith(
        incidents: incidents,
        boilerHouseIdsWithIncidents: bhIds,
        locationIdsWithIncidents: locIds,
        isLoading: false,
      );
    }, onError: (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    });
    
    ref.onDispose(() {
      bhSub.cancel();
      locSub.cancel();
      incSub.cancel();
    });

    // 3. Kick off initial fetch from the backend API to populate the local DB
    _fetchInitialData();

    return MapDataState(isLoading: true);
  }

  Future<void> _fetchInitialData() async {
    try {
      final syncRepo = ref.read(syncRepositoryProvider);
      await syncRepo.deduplicateSavedLocations();

      final bhService = ref.read(boilerHouseServiceProvider);
      final locService = ref.read(locationServiceProvider);
      final incService = ref.read(incidentServiceProvider);

      await Future.wait([
        bhService.getAllBoilerHouses(),
        locService.getAllSavedLocations(),
        incService.getAllIncidents(),
      ]);
      print('✅ [MapData] Initial data fetch complete');
    } catch (e) {
      print('⚠️ [MapData] Initial data fetch failed: $e');
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
  }

  // 3. Filter by Incidents
  if (filter.showOnlyIncidents) {
    boilerHouses = boilerHouses.where((bh) => dataState.boilerHouseIdsWithIncidents.contains(bh.id)).toList();
    locations = locations.where((loc) => dataState.locationIdsWithIncidents.contains(loc.id)).toList();
  }

  // 4. Sort by Incidents (Boiler houses with incidents first, then by address)
  boilerHouses.sort((a, b) {
    final aHas = dataState.boilerHouseIdsWithIncidents.contains(a.id);
    final bHas = dataState.boilerHouseIdsWithIncidents.contains(b.id);
    if (aHas && !bHas) return -1;
    if (!aHas && bHas) return 1;
    return a.address.compareTo(b.address);
  });

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

// flutter_map MapController is managed outside Riverpod since it has its own lifecycle
