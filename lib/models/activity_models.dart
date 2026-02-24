import 'package:json_annotation/json_annotation.dart';

part 'activity_models.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ActivityAuthor {
  final int id;
  @JsonKey(name: 'full_name')
  final String fullName;

  ActivityAuthor({
    required this.id,
    required this.fullName,
  });

  factory ActivityAuthor.fromJson(Map<String, dynamic> json) => _$ActivityAuthorFromJson(json);
  Map<String, dynamic> toJson() => _$ActivityAuthorToJson(this);
}

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
  @JsonKey(name: 'incident_id')
  final int incidentId;
  @JsonKey(name: 'action_type')
  final String actionType; // 'create', 'update', 'delete', 'comment'
  @JsonKey(name: 'entity_type')
  final String entityType; // 'incident', 'incident_comment'
  
  @JsonKey(name: 'user_id')
  final int userId;
  final ActivityAuthor author;
  
  // Can be a string message or a map of changes
  final String? message;
  final List<ActivityChange>? changes;
  
  @JsonKey(name: 'created_at')
  final String createdAt;

  IncidentActivity({
    required this.id,
    required this.incidentId,
    required this.actionType,
    required this.entityType,
    required this.userId,
    required this.author,
    this.message,
    this.changes,
    required this.createdAt,
  });

  factory IncidentActivity.fromJson(Map<String, dynamic> json) => _$IncidentActivityFromJson(json);
  Map<String, dynamic> toJson() => _$IncidentActivityToJson(this);
}
