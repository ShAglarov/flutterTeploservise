// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SavedLocationResponse _$SavedLocationResponseFromJson(
  Map<String, dynamic> json,
) => SavedLocationResponse(
  id: (json['id'] as num).toInt(),
  userId: (json['user_id'] as num?)?.toInt(),
  name: json['name'] as String,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  managementCompanyId: json['management_company_id'] as String?,
  boilerHouseId: (json['boiler_house_id'] as num?)?.toInt(),
  floors: (json['floors'] as num?)?.toInt(),
  residentsCount: (json['residents_count'] as num?)?.toInt(),
  rooms: (json['rooms'] as num?)?.toInt(),
  totalArea: (json['total_area'] as num?)?.toDouble(),
  yearBuilt: (json['year_built'] as num?)?.toInt(),
  fiasHouseGuid: json['fias_house_guid'] as String?,
  fiasAOGuid: json['fias_a_o_guid'] as String?,
  locationUUID: json['location_u_u_i_d'] as String?,
  providesHeating: json['provides_heating'] as bool?,
  providesHotWater: json['provides_hot_water'] as bool?,
  cadastralNumber: json['cadastral_number'] as String?,
  commissioningDate: json['commissioning_date'] as String?,
  managementCompanyName: json['management_company_name'] as String?,
  accountsCount: (json['accounts_count'] as num?)?.toInt(),
  stoveType: json['stove_type'] as String?,
  housingType: json['housing_type'] as String?,
  entrancesCount: (json['entrances_count'] as num?)?.toInt(),
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String?,
  photos: (json['photos'] as List<dynamic>?)
      ?.map((e) => PhotoInfo.fromJson(e as Map<String, dynamic>))
      .toList(),
  accounts: (json['accounts'] as List<dynamic>?)
      ?.map((e) => AccountResponse.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$SavedLocationResponseToJson(
  SavedLocationResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'name': instance.name,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'management_company_id': instance.managementCompanyId,
  'boiler_house_id': instance.boilerHouseId,
  'floors': instance.floors,
  'residents_count': instance.residentsCount,
  'rooms': instance.rooms,
  'total_area': instance.totalArea,
  'year_built': instance.yearBuilt,
  'fias_house_guid': instance.fiasHouseGuid,
  'fias_a_o_guid': instance.fiasAOGuid,
  'location_u_u_i_d': instance.locationUUID,
  'provides_heating': instance.providesHeating,
  'provides_hot_water': instance.providesHotWater,
  'cadastral_number': instance.cadastralNumber,
  'commissioning_date': instance.commissioningDate,
  'management_company_name': instance.managementCompanyName,
  'accounts_count': instance.accountsCount,
  'stove_type': instance.stoveType,
  'housing_type': instance.housingType,
  'entrances_count': instance.entrancesCount,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
  'photos': instance.photos,
  'accounts': instance.accounts,
};

SavedLocationCreate _$SavedLocationCreateFromJson(Map<String, dynamic> json) =>
    SavedLocationCreate(
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      managementCompanyId: json['management_company_id'] as String?,
      boilerHouseId: (json['boiler_house_id'] as num?)?.toInt(),
      floors: (json['floors'] as num?)?.toInt(),
      residentsCount: (json['residents_count'] as num?)?.toInt(),
      rooms: (json['rooms'] as num?)?.toInt(),
      totalArea: (json['total_area'] as num?)?.toDouble(),
      yearBuilt: (json['year_built'] as num?)?.toInt(),
      fiasHouseGuid: json['fias_house_guid'] as String?,
      fiasAOGuid: json['fias_a_o_guid'] as String?,
      locationUUID: json['location_u_u_i_d'] as String?,
      providesHeating: json['provides_heating'] as bool?,
      providesHotWater: json['provides_hot_water'] as bool?,
      cadastralNumber: json['cadastral_number'] as String?,
      commissioningDate: json['commissioning_date'] as String?,
      stoveType: json['stove_type'] as String?,
      housingType: json['housing_type'] as String?,
      entrancesCount: (json['entrances_count'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SavedLocationCreateToJson(
  SavedLocationCreate instance,
) => <String, dynamic>{
  'name': instance.name,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'management_company_id': instance.managementCompanyId,
  'boiler_house_id': instance.boilerHouseId,
  'floors': instance.floors,
  'residents_count': instance.residentsCount,
  'rooms': instance.rooms,
  'total_area': instance.totalArea,
  'year_built': instance.yearBuilt,
  'fias_house_guid': instance.fiasHouseGuid,
  'fias_a_o_guid': instance.fiasAOGuid,
  'location_u_u_i_d': instance.locationUUID,
  'provides_heating': instance.providesHeating,
  'provides_hot_water': instance.providesHotWater,
  'cadastral_number': instance.cadastralNumber,
  'commissioning_date': instance.commissioningDate,
  'stove_type': instance.stoveType,
  'housing_type': instance.housingType,
  'entrances_count': instance.entrancesCount,
};

SavedLocationUpdate _$SavedLocationUpdateFromJson(Map<String, dynamic> json) =>
    SavedLocationUpdate(
      name: json['name'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      managementCompanyId: json['management_company_id'] as String?,
      boilerHouseId: (json['boiler_house_id'] as num?)?.toInt(),
      floors: (json['floors'] as num?)?.toInt(),
      residentsCount: (json['residents_count'] as num?)?.toInt(),
      rooms: (json['rooms'] as num?)?.toInt(),
      totalArea: (json['total_area'] as num?)?.toDouble(),
      yearBuilt: (json['year_built'] as num?)?.toInt(),
      fiasHouseGuid: json['fias_house_guid'] as String?,
      fiasAOGuid: json['fias_a_o_guid'] as String?,
      locationUUID: json['location_u_u_i_d'] as String?,
      providesHeating: json['provides_heating'] as bool?,
      providesHotWater: json['provides_hot_water'] as bool?,
      cadastralNumber: json['cadastral_number'] as String?,
      commissioningDate: json['commissioning_date'] as String?,
      stoveType: json['stove_type'] as String?,
      housingType: json['housing_type'] as String?,
      entrancesCount: (json['entrances_count'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SavedLocationUpdateToJson(
  SavedLocationUpdate instance,
) => <String, dynamic>{
  'name': instance.name,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'management_company_id': instance.managementCompanyId,
  'boiler_house_id': instance.boilerHouseId,
  'floors': instance.floors,
  'residents_count': instance.residentsCount,
  'rooms': instance.rooms,
  'total_area': instance.totalArea,
  'year_built': instance.yearBuilt,
  'fias_house_guid': instance.fiasHouseGuid,
  'fias_a_o_guid': instance.fiasAOGuid,
  'location_u_u_i_d': instance.locationUUID,
  'provides_heating': instance.providesHeating,
  'provides_hot_water': instance.providesHotWater,
  'cadastral_number': instance.cadastralNumber,
  'commissioning_date': instance.commissioningDate,
  'stove_type': instance.stoveType,
  'housing_type': instance.housingType,
  'entrances_count': instance.entrancesCount,
};

AccountResponse _$AccountResponseFromJson(Map<String, dynamic> json) =>
    AccountResponse(
      id: (json['id'] as num).toInt(),
      locationId: (json['location_id'] as num?)?.toInt(),
      accountNumber: json['account_number'] as String,
      address: json['address'] as String?,
      fio: json['fio'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      area: (json['area'] as num?)?.toDouble(),
      serviceType: json['service_type'] as String?,
      status: json['status'] as String?,
      jkuIdentifier: json['jku_identifier'] as String?,
      openDate: json['open_date'] as String?,
      closeDate: json['close_date'] as String?,
      cadastralNumber: json['cadastral_number'] as String?,
      roomsCount: (json['rooms_count'] as num?)?.toInt(),
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String?,
      locationUUID: json['location_u_u_i_d'] as String?,
    );

Map<String, dynamic> _$AccountResponseToJson(AccountResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'location_id': instance.locationId,
      'account_number': instance.accountNumber,
      'address': instance.address,
      'fio': instance.fio,
      'phone': instance.phone,
      'email': instance.email,
      'area': instance.area,
      'service_type': instance.serviceType,
      'status': instance.status,
      'jku_identifier': instance.jkuIdentifier,
      'open_date': instance.openDate,
      'close_date': instance.closeDate,
      'cadastral_number': instance.cadastralNumber,
      'rooms_count': instance.roomsCount,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'location_u_u_i_d': instance.locationUUID,
    };

AccountCreate _$AccountCreateFromJson(Map<String, dynamic> json) =>
    AccountCreate(
      locationId: (json['location_id'] as num).toInt(),
      accountNumber: json['account_number'] as String,
      address: json['address'] as String?,
      fio: json['fio'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      area: (json['area'] as num?)?.toDouble(),
      serviceType: json['service_type'] as String?,
      status: json['status'] as String?,
      jkuIdentifier: json['jku_identifier'] as String?,
      openDate: json['open_date'] as String?,
      closeDate: json['close_date'] as String?,
      cadastralNumber: json['cadastral_number'] as String?,
      roomsCount: (json['rooms_count'] as num?)?.toInt(),
    );

Map<String, dynamic> _$AccountCreateToJson(AccountCreate instance) =>
    <String, dynamic>{
      'location_id': instance.locationId,
      'account_number': instance.accountNumber,
      'address': instance.address,
      'fio': instance.fio,
      'phone': instance.phone,
      'email': instance.email,
      'area': instance.area,
      'service_type': instance.serviceType,
      'status': instance.status,
      'jku_identifier': instance.jkuIdentifier,
      'open_date': instance.openDate,
      'close_date': instance.closeDate,
      'cadastral_number': instance.cadastralNumber,
      'rooms_count': instance.roomsCount,
    };

AccountUpdate _$AccountUpdateFromJson(Map<String, dynamic> json) =>
    AccountUpdate(
      locationId: (json['location_id'] as num?)?.toInt(),
      accountNumber: json['account_number'] as String?,
      address: json['address'] as String?,
      fio: json['fio'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      area: (json['area'] as num?)?.toDouble(),
      serviceType: json['service_type'] as String?,
      status: json['status'] as String?,
      jkuIdentifier: json['jku_identifier'] as String?,
      openDate: json['open_date'] as String?,
      closeDate: json['close_date'] as String?,
      cadastralNumber: json['cadastral_number'] as String?,
      roomsCount: (json['rooms_count'] as num?)?.toInt(),
    );

Map<String, dynamic> _$AccountUpdateToJson(AccountUpdate instance) =>
    <String, dynamic>{
      'location_id': instance.locationId,
      'account_number': instance.accountNumber,
      'address': instance.address,
      'fio': instance.fio,
      'phone': instance.phone,
      'email': instance.email,
      'area': instance.area,
      'service_type': instance.serviceType,
      'status': instance.status,
      'jku_identifier': instance.jkuIdentifier,
      'open_date': instance.openDate,
      'close_date': instance.closeDate,
      'cadastral_number': instance.cadastralNumber,
      'rooms_count': instance.roomsCount,
    };
