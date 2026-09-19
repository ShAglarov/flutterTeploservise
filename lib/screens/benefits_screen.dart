import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/base_api_service.dart';

/// Экран управления льготами — аналог blgot, blgotn из FoxPro.
/// Позволяет просматривать, создавать, редактировать и удалять льготы абонентов.
class BenefitsScreen extends ConsumerStatefulWidget {
  const BenefitsScreen({super.key});

  @override
  ConsumerState<BenefitsScreen> createState() => _BenefitsScreenState();
}

class _BenefitsScreenState extends ConsumerState<BenefitsScreen> {
  List<Map<String, dynamic>> _benefits = [];
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;
  String? _error;
  String? _filterCategory;

  static const Map<String, IconData> categoryIcons = {
    'veteran': Icons.military_tech,
    'veteran_war': Icons.star,
    'disabled_1': Icons.accessible,
    'disabled_2': Icons.accessible,
    'disabled_3': Icons.accessible,
    'disabled_child': Icons.child_care,
    'large_family': Icons.family_restroom,
    'chernobyl': Icons.warning_amber,
    'repressed': Icons.gavel,
    'hero': Icons.emoji_events,
    'single_parent': Icons.person,
    'orphan': Icons.person_outline,
    'other': Icons.category,
  };

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _load();
  }

  Future<void> _loadCategories() async {
    try {
      final dio = ref.read(dioProvider);
      final resp = await dio.get('/benefits/categories');
      if (resp.statusCode == 200) {
        setState(() => _categories = (resp.data as List).cast<Map<String, dynamic>>());
      }
    } catch (_) {}
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final dio = ref.read(dioProvider);
      final params = <String, dynamic>{'limit': 500};
      if (_filterCategory != null) params['category'] = _filterCategory;
      final resp = await dio.get('/benefits/', queryParameters: params);
      if (resp.statusCode == 200) {
        setState(() => _benefits = (resp.data as List).cast<Map<String, dynamic>>());
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
        title: const Text('Льготы'),
        actions: [
          IconButton(icon: const Icon(Icons.add_circle_outline), tooltip: 'Добавить', onPressed: () => _edit(null)),
        ],
      ),
      body: Column(
        children: [
          // Фильтр по категории
          if (_categories.isNotEmpty)
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                children: [
                  _chip(null, 'Все', Icons.grid_view),
                  ..._categories.map((c) {
                    final code = c['code'] as String;
                    return _chip(code, c['label'] as String, categoryIcons[code] ?? Icons.category);
                  }),
                ],
              ),
            ),
          Expanded(child: _buildBody(theme)),
        ],
      ),
    );
  }

  Widget _chip(String? code, String label, IconData icon) {
    final selected = _filterCategory == code;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        selected: selected,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: selected ? Colors.white : Colors.grey),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 11, color: selected ? Colors.white : null)),
          ],
        ),
        selectedColor: Colors.teal,
        onSelected: (_) {
          setState(() => _filterCategory = selected ? null : code);
          _load();
        },
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.error_outline, size: 48, color: Colors.red),
      const SizedBox(height: 8),
      Text(_error!, style: const TextStyle(fontSize: 13)),
      const SizedBox(height: 12),
      FilledButton(onPressed: _load, child: const Text('Повторить')),
    ]));
    if (_benefits.isEmpty) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.card_giftcard, size: 64, color: Colors.grey.shade400),
      const SizedBox(height: 12),
      const Text('Нет льгот', style: TextStyle(fontSize: 16, color: Colors.grey)),
      const SizedBox(height: 12),
      FilledButton.icon(onPressed: () => _edit(null), icon: const Icon(Icons.add), label: const Text('Добавить')),
    ]));

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _benefits.length,
        itemBuilder: (_, i) => _card(_benefits[i], theme),
      ),
    );
  }

  Widget _card(Map<String, dynamic> b, ThemeData theme) {
    final cat = b['category'] as String? ?? '';
    final catLabel = b['category_label'] ?? cat;
    final pct = (b['discount_percent'] as num?)?.toDouble() ?? 0;
    final isActive = b['is_active'] == true;
    final icon = categoryIcons[cat] ?? Icons.category;

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isActive ? BorderSide(color: Colors.teal.withAlpha(80)) : BorderSide.none,
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isActive ? Colors.teal.withAlpha(30) : Colors.grey.withAlpha(30),
          child: Icon(icon, size: 22, color: isActive ? Colors.teal : Colors.grey),
        ),
        title: Text(catLabel, style: TextStyle(
          fontWeight: FontWeight.w600, fontSize: 14,
          color: isActive ? null : Colors.grey,
        )),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${b['fio'] ?? ''} • ЛС: ${b['account_number'] ?? ''}',
              style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
              maxLines: 1, overflow: TextOverflow.ellipsis,
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(color: Colors.teal.withAlpha(30), borderRadius: BorderRadius.circular(4)),
                  child: Text('${pct.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.teal)),
                ),
                const SizedBox(width: 6),
                Text(
                  'c ${b['effective_from'] ?? '?'}${b['effective_to'] != null ? ' по ${b['effective_to']}' : ''}',
                  style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
                ),
                if (!isActive) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(color: Colors.red.withAlpha(30), borderRadius: BorderRadius.circular(4)),
                    child: const Text('Неактивна', style: TextStyle(fontSize: 10, color: Colors.red)),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (v) {
            if (v == 'edit') _edit(b);
            if (v == 'delete') _delete(b['id'] as int);
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit, size: 20), title: Text('Редактировать'))),
            const PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete, size: 20, color: Colors.red), title: Text('Удалить'))),
          ],
        ),
        onTap: () => _edit(b),
      ),
    );
  }

  Future<void> _edit(Map<String, dynamic>? existing) async {
    final isNew = existing == null;
    String category = (existing?['category'] as String?) ?? 'veteran';
    final pctCtrl = TextEditingController(text: existing?['discount_percent']?.toString() ?? '50');
    final countCtrl = TextEditingController(text: existing?['beneficiaries_count']?.toString() ?? '1');
    final docNumCtrl = TextEditingController(text: existing?['document_number'] ?? '');
    final fromCtrl = TextEditingController(text: existing?['effective_from'] ?? DateTime.now().toIso8601String().substring(0, 10));
    final toCtrl = TextEditingController(text: existing?['effective_to'] ?? '');
    final noteCtrl = TextEditingController(text: existing?['note'] ?? '');
    // Для нового — нужно выбрать ЛС
    int? accountId = existing?['account_id'] as int?;
    String accountLabel = existing != null ? '${existing['fio'] ?? ''} (ЛС: ${existing['account_number'] ?? ''})' : 'Выберите ЛС';

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, ss) => AlertDialog(
          title: Text(isNew ? '➕ Новая льгота' : '✏️ Редактирование'),
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
              DropdownButtonFormField<String>(
                value: category,
                decoration: const InputDecoration(labelText: 'Категория', border: OutlineInputBorder(), isDense: true, prefixIcon: Icon(Icons.category, size: 20)),
                items: _categories.map((c) => DropdownMenuItem(value: c['code'] as String, child: Text(c['label'] as String, style: const TextStyle(fontSize: 14)))).toList(),
                onChanged: (v) => ss(() => category = v!),
              ),
              const SizedBox(height: 12),
              TextField(controller: pctCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Процент льготы (%)', border: OutlineInputBorder(), isDense: true, prefixIcon: Icon(Icons.percent, size: 20))),
              const SizedBox(height: 12),
              TextField(controller: countCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Кол-во льготников', border: OutlineInputBorder(), isDense: true, prefixIcon: Icon(Icons.people, size: 20))),
              const SizedBox(height: 12),
              TextField(controller: docNumCtrl, decoration: const InputDecoration(labelText: 'Номер документа', border: OutlineInputBorder(), isDense: true, prefixIcon: Icon(Icons.description, size: 20))),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: TextField(controller: fromCtrl, readOnly: true, onTap: () async {
                  final d = await showDatePicker(context: ctx, initialDate: DateTime.tryParse(fromCtrl.text) ?? DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
                  if (d != null) fromCtrl.text = d.toIso8601String().substring(0, 10);
                }, decoration: const InputDecoration(labelText: 'С', border: OutlineInputBorder(), isDense: true))),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: toCtrl, readOnly: true, onTap: () async {
                  final d = await showDatePicker(context: ctx, initialDate: DateTime.tryParse(toCtrl.text) ?? DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
                  if (d != null) toCtrl.text = d.toIso8601String().substring(0, 10);
                }, decoration: InputDecoration(labelText: 'По', border: const OutlineInputBorder(), isDense: true, hintText: 'Бессрочно', suffixIcon: toCtrl.text.isNotEmpty ? IconButton(icon: const Icon(Icons.clear, size: 16), onPressed: () => ss(() => toCtrl.clear())) : null))),
              ]),
              const SizedBox(height: 12),
              TextField(controller: noteCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Примечание', border: OutlineInputBorder(), isDense: true)),
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
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('❌ Выберите лицевой счёт'), backgroundColor: Colors.red));
      return;
    }

    final body = <String, dynamic>{
      'category': category,
      'discount_percent': double.tryParse(pctCtrl.text) ?? 50,
      'beneficiaries_count': int.tryParse(countCtrl.text) ?? 1,
      'document_number': docNumCtrl.text.isEmpty ? null : docNumCtrl.text,
      'effective_from': fromCtrl.text,
      'note': noteCtrl.text.isEmpty ? null : noteCtrl.text,
    };
    if (toCtrl.text.isNotEmpty) body['effective_to'] = toCtrl.text;
    if (isNew) body['account_id'] = accountId;

    try {
      final dio = ref.read(dioProvider);
      if (isNew) {
        await dio.post('/benefits/', data: body);
      } else {
        await dio.put('/benefits/${existing['id']}', data: body);
      }
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isNew ? '✅ Льгота создана' : '✅ Обновлено'), backgroundColor: Colors.green));
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
      title: const Text('Удалить льготу?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), style: FilledButton.styleFrom(backgroundColor: Colors.red), child: const Text('Удалить')),
      ],
    ));
    if (ok != true) return;
    try {
      final dio = ref.read(dioProvider);
      await dio.delete('/benefits/$id');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🗑 Удалено')));
      _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ $e'), backgroundColor: Colors.red));
    }
  }
}
