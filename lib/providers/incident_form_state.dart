import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/incident_models.dart';

part 'incident_form_state.freezed.dart';

@freezed
abstract class IncidentFormState with _$IncidentFormState {
  const factory IncidentFormState({
    required int? id,
    required int? boilerHouseId,
    @Default('') String title,
    @Default('') String description,
    @Default(IncidentStatus.open) IncidentStatus status,
    @Default('1') String severity,
    @Default(false) bool stopHotWater,
    @Default(false) bool stopHeating,
    @Default({}) Set<int> affectedHouseIds,
    required DateTime createdAt,
    DateTime? resolvedAt,
    /// Время начала инцидента (может быть в будущем для запланированных)
    DateTime? startedAt,
    /// Время завершения инцидента (опционально)
    DateTime? finishedAt,
    /// Авто-завершение по окончании finishedAt
    @Default(false) bool autoResolveOnFinish,
    int? assignedTo,
    NotificationConfig? notificationConfig,
    @Default(false) bool isSaving,
    String? errorMessage,
    /// Номера неработающих котлов (напр. {1, 3})
    @Default({}) Set<int> inactiveBoilers,
    /// Тумблер "Теплоноситель не поступает полностью" — форсирует статус КРАСНЫЙ
    @Default(false) bool supplyFullyStopped,
  }) = _IncidentFormState;
}

