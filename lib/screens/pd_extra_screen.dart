import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/gis_details_models.dart';
import '../services/gis_details_service.dart';
import '../utils/app_theme.dart';

/// Дополнительные листы платёжного документа: «Неустойки и судебные
/// расходы», «ДПД», «Составляющие стоимости ЭЭ», «Платежные реквизиты».
///
/// Эти листы шаблона ПД выгружались пустыми: таких данных в приложении
/// не было. Основные начисления по услугам сюда не входят — они берутся
/// из самого платёжного документа.
class PdExtraScreen extends ConsumerStatefulWidget {
  final int documentId;
  final String documentTitle;

  /// Тип ПД: лист «ДПД» портал принимает только у документа с типом
  /// «Долговой», поэтому для «Текущего» раздел скрыт.
  final String? pdType;

  const PdExtraScreen({
    super.key,
    required this.documentId,
    required this.documentTitle,
    this.pdType,
  });

  @override
  ConsumerState<PdExtraScreen> createState() => _PdExtraScreenState();
}

/// Вид начисления — из выпадающего списка шаблона.
const _penaltyKinds = <String>[
  'Пени',
  'Штрафы',
  'Государственные пошлины',
  'Судебные издержки',
];

/// Составляющие стоимости электроэнергии — из выпадающего списка шаблона.
const _energyNames = <String>[
  'Стоимость электрической энергии (мощности)',
  'Услуги по передаче электрической энергии',
  'Сбытовая надбавка гарантирующего поставщика',
  'Иные услуги, являющиеся неотъемлемой частью процесса поставки '
      'электрической энергии потребителям',
];

/// Услуги приложения — ключ и русское название.
const _services = <String, String>{
  'heating': 'Отопление',
  'hot_water': 'Горячая вода',
  'maintenance': 'Содержание жилья',
  'waste': 'ТКО',
  'odn_water': 'ОДН вода',
  'odn_electricity': 'ОДН электричество',
};

class _PdExtraScreenState extends ConsumerState<PdExtraScreen> {
  final Map<String, List<PdExtraRow>> _rows = {};
  bool _loading = true;
  String? _error;

  bool get _isDebtDoc => widget.pdType == 'Долговой';

  List<String> get _kinds => [
        'penalties',
        if (_isDebtDoc) 'debts',
        'energy',
        'requisites',
      ];

  static const _titles = {
    'penalties': 'Неустойки и судебные расходы',
    'debts': 'Задолженность по периодам (ДПД)',
    'energy': 'Составляющие стоимости электроэнергии',
    'requisites': 'Платёжные реквизиты',
  };

  static const _icons = {
    'penalties': Icons.gavel,
    'debts': Icons.history,
    'energy': Icons.bolt,
    'requisites': Icons.account_balance,
  };

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
      for (final kind in _kinds) {
        _rows[kind] = await service.getPdRows(kind, widget.documentId);
      }
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
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        title: const Text('Дополнительные сведения ПД'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(widget.documentTitle,
                style: const TextStyle(fontSize: 12, color: Colors.white70)),
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
                      if (!_isDebtDoc)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Раздел «Задолженность по периодам» доступен '
                            'только для документа с типом «Долговой».',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600]),
                          ),
                        ),
                      for (final kind in _kinds) ...[
                        _header(kind),
                        ...(_rows[kind] ?? []).map((r) => _tile(kind, r)),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text('Добавить'),
                            onPressed: () => _edit(kind),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _header(String kind) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Row(
          children: [
            Icon(_icons[kind], size: 18, color: AppTheme.primaryBlue),
            const SizedBox(width: 8),
            Expanded(
              child: Text(_titles[kind]!,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600)),
            ),
            Text('${(_rows[kind] ?? []).length}',
                style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );

  Widget _tile(String kind, PdExtraRow row) {
    final subtitle = <String>[];
    if (kind == 'penalties' && (row.data['reason'] ?? '').toString().isNotEmpty) {
      subtitle.add('${row.data['reason']}');
    }
    if (kind == 'debts' && row.data['period_date'] != null) {
      final period = '${row.data['period_date']}'.split('-');
      if (period.length >= 2) subtitle.add('${period[1]}.${period[0]}');
    }
    if (kind == 'requisites') {
      if ((row.data['bik'] ?? '').toString().isNotEmpty) {
        subtitle.add('БИК ${row.data['bik']}');
      }
      if ((row.data['account_number'] ?? '').toString().isNotEmpty) {
        subtitle.add('счёт ${row.data['account_number']}');
      }
    }
    final title = kind == 'debts'
        ? (_services[row.title] ?? row.title)
        : row.title;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontSize: 14)),
        subtitle: subtitle.isEmpty ? null : Text(subtitle.join(' · ')),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (row.amount != null)
              Text('${row.amount!.toStringAsFixed(2)} ₽',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') _edit(kind, row);
                if (value == 'delete') _delete(kind, row);
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Изменить')),
                PopupMenuItem(value: 'delete', child: Text('Удалить')),
              ],
            ),
          ],
        ),
        onTap: () => _edit(kind, row),
      ),
    );
  }

  Future<void> _edit(String kind, [PdExtraRow? row]) async {
    final amount = TextEditingController(
        text: row?.amount?.toString() ?? '');
    final reason =
        TextEditingController(text: '${row?.data['reason'] ?? ''}');
    final requisite = TextEditingController(
        text: '${row?.data['requisite_number'] ?? ''}');
    final number = TextEditingController(text: '${row?.data['number'] ?? ''}');
    final bik = TextEditingController(text: '${row?.data['bik'] ?? ''}');
    final account =
        TextEditingController(text: '${row?.data['account_number'] ?? ''}');
    var penaltyKind = '${row?.data['kind'] ?? _penaltyKinds.first}';
    var energyName = '${row?.data['name'] ?? _energyNames.first}';
    var service = '${row?.data['service'] ?? 'heating'}';
    DateTime? period = row?.data['period_date'] == null
        ? null
        : DateTime.tryParse('${row!.data['period_date']}');

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          title: Text(_titles[kind]!, style: const TextStyle(fontSize: 16)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (kind == 'penalties') ...[
                  DropdownButtonFormField<String>(
                    initialValue: penaltyKind,
                    isExpanded: true,
                    decoration:
                        const InputDecoration(labelText: 'Вид начисления *'),
                    items: [
                      for (final k in _penaltyKinds)
                        DropdownMenuItem(value: k, child: Text(k)),
                    ],
                    onChanged: (v) => setDialog(() => penaltyKind = v!),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: reason,
                    maxLines: 2,
                    decoration: const InputDecoration(
                        labelText: 'Основания начислений'),
                  ),
                ],
                if (kind == 'debts') ...[
                  DropdownButtonFormField<String>(
                    initialValue: service,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Услуга *'),
                    items: [
                      for (final e in _services.entries)
                        DropdownMenuItem(value: e.key, child: Text(e.value)),
                    ],
                    onChanged: (v) => setDialog(() => service = v!),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Период задолженности *',
                        style: TextStyle(fontSize: 14)),
                    subtitle: Text(period == null
                        ? 'не указан'
                        : '${period!.month.toString().padLeft(2, '0')}.'
                            '${period!.year}'),
                    trailing: const Icon(Icons.calendar_today, size: 18),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: period ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        // Период — всегда первое число месяца.
                        setDialog(() =>
                            period = DateTime(picked.year, picked.month, 1));
                      }
                    },
                  ),
                ],
                if (kind == 'energy')
                  DropdownButtonFormField<String>(
                    initialValue: energyName,
                    isExpanded: true,
                    decoration: const InputDecoration(
                        labelText: 'Наименование составляющей *'),
                    items: [
                      for (final n in _energyNames)
                        DropdownMenuItem(
                          value: n,
                          child:
                              Text(n, style: const TextStyle(fontSize: 12)),
                        ),
                    ],
                    onChanged: (v) => setDialog(() => energyName = v!),
                  ),
                if (kind == 'requisites') ...[
                  TextField(
                    controller: number,
                    decoration: const InputDecoration(
                      labelText: 'Номер реквизита *',
                      helperText: 'По нему услуги связываются со счётом',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: bik,
                    decoration: const InputDecoration(labelText: 'БИК банка'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: account,
                    decoration:
                        const InputDecoration(labelText: 'Расчётный счёт'),
                  ),
                ],
                const SizedBox(height: 8),
                TextField(
                  controller: amount,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: kind == 'requisites'
                        ? 'Сумма к оплате, ₽'
                        : 'Сумма, ₽ *',
                  ),
                ),
                if (kind != 'requisites' && kind != 'energy') ...[
                  const SizedBox(height: 8),
                  TextField(
                    controller: requisite,
                    decoration: const InputDecoration(
                        labelText: 'Номер платёжного реквизита'),
                  ),
                ],
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

    final value = double.tryParse(amount.text.replaceAll(',', '.'));
    if (kind == 'debts' && period == null) {
      _toast('Укажите период задолженности', error: true);
      return;
    }
    if (kind == 'requisites' && number.text.trim().isEmpty) {
      _toast('Укажите номер реквизита', error: true);
      return;
    }
    if (kind != 'requisites' && value == null) {
      _toast('Укажите сумму', error: true);
      return;
    }

    final data = <String, dynamic>{
      if (kind == 'penalties') ...{
        'kind': penaltyKind,
        if (reason.text.trim().isNotEmpty) 'reason': reason.text.trim(),
        'amount': value,
      },
      if (kind == 'debts') ...{
        'service': service,
        'period_date': period!.toIso8601String().split('T').first,
        'amount': value,
      },
      if (kind == 'energy') ...{'name': energyName, 'amount': value},
      if (kind == 'requisites') ...{
        'number': number.text.trim(),
        if (bik.text.trim().isNotEmpty) 'bik': bik.text.trim(),
        if (account.text.trim().isNotEmpty)
          'account_number': account.text.trim(),
        'amount': ?value,
      },
      if (kind == 'penalties' || kind == 'debts')
        if (requisite.text.trim().isNotEmpty)
          'requisite_number': requisite.text.trim(),
    };

    try {
      final api = ref.read(gisDetailsServiceProvider);
      if (row?.id == null) {
        await api.createPdRow(kind, widget.documentId, data);
      } else {
        await api.updatePdRow(kind, row!.id!, data);
      }
      await _load();
      _toast('Сохранено');
    } catch (e) {
      _toast(_message(e), error: true);
    }
  }

  Future<void> _delete(String kind, PdExtraRow row) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Удалить «${row.title}»?'),
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
    if (ok != true) return;
    try {
      await ref.read(gisDetailsServiceProvider).deletePdRow(kind, row.id!);
      await _load();
      _toast('Удалено');
    } catch (e) {
      _toast(_message(e), error: true);
    }
  }
}
