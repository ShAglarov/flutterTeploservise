import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/base_api_service.dart';
import '../utils/app_theme.dart';

/// Экран управления субсидиями — аналог vvodapr / SUBSID.PRG из FoxPro.
/// Позволяет просматривать, создавать, редактировать и удалять субсидии абонентов.
class SubsidiesScreen extends ConsumerStatefulWidget {
  const SubsidiesScreen({super.key});

  @override
  ConsumerState<SubsidiesScreen> createState() => _SubsidiesScreenState();
}

class _SubsidiesScreenState extends ConsumerState<SubsidiesScreen> {
  List<Map<String, dynamic>> _items = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  String? _statusFilter;
  int _total = 0;

  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final dio = ref.read(dioProvider);
      final params = <String, dynamic>{'limit': 100};
      if (_searchQuery.isNotEmpty) params['search'] = _searchQuery;
      if (_statusFilter != null) params['status'] = _statusFilter;

      final resp = await dio.get('/subsidies/', queryParameters: params);
      final statsResp = await dio.get('/subsidies/stats');

      if (mounted) {
        setState(() {
          _items = List<Map<String, dynamic>>.from(resp.data['items']);
          _total = resp.data['total'];
          _stats = Map<String, dynamic>.from(statsResp.data);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _error = '$e'; _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Субсидии'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        icon: const Icon(Icons.add),
        label: const Text('Новая'),
        backgroundColor: Colors.indigo,
      ),
      body: Column(
        children: [
          // Статистика
          if (_stats.isNotEmpty && !_isLoading) _buildStatsBar(theme),

          // Поиск и фильтр
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Поиск по ФИО или Л/С...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      isDense: true,
                    ),
                    onSubmitted: (v) {
                      _searchQuery = v;
                      _load();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String?>(
                  icon: Icon(Icons.filter_list, color: _statusFilter != null ? Colors.indigo : null),
                  onSelected: (v) {
                    _statusFilter = v;
                    _load();
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: null, child: Text('Все статусы')),
                    const PopupMenuItem(value: 'assigned', child: Text('📋 Назначена')),
                    const PopupMenuItem(value: 'applied', child: Text('✅ Учтена')),
                    const PopupMenuItem(value: 'paid', child: Text('💰 Выплачена')),
                    const PopupMenuItem(value: 'cancelled', child: Text('❌ Отменена')),
                    const PopupMenuItem(value: 'expired', child: Text('⏰ Истекла')),
                  ],
                ),
              ],
            ),
          ),

          // Список
          Expanded(
            child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                ? Center(child: Text('Ошибка: $_error'))
                : _items.isEmpty
                  ? const Center(child: Text('Нет субсидий', style: TextStyle(color: Colors.grey)))
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: _items.length,
                        itemBuilder: (_, i) => _buildCard(_items[i], theme),
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBar(ThemeData theme) {
    final totalCount = _stats['total_count'] ?? 0;
    final totalAmount = (_stats['total_amount'] as num?)?.toDouble() ?? 0;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.indigo.shade700, Colors.indigo.shade500]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.monetization_on, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Всего: $totalCount субсидий', style: const TextStyle(color: Colors.white, fontSize: 13)),
              Text('${totalAmount.toStringAsFixed(2)} ₽', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> item, ThemeData theme) {
    final statusColors = {
      'assigned': Colors.blue,
      'applied': Colors.green,
      'paid': Colors.teal,
      'cancelled': Colors.red,
      'expired': Colors.grey,
    };
    final statusIcons = {
      'assigned': Icons.assignment,
      'applied': Icons.check_circle,
      'paid': Icons.payments,
      'cancelled': Icons.cancel,
      'expired': Icons.timer_off,
    };
    final color = statusColors[item['status']] ?? Colors.grey;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showEditDialog(item),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(statusIcons[item['status']] ?? Icons.help, color: color, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item['resident'] ?? 'Л/С: ${item['account_number']}',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item['status_label'] ?? item['status'] ?? '',
                      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _chipInfo(Icons.credit_card, item['account_number'] ?? '—'),
                  const SizedBox(width: 12),
                  _chipInfo(Icons.calendar_month, item['period_start'] ?? '—'),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  _chipInfo(Icons.account_balance, item['source_label'] ?? '—'),
                  const Spacer(),
                  Text(
                    '${(item['amount_total'] as num?)?.toStringAsFixed(2) ?? '0'} ₽',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
                  ),
                ],
              ),
              if (item['note'] != null && (item['note'] as String).isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(item['note'], style: TextStyle(fontSize: 11, color: Colors.grey.shade500), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _chipInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  // ─── Создание ───────────────────────────────────────────────────────────────

  void _showCreateDialog() {
    final accountIdCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    final incomeCtrl = TextEditingController();
    final membersCtrl = TextEditingController();
    String source = 'budget';
    DateTime periodStart = DateTime.now();

    // Amount by service
    final heatingCtrl = TextEditingController();
    final hotWaterCtrl = TextEditingController();
    final coldWaterCtrl = TextEditingController();
    final gasCtrl = TextEditingController();
    final electricityCtrl = TextEditingController();
    final wasteCtrl = TextEditingController();
    final maintenanceCtrl = TextEditingController();
    final sewerageCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          height: MediaQuery.of(ctx).size.height * 0.85,
          decoration: BoxDecoration(
            color: Theme.of(ctx).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(2)),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.monetization_on, color: Colors.indigo),
                    const SizedBox(width: 8),
                    const Text('Новая субсидия', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    TextButton(
                      onPressed: () async {
                        final accountId = int.tryParse(accountIdCtrl.text);
                        if (accountId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Укажите ID лицевого счёта')));
                          return;
                        }
                        try {
                          final dio = ref.read(dioProvider);
                          await dio.post('/subsidies/', data: {
                            'account_id': accountId,
                            'period_start': '${periodStart.year}-${periodStart.month.toString().padLeft(2, '0')}-01',
                            'amount_total': double.tryParse(amountCtrl.text) ?? 0,
                            'amount_heating': double.tryParse(heatingCtrl.text) ?? 0,
                            'amount_hot_water': double.tryParse(hotWaterCtrl.text) ?? 0,
                            'amount_cold_water': double.tryParse(coldWaterCtrl.text) ?? 0,
                            'amount_gas': double.tryParse(gasCtrl.text) ?? 0,
                            'amount_electricity': double.tryParse(electricityCtrl.text) ?? 0,
                            'amount_waste': double.tryParse(wasteCtrl.text) ?? 0,
                            'amount_maintenance': double.tryParse(maintenanceCtrl.text) ?? 0,
                            'amount_sewerage': double.tryParse(sewerageCtrl.text) ?? 0,
                            'source': source,
                            'family_income': double.tryParse(incomeCtrl.text),
                            'family_members': int.tryParse(membersCtrl.text),
                            'note': noteCtrl.text.isNotEmpty ? noteCtrl.text : null,
                          });
                          if (mounted) Navigator.pop(ctx);
                          _load();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('✅ Субсидия создана'), backgroundColor: Colors.green),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ $e'), backgroundColor: Colors.red));
                        }
                      },
                      child: const Text('Сохранить', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _formField(accountIdCtrl, 'ID лицевого счёта', Icons.credit_card, keyboard: TextInputType.number),
                    const SizedBox(height: 12),
                    // Период
                    ListTile(
                      leading: const Icon(Icons.calendar_month, color: Colors.indigo),
                      title: const Text('Период начала'),
                      subtitle: Text('${periodStart.year}-${periodStart.month.toString().padLeft(2, '0')}'),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: ctx, initialDate: periodStart,
                          firstDate: DateTime(2000), lastDate: DateTime(2100),
                        );
                        if (picked != null) setSheetState(() => periodStart = picked);
                      },
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      tileColor: Theme.of(ctx).colorScheme.surface,
                    ),
                    const SizedBox(height: 12),
                    _formField(amountCtrl, 'Общая сумма (₽)', Icons.monetization_on, keyboard: TextInputType.number),
                    const SizedBox(height: 16),
                    const Text('По услугам:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),
                    _formField(heatingCtrl, 'Отопление', Icons.whatshot, keyboard: TextInputType.number),
                    _formField(hotWaterCtrl, 'ГВС', Icons.hot_tub, keyboard: TextInputType.number),
                    _formField(coldWaterCtrl, 'ХВС', Icons.water_drop, keyboard: TextInputType.number),
                    _formField(gasCtrl, 'Газ', Icons.local_fire_department, keyboard: TextInputType.number),
                    _formField(electricityCtrl, 'Электричество', Icons.bolt, keyboard: TextInputType.number),
                    _formField(wasteCtrl, 'ТБО', Icons.delete, keyboard: TextInputType.number),
                    _formField(maintenanceCtrl, 'Содержание', Icons.build, keyboard: TextInputType.number),
                    _formField(sewerageCtrl, 'Канализация', Icons.plumbing, keyboard: TextInputType.number),
                    const SizedBox(height: 16),
                    // Источник
                    DropdownButtonFormField<String>(
                      value: source,
                      decoration: InputDecoration(
                        labelText: 'Источник',
                        prefixIcon: const Icon(Icons.account_balance),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'budget', child: Text('Бюджет')),
                        DropdownMenuItem(value: 'federal', child: Text('Федеральный')),
                        DropdownMenuItem(value: 'regional', child: Text('Региональный')),
                        DropdownMenuItem(value: 'municipal', child: Text('Муниципальный')),
                      ],
                      onChanged: (v) => setSheetState(() => source = v ?? 'budget'),
                    ),
                    const SizedBox(height: 12),
                    _formField(incomeCtrl, 'Доход семьи (₽)', Icons.trending_up, keyboard: TextInputType.number),
                    _formField(membersCtrl, 'Членов семьи', Icons.people, keyboard: TextInputType.number),
                    _formField(noteCtrl, 'Примечание', Icons.note),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Редактирование ─────────────────────────────────────────────────────────

  void _showEditDialog(Map<String, dynamic> item) {
    final amountCtrl = TextEditingController(text: '${item['amount_total'] ?? 0}');
    final noteCtrl = TextEditingController(text: item['note'] ?? '');
    String status = item['status'] ?? 'assigned';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          height: MediaQuery.of(ctx).size.height * 0.6,
          decoration: BoxDecoration(
            color: Theme.of(ctx).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(2)),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.edit, color: Colors.indigo),
                    const SizedBox(width: 8),
                    Expanded(child: Text('${item['resident'] ?? item['account_number']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: ctx,
                          builder: (c) => AlertDialog(
                            title: const Text('Удалить субсидию?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Нет')),
                              TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Да', style: TextStyle(color: Colors.red))),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          try {
                            final dio = ref.read(dioProvider);
                            await dio.delete('/subsidies/${item['id']}');
                            if (mounted) Navigator.pop(ctx);
                            _load();
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ $e')));
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _infoTile('Л/С', item['account_number'] ?? '—'),
                    _infoTile('Период', item['period_start'] ?? '—'),
                    _infoTile('Источник', item['source_label'] ?? '—'),
                    const Divider(),
                    _formField(amountCtrl, 'Сумма (₽)', Icons.monetization_on, keyboard: TextInputType.number),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: status,
                      decoration: InputDecoration(
                        labelText: 'Статус',
                        prefixIcon: const Icon(Icons.flag),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'assigned', child: Text('📋 Назначена')),
                        DropdownMenuItem(value: 'applied', child: Text('✅ Учтена')),
                        DropdownMenuItem(value: 'paid', child: Text('💰 Выплачена')),
                        DropdownMenuItem(value: 'cancelled', child: Text('❌ Отменена')),
                        DropdownMenuItem(value: 'expired', child: Text('⏰ Истекла')),
                      ],
                      onChanged: (v) => setSheetState(() => status = v ?? 'assigned'),
                    ),
                    const SizedBox(height: 12),
                    _formField(noteCtrl, 'Примечание', Icons.note),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            final dio = ref.read(dioProvider);
                            await dio.put('/subsidies/${item['id']}', data: {
                              'amount_total': double.tryParse(amountCtrl.text) ?? 0,
                              'status': status,
                              'note': noteCtrl.text.isNotEmpty ? noteCtrl.text : null,
                            });
                            if (mounted) Navigator.pop(ctx);
                            _load();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('✅ Обновлено'), backgroundColor: Colors.green),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ $e')));
                          }
                        },
                        icon: const Icon(Icons.save),
                        label: const Text('Сохранить'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _formField(TextEditingController ctrl, String label, IconData icon, {TextInputType keyboard = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: ctrl,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          isDense: true,
        ),
      ),
    );
  }
}
