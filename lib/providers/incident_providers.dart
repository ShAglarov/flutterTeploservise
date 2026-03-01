import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/incident_models.dart';
import '../repositories/sync_repository.dart';
import '../providers/auth_provider.dart';

import '../services/user_service.dart';

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

@Riverpod(keepAlive: true)
class IncidentFilter extends _$IncidentFilter {
  @override
  IncidentFilterState build() => IncidentFilterState();

  void setQuickFilter(IncidentQuickFilter filter) => state = state.copyWith(quickFilter: filter);
  void setPeriod(IncidentPeriod period) => state = state.copyWith(period: period);
  void updateSearchQuery(String query) => state = state.copyWith(searchQuery: query);
  void setStoppedHotWater(bool? value) => state = state.copyWith(stoppedHotWater: value);
  void setStoppedHeating(bool? value) => state = state.copyWith(stoppedHeating: value);
}

final allIncidentsProvider = StreamProvider<List<IncidentResponse>>((ref) {
  // CRITICAL: Prevent instant destruction, but also throttle fast updates
  // to prevent UI cascades as requested (2 seconds rate limit).
  ref.keepAlive(); 
  final syncRepo = ref.watch(syncRepositoryProvider);
  return syncRepo.watchAllIncidents().transform(_ThrottleWithTrailingStreamTransformer(const Duration(seconds: 2)));
});

class _ThrottleWithTrailingStreamTransformer<T> extends StreamTransformerBase<T, T> {
  final Duration duration;
  _ThrottleWithTrailingStreamTransformer(this.duration);

  @override
  Stream<T> bind(Stream<T> stream) {
    Timer? timer;
    StreamController<T>? controller;
    StreamSubscription<T>? subscription;
    T? pendingEvent;
    bool hasPending = false;

    void emitPending() {
      if (hasPending && controller != null && !controller.isClosed) {
        controller.add(pendingEvent as T);
        hasPending = false;
        pendingEvent = null;
        timer = Timer(duration, emitPending);
      } else {
        timer = null;
      }
    }

    controller = StreamController<T>(
      onListen: () {
        subscription = stream.listen((event) {
          if (timer == null || !timer!.isActive) {
            controller?.add(event);
            timer = Timer(duration, emitPending);
          } else {
            hasPending = true;
            pendingEvent = event;
          }
        },
        onError: controller?.addError,
        onDone: () {
          if (hasPending && controller != null && !controller.isClosed) {
            controller.add(pendingEvent as T);
          }
          controller?.close();
        });
      },
      onPause: () => subscription?.pause(),
      onResume: () => subscription?.resume(),
      onCancel: () {
        subscription?.cancel();
        timer?.cancel();
      },
    );

    return controller.stream;
  }
}

// Global Event Stream for explicit UI refreshes bypassing Riverpod caches
final globalRefreshEventControllerProvider = Provider<StreamController<void>>((ref) {
  final controller = StreamController<void>.broadcast();
  ref.onDispose(controller.close);
  return controller;
});

final globalRefreshEventProvider = StreamProvider<void>((ref) {
  return ref.watch(globalRefreshEventControllerProvider).stream;
});

class IncidentViewModel {
  final IncidentResponse raw;
  final String? boilerHouseDetail;
  final int totalResidents;
  final String? assigneeName;
  final String formattedTimestamp;
  final String? stoppedServicesText;
  final String? broadcastText;

  IncidentViewModel({
    required this.raw,
    this.boilerHouseDetail,
    required this.totalResidents,
    this.assigneeName,
    required this.formattedTimestamp,
    this.stoppedServicesText,
    this.broadcastText,
  });
}

final incidentViewModelsProvider = Provider<AsyncValue<List<IncidentViewModel>>>((ref) {
  final filteredAsync = ref.watch(filteredIncidentsProvider);
  final usersMap = ref.watch(usersMapProvider).value ?? {};

  return filteredAsync.whenData((incidents) {
    if (incidents.isEmpty) return [];
    return incidents.map((inc) {
      String? boilerHouseDetail;
      if (inc.boilerHouse != null) {
        boilerHouseDetail = 'Нач: ${inc.boilerHouse!.siteManager ?? "?"} | Участок: ${inc.boilerHouse!.siteNumber ?? "?"}';
      }
      return _createViewModel(inc, boilerHouseDetail, usersMap);
    }).toList();
  });
});

IncidentViewModel _createViewModel(IncidentResponse inc, String? boilerHouseDetail, Map<int, dynamic> usersMap) {
  // 1. Total Residents
  int totalResidents = 0;
  if (inc.affectedHouseDetails != null) {
    for (final hd in inc.affectedHouseDetails!) {
      totalResidents += (hd.residentsCount ?? 0);
    }
  }

  // 2. Assignee Name
  String? assigneeName;
  if (inc.assignedTo != null) {
    final user = usersMap[inc.assignedTo];
    if (user != null) {
      assigneeName = user.formattedDisplayName;
    } else {
      assigneeName = 'Неизвестный (${inc.assignedTo})';
    }
  }

  // 3. Timestamp
  final startDt = inc.createdAt != null && inc.createdAt!.isNotEmpty ? DateTime.tryParse(inc.createdAt!)?.toLocal() : null;
  final startStr = startDt != null ? '${startDt.day.toString().padLeft(2, '0')}.${startDt.month.toString().padLeft(2, '0')}.${startDt.year} ${startDt.hour.toString().padLeft(2, '0')}:${startDt.minute.toString().padLeft(2, '0')}' : inc.createdAt ?? '';
  
  String formattedTimestamp;
  if (inc.status == IncidentStatus.resolved || inc.status == IncidentStatus.closed) {
    final endDtStr = inc.resolvedAt ?? inc.updatedAt;
    final endDt = endDtStr != null && endDtStr.isNotEmpty ? DateTime.tryParse(endDtStr)?.toLocal() : null;
    final endStr = endDt != null ? '${endDt.day.toString().padLeft(2, '0')}.${endDt.month.toString().padLeft(2, '0')}.${endDt.year} ${endDt.hour.toString().padLeft(2, '0')}:${endDt.minute.toString().padLeft(2, '0')}' : endDtStr ?? '';
    formattedTimestamp = 'с $startStr до $endStr';
  } else {
    formattedTimestamp = 'с $startStr до по наст. время';
  }

  // 4. Stopped Services
  List<String> stopped = [];
  if (inc.resourceHotWaterStopped == 1) stopped.add('ГВС');
  if (inc.resourceHeatingStopped == 1) stopped.add('Отопление');
  final stoppedServicesText = stopped.isEmpty ? null : stopped.join(', ');

  // 5. Broadcast Text
  String? broadcastText;
  if (inc.notificationConfig != null) {
    if (inc.notificationConfig!.type == AudienceType.broadcast) {
      broadcastText = 'Все (Broadcast)';
    } else {
      broadcastText = 'Роли/Пользователи (${inc.notificationConfig!.type.name})';
    }
  }

  return IncidentViewModel(
    raw: inc,
    boilerHouseDetail: boilerHouseDetail,
    totalResidents: totalResidents,
    assigneeName: assigneeName,
    formattedTimestamp: formattedTimestamp,
    stoppedServicesText: stoppedServicesText,
    broadcastText: broadcastText,
  );
}

final filteredIncidentsProvider = Provider<AsyncValue<List<IncidentResponse>>>((ref) {
  final allAsync = ref.watch(allIncidentsProvider);
  final filter = ref.watch(incidentFilterProvider);
  final authState = ref.watch(authProvider);
  final currentUserId = int.tryParse(authState.user?.id ?? '');
  
  return allAsync.whenData((incidents) {
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
        if (inc.status?.name.toLowerCase().contains('closed') ?? false) return false;
      } else if (filter.quickFilter == IncidentQuickFilter.assignedToMe) {
        if (currentUserId != null && inc.assignedTo != currentUserId) return false;
      }

      // 3. Period (Simplified)
      if (filter.period != IncidentPeriod.allTime) {
        final now = DateTime.now();
        final incidentDate = inc.createdAt != null && inc.createdAt!.isNotEmpty ? DateTime.tryParse(inc.createdAt!)?.toLocal() : null;
        if (incidentDate != null) {
          if (filter.period == IncidentPeriod.today) {
            final startOfDay = DateTime(now.year, now.month, now.day);
            if (incidentDate.isBefore(startOfDay)) return false;
          } else if (filter.period == IncidentPeriod.thisWeek) {
            final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
            final startOfWeekDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
            if (incidentDate.isBefore(startOfWeekDate)) return false;
          }
        }
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
});



@Riverpod(keepAlive: true)
Stream<IncidentResponse?> singleIncident(Ref ref, int id) {
  final syncRepo = ref.watch(syncRepositoryProvider);
  return syncRepo.watchIncidentById(id);
}
