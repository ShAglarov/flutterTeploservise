// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'incident_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationConfig _$NotificationConfigFromJson(Map<String, dynamic> json) =>
    NotificationConfig(
      type: AudienceType.fromAny(json['type']),
      roleIds: (json['role_ids'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      userIds: (json['user_ids'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$NotificationConfigToJson(NotificationConfig instance) =>
    <String, dynamic>{
      'type': _$AudienceTypeEnumMap[instance.type]!,
      'role_ids': instance.roleIds,
      'user_ids': instance.userIds,
    };

const _$AudienceTypeEnumMap = {
  AudienceType.broadcast: 'broadcast',
  AudienceType.roleBased: 'role_based',
  AudienceType.userBased: 'user_based',
};

SavedLocationInfo _$SavedLocationInfoFromJson(Map<String, dynamic> json) =>
    SavedLocationInfo(
      id: SavedLocationInfo._idFromJson(json['id']),
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      floors: (json['floors'] as num?)?.toInt(),
      rooms: (json['rooms'] as num?)?.toInt(),
      totalArea: (json['total_area'] as num?)?.toDouble(),
      residentsCount: (json['residents_count'] as num?)?.toInt(),
      yearBuilt: (json['year_built'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SavedLocationInfoToJson(SavedLocationInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'floors': instance.floors,
      'rooms': instance.rooms,
      'total_area': instance.totalArea,
      'residents_count': instance.residentsCount,
      'year_built': instance.yearBuilt,
    };

AffectedHouseDetail _$AffectedHouseDetailFromJson(Map<String, dynamic> json) =>
    AffectedHouseDetail(
      savedLocationId: (json['saved_location_id'] as num).toInt(),
      area: (json['area'] as num?)?.toDouble(),
      status: json['status'] as String?,
      residentsCount: (json['residents_count'] as num?)?.toInt(),
      notes: json['notes'] as String?,
      savedLocation: json['saved_location'] == null
          ? null
          : SavedLocationInfo.fromJson(
              json['saved_location'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$AffectedHouseDetailToJson(
  AffectedHouseDetail instance,
) => <String, dynamic>{
  'saved_location_id': instance.savedLocationId,
  'area': instance.area,
  'status': instance.status,
  'residents_count': instance.residentsCount,
  'notes': instance.notes,
  'saved_location': instance.savedLocation,
};

BoilerHouseSummary _$BoilerHouseSummaryFromJson(Map<String, dynamic> json) =>
    BoilerHouseSummary(
      id: (json['id'] as num).toInt(),
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      activeIncidentsCount: (json['active_incidents_count'] as num).toInt(),
      hasActiveIncidents: (json['has_active_incidents'] as num).toInt(),
      siteNumber: json['site_number'] as String?,
      siteManager: json['site_manager'] as String?,
    );

Map<String, dynamic> _$BoilerHouseSummaryToJson(BoilerHouseSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'active_incidents_count': instance.activeIncidentsCount,
      'has_active_incidents': instance.hasActiveIncidents,
      'site_number': instance.siteNumber,
      'site_manager': instance.siteManager,
    };

IncidentResponse _$IncidentResponseFromJson(Map<String, dynamic> json) =>
    IncidentResponse(
      id: (json['id'] as num).toInt(),
      boilerHouseId: (json['boiler_house_id'] as num?)?.toInt(),
      title: json['title'] as String?,
      description: json['description'] as String?,
      status: IncidentStatus.fromAny(json['status']),
      severity: json['severity'] as String?,
      resourceHotWaterStopped: (json['resource_hot_water_stopped'] as num?)
          ?.toInt(),
      resourceHeatingStopped: (json['resource_heating_stopped'] as num?)
          ?.toInt(),
      reportedBy: (json['reported_by'] as num?)?.toInt(),
      assignedTo: (json['assigned_to'] as num?)?.toInt(),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      resolvedAt: json['resolved_at'] as String?,
      localUUID: json['local_uuid'] as String?,
      localPendingAck: json['local_pending_ack'] as bool?,
      affectedHouseIds: (json['affected_house_ids'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      affectedHouseDetails: (json['affected_house_details'] as List<dynamic>?)
          ?.map((e) => AffectedHouseDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
      boilerHouse: json['boiler_house'] == null
          ? null
          : BoilerHouseSummary.fromJson(
              json['boiler_house'] as Map<String, dynamic>,
            ),
      photos: (json['photos'] as List<dynamic>?)
          ?.map((e) => PhotoInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      notificationConfig: json['notification_config'] == null
          ? null
          : NotificationConfig.fromJson(
              json['notification_config'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$IncidentResponseToJson(IncidentResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'boiler_house_id': instance.boilerHouseId,
      'title': instance.title,
      'description': instance.description,
      'status': _$IncidentStatusEnumMap[instance.status],
      'severity': instance.severity,
      'resource_hot_water_stopped': instance.resourceHotWaterStopped,
      'resource_heating_stopped': instance.resourceHeatingStopped,
      'reported_by': instance.reportedBy,
      'assigned_to': instance.assignedTo,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'resolved_at': instance.resolvedAt,
      'local_uuid': instance.localUUID,
      'local_pending_ack': instance.localPendingAck,
      'affected_house_ids': instance.affectedHouseIds,
      'affected_house_details': instance.affectedHouseDetails,
      'boiler_house': instance.boilerHouse,
      'photos': instance.photos,
      'notification_config': instance.notificationConfig,
    };

const _$IncidentStatusEnumMap = {
  IncidentStatus.open: 'open',
  IncidentStatus.inProgress: 'in_progress',
  IncidentStatus.resolved: 'resolved',
  IncidentStatus.closed: 'closed',
};

PhotoInfo _$PhotoInfoFromJson(Map<String, dynamic> json) => PhotoInfo(
  id: (json['id'] as num).toInt(),
  url: json['url'] as String,
  thumbnailUrl: json['thumbnail_url'] as String?,
  createdAt: json['created_at'] as String?,
);

Map<String, dynamic> _$PhotoInfoToJson(PhotoInfo instance) => <String, dynamic>{
  'id': instance.id,
  'url': instance.url,
  'thumbnail_url': instance.thumbnailUrl,
  'created_at': instance.createdAt,
};

AffectedHouseCreate _$AffectedHouseCreateFromJson(Map<String, dynamic> json) =>
    AffectedHouseCreate(
      savedLocationId: (json['saved_location_id'] as num).toInt(),
      area: (json['area'] as num?)?.toDouble(),
      status: json['status'] as String?,
      residentsCount: (json['residents_count'] as num?)?.toInt(),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$AffectedHouseCreateToJson(
  AffectedHouseCreate instance,
) => <String, dynamic>{
  'saved_location_id': instance.savedLocationId,
  'area': instance.area,
  'status': instance.status,
  'residents_count': instance.residentsCount,
  'notes': instance.notes,
};

IncidentCreate _$IncidentCreateFromJson(Map<String, dynamic> json) =>
    IncidentCreate(
      boilerHouseId: (json['boiler_house_id'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String?,
      status: $enumDecodeNullable(_$IncidentStatusEnumMap, json['status']),
      severity: json['severity'] as String?,
      resourceHotWaterStopped: (json['resource_hot_water_stopped'] as num?)
          ?.toInt(),
      resourceHeatingStopped: (json['resource_heating_stopped'] as num?)
          ?.toInt(),
      assignedTo: (json['assigned_to'] as num?)?.toInt(),
      affectedHouseIds: (json['affected_house_ids'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      affectedHouseDetails: (json['affected_house_details'] as List<dynamic>?)
          ?.map((e) => AffectedHouseCreate.fromJson(e as Map<String, dynamic>))
          .toList(),
      notificationConfig: json['notification_config'] == null
          ? null
          : NotificationConfig.fromJson(
              json['notification_config'] as Map<String, dynamic>,
            ),
      createdAt: json['created_at'] as String?,
    );

Map<String, dynamic> _$IncidentCreateToJson(IncidentCreate instance) =>
    <String, dynamic>{
      'boiler_house_id': instance.boilerHouseId,
      'title': instance.title,
      'description': instance.description,
      'status': _$IncidentStatusEnumMap[instance.status],
      'severity': instance.severity,
      'resource_hot_water_stopped': instance.resourceHotWaterStopped,
      'resource_heating_stopped': instance.resourceHeatingStopped,
      'assigned_to': instance.assignedTo,
      'affected_house_ids': instance.affectedHouseIds,
      'affected_house_details': instance.affectedHouseDetails,
      'notification_config': instance.notificationConfig,
      'created_at': instance.createdAt,
    };

IncidentUpdate _$IncidentUpdateFromJson(Map<String, dynamic> json) =>
    IncidentUpdate(
      id: (json['id'] as num?)?.toInt(),
      boilerHouseId: (json['boiler_house_id'] as num?)?.toInt(),
      title: json['title'] as String?,
      description: json['description'] as String?,
      status: $enumDecodeNullable(_$IncidentStatusEnumMap, json['status']),
      severity: json['severity'] as String?,
      resourceHotWaterStopped: (json['resource_hot_water_stopped'] as num?)
          ?.toInt(),
      resourceHeatingStopped: (json['resource_heating_stopped'] as num?)
          ?.toInt(),
      assignedTo: (json['assigned_to'] as num?)?.toInt(),
      affectedHouseIds: (json['affected_house_ids'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      affectedHouseDetails: (json['affected_house_details'] as List<dynamic>?)
          ?.map((e) => AffectedHouseCreate.fromJson(e as Map<String, dynamic>))
          .toList(),
      notificationConfig: json['notification_config'] == null
          ? null
          : NotificationConfig.fromJson(
              json['notification_config'] as Map<String, dynamic>,
            ),
      createdAt: json['created_at'] as String?,
      resolvedAt: json['resolved_at'] as String?,
    );

Map<String, dynamic> _$IncidentUpdateToJson(IncidentUpdate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'boiler_house_id': instance.boilerHouseId,
      'title': instance.title,
      'description': instance.description,
      'status': _$IncidentStatusEnumMap[instance.status],
      'severity': instance.severity,
      'resource_hot_water_stopped': instance.resourceHotWaterStopped,
      'resource_heating_stopped': instance.resourceHeatingStopped,
      'assigned_to': instance.assignedTo,
      'affected_house_ids': instance.affectedHouseIds,
      'affected_house_details': instance.affectedHouseDetails,
      'notification_config': instance.notificationConfig,
      'created_at': instance.createdAt,
      'resolved_at': instance.resolvedAt,
    };

IncidentCommentAuthor _$IncidentCommentAuthorFromJson(
  Map<String, dynamic> json,
) => IncidentCommentAuthor(
  id: (json['id'] as num).toInt(),
  fullName: json['full_name'] as String?,
  firstName: json['first_name'] as String?,
  lastName: json['last_name'] as String?,
  middleName: json['middle_name'] as String?,
);

Map<String, dynamic> _$IncidentCommentAuthorToJson(
  IncidentCommentAuthor instance,
) => <String, dynamic>{
  'id': instance.id,
  'full_name': instance.fullName,
  'first_name': instance.firstName,
  'last_name': instance.lastName,
  'middle_name': instance.middleName,
};

IncidentComment _$IncidentCommentFromJson(Map<String, dynamic> json) =>
    IncidentComment(
      id: (json['id'] as num).toInt(),
      incidentId: (json['incident_id'] as num).toInt(),
      text: json['text'] as String,
      createdAt: json['created_at'] as String,
      userId: (json['user_id'] as num).toInt(),
      author: json['author'] == null
          ? null
          : IncidentCommentAuthor.fromJson(
              json['author'] as Map<String, dynamic>,
            ),
      isSystemMessage: json['is_system_message'] as bool? ?? false,
    );

Map<String, dynamic> _$IncidentCommentToJson(IncidentComment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'incident_id': instance.incidentId,
      'text': instance.text,
      'created_at': instance.createdAt,
      'user_id': instance.userId,
      'author': instance.author,
      'is_system_message': instance.isSystemMessage,
    };
