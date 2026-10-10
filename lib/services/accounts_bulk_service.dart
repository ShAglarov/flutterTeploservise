import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../utils/safe_filename.dart';
import 'base_api_service.dart';

/// Массовое создание лицевых счетов — по домам и из файла.
///
/// Вынесено в сервис, а не живёт в экране: тех же вызовов требуют два
/// экрана (настройки и карточка дома), а Dio-запросы внутри виджета
/// пришлось бы дублировать.
final accountsBulkServiceProvider = Provider<AccountsBulkService>((ref) {
  return AccountsBulkService(ref.watch(dioProvider));
});

/// Дом-кандидат на создание счетов.
class BulkHouse {
  final int id;
  final String name;
  final int? boilerHouseId;
  final String? boilerHouseName;

  /// Количество КВАРТИР из карточки дома. Нежилые помещения сюда не
  /// входят — счета по ним заводятся отдельно.
  final int? apartments;

  /// Сколько лицевых счетов уже есть. По этому числу экран снимает
  /// галочку: повторно создавать не нужно.
  final int accountsCount;

  final String? cadastralNumber;

  const BulkHouse({
    required this.id,
    required this.name,
    this.boilerHouseId,
    this.boilerHouseName,
    this.apartments,
    this.accountsCount = 0,
    this.cadastralNumber,
  });

  factory BulkHouse.fromJson(Map<String, dynamic> json) => BulkHouse(
        id: json['id'] as int,
        name: json['name']?.toString() ?? '',
        boilerHouseId: json['boiler_house_id'] as int?,
        boilerHouseName: json['boiler_house_name'] as String?,
        apartments: json['apartments'] as int?,
        accountsCount: (json['accounts_count'] as num?)?.toInt() ?? 0,
        cadastralNumber: json['cadastral_number'] as String?,
      );

  /// Счета уже созданы — дом по умолчанию не отмечается.
  bool get hasAccounts => accountsCount > 0;

  /// Без количества квартир создавать нечего.
  bool get canGenerate => (apartments ?? 0) > 0;

  /// Сколько счетов появится: уже существующие пропускаются сервером.
  int get plannedCount {
    final total = apartments ?? 0;
    final left = total - accountsCount;
    return left > 0 ? left : 0;
  }
}

/// Итог создания — общий для всех режимов.
class BulkResult {
  final bool dryRun;
  final int created;

  /// Сколько будет создано в пробном прогоне.
  final int wouldCreate;
  final int skipped;
  final List<String> warnings;
  final List<BulkHouseResult> houses;

  /// Адреса из файла, которым не нашлось дома.
  final List<String> unresolvedAddresses;

  /// Была ли это замена ранее загруженных счетов.
  final bool replaced;

  /// Сколько счетов удалено — всего и из них «не было в файле».
  final int deleted;
  final int deletedAbsent;

  /// Обновлено на месте: счёт с платежами удалять нельзя.
  final int updated;

  /// Оставлено, хотя в файле их нет: за ними деньги.
  final int keptWithHistory;

  const BulkResult({
    required this.dryRun,
    required this.created,
    required this.wouldCreate,
    required this.skipped,
    required this.warnings,
    required this.houses,
    required this.unresolvedAddresses,
    this.replaced = false,
    this.deleted = 0,
    this.deletedAbsent = 0,
    this.updated = 0,
    this.keptWithHistory = 0,
  });

  factory BulkResult.fromJson(Map<String, dynamic> json) => BulkResult(
        dryRun: json['dry_run'] as bool? ?? false,
        created: (json['created'] as num?)?.toInt() ?? 0,
        wouldCreate: (json['would_create'] as num?)?.toInt() ?? 0,
        skipped: (json['skipped'] as num?)?.toInt() ?? 0,
        warnings: ((json['warnings'] as List?) ?? const [])
            .map((e) => e.toString())
            .toList(),
        houses: ((json['houses'] as List?) ?? const [])
            .map((e) => BulkHouseResult.fromJson((e as Map).cast()))
            .toList(),
        unresolvedAddresses:
            ((json['unresolved_addresses'] as List?) ?? const [])
                .map((e) => e.toString())
                .toList(),
        replaced: json['replaced'] as bool? ?? false,
        deleted: (json['deleted'] as num?)?.toInt() ?? 0,
        deletedAbsent: (json['deleted_absent'] as num?)?.toInt() ?? 0,
        updated: (json['updated'] as num?)?.toInt() ?? 0,
        keptWithHistory: (json['kept_with_history'] as num?)?.toInt() ?? 0,
      );
}

/// Что получилось по одному дому.
class BulkHouseResult {
  final int? locationId;
  final String? name;

  /// Адрес, как он написан в файле. Отличается от `name`, когда дом
  /// нашёлся нечётко: «Айвазовского 2» → «ул. Айвазовского, д. 2А».
  final String? addressInFile;
  final int created;
  final int skipped;
  final int rows;

  /// Почему дом пропущен целиком.
  final String? reason;

  const BulkHouseResult({
    this.locationId,
    this.name,
    this.addressInFile,
    this.created = 0,
    this.skipped = 0,
    this.rows = 0,
    this.reason,
  });

  factory BulkHouseResult.fromJson(Map<String, dynamic> json) =>
      BulkHouseResult(
        locationId: json['location_id'] as int?,
        name: json['name'] as String?,
        addressInFile: json['address_in_file'] as String?,
        created: (json['created'] as num?)?.toInt() ?? 0,
        skipped: (json['skipped'] as num?)?.toInt() ?? 0,
        rows: (json['rows'] as num?)?.toInt() ?? 0,
        reason: json['reason'] as String?,
      );
}

/// Колонка шаблона-таблицы — для справки на экране.
class TemplateField {
  final String key;
  final String title;

  /// Куда уедет в портал: лист и колонка шаблона ЛС.
  final String gis;
  final String example;
  final bool required;

  const TemplateField({
    required this.key,
    required this.title,
    required this.gis,
    required this.example,
    required this.required,
  });

  factory TemplateField.fromJson(Map<String, dynamic> json) => TemplateField(
        key: json['key']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        gis: json['gis']?.toString() ?? '',
        example: json['example']?.toString() ?? '',
        required: json['required'] as bool? ?? false,
      );
}

/// Разобранный файл: строки и сводка по домам.
class ParsedApartments {
  final int count;
  final List<Map<String, dynamic>> rows;

  /// Адреса домов из файла. Пусто — колонки адреса нет, и файл
  /// относится к одному дому.
  final List<String> addresses;
  final Map<String, int> byAddress;
  final bool multiHouse;
  final int withoutAddress;
  final Map<String, String> columns;
  final List<String> warnings;

  const ParsedApartments({
    required this.count,
    required this.rows,
    required this.addresses,
    required this.byAddress,
    required this.multiHouse,
    required this.withoutAddress,
    required this.columns,
    required this.warnings,
  });

  factory ParsedApartments.fromJson(Map<String, dynamic> json) {
    final byAddress = <String, int>{};
    for (final entry in (json['by_address'] as List?) ?? const []) {
      final map = (entry as Map).cast<String, dynamic>();
      byAddress[map['address']?.toString() ?? ''] =
          (map['count'] as num?)?.toInt() ?? 0;
    }
    return ParsedApartments(
      count: (json['count'] as num?)?.toInt() ?? 0,
      rows: ((json['rows'] as List?) ?? const [])
          .map((e) => (e as Map).cast<String, dynamic>())
          .toList(),
      addresses: ((json['addresses'] as List?) ?? const [])
          .map((e) => e.toString())
          .toList(),
      byAddress: byAddress,
      multiHouse: json['multi_house'] as bool? ?? false,
      withoutAddress: (json['without_address'] as num?)?.toInt() ?? 0,
      columns: ((json['columns'] as Map?) ?? const {})
          .map((k, v) => MapEntry(k.toString(), v.toString())),
      warnings: ((json['warnings'] as List?) ?? const [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}

/// Сервер не умеет замену: обновлён клиент, но не бэкенд.
///
/// Отдельным типом, а не текстом в общей ошибке: экран по нему
/// показывает, что именно делать, и — главное — НЕ сообщает об успехе.
class BulkReplaceUnsupported implements Exception {
  const BulkReplaceUnsupported();

  @override
  String toString() =>
      'Сервер не поддерживает замену лицевых счетов: обновлён клиент, '
      'но не серверная часть. Запустите deploy_accounts_mass.sh — '
      'до этого замена молча добавляла бы счета к прежним.';
}

class AccountsBulkService {
  final Dio _dio;

  AccountsBulkService(this._dio);

  /// Разбор больших таблиц и создание тысяч счетов идут дольше обычного
  /// запроса, поэтому таймаут поднят.
  static const _long = Duration(minutes: 5);

  Future<List<BulkHouse>> houses() async {
    final response = await _dio.get('/accounts/bulk-generate/candidates');
    final data = (response.data as Map).cast<String, dynamic>();
    return ((data['houses'] as List?) ?? const [])
        .map((e) => BulkHouse.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  Future<List<TemplateField>> templateFields() async {
    final response = await _dio.get('/accounts/apartments-template/fields');
    final data = (response.data as Map).cast<String, dynamic>();
    return ((data['columns'] as List?) ?? const [])
        .map((e) => TemplateField.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  /// Скачивает шаблон-таблицу во временный файл.
  ///
  /// `prefill` — подставить адреса домов и номера квартир: оператору
  /// остаётся вписать площади и ФИО, а не копировать адрес в каждую
  /// строку вручную.
  Future<File> downloadTemplate({bool prefill = true}) async {
    final response = await _dio.get<List<int>>(
      '/accounts/apartments-template/download',
      queryParameters: {'prefill': prefill},
      options: Options(responseType: ResponseType.bytes),
    );
    final dir = await getTemporaryDirectory();
    final name = safeFileName(
      'Лицевые счета ${fileTimeStamp()}.xlsx',
      fallback: 'accounts_template.xlsx',
    );
    final file = File(p.join(dir.path, name));
    await file.writeAsBytes(response.data ?? const []);
    return file;
  }

  /// Что нашлось в файле — без записи в базу.
  Future<ParsedApartments> previewFile(String filePath) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    final response = await _dio.post(
      '/accounts/import-apartments/preview',
      data: form,
      options: Options(receiveTimeout: _long),
    );
    return ParsedApartments.fromJson((response.data as Map).cast());
  }

  /// Создание счетов по домам: номера квартир 1..N из карточки дома.
  Future<BulkResult> generateByHouses({
    required List<int> locationIds,
    required String numberTemplate,
    String? jkuTemplate,
    required String premisesType,
    required String accountType,
    bool dryRun = false,
  }) async {
    final response = await _dio.post(
      '/accounts/bulk-generate/multi',
      data: {
        'location_ids': locationIds,
        'number_template': numberTemplate,
        if (jkuTemplate != null && jkuTemplate.isNotEmpty)
          'jku_template': jkuTemplate,
        'premises_type': premisesType,
        'account_type': accountType,
        'dry_run': dryRun,
      },
      options: Options(receiveTimeout: _long),
    );
    return BulkResult.fromJson((response.data as Map).cast());
  }

  /// Создание счетов по ВСЕМУ файлу: дом у каждой строки свой.
  ///
  /// Отправляется сам файл, а не строки предпросмотра: предпросмотр
  /// отдаёт только первые 100 строк, и по ним из таблицы на пять тысяч
  /// квартир создалось бы сто счетов. Сервер разбирает файл заново.
  Future<BulkResult> importFile({
    required String filePath,
    int? defaultLocationId,
    required String numberTemplate,
    String? jkuTemplate,
    required String premisesType,
    required String accountType,
    bool preferFileNumbers = true,
    bool replaceExisting = false,
    bool dryRun = false,
  }) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    final response = await _dio.post(
      '/accounts/import-apartments/file',
      data: form,
      queryParameters: {
        'default_location_id': ?defaultLocationId,
        'number_template': numberTemplate,
        if (jkuTemplate != null && jkuTemplate.isNotEmpty)
          'jku_template': jkuTemplate,
        'premises_type': premisesType,
        'account_type': accountType,
        'prefer_file_numbers': preferFileNumbers,
        'replace_existing': replaceExisting,
        'dry_run': dryRun,
      },
      options: Options(receiveTimeout: _long, sendTimeout: _long),
    );
    final result = BulkResult.fromJson((response.data as Map).cast());

    // СТРАХОВКА ОТ СТАРОГО БЭКЕНДА.
    //
    // FastAPI молча отбрасывает неизвестные query-параметры: сервер без
    // поддержки замены принял бы запрос, проигнорировал
    // `replace_existing` и ДОБАВИЛ счета к прежним вместо замены.
    // Ответ такого сервера не содержит `replaced`, поэтому ловим это
    // здесь и говорим прямо, вместо того чтобы показать «создано N» и
    // оставить дубли в базе.
    if (replaceExisting && !result.replaced) {
      throw const BulkReplaceUnsupported();
    }
    return result;
  }

  /// Создание счетов по уже разобранным строкам.
  Future<BulkResult> importRows({
    required List<Map<String, dynamic>> rows,
    int? defaultLocationId,
    required String numberTemplate,
    String? jkuTemplate,
    required String premisesType,
    required String accountType,
    bool preferFileNumbers = true,
    bool dryRun = false,
  }) async {
    final response = await _dio.post(
      '/accounts/import-apartments/multi',
      data: {
        'apartments': rows,
        'default_location_id': ?defaultLocationId,
        'number_template': numberTemplate,
        if (jkuTemplate != null && jkuTemplate.isNotEmpty)
          'jku_template': jkuTemplate,
        'premises_type': premisesType,
        'account_type': accountType,
        'prefer_file_numbers': preferFileNumbers,
        'dry_run': dryRun,
      },
      options: Options(receiveTimeout: _long),
    );
    return BulkResult.fromJson((response.data as Map).cast());
  }
}
