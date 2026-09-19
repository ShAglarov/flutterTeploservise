import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/base_api_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
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
    final currentTab = _tabController.index;
    final cat = currentTab == 0 ? 'chronic' : currentTab == 1 ? 'irregular' : currentTab == 2 ? 'stable' : 'promised';
    final defaultName = 'monitor_${cat}_${DateTime.now().millisecondsSinceEpoch}.pdf';

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

      if (response.statusCode != 200) return;
      final bytes = response.data as List<int>;

      // iOS/Android — Share Sheet
      if (Platform.isIOS || Platform.isAndroid) {
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/$defaultName');
        await tempFile.writeAsBytes(bytes);
        if (!mounted) return;
        await Share.shareXFiles([XFile(tempFile.path, mimeType: 'application/pdf')], subject: defaultName);
        return;
      }

      // Desktop — диалог сохранения
      String? savePath;
      try {
        savePath = await FilePicker.saveFile(dialogTitle: 'Сохранить PDF', fileName: defaultName);
      } catch (_) {
        try {
          final dir = await FilePicker.getDirectoryPath(dialogTitle: 'Выберите папку');
          if (dir != null) savePath = '$dir/$defaultName';
        } catch (_) {}
      }
      if (savePath == null) return;

      final filePath = savePath.endsWith('.pdf') ? savePath : '$savePath.pdf';
      await File(filePath).writeAsBytes(bytes);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ Сохранено: $filePath'), duration: const Duration(seconds: 5)));
      }
    } on DioException catch (e) {
      if (!mounted) return;
      final statusCode = e.response?.statusCode;
      String msg;
      if (statusCode == 404) {
        msg = 'Функция экспорта PDF ещё не доступна на сервере. Требуется обновление бэкенда.';
      } else if (statusCode == 500) {
        msg = 'Ошибка сервера при генерации PDF. Обратитесь к администратору.';
      } else {
        msg = 'Ошибка сети ($statusCode). Проверьте подключение.';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: statusCode == 404 ? Colors.orange : Colors.red,
        duration: const Duration(seconds: 4),
      ));
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
      body: LayoutBuilder(builder: (context, constraints) {
        final isWide = constraints.maxWidth > 900;
        final pad = isWide ? 24.0 : 12.0;

        return Column(
          children: [
            // Поиск
            Padding(
              padding: EdgeInsets.fromLTRB(pad, 10, pad, 6),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => _onSearchChanged(),
                decoration: InputDecoration(
                  hintText: 'Поиск по ФИО, лицевому счёту, адресу...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchController.clear(); _loadData(); })
                      : null,
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest.withAlpha(50),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: theme.colorScheme.outlineVariant.withAlpha(80)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),

            // Сводка
            if (!_isLoading && _summary.isNotEmpty) _buildSummaryBar(theme, isWide, pad),

            // Контент
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
                          const SizedBox(height: 12),
                          Text('Ошибка: $_error', style: TextStyle(color: theme.colorScheme.error)),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(icon: const Icon(Icons.refresh), label: const Text('Повторить'), onPressed: _loadData),
                        ]))
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            _buildList(_getList('chronic'), Colors.red, '😤', isWide, pad),
                            _buildList(_getList('irregular'), Colors.orange, '📉', isWide, pad),
                            _buildList(_getList('stable'), Colors.green, '✅', isWide, pad),
                            _buildList(_getList('promised'), Colors.blue, '🤝', isWide, pad),
                          ],
                        ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSummaryBar(ThemeData theme, bool isWide, double pad) {
    if (isWide) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: pad, vertical: 6),
        child: Row(children: [
          Expanded(child: _summaryCard('Всего', '${_summary['total_accounts'] ?? 0}', theme.colorScheme.onSurface, Icons.people, theme)),
          const SizedBox(width: 10),
          Expanded(child: _summaryCard('Стабильные', '${_summary['stable_count'] ?? 0}', Colors.green, Icons.check_circle, theme)),
          const SizedBox(width: 10),
          Expanded(child: _summaryCard('Нерегулярные', '${_summary['irregular_count'] ?? 0}', Colors.orange, Icons.trending_down, theme)),
          const SizedBox(width: 10),
          Expanded(child: _summaryCard('Злостные', '${_summary['chronic_count'] ?? 0}', Colors.red, Icons.warning_amber, theme)),
          const SizedBox(width: 10),
          Expanded(child: _summaryCard('Обещали', '${_summary['promised_count'] ?? 0}', Colors.blue, Icons.handshake, theme)),
        ]),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: pad, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(80),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant.withAlpha(60)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _summaryItem('Всего', '${_summary['total_accounts'] ?? 0}', theme.colorScheme.onSurface),
          _summaryItem('Стабильн.', '${_summary['stable_count'] ?? 0}', Colors.green),
          _summaryItem('Нерегул.', '${_summary['irregular_count'] ?? 0}', Colors.orange),
          _summaryItem('Злостные', '${_summary['chronic_count'] ?? 0}', Colors.red),
          _summaryItem('Обещали', '${_summary['promised_count'] ?? 0}', Colors.blue),
        ],
      ),
    );
  }

  Widget _summaryCard(String label, String value, Color color, IconData icon, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color.withAlpha(15), color.withAlpha(8)]),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: color.withAlpha(25), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant)),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
        ])),
      ]),
    );
  }

  Widget _summaryItem(String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(fontSize: 9, color: color.withAlpha(200))),
      ],
    );
  }

  Widget _buildList(List<Map<String, dynamic>> items, Color color, String emoji, bool isWide, double pad) {
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
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: isWide ? pad : 12, vertical: 8),
        itemCount: items.length,
        separatorBuilder: (_, __) => Divider(height: 1, color: Theme.of(context).dividerColor.withAlpha(30)),
        itemBuilder: (context, index) => _buildResidentCard(items[index], color, emoji, isWide),
      ),
    );
  }

  Widget _buildResidentCard(Map<String, dynamic> item, Color color, String emoji, bool isWide) {
    final fio = item['fio'] ?? 'Не указано';
    final address = item['address'] ?? '';
    final debt = (item['current_debt'] as num?)?.toDouble() ?? 0;
    final payRatio = (item['pay_ratio'] as num?)?.toDouble() ?? 0;
    final totalPeriods = item['total_periods'] ?? 0;
    final paidPeriods = item['paid_periods'] ?? 0;
    final promises = (item['promises'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final hasPromise = item['has_active_promise'] == true;
    final debtColor = debt > 0 ? Colors.red : Colors.green;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => _showResidentDetails(item, color),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: isWide ? 10 : 8, horizontal: 4),
        child: Row(
          children: [
            // Цветная полоска категории
            Container(
              width: 3, height: isWide ? 44 : 38,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
            ),
            SizedBox(width: isWide ? 12 : 10),
            // ФИО + адрес
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(fio, style: TextStyle(fontWeight: FontWeight.w600, fontSize: isWide ? 14 : 13), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(address, style: TextStyle(fontSize: isWide ? 11 : 10, color: Theme.of(context).colorScheme.onSurfaceVariant), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                // Прогресс
                Row(children: [
                  SizedBox(
                    width: isWide ? 120 : 80,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: payRatio / 100,
                        backgroundColor: Theme.of(context).dividerColor.withAlpha(40),
                        color: payRatio >= 70 ? Colors.green : payRatio >= 30 ? Colors.orange : Colors.red,
                        minHeight: 4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text('$paidPeriods/$totalPeriods', style: TextStyle(fontSize: 9, color: Colors.grey.shade500)),
                  if (hasPromise) ...[
                    const SizedBox(width: 8),
                    Icon(Icons.handshake, size: 12, color: Colors.blue.shade300),
                  ],
                ]),
              ]),
            ),
            const SizedBox(width: 8),
            // Долг — просто текст без контейнера
            Text(
              '${debt.toStringAsFixed(0)} ₽',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: isWide ? 14 : 13, color: debtColor),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 16, color: Colors.grey.shade500),
          ],
        ),
      ),
    );
  }

  void _showResidentDetails(Map<String, dynamic> item, Color color) {
    final accountId = item['account_id'] as int?;
    final promises = (item['promises'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final debt = (item['current_debt'] as num?)?.toDouble() ?? 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.65, minChildSize: 0.3, maxChildSize: 0.9, expand: false,
        builder: (ctx, scroll) => Container(
          decoration: BoxDecoration(
            color: Theme.of(ctx).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            controller: scroll,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Хэндл
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 16),

                // Заголовок
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [color.withAlpha(25), color.withAlpha(10)]),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: color.withAlpha(40)),
                  ),
                  child: Row(children: [
                    Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(color: color.withAlpha(30), borderRadius: BorderRadius.circular(12)),
                      child: Icon(Icons.person, color: color, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(item['fio'] ?? '', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text('${item['address'] ?? ''}  •  Л/С: ${item['account_number'] ?? '-'}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    ])),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: (debt > 0 ? Colors.red : Colors.green).withAlpha(20),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: (debt > 0 ? Colors.red : Colors.green).withAlpha(50)),
                      ),
                      child: Text('${debt.toStringAsFixed(2)} ₽',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: debt > 0 ? Colors.red : Colors.green)),
                    ),
                  ]),
                ),
                const SizedBox(height: 16),

                // Статистика
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Theme.of(ctx).colorScheme.surfaceContainerHighest.withAlpha(60),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Theme.of(ctx).colorScheme.outlineVariant.withAlpha(50)),
                  ),
                  child: Column(children: [
                    _detailRow('Оплачено периодов', '${item['paid_periods']} из ${item['total_periods']}', Icons.calendar_today),
                    _detailRow('Процент оплаты', '${item['pay_ratio']}%', Icons.pie_chart),
                    _detailRow('Всего начислено', '${(item['total_charged'] as num?)?.toStringAsFixed(2) ?? '0'} ₽', Icons.receipt_long),
                    _detailRow('Всего оплачено', '${(item['total_paid'] as num?)?.toStringAsFixed(2) ?? '0'} ₽', Icons.payments),
                  ]),
                ),
                const SizedBox(height: 16),

                // Обещания
                if (promises.isNotEmpty) ...[
                  Text('🤝 Обещания оплаты', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Theme.of(ctx).colorScheme.onSurface)),
                  const SizedBox(height: 8),
                  ...promises.map((p) {
                    String dateStr = p['promised_date'] ?? '-';
                    final parsed = DateTime.tryParse(dateStr);
                    if (parsed != null) {
                      dateStr = '${parsed.day.toString().padLeft(2, '0')}.${parsed.month.toString().padLeft(2, '0')}.${parsed.year}';
                    }
                    final statusColor = p['status'] == 'fulfilled' ? Colors.green : p['status'] == 'broken' ? Colors.red : Colors.orange;
                    final statusIcon = p['status'] == 'fulfilled' ? Icons.check_circle : p['status'] == 'broken' ? Icons.cancel : Icons.schedule;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: statusColor.withAlpha(10),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: statusColor.withAlpha(40)),
                      ),
                      child: Row(children: [
                        Icon(statusIcon, color: statusColor, size: 22),
                        const SizedBox(width: 10),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('До $dateStr${p['promised_amount'] != null ? ' — ${p['promised_amount']} ₽' : ''}',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                          if (p['note'] != null) Text(p['note'], style: TextStyle(fontSize: 11, color: Colors.grey.shade600), maxLines: 2),
                        ])),
                        PopupMenuButton<String>(
                          iconSize: 20,
                          onSelected: (v) {
                            if (v == 'edit') { Navigator.pop(ctx); _addPromise(accountId!, existingPromise: p); }
                            else { _updatePromise(p['id'], v, ctx); }
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(value: 'edit', child: Text('✏️ Редактировать')),
                            const PopupMenuItem(value: 'fulfilled', child: Text('✅ Выполнено')),
                            const PopupMenuItem(value: 'broken', child: Text('❌ Не выполнено')),
                            const PopupMenuItem(value: 'delete', child: Text('🗑 Удалить')),
                          ],
                        ),
                      ]),
                    );
                  }),
                  const SizedBox(height: 8),
                ],

                // Кнопки
                Row(children: [
                  Expanded(child: FilledButton.icon(
                    icon: const Icon(Icons.handshake, size: 18),
                    label: const Text('Обещание'),
                    onPressed: () { Navigator.pop(ctx); _addPromise(accountId!); },
                    style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: OutlinedButton.icon(
                    icon: const Icon(Icons.receipt_long, size: 18),
                    label: const Text('Документы'),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    onPressed: () {
                      Navigator.pop(ctx);
                      if (accountId != null) {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (_) => PaymentDocumentsScreen(accountId: accountId, accountNumber: item['account_number'], fio: item['fio']),
                        ));
                      }
                    },
                  )),
                ]),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, [IconData? icon]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        if (icon != null) ...[Icon(icon, size: 16, color: Colors.grey.shade500), const SizedBox(width: 8)],
        Expanded(child: Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade600))),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Future<void> _addPromise(int accountId, {Map<String, dynamic>? existingPromise}) async {
    final amountCtrl = TextEditingController(text: existingPromise?['promised_amount']?.toString() ?? '');
    final noteCtrl = TextEditingController(text: existingPromise?['note'] ?? '');
    DateTime selectedDate = DateTime.now();
    
    // Парсим дату из существующего обещания
    if (existingPromise?['promised_date'] != null) {
      final parsed = DateTime.tryParse(existingPromise!['promised_date'].toString());
      if (parsed != null) selectedDate = parsed;
    }

    final result = await showModalBottomSheet<Map<String, dynamic>?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setDialogState) {
          return Container(
            padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
            decoration: BoxDecoration(
              color: Theme.of(ctx).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 12),
              // Заголовок
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.blue.withAlpha(25), Colors.blue.withAlpha(10)]),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.blue.withAlpha(40)),
                ),
                child: Row(children: [
                  Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(color: Colors.blue.withAlpha(30), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.handshake, color: Colors.blue, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(existingPromise != null ? 'Редактировать обещание' : 'Обещание оплаты',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                ]),
              ),
              const SizedBox(height: 16),
              // Календарь
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: selectedDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 30)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) setDialogState(() => selectedDate = picked);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Theme.of(ctx).colorScheme.outlineVariant.withAlpha(80)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.calendar_today, size: 18, color: Colors.blue),
                    const SizedBox(width: 12),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Дата оплаты', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                      Text(
                        '${selectedDate.day.toString().padLeft(2, '0')}.${selectedDate.month.toString().padLeft(2, '0')}.${selectedDate.year}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ]),
                    const Spacer(),
                    Icon(Icons.edit_calendar, size: 18, color: Colors.grey.shade400),
                  ]),
                ),
              ),
              const SizedBox(height: 12),
              // Сумма
              TextField(controller: amountCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(
                labelText: 'Сумма (необязательно)', suffixText: '₽',
                filled: true, fillColor: Theme.of(ctx).colorScheme.surfaceContainerHighest.withAlpha(40),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(ctx).colorScheme.outlineVariant.withAlpha(80))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(ctx).colorScheme.primary, width: 1.5)),
              )),
              const SizedBox(height: 12),
              // Комментарий
              TextField(controller: noteCtrl, maxLines: 2, decoration: InputDecoration(
                labelText: 'Комментарий',
                filled: true, fillColor: Theme.of(ctx).colorScheme.surfaceContainerHighest.withAlpha(40),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(ctx).colorScheme.outlineVariant.withAlpha(80))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(ctx).colorScheme.primary, width: 1.5)),
              )),
              const SizedBox(height: 16),
              // Кнопки
              Row(children: [
                Expanded(child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text('Отмена'),
                )),
                const SizedBox(width: 12),
                Expanded(flex: 2, child: FilledButton.icon(
                  onPressed: () => Navigator.pop(ctx, {
                    'date': selectedDate,
                    'amount': amountCtrl.text,
                    'note': noteCtrl.text,
                  }),
                  icon: const Icon(Icons.save, size: 18),
                  label: const Text('Сохранить'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                )),
              ]),
            ]),
          );
        });
      },
    );

    if (result == null) return;

    try {
      final date = result['date'] as DateTime;
      final isoDate = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      final dio = ref.read(dioProvider);
      
      if (existingPromise != null) {
        // Обновляем существующее обещание
        await dio.put('/activity-monitor/promises/${existingPromise['id']}', data: {
          'promised_date': isoDate,
          if (result['amount'].toString().isNotEmpty) 'promised_amount': double.tryParse(result['amount']),
          if (result['note'].toString().isNotEmpty) 'note': result['note'],
        });
      } else {
        // Создаём новое обещание
        await dio.post('/activity-monitor/promises', data: {
          'account_id': accountId,
          'promised_date': isoDate,
          if (result['amount'].toString().isNotEmpty) 'promised_amount': double.tryParse(result['amount']),
          if (result['note'].toString().isNotEmpty) 'note': result['note'],
        });
      }

      // Также обновляем promise_to_pay у жильца (ищем по account_id)
      try {
        final accResp = await dio.get('/accounts', queryParameters: {'skip': 0, 'limit': 5000});
        if (accResp.statusCode == 200) {
          final accounts = accResp.data is List ? accResp.data : [];
          for (final acc in accounts) {
            if (acc['id'] == accountId && acc['resident'] != null) {
              final residentId = acc['resident']['id'];
              await dio.put('/residents/$residentId', data: {
                'promise_to_pay': true,
                'promise_date': isoDate,
              });
              break;
            }
          }
        }
      } catch (_) {}

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(existingPromise != null ? '✅ Обещание обновлено' : '✅ Обещание добавлено'), backgroundColor: Colors.green));
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
