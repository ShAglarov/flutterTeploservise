import 'package:json_annotation/json_annotation.dart';
import 'incident_models.dart';

part 'location_models.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class SavedLocationResponse {
  final int id;
  final int? userId;
  final String name;
  final double latitude;
  final double longitude;
  final String? managementCompanyId;
  final int? boilerHouseId;
  final int? floors;
  final int? residentsCount;
  final int? rooms;
  final double? totalArea;
  final int? yearBuilt;
  final String? fiasHouseGuid;
  final String? fiasAOGuid;
  final String? locationUUID;
  final bool? providesHeating;
  final bool? providesHotWater;
  final String? managementCompanyName;
  final int? accountsCount;
  final String createdAt;
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
    this.accountsCount,
    required this.createdAt,
    this.updatedAt,
    this.photos,
    this.accounts,
  });

  factory SavedLocationResponse.fromJson(Map<String, dynamic> json) => _$SavedLocationResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SavedLocationResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class SavedLocationCreate {
  final String name;
  final double latitude;
  final double longitude;
  final String? managementCompanyId;
  final int? boilerHouseId;
  final int? floors;
  final int? residentsCount;
  final int? rooms;
  final double? totalArea;
  final int? yearBuilt;
  final String? fiasHouseGuid;
  final String? fiasAOGuid;
  final String? locationUUID;
  final bool? providesHeating;
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

@JsonSerializable(fieldRename: FieldRename.snake)
class SavedLocationUpdate {
  final String? name;
  final double? latitude;
  final double? longitude;
  final String? managementCompanyId;
  final int? boilerHouseId;
  final int? floors;
  final int? residentsCount;
  final int? rooms;
  final double? totalArea;
  final int? yearBuilt;
  final String? fiasHouseGuid;
  final String? fiasAOGuid;
  final String? locationUUID;
  final bool? providesHeating;
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

@JsonSerializable(fieldRename: FieldRename.snake)
class AccountResponse {
  final int id;
  final int? locationId;
  final String accountNumber;
  final String? address;
  final String? fio;
  final String? phone;
  final String? email;
  final double? area;
  final String? serviceType;
  final String? status;
  final String? jkuIdentifier;
  final String? openDate;
  final String? closeDate;
  final String createdAt;
  final String? updatedAt;
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

@JsonSerializable(fieldRename: FieldRename.snake)
class AccountCreate {
  final int locationId;
  final String accountNumber;
  final String? address;
  final String? fio;
  final String? phone;
  final String? email;
  final double? area;
  final String? serviceType;
  final String? status;
  final String? jkuIdentifier;
  final String? openDate;
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

@JsonSerializable(fieldRename: FieldRename.snake)
class AccountUpdate {
  final int? locationId;
  final String? accountNumber;
  final String? address;
  final String? fio;
  final String? phone;
  final String? email;
  final double? area;
  final String? serviceType;
  final String? status;
  final String? jkuIdentifier;
  final String? openDate;
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
