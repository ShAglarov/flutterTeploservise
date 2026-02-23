// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'management_company_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ManagementCompanyResponse _$ManagementCompanyResponseFromJson(
  Map<String, dynamic> json,
) => ManagementCompanyResponse(
  id: json['id'] as String,
  name: json['name'] as String,
  phone: json['phone'] as String?,
  email: json['email'] as String?,
  address: json['address'] as String?,
  notes: json['notes'] as String?,
  director: json['director'] as String?,
  additionalData: json['additionalData'] as Map<String, dynamic>?,
  locationUUIDs:
      (json['location_uuids'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      [],
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$ManagementCompanyResponseToJson(
  ManagementCompanyResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'phone': instance.phone,
  'email': instance.email,
  'address': instance.address,
  'notes': instance.notes,
  'director': instance.director,
  'additionalData': instance.additionalData,
  'location_uuids': instance.locationUUIDs,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};

ManagementCompanyCreate _$ManagementCompanyCreateFromJson(
  Map<String, dynamic> json,
) => ManagementCompanyCreate(
  name: json['name'] as String,
  phone: json['phone'] as String?,
  email: json['email'] as String?,
  address: json['address'] as String?,
  notes: json['notes'] as String?,
  director: json['director'] as String?,
  additionalData: json['additionalData'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$ManagementCompanyCreateToJson(
  ManagementCompanyCreate instance,
) => <String, dynamic>{
  'name': instance.name,
  'phone': instance.phone,
  'email': instance.email,
  'address': instance.address,
  'notes': instance.notes,
  'director': instance.director,
  'additionalData': instance.additionalData,
};

ManagementCompanyUpdate _$ManagementCompanyUpdateFromJson(
  Map<String, dynamic> json,
) => ManagementCompanyUpdate(
  name: json['name'] as String?,
  phone: json['phone'] as String?,
  email: json['email'] as String?,
  address: json['address'] as String?,
  notes: json['notes'] as String?,
  director: json['director'] as String?,
  additionalData: json['additionalData'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$ManagementCompanyUpdateToJson(
  ManagementCompanyUpdate instance,
) => <String, dynamic>{
  'name': instance.name,
  'phone': instance.phone,
  'email': instance.email,
  'address': instance.address,
  'notes': instance.notes,
  'director': instance.director,
  'additionalData': instance.additionalData,
};
