import 'package:json_annotation/json_annotation.dart';

part 'management_company_models.g.dart';

@JsonSerializable()
class ManagementCompanyResponse {
  final String id;
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final String? notes;
  final String? director;
  final Map<String, dynamic>? additionalData;
  @JsonKey(name: 'location_uuids', defaultValue: [])
  final List<String> locationUUIDs;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  ManagementCompanyResponse({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.address,
    this.notes,
    this.director,
    this.additionalData,
    required this.locationUUIDs,
    required this.createdAt,
    this.updatedAt,
  });

  factory ManagementCompanyResponse.fromJson(Map<String, dynamic> json) => _$ManagementCompanyResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ManagementCompanyResponseToJson(this);
}

@JsonSerializable()
class ManagementCompanyCreate {
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final String? notes;
  final String? director;
  final Map<String, dynamic>? additionalData;

  ManagementCompanyCreate({
    required this.name,
    this.phone,
    this.email,
    this.address,
    this.notes,
    this.director,
    this.additionalData,
  });

  factory ManagementCompanyCreate.fromJson(Map<String, dynamic> json) => _$ManagementCompanyCreateFromJson(json);
  Map<String, dynamic> toJson() => _$ManagementCompanyCreateToJson(this);
}

@JsonSerializable()
class ManagementCompanyUpdate {
  final String? name;
  final String? phone;
  final String? email;
  final String? address;
  final String? notes;
  final String? director;
  final Map<String, dynamic>? additionalData;

  ManagementCompanyUpdate({
    this.name,
    this.phone,
    this.email,
    this.address,
    this.notes,
    this.director,
    this.additionalData,
  });

  factory ManagementCompanyUpdate.fromJson(Map<String, dynamic> json) => _$ManagementCompanyUpdateFromJson(json);
  Map<String, dynamic> toJson() => _$ManagementCompanyUpdateToJson(this);
}
