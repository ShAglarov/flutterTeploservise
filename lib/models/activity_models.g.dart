// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
      entityId: json['entity_id'],
      actionType: json['action_type'] as String,
      entityType: json['entity_type'] as String,
      userId: (json['user_id'] as num).toInt(),
      userName: json['user_name'] as String?,
      message: json['message'] as String?,
      changesData: json['changes'] as Map<String, dynamic>?,
      timestamp: json['timestamp'] as String,
    );

Map<String, dynamic> _$IncidentActivityToJson(IncidentActivity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'entity_id': instance.entityId,
      'action_type': instance.actionType,
      'entity_type': instance.entityType,
      'user_id': instance.userId,
      'user_name': instance.userName,
      'message': instance.message,
      'changes': instance.changesData,
      'timestamp': instance.timestamp,
    };
