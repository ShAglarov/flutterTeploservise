import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/incident_models.dart';
import '../repositories/sync_repository.dart';

part 'incident_providers.g.dart';

enum IncidentQuickFilter { all, active, assignedToMe }
enum IncidentPeriod { allTime, today, thisWeek }

class IncidentFilterState {
  final IncidentQuickFilter quickFilter;
  final IncidentPeriod period;
  final String searchQuery;
  final bool? stoppedHotWater;
  final bool? stoppedHeating;

  IncidentFilterState({
    this.quickFilter = IncidentQuickFilter.all,
    this.period = IncidentPeriod.allTime,
    this.searchQuery = '',
    this.stoppedHotWater,
    this.stoppedHeating,
  });

  IncidentFilterState copyWith({
    IncidentQuickFilter? quickFilter,
    IncidentPeriod? period,
    String? searchQuery,
    bool? stoppedHotWater,
    bool? stoppedHeating,
  }) {
    return IncidentFilterState(
      quickFilter: quickFilter ?? this.quickFilter,
      period: period ?? this.period,
      searchQuery: searchQuery ?? this.searchQuery,
      stoppedHotWater: stoppedHotWater ?? this.stoppedHotWater,
      stoppedHeating: stoppedHeating ?? this.stoppedHeating,
    );
  }
}

@riverpod
class IncidentFilter extends _$IncidentFilter {
  @override
  IncidentFilterState build() => IncidentFilterState();

  void setQuickFilter(IncidentQuickFilter filter) => state = state.copyWith(quickFilter: filter);
  void setPeriod(IncidentPeriod period) => state = state.copyWith(period: period);
  void updateSearchQuery(String query) => state = state.copyWith(searchQuery: query);
  void setStoppedHotWater(bool? value) => state = state.copyWith(stoppedHotWater: value);
  void setStoppedHeating(bool? value) => state = state.copyWith(stoppedHeating: value);
}

@riverpod
Stream<List<IncidentResponse>> allIncidents(Ref ref) {
  final syncRepo = ref.watch(syncRepositoryProvider);
  return syncRepo.watchAllIncidents();
}

@riverpod
AsyncValue<List<IncidentResponse>> filteredIncidents(Ref ref) {
  final allIncidentsAsync = ref.watch(allIncidentsProvider);
  final filter = ref.watch(incidentFilterProvider);

  return allIncidentsAsync.whenData((incidents) {
    return incidents.where((inc) {
      // 1. Search Query
      if (filter.searchQuery.isNotEmpty) {
        final query = filter.searchQuery.toLowerCase();
        final matches = (inc.title?.toLowerCase().contains(query) ?? false) ||
            (inc.description?.toLowerCase().contains(query) ?? false);
        if (!matches) return false;
      }

      // 2. Quick Filter
      if (filter.quickFilter == IncidentQuickFilter.active) {
        if (inc.status?.name.toLowerCase().contains('resolved') ?? false) return false;
      }
      // Note: assignedToMe would require current user ID

      // 3. Period (Simplified)
      if (filter.period != IncidentPeriod.allTime) {
        // Here we would parse inc.startedAt and check against current date
      }

      // 4. Resources
      if (filter.stoppedHotWater != null) {
        final isStopped = inc.resourceHotWaterStopped == 1;
        if (isStopped != filter.stoppedHotWater) return false;
      }
      if (filter.stoppedHeating != null) {
        final isStopped = inc.resourceHeatingStopped == 1;
        if (isStopped != filter.stoppedHeating) return false;
      }

      return true;
    }).toList();
  });
}

@riverpod
Stream<IncidentResponse?> singleIncident(Ref ref, int id) {
  final syncRepo = ref.watch(syncRepositoryProvider);
  return syncRepo.watchIncidentById(id);
}
