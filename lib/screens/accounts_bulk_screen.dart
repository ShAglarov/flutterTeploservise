import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/base_api_service.dart';
import '../utils/app_theme.dart';
import '../utils/gis_dictionaries.dart';

/// Откуда брать номера квартир.
enum _Source { range, list, file }

/// Массовое создание лицевых счетов по номерам квартир.
///
/// Нужно, чтобы не придумывать номер для каждой квартиры вручную: в доме
/// их десятки. Поля заполняются по правилам шаблонов ГИС ЖКХ, поэтому
/// выгрузка сразу проходит проверку портала.
class AccountsBulkScreen extends ConsumerStatefulWidget {
  final int locationId;
  final String? locationName;

  const AccountsBulkScreen({
    super.key,
    required this.locationId,
    this.locationName,
  });

  @override
  ConsumerState<AccountsBulkScreen> createState() => _AccountsBulkScreenState();
}

class _AccountsBulkScreenState extends ConsumerState<AccountsBulkScreen> {
  final _from = TextEditingController(text: '1');
  final _to = TextEditingController(text: '20');
  final _list = TextEditingController();
  final _numberTemplate = TextEditingController(text: '{house}-{apt}');
  // Заполнен по умолчанию: без идентификатора ЖКУ счёт не попадёт
  // в выгрузку ГИС — портал сопоставляет записи именно по нему.
  final _jkuTemplate = TextEditingController(text: 'ЖКУ-{house}-{apt}');
  final _area = TextEditingController();

  /// Откуда брать номера квартир.
  _Source _source = _Source.range;
  String _premisesType = gisPremisesTypes.first;
  String _accountType = gisAccountTypes.first;
  bool _busy = false;
  Map<String, dynamic>? _result;
  String? _error;

  @override
  void dispose() {
    for (final c in [_from, _to, _list, _numberTemplate, _jkuTemplate, _area]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Разобранные строки файла: номер, площадь, ФИО…
  List<Map<String, dynamic>> _fileRows = const [];
  String? _fileName;
  Map<String, String> _fileColumns = const {};

  List<String> get _apartments {
    if (_source != _Source.list) return const [];
    return _list.text
        .split(RegExp(r'[,;\n]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  int get _plannedCount {
    if (_source == _Source.file) return _fileRows.length;
    if (_source == _Source.list) return _apartments.length;
    final a = int.tryParse(_from.text.trim());
    final b = int.tryParse(_to.text.trim());
    if (a == null || b == null || b < a) return 0;
    return b - a + 1;
  }

  Future<void> _generate() async {
    if (_plannedCount == 0) {
      setState(() => _error = 'Укажите диапазон или список номеров квартир');
      return;
    }
    if (_numberTemplate.text.trim().isEmpty) {
      setState(() => _error = 'Шаблон номера не может быть пустым');
      return;
    }

    // Создание десятков записей — подтверждаем, чтобы случайное нажатие
    // не наплодило счетов, которые придётся удалять по одному.
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Создать лицевые счета?'),
        content: Text(
          'Будет создано до $_plannedCount счетов по дому '
          '«${widget.locationName ?? ''}».\n\n'
          'Помещения, для которых счёт уже есть, пропускаются.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Отмена')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Создать')),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() {
      _busy = true;
      _error = null;
      _result = null;
    });
    try {
      final dio = ref.read(dioProvider);
      // Для файла отдельный endpoint: он переносит площади и ФИО из
      // таблицы, а не только создаёт номера.
      final path = _source == _Source.file
          ? '/accounts/import-apartments'
          : '/accounts/bulk-generate';
      final response = await dio.post(
        path,
        data: {
          'location_id': widget.locationId,
          if (_source == _Source.range)
            'range_from': int.tryParse(_from.text.trim()),
          if (_source == _Source.range)
            'range_to': int.tryParse(_to.text.trim()),
          if (_source == _Source.list) 'apartments': _apartments,
          if (_source == _Source.file) 'apartments': _fileRows,
          'number_template': _numberTemplate.text.trim(),
          if (_jkuTemplate.text.trim().isNotEmpty)
            'jku_template': _jkuTemplate.text.trim(),
          'premises_type': _premisesType,
          'account_type': _accountType,
          if (_source != _Source.file && _area.text.trim().isNotEmpty)
            'area': double.tryParse(_area.text.trim().replaceAll(',', '.')),
        },
        options: Options(receiveTimeout: const Duration(minutes: 5)),
      );
      setState(() => _result = (response.data as Map).cast<String, dynamic>());
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
        return 'Нет права на создание лицевых счетов';
      }
      return detail ?? e.message ?? 'Ошибка сети';
    }
    return e.toString();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Создать счета по квартирам')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (widget.locationName != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  Icon(Icons.home_outlined,
                      size: 16, color: cs.onSurface.withAlpha(150)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(widget.locationName!,
                        style: TextStyle(
                            fontSize: 12.5, color: cs.onSurface.withAlpha(165))),
                  ),
                ],
              ),
            ),

          _header('Какие помещения'),
          SegmentedButton<_Source>(
            segments: const [
              ButtonSegment(value: _Source.range, label: Text('Диапазон')),
              ButtonSegment(value: _Source.list, label: Text('Списком')),
              ButtonSegment(value: _Source.file, label: Text('Из файла')),
            ],
            selected: {_source},
            onSelectionChanged: _busy
                ? null
                : (s) => setState(() => _source = s.first),
          ),
          const SizedBox(height: 12),
          if (_source == _Source.range)
            Row(
              children: [
                Expanded(child: _field(_from, 'С квартиры', number: true)),
                const SizedBox(width: 10),
                Expanded(child: _field(_to, 'По квартиру', number: true)),
              ],
            )
          else if (_source == _Source.list)
            _field(_list, 'Номера через запятую',
                hint: '1, 2, 3а, 4, 11/1', maxLines: 3)
          else
            _filePicker(cs),

          if (_plannedCount > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text('Будет создано до $_plannedCount счетов',
                  style: TextStyle(
                      fontSize: 11.5, color: cs.onSurface.withAlpha(150))),
            ),

          const SizedBox(height: 6),
          _header('Как нумеровать'),
          _field(_numberTemplate, 'Шаблон номера ЛС', hint: '{house}-{apt}'),
          _field(_jkuTemplate, 'Шаблон идентификатора ЖКУ',
              hint: 'ЖКУ-{house}-{apt}'),
          if (_source == _Source.file)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                'Если в файле есть своя колонка с номерами лицевых счетов, '
                'они будут взяты оттуда, а шаблон не применится.',
                style: TextStyle(
                    fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withAlpha(140)),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Text(
              '{house} — номер дома из адреса, {apt} — номер квартиры, '
              '{n} — порядковый номер.\n'
              'Например «{house}-{apt}» для дома 27 даст 27-1, 27-2, 27-3…',
              style: TextStyle(fontSize: 11, color: cs.onSurface.withAlpha(140)),
            ),
          ),

          _header('Данные для ГИС ЖКХ'),
          _dropdown('Тип помещения', _premisesType, gisPremisesTypes,
              (v) => setState(() => _premisesType = v!)),
          _dropdown('Тип лицевого счёта', _accountType, gisAccountTypes,
              (v) => setState(() => _accountType = v!)),
          if (_source != _Source.file)
            _field(_area, 'Площадь по умолчанию, кв. м', number: true),
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Text(
              'Площадь и ФИО можно уточнить позже в карточке каждого счёта. '
              'Доля внесения платы ставится 100 % — как требует портал.\n'
              'Идентификатор ЖКУ обязателен для выгрузки в ГИС: без него '
              'портал запись не примет.',
              style: TextStyle(fontSize: 11, color: cs.onSurface.withAlpha(140)),
            ),
          ),

          if (_error != null)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
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
                      child: Text(_error!,
                          style: const TextStyle(fontSize: 12))),
                ],
              ),
            ),

          if (_busy) const LinearProgressIndicator(),

          if (_result != null) _resultBlock(cs),

          const SizedBox(height: 10),
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _busy ? null : _generate,
              icon: const Icon(Icons.playlist_add),
              label: const Text('Создать счета'),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// Выбор файла и предпросмотр того, что в нём нашлось.
  ///
  /// Предпросмотр обязателен: колонки определяются по заголовку, а
  /// таблицы приходят от разных людей — оператор должен увидеть, что
  /// номера и площади распознаны верно, до создания счетов.
  Widget _filePicker(ColorScheme cs) {
    const names = {
      'apartment': 'номер квартиры',
      'area': 'общая площадь',
      'living_area': 'жилая площадь',
      'heated_area': 'отапливаемая площадь',
      'fio': 'ФИО',
      'residents': 'проживающих',
      'rooms': 'комнат',
      'phone': 'телефон',
      'account_number': 'номер ЛС',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OutlinedButton.icon(
          onPressed: _busy ? null : _pickFile,
          icon: const Icon(Icons.table_chart_outlined),
          label: Text(_fileName ?? 'Выбрать файл XLSX'),
        ),
        const SizedBox(height: 6),
        Text(
          'Подойдёт обычная таблица: колонка с номерами квартир и, если '
          'есть, площадь, ФИО, число проживающих. Заголовок распознаётся '
          'автоматически.',
          style: TextStyle(fontSize: 11, color: cs.onSurface.withAlpha(140)),
        ),
        if (_fileColumns.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text('Распознаны колонки:',
              style: TextStyle(
                  fontSize: 11.5, color: cs.onSurface.withAlpha(165))),
          const SizedBox(height: 4),
          Text(
            _fileColumns.entries
                .map((e) => '${e.key} — ${names[e.value] ?? e.value}')
                .join(',  '),
            style: TextStyle(fontSize: 11.5, color: cs.onSurface.withAlpha(175)),
          ),
        ],
        if (_fileRows.isNotEmpty) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Найдено квартир: ${_fileRows.length}',
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                ..._fileRows.take(6).map((r) {
                  final parts = <String>[
                    'кв. ${r['apartment']}',
                    if (r['area'] != null) '${r['area']} м²',
                    if (r['fio'] != null) '${r['fio']}',
                    if (r['residents'] != null) 'прож. ${r['residents']}',
                  ];
                  return Text('• ${parts.join('  ·  ')}',
                      style: TextStyle(
                          fontSize: 11, color: cs.onSurface.withAlpha(175)));
                }),
                if (_fileRows.length > 6)
                  Text('…и ещё ${_fileRows.length - 6}',
                      style: TextStyle(
                          fontSize: 11, color: cs.onSurface.withAlpha(140))),
              ],
            ),
          ),
        ],
        const SizedBox(height: 10),
      ],
    );
  }

  Future<void> _pickFile() async {
    final picked = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['xlsx', 'xlsm'],
    );
    final path = picked?.files.single.path;
    if (path == null) return;

    setState(() {
      _busy = true;
      _error = null;
      _result = null;
      _fileName = picked!.files.single.name;
    });
    try {
      final form = FormData.fromMap({
        'file': await MultipartFile.fromFile(path),
      });
      final response = await ref.read(dioProvider).post(
            '/accounts/import-apartments/preview',
            data: form,
            options: Options(receiveTimeout: const Duration(minutes: 3)),
          );
      final data = (response.data as Map).cast<String, dynamic>();
      setState(() {
        _fileRows = ((data['rows'] as List?) ?? const [])
            .map((e) => (e as Map).cast<String, dynamic>())
            .toList();
        _fileColumns = ((data['columns'] as Map?) ?? const {})
            .map((k, v) => MapEntry(k.toString(), v.toString()));
        final warns = ((data['warnings'] as List?) ?? const [])
            .map((e) => e.toString())
            .toList();
        if (warns.isNotEmpty) _error = warns.first;
      });
    } catch (e) {
      setState(() {
        _error = _errorText(e);
        _fileRows = const [];
        _fileColumns = const {};
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _resultBlock(ColorScheme cs) {
    final r = _result!;
    final created = (r['created'] as num?)?.toInt() ?? 0;
    final skipped = (r['skipped'] as num?)?.toInt() ?? 0;
    final accounts =
        ((r['accounts'] as List?) ?? const []).cast<Map<String, dynamic>>();
    final warnings =
        ((r['warnings'] as List?) ?? const []).map((e) => e.toString()).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Создано: $created',
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: AppTheme.successGreen)),
          if (skipped > 0)
            Text('Пропущено: $skipped',
                style: const TextStyle(color: AppTheme.warningOrange)),
          if (accounts.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              accounts
                  .take(12)
                  .map((a) => a['account_number']?.toString() ?? '')
                  .join(', ') +
                  (accounts.length > 12 ? ' …' : ''),
              style: TextStyle(fontSize: 11.5, color: cs.onSurface.withAlpha(170)),
            ),
          ],
          if (warnings.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...warnings.take(6).map((w) => Text('• $w',
                style: TextStyle(fontSize: 11, color: cs.onSurface.withAlpha(150)))),
          ],
        ],
      ),
    );
  }

  Widget _header(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
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

  Widget _field(
    TextEditingController controller,
    String label, {
    String? hint,
    bool number = false,
    int maxLines = 1,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: number ? TextInputType.number : TextInputType.text,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            isDense: true,
            border: const OutlineInputBorder(),
          ),
        ),
      );

  Widget _dropdown(String label, String value, List<String> options,
          ValueChanged<String?> onChanged) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          isDense: true,
          decoration: InputDecoration(
            labelText: label,
            isDense: true,
            border: const OutlineInputBorder(),
          ),
          style: const TextStyle(fontSize: 12.5),
          items: options
              .map((o) => DropdownMenuItem(
                  value: o,
                  child: Text(o, style: const TextStyle(fontSize: 12.5))))
              .toList(),
          onChanged: _busy ? null : onChanged,
        ),
      );
}
