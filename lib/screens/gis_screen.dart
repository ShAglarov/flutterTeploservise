import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/permission_key.dart';
import '../services/file_export_helper.dart';
import '../services/gis_service.dart';
import '../services/permission_service.dart';
import '../utils/app_theme.dart';

final gisTemplatesProvider = FutureProvider<List<GisTemplateInfo>>((ref) async {
  return ref.watch(gisServiceProvider).getTemplates();
});

/// Интеграция с ГИС ЖКХ: выгрузка данных в официальные шаблоны и загрузка
/// заполненных файлов обратно.
class GisScreen extends ConsumerStatefulWidget {
  const GisScreen({super.key});

  @override
  ConsumerState<GisScreen> createState() => _GisScreenState();
}

class _GisScreenState extends ConsumerState<GisScreen> {
  String? _busyKind;
  DateTime? _pdPeriod;

  static const _mime =
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';

  bool get _busy => _busyKind != null;

  // ─────────────────────────── экспорт ───────────────────────────

  Future<void> _export(String kind, String title) async {
    setState(() => _busyKind = 'export_$kind');
    try {
      final service = ref.read(gisServiceProvider);
      final GisExportResult result;
      switch (kind) {
        case 'mkd':
          result = await service.exportHouses();
          break;
        case 'ls':
          result = await service.exportAccounts();
          break;
        case 'pd':
          result = await service.exportPaymentDocuments(period: _pdPeriod);
          break;
        case 'kvit':
          result = await service.exportAcknowledgments();
          break;
        default:
          return;
      }

      await FileExportHelper.exportFile(
        sourceFile: result.file,
        fileName: result.file.uri.pathSegments.last,
        mimeType: _mime,
        subject: title,
      );
      if (mounted) await _showExportResult(title, result);
    } catch (e) {
      _toast(_errorText(e), AppTheme.errorRed);
    } finally {
      if (mounted) setState(() => _busyKind = null);
    }
  }

  /// Показывает, что попало в файл и чего не хватило.
  ///
  /// Раньше шаблон выгружался молча, и пустой файл выглядел как
  /// неработающая выгрузка. На деле запись без ключевого идентификатора
  /// (ФИАС у дома, идентификатор ЖКУ у лицевого счёта) портал не примет,
  /// и её нужно сначала дозаполнить.
  Future<void> _showExportResult(String title, GisExportResult r) async {
    if (!r.hasStats) {
      _toast('Файл готов. Загрузите его в личном кабинете ГИС ЖКХ.',
          AppTheme.successGreen);
      return;
    }

    if (r.skipped == 0) {
      _toast('Файл готов: ${r.exported} записей. '
          'Загрузите его в личном кабинете ГИС ЖКХ.', AppTheme.successGreen);
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Выгружено записей: ${r.exported}',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text('Пропущено: ${r.skipped}',
                  style: const TextStyle(color: AppTheme.warningOrange)),
              const SizedBox(height: 10),
              const Text(
                'Портал сопоставляет записи по идентификаторам. Без них '
                'строка не принимается, поэтому такие записи в файл не '
                'попали — заполните их в карточке и выгрузите снова.',
                style: TextStyle(fontSize: 12),
              ),
              if (r.warnings.isNotEmpty) ...[
                const SizedBox(height: 10),
                ...r.warnings.map((w) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text('• $w', style: const TextStyle(fontSize: 11.5)),
                    )),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Понятно')),
        ],
      ),
    );
  }

  Future<void> _downloadBlank(String kind, String title) async {
    setState(() => _busyKind = 'blank_$kind');
    try {
      final result = await ref.read(gisServiceProvider).downloadBlank(kind);
      await FileExportHelper.exportFile(
        sourceFile: result.file,
        fileName: result.file.uri.pathSegments.last,
        mimeType: _mime,
        subject: title,
      );
      _toast('Пустой шаблон сохранён', AppTheme.successGreen);
    } catch (e) {
      _toast(_errorText(e), AppTheme.errorRed);
    } finally {
      if (mounted) setState(() => _busyKind = null);
    }
  }

  // ─────────────────────────── импорт ───────────────────────────

  Future<void> _import(String kind, String title) async {
    final picked = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['xlsx', 'xlsm'],
    );
    final path = picked?.files.single.path;
    if (path == null) return;

    setState(() => _busyKind = 'import_$kind');
    try {
      final result = await ref.read(gisServiceProvider).import(kind, path);
      if (mounted) await _showResult(title, result);
    } catch (e) {
      _toast(_errorText(e), AppTheme.errorRed);
    } finally {
      if (mounted) setState(() => _busyKind = null);
    }
  }

  Future<void> _showResult(String title, GisImportResult r) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _stat('Создано', r.created, AppTheme.successGreen),
              _stat('Обновлено', r.updated, AppTheme.primaryBlue),
              if (r.skipped > 0)
                _stat('Пропущено', r.skipped, AppTheme.warningOrange),
              if (r.errorsTotal > 0)
                _stat('Ошибок', r.errorsTotal, AppTheme.errorRed),
              if (r.warnings.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text('Замечания:',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                ...r.warnings.take(20).map(
                      (w) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text('• $w', style: const TextStyle(fontSize: 12)),
                      ),
                    ),
              ],
              if (r.errors.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text('Ошибки:',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: AppTheme.errorRed)),
                const SizedBox(height: 4),
                ...r.errors.take(20).map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text('• $e', style: const TextStyle(fontSize: 12)),
                      ),
                    ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Закрыть')),
        ],
      ),
    );
  }

  Widget _stat(String label, int value, Color color) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            Container(width: 8, height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text('$label: ', style: const TextStyle(fontSize: 13)),
            Text('$value',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
      );

  Future<void> _pickPeriod() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _pdPeriod ?? DateTime(now.year, now.month),
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 2, 12),
      helpText: 'Расчётный период платёжных документов',
    );
    if (picked != null) {
      setState(() => _pdPeriod = DateTime(picked.year, picked.month));
    }
  }

  void _toast(String text, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: color,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  String _errorText(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      final detail = data is Map ? data['detail']?.toString() : null;
      if (detail != null && detail.startsWith('permission_denied')) {
        return 'Нет прав на обмен данными с ГИС';
      }
      if (e.response?.statusCode == 503) {
        return detail ?? 'Шаблоны ГИС не установлены на сервере';
      }
      return detail ?? e.message ?? 'Ошибка сети';
    }
    return e.toString();
  }

  // ─────────────────────────── интерфейс ───────────────────────────

  @override
  Widget build(BuildContext context) {
    final templates = ref.watch(gisTemplatesProvider);
    final perms = ref.watch(permissionStateProvider);
    final canExport = perms.hasPermission(PermissionKey.dataExport);
    final canImport = perms.hasPermission(PermissionKey.dataImport);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ГИС ЖКХ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _busy ? null : () => ref.invalidate(gisTemplatesProvider),
          ),
        ],
      ),
      body: templates.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off, size: 44, color: AppTheme.errorRed),
                const SizedBox(height: 12),
                Text(_errorText(e), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => ref.invalidate(gisTemplatesProvider),
                  child: const Text('Повторить'),
                ),
              ],
            ),
          ),
        ),
        data: (list) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _intro(),
            const SizedBox(height: 16),
            for (final t in list)
              _TemplateCard(
                info: t,
                busyKind: _busyKind,
                canExport: canExport,
                canImport: canImport,
                period: t.kind == 'pd' ? _pdPeriod : null,
                onPickPeriod: t.kind == 'pd' ? _pickPeriod : null,
                onClearPeriod: t.kind == 'pd' && _pdPeriod != null
                    ? () => setState(() => _pdPeriod = null)
                    : null,
                onExport: () => _export(t.kind, t.title),
                onImport: () => _import(t.kind, t.title),
                onBlank: () => _downloadBlank(t.kind, t.title),
              ),
          ],
        ),
      ),
    );
  }

  Widget _intro() {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, size: 18, color: AppTheme.primaryBlue),
              const SizedBox(width: 8),
              Text('Как это работает',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: cs.onSurface)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Выгрузка собирает данные в официальный шаблон ГИС — со всеми '
            'списками и проверками портала, без изменения формата файла. '
            'Полученный файл загружается в личном кабинете ГИС ЖКХ.\n\n'
            'Загрузка читает заполненный шаблон и обновляет записи по '
            'идентификаторам ГИС (ЖКУ, ЕЛС, ФИАС). Пустые ячейки ничего '
            'не затирают.',
            style: TextStyle(fontSize: 12, color: cs.onSurface.withAlpha(165)),
          ),
        ],
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final GisTemplateInfo info;
  final String? busyKind;
  final bool canExport;
  final bool canImport;
  final DateTime? period;
  final VoidCallback? onPickPeriod;
  final VoidCallback? onClearPeriod;
  final VoidCallback onExport;
  final VoidCallback onImport;
  final VoidCallback onBlank;

  const _TemplateCard({
    required this.info,
    required this.busyKind,
    required this.canExport,
    required this.canImport,
    required this.period,
    required this.onPickPeriod,
    required this.onClearPeriod,
    required this.onExport,
    required this.onImport,
    required this.onBlank,
  });

  static const _months = [
    'январь', 'февраль', 'март', 'апрель', 'май', 'июнь',
    'июль', 'август', 'сентябрь', 'октябрь', 'ноябрь', 'декабрь',
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final busy = busyKind != null;
    final exporting = busyKind == 'export_${info.kind}';
    final importing = busyKind == 'import_${info.kind}';
    final blanking = busyKind == 'blank_${info.kind}';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(info.title,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                ),
                if (info.version != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: cs.onSurface.withAlpha(18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('v${info.version}',
                        style: TextStyle(
                            fontSize: 11, color: cs.onSurface.withAlpha(160))),
                  ),
              ],
            ),
            if (!info.available) ...[
              const SizedBox(height: 8),
              Text('Шаблон не найден на сервере',
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.warningOrange)),
            ],
            if (info.kind == 'pd') ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.event, size: 16, color: cs.onSurface.withAlpha(140)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      period == null
                          ? 'Период: все'
                          : 'Период: ${_months[period!.month - 1]} ${period!.year}',
                      style: TextStyle(
                          fontSize: 12, color: cs.onSurface.withAlpha(175)),
                    ),
                  ),
                  if (onClearPeriod != null)
                    TextButton(
                        onPressed: busy ? null : onClearPeriod,
                        child: const Text('Сбросить')),
                  TextButton(
                      onPressed: busy ? null : onPickPeriod,
                      child: const Text('Выбрать')),
                ],
              ),
            ],
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed:
                      (busy || !canExport || !info.available) ? null : onExport,
                  icon: exporting
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.download, size: 18),
                  label: const Text('Выгрузить'),
                ),
                OutlinedButton.icon(
                  onPressed:
                      (busy || !canImport || !info.available) ? null : onImport,
                  icon: importing
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.upload_file, size: 18),
                  label: const Text('Загрузить'),
                ),
                TextButton.icon(
                  onPressed:
                      (busy || !canExport || !info.available) ? null : onBlank,
                  icon: blanking
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.insert_drive_file_outlined, size: 18),
                  label: const Text('Пустой'),
                ),
              ],
            ),
            if (!canExport || !canImport) ...[
              const SizedBox(height: 6),
              Text(
                !canExport && !canImport
                    ? 'Нет прав на обмен данными'
                    : (!canExport ? 'Нет права на выгрузку' : 'Нет права на загрузку'),
                style:
                    TextStyle(fontSize: 11, color: cs.onSurface.withAlpha(140)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
