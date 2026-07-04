import 'dart:async';
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
    Object? error = _sentinel,
  }) {
    return MapDataState(
      boilerHouses: boilerHouses ?? this.boilerHouses,
      locations: locations ?? this.locations,
      incidents: incidents ?? this.incidents,
      boilerHouseIdsWithIncidents: boilerHouseIdsWithIncidents ?? this.boilerHouseIdsWithIncidents,
      locationIdsWithIncidents: locationIdsWithIncidents ?? this.locationIdsWithIncidents,
      isLoading: isLoading ?? this.isLoading,
      error: error == _sentinel ? this.error : (error as String?),
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
    Object? selectedSection = _sentinel,
    bool? showOnlyIncidents,
  }) {
    return MapFilterState(
      selectedSection: selectedSection == _sentinel ? this.selectedSection : (selectedSection as String?),
      showOnlyIncidents: showOnlyIncidents ?? this.showOnlyIncidents,
    );
  }
}

const Object _sentinel = Object();

@Riverpod(keepAlive: true)
class MapData extends _$MapData {
  @override
  MapDataState build() {
    final syncRepo = ref.watch(syncRepositoryProvider);
    
    // 1. Subscribe to local DB streams for reactive updates
    final bhSub = syncRepo.watchAllBoilerHouses().listen((bhs) {
      _applyBatchUpdate((s) => s.copyWith(boilerHouses: bhs, isLoading: false));
    }, onError: (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    });
    
    final locSub = syncRepo.watchAllLocations().listen((locs) {
      _applyBatchUpdate((s) => s.copyWith(locations: locs, isLoading: false));
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

      _applyBatchUpdate((s) => s.copyWith(
        incidents: incidents,
        boilerHouseIdsWithIncidents: bhIds,
        locationIdsWithIncidents: locIds,
        isLoading: false,
      ));
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

  /// Applies state update immediately (reliance is on SyncRepository debounce)
  void _applyBatchUpdate(MapDataState Function(MapDataState) updater) {
    state = updater(state);
  }

  bool _isFetching = false;
  int _fetchRetryCount = 0;
  static const _maxFetchRetries = 2;

  Future<void> _fetchInitialData() async {
    if (_isFetching) {
      print('⏭️ [MapData] _fetchInitialData already in progress, skipping');
      return;
    }
    _isFetching = true;

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
      _fetchRetryCount = 0; // Reset on success
      print('✅ [MapData] Initial data fetch complete');
    } catch (e) {
      print('⚠️ [MapData] Initial data fetch failed: $e');
      _fetchRetryCount++;
      if (_fetchRetryCount <= _maxFetchRetries) {
        final delay = Duration(seconds: _fetchRetryCount * 5);
        print('🔄 [MapData] Retry $_fetchRetryCount/$_maxFetchRetries in ${delay.inSeconds}s');
        Future.delayed(delay, () {
          _isFetching = false;
          _fetchInitialData();
        });
        return; // Don't reset _isFetching yet
      } else {
        print('❌ [MapData] Max retries reached, giving up');
      }
    } finally {
      if (_fetchRetryCount == 0 || _fetchRetryCount > _maxFetchRetries) {
        _isFetching = false;
      }
    }
  }
}

@Riverpod(keepAlive: true)
class MapSearchQuery extends _$MapSearchQuery {
  @override
  String build() => '';

  void update(String query) => state = query;
}

@Riverpod(keepAlive: true)
class MapFilter extends _$MapFilter {
  @override
  MapFilterState build() => MapFilterState();

  void setSection(String? section) => state = state.copyWith(selectedSection: section);
  void toggleOnlyIncidents() => state = state.copyWith(showOnlyIncidents: !state.showOnlyIncidents);
}

@Riverpod(keepAlive: true)
MapDataState filteredMapData(Ref ref) {
  final dataState = ref.watch(mapDataProvider);
  final query = ref.watch(mapSearchQueryProvider).toLowerCase();
  final filter = ref.watch(mapFilterProvider);

  var boilerHouses = dataState.boilerHouses.toList();
  var locations = dataState.locations.toList();

  // 1. Filter by Query
  if (query.isNotEmpty) {
    // Build a set of boiler house IDs that have at least one linked house
    // matching the search query (by house name or management company).
    // This mirrors the iOS Core Data predicate:
    //   ANY savedLocations.name CONTAINS[cd] %@
    //   ANY savedLocations.managementCompany CONTAINS[cd] %@
    final matchedBhIdsByHouse = <int>{};
    for (final loc in locations) {
      final nameMatches = loc.name.toLowerCase().contains(query);
      final mcMatches = loc.managementCompanyName?.toLowerCase().contains(query) ?? false;
      if ((nameMatches || mcMatches) && loc.boilerHouseId != null) {
        matchedBhIdsByHouse.add(loc.boilerHouseId!);
      }
    }

    boilerHouses = boilerHouses.where((bh) {
      // Direct match on boiler house fields
      final directMatch = bh.address.toLowerCase().contains(query) ||
             (bh.siteManager?.toLowerCase().contains(query) ?? false) ||
             (bh.siteNumber?.toLowerCase().contains(query) ?? false);
      // Indirect match: a linked house name/management company matches
      final houseMatch = matchedBhIdsByHouse.contains(bh.id);
      return directMatch || houseMatch;
    }).toList();

    // Собрать ID всех найденных котельных, чтобы включить их дома в результат
    final matchedBhIds = boilerHouses.map((bh) => bh.id).toSet();

    locations = locations.where((loc) =>
      loc.name.toLowerCase().contains(query) ||
      (loc.managementCompanyName?.toLowerCase().contains(query) ?? false) ||
      // Включаем дома, принадлежащие найденным котельным
      (loc.boilerHouseId != null && matchedBhIds.contains(loc.boilerHouseId))
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

@Riverpod(keepAlive: true)
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
