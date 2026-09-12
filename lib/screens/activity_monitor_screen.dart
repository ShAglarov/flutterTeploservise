import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/base_api_service.dart';
import 'package:file_picker/file_picker.dart';
import 'payment_documents_screen.dart';

/// Монитор активности жильцов — анализ платежной дисциплины
class ActivityMonitorScreen extends ConsumerStatefulWidget {
  const ActivityMonitorScreen({super.key});

  @override
  ConsumerState<ActivityMonitorScreen> createState() => _ActivityMonitorScreenState();
}

class _ActivityMonitorScreenState extends ConsumerState<ActivityMonitorScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic> _data = {};
  bool _isLoading = true;
  String? _error;
  final _searchController = TextEditingController();
  Timer? _searchDebounce;
  int? _locationId;

  final _tabs = [
    const Tab(icon: Icon(Icons.warning_amber), text: 'Злостные'),
    const Tab(icon: Icon(Icons.trending_down), text: 'Нерегулярные'),
    const Tab(icon: Icon(Icons.check_circle), text: 'Стабильные'),
    const Tab(icon: Icon(Icons.handshake), text: 'Обещали'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final dio = ref.read(dioProvider);
      final params = <String, dynamic>{};
      if (_locationId != null) params['location_id'] = _locationId;
      final q = _searchController.text.trim();
      if (q.isNotEmpty) params['search'] = q;

      final response = await dio.get('/activity-monitor/', queryParameters: params);
      if (response.statusCode == 200) {
        setState(() { _data = response.data as Map<String, dynamic>; _isLoading = false; });
      }
    } catch (e) {
      setState(() { _error = '$e'; _isLoading = false; });
    }
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) _loadData();
    });
  }

  Future<void> _exportPdf() async {
    final catKeys = ['all', 'chronic', 'irregular', 'stable', 'promised'];
    final currentTab = _tabController.index;
    final cat = currentTab == 0 ? 'chronic' : currentTab == 1 ? 'irregular' : currentTab == 2 ? 'stable' : 'promised';

    final defaultName = 'monitor_${cat}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    String? savePath;
    try {
      savePath = await FilePicker.platform.saveFile(dialogTitle: 'Сохранить PDF', fileName: defaultName);
    } catch (e) {
      try {
        final dir = await FilePicker.platform.getDirectoryPath(dialogTitle: 'Выберите папку');
        if (dir != null) savePath = '$dir/$defaultName';
      } catch (_) {
        savePath = '${Directory.systemTemp.parent.path}/Documents/$defaultName';
      }
    }
    if (savePath == null) return;

    try {
      final dio = ref.read(dioProvider);
      final params = <String, dynamic>{'category': cat};
      if (_locationId != null) params['location_id'] = _locationId;
      final q = _searchController.text.trim();
      if (q.isNotEmpty) params['search'] = q;

      final response = await dio.get(
        '/activity-monitor/export/pdf',
        queryParameters: params,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200) {
        final filePath = savePath.endsWith('.pdf') ? savePath : '$savePath.pdf';
        await File(filePath).writeAsBytes(response.data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ Сохранено: $filePath'), duration: const Duration(seconds: 5)));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ Ошибка: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Map<String, dynamic> get _summary => (_data['summary'] as Map<String, dynamic>?) ?? {};
  Map<String, dynamic> get _categories => (_data['categories'] as Map<String, dynamic>?) ?? {};

  List<Map<String, dynamic>> _getList(String key) {
    final list = _categories[key];
    if (list is List) return list.cast<Map<String, dynamic>>();
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Монитор активности'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Экспорт PDF',
            onPressed: _exportPdf,
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs,
          isScrollable: false,
          indicatorWeight: 3,
        ),
      ),
      body: Column(
        children: [
          // Поиск
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _onSearchChanged(),
              decoration: InputDecoration(
                hintText: 'Поиск по ФИО, Л/С, адресу, дом,кв...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchController.clear(); _loadData(); })
                    : null,
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
          ),

          // Сводка
          if (!_isLoading && _summary.isNotEmpty) _buildSummaryBar(theme),

          // Контент
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text('Ошибка: $_error', style: TextStyle(color: theme.colorScheme.error)))
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildList(_getList('chronic'), Colors.red, '😤'),
                          _buildList(_getList('irregular'), Colors.orange, '📉'),
                          _buildList(_getList('stable'), Colors.green, '✅'),
                          _buildList(_getList('promised'), Colors.blue, '🤝'),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBar(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _summaryItem('Всего', '${_summary['total_accounts'] ?? 0}', theme.colorScheme.onSurface),
          _summaryItem('Стабильные', '${_summary['stable_count'] ?? 0}', Colors.green),
          _summaryItem('Нерегулярные', '${_summary['irregular_count'] ?? 0}', Colors.orange),
          _summaryItem('Злостные', '${_summary['chronic_count'] ?? 0}', Colors.red),
          _summaryItem('Обещали', '${_summary['promised_count'] ?? 0}', Colors.blue),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(fontSize: 9, color: color.withValues(alpha: 0.8))),
      ],
    );
  }

  Widget _buildList(List<Map<String, dynamic>> items, Color color, String emoji) {
    if (items.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(emoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 8),
          Text('Нет записей', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
        ]),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        itemCount: items.length,
        itemBuilder: (context, index) => _buildResidentCard(items[index], color, emoji),
      ),
    );
  }

  Widget _buildResidentCard(Map<String, dynamic> item, Color color, String emoji) {
    final fio = item['fio'] ?? 'Не указано';
    final address = item['address'] ?? '';
    final debt = (item['current_debt'] as num?)?.toDouble() ?? 0;
    final payRatio = (item['pay_ratio'] as num?)?.toDouble() ?? 0;
    final totalPeriods = item['total_periods'] ?? 0;
    final paidPeriods = item['paid_periods'] ?? 0;
    final promises = (item['promises'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final hasPromise = item['has_active_promise'] == true;
    final accountId = item['account_id'] as int?;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: 0.3)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showResidentDetails(item, color),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(fio, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14), overflow: TextOverflow.ellipsis),
                        Text(address, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant), overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  // Долг
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${debt.toStringAsFixed(0)} ₽',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: debt > 0 ? Colors.red : Colors.green),
                      ),
                      Text('$paidPeriods/$totalPeriods опл.', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Прогресс бар оплаты
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: payRatio / 100,
                  backgroundColor: Colors.grey.shade300,
                  color: payRatio >= 70 ? Colors.green : payRatio >= 30 ? Colors.orange : Colors.red,
                  minHeight: 4,
                ),
              ),
              if (hasPromise) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.handshake, size: 14, color: Colors.blue),
                    const SizedBox(width: 4),
                    Text(
                      'Обещал оплатить${promises.isNotEmpty ? " до ${promises.first['promised_date'] ?? ''}" : ""}',
                      style: const TextStyle(fontSize: 11, color: Colors.blue, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showResidentDetails(Map<String, dynamic> item, Color color) {
    final accountId = item['account_id'] as int?;
    final promises = (item['promises'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6, minChildSize: 0.3, maxChildSize: 0.9, expand: false,
        builder: (ctx, scroll) => SingleChildScrollView(
          controller: scroll,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              Text(item['fio'] ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(item['address'] ?? '', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
              Text('Л/С: ${item['account_number'] ?? '-'}', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
              const SizedBox(height: 12),

              // Статистика
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _detailRow('Текущий долг', '${(item['current_debt'] as num?)?.toStringAsFixed(2) ?? '0'} ₽'),
                    _detailRow('Оплачено периодов', '${item['paid_periods']} из ${item['total_periods']}'),
                    _detailRow('Процент оплаты', '${item['pay_ratio']}%'),
                    _detailRow('Всего начислено', '${(item['total_charged'] as num?)?.toStringAsFixed(2) ?? '0'} ₽'),
                    _detailRow('Всего оплачено', '${(item['total_paid'] as num?)?.toStringAsFixed(2) ?? '0'} ₽'),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Обещания
              if (promises.isNotEmpty) ...[
                const Text('🤝 Обещания оплаты:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 6),
                ...promises.map((p) => Card(
                  child: ListTile(
                    leading: Icon(
                      p['status'] == 'fulfilled' ? Icons.check_circle : p['status'] == 'broken' ? Icons.cancel : Icons.schedule,
                      color: p['status'] == 'fulfilled' ? Colors.green : p['status'] == 'broken' ? Colors.red : Colors.orange,
                    ),
                    title: Text('До ${p['promised_date'] ?? '-'}${p['promised_amount'] != null ? ' — ${p['promised_amount']} ₽' : ''}'),
                    subtitle: p['note'] != null ? Text(p['note'], maxLines: 2) : null,
                    trailing: PopupMenuButton<String>(
                      onSelected: (v) => _updatePromise(p['id'], v, ctx),
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: 'fulfilled', child: Text('✅ Выполнено')),
                        const PopupMenuItem(value: 'broken', child: Text('❌ Не выполнено')),
                        const PopupMenuItem(value: 'delete', child: Text('🗑 Удалить')),
                      ],
                    ),
                  ),
                )),
                const SizedBox(height: 8),
              ],

              // Кнопки
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      icon: const Icon(Icons.handshake),
                      label: const Text('Обещание'),
                      onPressed: () { Navigator.pop(ctx); _addPromise(accountId!); },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.receipt_long),
                      label: const Text('Документы'),
                      onPressed: () {
                        Navigator.pop(ctx);
                        if (accountId != null) {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (_) => PaymentDocumentsScreen(
                              accountId: accountId,
                              accountNumber: item['account_number'],
                              fio: item['fio'],
                            ),
                          ));
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Future<void> _addPromise(int accountId) async {
    final dateCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('🤝 Обещание оплаты'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: dateCtrl, decoration: const InputDecoration(labelText: 'Дата оплаты (ДД.ММ.ГГГГ)', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: amountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Сумма (необязательно)', border: OutlineInputBorder(), suffixText: '₽')),
            const SizedBox(height: 10),
            TextField(controller: noteCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Комментарий', border: OutlineInputBorder())),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );

    if (result != true || dateCtrl.text.isEmpty) return;

    try {
      // Парсим дату ДД.ММ.ГГГГ → ГГГГ-ММ-ДД
      final parts = dateCtrl.text.split('.');
      final isoDate = parts.length == 3 ? '${parts[2]}-${parts[1]}-${parts[0]}' : dateCtrl.text;

      final dio = ref.read(dioProvider);
      await dio.post('/activity-monitor/promises', data: {
        'account_id': accountId,
        'promised_date': isoDate,
        if (amountCtrl.text.isNotEmpty) 'promised_amount': double.tryParse(amountCtrl.text),
        if (noteCtrl.text.isNotEmpty) 'note': noteCtrl.text,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Обещание добавлено'), backgroundColor: Colors.green));
      }
      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ Ошибка: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _updatePromise(int promiseId, String action, BuildContext ctx) async {
    try {
      final dio = ref.read(dioProvider);
      if (action == 'delete') {
        await dio.delete('/activity-monitor/promises/$promiseId');
      } else {
        await dio.put('/activity-monitor/promises/$promiseId', data: {'status': action});
      }
      Navigator.pop(ctx);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Обновлено'), backgroundColor: Colors.green));
      }
      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ Ошибка: $e'), backgroundColor: Colors.red));
      }
    }
  }
}
