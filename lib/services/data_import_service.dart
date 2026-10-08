import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'base_api_service.dart';

final dataImportServiceProvider = Provider<DataImportService>((ref) {
  return DataImportService(ref.watch(dioProvider));
});

/// Что лежит в файле — до записи в базу.
class ImportPreview {
  final String format;
  final String? exportedAt;
  final Map<String, int> entities;

  const ImportPreview({
    required this.format,
    required this.entities,
    this.exportedAt,
  });

  factory ImportPreview.fromJson(Map<String, dynamic> json) => ImportPreview(
        format: json['format'] as String? ?? '',
        exportedAt: json['exported_at'] as String?,
        entities: ((json['entities'] as Map?) ?? const {}).map(
          (k, v) => MapEntry(k.toString(), (v as num?)?.toInt() ?? 0),
        ),
      );

  String get formatRu => format == 'dump_archive'
      ? 'Архив выгрузки (ZIP)'
      : 'Выгрузка котельных (JSON)';

  int get totalRecords => entities.values.fold(0, (a, b) => a + b);
}

class ImportEntityResult {
  final String name;
  final int created;
  final int updated;
  final int skipped;

  const ImportEntityResult({
    required this.name,
    required this.created,
    required this.updated,
    required this.skipped,
  });

  factory ImportEntityResult.fromJson(Map<String, dynamic> json) =>
      ImportEntityResult(
        name: json['name'] as String? ?? '',
        created: (json['created'] as num?)?.toInt() ?? 0,
        updated: (json['updated'] as num?)?.toInt() ?? 0,
        skipped: (json['skipped'] as num?)?.toInt() ?? 0,
      );

  /// Русские названия сущностей: оператор не должен видеть «SavedLocation».
  String get nameRu => const {
        'BoilerHouse': 'Котельные',
        'SavedLocation': 'Дома',
        'Account': 'Лицевые счета',
        'MyAccount': 'Лицевые счета',
        'ManagementCompany': 'Управляющие компании',
        'Incident': 'Инциденты',
        'AppUser': 'Пользователи',
        'ActionLog': 'Журнал действий',
        'IncidentPhoto': 'Фото инцидентов',
        'HousePhoto': 'Фото домов',
        'BoilerPhoto': 'Фото котельных',
        'IncidentComment': 'Комментарии',
        'PendingChange': 'Отложенные изменения',
      }[name] ??
      name;
}

class ImportResult {
  final String format;
  final List<ImportEntityResult> entities;
  final int totalCreated;
  final int totalUpdated;
  final int totalSkipped;
  final List<String> warnings;
  final int warningsTotal;

  const ImportResult({
    required this.format,
    required this.entities,
    required this.totalCreated,
    required this.totalUpdated,
    required this.totalSkipped,
    required this.warnings,
    required this.warningsTotal,
  });

  factory ImportResult.fromJson(Map<String, dynamic> json) => ImportResult(
        format: json['format'] as String? ?? '',
        entities: ((json['entities'] as List?) ?? const [])
            .map((e) =>
                ImportEntityResult.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
        totalCreated: (json['total_created'] as num?)?.toInt() ?? 0,
        totalUpdated: (json['total_updated'] as num?)?.toInt() ?? 0,
        totalSkipped: (json['total_skipped'] as num?)?.toInt() ?? 0,
        warnings: ((json['warnings'] as List?) ?? const [])
            .map((e) => e.toString())
            .toList(),
        warningsTotal: (json['warnings_total'] as num?)?.toInt() ?? 0,
      );
}

class DataImportService {
  final Dio _dio;

  DataImportService(this._dio);

  Future<ImportPreview> preview(String filePath) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    final r = await _dio.post('/data-import/preview', data: form,
        options: Options(receiveTimeout: const Duration(minutes: 2)));
    return ImportPreview.fromJson((r.data as Map).cast<String, dynamic>());
  }

  Future<ImportResult> upload(
    String filePath, {
    void Function(int sent, int total)? onProgress,
  }) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    final r = await _dio.post(
      '/data-import/upload',
      data: form,
      onSendProgress: onProgress,
      // 11 000 записей пишутся больше минуты — таймаут по умолчанию мал.
      options: Options(receiveTimeout: const Duration(minutes: 10)),
    );
    return ImportResult.fromJson((r.data as Map).cast<String, dynamic>());
  }
}
