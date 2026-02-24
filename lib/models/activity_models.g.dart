// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActivityAuthor _$ActivityAuthorFromJson(Map<String, dynamic> json) =>
    ActivityAuthor(
      id: (json['id'] as num).toInt(),
      fullName: json['full_name'] as String,
    );

Map<String, dynamic> _$ActivityAuthorToJson(ActivityAuthor instance) =>
    <String, dynamic>{'id': instance.id, 'full_name': instance.fullName};

ActivityChange _$ActivityChangeFromJson(Map<String, dynamic> json) =>
    ActivityChange(
      field: json['field'] as String,
      oldValue: json['old_value'],
      newValue: json['new_value'],
    );

Map<String, dynamic> _$ActivityChangeToJson(ActivityChange instance) =>
    <String, dynamic>{
      'field': instance.field,
      'old_value': instance.oldValue,
      'new_value': instance.newValue,
    };

IncidentActivity _$IncidentActivityFromJson(Map<String, dynamic> json) =>
    IncidentActivity(
      id: (json['id'] as num).toInt(),
      incidentId: (json['incident_id'] as num).toInt(),
      actionType: json['action_type'] as String,
      entityType: json['entity_type'] as String,
      userId: (json['user_id'] as num).toInt(),
      author: ActivityAuthor.fromJson(json['author'] as Map<String, dynamic>),
      message: json['message'] as String?,
      changes: (json['changes'] as List<dynamic>?)
          ?.map((e) => ActivityChange.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$IncidentActivityToJson(IncidentActivity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'incident_id': instance.incidentId,
      'action_type': instance.actionType,
      'entity_type': instance.entityType,
      'user_id': instance.userId,
      'author': instance.author,
      'message': instance.message,
      'changes': instance.changes,
      'created_at': instance.createdAt,
    };
