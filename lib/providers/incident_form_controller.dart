import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/incident_models.dart';
import '../services/incident_service.dart';
import 'incident_form_state.dart';
export 'incident_form_state.dart';

part 'incident_form_controller.g.dart';



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
    return IncidentFormState(
      id: null,
      boilerHouseId: null,
      createdAt: DateTime.now(),
    );
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
  void updateCreatedAt(DateTime time) => state = state.copyWith(createdAt: time);
  void updateResolvedAt(DateTime? time) => state = state.copyWith(resolvedAt: time);
  void updateAssignedTo(int? userId) {
    state = state.copyWith(assignedTo: userId);
    // If a user is assigned, automatically switch notification to "User Based" for that user
    if (userId != null) {
      state = state.copyWith(
        notificationConfig: NotificationConfig(
          type: AudienceType.userBased,
          userIds: [userId],
        ),
      );
    }
  }
  void updateNotificationConfig(NotificationConfig? config) => state = state.copyWith(notificationConfig: config);
  
  void toggleHouse(int houseId) {
    final newSet = Set<int>.from(state.affectedHouseIds);
    if (newSet.contains(houseId)) {
      newSet.remove(houseId);
    } else {
      newSet.add(houseId);
    }
    state = state.copyWith(affectedHouseIds: newSet);
  }

  void toggleAllHouses(List<int> allHouseIds) {
    final newSet = Set<int>.from(state.affectedHouseIds);
    final allIncluded = allHouseIds.every((id) => newSet.contains(id));
    
    if (allIncluded) {
      // If all are selected, deselect all
      newSet.removeAll(allHouseIds);
    } else {
      // Otherwise select all
      newSet.addAll(allHouseIds);
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

    state = state.copyWith(isSaving: true);
    try {
      final service = ref.read(incidentServiceProvider);
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
          createdAt: state.createdAt.toIso8601String(),
          resolvedAt: state.resolvedAt?.toIso8601String(),
        );
        await service.updateIncident(state.id!, update);
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
          createdAt: state.createdAt.toIso8601String(),
        );
        await service.createIncident(create);
      }
      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: 'Ошибка сохранения: $e');
      return false;
    }
  }
}
