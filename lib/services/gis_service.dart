import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'base_api_service.dart';

final gisServiceProvider = Provider<GisService>((ref) {
  final dio = ref.watch(dioProvider);
  return GisService(dio);
});

/// Описание шаблона ГИС на сервере — тип и версия берутся из самого файла.
class GisTemplateInfo {
  final String kind;
  final String title;
  final bool available;
  final String? type;
  final String? version;
  final String? release;

  const GisTemplateInfo({
    required this.kind,
    required this.title,
    required this.available,
    this.type,
    this.version,
    this.release,
  });

  factory GisTemplateInfo.fromJson(Map<String, dynamic> json) => GisTemplateInfo(
        kind: json['kind'] as String? ?? '',
        title: json['title'] as String? ?? '',
        available: json['available'] as bool? ?? false,
        type: json['type'] as String?,
        version: json['version'] as String?,
        release: json['release'] as String?,
      );
}

/// Результат импорта заполненного шаблона.
class GisImportResult {
  final int created;
  final int updated;
  final int skipped;
  final List<String> errors;
  final int errorsTotal;
  final List<String> warnings;

  const GisImportResult({
    required this.created,
    required this.updated,
    required this.skipped,
    required this.errors,
    required this.errorsTotal,
    required this.warnings,
  });

  factory GisImportResult.fromJson(Map<String, dynamic> json) => GisImportResult(
        created: (json['created'] as num?)?.toInt() ?? 0,
        updated: (json['updated'] as num?)?.toInt() ?? 0,
        skipped: (json['skipped'] as num?)?.toInt() ?? 0,
        errors: (json['errors'] as List?)?.map((e) => e.toString()).toList() ?? const [],
        errorsTotal: (json['errors_total'] as num?)?.toInt() ?? 0,
        warnings: (json['warnings'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      );

  int get total => created + updated;
  bool get hasIssues => skipped > 0 || errorsTotal > 0 || warnings.isNotEmpty;
}

/// Экспорт и импорт официальных шаблонов ГИС ЖКХ.
class GisService {
  final Dio _dio;

  GisService(this._dio);

  Future<List<GisTemplateInfo>> getTemplates() async {
    final response = await _dio.get('/gis/templates');
    return (response.data as List)
        .map((e) => GisTemplateInfo.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Скачивает .xlsx во временный файл и возвращает его.
  ///
  /// Файл приходит как байты: шаблон ГИС собран на сервере поверх
  /// оригинала, и его нельзя пересобирать на клиенте — портал
  /// отвергает файлы с изменённым форматом.
  Future<File> _download(String path, {Map<String, dynamic>? query}) async {
    final response = await _dio.get<List<int>>(
      path,
      queryParameters: query,
      options: Options(responseType: ResponseType.bytes),
    );

    final dir = await getTemporaryDirectory();
    final name = _fileNameFrom(response.headers) ??
        'ГИС ${DateTime.now().toIso8601String().substring(0, 16)}.xlsx';
    final file = File('${dir.path}/$name');
    await file.writeAsBytes(response.data ?? const []);
    return file;
  }

  /// Имя файла из Content-Disposition — сервер присылает понятное
  /// название вроде «Лицевые счета 20261007_1830.xlsx».
  String? _fileNameFrom(Headers headers) {
    final raw = headers.value('content-disposition');
    if (raw == null) return null;
    // Сначала RFC 5987 (filename*=UTF-8''...), затем обычный filename.
    final ext = RegExp(r"filename\*=UTF-8''([^;]+)").firstMatch(raw);
    if (ext != null) {
      try {
        return Uri.decodeComponent(ext.group(1)!.trim());
      } catch (_) {
        // Некорректное процентное кодирование — пробуем обычное поле.
      }
    }
    final plain = RegExp(r'filename="?([^";]+)"?').firstMatch(raw);
    return plain?.group(1)?.trim();
  }

  Future<File> exportHouses({List<int>? houseIds}) =>
      _download('/gis/export/houses', query: _ids('house_ids', houseIds));

  Future<File> exportAccounts({List<int>? accountIds}) =>
      _download('/gis/export/accounts', query: _ids('account_ids', accountIds));

  Future<File> exportPaymentDocuments({DateTime? period, List<int>? accountIds}) =>
      _download('/gis/export/payment-documents', query: {
        if (period != null) 'period': _date(period),
        ..._ids('account_ids', accountIds),
      });

  Future<File> exportAcknowledgments({DateTime? from, DateTime? to}) =>
      _download('/gis/export/acknowledgments', query: {
        if (from != null) 'date_from': _date(from),
        if (to != null) 'date_to': _date(to),
      });

  Future<File> downloadBlank(String kind) => _download('/gis/templates/$kind/blank');

  Future<GisImportResult> import(String kind, String filePath) async {
    final endpoint = {
      'mkd': '/gis/import/houses',
      'ls': '/gis/import/accounts',
      'pd': '/gis/import/payment-documents',
      'kvit': '/gis/import/acknowledgments',
    }[kind];
    if (endpoint == null) {
      throw ArgumentError('Неизвестный тип шаблона: $kind');
    }

    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    final response = await _dio.post(
      endpoint,
      data: form,
      // Разбор большого файла на сервере может занять минуту.
      options: Options(receiveTimeout: const Duration(minutes: 3)),
    );
    return GisImportResult.fromJson(response.data as Map<String, dynamic>);
  }

  Map<String, dynamic> _ids(String key, List<int>? ids) =>
      (ids == null || ids.isEmpty) ? const {} : {key: ids};

  String _date(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
