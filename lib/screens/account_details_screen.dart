import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/gis_details_models.dart';
import '../services/gis_details_service.dart';
import 'gis_params_screen.dart';

/// Комнаты и основания лицевого счёта — листы «Комнаты», «Информация о
/// комнатах» (шаблон МКД) и «Основания» (шаблон ЛС).
///
/// Раньше комнат в приложении не было, а основания (договоры соцнайма,
/// ресурсоснабжения, ТКО) не велись вовсе — эти листы выгружались
/// пустыми.
class AccountDetailsScreen extends ConsumerStatefulWidget {
  final int accountId;
  final String accountTitle;

  /// Тип помещения: от него зависит, какая группа расширенных
  /// параметров относится к счёту.
  final String? premisesType;

  const AccountDetailsScreen({
    super.key,
    required this.accountId,
    required this.accountTitle,
    this.premisesType,
  });

  @override
  ConsumerState<AccountDetailsScreen> createState() =>
      _AccountDetailsScreenState();
}

/// Типы оснований — строго из выпадающего списка шаблона ЛС.
const _basisTypes = <String>[
  'Договор ресурсоснабжения (ЛС РСО или ЛС РЦ)',
  'Договор социального найма жилого помещения (ЛС ОГВ/ОМС)',
  'Договор на оказание услуг по обращению с ТКО (ЛС ТКО)',
];

/// Тип договора соцнайма — лист «Тип_ДСОЦ» шаблона. Значения приходят
/// в портал кодами, поэтому рядом показываем расшифровку.
const _socialTypes = <String, String>{
  'DWELLING_APARTMENT': 'Жилое помещение (квартира)',
  'SOCIAL_FUND': 'Фонд социального использования',
  'STATE_MUNICIPAL_FUND': 'Государственный/муниципальный фонд',
};

class _AccountDetailsScreenState extends ConsumerState<AccountDetailsScreen> {
  List<GisRoom> _rooms = [];
  List<AccountBasis> _bases = [];
  bool _loading = true;
  String? _error;

  bool get _isNonLiving => widget.premisesType == 'Нежилое помещение';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final service = ref.read(gisDetailsServiceProvider);
      final results = await Future.wait([
        service.getRooms(widget.accountId),
        service.getBases(widget.accountId),
      ]);
      _rooms = results[0] as List<GisRoom>;
      _bases = results[1] as List<AccountBasis>;
    } catch (e) {
      _error = _message(e);
    }
    if (mounted) setState(() => _loading = false);
  }

  String _message(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['detail'] != null) return '${data['detail']}';
      return error.message ?? 'Ошибка сети';
    }
    return '$error';
  }

  void _toast(String text, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text),
      backgroundColor: error ? Colors.red : Colors.green,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Сведения ГИС по счёту'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(widget.accountTitle,
                style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context)
                        .appBarTheme
                        .foregroundColor
                        ?.withAlpha(180))),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      OutlinedButton(
                          onPressed: _load, child: const Text('Повторить')),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 80),
                    children: [
                      Card(
                        margin: const EdgeInsets.all(16),
                        child: ListTile(
                          leading: const Icon(Icons.list_alt,
                              color: Colors.deepPurple),
                          title: const Text('Расширенные сведения'),
                          subtitle: Text(_isNonLiving
                              ? 'Назначение нежилого помещения'
                              : 'Комнаты, проживающие'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => GisParamsScreen(
                                groupKey: _isNonLiving
                                    ? 'nonliving_info'
                                    : 'living_info',
                                ownerType: 'premises',
                                ownerId: widget.accountId,
                                ownerTitle: widget.accountTitle,
                              ),
                            ),
                          ),
                        ),
                      ),
                      _header('Комнаты', _rooms.length),
                      if (_rooms.isEmpty)
                        _hint('Комнаты нужны только для коммунальных '
                            'квартир — лист «Комнаты» шаблона.'),
                      ..._rooms.map(_roomTile),
                      _addButton('Добавить комнату', _editRoom),
                      const SizedBox(height: 16),
                      _header('Основания', _bases.length),
                      if (_bases.isEmpty)
                        _hint('Договор, по которому ведётся счёт — лист '
                            '«Основания» шаблона лицевых счетов.'),
                      ..._bases.map(_basisTile),
                      _addButton('Добавить основание', _editBasis),
                    ],
                  ),
                ),
    );
  }

  Widget _header(String title, int count) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Row(
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            Text('$count', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );

  Widget _hint(String text) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Text(text,
            style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      );

  Widget _addButton(String label, VoidCallback onTap) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: OutlinedButton.icon(
          icon: const Icon(Icons.add),
          label: Text(label),
          onPressed: onTap,
        ),
      );

  Widget _roomTile(GisRoom item) {
    final details = [
      if (item.area != null) '${item.area} кв.м',
      if ((item.cadastralNumber ?? '').isNotEmpty) item.cadastralNumber!,
    ].join(' · ');
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: const Icon(Icons.meeting_room, color: Colors.teal),
        title: Text('Комната №${item.number}'),
        subtitle: details.isEmpty ? null : Text(details),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') _editRoom(item);
            if (value == 'params') {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => GisParamsScreen(
                  groupKey: 'room_info',
                  ownerType: 'room',
                  ownerId: item.id!,
                  ownerTitle: 'Комната №${item.number}',
                ),
              ));
            }
            if (value == 'delete') _deleteRoom(item);
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Изменить')),
            PopupMenuItem(value: 'params', child: Text('Расширенные сведения')),
            PopupMenuItem(value: 'delete', child: Text('Удалить')),
          ],
        ),
        onTap: () => _editRoom(item),
      ),
    );
  }

  Widget _basisTile(AccountBasis item) {
    final number = item.socialNumber ?? item.supplyNumber ?? item.wasteNumber;
    final date = item.socialDate ?? item.supplyDate ?? item.wasteDate;
    final details = [
      if ((item.basisIdentifier ?? '').isNotEmpty)
        'ид. ${item.basisIdentifier}',
      if ((number ?? '').isNotEmpty) '№ $number',
      if (date != null)
        '${date.day.toString().padLeft(2, '0')}.'
            '${date.month.toString().padLeft(2, '0')}.${date.year}',
    ].join(' · ');
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: const Icon(Icons.description, color: Colors.orange),
        title: Text(item.basisType, style: const TextStyle(fontSize: 14)),
        subtitle: Text(details.isEmpty ? 'нет номера договора' : details),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') _editBasis(item);
            if (value == 'delete') _deleteBasis(item);
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Изменить')),
            PopupMenuItem(value: 'delete', child: Text('Удалить')),
          ],
        ),
        onTap: () => _editBasis(item),
      ),
    );
  }

  // ─────────────────────────── комнаты ───────────────────────────

  Future<void> _editRoom([GisRoom? item]) async {
    final number = TextEditingController(text: item?.number ?? '');
    final area = TextEditingController(text: item?.area?.toString() ?? '');
    final cadastral =
        TextEditingController(text: item?.cadastralNumber ?? '');
    // Привязка комнаты к ЕГРП — колонка D листа «Доп критерии поиска в
    // ЕГРП». Нужна, когда по кадастровому номеру комнату не нашли.
    final egrpConditional =
        TextEditingController(text: item?.gisEgrpConditionalNumber ?? '');
    final egrpRegNumber =
        TextEditingController(text: item?.gisEgrpRegistrationNumber ?? '');
    final egrpRegDate = TextEditingController(
      text: item?.gisEgrpRegistrationDate
              ?.toIso8601String()
              .split('T')
              .first ??
          '',
    );
    var confirmed = item?.confirmed ?? true;

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          title: Text(item == null ? 'Новая комната' : 'Комната'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: number,
                  decoration: const InputDecoration(
                    labelText: 'Номер комнаты *',
                    helperText: 'Обязательное поле портала',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: area,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration:
                      const InputDecoration(labelText: 'Площадь, кв.м'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: cadastral,
                  decoration: const InputDecoration(
                    labelText: 'Кадастровый номер',
                    helperText: 'Пусто — выгрузится «отсутствует»',
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Информация подтверждена'),
                  value: confirmed,
                  onChanged: (v) => setDialog(() => confirmed = v),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: egrpConditional,
                  decoration: const InputDecoration(
                    labelText: 'Условный номер ЕГРП',
                    helperText: 'лист «Доп критерии поиска в ЕГРП»',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: egrpRegNumber,
                  decoration: const InputDecoration(
                    labelText: 'Номер гос. регистрации права',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: egrpRegDate,
                  decoration: const InputDecoration(
                    labelText: 'Дата гос. регистрации права',
                    hintText: 'ГГГГ-ММ-ДД',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Отмена')),
            FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Сохранить')),
          ],
        ),
      ),
    );
    if (saved != true) return;
    if (number.text.trim().isEmpty) {
      _toast('Укажите номер комнаты', error: true);
      return;
    }

    final body = GisRoom(
      accountId: widget.accountId,
      number: number.text.trim(),
      area: double.tryParse(area.text.replaceAll(',', '.')),
      cadastralNumber:
          cadastral.text.trim().isEmpty ? null : cadastral.text.trim(),
      confirmed: confirmed,
      gisEgrpConditionalNumber: egrpConditional.text.trim().isEmpty
          ? null
          : egrpConditional.text.trim(),
      gisEgrpRegistrationNumber: egrpRegNumber.text.trim().isEmpty
          ? null
          : egrpRegNumber.text.trim(),
      gisEgrpRegistrationDate: DateTime.tryParse(egrpRegDate.text.trim()),
    );
    try {
      final service = ref.read(gisDetailsServiceProvider);
      if (item?.id == null) {
        await service.createRoom(body);
      } else {
        await service.updateRoom(item!.id!, body);
      }
      await _load();
      _toast('Сохранено');
    } catch (e) {
      _toast(_message(e), error: true);
    }
  }

  Future<void> _deleteRoom(GisRoom item) async {
    if (!await _confirm('Удалить комнату №${item.number}?')) return;
    try {
      await ref.read(gisDetailsServiceProvider).deleteRoom(item.id!);
      await _load();
      _toast('Комната удалена');
    } catch (e) {
      _toast(_message(e), error: true);
    }
  }

  // ─────────────────────────── основания ───────────────────────────

  Future<void> _editBasis([AccountBasis? item]) async {
    var basisType = item?.basisType ?? _basisTypes.first;
    var socialType = item?.socialType;
    var supplyNotPublic = item?.supplyNotPublic;
    final identifier =
        TextEditingController(text: item?.basisIdentifier ?? '');
    final number = TextEditingController(
        text: item?.socialNumber ?? item?.supplyNumber ?? item?.wasteNumber ?? '');
    DateTime? signed = item?.socialDate ?? item?.supplyDate ?? item?.wasteDate;
    DateTime? effective = item?.wasteEffectiveDate;

    String fmt(DateTime? d) => d == null
        ? 'не указана'
        : '${d.day.toString().padLeft(2, '0')}.'
            '${d.month.toString().padLeft(2, '0')}.${d.year}';

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) {
          final isSocial = basisType.contains('социального найма');
          final isSupply = basisType.contains('ресурсоснабжения');
          final isWaste = basisType.contains('ТКО');
          return AlertDialog(
            title: Text(item == null ? 'Новое основание' : 'Основание'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: basisType,
                    isExpanded: true,
                    decoration:
                        const InputDecoration(labelText: 'Тип основания *'),
                    items: [
                      for (final t in _basisTypes)
                        DropdownMenuItem(
                          value: t,
                          child: Text(t, style: const TextStyle(fontSize: 13)),
                        ),
                    ],
                    onChanged: (v) => setDialog(() => basisType = v!),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: identifier,
                    decoration: const InputDecoration(
                      labelText: 'Идентификатор основания',
                      helperText: 'Присваивает портал. Если он есть, '
                          'номер договора не обязателен',
                    ),
                  ),
                  if (isSocial) ...[
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: socialType,
                      isExpanded: true,
                      decoration:
                          const InputDecoration(labelText: 'Тип договора'),
                      items: [
                        for (final e in _socialTypes.entries)
                          DropdownMenuItem(
                            value: e.key,
                            child: Text(e.value,
                                style: const TextStyle(fontSize: 13)),
                          ),
                      ],
                      onChanged: (v) => setDialog(() => socialType = v),
                    ),
                  ],
                  if (isSupply) ...[
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Договор не публичный',
                          style: TextStyle(fontSize: 14)),
                      subtitle: const Text(
                          'заключён на бумаге или в электронной форме',
                          style: TextStyle(fontSize: 11)),
                      value: supplyNotPublic ?? false,
                      onChanged: (v) => setDialog(() => supplyNotPublic = v),
                    ),
                  ],
                  const SizedBox(height: 8),
                  TextField(
                    controller: number,
                    decoration: const InputDecoration(
                        labelText: 'Номер договора'),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Дата заключения',
                        style: TextStyle(fontSize: 14)),
                    subtitle: Text(fmt(signed)),
                    trailing: const Icon(Icons.calendar_today, size: 18),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: signed ?? DateTime.now(),
                        firstDate: DateTime(1990),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) setDialog(() => signed = picked);
                    },
                  ),
                  if (isWaste)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Дата вступления в силу',
                          style: TextStyle(fontSize: 14)),
                      subtitle: Text(fmt(effective)),
                      trailing: const Icon(Icons.calendar_today, size: 18),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: effective ?? signed ?? DateTime.now(),
                          firstDate: DateTime(1990),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) setDialog(() => effective = picked);
                      },
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('Отмена')),
              FilledButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text('Сохранить')),
            ],
          );
        },
      ),
    );
    if (saved != true) return;

    final isSocial = basisType.contains('социального найма');
    final isSupply = basisType.contains('ресурсоснабжения');
    final isWaste = basisType.contains('ТКО');
    final text = number.text.trim();
    final payload = AccountBasis(
      accountId: widget.accountId,
      basisType: basisType,
      basisIdentifier:
          identifier.text.trim().isEmpty ? null : identifier.text.trim(),
      socialType: isSocial ? socialType : null,
      socialNumber: isSocial && text.isNotEmpty ? text : null,
      socialDate: isSocial ? signed : null,
      supplyNotPublic: isSupply ? supplyNotPublic : null,
      supplyNumber: isSupply && text.isNotEmpty ? text : null,
      supplyDate: isSupply ? signed : null,
      wasteNumber: isWaste && text.isNotEmpty ? text : null,
      wasteDate: isWaste ? signed : null,
      wasteEffectiveDate: isWaste ? effective : null,
    );
    try {
      final service = ref.read(gisDetailsServiceProvider);
      if (item?.id == null) {
        await service.createBasis(payload);
      } else {
        await service.updateBasis(item!.id!, payload);
      }
      await _load();
      _toast('Сохранено');
    } catch (e) {
      _toast(_message(e), error: true);
    }
  }

  Future<void> _deleteBasis(AccountBasis item) async {
    if (!await _confirm('Удалить основание?')) return;
    try {
      await ref.read(gisDetailsServiceProvider).deleteBasis(item.id!);
      await _load();
      _toast('Основание удалено');
    } catch (e) {
      _toast(_message(e), error: true);
    }
  }

  Future<bool> _confirm(String title) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Отмена')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    return result == true;
  }
}
