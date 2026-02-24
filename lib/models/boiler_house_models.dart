import 'package:json_annotation/json_annotation.dart';
import 'incident_models.dart';

part 'boiler_house_models.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class BoilerHouseResponse {
  final int id;
  final String address;
  final double latitude;
  final double longitude;
  final String? managementCompanyId;
  final Map<String, dynamic>? additionalData;
  final int? createdBy;
  final int? updatedBy;
  final String createdAt;
  final String? updatedAt;
  final String? siteNumber;
  final String? siteManager;
  final String? boilerHouseUUID;
  final int? incidentCount;
  final List<PhotoInfo>? photos;

  BoilerHouseResponse({
    required this.id,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.managementCompanyId,
    this.additionalData,
    this.createdBy,
    this.updatedBy,
    required this.createdAt,
    this.updatedAt,
    this.siteNumber,
    this.siteManager,
    this.boilerHouseUUID,
    this.incidentCount,
    this.photos,
  });

  factory BoilerHouseResponse.fromJson(Map<String, dynamic> json) => _$BoilerHouseResponseFromJson(json);
  Map<String, dynamic> toJson() => _$BoilerHouseResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class BoilerHouseCreate {
  final String address;
  final double latitude;
  final double longitude;
  final String? managementCompanyId;
  final Map<String, dynamic>? additionalData;
  final String? siteNumber;
  final String? siteManager;
  final String? boilerHouseUUID;

  BoilerHouseCreate({
    required this.address,
    required this.latitude,
    required this.longitude,
    this.managementCompanyId,
    this.additionalData,
    this.siteNumber,
    this.siteManager,
    this.boilerHouseUUID,
  });

  factory BoilerHouseCreate.fromJson(Map<String, dynamic> json) => _$BoilerHouseCreateFromJson(json);
  Map<String, dynamic> toJson() => _$BoilerHouseCreateToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class BoilerHouseUpdate {
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? managementCompanyId;
  final Map<String, dynamic>? additionalData;
  final String? siteNumber;
  final String? siteManager;

  BoilerHouseUpdate({
    this.address,
    this.latitude,
    this.longitude,
    this.managementCompanyId,
    this.additionalData,
    this.siteNumber,
    this.siteManager,
  });

  factory BoilerHouseUpdate.fromJson(Map<String, dynamic> json) => _$BoilerHouseUpdateFromJson(json);
  Map<String, dynamic> toJson() => _$BoilerHouseUpdateToJson(this);
}
