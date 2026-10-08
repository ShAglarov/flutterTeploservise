import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/data_import_service.dart';
import '../utils/app_theme.dart';

/// Импорт данных из выгрузок прежней системы.
///
/// Принимает `boilerhouses.json` и `TeploserviceDump_*.zip`. Тип файла
/// определяет сервер по содержимому, поэтому переименованный файл тоже
/// подойдёт — выбирать формат вручную не нужно.
class DataImportScreen extends ConsumerStatefulWidget {
  const DataImportScreen({super.key});

  @override
  ConsumerState<DataImportScreen> createState() => _DataImportScreenState();
}

class _DataImportScreenState extends ConsumerState<DataImportScreen> {
  String? _path;
  String? _fileName;
  ImportPreview? _preview;
  ImportResult? _result;
  bool _busy = false;
  double _progress = 0;
  String? _error;

  Future<void> _pick() async {
    final picked = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['json', 'zip'],
    );
    final file = picked?.files.single;
    if (file?.path == null) return;

    setState(() {
      _path = file!.path;
      _fileName = file.name;
      _preview = null;
      _result = null;
      _error = null;
    });
    await _loadPreview();
  }

  Future<void> _loadPreview() async {
    final path = _path;
    if (path == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final preview = await ref.read(dataImportServiceProvider).preview(path);
      setState(() => _preview = preview);
    } catch (e) {
      setState(() => _error = _errorText(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _import() async {
    final path = _path;
    if (path == null) return;

    // Импорт меняет дома, котельные и лицевые счета всей организации —
    // спрашиваем подтверждение, а не делаем по одному нажатию.
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Импортировать данные?'),
        content: Text(
          'Будут добавлены новые записи и обновлены существующие '
          '(${_preview?.totalRecords ?? 0} записей в файле).\n\n'
          'Данные попадут в вашу организацию. Отменить импорт одним '
          'действием нельзя.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Отмена')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Импортировать')),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() {
      _busy = true;
      _progress = 0;
      _error = null;
      _result = null;
    });
    try {
      final result = await ref.read(dataImportServiceProvider).upload(
            path,
            onProgress: (sent, total) {
              if (total > 0 && mounted) {
                setState(() => _progress = sent / total);
              }
            },
          );
      setState(() => _result = result);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Импорт завершён: создано ${result.totalCreated}, '
              'обновлено ${result.totalUpdated}'),
          backgroundColor: AppTheme.successGreen,
        ));
      }
    } catch (e) {
      setState(() => _error = _errorText(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _errorText(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      String? detail;
      if (data is Map) detail = data['detail']?.toString();
      if (detail != null && detail.startsWith('permission_denied')) {
        return 'Нет права на импорт данных';
      }
      if (e.type == DioExceptionType.receiveTimeout) {
        return 'Сервер слишком долго отвечает. Импорт мог продолжиться — '
            'проверьте данные перед повторной попыткой.';
      }
      return detail ?? e.message ?? 'Ошибка сети';
    }
    return e.toString();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Импорт данных')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
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
                    const Icon(Icons.info_outline,
                        size: 18, color: AppTheme.primaryBlue),
                    const SizedBox(width: 8),
                    Text('Какие файлы подходят',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, color: cs.onSurface)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'boilerhouses.json — котельные с домами и лицевыми счетами.\n'
                  'TeploserviceDump_*.zip — полная выгрузка базы.\n\n'
                  'Существующие записи обновляются, новые добавляются. '
                  'Сопоставление идёт по ФИАС, UUID и номеру лицевого счёта, '
                  'поэтому повторный импорт того же файла не создаёт дублей.',
                  style: TextStyle(
                      fontSize: 12, color: cs.onSurface.withAlpha(165)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          OutlinedButton.icon(
            onPressed: _busy ? null : _pick,
            icon: const Icon(Icons.folder_open),
            label: Text(_fileName ?? 'Выбрать файл'),
          ),

          if (_busy && _progress > 0 && _progress < 1) ...[
            const SizedBox(height: 14),
            LinearProgressIndicator(value: _progress),
            const SizedBox(height: 4),
            Text('Отправка: ${(_progress * 100).toStringAsFixed(0)}%',
                style: TextStyle(fontSize: 11, color: cs.onSurface.withAlpha(150))),
          ] else if (_busy) ...[
            const SizedBox(height: 14),
            const LinearProgressIndicator(),
            const SizedBox(height: 4),
            Text('Обработка на сервере. Для большой выгрузки это '
                'занимает до нескольких минут.',
                style: TextStyle(fontSize: 11, color: cs.onSurface.withAlpha(150))),
          ],

          if (_error != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.errorRed.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_outline,
                      size: 18, color: AppTheme.errorRed),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_error!, style: const TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
          ],

          if (_preview != null && _result == null) ...[
            const SizedBox(height: 18),
            _title('В файле'),
            Text(_preview!.formatRu,
                style: TextStyle(fontSize: 12, color: cs.onSurface.withAlpha(165))),
            const SizedBox(height: 8),
            ..._preview!.entities.entries
                .where((e) => e.value > 0)
                .map((e) => _row(
                      ImportEntityResult(
                              name: e.key, created: 0, updated: 0, skipped: 0)
                          .nameRu,
                      '${e.value}',
                    )),
            const SizedBox(height: 16),
            SizedBox(
              height: 46,
              child: FilledButton.icon(
                onPressed: _busy ? null : _import,
                icon: const Icon(Icons.cloud_upload_outlined),
                label: const Text('Импортировать'),
              ),
            ),
          ],

          if (_result != null) ...[
            const SizedBox(height: 18),
            _title('Результат'),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2.2),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(1),
              },
              children: [
                TableRow(children: [
                  _cell('Сущность', bold: true),
                  _cell('Создано', bold: true, center: true),
                  _cell('Обновлено', bold: true, center: true),
                  _cell('Пропущено', bold: true, center: true),
                ]),
                ..._result!.entities.map((e) => TableRow(children: [
                      _cell(e.nameRu),
                      _cell('${e.created}', center: true),
                      _cell('${e.updated}', center: true),
                      _cell('${e.skipped}', center: true),
                    ])),
              ],
            ),
            const SizedBox(height: 12),
            if (_result!.warnings.isNotEmpty) ...[
              _title('Замечания'),
              ..._result!.warnings.take(12).map(
                    (w) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text('• $w',
                          style: TextStyle(
                              fontSize: 11.5,
                              color: cs.onSurface.withAlpha(175))),
                    ),
                  ),
              if (_result!.warningsTotal > 12)
                Text('…и ещё ${_result!.warningsTotal - 12}',
                    style: TextStyle(
                        fontSize: 11, color: cs.onSurface.withAlpha(140))),
            ],
            const SizedBox(height: 14),
            Text(
              'Данные на карте появятся после синхронизации: '
              'Настройки → Синхронизация.',
              style: TextStyle(fontSize: 11.5, color: cs.onSurface.withAlpha(150)),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _title(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
            color: Theme.of(context).colorScheme.onSurface.withAlpha(140),
          ),
        ),
      );

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Row(
          children: [
            Expanded(child: Text(label, style: const TextStyle(fontSize: 12.5))),
            Text(value,
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
          ],
        ),
      );

  Widget _cell(String text, {bool bold = false, bool center = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 2),
        child: Text(
          text,
          textAlign: center ? TextAlign.center : TextAlign.left,
          style: TextStyle(
            fontSize: 12,
            fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      );
}
