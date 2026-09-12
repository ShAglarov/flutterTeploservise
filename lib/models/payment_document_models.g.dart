// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_document_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentDocument _$PaymentDocumentFromJson(
  Map<String, dynamic> json,
) => PaymentDocument(
  id: (json['id'] as num).toInt(),
  accountId: (json['account_id'] as num).toInt(),
  periodDate: json['period_date'] as String?,
  debtHeatingStart: (json['debt_heating_start'] as num?)?.toDouble() ?? 0.0,
  chargedHeating: (json['charged_heating'] as num?)?.toDouble() ?? 0.0,
  paidHeating: (json['paid_heating'] as num?)?.toDouble() ?? 0.0,
  recalcHeating: (json['recalc_heating'] as num?)?.toDouble() ?? 0.0,
  debtHeatingEnd: (json['debt_heating_end'] as num?)?.toDouble() ?? 0.0,
  debtHotWaterStart: (json['debt_hot_water_start'] as num?)?.toDouble() ?? 0.0,
  chargedHotWater: (json['charged_hot_water'] as num?)?.toDouble() ?? 0.0,
  paidHotWater: (json['paid_hot_water'] as num?)?.toDouble() ?? 0.0,
  recalcHotWater: (json['recalc_hot_water'] as num?)?.toDouble() ?? 0.0,
  debtHotWaterEnd: (json['debt_hot_water_end'] as num?)?.toDouble() ?? 0.0,
  debtMaintenanceStart:
      (json['debt_maintenance_start'] as num?)?.toDouble() ?? 0.0,
  chargedMaintenance: (json['charged_maintenance'] as num?)?.toDouble() ?? 0.0,
  paidMaintenance: (json['paid_maintenance'] as num?)?.toDouble() ?? 0.0,
  recalcMaintenance: (json['recalc_maintenance'] as num?)?.toDouble() ?? 0.0,
  debtMaintenanceEnd: (json['debt_maintenance_end'] as num?)?.toDouble() ?? 0.0,
  debtWasteStart: (json['debt_waste_start'] as num?)?.toDouble() ?? 0.0,
  chargedWaste: (json['charged_waste'] as num?)?.toDouble() ?? 0.0,
  paidWaste: (json['paid_waste'] as num?)?.toDouble() ?? 0.0,
  recalcWaste: (json['recalc_waste'] as num?)?.toDouble() ?? 0.0,
  debtWasteEnd: (json['debt_waste_end'] as num?)?.toDouble() ?? 0.0,
  debtOdnElectricityStart:
      (json['debt_odn_electricity_start'] as num?)?.toDouble() ?? 0.0,
  chargedOdnElectricity:
      (json['charged_odn_electricity'] as num?)?.toDouble() ?? 0.0,
  paidOdnElectricity: (json['paid_odn_electricity'] as num?)?.toDouble() ?? 0.0,
  recalcOdnElectricity:
      (json['recalc_odn_electricity'] as num?)?.toDouble() ?? 0.0,
  debtOdnElectricityEnd:
      (json['debt_odn_electricity_end'] as num?)?.toDouble() ?? 0.0,
  debtOdnWaterStart: (json['debt_odn_water_start'] as num?)?.toDouble() ?? 0.0,
  chargedOdnWater: (json['charged_odn_water'] as num?)?.toDouble() ?? 0.0,
  paidOdnWater: (json['paid_odn_water'] as num?)?.toDouble() ?? 0.0,
  recalcOdnWater: (json['recalc_odn_water'] as num?)?.toDouble() ?? 0.0,
  debtOdnWaterEnd: (json['debt_odn_water_end'] as num?)?.toDouble() ?? 0.0,
  t30: (json['t30'] as num?)?.toDouble() ?? 0.0,
  t31: (json['t31'] as num?)?.toDouble() ?? 0.0,
  residentsCount: (json['residents_count'] as num?)?.toInt(),
  fs: (json['fs'] as num?)?.toDouble(),
  importSource: json['import_source'] as String?,
  totalDebtStart: (json['total_debt_start'] as num?)?.toDouble(),
  totalDebtEnd: (json['total_debt_end'] as num?)?.toDouble(),
  totalCharged: (json['total_charged'] as num?)?.toDouble(),
  totalPaid: (json['total_paid'] as num?)?.toDouble(),
  accountNumber: json['account_number'] as String?,
  fio: json['fio'] as String?,
  address: json['address'] as String?,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$PaymentDocumentToJson(PaymentDocument instance) =>
    <String, dynamic>{
      'id': instance.id,
      'account_id': instance.accountId,
      'period_date': instance.periodDate,
      'debt_heating_start': instance.debtHeatingStart,
      'charged_heating': instance.chargedHeating,
      'paid_heating': instance.paidHeating,
      'recalc_heating': instance.recalcHeating,
      'debt_heating_end': instance.debtHeatingEnd,
      'debt_hot_water_start': instance.debtHotWaterStart,
      'charged_hot_water': instance.chargedHotWater,
      'paid_hot_water': instance.paidHotWater,
      'recalc_hot_water': instance.recalcHotWater,
      'debt_hot_water_end': instance.debtHotWaterEnd,
      'debt_maintenance_start': instance.debtMaintenanceStart,
      'charged_maintenance': instance.chargedMaintenance,
      'paid_maintenance': instance.paidMaintenance,
      'recalc_maintenance': instance.recalcMaintenance,
      'debt_maintenance_end': instance.debtMaintenanceEnd,
      'debt_waste_start': instance.debtWasteStart,
      'charged_waste': instance.chargedWaste,
      'paid_waste': instance.paidWaste,
      'recalc_waste': instance.recalcWaste,
      'debt_waste_end': instance.debtWasteEnd,
      'debt_odn_electricity_start': instance.debtOdnElectricityStart,
      'charged_odn_electricity': instance.chargedOdnElectricity,
      'paid_odn_electricity': instance.paidOdnElectricity,
      'recalc_odn_electricity': instance.recalcOdnElectricity,
      'debt_odn_electricity_end': instance.debtOdnElectricityEnd,
      'debt_odn_water_start': instance.debtOdnWaterStart,
      'charged_odn_water': instance.chargedOdnWater,
      'paid_odn_water': instance.paidOdnWater,
      'recalc_odn_water': instance.recalcOdnWater,
      'debt_odn_water_end': instance.debtOdnWaterEnd,
      't30': instance.t30,
      't31': instance.t31,
      'residents_count': instance.residentsCount,
      'fs': instance.fs,
      'import_source': instance.importSource,
      'total_debt_start': instance.totalDebtStart,
      'total_debt_end': instance.totalDebtEnd,
      'total_charged': instance.totalCharged,
      'total_paid': instance.totalPaid,
      'account_number': instance.accountNumber,
      'fio': instance.fio,
      'address': instance.address,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

ImportResult _$ImportResultFromJson(Map<String, dynamic> json) => ImportResult(
  status: json['status'] as String,
  filename: json['filename'] as String?,
  periodDate: json['period_date'] as String?,
  statistics: json['statistics'] == null
      ? null
      : ImportStatistics.fromJson(json['statistics'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ImportResultToJson(ImportResult instance) =>
    <String, dynamic>{
      'status': instance.status,
      'filename': instance.filename,
      'period_date': instance.periodDate,
      'statistics': instance.statistics,
    };

ImportStatistics _$ImportStatisticsFromJson(Map<String, dynamic> json) =>
    ImportStatistics(
      totalRows: (json['total_rows'] as num?)?.toInt() ?? 0,
      accountsCreated: (json['accounts_created'] as num?)?.toInt() ?? 0,
      accountsUpdated: (json['accounts_updated'] as num?)?.toInt() ?? 0,
      paymentDocsCreated: (json['payment_docs_created'] as num?)?.toInt() ?? 0,
      paymentDocsUpdated: (json['payment_docs_updated'] as num?)?.toInt() ?? 0,
      locationsCreated: (json['locations_created'] as num?)?.toInt() ?? 0,
      errors: (json['errors'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$ImportStatisticsToJson(ImportStatistics instance) =>
    <String, dynamic>{
      'total_rows': instance.totalRows,
      'accounts_created': instance.accountsCreated,
      'accounts_updated': instance.accountsUpdated,
      'payment_docs_created': instance.paymentDocsCreated,
      'payment_docs_updated': instance.paymentDocsUpdated,
      'locations_created': instance.locationsCreated,
      'errors': instance.errors,
    };
