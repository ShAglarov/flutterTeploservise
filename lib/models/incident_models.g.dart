// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'incident_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationConfig _$NotificationConfigFromJson(Map<String, dynamic> json) =>
    NotificationConfig(
      type: $enumDecode(_$AudienceTypeEnumMap, json['type']),
      roleIds: (json['roleIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      userIds: (json['userIds'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$NotificationConfigToJson(NotificationConfig instance) =>
    <String, dynamic>{
      'type': _$AudienceTypeEnumMap[instance.type]!,
      'roleIds': instance.roleIds,
      'userIds': instance.userIds,
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
      totalArea: (json['totalArea'] as num?)?.toDouble(),
      residentsCount: (json['residentsCount'] as num?)?.toInt(),
      yearBuilt: (json['yearBuilt'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SavedLocationInfoToJson(SavedLocationInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'floors': instance.floors,
      'rooms': instance.rooms,
      'totalArea': instance.totalArea,
      'residentsCount': instance.residentsCount,
      'yearBuilt': instance.yearBuilt,
    };

AffectedHouseDetail _$AffectedHouseDetailFromJson(Map<String, dynamic> json) =>
    AffectedHouseDetail(
      savedLocationId: (json['savedLocationId'] as num).toInt(),
      area: (json['area'] as num?)?.toDouble(),
      status: json['status'] as String?,
      residentsCount: (json['residentsCount'] as num?)?.toInt(),
      notes: json['notes'] as String?,
      savedLocation: json['savedLocation'] == null
          ? null
          : SavedLocationInfo.fromJson(
              json['savedLocation'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$AffectedHouseDetailToJson(
  AffectedHouseDetail instance,
) => <String, dynamic>{
  'savedLocationId': instance.savedLocationId,
  'area': instance.area,
  'status': instance.status,
  'residentsCount': instance.residentsCount,
  'notes': instance.notes,
  'savedLocation': instance.savedLocation,
};

BoilerHouseSummary _$BoilerHouseSummaryFromJson(Map<String, dynamic> json) =>
    BoilerHouseSummary(
      id: (json['id'] as num).toInt(),
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      activeIncidentsCount: (json['activeIncidentsCount'] as num).toInt(),
      hasActiveIncidents: (json['hasActiveIncidents'] as num).toInt(),
      siteNumber: json['siteNumber'] as String?,
      siteManager: json['siteManager'] as String?,
    );

Map<String, dynamic> _$BoilerHouseSummaryToJson(BoilerHouseSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'activeIncidentsCount': instance.activeIncidentsCount,
      'hasActiveIncidents': instance.hasActiveIncidents,
      'siteNumber': instance.siteNumber,
      'siteManager': instance.siteManager,
    };

IncidentResponse _$IncidentResponseFromJson(Map<String, dynamic> json) =>
    IncidentResponse(
      id: (json['id'] as num).toInt(),
      boilerHouseId: (json['boilerHouseId'] as num?)?.toInt(),
      title: json['title'] as String?,
      description: json['description'] as String?,
      status: IncidentStatus.fromAny(json['status']),
      severity: json['severity'] as String?,
      resourceHotWaterStopped: (json['resourceHotWaterStopped'] as num?)
          ?.toInt(),
      resourceHeatingStopped: (json['resourceHeatingStopped'] as num?)?.toInt(),
      reportedBy: (json['reportedBy'] as num?)?.toInt(),
      assignedTo: (json['assignedTo'] as num?)?.toInt(),
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      resolvedAt: json['resolvedAt'] as String?,
      localUUID: json['local_uuid'] as String?,
      localPendingAck: json['localPendingAck'] as bool?,
      affectedHouseIds: (json['affectedHouseIds'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      affectedHouseDetails: (json['affectedHouseDetails'] as List<dynamic>?)
          ?.map((e) => AffectedHouseDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
      boilerHouse: json['boilerHouse'] == null
          ? null
          : BoilerHouseSummary.fromJson(
              json['boilerHouse'] as Map<String, dynamic>,
            ),
      photos: (json['photos'] as List<dynamic>?)
          ?.map((e) => PhotoInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      notificationConfig: json['notificationConfig'] == null
          ? null
          : NotificationConfig.fromJson(
              json['notificationConfig'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$IncidentResponseToJson(IncidentResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'boilerHouseId': instance.boilerHouseId,
      'title': instance.title,
      'description': instance.description,
      'status': _$IncidentStatusEnumMap[instance.status],
      'severity': instance.severity,
      'resourceHotWaterStopped': instance.resourceHotWaterStopped,
      'resourceHeatingStopped': instance.resourceHeatingStopped,
      'reportedBy': instance.reportedBy,
      'assignedTo': instance.assignedTo,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'resolvedAt': instance.resolvedAt,
      'local_uuid': instance.localUUID,
      'localPendingAck': instance.localPendingAck,
      'affectedHouseIds': instance.affectedHouseIds,
      'affectedHouseDetails': instance.affectedHouseDetails,
      'boilerHouse': instance.boilerHouse,
      'photos': instance.photos,
      'notificationConfig': instance.notificationConfig,
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
      savedLocationId: (json['savedLocationId'] as num).toInt(),
      area: (json['area'] as num?)?.toDouble(),
      status: json['status'] as String?,
      residentsCount: (json['residentsCount'] as num?)?.toInt(),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$AffectedHouseCreateToJson(
  AffectedHouseCreate instance,
) => <String, dynamic>{
  'savedLocationId': instance.savedLocationId,
  'area': instance.area,
  'status': instance.status,
  'residentsCount': instance.residentsCount,
  'notes': instance.notes,
};

IncidentCreate _$IncidentCreateFromJson(Map<String, dynamic> json) =>
    IncidentCreate(
      boilerHouseId: (json['boilerHouseId'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String?,
      status: $enumDecodeNullable(_$IncidentStatusEnumMap, json['status']),
      severity: json['severity'] as String?,
      resourceHotWaterStopped: (json['resourceHotWaterStopped'] as num?)
          ?.toInt(),
      resourceHeatingStopped: (json['resourceHeatingStopped'] as num?)?.toInt(),
      assignedTo: (json['assignedTo'] as num?)?.toInt(),
      affectedHouseIds: (json['affectedHouseIds'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      affectedHouseDetails: (json['affectedHouseDetails'] as List<dynamic>?)
          ?.map((e) => AffectedHouseCreate.fromJson(e as Map<String, dynamic>))
          .toList(),
      notificationConfig: json['notification_config'] == null
          ? null
          : NotificationConfig.fromJson(
              json['notification_config'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$IncidentCreateToJson(IncidentCreate instance) =>
    <String, dynamic>{
      'boilerHouseId': instance.boilerHouseId,
      'title': instance.title,
      'description': instance.description,
      'status': _$IncidentStatusEnumMap[instance.status],
      'severity': instance.severity,
      'resourceHotWaterStopped': instance.resourceHotWaterStopped,
      'resourceHeatingStopped': instance.resourceHeatingStopped,
      'assignedTo': instance.assignedTo,
      'affectedHouseIds': instance.affectedHouseIds,
      'affectedHouseDetails': instance.affectedHouseDetails,
      'notification_config': instance.notificationConfig,
    };

IncidentUpdate _$IncidentUpdateFromJson(Map<String, dynamic> json) =>
    IncidentUpdate(
      id: (json['id'] as num?)?.toInt(),
      boilerHouseId: (json['boilerHouseId'] as num?)?.toInt(),
      title: json['title'] as String?,
      description: json['description'] as String?,
      status: $enumDecodeNullable(_$IncidentStatusEnumMap, json['status']),
      severity: json['severity'] as String?,
      resourceHotWaterStopped: (json['resourceHotWaterStopped'] as num?)
          ?.toInt(),
      resourceHeatingStopped: (json['resourceHeatingStopped'] as num?)?.toInt(),
      assignedTo: (json['assignedTo'] as num?)?.toInt(),
      affectedHouseIds: (json['affectedHouseIds'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      affectedHouseDetails: (json['affectedHouseDetails'] as List<dynamic>?)
          ?.map((e) => AffectedHouseCreate.fromJson(e as Map<String, dynamic>))
          .toList(),
      notificationConfig: json['notification_config'] == null
          ? null
          : NotificationConfig.fromJson(
              json['notification_config'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$IncidentUpdateToJson(IncidentUpdate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'boilerHouseId': instance.boilerHouseId,
      'title': instance.title,
      'description': instance.description,
      'status': _$IncidentStatusEnumMap[instance.status],
      'severity': instance.severity,
      'resourceHotWaterStopped': instance.resourceHotWaterStopped,
      'resourceHeatingStopped': instance.resourceHeatingStopped,
      'assignedTo': instance.assignedTo,
      'affectedHouseIds': instance.affectedHouseIds,
      'affectedHouseDetails': instance.affectedHouseDetails,
      'notification_config': instance.notificationConfig,
    };

IncidentCommentAuthor _$IncidentCommentAuthorFromJson(
  Map<String, dynamic> json,
) => IncidentCommentAuthor(
  id: (json['id'] as num).toInt(),
  fullName: json['full_name'] as String,
);

Map<String, dynamic> _$IncidentCommentAuthorToJson(
  IncidentCommentAuthor instance,
) => <String, dynamic>{'id': instance.id, 'full_name': instance.fullName};

IncidentComment _$IncidentCommentFromJson(Map<String, dynamic> json) =>
    IncidentComment(
      id: (json['id'] as num).toInt(),
      incidentId: (json['incident_id'] as num).toInt(),
      text: json['text'] as String,
      createdAt: json['created_at'] as String,
      userId: (json['user_id'] as num).toInt(),
      author: IncidentCommentAuthor.fromJson(
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
