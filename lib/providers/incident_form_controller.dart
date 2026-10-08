import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';
import '../models/incident_models.dart';
import '../services/incident_service.dart';
import '../providers/offline_edit_permission.dart';
import 'incident_form_state.dart';
import '../utils/app_logger.dart';
export 'incident_form_state.dart';

part 'incident_form_controller.g.dart';



@riverpod
class IncidentFormController extends _$IncidentFormController {
  @override
  IncidentFormState build(IncidentResponse? initialIncident) {
    if (initialIncident != null) {
      // Сервер хранит только факт полной остановки, без признака «откуда».
      // Восстанавливаем его по котлам: все нерабочие → остановка выведена,
      // иначе считаем ручной и не сбрасываем при клике по котлу.
      final inactive = initialIncident.inactiveBoilerNumbers?.toSet() ?? <int>{};
      final total = initialIncident.boilerHouse?.totalBoilersCount ?? 0;
      final derived = total > 0 && inactive.length >= total;
      return IncidentFormState(
        supplyFullyStoppedIsDerived: derived,
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
        inactiveBoilers: inactive,
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
    // «Закрыт» — тоже завершение: раньше resolvedAt ставился только для
    // «Решён», и у закрытых инцидентов время решения оставалось пустым,
    // хотя форма показывает для них поле «Время решения».
    final isFinished =
        value == IncidentStatus.resolved || value == IncidentStatus.closed;
    state = state.copyWith(
      status: value,
      resolvedAt: isFinished ? (state.resolvedAt ?? DateTime.now()) : null,
    );
  }
  void updateSeverity(String value) => state = state.copyWith(severity: value);
  // ─────────────────────────────────────────────────────────────────────
  // Остановленные услуги и состояние котлов — ТРИ НЕЗАВИСИМЫХ факта:
  //
  //   stopHotWater / stopHeating — что именно НЕ ПОЛУЧАЮТ жильцы;
  //   inactiveBoilers            — какие котлы не работают (техника);
  //   supplyFullyStopped         — теплоноситель прекращён полностью.
  //
  // Раньше они молча перезаписывали друг друга, и форма делала не то, что
  // пользователь видел:
  //   * «Остановить ГВС» ставил supplyFullyStopped = true — то есть
  //     остановка одной услуги объявлялась полным прекращением подачи,
  //     хотя отопление при этом могло идти;
  //   * он же СТИРАЛ все отмеченные котлы (inactiveBoilers: {}) — кассир
  //     отмечал котлы 1 и 3, потом включал ГВС, и отметки исчезали без
  //     предупреждения;
  //   * тумблер «Услуги поступают» после этого блокировался, и вернуть
  //     частичный режим было нельзя — только пересоздавать форму.
  //
  // Теперь остановка услуги влияет только на саму услугу. Полная остановка
  // выводится из котлов (все нерабочие → полная) либо ставится вручную.
  // ─────────────────────────────────────────────────────────────────────

  void updateStopHotWater(bool value) {
    state = state.copyWith(stopHotWater: value);
  }

  void updateStopHeating(bool value) {
    state = state.copyWith(stopHeating: value);
  }
  void updateBoilerHouse(int? id) => state = state.copyWith(boilerHouseId: id);
  void updateCreatedAt(DateTime time) => state = state.copyWith(createdAt: time);
  void updateResolvedAt(DateTime? time) => state = state.copyWith(resolvedAt: time);
  void updateStartedAt(DateTime time) => state = state.copyWith(startedAt: time);
  void updateFinishedAt(DateTime? time) {
    // Убрали время завершения → авто-завершению нечего ждать. Тумблер в UI
    // при этом скрывается, поэтому включённым он оставался невидимо: форма
    // отправляла autoResolveOnFinish=true для бессрочного инцидента.
    state = state.copyWith(
      finishedAt: time,
      autoResolveOnFinish: time == null ? false : state.autoResolveOnFinish,
    );
  }
  void updateAutoResolveOnFinish(bool value) => state = state.copyWith(autoResolveOnFinish: value);
  void updateAssignedTo(int? userId) {
    // Назначение ответственного НЕ меняет аудиторию уведомления.
    //
    // Раньше выбор ответственного молча переписывал notificationConfig на
    // userBased=[он один]. Пользователь выставлял «Всем пользователям»,
    // затем назначал ответственного — и рассылка превращалась в адресную
    // одному человеку, причём выпадающий список продолжал показывать
    // «Выбранным пользователям» только после возврата на поле.
    //
    // Ответственный и так получает push гарантированно: push_service
    // добавляет assignee в получатели для любого типа рассылки
    // (см. «Mandatory Inclusion (Assignee)»), так что терять аудиторию
    // не нужно ни для доставки, ни для чего-либо ещё.
    state = state.copyWith(assignedTo: userId);
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

  /// Переключает состояние котла (работает / не работает).
  ///
  /// [totalBoilers] — общее кол-во котлов котельной. Все котлы нерабочие
  /// → подача прекращена полностью (это следствие, а не отдельный ввод).
  void toggleBoiler(int boilerNumber, {int totalBoilers = 0}) {
    final newSet = Set<int>.from(state.inactiveBoilers);
    if (newSet.contains(boilerNumber)) {
      newSet.remove(boilerNumber);
    } else {
      newSet.add(boilerNumber);
    }

    final allInactive = totalBoilers > 0 && newSet.length >= totalBoilers;
    // Полная остановка следует из котлов. Если пользователь поставил её
    // вручную (котлы ни при чём — например, авария на трассе), снимать её
    // при возврате котла нельзя: иначе его собственный выбор молча
    // отменяется. Поэтому снимаем только то, что сами же и выставили.
    final bool newSupplyFullyStopped;
    if (allInactive) {
      newSupplyFullyStopped = true;
    } else if (state.supplyFullyStoppedIsDerived) {
      newSupplyFullyStopped = false;
    } else {
      newSupplyFullyStopped = state.supplyFullyStopped;
    }

    state = state.copyWith(
      inactiveBoilers: newSet,
      supplyFullyStopped: newSupplyFullyStopped,
      supplyFullyStoppedIsDerived: allInactive,
    );
  }

  /// Ручное переключение «подача теплоносителя прекращена полностью».
  ///
  /// Отметки котлов НЕ стираются: пользователь мог отметить котлы 1 и 3, и
  /// после выключения тумблера его выбор должен вернуться, а не исчезнуть.
  /// Пока все котлы отмечены нерабочими, выключить нельзя — это
  /// противоречило бы самим котлам (тумблер в UI в этом случае disabled).
  void updateSupplyFullyStopped(bool value, {int totalBoilers = 0}) {
    final allInactive = totalBoilers > 0 && state.inactiveBoilers.length >= totalBoilers;
    if (!value && allInactive) return;
    state = state.copyWith(
      supplyFullyStopped: value,
      // Ручная установка: при возврате котла её не сбрасываем.
      supplyFullyStoppedIsDerived: value ? false : allInactive,
    );
  }

  /// Добавить локальный путь к фото (до сохранения инцидента)
  void addPhoto(String path) {
    state = state.copyWith(pendingPhotoPaths: [...state.pendingPhotoPaths, path]);
  }

  /// Удалить фото из списка pending по индексу
  void removePhoto(int index) {
    final newList = List<String>.from(state.pendingPhotoPaths);
    if (index >= 0 && index < newList.length) {
      newList.removeAt(index);
      state = state.copyWith(pendingPhotoPaths: newList);
    }
  }

  Future<bool> save() async {
    if (state.boilerHouseId == null || state.title.isEmpty) {
      state = state.copyWith(errorMessage: 'Заполните обязательные поля');
      return false;
    }

    // Инцидент БЕЗ остановки услуг — нормальный случай, а не ошибка.
    //
    // Раньше здесь стояла проверка «выберите хотя бы одну проблему», и
    // сохранить инцидент с выключенными тумблерами было невозможно. Но в
    // котельной может случиться происшествие (пожар, авария на кровле,
    // повреждение оборудования), которое потушили вовремя: котёл работает,
    // ГВС и отопление идут, услуги поступают — а зафиксировать инцидент
    // нужно. Пин при этом остаётся оранжевым: происшествие есть, но
    // снабжение не прервано.

    if (state.affectedHouseIds.isEmpty) {
      state = state.copyWith(errorMessage: 'Выберите затронутые дома');
      return false;
    }

    // Завершение раньше начала: сервер такое принимает, а инцидент сразу
    // становится просроченным и (при авто-завершении) закрывается в тот же
    // момент, в который создан. Для пользователя это выглядит как «инцидент
    // исчез сразу после сохранения».
    final effectiveStart = state.startedAt ?? state.createdAt;
    if (state.finishedAt != null && !state.finishedAt!.isAfter(effectiveStart)) {
      state = state.copyWith(
        errorMessage: 'Время завершения должно быть позже времени начала',
      );
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

        final createdIncident = await service.createIncident(create);

        // Загружаем pending фото после успешного создания инцидента
        if (state.pendingPhotoPaths.isNotEmpty) {
          for (final photoPath in state.pendingPhotoPaths) {
            try {
              await service.uploadIncidentPhoto(createdIncident.id, photoPath);
              debugPrint('📸 [IncidentFormController] Uploaded photo: $photoPath for incident ${createdIncident.id}');
            } catch (e) {
              debugPrint('⚠️ [IncidentFormController] Failed to upload photo $photoPath: $e');
              // Не прерываем — продолжаем загрузку остальных
            }
          }
        }
      }
      state = state.copyWith(isSaving: false, pendingPhotoPaths: []);
      return true;
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final detail = e.response?.data;
      logDebug('❌ [IncidentFormController] DioException: $statusCode, data: $detail');
      state = state.copyWith(isSaving: false, errorMessage: 'Ошибка $statusCode: $detail');
      return false;
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: 'Ошибка сохранения: $e');
      return false;
    }
  }

  // Удалён _saveAutoResolveLocally: он нигде не вызывался, а autoResolveOnFinish
  // и так уходит на сервер в IncidentCreate/IncidentUpdate выше, локальная копия
  // в Drift обновляется при следующей синхронизации.
  // syncRepo.updateAutoResolveOnFinish остаётся доступен, если понадобится
  // оптимистичное локальное обновление.
}
