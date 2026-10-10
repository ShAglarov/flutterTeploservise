/// Сведения для шаблонов ГИС ЖКХ: подъезды, лифты, комнаты, основания
/// лицевых счетов, дополнительные листы платёжного документа и
/// расширенные параметры («Информация о МКД», «Конструктивные
/// элементы», «Внутридомовые сети» и т. д.).
///
/// JSON пишется руками, без json_serializable: запуск build_runner
/// перегенерировал бы все *.g.dart проекта (так же, как в
/// organization_models.dart).
///
/// Незаполненные поля в запрос НЕ попадают — сервер отличает «не
/// передано» от «очищено», поэтому `toJson` пропускает null.

/// Один параметр каталога: название, тип значения и справочник.
library;

class GisParamDef {
  final String code;

  /// Название ДОСЛОВНО как в шаблоне — портал сверяет его посимвольно.
  final String name;

  /// number / integer / year / date / bool / enum / string.
  final String valueType;
  final String? unit;
  final bool multiple;
  final List<String> values;

  const GisParamDef({
    required this.code,
    required this.name,
    required this.valueType,
    this.unit,
    required this.multiple,
    required this.values,
  });

  factory GisParamDef.fromJson(Map<String, dynamic> json) => GisParamDef(
        code: json['code']?.toString() ?? '',
        name: json['name'] as String,
        valueType: json['value_type'] as String? ?? 'string',
        unit: json['unit'] as String?,
        multiple: json['multiple'] as bool? ?? false,
        values: (json['values'] as List?)?.map((e) => e.toString()).toList() ??
            const [],
      );

  /// Короткая подпись без технического хвоста: в шаблоне названия
  /// заканчиваются пометкой типа — «Общий износ здания
  /// (вещественное),%». В форме она только мешает.
  String get label {
    final cut = name.indexOf('(');
    final base = cut > 0 ? name.substring(0, cut).trim() : name;
    return unit == null ? base : '$base, $unit';
  }
}

/// Группа параметров = лист шаблона.
class GisParamGroup {
  final String key;
  final String sheet;

  /// house / lift / premises / room.
  final String ownerType;
  final String title;
  final List<GisParamDef> params;

  const GisParamGroup({
    required this.key,
    required this.sheet,
    required this.ownerType,
    required this.title,
    required this.params,
  });

  factory GisParamGroup.fromJson(Map<String, dynamic> json) => GisParamGroup(
        key: json['key'] as String,
        sheet: json['sheet'] as String? ?? '',
        ownerType: json['owner_type'] as String,
        title: json['title'] as String? ?? '',
        params: (json['params'] as List? ?? [])
            .map((e) => GisParamDef.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

/// Сохранённое значение параметра у объекта.
class GisParamValue {
  final String paramName;
  final String? value;

  const GisParamValue({required this.paramName, this.value});

  factory GisParamValue.fromJson(Map<String, dynamic> json) => GisParamValue(
        paramName: json['param_name'] as String,
        value: json['value'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'param_name': paramName,
        if (value != null) 'value': value,
      };
}

class Entrance {
  final int? id;
  final int locationId;
  final String number;
  final int? floors;
  final int? yearBuilt;
  final bool confirmed;
  final String? gisStatus;

  const Entrance({
    this.id,
    required this.locationId,
    required this.number,
    this.floors,
    this.yearBuilt,
    this.confirmed = true,
    this.gisStatus,
  });

  factory Entrance.fromJson(Map<String, dynamic> json) => Entrance(
        id: json['id'] as int?,
        locationId: json['location_id'] as int,
        number: json['number']?.toString() ?? '',
        floors: json['floors'] as int?,
        yearBuilt: json['year_built'] as int?,
        confirmed: json['confirmed'] as bool? ?? true,
        gisStatus: json['gis_status'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'location_id': locationId,
        'number': number,
        if (floors != null) 'floors': floors,
        if (yearBuilt != null) 'year_built': yearBuilt,
        'confirmed': confirmed,
      };
}

class Lift {
  final int? id;
  final int locationId;
  final int? entranceId;
  final String factoryNumber;
  final String? liftType;
  final int? serviceLifeUntil;
  final String? gisStatus;

  const Lift({
    this.id,
    required this.locationId,
    this.entranceId,
    required this.factoryNumber,
    this.liftType,
    this.serviceLifeUntil,
    this.gisStatus,
  });

  factory Lift.fromJson(Map<String, dynamic> json) => Lift(
        id: json['id'] as int?,
        locationId: json['location_id'] as int,
        entranceId: json['entrance_id'] as int?,
        factoryNumber: json['factory_number']?.toString() ?? '',
        liftType: json['lift_type'] as String?,
        serviceLifeUntil: json['service_life_until'] as int?,
        gisStatus: json['gis_status'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'location_id': locationId,
        if (entranceId != null) 'entrance_id': entranceId,
        'factory_number': factoryNumber,
        if (liftType != null) 'lift_type': liftType,
        if (serviceLifeUntil != null) 'service_life_until': serviceLifeUntil,
      };
}

class GisRoom {
  final int? id;
  final int accountId;
  final String number;
  final double? area;
  final String? cadastralNumber;
  final bool confirmed;
  // Лист «Доп критерии поиска в ЕГРП», колонка D «Номер комнаты»:
  // привязку к ЕГРП можно задать комнате, а не только помещению.
  final String? gisEgrpConditionalNumber;
  final String? gisEgrpRegistrationNumber;
  final DateTime? gisEgrpRegistrationDate;
  final String? gisStatus;

  const GisRoom({
    this.id,
    required this.accountId,
    required this.number,
    this.area,
    this.cadastralNumber,
    this.confirmed = true,
    this.gisEgrpConditionalNumber,
    this.gisEgrpRegistrationNumber,
    this.gisEgrpRegistrationDate,
    this.gisStatus,
  });

  static DateTime? _date(dynamic value) =>
      value == null ? null : DateTime.tryParse(value.toString());

  factory GisRoom.fromJson(Map<String, dynamic> json) => GisRoom(
        id: json['id'] as int?,
        accountId: json['account_id'] as int,
        number: json['number']?.toString() ?? '',
        area: (json['area'] as num?)?.toDouble(),
        cadastralNumber: json['cadastral_number'] as String?,
        confirmed: json['confirmed'] as bool? ?? true,
        gisEgrpConditionalNumber:
            json['gis_egrp_conditional_number'] as String?,
        gisEgrpRegistrationNumber:
            json['gis_egrp_registration_number'] as String?,
        gisEgrpRegistrationDate: _date(json['gis_egrp_registration_date']),
        gisStatus: json['gis_status'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'account_id': accountId,
        'number': number,
        if (area != null) 'area': area,
        if (cadastralNumber != null) 'cadastral_number': cadastralNumber,
        'confirmed': confirmed,
        if (gisEgrpConditionalNumber != null)
          'gis_egrp_conditional_number': gisEgrpConditionalNumber,
        if (gisEgrpRegistrationNumber != null)
          'gis_egrp_registration_number': gisEgrpRegistrationNumber,
        if (gisEgrpRegistrationDate != null)
          'gis_egrp_registration_date':
              gisEgrpRegistrationDate!.toIso8601String().split('T').first,
      };
}

/// Основание лицевого счёта: договор соцнайма, ресурсоснабжения или ТКО.
class AccountBasis {
  final int? id;
  final int accountId;
  final String basisType;
  final String? basisIdentifier;
  final String? socialType;
  final String? socialNumber;
  final DateTime? socialDate;
  final bool? supplyNotPublic;
  final String? supplyNumber;
  final DateTime? supplyDate;
  final String? wasteNumber;
  final DateTime? wasteDate;
  final DateTime? wasteEffectiveDate;
  final String? gisStatus;

  const AccountBasis({
    this.id,
    required this.accountId,
    required this.basisType,
    this.basisIdentifier,
    this.socialType,
    this.socialNumber,
    this.socialDate,
    this.supplyNotPublic,
    this.supplyNumber,
    this.supplyDate,
    this.wasteNumber,
    this.wasteDate,
    this.wasteEffectiveDate,
    this.gisStatus,
  });

  static DateTime? _date(dynamic value) =>
      value == null ? null : DateTime.tryParse(value.toString());

  static String? _iso(DateTime? value) =>
      value?.toIso8601String().split('T').first;

  factory AccountBasis.fromJson(Map<String, dynamic> json) => AccountBasis(
        id: json['id'] as int?,
        accountId: json['account_id'] as int,
        basisType: json['basis_type']?.toString() ?? '',
        basisIdentifier: json['basis_identifier'] as String?,
        socialType: json['social_type'] as String?,
        socialNumber: json['social_number'] as String?,
        socialDate: _date(json['social_date']),
        supplyNotPublic: json['supply_not_public'] as bool?,
        supplyNumber: json['supply_number'] as String?,
        supplyDate: _date(json['supply_date']),
        wasteNumber: json['waste_number'] as String?,
        wasteDate: _date(json['waste_date']),
        wasteEffectiveDate: _date(json['waste_effective_date']),
        gisStatus: json['gis_status'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'account_id': accountId,
        'basis_type': basisType,
        if (basisIdentifier != null) 'basis_identifier': basisIdentifier,
        if (socialType != null) 'social_type': socialType,
        if (socialNumber != null) 'social_number': socialNumber,
        if (socialDate != null) 'social_date': _iso(socialDate),
        if (supplyNotPublic != null) 'supply_not_public': supplyNotPublic,
        if (supplyNumber != null) 'supply_number': supplyNumber,
        if (supplyDate != null) 'supply_date': _iso(supplyDate),
        if (wasteNumber != null) 'waste_number': wasteNumber,
        if (wasteDate != null) 'waste_date': _iso(wasteDate),
        if (wasteEffectiveDate != null)
          'waste_effective_date': _iso(wasteEffectiveDate),
      };
}

/// Строка дополнительного листа платёжного документа.
///
/// Одна модель на четыре листа (неустойки, ДПД, составляющие
/// стоимости ЭЭ, платёжные реквизиты): набор полей у них разный, но
/// экран с ними работает одинаково — список строк с суммой и подписью.
class PdExtraRow {
  final int? id;
  final int paymentDocumentId;

  /// penalties / debts / energy / requisites.
  final String kind;
  final Map<String, dynamic> data;

  const PdExtraRow({
    this.id,
    required this.paymentDocumentId,
    required this.kind,
    required this.data,
  });

  factory PdExtraRow.fromJson(String kind, Map<String, dynamic> json) =>
      PdExtraRow(
        id: json['id'] as int?,
        paymentDocumentId: json['payment_document_id'] as int,
        kind: kind,
        data: Map<String, dynamic>.from(json),
      );

  /// Подпись строки в списке — зависит от листа.
  String get title {
    switch (kind) {
      case 'penalties':
        return data['kind']?.toString() ?? 'Начисление';
      case 'debts':
        return data['service']?.toString() ?? 'Услуга';
      case 'energy':
        return data['name']?.toString() ?? 'Составляющая';
      case 'requisites':
        return data['number']?.toString() ?? 'Реквизит';
      default:
        return '—';
    }
  }

  double? get amount => (data['amount'] as num?)?.toDouble();
}
