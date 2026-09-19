import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/base_api_service.dart';

/// Экран уведомлений о задолженности — аналог uved.prg / UVEDTO.DBF из FoxPro.
/// Формирование, массовое создание и управление уведомлениями должникам.
class DebtNoticesScreen extends ConsumerStatefulWidget {
  const DebtNoticesScreen({super.key});

  @override
  ConsumerState<DebtNoticesScreen> createState() => _DebtNoticesScreenState();
}

class _DebtNoticesScreenState extends ConsumerState<DebtNoticesScreen> {
  List<Map<String, dynamic>> _notices = [];
  bool _isLoading = true;
  String? _error;
  String? _filterType;
  String? _filterStatus;

  static const Map<String, String> typeLabels = {
    'warning': 'Предупреждение',
    'pretrial': 'Досудебная',
    'court': 'Судебное',
  };
  static const Map<String, IconData> typeIcons = {
    'warning': Icons.warning_amber,
    'pretrial': Icons.gavel,
    'court': Icons.balance,
  };
  static const Map<String, Color> typeColors = {
    'warning': Colors.orange,
    'pretrial': Colors.red,
    'court': Colors.deepPurple,
  };
  static const Map<String, String> statusLabels = {
    'draft': 'Черновик',
    'sent': 'Отправлено',
    'delivered': 'Доставлено',
    'returned': 'Возвращено',
  };
  static const Map<String, Color> statusColors = {
    'draft': Colors.grey,
    'sent': Colors.blue,
    'delivered': Colors.green,
    'returned': Colors.red,
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
      if (_filterType != null) params['notice_type'] = _filterType;
      if (_filterStatus != null) params['status'] = _filterStatus;
      final resp = await dio.get('/debt-notices/', queryParameters: params);
      if (resp.statusCode == 200) {
        setState(() => _notices = (resp.data as List).cast<Map<String, dynamic>>());
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
        title: const Text('Уведомления о задолженности'),
        actions: [
          IconButton(icon: const Icon(Icons.flash_on), tooltip: 'Массовое формирование', onPressed: _massCreate),
          IconButton(icon: const Icon(Icons.add_circle_outline), tooltip: 'Создать', onPressed: () => _edit(null)),
        ],
      ),
      body: Column(
        children: [
          // Фильтры
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              children: [
                _typeChip(null, 'Все', Icons.grid_view),
                ...typeLabels.entries.map((e) => _typeChip(e.key, e.value, typeIcons[e.key]!)),
                const SizedBox(width: 12),
                ...statusLabels.entries.map((e) => _statusChip(e.key, e.value)),
              ],
            ),
          ),
          Expanded(child: _buildBody(theme)),
        ],
      ),
    );
  }

  Widget _typeChip(String? type, String label, IconData icon) {
    final selected = _filterType == type;
    final color = type != null ? (typeColors[type] ?? Colors.grey) : Colors.blue;
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

  Widget _statusChip(String status, String label) {
    final selected = _filterStatus == status;
    final color = statusColors[status] ?? Colors.grey;
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: FilterChip(
        selected: selected,
        label: Text(label, style: TextStyle(fontSize: 10, color: selected ? Colors.white : color)),
        selectedColor: color,
        onSelected: (_) { setState(() => _filterStatus = selected ? null : status); _load(); },
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
    if (_notices.isEmpty) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.mark_email_read, size: 64, color: Colors.grey.shade400),
      const SizedBox(height: 12),
      const Text('Нет уведомлений', style: TextStyle(fontSize: 16, color: Colors.grey)),
      const SizedBox(height: 12),
      FilledButton.icon(onPressed: _massCreate, icon: const Icon(Icons.flash_on), label: const Text('Массовое формирование')),
    ]));

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _notices.length,
        itemBuilder: (_, i) => _card(_notices[i], theme),
      ),
    );
  }

  Widget _card(Map<String, dynamic> n, ThemeData theme) {
    final type = n['notice_type'] as String? ?? 'warning';
    final status = n['status'] as String? ?? 'draft';
    final color = typeColors[type] ?? Colors.grey;
    final stColor = statusColors[status] ?? Colors.grey;
    final icon = typeIcons[type] ?? Icons.mail;
    final debt = (n['debt_amount'] as num?)?.toDouble() ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: color.withAlpha(60))),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withAlpha(30), child: Icon(icon, size: 22, color: color)),
        title: Row(children: [
          Expanded(child: Text('${n['fio'] ?? 'Без ФИО'}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis)),
          Text('${debt.toStringAsFixed(2)} ₽', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.red.shade700)),
        ]),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ЛС: ${n['account_number'] ?? ''} • ${n['address'] ?? ''}',
              style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 3),
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(color: color.withAlpha(30), borderRadius: BorderRadius.circular(4)),
                child: Text(n['notice_type_label'] ?? type, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(color: stColor.withAlpha(30), borderRadius: BorderRadius.circular(4)),
                child: Text(n['status_label'] ?? status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: stColor)),
              ),
              const Spacer(),
              Text(n['issued_date'] ?? '', style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant)),
            ]),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (v) {
            if (v == 'edit') _edit(n);
            if (v == 'send') _updateStatus(n['id'] as int, 'sent');
            if (v == 'delete') _delete(n['id'] as int);
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit, size: 20), title: Text('Редактировать'))),
            if (status == 'draft')
              const PopupMenuItem(value: 'send', child: ListTile(leading: Icon(Icons.send, size: 20, color: Colors.blue), title: Text('Отметить отправленным'))),
            const PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete, size: 20, color: Colors.red), title: Text('Удалить'))),
          ],
        ),
        onTap: () => _edit(n),
      ),
    );
  }

  Future<void> _massCreate() async {
    DateTime period = DateTime(DateTime.now().year, DateTime.now().month, 1);
    String noticeType = 'warning';
    final minDebtCtrl = TextEditingController(text: '100');

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, ss) => AlertDialog(
          icon: const Icon(Icons.flash_on, size: 48, color: Colors.orange),
          title: const Text('Массовое формирование'),
          content: SizedBox(
            width: 380,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('Будут созданы уведомления для всех должников за выбранный период.', style: TextStyle(fontSize: 13)),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final d = await showDatePicker(context: ctx, initialDate: period, firstDate: DateTime(2020), lastDate: DateTime(2100));
                  if (d != null) ss(() => period = DateTime(d.year, d.month, 1));
                },
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Период', border: OutlineInputBorder(), isDense: true, prefixIcon: Icon(Icons.calendar_month, size: 20)),
                  child: Text(_formatPeriod(period)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(controller: minDebtCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Мин. долг (₽)', border: OutlineInputBorder(), isDense: true, prefixIcon: Icon(Icons.money_off, size: 20))),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: noticeType,
                decoration: const InputDecoration(labelText: 'Тип уведомления', border: OutlineInputBorder(), isDense: true, prefixIcon: Icon(Icons.mail, size: 20)),
                items: typeLabels.entries.map((e) => DropdownMenuItem(value: e.key, child: Row(children: [
                  Icon(typeIcons[e.key], size: 18, color: typeColors[e.key]),
                  const SizedBox(width: 8), Text(e.value),
                ]))).toList(),
                onChanged: (v) => ss(() => noticeType = v!),
              ),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
            FilledButton.icon(
              onPressed: () => Navigator.pop(ctx, true),
              icon: const Icon(Icons.flash_on),
              label: const Text('Сформировать'),
            ),
          ],
        ),
      ),
    );
    if (result != true) return;

    try {
      final dio = ref.read(dioProvider);
      final resp = await dio.post('/debt-notices/mass-create', data: {
        'period_date': period.toIso8601String().substring(0, 10),
        'min_debt': double.tryParse(minDebtCtrl.text) ?? 100,
        'notice_type': noticeType,
      });
      if (mounted) {
        final created = resp.data?['created'] ?? 0;
        final total = resp.data?['total_debt'] ?? 0;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('✅ Создано $created уведомлений на сумму ${total.toStringAsFixed(2)} ₽'),
          backgroundColor: Colors.green,
        ));
      }
      _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ $e'), backgroundColor: Colors.red));
    }
  }

  String _formatPeriod(DateTime d) {
    const months = ['', 'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь', 'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь'];
    return '${months[d.month]} ${d.year}';
  }

  Future<void> _edit(Map<String, dynamic>? existing) async {
    final isNew = existing == null;
    String noticeType = (existing?['notice_type'] as String?) ?? 'warning';
    final debtCtrl = TextEditingController(text: existing?['debt_amount']?.toString() ?? '');
    final noteCtrl = TextEditingController(text: existing?['note'] ?? '');
    int? accountId = existing?['account_id'] as int?;
    String accountLabel = existing != null ? '${existing['fio'] ?? ''} (ЛС: ${existing['account_number'] ?? ''})' : 'Выберите ЛС';

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, ss) => AlertDialog(
          title: Text(isNew ? '📬 Новое уведомление' : '✏️ Редактирование'),
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
              ],
              TextField(controller: debtCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Сумма задолженности *', border: OutlineInputBorder(), isDense: true, prefixIcon: Icon(Icons.money_off, size: 20), suffixText: '₽')),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: noticeType,
                decoration: const InputDecoration(labelText: 'Тип', border: OutlineInputBorder(), isDense: true),
                items: typeLabels.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
                onChanged: (v) => ss(() => noticeType = v!),
              ),
              const SizedBox(height: 12),
              TextField(controller: noteCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Текст / примечание', border: OutlineInputBorder(), isDense: true)),
            ])),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(isNew ? 'Создать' : 'Сохранить')),
          ],
        ),
      ),
    );
    if (result != true) return;
    if (isNew && accountId == null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('❌ Выберите ЛС'), backgroundColor: Colors.red));
      return;
    }

    try {
      final dio = ref.read(dioProvider);
      if (isNew) {
        await dio.post('/debt-notices/', data: {
          'account_id': accountId,
          'debt_amount': double.tryParse(debtCtrl.text) ?? 0,
          'notice_type': noticeType,
          'issued_date': DateTime.now().toIso8601String().substring(0, 10),
          'note': noteCtrl.text.isEmpty ? null : noteCtrl.text,
        });
      } else {
        await dio.put('/debt-notices/${existing['id']}', data: {
          'notice_type': noticeType,
          'note': noteCtrl.text.isEmpty ? null : noteCtrl.text,
        });
      }
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isNew ? '✅ Уведомление создано' : '✅ Обновлено'), backgroundColor: Colors.green));
      _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _updateStatus(int id, String status) async {
    try {
      final dio = ref.read(dioProvider);
      await dio.put('/debt-notices/$id', data: {
        'status': status,
        if (status == 'sent') 'sent_date': DateTime.now().toIso8601String().substring(0, 10),
      });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ Статус: ${statusLabels[status] ?? status}'), backgroundColor: Colors.green));
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
      title: const Text('Удалить уведомление?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), style: FilledButton.styleFrom(backgroundColor: Colors.red), child: const Text('Удалить')),
      ],
    ));
    if (ok != true) return;
    try {
      final dio = ref.read(dioProvider);
      await dio.delete('/debt-notices/$id');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🗑 Удалено')));
      _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ $e'), backgroundColor: Colors.red));
    }
  }
}
