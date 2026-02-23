import 'package:json_annotation/json_annotation.dart';
import 'incident_models.dart';

part 'location_models.g.dart';

@JsonSerializable()
class SavedLocationResponse {
  final int id;
  final int? userId;
  final String name;
  final double latitude;
  final double longitude;
  @JsonKey(name: 'management_company_id')
  final String? managementCompanyId;
  @JsonKey(name: 'boiler_house_id')
  final int? boilerHouseId;
  final int? floors;
  @JsonKey(name: 'residents_count')
  final int? residentsCount;
  final int? rooms;
  @JsonKey(name: 'total_area')
  final double? totalArea;
  @JsonKey(name: 'year_built')
  final int? yearBuilt;
  @JsonKey(name: 'fias_house_guid')
  final String? fiasHouseGuid;
  @JsonKey(name: 'fias_ao_guid')
  final String? fiasAOGuid;
  @JsonKey(name: 'location_uuid')
  final String? locationUUID;
  @JsonKey(name: 'provides_heating')
  final bool? providesHeating;
  @JsonKey(name: 'provides_hot_water')
  final bool? providesHotWater;
  final String? managementCompanyName;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;
  final List<PhotoInfo>? photos;
  final List<AccountResponse>? accounts;

  SavedLocationResponse({
    required this.id,
    this.userId,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.managementCompanyId,
    this.boilerHouseId,
    this.floors,
    this.residentsCount,
    this.rooms,
    this.totalArea,
    this.yearBuilt,
    this.fiasHouseGuid,
    this.fiasAOGuid,
    this.locationUUID,
    this.providesHeating,
    this.providesHotWater,
    this.managementCompanyName,
    required this.createdAt,
    this.updatedAt,
    this.photos,
    this.accounts,
  });

  factory SavedLocationResponse.fromJson(Map<String, dynamic> json) => _$SavedLocationResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SavedLocationResponseToJson(this);
}

@JsonSerializable()
class SavedLocationCreate {
  final String name;
  final double latitude;
  final double longitude;
  @JsonKey(name: 'management_company_id')
  final String? managementCompanyId;
  @JsonKey(name: 'boiler_house_id')
  final int? boilerHouseId;
  final int? floors;
  @JsonKey(name: 'residents_count')
  final int? residentsCount;
  final int? rooms;
  @JsonKey(name: 'total_area')
  final double? totalArea;
  @JsonKey(name: 'year_built')
  final int? yearBuilt;
  @JsonKey(name: 'fias_house_guid')
  final String? fiasHouseGuid;
  @JsonKey(name: 'fias_ao_guid')
  final String? fiasAOGuid;
  @JsonKey(name: 'location_uuid')
  final String? locationUUID;
  @JsonKey(name: 'provides_heating')
  final bool? providesHeating;
  @JsonKey(name: 'provides_hot_water')
  final bool? providesHotWater;

  SavedLocationCreate({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.managementCompanyId,
    this.boilerHouseId,
    this.floors,
    this.residentsCount,
    this.rooms,
    this.totalArea,
    this.yearBuilt,
    this.fiasHouseGuid,
    this.fiasAOGuid,
    this.locationUUID,
    this.providesHeating,
    this.providesHotWater,
  });

  factory SavedLocationCreate.fromJson(Map<String, dynamic> json) => _$SavedLocationCreateFromJson(json);
  Map<String, dynamic> toJson() => _$SavedLocationCreateToJson(this);
}

@JsonSerializable()
class SavedLocationUpdate {
  final String? name;
  final double? latitude;
  final double? longitude;
  @JsonKey(name: 'management_company_id')
  final String? managementCompanyId;
  @JsonKey(name: 'boiler_house_id')
  final int? boilerHouseId;
  final int? floors;
  @JsonKey(name: 'residents_count')
  final int? residentsCount;
  final int? rooms;
  @JsonKey(name: 'total_area')
  final double? totalArea;
  @JsonKey(name: 'year_built')
  final int? yearBuilt;
  @JsonKey(name: 'fias_house_guid')
  final String? fiasHouseGuid;
  @JsonKey(name: 'fias_ao_guid')
  final String? fiasAOGuid;
  @JsonKey(name: 'location_uuid')
  final String? locationUUID;
  @JsonKey(name: 'provides_heating')
  final bool? providesHeating;
  @JsonKey(name: 'provides_hot_water')
  final bool? providesHotWater;

  SavedLocationUpdate({
    this.name,
    this.latitude,
    this.longitude,
    this.managementCompanyId,
    this.boilerHouseId,
    this.floors,
    this.residentsCount,
    this.rooms,
    this.totalArea,
    this.yearBuilt,
    this.fiasHouseGuid,
    this.fiasAOGuid,
    this.locationUUID,
    this.providesHeating,
    this.providesHotWater,
  });

  factory SavedLocationUpdate.fromJson(Map<String, dynamic> json) => _$SavedLocationUpdateFromJson(json);
  Map<String, dynamic> toJson() => _$SavedLocationUpdateToJson(this);
}

@JsonSerializable()
class AccountResponse {
  final int id;
  @JsonKey(name: 'location_id')
  final int? locationId;
  @JsonKey(name: 'account_number')
  final String accountNumber;
  final String? address;
  final String? fio;
  final String? phone;
  final String? email;
  final double? area;
  @JsonKey(name: 'service_type')
  final String? serviceType;
  final String? status;
  @JsonKey(name: 'jku_identifier')
  final String? jkuIdentifier;
  @JsonKey(name: 'open_date')
  final String? openDate;
  @JsonKey(name: 'close_date')
  final String? closeDate;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;
  @JsonKey(name: 'location_uuid')
  final String? locationUUID;

  AccountResponse({
    required this.id,
    this.locationId,
    required this.accountNumber,
    this.address,
    this.fio,
    this.phone,
    this.email,
    this.area,
    this.serviceType,
    this.status,
    this.jkuIdentifier,
    this.openDate,
    this.closeDate,
    required this.createdAt,
    this.updatedAt,
    this.locationUUID,
  });

  factory AccountResponse.fromJson(Map<String, dynamic> json) => _$AccountResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AccountResponseToJson(this);
}

@JsonSerializable()
class AccountCreate {
  @JsonKey(name: 'location_id')
  final int locationId;
  @JsonKey(name: 'account_number')
  final String accountNumber;
  final String? address;
  final String? fio;
  final String? phone;
  final String? email;
  final double? area;
  @JsonKey(name: 'service_type')
  final String? serviceType;
  final String? status;
  @JsonKey(name: 'jku_identifier')
  final String? jkuIdentifier;
  @JsonKey(name: 'open_date')
  final String? openDate;
  @JsonKey(name: 'close_date')
  final String? closeDate;

  AccountCreate({
    required this.locationId,
    required this.accountNumber,
    this.address,
    this.fio,
    this.phone,
    this.email,
    this.area,
    this.serviceType,
    this.status,
    this.jkuIdentifier,
    this.openDate,
    this.closeDate,
  });

  factory AccountCreate.fromJson(Map<String, dynamic> json) => _$AccountCreateFromJson(json);
  Map<String, dynamic> toJson() => _$AccountCreateToJson(this);
}

@JsonSerializable()
class AccountUpdate {
  @JsonKey(name: 'location_id')
  final int? locationId;
  @JsonKey(name: 'account_number')
  final String? accountNumber;
  final String? address;
  final String? fio;
  final String? phone;
  final String? email;
  final double? area;
  @JsonKey(name: 'service_type')
  final String? serviceType;
  final String? status;
  @JsonKey(name: 'jku_identifier')
  final String? jkuIdentifier;
  @JsonKey(name: 'open_date')
  final String? openDate;
  @JsonKey(name: 'close_date')
  final String? closeDate;

  AccountUpdate({
    this.locationId,
    this.accountNumber,
    this.address,
    this.fio,
    this.phone,
    this.email,
    this.area,
    this.serviceType,
    this.status,
    this.jkuIdentifier,
    this.openDate,
    this.closeDate,
  });

  factory AccountUpdate.fromJson(Map<String, dynamic> json) => _$AccountUpdateFromJson(json);
  Map<String, dynamic> toJson() => _$AccountUpdateToJson(this);
}
