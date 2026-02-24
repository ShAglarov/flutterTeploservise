import 'package:json_annotation/json_annotation.dart';

part 'activity_models.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ActivityChange {
  final String field;
  @JsonKey(name: 'old_value')
  final dynamic oldValue;
  @JsonKey(name: 'new_value')
  final dynamic newValue;

  ActivityChange({
    required this.field,
    this.oldValue,
    this.newValue,
  });

  factory ActivityChange.fromJson(Map<String, dynamic> json) => _$ActivityChangeFromJson(json);
  Map<String, dynamic> toJson() => _$ActivityChangeToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class IncidentActivity {
  final int id;
  @JsonKey(name: 'entity_id')
  final dynamic entityId;
  @JsonKey(name: 'action_type')
  final String actionType;
  @JsonKey(name: 'entity_type')
  final String entityType;
  
  @JsonKey(name: 'user_id')
  final int userId;
  @JsonKey(name: 'user_name')
  final String? userName;
  
  final String? message;
  
  @JsonKey(name: 'changes')
  final Map<String, dynamic>? changesData;
  
  @JsonKey(name: 'timestamp')
  final String timestamp;

  IncidentActivity({
    required this.id,
    this.entityId,
    required this.actionType,
    required this.entityType,
    required this.userId,
    this.userName,
    this.message,
    this.changesData,
    required this.timestamp,
  });

  // Getter to convert raw changes dict to structured ActionChanges
  List<ActivityChange> get parsedChanges {
    final list = <ActivityChange>[];
    if (changesData == null) return list;
    
    changesData!.forEach((key, value) {
      if (key == 'scope' || key == 'type' || key == 'screen') return;
      
      var oldVal;
      var newVal;
      if (value is Map) {
        oldVal = value['old'];
        newVal = value['new'];
        if (oldVal == null && newVal == null) {
          oldVal = value['old_value'];
          newVal = value['new_value'];
        }
      } else {
        newVal = value;
      }
      list.add(ActivityChange(field: key, oldValue: oldVal, newValue: newVal));
    });
    return list;
  }

  factory IncidentActivity.fromJson(Map<String, dynamic> json) => _$IncidentActivityFromJson(json);
  Map<String, dynamic> toJson() => _$IncidentActivityToJson(this);
}
