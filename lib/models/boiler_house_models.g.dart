// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'boiler_house_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BoilerHouseResponse _$BoilerHouseResponseFromJson(Map<String, dynamic> json) =>
    BoilerHouseResponse(
      id: (json['id'] as num).toInt(),
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      managementCompanyId: json['management_company_id'] as String?,
      additionalData: json['additionalData'] as Map<String, dynamic>?,
      createdBy: (json['createdBy'] as num?)?.toInt(),
      updatedBy: (json['updatedBy'] as num?)?.toInt(),
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String?,
      siteNumber: json['site_number'] as String?,
      siteManager: json['site_manager'] as String?,
      boilerHouseUUID: json['boiler_house_uuid'] as String?,
      incidentCount: (json['incident_count'] as num?)?.toInt(),
      photos: (json['photos'] as List<dynamic>?)
          ?.map((e) => PhotoInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$BoilerHouseResponseToJson(
  BoilerHouseResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'address': instance.address,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'management_company_id': instance.managementCompanyId,
  'additionalData': instance.additionalData,
  'createdBy': instance.createdBy,
  'updatedBy': instance.updatedBy,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
  'site_number': instance.siteNumber,
  'site_manager': instance.siteManager,
  'boiler_house_uuid': instance.boilerHouseUUID,
  'incident_count': instance.incidentCount,
  'photos': instance.photos,
};

BoilerHouseCreate _$BoilerHouseCreateFromJson(Map<String, dynamic> json) =>
    BoilerHouseCreate(
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      managementCompanyId: json['management_company_id'] as String?,
      additionalData: json['additionalData'] as Map<String, dynamic>?,
      siteNumber: json['site_number'] as String?,
      siteManager: json['site_manager'] as String?,
      boilerHouseUUID: json['boiler_house_uuid'] as String?,
    );

Map<String, dynamic> _$BoilerHouseCreateToJson(BoilerHouseCreate instance) =>
    <String, dynamic>{
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'management_company_id': instance.managementCompanyId,
      'additionalData': instance.additionalData,
      'site_number': instance.siteNumber,
      'site_manager': instance.siteManager,
      'boiler_house_uuid': instance.boilerHouseUUID,
    };

BoilerHouseUpdate _$BoilerHouseUpdateFromJson(Map<String, dynamic> json) =>
    BoilerHouseUpdate(
      address: json['address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      managementCompanyId: json['management_company_id'] as String?,
      additionalData: json['additionalData'] as Map<String, dynamic>?,
      siteNumber: json['site_number'] as String?,
      siteManager: json['site_manager'] as String?,
    );

Map<String, dynamic> _$BoilerHouseUpdateToJson(BoilerHouseUpdate instance) =>
    <String, dynamic>{
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'management_company_id': instance.managementCompanyId,
      'additionalData': instance.additionalData,
      'site_number': instance.siteNumber,
      'site_manager': instance.siteManager,
    };
