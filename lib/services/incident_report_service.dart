import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'base_api_service.dart';

final incidentReportServiceProvider = Provider<IncidentReportService>((ref) {
  return IncidentReportService(ref.watch(dioProvider));
});

/// Смена диспетчера со счётчиками — для выбора в списке.
class ShiftInfo {
  final String shiftDate;
  final String label;
  final bool isCurrent;
  final int total;
  final int boilerFailures;
  final int housesAffected;
  final int stillActive;

  const ShiftInfo({
    required this.shiftDate,
    required this.label,
    required this.isCurrent,
    required this.total,
    required this.boilerFailures,
    required this.housesAffected,
    required this.stillActive,
  });

  factory ShiftInfo.fromJson(Map<String, dynamic> json) => ShiftInfo(
        shiftDate: json['shift_date'] as String? ?? '',
        label: json['label'] as String? ?? '',
        isCurrent: json['is_current'] as bool? ?? false,
        total: (json['total'] as num?)?.toInt() ?? 0,
        boilerFailures: (json['boiler_failures'] as num?)?.toInt() ?? 0,
        housesAffected: (json['houses_affected'] as num?)?.toInt() ?? 0,
        stillActive: (json['still_active'] as num?)?.toInt() ?? 0,
      );
}

/// Сводка отчёта для предпросмотра до выгрузки PDF.
class ReportSummary {
  final String title;
  final String periodLabel;
  final int total;
  final int newInPeriod;
  final int inherited;
  final int finished;
  final int stillActive;
  final int boilerFailures;
  final int plannedWorks;
  final int housesAffected;
  final int residentsAffected;
  final List<Map<String, dynamic>> incidents;
  final List<Map<String, dynamic>> byBoilerHouse;
  final List<Map<String, dynamic>> byHouse;

  const ReportSummary({
    required this.title,
    required this.periodLabel,
    required this.total,
    required this.newInPeriod,
    required this.inherited,
    required this.finished,
    required this.stillActive,
    required this.boilerFailures,
    required this.plannedWorks,
    required this.housesAffected,
    required this.residentsAffected,
    required this.incidents,
    required this.byBoilerHouse,
    required this.byHouse,
  });

  factory ReportSummary.fromJson(Map<String, dynamic> json) {
    final s = (json['summary'] as Map?)?.cast<String, dynamic>() ?? const {};
    List<Map<String, dynamic>> list(String key) =>
        ((json[key] as List?) ?? const [])
            .map((e) => (e as Map).cast<String, dynamic>())
            .toList();
    return ReportSummary(
      title: json['title'] as String? ?? '',
      periodLabel: json['period_label'] as String? ?? '',
      total: (s['total'] as num?)?.toInt() ?? 0,
      newInPeriod: (s['new_in_period'] as num?)?.toInt() ?? 0,
      inherited: (s['inherited'] as num?)?.toInt() ?? 0,
      finished: (s['finished'] as num?)?.toInt() ?? 0,
      stillActive: (s['still_active'] as num?)?.toInt() ?? 0,
      boilerFailures: (s['boiler_failures'] as num?)?.toInt() ?? 0,
      plannedWorks: (s['planned_works'] as num?)?.toInt() ?? 0,
      housesAffected: (s['houses_affected'] as num?)?.toInt() ?? 0,
      residentsAffected: (s['residents_affected'] as num?)?.toInt() ?? 0,
      incidents: list('incidents'),
      byBoilerHouse: list('by_boiler_house'),
      byHouse: list('by_house'),
    );
  }
}

class IncidentReportService {
  final Dio _dio;

  IncidentReportService(this._dio);

  Future<List<ShiftInfo>> getShifts({int days = 14}) async {
    final r = await _dio.get('/incident-reports/shifts',
        queryParameters: {'days': days});
    return (r.data as List)
        .map((e) => ShiftInfo.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  Future<ReportSummary> shiftSummary({String? shiftDate}) async {
    final r = await _dio.get('/incident-reports/shift', queryParameters: {
      'format': 'json',
      'shift_date': ?shiftDate,
    });
    return ReportSummary.fromJson((r.data as Map).cast<String, dynamic>());
  }

  Future<ReportSummary> periodSummary({
    required DateTime from,
    required DateTime to,
    int? boilerHouseId,
    int? houseId,
    String? status,
  }) async {
    final r = await _dio.get('/incident-reports/period', queryParameters: {
      'format': 'json',
      'date_from': _d(from),
      'date_to': _d(to),
      'boiler_house_id': ?boilerHouseId,
      'house_id': ?houseId,
      'status': ?status,
    });
    return ReportSummary.fromJson((r.data as Map).cast<String, dynamic>());
  }

  Future<File> downloadShiftPdf({String? shiftDate}) => _pdf(
        '/incident-reports/shift',
        {'format': 'pdf', 'shift_date': ?shiftDate},
        'Отчёт о дежурстве.pdf',
      );

  Future<File> downloadPeriodPdf({
    required DateTime from,
    required DateTime to,
    int? boilerHouseId,
    int? houseId,
    String? status,
  }) =>
      _pdf(
        '/incident-reports/period',
        {
          'format': 'pdf',
          'date_from': _d(from),
          'date_to': _d(to),
          'boiler_house_id': ?boilerHouseId,
          'house_id': ?houseId,
          'status': ?status,
        },
        'Отчёт по инцидентам.pdf',
      );

  Future<File> _pdf(
    String path,
    Map<String, dynamic> query,
    String fallbackName,
  ) async {
    final response = await _dio.get<List<int>>(
      path,
      queryParameters: query,
      options: Options(
        responseType: ResponseType.bytes,
        // Отчёт за длинный период считается дольше обычного запроса.
        receiveTimeout: const Duration(minutes: 2),
      ),
    );
    final dir = await getTemporaryDirectory();
    final name = _nameFrom(response.headers) ?? fallbackName;
    final file = File('${dir.path}/$name');
    await file.writeAsBytes(response.data ?? const []);
    return file;
  }

  /// Имя файла из заголовка: сервер присылает его по-русски через RFC 5987.
  String? _nameFrom(Headers headers) {
    final raw = headers.value('content-disposition');
    if (raw == null) return null;
    final ext = RegExp(r"filename\*=UTF-8''([^;]+)").firstMatch(raw);
    if (ext != null) {
      try {
        return Uri.decodeComponent(ext.group(1)!.trim());
      } catch (_) {
        // Битое процентное кодирование — используем обычное поле.
      }
    }
    return RegExp(r'filename="?([^";]+)"?').firstMatch(raw)?.group(1)?.trim();
  }

  String _d(DateTime v) =>
      '${v.year.toString().padLeft(4, '0')}-'
      '${v.month.toString().padLeft(2, '0')}-'
      '${v.day.toString().padLeft(2, '0')}';
}
