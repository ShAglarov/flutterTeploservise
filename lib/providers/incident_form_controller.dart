import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/incident_models.dart';
import '../repositories/sync_repository.dart';

part 'incident_form_controller.g.dart';

class IncidentFormState {
  final int? id;
  final int? boilerHouseId;
  final String title;
  final String description;
  final IncidentStatus status;
  final String severity;
  final bool stopHotWater;
  final bool stopHeating;
  final Set<int> affectedHouseIds;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final int? assignedTo;
  final NotificationConfig? notificationConfig;
  final bool isSaving;
  final String? errorMessage;

  IncidentFormState({
    this.id,
    this.boilerHouseId,
    this.title = '',
    this.description = '',
    this.status = IncidentStatus.open,
    this.severity = '1',
    this.stopHotWater = false,
    this.stopHeating = false,
    this.affectedHouseIds = const {},
    DateTime? createdAt,
    this.resolvedAt,
    this.assignedTo,
    this.notificationConfig,
    this.isSaving = false,
    this.errorMessage,
  }) : createdAt = createdAt ?? DateTime.now();

  IncidentFormState copyWith({
    int? id,
    int? boilerHouseId,
    String? title,
    String? description,
    IncidentStatus? status,
    String? severity,
    bool? stopHotWater,
    bool? stopHeating,
    Set<int>? affectedHouseIds,
    DateTime? createdAt,
    DateTime? resolvedAt,
    int? assignedTo,
    NotificationConfig? notificationConfig,
    bool? isSaving,
    String? errorMessage,
  }) {
    return IncidentFormState(
      id: id ?? this.id,
      boilerHouseId: boilerHouseId ?? this.boilerHouseId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      severity: severity ?? this.severity,
      stopHotWater: stopHotWater ?? this.stopHotWater,
      stopHeating: stopHeating ?? this.stopHeating,
      affectedHouseIds: affectedHouseIds ?? this.affectedHouseIds,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      assignedTo: assignedTo ?? this.assignedTo,
      notificationConfig: notificationConfig ?? this.notificationConfig,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
    );
  }
}

@riverpod
class IncidentFormController extends _$IncidentFormController {
  @override
  IncidentFormState build(IncidentResponse? initialIncident) {
    if (initialIncident != null) {
      return IncidentFormState(
        id: initialIncident.id,
        boilerHouseId: initialIncident.boilerHouseId,
        title: initialIncident.title ?? '',
        description: initialIncident.description ?? '',
        status: initialIncident.status ?? IncidentStatus.open,
        severity: initialIncident.severity ?? '1',
        stopHotWater: initialIncident.resourceHotWaterStopped == 1,
        stopHeating: initialIncident.resourceHeatingStopped == 1,
        affectedHouseIds: initialIncident.affectedHouseIds?.toSet() ?? {},
        createdAt: DateTime.tryParse(initialIncident.createdAt ?? '') ?? DateTime.now(),
        resolvedAt: DateTime.tryParse(initialIncident.resolvedAt ?? ''),
        assignedTo: initialIncident.assignedTo,
        notificationConfig: initialIncident.notificationConfig,
      );
    }
    return IncidentFormState();
  }

  void updateTitle(String value) => state = state.copyWith(title: value);
  void updateDescription(String value) => state = state.copyWith(description: value);
  void updateStatus(IncidentStatus value) {
    state = state.copyWith(
      status: value,
      resolvedAt: value == IncidentStatus.resolved ? DateTime.now() : null,
    );
  }
  void updateSeverity(String value) => state = state.copyWith(severity: value);
  void updateStopHotWater(bool value) => state = state.copyWith(stopHotWater: value);
  void updateStopHeating(bool value) => state = state.copyWith(stopHeating: value);
  void updateBoilerHouse(int? id) => state = state.copyWith(boilerHouseId: id);
  
  void toggleHouse(int houseId) {
    final newSet = Set<int>.from(state.affectedHouseIds);
    if (newSet.contains(houseId)) {
      newSet.remove(houseId);
    } else {
      newSet.add(houseId);
    }
    state = state.copyWith(affectedHouseIds: newSet);
  }

  Future<bool> save() async {
    if (state.boilerHouseId == null || state.title.isEmpty) {
      state = state.copyWith(errorMessage: 'Заполните обязательные поля');
      return false;
    }

    if (!state.stopHotWater && !state.stopHeating) {
      state = state.copyWith(errorMessage: 'Выберите хотя бы одну проблему');
      return false;
    }

    if (state.affectedHouseIds.isEmpty) {
      state = state.copyWith(errorMessage: 'Выберите затронутые дома');
      return false;
    }

    try {
      final syncRepo = ref.read(syncRepositoryProvider);
      if (state.id != null) {
        final update = IncidentUpdate(
          id: state.id,
          title: state.title,
          description: state.description,
          status: state.status,
          severity: state.severity,
          resourceHotWaterStopped: state.stopHotWater ? 1 : 0,
          resourceHeatingStopped: state.stopHeating ? 1 : 0,
          affectedHouseIds: state.affectedHouseIds.toList(),
          assignedTo: state.assignedTo,
          notificationConfig: state.notificationConfig,
        );
        await syncRepo.saveIncidentOffline(update: update);
      } else {
        final create = IncidentCreate(
          boilerHouseId: state.boilerHouseId!,
          title: state.title,
          description: state.description,
          status: state.status,
          severity: state.severity,
          resourceHotWaterStopped: state.stopHotWater ? 1 : 0,
          resourceHeatingStopped: state.stopHeating ? 1 : 0,
          affectedHouseIds: state.affectedHouseIds.toList(),
          assignedTo: state.assignedTo,
          notificationConfig: state.notificationConfig,
        );
        await syncRepo.saveIncidentOffline(create: create);
      }
      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: 'Ошибка сохранения: $e');
      return false;
    }
  }
}
