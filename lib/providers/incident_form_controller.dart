import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';
import '../models/incident_models.dart';
import '../services/incident_service.dart';
import '../providers/offline_edit_permission.dart';
import '../repositories/sync_repository.dart';
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
        startedAt: DateTime.tryParse(initialIncident.startedAt ?? ''),
        finishedAt: DateTime.tryParse(initialIncident.finishedAt ?? ''),
        autoResolveOnFinish: initialIncident.autoResolveOnFinish,
        assignedTo: initialIncident.assignedTo,
        notificationConfig: initialIncident.notificationConfig,
        inactiveBoilers: initialIncident.inactiveBoilerNumbers?.toSet() ?? {},
        supplyFullyStopped: initialIncident.supplyFullyStopped ?? false,
      );
    }
    return IncidentFormState(
      id: null,
      boilerHouseId: null,
      createdAt: DateTime.now(),
      startedAt: DateTime.now(),
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
  void updateStartedAt(DateTime time) => state = state.copyWith(startedAt: time);
  void updateFinishedAt(DateTime? time) => state = state.copyWith(finishedAt: time);
  void updateAutoResolveOnFinish(bool value) => state = state.copyWith(autoResolveOnFinish: value);
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
  
  void updateNotificationRoles(List<String> roleIds) {
    final current = state.notificationConfig ?? NotificationConfig(type: AudienceType.roleBased);
    state = state.copyWith(notificationConfig: NotificationConfig(
      type: current.type,
      userIds: current.userIds,
      roleIds: roleIds,
    ));
  }
  
  void setError(String message) {
    state = state.copyWith(errorMessage: message);
  }

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

  /// Переключает состояние котла (работает / не работает)
  void toggleBoiler(int boilerNumber) {
    final newSet = Set<int>.from(state.inactiveBoilers);
    if (newSet.contains(boilerNumber)) {
      newSet.remove(boilerNumber);
    } else {
      newSet.add(boilerNumber);
    }
    state = state.copyWith(inactiveBoilers: newSet);
  }

  /// Устанавливает тумблер "Не поступает полностью".
  /// При включении — сбрасываем чипы котлов (тумблер имеет приоритет).
  void updateSupplyFullyStopped(bool value) {
    state = state.copyWith(
      supplyFullyStopped: value,
      inactiveBoilers: value ? {} : state.inactiveBoilers,
    );
  }

  Future<bool> save() async {
    if (state.boilerHouseId == null || state.title.isEmpty) {
      state = state.copyWith(errorMessage: 'Заполните обязательные поля');
      return false;
    }

    // Проблема указана если: остановлен ГВС/отопление, ИЛИ есть неработающие котлы, ИЛИ полная остановка
    final hasStoppedResource = state.stopHotWater || state.stopHeating;
    final hasBoilerIssue = state.inactiveBoilers.isNotEmpty || state.supplyFullyStopped;
    if (!hasStoppedResource && !hasBoilerIssue) {
      state = state.copyWith(errorMessage: 'Выберите хотя бы одну проблему: остановите ГВС/отопление или отметьте неработающий котёл');
      return false;
    }

    if (state.affectedHouseIds.isEmpty) {
      state = state.copyWith(errorMessage: 'Выберите затронутые дома');
      return false;
    }

    // Offline permission check
    final canWrite = ref.read(writeAccessProvider);
    if (!canWrite) {
      state = state.copyWith(errorMessage: 'Нет интернета и у вас нет прав на редактирование без сети');
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
          affectedHouseDetails: state.affectedHouseIds.map((id) => AffectedHouseCreate(savedLocationId: id)).toList(),
          assignedTo: state.assignedTo,
          notificationConfig: state.notificationConfig,
          createdAt: state.createdAt.toUtc().toIso8601String(),
          resolvedAt: state.resolvedAt?.toUtc().toIso8601String(),
          startedAt: (state.startedAt ?? state.createdAt).toUtc().toIso8601String(),
          finishedAt: state.finishedAt?.toUtc().toIso8601String(),
          autoResolveOnFinish: state.autoResolveOnFinish,
          inactiveBoilerNumbers: state.inactiveBoilers.isEmpty ? null : state.inactiveBoilers.toList(),
          supplyFullyStopped: state.supplyFullyStopped,
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
          affectedHouseDetails: state.affectedHouseIds.map((id) => AffectedHouseCreate(savedLocationId: id)).toList(),
          assignedTo: state.assignedTo,
          notificationConfig: state.notificationConfig,
          createdAt: state.createdAt.toUtc().toIso8601String(),
          startedAt: (state.startedAt ?? state.createdAt).toUtc().toIso8601String(),
          finishedAt: state.finishedAt?.toUtc().toIso8601String(),
          autoResolveOnFinish: state.autoResolveOnFinish,
          inactiveBoilerNumbers: state.inactiveBoilers.isEmpty ? null : state.inactiveBoilers.toList(),
          supplyFullyStopped: state.supplyFullyStopped,
        );

        await service.createIncident(create);
      }
      state = state.copyWith(isSaving: false);
      return true;
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final detail = e.response?.data;
      print('❌ [IncidentFormController] DioException: $statusCode, data: $detail');
      state = state.copyWith(isSaving: false, errorMessage: 'Ошибка $statusCode: $detail');
      return false;
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: 'Ошибка сохранения: $e');
      return false;
    }
  }

  /// Сохраняет autoResolveOnFinish в Drift БД после успешного сохранения на сервере.
  /// Аналогично iOS: incident.setValue(autoResolveOnFinishCaptured, forKey: "autoResolveOnFinish")
  Future<void> _saveAutoResolveLocally(int incidentId, bool autoResolve) async {
    try {
      final syncRepo = ref.read(syncRepositoryProvider);
      await syncRepo.updateAutoResolveOnFinish(incidentId, autoResolve);
    } catch (e) {
      // Не критично — логируем и продолжаем
      print('⚠️ [IncidentFormController] Failed to save autoResolveOnFinish locally: $e');
    }
  }
}
