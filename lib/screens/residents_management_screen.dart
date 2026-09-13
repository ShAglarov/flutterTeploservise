import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/base_api_service.dart';

/// Экран управления жильцами — список, создание, редактирование, блокировка
class ResidentsManagementScreen extends ConsumerStatefulWidget {
  const ResidentsManagementScreen({super.key});

  @override
  ConsumerState<ResidentsManagementScreen> createState() => _ResidentsManagementScreenState();
}

class _ResidentsManagementScreenState extends ConsumerState<ResidentsManagementScreen> {
  List<Map<String, dynamic>> _residents = [];
  bool _isLoading = true;
  String? _error;
  final _searchCtrl = TextEditingController();
  Timer? _debounce;
  String _statusFilter = 'all'; // all, ACTIVE, BLOCKED

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final dio = ref.read(dioProvider);
      final params = <String, dynamic>{'limit': 500};
      if (_searchCtrl.text.trim().isNotEmpty) params['search'] = _searchCtrl.text.trim();
      if (_statusFilter != 'all') params['status'] = _statusFilter;

      final resp = await dio.get('/residents', queryParameters: params);
      if (resp.statusCode == 200) {
        setState(() => _residents = (resp.data as List).cast<Map<String, dynamic>>());
      }
    } catch (e) {
      setState(() => _error = '$e');
    }
    setState(() => _isLoading = false);
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Управление жильцами'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _editResident(null),
        icon: const Icon(Icons.person_add),
        label: const Text('Добавить'),
      ),
      body: Column(
        children: [
          // Поиск
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => _onSearchChanged(),
              decoration: InputDecoration(
                hintText: 'Поиск по ФИО, логину, адресу, Л/С...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchCtrl.clear(); _load(); })
                    : null,
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
          ),
          // Фильтры
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                _filterChip('Все', 'all'),
                const SizedBox(width: 6),
                _filterChip('Активные', 'ACTIVE'),
                const SizedBox(width: 6),
                _filterChip('Заблокированные', 'BLOCKED'),
                const Spacer(),
                Text('${_residents.length} чел.', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
              ],
            ),
          ),
          // Список
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 8),
                        Text('Ошибка: $_error', textAlign: TextAlign.center),
                        const SizedBox(height: 8),
                        FilledButton(onPressed: _load, child: const Text('Повторить')),
                      ]))
                    : _residents.isEmpty
                        ? const Center(child: Text('Нет жильцов', style: TextStyle(fontSize: 16)))
                        : RefreshIndicator(
                            onRefresh: _load,
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(8, 0, 8, 80),
                              itemCount: _residents.length,
                              itemBuilder: (ctx, i) => _buildCard(_residents[i]),
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String value) {
    final selected = _statusFilter == value;
    return FilterChip(
      label: Text(label, style: TextStyle(fontSize: 12)),
      selected: selected,
      onSelected: (_) {
        setState(() => _statusFilter = value);
        _load();
      },
    );
  }

  Widget _buildCard(Map<String, dynamic> r) {
    final fullName = r['full_name'] ?? r['username'] ?? '';
    final isBlocked = r['is_blocked'] == true;
    final isActive = r['is_active'] == true;
    final address = r['address'] ?? '';
    final apartment = r['apartment'] ?? '';
    final phone = r['phone_number'] ?? '';
    final account = r['account_number'] ?? '';
    final email = r['email'] ?? '';

    String subtitle = '';
    if (address.isNotEmpty || apartment.isNotEmpty) {
      subtitle = [address, if (apartment.isNotEmpty) 'кв. $apartment'].join(', ');
    }
    if (account.isNotEmpty) subtitle += subtitle.isNotEmpty ? ' | Л/С: $account' : 'Л/С: $account';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isBlocked ? const BorderSide(color: Colors.red, width: 1) : BorderSide.none,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: isBlocked ? Colors.red : !isActive ? Colors.grey : Colors.green,
          child: Icon(
            isBlocked ? Icons.block : Icons.person,
            color: Colors.white, size: 20,
          ),
        ),
        title: Row(
          children: [
            Expanded(child: Text(fullName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14), overflow: TextOverflow.ellipsis)),
            if (isBlocked) Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(6)),
              child: const Text('Заблокирован', style: TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (subtitle.isNotEmpty) Text(subtitle, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant), overflow: TextOverflow.ellipsis),
            if (phone.isNotEmpty) Text('📱 $phone', style: const TextStyle(fontSize: 11)),
            if (email.isNotEmpty) Text('✉️ $email', style: const TextStyle(fontSize: 11)),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (v) => _onAction(v, r),
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'edit', child: ListTile(dense: true, leading: Icon(Icons.edit), title: Text('Редактировать'))),
            if (!isBlocked)
              const PopupMenuItem(value: 'block', child: ListTile(dense: true, leading: Icon(Icons.block, color: Colors.red), title: Text('Заблокировать')))
            else
              const PopupMenuItem(value: 'unblock', child: ListTile(dense: true, leading: Icon(Icons.check_circle, color: Colors.green), title: Text('Разблокировать'))),
            const PopupMenuItem(value: 'password', child: ListTile(dense: true, leading: Icon(Icons.lock_reset), title: Text('Сменить пароль'))),
            const PopupMenuItem(value: 'delete', child: ListTile(dense: true, leading: Icon(Icons.delete, color: Colors.red), title: Text('Удалить'))),
          ],
        ),
        onTap: () => _editResident(r),
      ),
    );
  }

  void _onAction(String action, Map<String, dynamic> r) {
    final id = r['id'];
    switch (action) {
      case 'edit': _editResident(r); break;
      case 'block': _blockResident(id, true); break;
      case 'unblock': _blockResident(id, false); break;
      case 'password': _changePassword(id); break;
      case 'delete': _deleteResident(id, r['full_name'] ?? r['username']); break;
    }
  }

  Future<void> _editResident(Map<String, dynamic>? existing) async {
    final isNew = existing == null;
    final usernameCtrl = TextEditingController(text: existing?['username'] ?? '');
    final emailCtrl = TextEditingController(text: existing?['email'] ?? '');
    final passwordCtrl = TextEditingController();
    final lastNameCtrl = TextEditingController(text: existing?['last_name'] ?? '');
    final firstNameCtrl = TextEditingController(text: existing?['first_name'] ?? '');
    final middleNameCtrl = TextEditingController(text: existing?['middle_name'] ?? '');
    final phoneCtrl = TextEditingController(text: existing?['phone_number'] ?? '');
    final addressCtrl = TextEditingController(text: existing?['address'] ?? '');
    final apartmentCtrl = TextEditingController(text: existing?['apartment'] ?? '');
    final accountCtrl = TextEditingController(text: existing?['account_number'] ?? '');
    final notesCtrl = TextEditingController(text: existing?['notes'] ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isNew ? '👤 Новый жилец' : '✏️ Редактирование'),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isNew) ...[
                  _f(usernameCtrl, 'Логин *', Icons.person),
                  _f(emailCtrl, 'Email *', Icons.email),
                  _f(passwordCtrl, 'Пароль *', Icons.lock, obscure: true),
                  const Divider(),
                ],
                _f(lastNameCtrl, 'Фамилия', Icons.badge),
                _f(firstNameCtrl, 'Имя', Icons.badge_outlined),
                _f(middleNameCtrl, 'Отчество', Icons.badge_outlined),
                const Divider(),
                _f(phoneCtrl, 'Телефон', Icons.phone),
                _f(addressCtrl, 'Адрес', Icons.home),
                _f(apartmentCtrl, 'Квартира', Icons.door_front_door),
                _f(accountCtrl, 'Лицевой счёт', Icons.receipt),
                const Divider(),
                _f(notesCtrl, 'Заметки', Icons.note, maxLines: 2),
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

    try {
      final dio = ref.read(dioProvider);
      if (isNew) {
        await dio.post('/residents', data: {
          'username': usernameCtrl.text,
          'email': emailCtrl.text,
          'password': passwordCtrl.text,
          'last_name': lastNameCtrl.text,
          'first_name': firstNameCtrl.text,
          'middle_name': middleNameCtrl.text,
          'phone_number': phoneCtrl.text,
          'address': addressCtrl.text,
          'apartment': apartmentCtrl.text,
          'account_number': accountCtrl.text,
          'notes': notesCtrl.text,
        });
      } else {
        await dio.put('/residents/${existing['id']}', data: {
          'last_name': lastNameCtrl.text,
          'first_name': firstNameCtrl.text,
          'middle_name': middleNameCtrl.text,
          'phone_number': phoneCtrl.text,
          'address': addressCtrl.text,
          'apartment': apartmentCtrl.text,
          'account_number': accountCtrl.text,
          'notes': notesCtrl.text,
        });
      }
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Сохранено'), backgroundColor: Colors.green));
      _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ Ошибка: $e'), backgroundColor: Colors.red));
    }
  }

  Widget _f(TextEditingController ctrl, String label, IconData icon, {bool obscure = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: ctrl,
        obscureText: obscure,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }

  Future<void> _blockResident(int id, bool block) async {
    try {
      final dio = ref.read(dioProvider);
      await dio.post('/residents/$id/${block ? "block" : "unblock"}');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(block ? '🚫 Заблокирован' : '✅ Разблокирован'), backgroundColor: block ? Colors.red : Colors.green,
      ));
      _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _changePassword(int id) async {
    final ctrl = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('🔑 Сменить пароль'),
        content: TextField(
          controller: ctrl,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Новый пароль', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Сменить')),
        ],
      ),
    );
    if (result != true || ctrl.text.isEmpty) return;

    try {
      final dio = ref.read(dioProvider);
      await dio.post('/residents/$id/change-password', data: {'new_password': ctrl.text});
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Пароль изменён'), backgroundColor: Colors.green));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _deleteResident(int id, String name) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('🗑 Удалить жильца?'),
        content: Text('Удалить «$name»? Это действие нельзя отменить.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      final dio = ref.read(dioProvider);
      await dio.delete('/residents/$id');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🗑 Жилец удалён')));
      _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ $e'), backgroundColor: Colors.red));
    }
  }
}
