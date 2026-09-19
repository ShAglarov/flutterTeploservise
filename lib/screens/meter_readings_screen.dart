import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/base_api_service.dart';

/// Экран показаний счётчиков — аналог pokas.SCX, BT12, BE9 из FoxPro.
/// Ввод и просмотр показаний приборов учёта (газ, электричество, вода).
class MeterReadingsScreen extends ConsumerStatefulWidget {
  const MeterReadingsScreen({super.key});

  @override
  ConsumerState<MeterReadingsScreen> createState() => _MeterReadingsScreenState();
}

class _MeterReadingsScreenState extends ConsumerState<MeterReadingsScreen> {
  List<Map<String, dynamic>> _readings = [];
  bool _isLoading = true;
  String? _error;
  String? _filterType;

  static const Map<String, String> meterLabels = {
    'gas': 'Газ',
    'electricity': 'Электричество',
    'hot_water': 'Горячая вода',
    'cold_water': 'Холодная вода',
  };
  static const Map<String, IconData> meterIcons = {
    'gas': Icons.local_fire_department,
    'electricity': Icons.bolt,
    'hot_water': Icons.water_drop,
    'cold_water': Icons.water,
  };
  static const Map<String, Color> meterColors = {
    'gas': Colors.orange,
    'electricity': Colors.amber,
    'hot_water': Colors.red,
    'cold_water': Colors.blue,
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final dio = ref.read(dioProvider);
      final params = <String, dynamic>{'limit': 500};
      if (_filterType != null) params['meter_type'] = _filterType;
      final resp = await dio.get('/meter-readings/', queryParameters: params);
      if (resp.statusCode == 200) {
        setState(() => _readings = (resp.data as List).cast<Map<String, dynamic>>());
      }
    } catch (e) {
      setState(() => _error = '$e');
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Показания счётчиков'),
        actions: [
          IconButton(icon: const Icon(Icons.add_circle_outline), tooltip: 'Внести показание', onPressed: () => _edit(null)),
        ],
      ),
      body: Column(
        children: [
          // Фильтр
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              children: [
                _chip(null, 'Все', Icons.grid_view),
                ...meterLabels.entries.map((e) => _chip(e.key, e.value, meterIcons[e.key]!)),
              ],
            ),
          ),
          Expanded(child: _buildBody(theme)),
        ],
      ),
    );
  }

  Widget _chip(String? type, String label, IconData icon) {
    final selected = _filterType == type;
    final color = type != null ? (meterColors[type] ?? Colors.grey) : Colors.blue;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        selected: selected,
        label: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: selected ? Colors.white : color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, color: selected ? Colors.white : null)),
        ]),
        selectedColor: color,
        onSelected: (_) { setState(() => _filterType = selected ? null : type); _load(); },
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.error_outline, size: 48, color: Colors.red),
      const SizedBox(height: 8), Text(_error!, style: const TextStyle(fontSize: 13)),
      const SizedBox(height: 12), FilledButton(onPressed: _load, child: const Text('Повторить')),
    ]));
    if (_readings.isEmpty) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.speed, size: 64, color: Colors.grey.shade400),
      const SizedBox(height: 12),
      const Text('Нет показаний', style: TextStyle(fontSize: 16, color: Colors.grey)),
      const SizedBox(height: 12),
      FilledButton.icon(onPressed: () => _edit(null), icon: const Icon(Icons.add), label: const Text('Внести показание')),
    ]));

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _readings.length,
        itemBuilder: (_, i) => _card(_readings[i], theme),
      ),
    );
  }

  Widget _card(Map<String, dynamic> r, ThemeData theme) {
    final type = r['meter_type'] as String? ?? '';
    final label = r['meter_type_label'] ?? meterLabels[type] ?? type;
    final color = meterColors[type] ?? Colors.grey;
    final icon = meterIcons[type] ?? Icons.speed;
    final consumption = (r['consumption'] as num?)?.toDouble();
    final amount = (r['amount'] as num?)?.toDouble();
    final current = (r['current_reading'] as num?)?.toDouble() ?? 0;
    final prev = (r['previous_reading'] as num?)?.toDouble();

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: color.withAlpha(60))),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Иконка типа
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: color.withAlpha(30), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, size: 22, color: color),
            ),
            const SizedBox(width: 12),
            // Основное
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: color)),
                  if (r['meter_number'] != null) ...[
                    const SizedBox(width: 6),
                    Text('№${r['meter_number']}', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ]),
                const SizedBox(height: 2),
                Text('${r['fio'] ?? ''} • ЛС: ${r['account_number'] ?? ''}',
                  style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text('Период: ${r['period_date'] ?? '?'}',
                  style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant)),
              ],
            )),
            const SizedBox(width: 8),
            // Показания и расход
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(current.toStringAsFixed(1), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color)),
                if (prev != null)
                  Text('пред: ${prev.toStringAsFixed(1)}', style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant)),
                if (consumption != null)
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(color: color.withAlpha(20), borderRadius: BorderRadius.circular(4)),
                    child: Text('расход: ${consumption.toStringAsFixed(1)}${amount != null ? ' (${amount.toStringAsFixed(2)}₽)' : ''}',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
                  ),
              ],
            ),
            PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'edit') _edit(r);
                if (v == 'delete') _delete(r['id'] as int);
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit, size: 20), title: Text('Редактировать'))),
                const PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete, size: 20, color: Colors.red), title: Text('Удалить'))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _edit(Map<String, dynamic>? existing) async {
    final isNew = existing == null;
    String meterType = (existing?['meter_type'] as String?) ?? 'gas';
    final currentCtrl = TextEditingController(text: existing?['current_reading']?.toString() ?? '');
    final prevCtrl = TextEditingController(text: existing?['previous_reading']?.toString() ?? '');
    final numberCtrl = TextEditingController(text: existing?['meter_number'] ?? '');
    final rateCtrl = TextEditingController(text: existing?['rate']?.toString() ?? '');
    final periodCtrl = TextEditingController(
      text: existing?['period_date'] ?? DateTime(DateTime.now().year, DateTime.now().month, 1).toIso8601String().substring(0, 10),
    );
    final noteCtrl = TextEditingController(text: existing?['note'] ?? '');
    int? accountId = existing?['account_id'] as int?;
    String accountLabel = existing != null ? '${existing['fio'] ?? ''} (ЛС: ${existing['account_number'] ?? ''})' : 'Выберите ЛС';

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, ss) => AlertDialog(
          title: Text(isNew ? '📊 Новое показание' : '✏️ Редактирование'),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
              if (isNew) ...[
                InkWell(
                  onTap: () => _pickAccount(ctx, (id, label) => ss(() { accountId = id; accountLabel = label; })),
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Лицевой счёт *', border: OutlineInputBorder(), isDense: true, prefixIcon: Icon(Icons.person, size: 20)),
                    child: Text(accountLabel, style: const TextStyle(fontSize: 14), overflow: TextOverflow.ellipsis),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: meterType,
                  decoration: const InputDecoration(labelText: 'Тип счётчика', border: OutlineInputBorder(), isDense: true, prefixIcon: Icon(Icons.speed, size: 20)),
                  items: meterLabels.entries.map((e) => DropdownMenuItem(value: e.key, child: Row(children: [
                    Icon(meterIcons[e.key], size: 18, color: meterColors[e.key]),
                    const SizedBox(width: 8), Text(e.value),
                  ]))).toList(),
                  onChanged: (v) => ss(() => meterType = v!),
                ),
                const SizedBox(height: 12),
              ],
              TextField(controller: periodCtrl, readOnly: true, onTap: () async {
                final d = await showDatePicker(context: ctx, initialDate: DateTime.tryParse(periodCtrl.text) ?? DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2100));
                if (d != null) periodCtrl.text = DateTime(d.year, d.month, 1).toIso8601String().substring(0, 10);
              }, decoration: const InputDecoration(labelText: 'Период', border: OutlineInputBorder(), isDense: true, prefixIcon: Icon(Icons.calendar_month, size: 20))),
              const SizedBox(height: 12),
              TextField(controller: numberCtrl, decoration: const InputDecoration(labelText: 'Номер прибора', border: OutlineInputBorder(), isDense: true, prefixIcon: Icon(Icons.tag, size: 20))),
              const SizedBox(height: 12),
              TextField(controller: prevCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Предыдущее показание', border: OutlineInputBorder(), isDense: true, prefixIcon: Icon(Icons.history, size: 20))),
              const SizedBox(height: 12),
              TextField(controller: currentCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Текущее показание *', border: OutlineInputBorder(), isDense: true, prefixIcon: Icon(Icons.speed, size: 20))),
              const SizedBox(height: 12),
              TextField(controller: rateCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Тариф (₽)', border: OutlineInputBorder(), isDense: true, prefixIcon: Icon(Icons.payments, size: 20))),
              const SizedBox(height: 12),
              TextField(controller: noteCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Примечание', border: OutlineInputBorder(), isDense: true)),
            ])),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(isNew ? 'Внести' : 'Сохранить')),
          ],
        ),
      ),
    );
    if (result != true) return;
    if (isNew && accountId == null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('❌ Выберите ЛС'), backgroundColor: Colors.red));
      return;
    }
    final currentVal = double.tryParse(currentCtrl.text);
    if (currentVal == null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('❌ Укажите текущее показание'), backgroundColor: Colors.red));
      return;
    }

    final body = <String, dynamic>{
      'current_reading': currentVal,
      'meter_number': numberCtrl.text.isEmpty ? null : numberCtrl.text,
      'note': noteCtrl.text.isEmpty ? null : noteCtrl.text,
    };
    if (prevCtrl.text.isNotEmpty) body['previous_reading'] = double.tryParse(prevCtrl.text);
    if (rateCtrl.text.isNotEmpty) body['rate'] = double.tryParse(rateCtrl.text);
    if (isNew) {
      body['account_id'] = accountId;
      body['meter_type'] = meterType;
      body['period_date'] = periodCtrl.text;
    }

    try {
      final dio = ref.read(dioProvider);
      if (isNew) {
        final resp = await dio.post('/meter-readings/', data: body);
        final consumption = resp.data?['consumption'];
        final amount = resp.data?['amount'];
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('✅ Показание внесено${consumption != null ? ' • Расход: $consumption' : ''}${amount != null ? ' • ${amount}₽' : ''}'),
          backgroundColor: Colors.green,
        ));
      } else {
        await dio.put('/meter-readings/${existing['id']}', data: body);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Обновлено'), backgroundColor: Colors.green));
      }
      _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _pickAccount(BuildContext ctx, void Function(int, String) onPick) async {
    try {
      final dio = ref.read(dioProvider);
      final resp = await dio.get('/accounts/', queryParameters: {'limit': 500});
      if (resp.statusCode != 200 || !ctx.mounted) return;
      final accounts = (resp.data as List).cast<Map<String, dynamic>>();
      final searchCtrl = TextEditingController();
      var filtered = accounts;
      await showDialog(context: ctx, builder: (dlg) => StatefulBuilder(builder: (dlg, ss) => AlertDialog(
        title: const Text('Выбор ЛС'),
        content: SizedBox(width: 400, height: 400, child: Column(children: [
          TextField(controller: searchCtrl, decoration: const InputDecoration(hintText: 'Поиск...', prefixIcon: Icon(Icons.search), isDense: true, border: OutlineInputBorder()), onChanged: (q) {
            ss(() => filtered = accounts.where((a) => '${a['fio']} ${a['account_number']} ${a['address']}'.toLowerCase().contains(q.toLowerCase())).toList());
          }),
          const SizedBox(height: 8),
          Expanded(child: ListView(children: filtered.map((a) => ListTile(
            dense: true,
            title: Text('${a['fio'] ?? ''} (ЛС: ${a['account_number'] ?? ''})', style: const TextStyle(fontSize: 13)),
            subtitle: Text(a['address'] ?? '', style: const TextStyle(fontSize: 11)),
            onTap: () { onPick(a['id'] as int, '${a['fio']} (ЛС: ${a['account_number']})'); Navigator.pop(dlg); },
          )).toList())),
        ])),
      )));
    } catch (_) {}
  }

  Future<void> _delete(int id) async {
    final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Удалить показание?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), style: FilledButton.styleFrom(backgroundColor: Colors.red), child: const Text('Удалить')),
      ],
    ));
    if (ok != true) return;
    try {
      final dio = ref.read(dioProvider);
      await dio.delete('/meter-readings/$id');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🗑 Удалено')));
      _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ $e'), backgroundColor: Colors.red));
    }
  }
}
