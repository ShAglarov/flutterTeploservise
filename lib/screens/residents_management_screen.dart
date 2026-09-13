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
            if (r['promise_to_pay'] == true)
              Text('🤝 Обещание оплатить${r['promise_date'] != null ? ' до ${r['promise_date']}' : ''}', style: TextStyle(fontSize: 11, color: Colors.orange[700], fontWeight: FontWeight.w600)),
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

    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      builder: (ctx) => _ResidentEditDialog(
        isNew: isNew,
        usernameCtrl: usernameCtrl,
        emailCtrl: emailCtrl,
        passwordCtrl: passwordCtrl,
        lastNameCtrl: lastNameCtrl,
        firstNameCtrl: firstNameCtrl,
        middleNameCtrl: middleNameCtrl,
        phoneCtrl: phoneCtrl,
        addressCtrl: addressCtrl,
        apartmentCtrl: apartmentCtrl,
        accountCtrl: accountCtrl,
        notesCtrl: notesCtrl,
        dio: ref.read(dioProvider),
        initialPromiseToPay: existing?['promise_to_pay'] == true,
        initialPromiseDate: existing?['promise_date']?.toString(),
      ),
    );

    if (result == null) return;

    try {
      final dio = ref.read(dioProvider);
      final promiseData = {
        'promise_to_pay': result['promise_to_pay'] ?? false,
        if (result['promise_date'] != null) 'promise_date': result['promise_date'],
      };
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
          ...promiseData,
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
          ...promiseData,
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

/// Диалог редактирования жильца с выбором дома/квартиры из списка
class _ResidentEditDialog extends StatefulWidget {
  final bool isNew;
  final TextEditingController usernameCtrl, emailCtrl, passwordCtrl;
  final TextEditingController lastNameCtrl, firstNameCtrl, middleNameCtrl;
  final TextEditingController phoneCtrl, addressCtrl, apartmentCtrl;
  final TextEditingController accountCtrl, notesCtrl;
  final dynamic dio;
  final bool initialPromiseToPay;
  final String? initialPromiseDate;

  const _ResidentEditDialog({
    required this.isNew,
    required this.usernameCtrl, required this.emailCtrl, required this.passwordCtrl,
    required this.lastNameCtrl, required this.firstNameCtrl, required this.middleNameCtrl,
    required this.phoneCtrl, required this.addressCtrl, required this.apartmentCtrl,
    required this.accountCtrl, required this.notesCtrl,
    required this.dio,
    this.initialPromiseToPay = false,
    this.initialPromiseDate,
  });

  @override
  State<_ResidentEditDialog> createState() => _ResidentEditDialogState();
}

class _ResidentEditDialogState extends State<_ResidentEditDialog> {
  List<Map<String, dynamic>> _locations = [];
  List<String> _apartments = [];
  Map<String, String> _aptAccountMap = {}; // кв → лицевой счёт
  int? _selectedLocationId;
  String? _selectedApartment;
  bool _loadingLocations = true;
  bool _loadingApartments = false;
  bool _manualAddress = false;
  late bool _promiseToPay;
  DateTime? _promiseDate;

  @override
  void initState() {
    super.initState();
    _promiseToPay = widget.initialPromiseToPay;
    if (widget.initialPromiseDate != null) {
      _promiseDate = DateTime.tryParse(widget.initialPromiseDate!);
    }
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    try {
      final resp = await widget.dio.get('/payment-documents/locations');
      if (resp.statusCode == 200) {
        _locations = (resp.data as List).cast<Map<String, dynamic>>();

        // Если есть текущий адрес — пробуем найти совпадение
        final currentAddr = widget.addressCtrl.text;
        if (currentAddr.isNotEmpty) {
          for (final loc in _locations) {
            final name = (loc['name'] ?? '').toString();
            if (currentAddr.contains(name) || name.contains(currentAddr)) {
              _selectedLocationId = loc['id'];
              await _loadApartments(loc['id']);
              // Пробуем найти квартиру
              final currentApt = widget.apartmentCtrl.text;
              if (currentApt.isNotEmpty && _apartments.contains(currentApt)) {
                _selectedApartment = currentApt;
              }
              break;
            }
          }
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _loadingLocations = false);
  }

  Future<void> _loadApartments(int locationId) async {
    setState(() { _loadingApartments = true; _apartments = []; _aptAccountMap = {}; _selectedApartment = null; });
    try {
      final resp = await widget.dio.get('/payment-documents/', queryParameters: {
        'location_id': locationId,
        'limit': 1000,
        'sort_by': 'apartment',
        'sort_order': 'asc',
      });
      if (resp.statusCode == 200) {
        final docs = resp.data['items'] as List? ?? resp.data as List? ?? [];
        final aptSet = <String>{};
        final aptAccMap = <String, String>{};
        for (final d in docs) {
          final addr = (d['address'] ?? '').toString();
          final accNum = (d['account_number'] ?? '').toString();
          // Извлечь квартиру из адреса "ул. X, д. Y, кв. Z"
          final match = RegExp(r'кв\.\s*(\S+)').firstMatch(addr);
          if (match != null) {
            final apt = match.group(1)!;
            aptSet.add(apt);
            if (accNum.isNotEmpty) aptAccMap[apt] = accNum;
          }
        }
        _apartments = aptSet.toList()
          ..sort((a, b) {
            final na = int.tryParse(a) ?? 0;
            final nb = int.tryParse(b) ?? 0;
            if (na != 0 && nb != 0) return na.compareTo(nb);
            return a.compareTo(b);
          });
        _aptAccountMap = aptAccMap;
      }
    } catch (_) {}
    if (mounted) setState(() => _loadingApartments = false);
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon, {bool obscure = false, int maxLines = 1}) {
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isNew ? '👤 Новый жилец' : '✏️ Редактирование'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.isNew) ...[
                _field(widget.usernameCtrl, 'Логин *', Icons.person),
                _field(widget.emailCtrl, 'Email *', Icons.email),
                _field(widget.passwordCtrl, 'Пароль *', Icons.lock, obscure: true),
                const Divider(),
              ],
              _field(widget.lastNameCtrl, 'Фамилия', Icons.badge),
              _field(widget.firstNameCtrl, 'Имя', Icons.badge_outlined),
              _field(widget.middleNameCtrl, 'Отчество', Icons.badge_outlined),
              const Divider(),
              _field(widget.phoneCtrl, 'Телефон', Icons.phone),

              // Адрес — выбор дома
              if (_manualAddress) ...[
                _field(widget.addressCtrl, 'Адрес (вручную)', Icons.home),
                _field(widget.apartmentCtrl, 'Квартира (вручную)', Icons.door_front_door),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    icon: const Icon(Icons.list, size: 16),
                    label: const Text('Выбрать из списка', style: TextStyle(fontSize: 12)),
                    onPressed: () => setState(() => _manualAddress = false),
                  ),
                ),
              ] else ...[
                // Выбор дома
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _loadingLocations
                      ? const LinearProgressIndicator()
                      : DropdownButtonFormField<int>(
                          value: _selectedLocationId,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: '🏠 Дом',
                            prefixIcon: Icon(Icons.home, size: 20),
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          items: _locations.map((loc) => DropdownMenuItem<int>(
                            value: loc['id'] as int,
                            child: Text(loc['name']?.toString() ?? '', overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13)),
                          )).toList(),
                          onChanged: (v) {
                            if (v == null) return;
                            _selectedLocationId = v;
                            final name = _locations.firstWhere((l) => l['id'] == v)['name']?.toString() ?? '';
                            widget.addressCtrl.text = name;
                            _loadApartments(v);
                          },
                        ),
                ),
                // Выбор квартиры
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _loadingApartments
                      ? const LinearProgressIndicator()
                      : _apartments.isEmpty
                          ? _field(widget.apartmentCtrl, 'Квартира', Icons.door_front_door)
                          : DropdownButtonFormField<String>(
                              value: _selectedApartment,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: '🚪 Квартира',
                                prefixIcon: Icon(Icons.door_front_door, size: 20),
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              items: _apartments.map((apt) => DropdownMenuItem<String>(
                                value: apt,
                                child: Text('кв. $apt', style: const TextStyle(fontSize: 13)),
                              )).toList(),
                              onChanged: (v) {
                                if (v == null) return;
                                setState(() => _selectedApartment = v);
                                widget.apartmentCtrl.text = v;
                                // Автозаполнение лицевого счёта
                                final acc = _aptAccountMap[v];
                                if (acc != null && acc.isNotEmpty) {
                                  widget.accountCtrl.text = acc;
                                }
                              },
                            ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Ввести вручную', style: TextStyle(fontSize: 12)),
                    onPressed: () => setState(() => _manualAddress = true),
                  ),
                ),
              ],

              _field(widget.accountCtrl, 'Лицевой счёт', Icons.receipt),
              const Divider(),
              // Обещание оплатить
              SwitchListTile(
                title: const Text('🤝 Обещание оплатить', style: TextStyle(fontSize: 14)),
                value: _promiseToPay,
                dense: true,
                contentPadding: EdgeInsets.zero,
                onChanged: (v) => setState(() => _promiseToPay = v),
              ),
              if (_promiseToPay)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _promiseDate ?? DateTime.now().add(const Duration(days: 7)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) setState(() => _promiseDate = picked);
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: '📅 До какого числа',
                        prefixIcon: Icon(Icons.calendar_today, size: 20),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      child: Text(
                        _promiseDate != null
                            ? '${_promiseDate!.day.toString().padLeft(2, '0')}.${_promiseDate!.month.toString().padLeft(2, '0')}.${_promiseDate!.year}'
                            : 'Выберите дату',
                        style: TextStyle(fontSize: 14, color: _promiseDate != null ? null : Colors.grey),
                      ),
                    ),
                  ),
                ),
              const Divider(),
              _field(widget.notesCtrl, 'Заметки', Icons.note, maxLines: 2),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
        FilledButton(
          onPressed: () => Navigator.pop(context, {
            'promise_to_pay': _promiseToPay,
            'promise_date': _promiseDate != null
                ? '${_promiseDate!.year}-${_promiseDate!.month.toString().padLeft(2, '0')}-${_promiseDate!.day.toString().padLeft(2, '0')}'
                : null,
          }),
          child: Text(widget.isNew ? 'Создать' : 'Сохранить'),
        ),
      ],
    );
  }
}
