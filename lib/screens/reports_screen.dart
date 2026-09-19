import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../services/base_api_service.dart';

/// Экран отчётов и реестров — аналог reeskvi, reeskviu, reestrr1, stlg*, vedost*
/// из FoxPro. Позволяет формировать и экспортировать реестры квитанций,
/// оборотные ведомости, списки неплательщиков.
class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  String? _selectedPeriod;
  int? _selectedLocationId;
  String _selectedLocationName = 'Все дома';
  List<String> _periods = [];

  // Текущий отчёт
  String? _currentReportType;
  Map<String, dynamic>? _reportData;
  bool _isLoading = false;
  bool _isExporting = false;
  bool _loadingPeriods = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPeriods();
  }

  Future<void> _loadPeriods() async {
    try {
      final dio = ref.read(dioProvider);
      final resp = await dio.get('/payment-documents/periods');
      if (resp.statusCode == 200) {
        final periods = (resp.data as List).map((e) => e.toString()).toList();
        setState(() {
          _periods = periods;
          if (periods.isNotEmpty) _selectedPeriod = periods.first;
        });
      }
    } catch (_) {}
    setState(() => _loadingPeriods = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Реестры и отчёты'),
      ),
      body: Column(
        children: [
          // Фильтры
          _buildFilters(theme, isDark),
          const Divider(height: 1),
          // Каталог отчётов + результат
          Expanded(
            child: _reportData != null
                ? _buildReportResult(theme, isDark)
                : _buildReportCatalog(theme, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Период
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: _showPeriodPicker,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Период',
                  border: OutlineInputBorder(),
                  isDense: true,
                  prefixIcon: Icon(Icons.calendar_month, size: 20),
                ),
                child: Text(
                  _selectedPeriod != null ? _formatPeriodString(_selectedPeriod!) : 'Выберите',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Дом
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: _selectLocation,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Дом',
                  border: OutlineInputBorder(),
                  isDense: true,
                  prefixIcon: Icon(Icons.home_outlined, size: 20),
                ),
                child: Text(
                  _selectedLocationName,
                  style: const TextStyle(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCatalog(ThemeData theme, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _buildReportCategory(
          'Финансовые отчёты',
          Icons.account_balance_wallet,
          Colors.green,
          [
            _ReportItem(
              icon: Icons.summarize,
              color: Colors.blue,
              title: 'Оборотная ведомость',
              subtitle: 'Долг НМ, начислено, оплачено, перерасчёт, долг КМ по всем услугам',
              type: 'turnover',
            ),
            _ReportItem(
              icon: Icons.money_off,
              color: Colors.red,
              title: 'Список неплательщиков',
              subtitle: 'Абоненты с задолженностью на конец периода',
              type: 'debtors',
            ),
            _ReportItem(
              icon: Icons.bar_chart,
              color: Colors.teal,
              title: 'Статистика по услугам',
              subtitle: 'Суммы начислений, оплат и долгов по каждой услуге',
              type: 'service_stats',
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildReportCategory(
          'Реестры',
          Icons.list_alt,
          Colors.indigo,
          [
            _ReportItem(
              icon: Icons.receipt_long,
              color: Colors.deepPurple,
              title: 'Реестр квитанций',
              subtitle: 'Полный реестр платежных документов за период',
              type: 'receipts',
            ),
            _ReportItem(
              icon: Icons.home_work,
              color: Colors.orange,
              title: 'Реестр по домам',
              subtitle: 'Сводная информация по начислениям/оплатам в разрезе домов',
              type: 'by_house',
            ),
            _ReportItem(
              icon: Icons.card_giftcard,
              color: Colors.purple,
              title: 'Статистика льгот',
              subtitle: 'Количество льготников, суммы льгот по категориям',
              type: 'benefit_stats',
            ),
            _ReportItem(
              icon: Icons.calendar_view_month,
              color: Colors.cyan,
              title: 'Помесячный отчёт',
              subtitle: 'Сравнение начислений, оплат и долгов по месяцам',
              type: 'monthly',
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildReportCategory(
          'Экспорт',
          Icons.download,
          Colors.brown,
          [
            _ReportItem(
              icon: Icons.table_chart,
              color: Colors.green,
              title: _isExporting ? 'Экспорт...' : 'Экспорт в Excel',
              subtitle: _isExporting ? 'Идёт выгрузка...' : 'Выгрузка всех документов за период в XLSX-файл',
              type: 'export_xlsx',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReportCategory(String title, IconData icon, Color color, List<_ReportItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Text(title, style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w700, color: color,
            )),
          ],
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Card(
          margin: const EdgeInsets.only(bottom: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: item.color.withAlpha(30),
              child: Icon(item.icon, size: 22, color: item.color),
            ),
            title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            subtitle: Text(item.subtitle, style: TextStyle(
              fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant,
            )),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _loadReport(item.type),
          ),
        )),
      ],
    );
  }

  Future<void> _loadReport(String type) async {
    if (_selectedPeriod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Выберите период'), backgroundColor: Colors.red),
      );
      return;
    }

    // Экспорт в Excel — отдельная логика
    if (type == 'export_xlsx') {
      await _exportXlsx();
      return;
    }

    // Статистика льгот
    if (type == 'benefit_stats') {
      setState(() { _isLoading = true; _error = null; _currentReportType = type; _reportData = null; });
      try {
        final dio = ref.read(dioProvider);
        final params = <String, dynamic>{};
        if (_selectedLocationId != null) params['location_id'] = _selectedLocationId;
        final resp = await dio.get('/benefits/', queryParameters: {...params, 'limit': 500});
        setState(() {
          _reportData = {'benefits': resp.data, 'type': type};
        });
      } catch (e) {
        setState(() => _error = '$e');
      } finally {
        setState(() => _isLoading = false);
      }
      return;
    }

    // Помесячный отчёт
    if (type == 'monthly') {
      setState(() { _isLoading = true; _error = null; _currentReportType = type; _reportData = null; });
      try {
        final dio = ref.read(dioProvider);
        final params = <String, dynamic>{};
        if (_selectedLocationId != null) params['location_id'] = _selectedLocationId;
        final resp = await dio.get('/archives/periods', queryParameters: params);
        setState(() {
          _reportData = {'periods': resp.data, 'type': type};
        });
      } catch (e) {
        setState(() => _error = '$e');
      } finally {
        setState(() => _isLoading = false);
      }
      return;
    }

    setState(() { _isLoading = true; _error = null; _currentReportType = type; _reportData = null; });

    try {
      final dio = ref.read(dioProvider);
      final params = <String, dynamic>{
        'period_date': _selectedPeriod,
        'sort_by': 'debt_end',
        'sort_order': 'desc',
      };
      if (_selectedLocationId != null) params['location_id'] = _selectedLocationId;

      final resp = await dio.get('/payment-documents/stats', queryParameters: params);
      final docsResp = await dio.get('/payment-documents/', queryParameters: {
        ...params,
        'limit': 2000,
        if (type == 'debtors') 'has_debt': true,
      });

      if (resp.statusCode == 200) {
        setState(() {
          _reportData = {
            'stats': resp.data,
            'docs': docsResp.data,
            'type': type,
          };
        });
      }
    } catch (e) {
      setState(() => _error = e.toString());
    }
    setState(() => _isLoading = false);
  }

  Widget _buildReportResult(ThemeData theme, bool isDark) {
    if (_isLoading) {
      return const Center(child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 12),
          Text('Формирование отчёта...'),
        ],
      ));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 12),
            FilledButton(onPressed: () => setState(() { _reportData = null; _error = null; }), child: const Text('Назад')),
          ],
        ),
      );
    }

    final type = _reportData?['type'] as String?;

    // Рендеринг статистики льгот
    if (type == 'benefit_stats') {
      final items = (_reportData?['benefits']?['items'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      final byCategory = <String, List<Map<String, dynamic>>>{};
      for (final b in items) {
        final cat = b['category'] as String? ?? 'other';
        byCategory.putIfAbsent(cat, () => []).add(b);
      }
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() { _reportData = null; _currentReportType = null; })),
                const Expanded(child: Text('Статистика льгот', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
                Text('Всего: ${items.length}', style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: byCategory.entries.map((e) {
                final totalDiscount = e.value.fold<double>(0, (sum, b) => sum + ((b['discount_percent'] as num?)?.toDouble() ?? 0));
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.card_giftcard, color: Colors.purple, size: 18),
                            const SizedBox(width: 8),
                            Expanded(child: Text(e.key, style: const TextStyle(fontWeight: FontWeight.bold))),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(8)),
                              child: Text('${e.value.length} чел.', style: TextStyle(color: Colors.purple.shade700, fontSize: 11, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('Средний % скидки: ${(totalDiscount / e.value.length).toStringAsFixed(1)}%', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      );
    }

    // Рендеринг помесячного отчёта
    if (type == 'monthly') {
      final periods = (_reportData?['periods'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() { _reportData = null; _currentReportType = null; })),
                const Expanded(child: Text('Помесячный отчёт', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: periods.length,
              itemBuilder: (_, i) {
                final p = periods[i];
                final charged = (p['total_charged'] as num?)?.toDouble() ?? 0;
                final paid = (p['total_paid'] as num?)?.toDouble() ?? 0;
                final debt = (p['total_debt'] as num?)?.toDouble() ?? 0;
                return Card(
                  margin: const EdgeInsets.only(bottom: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_month, size: 16, color: Colors.cyan),
                            const SizedBox(width: 6),
                            Text(p['period_label'] ?? p['period'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            const Spacer(),
                            Text('${p['count'] ?? 0} Л/С', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(child: Column(children: [
                              Text('${charged.toStringAsFixed(0)}₽', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                              const Text('Начислено', style: TextStyle(fontSize: 10, color: Colors.grey)),
                            ])),
                            Expanded(child: Column(children: [
                              Text('${paid.toStringAsFixed(0)}₽', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                              const Text('Оплачено', style: TextStyle(fontSize: 10, color: Colors.grey)),
                            ])),
                            Expanded(child: Column(children: [
                              Text('${debt.toStringAsFixed(0)}₽', style: TextStyle(color: debt > 0 ? Colors.red : Colors.grey, fontWeight: FontWeight.bold)),
                              const Text('Долг', style: TextStyle(fontSize: 10, color: Colors.grey)),
                            ])),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    }

    final stats = _reportData?['stats'] as Map<String, dynamic>? ?? {};
    final docs = (_reportData?['docs'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return Column(
      children: [
        // Заголовок отчёта + кнопка "Назад"
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() { _reportData = null; _currentReportType = null; }),
              ),
              Expanded(
                child: Text(
                  _getReportTitle(type),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                _formatPeriodString(_selectedPeriod ?? ''),
                style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Сводка
        if (stats.isNotEmpty) _buildStatsSummary(stats, theme),
        const Divider(height: 1),
        // Таблица документов
        Expanded(
          child: docs.isEmpty
              ? const Center(child: Text('Нет данных'))
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: docs.length,
                  itemBuilder: (_, i) => _buildDocRow(docs[i], i, theme, type),
                ),
        ),
      ],
    );
  }

  Widget _buildStatsSummary(Map<String, dynamic> stats, ThemeData theme) {
    final totalDebt = (stats['total_debt_end'] as num?)?.toDouble() ?? 0;
    final totalCharged = (stats['total_charged'] as num?)?.toDouble() ?? 0;
    final totalPaid = (stats['total_paid'] as num?)?.toDouble() ?? 0;
    final count = stats['total_count'] as int? ?? 0;

    return Container(
      padding: const EdgeInsets.all(12),
      color: theme.colorScheme.surfaceContainerHighest.withAlpha(80),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statChip('Документов', count.toString(), Colors.blue),
          _statChip('Начислено', '${totalCharged.toStringAsFixed(0)} ₽', Colors.orange),
          _statChip('Оплачено', '${totalPaid.toStringAsFixed(0)} ₽', Colors.green),
          _statChip('Долг', '${totalDebt.toStringAsFixed(0)} ₽',
              totalDebt > 0 ? Colors.red : Colors.green),
        ],
      ),
    );
  }

  Widget _statChip(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: color)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, color: color.withAlpha(180))),
      ],
    );
  }

  Widget _buildDocRow(Map<String, dynamic> doc, int index, ThemeData theme, String? type) {
    final fio = doc['fio'] ?? '';
    final address = doc['address'] ?? '';
    final accountNumber = doc['account_number'] ?? '';
    final totalDebt = (doc['total_debt_end'] as num?)?.toDouble() ?? 0;
    final totalCharged = (doc['total_charged'] as num?)?.toDouble() ?? 0;
    final totalPaid = (doc['total_paid'] as num?)?.toDouble() ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            // Номер
            SizedBox(
              width: 32,
              child: Text(
                '${index + 1}',
                style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
            // Абонент
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(fio, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text('$address • ЛС: $accountNumber',
                      style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Начислено
            SizedBox(
              width: 80,
              child: Text(
                totalCharged.toStringAsFixed(2),
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 12),
              ),
            ),
            // Оплачено
            SizedBox(
              width: 80,
              child: Text(
                totalPaid.toStringAsFixed(2),
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 12, color: Colors.green),
              ),
            ),
            // Долг
            SizedBox(
              width: 80,
              child: Text(
                totalDebt.toStringAsFixed(2),
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: totalDebt > 0 ? Colors.red : Colors.green,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getReportTitle(String? type) {
    return switch (type) {
      'turnover' => 'Оборотная ведомость',
      'debtors' => 'Список неплательщиков',
      'service_stats' => 'Статистика по услугам',
      'receipts' => 'Реестр квитанций',
      'by_house' => 'Реестр по домам',
      'benefit_stats' => 'Статистика льгот',
      'monthly' => 'Помесячный отчёт',
      _ => 'Отчёт',
    };
  }

  Future<void> _exportXlsx() async {
    if (_selectedPeriod == null) return;

    setState(() => _isExporting = true);

    try {
      final dio = ref.read(dioProvider);
      final params = <String, dynamic>{
        'period_date': _selectedPeriod,
      };
      if (_selectedLocationId != null) params['location_id'] = _selectedLocationId;

      final resp = await dio.get(
        '/payment-documents/export/xlsx',
        queryParameters: params,
        options: Options(responseType: ResponseType.bytes),
      );

      if (resp.statusCode == 200) {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/report_${_selectedPeriod}.xlsx');
        await file.writeAsBytes(resp.data as List<int>);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Файл сохранён: ${file.path}'),
              backgroundColor: Colors.green,
              action: SnackBarAction(
                label: 'Поделиться',
                textColor: Colors.white,
                onPressed: () => Share.shareXFiles([XFile(file.path)]),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Ошибка экспорта: $e'), backgroundColor: Colors.red),
        );
      }
    }
    setState(() => _isExporting = false);
  }

  void _showPeriodPicker() {
    if (_periods.isEmpty) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Выбор периода'),
        content: SizedBox(
          width: 300,
          height: 400,
          child: ListView(
            children: _periods.map((p) => ListTile(
              leading: const Icon(Icons.calendar_today, size: 20),
              title: Text(_formatPeriodString(p)),
              selected: p == _selectedPeriod,
              onTap: () {
                setState(() => _selectedPeriod = p);
                Navigator.pop(ctx);
              },
            )).toList(),
          ),
        ),
      ),
    );
  }

  String _formatPeriodString(String s) {
    final dt = DateTime.tryParse(s);
    if (dt == null) return s;
    const months = [
      '', 'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
      'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь',
    ];
    return '${months[dt.month]} ${dt.year}';
  }

  Future<void> _selectLocation() async {
    try {
      final dio = ref.read(dioProvider);
      final resp = await dio.get('/locations/', queryParameters: {'limit': 1000, 'assigned_only': true});
      if (resp.statusCode != 200) return;
      final locations = (resp.data as List).cast<Map<String, dynamic>>();

      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (ctx) {
          final searchCtrl = TextEditingController();
          var filtered = locations;
          return StatefulBuilder(
            builder: (ctx, setDialogState) => AlertDialog(
              title: const Text('Выбор дома'),
              content: SizedBox(
                width: 400,
                height: 400,
                child: Column(
                  children: [
                    TextField(
                      controller: searchCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Поиск...',
                        prefixIcon: Icon(Icons.search),
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (q) {
                        setDialogState(() {
                          filtered = locations.where((l) =>
                            (l['name'] ?? '').toString().toLowerCase().contains(q.toLowerCase())
                          ).toList();
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.public, color: Colors.blue),
                            title: const Text('Все дома', style: TextStyle(fontWeight: FontWeight.w600)),
                            selected: _selectedLocationId == null,
                            onTap: () {
                              setState(() { _selectedLocationId = null; _selectedLocationName = 'Все дома'; });
                              Navigator.pop(ctx);
                            },
                          ),
                          const Divider(),
                          ...filtered.map((l) => ListTile(
                            leading: const Icon(Icons.home, size: 20),
                            title: Text(l['name'] ?? 'ID: ${l['id']}', style: const TextStyle(fontSize: 14)),
                            selected: l['id'] == _selectedLocationId,
                            dense: true,
                            onTap: () {
                              setState(() {
                                _selectedLocationId = l['id'] as int;
                                _selectedLocationName = l['name'] ?? 'ID: ${l['id']}';
                              });
                              Navigator.pop(ctx);
                            },
                          )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } catch (e) {
      debugPrint('❌ Ошибка загрузки домов: $e');
    }
  }
}

class _ReportItem {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String type;

  const _ReportItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.type,
  });
}
