import 'package:json_annotation/json_annotation.dart';

part 'payment_document_models.g.dart';

@JsonSerializable()
class PaymentDocument {
  final int id;
  @JsonKey(name: 'account_id')
  final int accountId;
  @JsonKey(name: 'period_date')
  final String? periodDate;

  // Отопление
  @JsonKey(name: 'debt_heating_start')
  final double debtHeatingStart;
  @JsonKey(name: 'charged_heating')
  final double chargedHeating;
  @JsonKey(name: 'paid_heating')
  final double paidHeating;
  @JsonKey(name: 'recalc_heating')
  final double recalcHeating;
  @JsonKey(name: 'debt_heating_end')
  final double debtHeatingEnd;

  // ГВС
  @JsonKey(name: 'debt_hot_water_start')
  final double debtHotWaterStart;
  @JsonKey(name: 'charged_hot_water')
  final double chargedHotWater;
  @JsonKey(name: 'paid_hot_water')
  final double paidHotWater;
  @JsonKey(name: 'recalc_hot_water')
  final double recalcHotWater;
  @JsonKey(name: 'debt_hot_water_end')
  final double debtHotWaterEnd;

  // Теплообслуживание
  @JsonKey(name: 'debt_maintenance_start')
  final double debtMaintenanceStart;
  @JsonKey(name: 'charged_maintenance')
  final double chargedMaintenance;
  @JsonKey(name: 'paid_maintenance')
  final double paidMaintenance;
  @JsonKey(name: 'recalc_maintenance')
  final double recalcMaintenance;
  @JsonKey(name: 'debt_maintenance_end')
  final double debtMaintenanceEnd;

  // ТБО
  @JsonKey(name: 'debt_waste_start')
  final double debtWasteStart;
  @JsonKey(name: 'charged_waste')
  final double chargedWaste;
  @JsonKey(name: 'paid_waste')
  final double paidWaste;
  @JsonKey(name: 'recalc_waste')
  final double recalcWaste;
  @JsonKey(name: 'debt_waste_end')
  final double debtWasteEnd;

  // ОДН Электричество
  @JsonKey(name: 'debt_odn_electricity_start')
  final double debtOdnElectricityStart;
  @JsonKey(name: 'charged_odn_electricity')
  final double chargedOdnElectricity;
  @JsonKey(name: 'paid_odn_electricity')
  final double paidOdnElectricity;
  @JsonKey(name: 'recalc_odn_electricity')
  final double recalcOdnElectricity;
  @JsonKey(name: 'debt_odn_electricity_end')
  final double debtOdnElectricityEnd;

  // ОДН Вода
  @JsonKey(name: 'debt_odn_water_start')
  final double debtOdnWaterStart;
  @JsonKey(name: 'charged_odn_water')
  final double chargedOdnWater;
  @JsonKey(name: 'paid_odn_water')
  final double paidOdnWater;
  @JsonKey(name: 'recalc_odn_water')
  final double recalcOdnWater;
  @JsonKey(name: 'debt_odn_water_end')
  final double debtOdnWaterEnd;

  // Температура
  final double t30;
  final double t31;

  // Доп. данные
  @JsonKey(name: 'residents_count')
  final int? residentsCount;
  final double? fs;
  @JsonKey(name: 'import_source')
  final String? importSource;

  // Вычисляемые
  @JsonKey(name: 'total_debt_start')
  final double? totalDebtStart;
  @JsonKey(name: 'total_debt_end')
  final double? totalDebtEnd;
  @JsonKey(name: 'total_charged')
  final double? totalCharged;
  @JsonKey(name: 'total_paid')
  final double? totalPaid;

  // Данные из Account
  @JsonKey(name: 'account_number')
  final String? accountNumber;
  final String? fio;
  final String? address;

  // Метаданные
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  PaymentDocument({
    required this.id,
    required this.accountId,
    this.periodDate,
    this.debtHeatingStart = 0.0,
    this.chargedHeating = 0.0,
    this.paidHeating = 0.0,
    this.recalcHeating = 0.0,
    this.debtHeatingEnd = 0.0,
    this.debtHotWaterStart = 0.0,
    this.chargedHotWater = 0.0,
    this.paidHotWater = 0.0,
    this.recalcHotWater = 0.0,
    this.debtHotWaterEnd = 0.0,
    this.debtMaintenanceStart = 0.0,
    this.chargedMaintenance = 0.0,
    this.paidMaintenance = 0.0,
    this.recalcMaintenance = 0.0,
    this.debtMaintenanceEnd = 0.0,
    this.debtWasteStart = 0.0,
    this.chargedWaste = 0.0,
    this.paidWaste = 0.0,
    this.recalcWaste = 0.0,
    this.debtWasteEnd = 0.0,
    this.debtOdnElectricityStart = 0.0,
    this.chargedOdnElectricity = 0.0,
    this.paidOdnElectricity = 0.0,
    this.recalcOdnElectricity = 0.0,
    this.debtOdnElectricityEnd = 0.0,
    this.debtOdnWaterStart = 0.0,
    this.chargedOdnWater = 0.0,
    this.paidOdnWater = 0.0,
    this.recalcOdnWater = 0.0,
    this.debtOdnWaterEnd = 0.0,
    this.t30 = 0.0,
    this.t31 = 0.0,
    this.residentsCount,
    this.fs,
    this.importSource,
    this.totalDebtStart,
    this.totalDebtEnd,
    this.totalCharged,
    this.totalPaid,
    this.accountNumber,
    this.fio,
    this.address,
    this.createdAt,
    this.updatedAt,
  });

  factory PaymentDocument.fromJson(Map<String, dynamic> json) =>
      _$PaymentDocumentFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentDocumentToJson(this);
}

@JsonSerializable()
class ImportResult {
  final String status;
  final String? filename;
  @JsonKey(name: 'period_date')
  final String? periodDate;
  final ImportStatistics? statistics;

  ImportResult({
    required this.status,
    this.filename,
    this.periodDate,
    this.statistics,
  });

  factory ImportResult.fromJson(Map<String, dynamic> json) =>
      _$ImportResultFromJson(json);

  Map<String, dynamic> toJson() => _$ImportResultToJson(this);
}

@JsonSerializable()
class ImportStatistics {
  @JsonKey(name: 'total_rows')
  final int totalRows;
  @JsonKey(name: 'accounts_created')
  final int accountsCreated;
  @JsonKey(name: 'accounts_updated')
  final int accountsUpdated;
  @JsonKey(name: 'payment_docs_created')
  final int paymentDocsCreated;
  @JsonKey(name: 'payment_docs_updated')
  final int paymentDocsUpdated;
  @JsonKey(name: 'locations_created')
  final int locationsCreated;
  final List<String>? errors;

  ImportStatistics({
    this.totalRows = 0,
    this.accountsCreated = 0,
    this.accountsUpdated = 0,
    this.paymentDocsCreated = 0,
    this.paymentDocsUpdated = 0,
    this.locationsCreated = 0,
    this.errors,
  });

  factory ImportStatistics.fromJson(Map<String, dynamic> json) =>
      _$ImportStatisticsFromJson(json);

  Map<String, dynamic> toJson() => _$ImportStatisticsToJson(this);
}
