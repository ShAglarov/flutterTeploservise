import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/permission_key.dart';
import '../services/accounts_bulk_service.dart';
import '../services/file_export_helper.dart';
import '../services/permission_service.dart';
import '../utils/address_search_helper.dart';
import '../utils/app_theme.dart';
import '../utils/gis_dictionaries.dart';

/// Откуда брать помещения.
enum _Mode {
  /// Номера 1..N из поля «Квартир» карточки дома.
  byHouses,

  /// Таблица: дом у каждой строки свой, площади и ФИО из файла.
  fromFile,
}

/// Массовое создание лицевых счетов по всему жилфонду.
///
/// ЧЕМ ОТЛИЧАЕТСЯ ОТ ЭКРАНА В КАРТОЧКЕ ДОМА
///     Тот работает с одним домом: оператор заходил в каждый по
///     очереди. Здесь дома отмечаются галочками сразу, сгруппированные
///     по котельным, а дома со счетами снимаются автоматически —
///     повторно создавать их не нужно.
///
/// СВЯЗЬ С ВЫГРУЗКОЙ ГИС ЖКХ
///     Созданные счета уезжают в шаблон импорта ЛС, поэтому поля
///     заполняются по его правилам: номер помещения — текстом,
///     идентификатор ЖКУ обязателен (портал сопоставляет записи по
///     нему), доля внесения платы — 100%.
class AccountsMassScreen extends ConsumerStatefulWidget {
  const AccountsMassScreen({super.key});

  @override
  ConsumerState<AccountsMassScreen> createState() =>
      _AccountsMassScreenState();
}

class _AccountsMassScreenState extends ConsumerState<AccountsMassScreen> {
  final _numberTemplate = TextEditingController(text: '{house}-{apt}');
  // Заполнен по умолчанию: без идентификатора ЖКУ счёт не попадёт
  // в выгрузку ГИС — портал сопоставляет записи именно по нему.
  final _jkuTemplate = TextEditingController(text: 'ЖКУ-{house}-{apt}');
  final _search = TextEditingController();

  _Mode _mode = _Mode.byHouses;

  /// Заменить ранее загруженные счета домов из файла.
  ///
  /// Выключено по умолчанию: обычная загрузка только добавляет, а
  /// замена удаляет записи — такое не должно включаться само.
  bool _replaceExisting = false;
  String _premisesType = gisPremisesTypes.first;
  String _accountType = gisAccountTypes.first;

  List<BulkHouse> _houses = const [];
  final Set<int> _selected = {};
  bool _loading = true;
  String? _loadError;

  /// Разобранный файл, его имя и путь.
  ///
  /// Путь нужен для создания: на сервер уходит сам файл, а не строки
  /// предпросмотра — тех приходит только первая сотня.
  ParsedApartments? _parsed;
  String? _fileName;
  String? _filePath;
  int? _defaultLocationId;

  bool _busy = false;
  String? _error;
  BulkResult? _result;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in [_numberTemplate, _jkuTemplate, _search]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final houses = await ref.read(accountsBulkServiceProvider).houses();
      setState(() {
        _houses = houses;
        _selected
          ..clear()
          // По умолчанию отмечаем только то, что действительно нужно
          // создавать: дом без счетов и с заполненным числом квартир.
          // Это и есть просьба «снять галочку с домов, где счета уже
          // созданы» — оператору не приходится снимать их вручную.
          ..addAll(houses
              .where((h) => h.canGenerate && !h.hasAccounts)
              .map((h) => h.id));
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loadError = _errorText(e);
        _loading = false;
      });
    }
  }

  String _errorText(Object e) {
    // Клиент новее сервера: замена не выполнена, счета не тронуты.
    if (e is BulkReplaceUnsupported) return e.toString();
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

  // ─────────────────────── выбор домов ───────────────────────

  /// Дома, прошедшие поиск. Группировка по котельной — ниже.
  List<BulkHouse> get _visible {
    final query = _search.text.trim();
    if (query.isEmpty) return _houses;
    return _houses
        .where((h) => AddressSearchHelper.matchesHouse(
              query,
              name: h.name,
              managementCompany: h.boilerHouseName,
              cadastralNumber: h.cadastralNumber,
            ))
        .toList();
  }

  /// Дома по котельным, в порядке названия котельной.
  Map<String, List<BulkHouse>> get _grouped {
    final out = <String, List<BulkHouse>>{};
    for (final house in _visible) {
      final key = house.boilerHouseName ?? 'Без котельной';
      out.putIfAbsent(key, () => []).add(house);
    }
    return Map.fromEntries(
      out.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }

  /// Сколько счетов появится по отмеченным домам.
  int get _plannedCount => _houses
      .where((h) => _selected.contains(h.id))
      .fold<int>(0, (sum, h) => sum + h.plannedCount);

  int get _selectedCount =>
      _houses.where((h) => _selected.contains(h.id)).length;

  void _toggleHouse(BulkHouse house, bool? value) {
    setState(() {
      if (value == true) {
        _selected.add(house.id);
      } else {
        _selected.remove(house.id);
      }
    });
  }

  void _toggleGroup(List<BulkHouse> houses, bool select) {
    setState(() {
      for (final house in houses) {
        // Дом без количества квартир отмечать бессмысленно: сервер
        // пропустит его с причиной.
        if (!house.canGenerate) continue;
        if (select) {
          _selected.add(house.id);
        } else {
          _selected.remove(house.id);
        }
      }
    });
  }

  void _selectPreset(_Preset preset) {
    setState(() {
      _selected.clear();
      for (final house in _visible) {
        if (!house.canGenerate) continue;
        final matches = switch (preset) {
          _Preset.withoutAccounts => !house.hasAccounts,
          _Preset.all => true,
          _Preset.none => false,
        };
        if (matches) _selected.add(house.id);
      }
    });
  }

  // ─────────────────────── работа с файлом ───────────────────────

  Future<void> _downloadTemplate() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final file = await ref
          .read(accountsBulkServiceProvider)
          .downloadTemplate(prefill: true);
      if (!mounted) return;
      // FileExportHelper: десктоп → «Сохранить как», мобильные → share
      // с правильным sharePositionOrigin (iPad без него крашится).
      await FileExportHelper.exportFile(
        sourceFile: file,
        fileName: 'шаблон_лицевых_счетов.xlsx',
        mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        subject: 'Шаблон для создания лицевых счетов',
      );
    } catch (e) {
      setState(() => _error = _errorText(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
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
    });
    try {
      final parsed =
          await ref.read(accountsBulkServiceProvider).previewFile(path);
      setState(() {
        _parsed = parsed;
        _fileName = picked!.files.single.name;
        _filePath = path;
        // Файл без колонки адреса относится к одному дому — его
        // оператор выберет сам.
        if (!parsed.multiHouse) _defaultLocationId = null;
      });
    } catch (e) {
      setState(() {
        _error = _errorText(e);
        _parsed = null;
        _fileName = null;
        _filePath = null;
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Сколько строк файла реально создадут счета.
  int get _fileRowsCount => _parsed?.count ?? 0;

  // ─────────────────────── создание ───────────────────────

  /// Пробный прогон: сервер считает итог, ничего не записывая.
  Future<void> _preview() => _run(dryRun: true);

  Future<void> _create() async {
    final confirmed = await _confirm();
    if (confirmed != true) return;
    await _run(dryRun: false);
  }

  Future<bool?> _confirm() {
    final isFile = _mode == _Mode.fromFile;
    final count = isFile ? _fileRowsCount : _plannedCount;
    final where = isFile
        ? 'по файлу «${_fileName ?? ''}»'
        : 'по $_selectedCount домам';
    final replacing = isFile && _replaceExisting;

    // При замене спрашиваем иначе: это удаление, и число удаляемых
    // счетов оператор должен увидеть ДО запуска, а не в итоге.
    // Берём его из пробного прогона, если он уже был.
    final preview = _result;
    final willDelete = (preview != null && preview.replaced)
        ? preview.deleted
        : null;

    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(replacing
            ? 'Заменить лицевые счета?'
            : 'Создать лицевые счета?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (replacing) ...[
              Text(
                'Счета домов из файла «${_fileName ?? ''}» будут '
                'заменены данными файла: $count строк.',
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.warningOrange.withAlpha(28),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      willDelete == null
                          ? 'Прежние счета этих домов будут удалены.'
                          : 'Будет удалено счетов: $willDelete',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Счёт с платежами, квитанциями или кассовыми '
                      'операциями не удаляется — обновляется. Остальные '
                      'удаляются вместе с показаниями счётчиков.',
                      style: TextStyle(fontSize: 12),
                    ),
                    if (willDelete == null) ...[
                      const SizedBox(height: 6),
                      const Text(
                        'Нажмите «Проверить», чтобы увидеть точное число '
                        'до записи.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
            ] else
              Text(
                'Будет создано до $count счетов $where.\n\n'
                'Помещения, для которых счёт уже есть, пропускаются — '
                'повторный запуск ничего не продублирует.',
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            style: replacing
                ? FilledButton.styleFrom(
                    backgroundColor: AppTheme.warningOrange)
                : null,
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(replacing ? 'Заменить' : 'Создать'),
          ),
        ],
      ),
    );
  }

  Future<void> _run({required bool dryRun}) async {
    setState(() {
      _busy = true;
      _error = null;
      _result = null;
    });
    try {
      final service = ref.read(accountsBulkServiceProvider);
      final jku = _jkuTemplate.text.trim();
      final result = _mode == _Mode.fromFile
          ? await service.importFile(
              filePath: _filePath!,
              defaultLocationId: _defaultLocationId,
              numberTemplate: _numberTemplate.text.trim(),
              jkuTemplate: jku.isEmpty ? null : jku,
              premisesType: _premisesType,
              accountType: _accountType,
              replaceExisting: _replaceExisting,
              dryRun: dryRun,
            )
          : await service.generateByHouses(
              locationIds: _selected.toList(),
              numberTemplate: _numberTemplate.text.trim(),
              jkuTemplate: jku.isEmpty ? null : jku,
              premisesType: _premisesType,
              accountType: _accountType,
              dryRun: dryRun,
            );
      setState(() => _result = result);
      // После реального создания перечитываем список: у домов
      // изменилось число счетов, и галочки должны сняться сами.
      if (!dryRun) await _load();
    } catch (e) {
      setState(() => _error = _errorText(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Можно ли запускать.
  bool get _canRun {
    if (_busy) return false;
    if (_numberTemplate.text.trim().isEmpty) return false;
    return _mode == _Mode.fromFile
        // Путь обязателен: создание отправляет сам файл.
        ? _fileRowsCount > 0 && _filePath != null
        : _selected.isNotEmpty;
  }

  // ─────────────────────────── интерфейс ───────────────────────────

  @override
  Widget build(BuildContext context) {
    final canCreate = ref
        .watch(permissionStateProvider)
        .hasPermission(PermissionKey.accountCreate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Лицевые счета по квартирам'),
        actions: [
          IconButton(
            tooltip: 'Обновить список домов',
            icon: const Icon(Icons.refresh),
            onPressed: _busy ? null : _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
              ? _buildLoadError()
              : _buildBody(canCreate),
      // Итог и кнопка — закреплены снизу: список домов длинный, и
      // прокручивать его до кнопки на каждый запуск неудобно.
      bottomNavigationBar: _loading || _loadError != null
          ? null
          : _buildBottomBar(canCreate),
    );
  }

  Widget _buildLoadError() => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off,
                  size: 48,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(90)),
              const SizedBox(height: 12),
              Text(_loadError!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(onPressed: _load, child: const Text('Повторить')),
            ],
          ),
        ),
      );

  Widget _buildBody(bool canCreate) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _buildModeSwitch(),
        const SizedBox(height: 16),
        if (_mode == _Mode.byHouses) ...[
          _buildHousesHeader(),
          const SizedBox(height: 8),
          _buildHousesList(),
        ] else
          _buildFileSection(),
        const SizedBox(height: 20),
        _buildNumbering(),
        const SizedBox(height: 20),
        _buildGisFields(),
        if (_error != null) ...[
          const SizedBox(height: 16),
          _buildError(_error!),
        ],
        if (_result != null) ...[
          const SizedBox(height: 16),
          _buildResult(_result!),
        ],
        if (!canCreate) ...[
          const SizedBox(height: 16),
          Text(
            'Нет права на создание лицевых счетов — доступен только '
            'предварительный расчёт.',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildModeSwitch() => SegmentedButton<_Mode>(
        segments: const [
          ButtonSegment(
            value: _Mode.byHouses,
            icon: Icon(Icons.apartment),
            label: Text('По домам'),
          ),
          ButtonSegment(
            value: _Mode.fromFile,
            icon: Icon(Icons.table_chart),
            label: Text('Из файла'),
          ),
        ],
        selected: {_mode},
        onSelectionChanged: _busy
            ? null
            : (value) => setState(() {
                  _mode = value.first;
                  _result = null;
                  _error = null;
                }),
      );

  Widget _buildError(String text) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.errorRed.withAlpha(30),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: AppTheme.errorRed, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
          ],
        ),
      );

  // ─────────────────────── список домов ───────────────────────

  Widget _buildHousesHeader() {
    final withAccounts = _houses.where((h) => h.hasAccounts).length;
    final withoutRooms = _houses.where((h) => !h.canGenerate).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          'Дома',
          hint: 'Номера помещений — 1..N из поля «Квартир» карточки дома. '
              'Дома, где счета уже есть, сняты автоматически.',
        ),
        TextField(
          controller: _search,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Поиск по адресу, котельной, кадастровому номеру',
            prefixIcon: const Icon(Icons.search, size: 20),
            suffixIcon: _search.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () => setState(() => _search.clear()),
                  ),
            isDense: true,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // Первый набор — то, что нужно почти всегда.
            ActionChip(
              avatar: const Icon(Icons.playlist_add_check, size: 18),
              label: const Text('Только без счетов'),
              onPressed: () => _selectPreset(_Preset.withoutAccounts),
            ),
            ActionChip(
              avatar: const Icon(Icons.done_all, size: 18),
              label: const Text('Все'),
              onPressed: () => _selectPreset(_Preset.all),
            ),
            ActionChip(
              avatar: const Icon(Icons.remove_done, size: 18),
              label: const Text('Снять все'),
              onPressed: () => _selectPreset(_Preset.none),
            ),
          ],
        ),
        if (withAccounts > 0 || withoutRooms > 0) ...[
          const SizedBox(height: 8),
          Text(
            [
              if (withAccounts > 0) 'со счетами: $withAccounts',
              if (withoutRooms > 0)
                'без количества квартир: $withoutRooms (отметить нельзя)',
            ].join(' • '),
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(130),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildHousesList() {
    final groups = _grouped;
    if (groups.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Text(
            _houses.isEmpty
                ? 'Нет домов, привязанных к котельным'
                : 'Нет домов по запросу «${_search.text.trim()}»',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withAlpha(140),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        for (final entry in groups.entries)
          _buildGroup(entry.key, entry.value),
      ],
    );
  }

  Widget _buildGroup(String boiler, List<BulkHouse> houses) {
    final selectable = houses.where((h) => h.canGenerate).toList();
    final allSelected = selectable.isNotEmpty &&
        selectable.every((h) => _selected.contains(h.id));
    final someSelected = selectable.any((h) => _selected.contains(h.id));
    final planned =
        houses.fold<int>(0, (sum, h) => sum + h.plannedCount);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        // Убираем разделители ExpansionTile: в плотном списке они
        // спорят с границами карточки.
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: groupsExpandedByDefault,
          tilePadding: const EdgeInsets.symmetric(horizontal: 12),
          childrenPadding: const EdgeInsets.only(bottom: 6),
          leading: Checkbox(
            value: allSelected ? true : (someSelected ? null : false),
            tristate: true,
            onChanged: selectable.isEmpty
                ? null
                : (_) => _toggleGroup(selectable, !allSelected),
          ),
          title: Text(
            boiler,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          subtitle: Text(
            'домов ${houses.length} • к созданию $planned',
            style: const TextStyle(fontSize: 12),
          ),
          children: [
            for (final house in houses) _buildHouseRow(house),
          ],
        ),
      ),
    );
  }

  Widget _buildHouseRow(BulkHouse house) {
    final cs = Theme.of(context).colorScheme;
    final subtitle = <String>[
      if (house.canGenerate)
        'квартир ${house.apartments}'
      else
        'не указано количество квартир',
      if (house.hasAccounts) 'счетов ${house.accountsCount}',
    ].join(' • ');

    return CheckboxListTile(
      dense: true,
      controlAffinity: ListTileControlAffinity.leading,
      value: _selected.contains(house.id),
      // Дом без количества квартир отметить нельзя: создавать нечего,
      // и сервер всё равно вернул бы его в причинах.
      onChanged: house.canGenerate
          ? (value) => _toggleHouse(house, value)
          : null,
      title: Text(house.name, style: const TextStyle(fontSize: 13)),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 11,
          color: house.canGenerate
              ? cs.onSurface.withAlpha(140)
              : AppTheme.warningOrange,
        ),
      ),
      secondary: house.plannedCount > 0
          ? Chip(
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              label: Text('+${house.plannedCount}',
                  style: const TextStyle(fontSize: 11)),
            )
          : (house.hasAccounts
              ? Icon(Icons.check_circle, size: 18, color: AppTheme.successGreen)
              : null),
    );
  }

  // ─────────────────────── режим «Из файла» ───────────────────────

  Widget _buildFileSection() {
    final parsed = _parsed;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          'Таблица',
          hint: 'Один файл на все дома: дом берётся из колонки «Адрес '
              'дома». Номер лицевого счёта можно не заполнять — он '
              'соберётся из адреса и номера помещения.',
        ),
        Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.download, color: Colors.teal),
                title: const Text('Скачать шаблон'),
                subtitle: const Text(
                  'адреса домов и номера квартир уже подставлены',
                  style: TextStyle(fontSize: 12),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: _busy ? null : _downloadTemplate,
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.help_outline, color: Colors.indigo),
                title: const Text('Какие колонки заполнять'),
                subtitle: const Text(
                  'и куда каждая уходит в ГИС ЖКХ',
                  style: TextStyle(fontSize: 12),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: _busy ? null : _showTemplateFields,
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.upload_file, color: Colors.orange),
                title: Text(_fileName ?? 'Выбрать заполненный файл'),
                subtitle: Text(
                  parsed == null
                      ? '.xlsx или .xlsm'
                      : 'строк ${parsed.count}'
                          '${parsed.multiHouse ? ', домов ${parsed.addresses.length}' : ''}',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: _busy ? null : _pickFile,
              ),
            ],
          ),
        ),
        if (parsed != null) ...[
          const SizedBox(height: 12),
          _buildParsedSummary(parsed),
        ],
        const SizedBox(height: 12),
        _buildReplaceSwitch(),
      ],
    );
  }

  /// Галочка полной замены. Отдельной карточкой и оранжевым, когда
  /// включена: это единственное место экрана, которое УДАЛЯЕТ записи.
  ///
  /// Без права на удаление не показываем совсем: сервер всё равно
  /// ответит 403, а выключенный переключатель оператор счёл бы сбоем.
  Widget _buildReplaceSwitch() {
    final canDelete = ref
        .watch(permissionStateProvider)
        .hasPermission(PermissionKey.accountDelete);
    if (!canDelete) return const SizedBox.shrink();

    final on = _replaceExisting;
    return Container(
      decoration: BoxDecoration(
        color: on ? AppTheme.warningOrange.withAlpha(22) : null,
        border: Border.all(
          color: on
              ? AppTheme.warningOrange.withAlpha(110)
              : Theme.of(context).colorScheme.onSurface.withAlpha(40),
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          SwitchListTile(
            value: on,
            onChanged: _busy
                ? null
                : (value) => setState(() {
                      _replaceExisting = value;
                      // Прежний итог относился к другому режиму.
                      _result = null;
                    }),
            title: const Text(
              'Заменить ранее загруженные',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              on
                  ? 'Счета домов из файла будут перезаписаны, лишние — '
                      'удалены'
                  : 'Сейчас существующие помещения просто пропускаются',
              style: const TextStyle(fontSize: 12),
            ),
            secondary: Icon(
              on ? Icons.swap_horiz : Icons.playlist_add,
              color: on ? AppTheme.warningOrange : Colors.teal,
            ),
          ),
          if (on)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.shield_outlined,
                      size: 16, color: AppTheme.successGreen),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Счёт, по которому уже были платежи, квитанции или '
                      'кассовые операции, НЕ удаляется — он обновляется '
                      'данными из файла. История платежей сохраняется.',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildParsedSummary(ParsedApartments parsed) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Что нашлось в файле',
              style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text('Распознано колонок: ${parsed.columns.length}',
              style: const TextStyle(fontSize: 12)),
          if (parsed.multiHouse) ...[
            const SizedBox(height: 6),
            // Показываем по домам: иначе оператор не заметит, что
            // половина файла относится к одному адресу из-за опечатки.
            for (final entry in parsed.byAddress.entries.take(12))
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text('• ${entry.key} — ${entry.value}',
                    style: const TextStyle(fontSize: 12)),
              ),
            if (parsed.byAddress.length > 12)
              Text('…и ещё ${parsed.byAddress.length - 12} адресов',
                  style: const TextStyle(fontSize: 12)),
          ],
          if (parsed.withoutAddress > 0) ...[
            const SizedBox(height: 8),
            Text(
              'Без адреса дома: ${parsed.withoutAddress} строк — '
              'выберите дом для них ниже',
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.warningOrange),
            ),
            const SizedBox(height: 8),
            _buildDefaultHousePicker(),
          ],
          if (parsed.warnings.isNotEmpty) ...[
            const SizedBox(height: 8),
            for (final w in parsed.warnings.take(5))
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text('⚠ $w', style: const TextStyle(fontSize: 11)),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildDefaultHousePicker() => DropdownButtonFormField<int>(
        initialValue: _defaultLocationId,
        isExpanded: true,
        decoration: const InputDecoration(
          labelText: 'Дом для строк без адреса',
          isDense: true,
          border: OutlineInputBorder(),
        ),
        items: [
          const DropdownMenuItem<int>(value: null, child: Text('— не выбран —')),
          for (final house in _houses)
            DropdownMenuItem<int>(value: house.id, child: Text(house.name)),
        ],
        onChanged: (value) => setState(() => _defaultLocationId = value),
      );

  Future<void> _showTemplateFields() async {
    List<TemplateField> fields;
    try {
      fields = await ref.read(accountsBulkServiceProvider).templateFields();
    } catch (e) {
      if (mounted) setState(() => _error = _errorText(e));
      return;
    }
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.8,
        builder: (ctx, controller) => ListView.separated(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          itemCount: fields.length + 1,
          separatorBuilder: (_, _) => const Divider(height: 12),
          itemBuilder: (ctx, index) {
            if (index == 0) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Колонки шаблона',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  SizedBox(height: 6),
                  Text(
                    'Заголовки распознаются по названию, порядок колонок '
                    'не важен. Лишние колонки игнорируются.',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              );
            }
            final field = fields[index - 1];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        field.title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: field.required
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                    if (field.required)
                      const Text('обязательна',
                          style: TextStyle(
                              fontSize: 11, color: AppTheme.warningOrange)),
                  ],
                ),
                const SizedBox(height: 2),
                Text('→ ${field.gis}', style: const TextStyle(fontSize: 11)),
                if (field.example.isNotEmpty)
                  Text('например: ${field.example}',
                      style: const TextStyle(fontSize: 11)),
              ],
            );
          },
        ),
      ),
    );
  }

  // ─────────────────────── нумерация и поля ГИС ───────────────────────

  Widget _buildNumbering() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            'Нумерация',
            hint: '{house} — номер дома из адреса, {apt} — помещение, '
                '{id} — id дома, {n} — порядковый. Номер счёта уникален '
                'в организации: если дома с одинаковым номером на разных '
                'улицах, добавьте {id}.',
          ),
          TextField(
            controller: _numberTemplate,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Шаблон номера лицевого счёта',
              isDense: true,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _jkuTemplate,
            decoration: const InputDecoration(
              labelText: 'Шаблон идентификатора ЖКУ',
              helperText: 'без него счёт не попадёт в выгрузку ГИС ЖКХ',
              isDense: true,
              border: OutlineInputBorder(),
            ),
          ),
          if (_mode == _Mode.fromFile) ...[
            const SizedBox(height: 8),
            Text(
              'Свои номера из файла не перезаписываются — шаблон '
              'применяется только к пустым ячейкам.',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(130),
              ),
            ),
          ],
        ],
      );

  Widget _buildGisFields() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            'Поля ГИС ЖКХ',
            hint: 'Уходят в шаблон импорта лицевых счетов. В режиме '
                '«Из файла» значения из таблицы важнее.',
          ),
          DropdownButtonFormField<String>(
            initialValue: _premisesType,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Тип помещения',
              isDense: true,
              border: OutlineInputBorder(),
            ),
            items: [
              for (final t in gisPremisesTypes)
                DropdownMenuItem(value: t, child: Text(t)),
            ],
            onChanged: (v) => setState(() => _premisesType = v ?? _premisesType),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _accountType,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Тип лицевого счёта',
              isDense: true,
              border: OutlineInputBorder(),
            ),
            items: [
              for (final t in gisAccountTypes)
                DropdownMenuItem(value: t, child: Text(t)),
            ],
            onChanged: (v) => setState(() => _accountType = v ?? _accountType),
          ),
        ],
      );

  // ─────────────────────── итог и кнопки ───────────────────────

  Widget _buildResult(BulkResult result) {
    final cs = Theme.of(context).colorScheme;
    final houses = result.houses.where((h) => h.created > 0).toList();
    final failed = result.houses.where((h) => h.reason != null).toList();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: result.dryRun
            ? cs.surfaceContainerHighest
            : AppTheme.successGreen.withAlpha(28),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            result.dryRun
                ? 'Предварительный расчёт'
                : 'Создано ${result.created} лицевых счетов',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          if (result.dryRun)
            Text('Будет создано: ${result.wouldCreate}',
                style: const TextStyle(fontSize: 13)),
          // Замена: удалено и обновлено — отдельными строками. В пробном
          // прогоне это прогноз, поэтому формулировка в будущем времени.
          if (result.replaced) ...[
            if (result.deleted > 0)
              Text(
                result.dryRun
                    ? 'Будет удалено: ${result.deleted}'
                    : 'Удалено: ${result.deleted}',
                style: const TextStyle(
                    fontSize: 13, color: AppTheme.warningOrange),
              ),
            if (result.deletedAbsent > 0)
              Text(
                'из них не было в файле: ${result.deletedAbsent}',
                style: const TextStyle(fontSize: 12),
              ),
            if (result.updated > 0)
              Text(
                result.dryRun
                    ? 'Будет обновлено (есть платежи): ${result.updated}'
                    : 'Обновлено (есть платежи): ${result.updated}',
                style: const TextStyle(fontSize: 13),
              ),
            if (result.keptWithHistory > 0)
              Text(
                'Оставлено с историей, хотя в файле их нет: '
                '${result.keptWithHistory}',
                style: const TextStyle(fontSize: 12),
              ),
          ],
          if (result.skipped > 0)
            Text('Пропущено: ${result.skipped}',
                style: const TextStyle(fontSize: 13)),
          // Ноль с непустым файлом почти всегда значит одно: адреса не
          // сопоставились с домами. Это главное, что нужно показать, —
          // иначе итог «создано 0» выглядит как поломка.
          if (result.unresolvedAddresses.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Не нашлось домов по адресам: '
              '${result.unresolvedAddresses.length}',
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.warningOrange),
            ),
            const SizedBox(height: 4),
            for (final a in result.unresolvedAddresses.take(8))
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text('• $a', style: const TextStyle(fontSize: 12)),
              ),
            if (result.unresolvedAddresses.length > 8)
              Text(
                  '…и ещё ${result.unresolvedAddresses.length - 8} адресов',
                  style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            const Text(
              'Проверьте, что дом с таким адресом есть в приложении и '
              'привязан к котельной.',
              style: TextStyle(fontSize: 11),
            ),
          ],
          if (houses.isNotEmpty) ...[
            const SizedBox(height: 8),
            for (final h in houses.take(12))
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  '• ${h.name ?? h.addressInFile ?? '—'} — ${h.created}',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            if (houses.length > 12)
              Text('…и ещё ${houses.length - 12} домов',
                  style: const TextStyle(fontSize: 12)),
          ],
          if (failed.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Не обработаны',
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: AppTheme.warningOrange)),
            for (final h in failed.take(8))
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  '• ${h.addressInFile ?? h.name ?? '—'}: ${h.reason}',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
          ],
          if (result.warnings.isNotEmpty) ...[
            const SizedBox(height: 8),
            // Причины показываем всегда: «создано меньше, чем ожидал» —
            // первый вопрос оператора, и ответ должен быть на экране.
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: EdgeInsets.zero,
              title: Text('Причины (${result.warnings.length})',
                  style: const TextStyle(fontSize: 13)),
              children: [
                for (final w in result.warnings.take(50))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('• $w', style: const TextStyle(fontSize: 11)),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomBar(bool canCreate) {
    final isFile = _mode == _Mode.fromFile;
    final count = isFile ? _fileRowsCount : _plannedCount;
    final summary = isFile
        ? (_parsed == null
            ? 'Файл не выбран'
            : 'строк $count'
                '${_parsed!.multiHouse ? ', домов ${_parsed!.addresses.length}' : ''}')
        : 'выбрано домов $_selectedCount • к созданию $count';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_busy) const LinearProgressIndicator(minHeight: 2),
            if (_busy) const SizedBox(height: 8),
            Text(
              summary,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                // Пробный расчёт — до записи: создание тысяч счетов
                // стоит показать числом, а не «создано 4800, упс».
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _canRun ? _preview : null,
                    icon: const Icon(Icons.calculate_outlined, size: 18),
                    label: const Text('Проверить'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _canRun && canCreate ? _create : null,
                    style: isFile && _replaceExisting
                        ? FilledButton.styleFrom(
                            backgroundColor: AppTheme.warningOrange)
                        : null,
                    icon: Icon(
                      isFile && _replaceExisting
                          ? Icons.swap_horiz
                          : Icons.playlist_add,
                      size: 18,
                    ),
                    label: Text(
                      isFile && _replaceExisting ? 'Заменить' : 'Создать',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text, {String? hint}) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(140),
              ),
            ),
            if (hint != null) ...[
              const SizedBox(height: 4),
              Text(
                hint,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(130),
                ),
              ),
            ],
          ],
        ),
      );
}

/// Готовые наборы выбора — чаще всего нужен первый.
enum _Preset { withoutAccounts, all, none }

/// Котельные раскрыты сразу: иначе оператор видит список свёрнутых
/// заголовков и не понимает, что отмечено внутри.
const groupsExpandedByDefault = true;
