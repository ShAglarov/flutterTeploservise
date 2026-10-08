import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'base_api_service.dart';

final backupServiceProvider = Provider<BackupService>((ref) {
  return BackupService(ref.watch(dioProvider));
});

/// Резервная копия организации.
class BackupInfo {
  final String backupId;
  final DateTime? createdAt;
  final String kind;
  final String? note;
  final String? author;
  final int totalRows;
  final int sizeBytes;
  final Map<String, int> counts;
  final bool broken;

  const BackupInfo({
    required this.backupId,
    required this.createdAt,
    required this.kind,
    required this.totalRows,
    required this.sizeBytes,
    required this.counts,
    this.note,
    this.author,
    this.broken = false,
  });

  factory BackupInfo.fromJson(Map<String, dynamic> json) {
    final raw = json['created_at'] as String?;
    return BackupInfo(
      backupId: json['backup_id'] as String? ?? '',
      // Сервер отдаёт UTC — переводим в местное время, иначе дата копии
      // показывалась бы со сдвигом.
      createdAt: raw == null ? null : DateTime.tryParse(raw)?.toLocal(),
      kind: json['kind'] as String? ?? 'manual',
      note: json['note'] as String?,
      author: json['author'] as String?,
      totalRows: (json['total_rows'] as num?)?.toInt() ?? 0,
      sizeBytes: (json['size_bytes'] as num?)?.toInt() ?? 0,
      counts: ((json['counts'] as Map?) ?? const {}).map(
        (k, v) => MapEntry(k.toString(), (v as num?)?.toInt() ?? 0),
      ),
      broken: json['broken'] as bool? ?? false,
    );
  }

  /// Копия, снятая автоматически перед откатом.
  bool get isPreRestore => kind == 'pre_restore';

  String get sizeLabel {
    if (sizeBytes >= 1024 * 1024) {
      return '${(sizeBytes / 1024 / 1024).toStringAsFixed(1)} МБ';
    }
    if (sizeBytes >= 1024) return '${(sizeBytes / 1024).round()} КБ';
    return '$sizeBytes Б';
  }

  String get dateLabel {
    final d = createdAt;
    if (d == null) return 'дата неизвестна';
    const m = ['', 'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
               'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'];
    return '${d.day} ${m[d.month]} ${d.year}, '
        '${d.hour.toString().padLeft(2, '0')}:'
        '${d.minute.toString().padLeft(2, '0')}';
  }
}

class BackupList {
  final int organizationId;
  final String organization;
  final int limitPerKind;
  final List<BackupInfo> backups;

  const BackupList({
    required this.organizationId,
    required this.organization,
    required this.limitPerKind,
    required this.backups,
  });

  factory BackupList.fromJson(Map<String, dynamic> json) => BackupList(
        organizationId: (json['organization_id'] as num?)?.toInt() ?? 0,
        organization: json['organization'] as String? ?? '',
        limitPerKind: (json['limit_per_kind'] as num?)?.toInt() ?? 5,
        backups: ((json['backups'] as List?) ?? const [])
            .map((e) => BackupInfo.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
      );

  List<BackupInfo> get manual => backups.where((b) => !b.isPreRestore).toList();
  List<BackupInfo> get preRestore =>
      backups.where((b) => b.isPreRestore).toList();
}

class RestoreResult {
  final String backupId;
  final int totalDeleted;
  final int totalInserted;
  final String? safetyBackupId;

  const RestoreResult({
    required this.backupId,
    required this.totalDeleted,
    required this.totalInserted,
    this.safetyBackupId,
  });

  factory RestoreResult.fromJson(Map<String, dynamic> json) => RestoreResult(
        backupId: json['backup_id'] as String? ?? '',
        totalDeleted: (json['total_deleted'] as num?)?.toInt() ?? 0,
        totalInserted: (json['total_inserted'] as num?)?.toInt() ?? 0,
        safetyBackupId: json['safety_backup_id'] as String?,
      );
}

/// Копии организаций. Все вызовы требуют прав суперадмина на сервере.
class BackupService {
  final Dio _dio;

  BackupService(this._dio);

  Future<BackupList> list(int orgId) async {
    final r = await _dio.get('/backups/$orgId');
    return BackupList.fromJson((r.data as Map).cast<String, dynamic>());
  }

  Future<BackupInfo> create(int orgId, {String? note}) async {
    final r = await _dio.post(
      '/backups/$orgId',
      data: {'note': ?note},
      // Снимок большой организации занимает несколько секунд.
      options: Options(receiveTimeout: const Duration(minutes: 5)),
    );
    return BackupInfo.fromJson((r.data as Map).cast<String, dynamic>());
  }

  Future<RestoreResult> restore(int orgId, String backupId) async {
    final r = await _dio.post(
      '/backups/$orgId/restore',
      data: {'backup_id': backupId, 'confirm': true},
      options: Options(receiveTimeout: const Duration(minutes: 10)),
    );
    return RestoreResult.fromJson((r.data as Map).cast<String, dynamic>());
  }

  Future<void> delete(int orgId, String backupId) async {
    await _dio.delete('/backups/$orgId/$backupId');
  }
}
