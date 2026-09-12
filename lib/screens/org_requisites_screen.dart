import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/base_api_service.dart';

/// Экран управления реквизитами организаций
class OrgRequisitesScreen extends ConsumerStatefulWidget {
  const OrgRequisitesScreen({super.key});

  @override
  ConsumerState<OrgRequisitesScreen> createState() => _OrgRequisitesScreenState();
}

class _OrgRequisitesScreenState extends ConsumerState<OrgRequisitesScreen> {
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final dio = ref.read(dioProvider);
      final resp = await dio.get('/org-requisites/');
      if (resp.statusCode == 200) {
        setState(() => _items = (resp.data as List).cast<Map<String, dynamic>>());
      }
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Реквизиты организаций'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _editRequisites(null),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(child: Text('Нет реквизитов', style: TextStyle(fontSize: 16)))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _items.length,
                    itemBuilder: (ctx, i) => _buildCard(_items[i]),
                  ),
                ),
    );
  }

  Widget _buildCard(Map<String, dynamic> item) {
    final isDefault = item['is_default'] == 1;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isDefault ? const BorderSide(color: Colors.green, width: 2) : BorderSide.none,
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isDefault ? Colors.green : Colors.blueGrey,
          child: Icon(isDefault ? Icons.star : Icons.business, color: Colors.white, size: 20),
        ),
        title: Text(item['org_name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          [
            if (item['bik'] != null && item['bik'] != '') 'БИК: ${item['bik']}',
            if (item['account_number'] != null && item['account_number'] != '') 'Р/с: ${item['account_number']}',
          ].join(' | '),
          style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (v) {
            if (v == 'edit') _editRequisites(item);
            if (v == 'default') _setDefault(item['id']);
            if (v == 'delete') _delete(item['id']);
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit), title: Text('Редактировать'))),
            if (!isDefault) const PopupMenuItem(value: 'default', child: ListTile(leading: Icon(Icons.star, color: Colors.green), title: Text('По умолчанию'))),
            const PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete, color: Colors.red), title: Text('Удалить'))),
          ],
        ),
        onTap: () => _editRequisites(item),
      ),
    );
  }

  Future<void> _editRequisites(Map<String, dynamic>? existing) async {
    final isNew = existing == null;
    final orgCtrl = TextEditingController(text: existing?['org_name'] ?? '');
    final bikCtrl = TextEditingController(text: existing?['bik'] ?? '');
    final accCtrl = TextEditingController(text: existing?['account_number'] ?? '');
    final innCtrl = TextEditingController(text: existing?['inn'] ?? '');
    final kppCtrl = TextEditingController(text: existing?['kpp'] ?? '');
    final bankCtrl = TextEditingController(text: existing?['bank_name'] ?? '');
    final corrCtrl = TextEditingController(text: existing?['corr_account'] ?? '');
    final dirTitleCtrl = TextEditingController(text: existing?['director_title'] ?? 'Генеральный директор');
    final dirNameCtrl = TextEditingController(text: existing?['director_name'] ?? '');
    final cityCtrl = TextEditingController(text: existing?['city'] ?? 'г. Махачкала');
    final phoneCtrl = TextEditingController(text: existing?['phone'] ?? '');
    final addrCtrl = TextEditingController(text: existing?['address'] ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isNew ? '➕ Новые реквизиты' : '✏️ Редактирование'),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _field(orgCtrl, 'Название организации *', Icons.business),
                _field(bikCtrl, 'БИК', Icons.numbers),
                _field(accCtrl, 'Расчётный счёт', Icons.account_balance),
                _field(innCtrl, 'ИНН', Icons.badge),
                _field(kppCtrl, 'КПП', Icons.badge_outlined),
                _field(bankCtrl, 'Название банка', Icons.account_balance_wallet),
                _field(corrCtrl, 'Корр. счёт', Icons.swap_horiz),
                const Divider(),
                _field(dirTitleCtrl, 'Должность руководителя', Icons.work),
                _field(dirNameCtrl, 'ФИО руководителя', Icons.person),
                _field(cityCtrl, 'Город', Icons.location_city),
                _field(phoneCtrl, 'Телефон', Icons.phone),
                _field(addrCtrl, 'Юр. адрес', Icons.home),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(isNew ? 'Создать' : 'Сохранить'),
          ),
        ],
      ),
    );

    if (result != true) return;

    final body = {
      'org_name': orgCtrl.text,
      'bik': bikCtrl.text,
      'account_number': accCtrl.text,
      'inn': innCtrl.text,
      'kpp': kppCtrl.text,
      'bank_name': bankCtrl.text,
      'corr_account': corrCtrl.text,
      'director_title': dirTitleCtrl.text,
      'director_name': dirNameCtrl.text,
      'city': cityCtrl.text,
      'phone': phoneCtrl.text,
      'address': addrCtrl.text,
    };

    try {
      final dio = ref.read(dioProvider);
      if (isNew) {
        await dio.post('/org-requisites/', data: body);
      } else {
        await dio.put('/org-requisites/${existing['id']}', data: body);
      }
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Сохранено'), backgroundColor: Colors.green));
      _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ Ошибка: $e'), backgroundColor: Colors.red));
    }
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }

  Future<void> _setDefault(int id) async {
    try {
      final dio = ref.read(dioProvider);
      await dio.put('/org-requisites/$id', data: {'is_default': 1});
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⭐ Установлено по умолчанию'), backgroundColor: Colors.green));
      _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _delete(int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить?'),
        content: const Text('Реквизиты будут удалены безвозвратно.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), style: FilledButton.styleFrom(backgroundColor: Colors.red), child: const Text('Удалить')),
        ],
      ),
    );
    if (ok != true) return;

    try {
      final dio = ref.read(dioProvider);
      await dio.delete('/org-requisites/$id');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🗑 Удалено')));
      _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ $e'), backgroundColor: Colors.red));
    }
  }
}
