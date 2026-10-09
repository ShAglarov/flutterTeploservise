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
  final String? cadastralNumber;
  final String? commissioningDate;
  final String? managementCompanyName;
  final int? accountsCount;
  final String? stoveType;
  final String? housingType;
  final int? entrancesCount;
  // ГИС ЖКХ — лист «Характеристики МКД» шаблона импорта сведений о МКД.
  final String? gisOktmo;
  final String? gisState;
  final String? gisLifecycleStage;
  final int? undergroundFloors;
  final String? gisTimezone;
  final bool? gisCulturalHeritage;
  final bool? gisFederalProperty;
  final bool? gisMunicipalProperty;
  final String? gisHostelType;
  final String? gisStatus;
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
    this.cadastralNumber,
    this.commissioningDate,
    this.managementCompanyName,
    this.accountsCount,
    this.stoveType,
    this.housingType,
    this.entrancesCount,
    this.gisOktmo,
    this.gisState,
    this.gisLifecycleStage,
    this.undergroundFloors,
    this.gisTimezone,
    this.gisCulturalHeritage,
    this.gisFederalProperty,
    this.gisMunicipalProperty,
    this.gisHostelType,
    this.gisStatus,
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
  final String? cadastralNumber;
  final String? commissioningDate;
  final String? stoveType;
  final String? housingType;
  final int? entrancesCount;
  // ГИС ЖКХ — лист «Характеристики МКД» шаблона импорта сведений о МКД.
  final String? gisOktmo;
  final String? gisState;
  final String? gisLifecycleStage;
  final int? undergroundFloors;
  final String? gisTimezone;
  final bool? gisCulturalHeritage;
  final bool? gisFederalProperty;
  final bool? gisMunicipalProperty;
  final String? gisHostelType;
  final String? gisStatus;

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
    this.cadastralNumber,
    this.commissioningDate,
    this.stoveType,
    this.housingType,
    this.entrancesCount,
    this.gisOktmo,
    this.gisState,
    this.gisLifecycleStage,
    this.undergroundFloors,
    this.gisTimezone,
    this.gisCulturalHeritage,
    this.gisFederalProperty,
    this.gisMunicipalProperty,
    this.gisHostelType,
    this.gisStatus,
  });

  factory SavedLocationCreate.fromJson(Map<String, dynamic> json) => _$SavedLocationCreateFromJson(json);
  Map<String, dynamic> toJson() => _$SavedLocationCreateToJson(this);
}

// includeIfNull: false — иначе null-поля ГИС уехали бы на сервер как
// «присланные» и затёрли уже заполненные значения.
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
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
  final String? cadastralNumber;
  final String? commissioningDate;
  final String? stoveType;
  final String? housingType;
  final int? entrancesCount;
  // ГИС ЖКХ — лист «Характеристики МКД» шаблона импорта сведений о МКД.
  final String? gisOktmo;
  final String? gisState;
  final String? gisLifecycleStage;
  final int? undergroundFloors;
  final String? gisTimezone;
  final bool? gisCulturalHeritage;
  final bool? gisFederalProperty;
  final bool? gisMunicipalProperty;
  final String? gisHostelType;
  final String? gisStatus;

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
    this.cadastralNumber,
    this.commissioningDate,
    this.stoveType,
    this.housingType,
    this.entrancesCount,
    this.gisOktmo,
    this.gisState,
    this.gisLifecycleStage,
    this.undergroundFloors,
    this.gisTimezone,
    this.gisCulturalHeritage,
    this.gisFederalProperty,
    this.gisMunicipalProperty,
    this.gisHostelType,
    this.gisStatus,
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
  final String? cadastralNumber;
  final int? roomsCount;
  // ГИС ЖКХ — листы «Основные сведения» и «Помещения» шаблона импорта ЛС.
  final String? gisEls;
  final String? gisAccountType;
  final bool? gisIsTenant;
  final bool? gisIsSplit;
  final String? gisLastName;
  final String? gisFirstName;
  final String? gisMiddleName;
  final String? gisSnils;
  final String? gisDocType;
  final String? gisDocNumber;
  final String? gisDocSeries;
  final String? gisDocDate;
  final String? gisOgrn;
  final String? gisNza;
  final String? gisKpp;
  final double? livingArea;
  final double? heatedArea;
  final int? residentsCount;
  final String? gisPremisesType;
  final String? gisPremisesNumber;
  final String? gisRoomNumber;
  final double? gisPaymentShare;
  // Лист «Доп критерии поиска в ЕГРП» шаблона МКД: нужен, когда
  // привязать помещение по кадастровому номеру не удалось.
  final String? gisEgrpConditionalNumber;
  final String? gisEgrpRegistrationNumber;
  final String? gisEgrpRegistrationDate;
  final String? gisStatus;
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
    this.cadastralNumber,
    this.roomsCount,
    this.gisEls,
    this.gisAccountType,
    this.gisIsTenant,
    this.gisIsSplit,
    this.gisLastName,
    this.gisFirstName,
    this.gisMiddleName,
    this.gisSnils,
    this.gisDocType,
    this.gisDocNumber,
    this.gisDocSeries,
    this.gisDocDate,
    this.gisOgrn,
    this.gisNza,
    this.gisKpp,
    this.livingArea,
    this.heatedArea,
    this.residentsCount,
    this.gisPremisesType,
    this.gisPremisesNumber,
    this.gisRoomNumber,
    this.gisPaymentShare,
    this.gisEgrpConditionalNumber,
    this.gisEgrpRegistrationNumber,
    this.gisEgrpRegistrationDate,
    this.gisStatus,
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
  final String? cadastralNumber;
  final int? roomsCount;

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
    this.cadastralNumber,
    this.roomsCount,
  });

  factory AccountCreate.fromJson(Map<String, dynamic> json) => _$AccountCreateFromJson(json);
  Map<String, dynamic> toJson() => _$AccountCreateToJson(this);
}

// includeIfNull: false — КРИТИЧНО для полей ГИС. По умолчанию toJson()
// отправляет все null, сервер считает их присланными и обнуляет то, что
// в базе уже заполнено (например ЕЛС, который правили в другом экране).
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
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
  final String? cadastralNumber;
  final int? roomsCount;
  // ГИС ЖКХ.
  final String? gisEls;
  final String? gisAccountType;
  final bool? gisIsTenant;
  final bool? gisIsSplit;
  final String? gisLastName;
  final String? gisFirstName;
  final String? gisMiddleName;
  final String? gisSnils;
  final String? gisDocType;
  final String? gisDocNumber;
  final String? gisDocSeries;
  final String? gisDocDate;
  final String? gisOgrn;
  final String? gisNza;
  final String? gisKpp;
  final double? livingArea;
  final double? heatedArea;
  final int? residentsCount;
  final String? gisPremisesType;
  final String? gisPremisesNumber;
  final String? gisRoomNumber;
  final double? gisPaymentShare;
  // Лист «Доп критерии поиска в ЕГРП» шаблона МКД: нужен, когда
  // привязать помещение по кадастровому номеру не удалось.
  final String? gisEgrpConditionalNumber;
  final String? gisEgrpRegistrationNumber;
  final String? gisEgrpRegistrationDate;

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
    this.cadastralNumber,
    this.roomsCount,
    this.gisEls,
    this.gisAccountType,
    this.gisIsTenant,
    this.gisIsSplit,
    this.gisLastName,
    this.gisFirstName,
    this.gisMiddleName,
    this.gisSnils,
    this.gisDocType,
    this.gisDocNumber,
    this.gisDocSeries,
    this.gisDocDate,
    this.gisOgrn,
    this.gisNza,
    this.gisKpp,
    this.livingArea,
    this.heatedArea,
    this.residentsCount,
    this.gisPremisesType,
    this.gisPremisesNumber,
    this.gisRoomNumber,
    this.gisPaymentShare,
    this.gisEgrpConditionalNumber,
    this.gisEgrpRegistrationNumber,
    this.gisEgrpRegistrationDate,
  });

  factory AccountUpdate.fromJson(Map<String, dynamic> json) => _$AccountUpdateFromJson(json);
  Map<String, dynamic> toJson() => _$AccountUpdateToJson(this);
}
