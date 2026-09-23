import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../services/base_api_service.dart';
import '../services/file_export_helper.dart';

/// Экран отчётов и реестров — 6 уникальных отчётов + экспорт.
/// Каждый отчёт показывает принципиально разную аналитику,
/// используя различные данные из API.
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
  Map<String, dynamic>? _reportData;
  bool _isLoading = false;
  bool _isExporting = false;
  bool _loadingPeriods = true;
  String? _error;
  String? _periodsError;

  @override
  void initState() {
    super.initState();
    _loadPeriods();
  }

  Future<void> _loadPeriods() async {
    setState(() { _loadingPeriods = true; _periodsError = null; });
    try {
      final dio = ref.read(dioProvider);
      final resp = await dio.get('/payment-documents/periods');
      final data = resp.data;
      List<String> periods;
      if (data is List) {
        periods = data.map((e) => e.toString()).toList();
      } else {
        periods = [];
      }
      setState(() {
        _periods = periods;
        if (periods.isNotEmpty && _selectedPeriod == null) _selectedPeriod = periods.first;
      });
    } catch (e) {
      debugPrint('❌ Ошибка загрузки периодов: $e');
      setState(() => _periodsError = 'Не удалось загрузить периоды');
    }
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
          // Предупреждение если периоды не загрузились
          if (_periodsError != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.orange.shade50,
              child: Row(
                children: [
                  const Icon(Icons.warning_amber, color: Colors.orange, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_periodsError!, style: TextStyle(fontSize: 13, color: Colors.orange.shade900))),
                  TextButton(
                    onPressed: _loadPeriods,
                    child: const Text('Повторить', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
          const Divider(height: 1),
          // Каталог отчётов + результат
          Expanded(
            child: _isLoading
                ? const Center(child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 12),
                      Text('Формирование отчёта...'),
                    ],
                  ))
                : _error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.error_outline, size: 48, color: Colors.red),
                              const SizedBox(height: 12),
                              Text(_error!, style: const TextStyle(fontSize: 13), textAlign: TextAlign.center),
                              const SizedBox(height: 12),
                              FilledButton(
                                onPressed: () => setState(() { _reportData = null; _error = null; }),
                                child: const Text('Назад'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _reportData != null
                        ? _buildReportResult(theme, isDark)
                        : _loadingPeriods
                            ? const Center(child: CircularProgressIndicator())
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

  // ═══════════════════════════════════════════════════════════════════
  // КАТАЛОГ ОТЧЁТОВ
  // ═══════════════════════════════════════════════════════════════════

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
              icon: Icons.table_chart_outlined,
              color: Colors.blue,
              title: 'Оборотная ведомость',
              subtitle: 'Детализация по каждой услуге: отопление, ГВС, ТБО, ОДН и др.',
              type: 'turnover',
            ),
            _ReportItem(
              icon: Icons.warning_amber_rounded,
              color: Colors.red,
              title: 'Список неплательщиков',
              subtitle: 'Должники с индикаторами критичности и процентом неоплаты',
              type: 'debtors',
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildReportCategory(
          'Аналитика',
          Icons.analytics_outlined,
          Colors.indigo,
          [
            _ReportItem(
              icon: Icons.home_work,
              color: Colors.orange,
              title: 'Сводка по домам',
              subtitle: 'Начисления, оплаты и процент собираемости по каждому дому',
              type: 'house_summary',
            ),
            _ReportItem(
              icon: Icons.show_chart,
              color: Colors.cyan,
              title: 'Помесячная динамика',
              subtitle: 'Графики трендов начислений, оплат и собираемости',
              type: 'monthly',
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildReportCategory(
          'Реестры',
          Icons.list_alt,
          Colors.deepPurple,
          [
            _ReportItem(
              icon: Icons.receipt_long,
              color: Colors.deepPurple,
              title: 'Реестр квитанций',
              subtitle: 'Полный список документов с поиском и итоговой строкой',
              type: 'receipts',
            ),
            _ReportItem(
              icon: Icons.card_giftcard,
              color: Colors.purple,
              title: 'Статистика льгот',
              subtitle: 'Количество льготников и суммы скидок по категориям',
              type: 'benefit_stats',
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

  // ═══════════════════════════════════════════════════════════════════
  // ЗАГРУЗКА ДАННЫХ
  // ═══════════════════════════════════════════════════════════════════

  Future<void> _loadReport(String type) async {
    // Проверяем необходимость периода
    final needsPeriod = type != 'benefit_stats' && type != 'monthly';
    if (needsPeriod && _selectedPeriod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('❌ Выберите период'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
          action: _periodsError != null
              ? SnackBarAction(label: 'Повторить', textColor: Colors.white, onPressed: _loadPeriods)
              : null,
        ),
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
      await _loadBenefitStats();
      return;
    }

    // Помесячная динамика
    if (type == 'monthly') {
      await _loadMonthlyDynamics();
      return;
    }

    // Сводка по домам
    if (type == 'house_summary') {
      await _loadHouseSummary();
      return;
    }

    // Оборотная ведомость и неплательщики — загружают документы
    setState(() { _isLoading = true; _error = null; _reportData = null; });

    try {
      final dio = ref.read(dioProvider);
      final params = <String, dynamic>{
        'period_date': _selectedPeriod,
        'sort_by': 'debt_end',
        'sort_order': 'desc',
      };
      if (_selectedLocationId != null) params['location_id'] = _selectedLocationId;

      // Статистика
      final resp = await dio.get('/payment-documents/statistics', queryParameters: {
        'period_date': _selectedPeriod,
        if (_selectedLocationId != null) 'location_id': _selectedLocationId,
        if (type == 'debtors') 'has_debt': true,
      });

      // Документы
      final docsResp = await dio.get('/payment-documents/', queryParameters: {
        ...params,
        'limit': 2000,
        if (type == 'debtors') 'has_debt': true,
      });

      final docsData = docsResp.data;
      final List docsList = docsData is List
          ? docsData
          : (docsData is Map ? (docsData['items'] ?? []) : []);

      setState(() {
        _reportData = {
          'stats': resp.data,
          'docs': docsList,
          'type': type,
        };
      });
    } catch (e) {
      setState(() => _error = e.toString());
    }
    setState(() => _isLoading = false);
  }

  Future<void> _loadBenefitStats() async {
    setState(() { _isLoading = true; _error = null; _reportData = null; });
    try {
      final dio = ref.read(dioProvider);
      final params = <String, dynamic>{};
      if (_selectedLocationId != null) params['location_id'] = _selectedLocationId;
      final resp = await dio.get('/benefits/', queryParameters: {...params, 'limit': 500});
      final data = resp.data;
      final List items = data is List ? data : (data is Map ? (data['items'] ?? []) : []);
      setState(() {
        _reportData = {'benefits': items, 'type': 'benefit_stats'};
      });
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMonthlyDynamics() async {
    setState(() { _isLoading = true; _error = null; _reportData = null; });
    try {
      final dio = ref.read(dioProvider);
      final params = <String, dynamic>{};
      if (_selectedLocationId != null) params['location_id'] = _selectedLocationId;
      final resp = await dio.get('/archives/periods', queryParameters: params);
      setState(() {
        _reportData = {'periods': resp.data, 'type': 'monthly'};
      });
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadHouseSummary() async {
    if (_selectedPeriod == null) return;
    setState(() { _isLoading = true; _error = null; _reportData = null; });
    try {
      final dio = ref.read(dioProvider);

      // Получаем список домов
      final locResp = await dio.get('/locations/', queryParameters: {'limit': 1000, 'assigned_only': true});
      final locData = locResp.data;
      List<Map<String, dynamic>> locations;
      if (locData is List) {
        locations = locData.cast<Map<String, dynamic>>();
      } else if (locData is Map && locData.containsKey('items')) {
        locations = (locData['items'] as List).cast<Map<String, dynamic>>();
      } else {
        locations = [];
      }

      // Фильтруем по выбранному дому
      if (_selectedLocationId != null) {
        locations = locations.where((l) => l['id'] == _selectedLocationId).toList();
      }

      // Для каждого дома запрашиваем статистику
      final housesData = <Map<String, dynamic>>[];
      for (final loc in locations) {
        try {
          final statsResp = await dio.get('/payment-documents/statistics', queryParameters: {
            'period_date': _selectedPeriod,
            'location_id': loc['id'],
          });
          final stats = statsResp.data as Map<String, dynamic>? ?? {};
          final count = stats['count'] as int? ?? 0;
          if (count == 0) continue; // Пропускаем дома без документов

          housesData.add({
            'id': loc['id'],
            'name': loc['name'] ?? 'ID: ${loc['id']}',
            'address': loc['address'] ?? loc['name'] ?? '',
            'count': count,
            'total_charged': (stats['total_charged'] as num?)?.toDouble() ?? 0,
            'total_paid': (stats['total_paid'] as num?)?.toDouble() ?? 0,
            'total_debt': (stats['total_debt'] as num?)?.toDouble() ?? 0,
            'debtors_count': stats['debtors_count'] as int? ?? 0,
          });
        } catch (_) {
          // Пропускаем дом при ошибке
        }
      }

      // Сортируем по долгу (макс. долг первый)
      housesData.sort((a, b) => ((b['total_debt'] as double) - (a['total_debt'] as double)).sign.toInt());

      setState(() {
        _reportData = {'houses': housesData, 'type': 'house_summary'};
      });
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // РЕНДЕРИНГ ОТЧЁТОВ
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildReportResult(ThemeData theme, bool isDark) {
    final type = _reportData?['type'] as String?;

    return switch (type) {
      'benefit_stats' => _buildBenefitStatsResult(theme, isDark),
      'monthly' => _buildMonthlyResult(theme, isDark),
      'house_summary' => _buildHouseSummaryResult(theme, isDark),
      'turnover' => _buildTurnoverResult(theme, isDark),
      'debtors' => _buildDebtorsResult(theme, isDark),
      'receipts' => _buildReceiptsResult(theme, isDark),
      _ => const Center(child: Text('Неизвестный тип отчёта')),
    };
  }

  // ─── Кнопка «Назад» + PDF (общая) ───
  Widget _reportHeader(String title, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => setState(() { _reportData = null; }),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                if (subtitle != null)
                  Text(subtitle, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
            tooltip: 'Экспорт в PDF',
            onPressed: _isExporting ? null : () => _exportReportPdf(title),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // 1. ОБОРОТНАЯ ВЕДОМОСТЬ (по услугам)
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildTurnoverResult(ThemeData theme, bool isDark) {
    final docs = (_reportData?['docs'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    // Агрегируем итоги по каждой услуге
    const services = ['heating', 'hot_water', 'maintenance', 'waste', 'odn_electricity', 'odn_water'];
    const serviceLabels = {
      'heating': 'Отопление',
      'hot_water': 'ГВС',
      'maintenance': 'Содержание',
      'waste': 'ТБО',
      'odn_electricity': 'ОДН (эл)',
      'odn_water': 'ОДН (вода)',
    };

    // Считаем итоги по услугам
    final serviceTotals = <String, Map<String, double>>{};
    for (final svc in services) {
      double totalCharged = 0, totalPaid = 0, totalDebt = 0;
      for (final doc in docs) {
        totalCharged += (doc['charged_$svc'] as num?)?.toDouble() ?? 0;
        totalPaid += (doc['paid_$svc'] as num?)?.toDouble() ?? 0;
        totalDebt += (doc['debt_${svc}_end'] as num?)?.toDouble() ?? 0;
      }
      serviceTotals[svc] = {'charged': totalCharged, 'paid': totalPaid, 'debt': totalDebt};
    }

    return Column(
      children: [
        _reportHeader('Оборотная ведомость',
          subtitle: '${_formatPeriodString(_selectedPeriod ?? '')} • ${docs.length} Л/С'),
        const Divider(height: 1),
        // Сводка по услугам (горизонтально прокручиваемая)
        SizedBox(
          height: 90,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            children: services.where((svc) {
              final t = serviceTotals[svc]!;
              return (t['charged']! > 0 || t['debt']! != 0);
            }).map((svc) {
              final t = serviceTotals[svc]!;
              return Container(
                width: 130,
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? theme.colorScheme.surfaceContainerHigh : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor.withAlpha(50)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(serviceLabels[svc] ?? svc, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    Text('${t['charged']!.toStringAsFixed(0)}₽', style: const TextStyle(fontSize: 12, color: Colors.blue)),
                    Text('${t['paid']!.toStringAsFixed(0)}₽', style: const TextStyle(fontSize: 12, color: Colors.green)),
                    Text('${t['debt']!.toStringAsFixed(0)}₽',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                        color: t['debt']! > 0 ? Colors.red : Colors.green)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const Divider(height: 1),
        // Таблица абонентов с горизонтальной прокруткой по услугам
        Expanded(
          child: docs.isEmpty
              ? const Center(child: Text('Нет данных'))
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: docs.length,
                  itemBuilder: (_, i) {
                    final doc = docs[i];
                    final fio = doc['fio'] ?? '';
                    final accountNumber = doc['account_number'] ?? '';
                    return Card(
                      margin: const EdgeInsets.only(bottom: 4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      child: ExpansionTile(
                        tilePadding: const EdgeInsets.symmetric(horizontal: 12),
                        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                        leading: SizedBox(
                          width: 28,
                          child: Text('${i + 1}', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
                        ),
                        title: Text(fio, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text('ЛС: $accountNumber • ${(doc['total_charged'] as num?)?.toStringAsFixed(0) ?? '0'}₽ / ${(doc['total_paid'] as num?)?.toStringAsFixed(0) ?? '0'}₽',
                            style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant)),
                        trailing: Text(
                          '${((doc['total_debt_end'] as num?)?.toDouble() ?? 0).toStringAsFixed(0)}₽',
                          style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700,
                            color: ((doc['total_debt_end'] as num?)?.toDouble() ?? 0) > 0 ? Colors.red : Colors.green,
                          ),
                        ),
                        // Раскрывающаяся детализация по услугам
                        children: [
                          Table(
                            columnWidths: const {
                              0: FlexColumnWidth(2.2),
                              1: FlexColumnWidth(1.5),
                              2: FlexColumnWidth(1.5),
                              3: FlexColumnWidth(1.5),
                            },
                            children: [
                              TableRow(
                                decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest.withAlpha(80)),
                                children: const [
                                  Padding(padding: EdgeInsets.all(4), child: Text('Услуга', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700))),
                                  Padding(padding: EdgeInsets.all(4), child: Text('Начисл.', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700), textAlign: TextAlign.right)),
                                  Padding(padding: EdgeInsets.all(4), child: Text('Оплач.', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700), textAlign: TextAlign.right)),
                                  Padding(padding: EdgeInsets.all(4), child: Text('Долг', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700), textAlign: TextAlign.right)),
                                ],
                              ),
                              ...services.where((svc) {
                                final ch = (doc['charged_$svc'] as num?)?.toDouble() ?? 0;
                                final de = (doc['debt_${svc}_end'] as num?)?.toDouble() ?? 0;
                                return ch != 0 || de != 0;
                              }).map((svc) {
                                final ch = (doc['charged_$svc'] as num?)?.toDouble() ?? 0;
                                final pd = (doc['paid_$svc'] as num?)?.toDouble() ?? 0;
                                final de = (doc['debt_${svc}_end'] as num?)?.toDouble() ?? 0;
                                return TableRow(children: [
                                  Padding(padding: const EdgeInsets.all(4), child: Text(serviceLabels[svc] ?? svc, style: const TextStyle(fontSize: 11))),
                                  Padding(padding: const EdgeInsets.all(4), child: Text(ch.toStringAsFixed(2), style: const TextStyle(fontSize: 11), textAlign: TextAlign.right)),
                                  Padding(padding: const EdgeInsets.all(4), child: Text(pd.toStringAsFixed(2), style: const TextStyle(fontSize: 11, color: Colors.green), textAlign: TextAlign.right)),
                                  Padding(padding: const EdgeInsets.all(4), child: Text(de.toStringAsFixed(2),
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: de > 0 ? Colors.red : Colors.green), textAlign: TextAlign.right)),
                                ]);
                              }),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // 2. СПИСОК НЕПЛАТЕЛЬЩИКОВ (с индикаторами критичности)
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildDebtorsResult(ThemeData theme, bool isDark) {
    final stats = _reportData?['stats'] as Map<String, dynamic>? ?? {};
    final allDocs = (_reportData?['docs'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    // Считаем метрики для каждого должника
    final debtors = allDocs.map((doc) {
      final totalDebt = (doc['total_debt_end'] as num?)?.toDouble() ?? 0;
      final totalCharged = (doc['total_charged'] as num?)?.toDouble() ?? 0;
      final debtPercent = totalCharged > 0 ? (totalDebt / totalCharged * 100) : 0.0;
      return {...doc, '_debt': totalDebt, '_debt_percent': debtPercent};
    }).where((d) => (d['_debt'] as double) > 0).toList();

    // Сортировка по долгу (убыв.)
    debtors.sort((a, b) => (b['_debt'] as double).compareTo(a['_debt'] as double));

    final totalDebt = (stats['total_debt'] as num?)?.toDouble() ?? 0;
    final debtorsCount = debtors.length;
    final criticalCount = debtors.where((d) => (d['_debt'] as double) > 5000).length;
    final warningCount = debtors.where((d) {
      final debt = d['_debt'] as double;
      return debt > 1000 && debt <= 5000;
    }).length;
    final lowCount = debtorsCount - criticalCount - warningCount;

    return Column(
      children: [
        _reportHeader('Список неплательщиков',
          subtitle: '${_formatPeriodString(_selectedPeriod ?? '')} • $debtorsCount должников'),
        const Divider(height: 1),
        // Сводная панель критичности
        Container(
          padding: const EdgeInsets.all(12),
          color: theme.colorScheme.surfaceContainerHighest.withAlpha(80),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _debtorChip('🔴 Критичные', criticalCount, '> 5 000₽', Colors.red),
                  _debtorChip('🟠 Средние', warningCount, '1 000 — 5 000₽', Colors.orange),
                  _debtorChip('🟡 Малые', lowCount, '< 1 000₽', Colors.amber),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Общая задолженность: ', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
                  Text('${totalDebt.toStringAsFixed(0)} ₽', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.red)),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Список должников
        Expanded(
          child: debtors.isEmpty
              ? const Center(child: Text('Нет должников 🎉'))
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: debtors.length,
                  itemBuilder: (_, i) {
                    final doc = debtors[i];
                    final debt = doc['_debt'] as double;
                    final debtPercent = doc['_debt_percent'] as double;
                    final fio = doc['fio'] ?? '';
                    final address = doc['address'] ?? '';
                    final accountNumber = doc['account_number'] ?? '';
                    final totalCharged = (doc['total_charged'] as num?)?.toDouble() ?? 0;

                    // Цвет по критичности
                    final Color severityColor;
                    final String severityIcon;
                    if (debt > 5000) {
                      severityColor = Colors.red;
                      severityIcon = '🔴';
                    } else if (debt > 1000) {
                      severityColor = Colors.orange;
                      severityIcon = '🟠';
                    } else {
                      severityColor = Colors.amber.shade700;
                      severityIcon = '🟡';
                    }

                    return Card(
                      margin: const EdgeInsets.only(bottom: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: severityColor.withAlpha(60), width: 1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        child: Row(
                          children: [
                            // Номер + индикатор
                            SizedBox(
                              width: 40,
                              child: Column(
                                children: [
                                  Text('${i + 1}', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant)),
                                  Text(severityIcon, style: const TextStyle(fontSize: 14)),
                                ],
                              ),
                            ),
                            // Абонент
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(fio, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                      maxLines: 1, overflow: TextOverflow.ellipsis),
                                  Text('$address • ЛС: $accountNumber',
                                      style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
                                      maxLines: 1, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 4),
                                  // Процент неоплаты
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 80,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(4),
                                          child: LinearProgressIndicator(
                                            value: totalCharged > 0 ? min(debt / totalCharged, 1.0) : 0,
                                            backgroundColor: Colors.grey.shade200,
                                            color: severityColor,
                                            minHeight: 6,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text('${debtPercent.toStringAsFixed(0)}% не оплачено',
                                          style: TextStyle(fontSize: 10, color: severityColor)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Долг
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('${debt.toStringAsFixed(0)} ₽',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: severityColor)),
                                Text('из ${totalCharged.toStringAsFixed(0)}₽',
                                  style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant)),
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

  Widget _debtorChip(String label, int count, String range, Color color) {
    return Column(
      children: [
        Text('$count', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color)),
        Text(label, style: const TextStyle(fontSize: 11)),
        Text(range, style: TextStyle(fontSize: 9, color: Colors.grey.shade600)),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // 3. СВОДКА ПО ДОМАМ (с процентом собираемости)
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildHouseSummaryResult(ThemeData theme, bool isDark) {
    final houses = (_reportData?['houses'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    // Общие итоги
    double totalCharged = 0, totalPaid = 0, totalDebt = 0;
    int totalAccounts = 0;
    for (final h in houses) {
      totalCharged += (h['total_charged'] as num?)?.toDouble() ?? 0;
      totalPaid += (h['total_paid'] as num?)?.toDouble() ?? 0;
      totalDebt += (h['total_debt'] as num?)?.toDouble() ?? 0;
      totalAccounts += (h['count'] as int?) ?? 0;
    }
    final avgCollection = totalCharged > 0 ? (totalPaid / totalCharged * 100) : 0.0;

    return Column(
      children: [
        _reportHeader('Сводка по домам',
          subtitle: '${_formatPeriodString(_selectedPeriod ?? '')} • ${houses.length} домов, $totalAccounts Л/С'),
        const Divider(height: 1),
        // Итоговая строка
        Container(
          padding: const EdgeInsets.all(12),
          color: theme.colorScheme.surfaceContainerHighest.withAlpha(80),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statChip('Начислено', '${totalCharged.toStringAsFixed(0)} ₽', Colors.blue),
              _statChip('Оплачено', '${totalPaid.toStringAsFixed(0)} ₽', Colors.green),
              _statChip('Долг', '${totalDebt.toStringAsFixed(0)} ₽', totalDebt > 0 ? Colors.red : Colors.green),
              _statChip('Собираемость', '${avgCollection.toStringAsFixed(1)}%',
                  avgCollection >= 80 ? Colors.green : avgCollection >= 50 ? Colors.orange : Colors.red),
            ],
          ),
        ),
        const Divider(height: 1),
        // Дома
        Expanded(
          child: houses.isEmpty
              ? const Center(child: Text('Нет данных'))
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: houses.length,
                  itemBuilder: (_, i) {
                    final h = houses[i];
                    final name = h['name'] as String? ?? '';
                    final count = h['count'] as int? ?? 0;
                    final charged = (h['total_charged'] as num?)?.toDouble() ?? 0;
                    final paid = (h['total_paid'] as num?)?.toDouble() ?? 0;
                    final debt = (h['total_debt'] as num?)?.toDouble() ?? 0;
                    final debtorsCount = h['debtors_count'] as int? ?? 0;
                    final collection = charged > 0 ? (paid / charged * 100) : 0.0;

                    final Color collectionColor;
                    if (collection >= 80) {
                      collectionColor = Colors.green;
                    } else if (collection >= 50) {
                      collectionColor = Colors.orange;
                    } else {
                      collectionColor = Colors.red;
                    }

                    return Card(
                      margin: const EdgeInsets.only(bottom: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Адрес + кол-во ЛС
                            Row(
                              children: [
                                const Icon(Icons.home, size: 18, color: Colors.indigo),
                                const SizedBox(width: 8),
                                Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                    maxLines: 2, overflow: TextOverflow.ellipsis)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.indigo.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text('$count Л/С', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.indigo.shade700)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // Начислено / Оплачено / Долг
                            Row(
                              children: [
                                Expanded(child: Column(children: [
                                  Text('${charged.toStringAsFixed(0)}₽', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 13)),
                                  const Text('Начислено', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                ])),
                                Expanded(child: Column(children: [
                                  Text('${paid.toStringAsFixed(0)}₽', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
                                  const Text('Оплачено', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                ])),
                                Expanded(child: Column(children: [
                                  Text('${debt.toStringAsFixed(0)}₽', style: TextStyle(color: debt > 0 ? Colors.red : Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
                                  Text('Долг ($debtorsCount)', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                ])),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // Процент собираемости — прогресс-бар
                            Row(
                              children: [
                                Text('Собираемость:', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: collection / 100,
                                      backgroundColor: Colors.grey.shade200,
                                      color: collectionColor,
                                      minHeight: 8,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text('${collection.toStringAsFixed(1)}%',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: collectionColor)),
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

  // ═══════════════════════════════════════════════════════════════════
  // 4. ПОМЕСЯЧНАЯ ДИНАМИКА (с мини-графиками и трендами)
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildMonthlyResult(ThemeData theme, bool isDark) {
    final periods = (_reportData?['periods'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    // Находим максимальное начисление для масштабирования графиков
    double maxCharged = 1;
    for (final p in periods) {
      final ch = (p['total_charged'] as num?)?.toDouble() ?? 0;
      if (ch > maxCharged) maxCharged = ch;
    }

    return Column(
      children: [
        _reportHeader('Помесячная динамика',
          subtitle: '${periods.length} периодов'),
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
              final count = p['count'] as int? ?? 0;
              final collection = charged > 0 ? (paid / charged * 100) : 0.0;

              // Тренд по сравнению с предыдущим месяцем
              String trendIcon = '➖';
              if (i < periods.length - 1) {
                final prevDebt = (periods[i + 1]['total_debt'] as num?)?.toDouble() ?? 0;
                if (debt > prevDebt + 100) {
                  trendIcon = '📈';
                } else if (debt < prevDebt - 100) {
                  trendIcon = '📉';
                }
              }

              // Ширина полосок (относительно макс.)
              final chargedWidth = maxCharged > 0 ? (charged / maxCharged) : 0.0;
              final paidWidth = maxCharged > 0 ? (paid / maxCharged) : 0.0;

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Заголовок: период + тренд
                      Row(
                        children: [
                          const Icon(Icons.calendar_month, size: 16, color: Colors.cyan),
                          const SizedBox(width: 6),
                          Text(p['period_label'] ?? p['period'] ?? '',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(width: 8),
                          Text(trendIcon, style: const TextStyle(fontSize: 14)),
                          const Spacer(),
                          Text('$count Л/С', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Мини-графики (горизонтальные полоски)
                      Row(
                        children: [
                          SizedBox(width: 65, child: Text('Начисл.', style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant))),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: LinearProgressIndicator(
                                value: chargedWidth,
                                backgroundColor: Colors.grey.shade200,
                                color: Colors.blue,
                                minHeight: 10,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(width: 70, child: Text('${charged.toStringAsFixed(0)}₽', textAlign: TextAlign.right,
                              style: const TextStyle(fontSize: 11, color: Colors.blue, fontWeight: FontWeight.w600))),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          SizedBox(width: 65, child: Text('Оплач.', style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant))),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: LinearProgressIndicator(
                                value: paidWidth,
                                backgroundColor: Colors.grey.shade200,
                                color: Colors.green,
                                minHeight: 10,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(width: 70, child: Text('${paid.toStringAsFixed(0)}₽', textAlign: TextAlign.right,
                              style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.w600))),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Долг и процент собираемости
                      Row(
                        children: [
                          Text('Долг: ', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant)),
                          Text('${debt.toStringAsFixed(0)}₽',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: debt > 0 ? Colors.red : Colors.green)),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: collection >= 80 ? Colors.green.shade50 : collection >= 50 ? Colors.orange.shade50 : Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Собираемость: ${collection.toStringAsFixed(1)}%',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                                color: collection >= 80 ? Colors.green.shade700 : collection >= 50 ? Colors.orange.shade700 : Colors.red.shade700),
                            ),
                          ),
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

  // ═══════════════════════════════════════════════════════════════════
  // 5. РЕЕСТР КВИТАНЦИЙ (с поиском и итоговой строкой)
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildReceiptsResult(ThemeData theme, bool isDark) {
    final docs = (_reportData?['docs'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final searchController = TextEditingController();

    // Итоговые суммы — считаем из документов для точности
    double totalCharged = 0, totalPaid = 0, totalDebt = 0;
    for (final doc in docs) {
      totalCharged += (doc['total_charged'] as num?)?.toDouble() ?? 0;
      totalPaid += (doc['total_paid'] as num?)?.toDouble() ?? 0;
      totalDebt += (doc['total_debt_end'] as num?)?.toDouble() ?? 0;
    }
    final count = docs.length;

    return StatefulBuilder(
      builder: (context, setLocalState) {
        final searchQuery = searchController.text.toLowerCase();
        final filtered = searchQuery.isEmpty
            ? docs
            : docs.where((d) {
                final fio = (d['fio'] ?? '').toString().toLowerCase();
                final address = (d['address'] ?? '').toString().toLowerCase();
                final account = (d['account_number'] ?? '').toString().toLowerCase();
                return fio.contains(searchQuery) || address.contains(searchQuery) || account.contains(searchQuery);
              }).toList();

        return Column(
          children: [
            _reportHeader('Реестр квитанций',
              subtitle: '${_formatPeriodString(_selectedPeriod ?? '')} • $count документов'),
            const Divider(height: 1),
            // Поиск
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Поиск по ФИО, адресу, Л/С...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                onChanged: (_) => setLocalState(() {}),
              ),
            ),
            // Итоговая строка
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: theme.colorScheme.surfaceContainerHighest.withAlpha(80),
              child: Row(
                children: [
                  const Text('ИТОГО: ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  _miniStat('Начисл.', totalCharged, Colors.blue),
                  const SizedBox(width: 16),
                  _miniStat('Оплач.', totalPaid, Colors.green),
                  const SizedBox(width: 16),
                  _miniStat('Долг', totalDebt, totalDebt > 0 ? Colors.red : Colors.green),
                ],
              ),
            ),
            const Divider(height: 1),
            // Заголовок таблицы
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              color: theme.colorScheme.surfaceContainerHighest.withAlpha(40),
              child: const Row(
                children: [
                  SizedBox(width: 28, child: Text('#', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700))),
                  Expanded(flex: 3, child: Text('Абонент', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700))),
                  SizedBox(width: 70, child: Text('Начисл.', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700), textAlign: TextAlign.right)),
                  SizedBox(width: 70, child: Text('Оплач.', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700), textAlign: TextAlign.right)),
                  SizedBox(width: 70, child: Text('Долг', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700), textAlign: TextAlign.right)),
                ],
              ),
            ),
            // Список документов
            Expanded(
              child: filtered.isEmpty
                  ? Center(child: Text(searchQuery.isEmpty ? 'Нет данных' : 'Ничего не найдено'))
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final doc = filtered[i];
                        final fio = doc['fio'] ?? '';
                        final address = doc['address'] ?? '';
                        final accountNumber = doc['account_number'] ?? '';
                        final docDebt = (doc['total_debt_end'] as num?)?.toDouble() ?? 0;
                        final docCharged = (doc['total_charged'] as num?)?.toDouble() ?? 0;
                        final docPaid = (doc['total_paid'] as num?)?.toDouble() ?? 0;

                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: theme.dividerColor.withAlpha(30))),
                            color: i.isEven ? theme.colorScheme.surfaceContainerHighest.withAlpha(20) : null,
                          ),
                          child: Row(
                            children: [
                              SizedBox(width: 28, child: Text('${i + 1}', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant))),
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(fio, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                        maxLines: 1, overflow: TextOverflow.ellipsis),
                                    Text('$address • $accountNumber',
                                        style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant),
                                        maxLines: 1, overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                              ),
                              SizedBox(width: 70, child: Text(docCharged.toStringAsFixed(0),
                                  style: const TextStyle(fontSize: 11), textAlign: TextAlign.right)),
                              SizedBox(width: 70, child: Text(docPaid.toStringAsFixed(0),
                                  style: const TextStyle(fontSize: 11, color: Colors.green), textAlign: TextAlign.right)),
                              SizedBox(width: 70, child: Text(docDebt.toStringAsFixed(0),
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                                    color: docDebt > 0 ? Colors.red : Colors.green),
                                  textAlign: TextAlign.right)),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _miniStat(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('${value.toStringAsFixed(0)}₽', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
        Text(label, style: TextStyle(fontSize: 9, color: color.withAlpha(180))),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // 6. СТАТИСТИКА ЛЬГОТ (сохранена из предыдущей версии)
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildBenefitStatsResult(ThemeData theme, bool isDark) {
    final rawBenefits = _reportData?['benefits'];
    final List benefitsList = rawBenefits is List ? rawBenefits : [];
    final items = benefitsList.cast<Map<String, dynamic>>();
    final byCategory = <String, List<Map<String, dynamic>>>{};
    for (final b in items) {
      final cat = b['category'] as String? ?? 'other';
      byCategory.putIfAbsent(cat, () => []).add(b);
    }

    // Общая статистика
    final totalPeople = items.length;
    final avgDiscount = totalPeople > 0
        ? items.fold<double>(0, (sum, b) => sum + ((b['discount_percent'] as num?)?.toDouble() ?? 0)) / totalPeople
        : 0.0;

    return Column(
      children: [
        _reportHeader('Статистика льгот',
          subtitle: 'Всего: $totalPeople льготников • Средняя скидка: ${avgDiscount.toStringAsFixed(1)}%'),
        const Divider(height: 1),
        Expanded(
          child: byCategory.isEmpty
              ? const Center(child: Text('Нет данных о льготниках'))
              : ListView(
                  padding: const EdgeInsets.all(12),
                  children: byCategory.entries.map((e) {
                    final totalDiscount = e.value.fold<double>(0, (sum, b) => sum + ((b['discount_percent'] as num?)?.toDouble() ?? 0));
                    final avgCatDiscount = e.value.isNotEmpty ? totalDiscount / e.value.length : 0;
                    final percent = totalPeople > 0 ? (e.value.length / totalPeople * 100) : 0;

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
                                  child: Text('${e.value.length} чел. (${percent.toStringAsFixed(0)}%)',
                                      style: TextStyle(color: Colors.purple.shade700, fontSize: 11, fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            // Прогресс-бар доли от общего числа
                            ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: LinearProgressIndicator(
                                value: totalPeople > 0 ? e.value.length / totalPeople : 0,
                                backgroundColor: Colors.grey.shade200,
                                color: Colors.purple.shade300,
                                minHeight: 4,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('Средний % скидки: ${avgCatDiscount.toStringAsFixed(1)}%',
                                style: const TextStyle(fontSize: 12, color: Colors.grey)),
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

  // ═══════════════════════════════════════════════════════════════════
  // ОБЩИЕ УТИЛИТЫ
  // ═══════════════════════════════════════════════════════════════════

  Widget _statChip(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: color)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, color: color.withAlpha(180))),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // PDF ЭКСПОРТ ТЕКУЩЕГО ОТЧЁТА
  // ═══════════════════════════════════════════════════════════════════

  Future<void> _exportReportPdf(String title) async {
    final type = _reportData?['type'] as String?;
    if (type == null) return;

    setState(() => _isExporting = true);
    try {
      // Загружаем кириллический шрифт
      final fontData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
      final ttf = pw.Font.ttf(fontData);

      final pdf = pw.Document(
        theme: pw.ThemeData.withFont(base: ttf, bold: ttf),
      );

      // Проверка: если данных нет — сообщаем вместо пустого PDF
      final hasData = _reportDataHasRows(type);
      if (!hasData) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('⚠️ Нет данных для экспорта в PDF'), backgroundColor: Colors.orange),
          );
        }
        setState(() => _isExporting = false);
        return;
      }

      final pages = _buildPdfPages(type, title, ttf);

      for (final page in pages) {
        pdf.addPage(page);
      }

      final dir = await getTemporaryDirectory();
      final fileName = 'report_${type}_${_selectedPeriod ?? 'all'}.pdf';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      if (mounted) {
        final savedPath = await FileExportHelper.exportFile(
          sourceFile: file,
          fileName: fileName,
          mimeType: 'application/pdf',
          subject: '$title — $_selectedLocationName',
        );
        if (savedPath != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('✅ PDF сохранён: $savedPath'), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Ошибка PDF: $e'), backgroundColor: Colors.red),
        );
      }
    }
    setState(() => _isExporting = false);
  }

  List<pw.Page> _buildPdfPages(String type, String title, pw.Font ttf) {
    switch (type) {
      case 'turnover':
        return _buildTurnoverPdf(title, ttf);
      case 'debtors':
        return _buildDebtorsPdf(title, ttf);
      case 'house_summary':
        return _buildHouseSummaryPdf(title, ttf);
      case 'monthly':
        return _buildMonthlyPdf(title, ttf);
      case 'receipts':
        return _buildReceiptsPdf(title, ttf);
      case 'benefit_stats':
        return _buildBenefitsPdf(title, ttf);
      default:
        return [];
    }
  }

  // ─── PDF: Оборотная ведомость ───
  List<pw.Page> _buildTurnoverPdf(String title, pw.Font ttf) {
    final docs = (_reportData?['docs'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return _paginatedTable(
      ttf: ttf,
      title: title,
      subtitle: '${_formatPeriodString(_selectedPeriod ?? '')} • $_selectedLocationName • ${docs.length} Л/С',
      headers: ['#', 'ФИО', 'Л/С', 'Начисл.', 'Оплач.', 'Долг'],
      columnWidths: {0: const pw.FixedColumnWidth(25), 1: const pw.FlexColumnWidth(3), 2: const pw.FlexColumnWidth(1.5),
        3: const pw.FlexColumnWidth(1.2), 4: const pw.FlexColumnWidth(1.2), 5: const pw.FlexColumnWidth(1.2)},
      rows: docs.asMap().entries.map((e) {
        final i = e.key;
        final doc = e.value;
        return <String>['${i + 1}', doc['fio'] ?? '', doc['account_number'] ?? '',
          _f(doc['total_charged']), _f(doc['total_paid']), _f(doc['total_debt_end'])];
      }).toList(),
      totals: () {
        double tc = 0, tp = 0, td = 0;
        for (final d in docs) { tc += _n(d['total_charged']); tp += _n(d['total_paid']); td += _n(d['total_debt_end']); }
        return <String>['', 'ИТОГО', '${docs.length}', _f(tc), _f(tp), _f(td)];
      }(),
    );
  }

  // ─── PDF: Неплательщики ───
  List<pw.Page> _buildDebtorsPdf(String title, pw.Font ttf) {
    final allDocs = (_reportData?['docs'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final debtors = allDocs.where((d) => (_n(d['total_debt_end'])) > 0).toList();
    debtors.sort((a, b) => _n(b['total_debt_end']).compareTo(_n(a['total_debt_end'])));

    return _paginatedTable(
      ttf: ttf,
      title: title,
      subtitle: '${_formatPeriodString(_selectedPeriod ?? '')} • $_selectedLocationName • ${debtors.length} должников',
      headers: ['#', 'ФИО', 'Адрес', 'Л/С', 'Начисл.', 'Долг'],
      columnWidths: {0: const pw.FixedColumnWidth(25), 1: const pw.FlexColumnWidth(2.5), 2: const pw.FlexColumnWidth(2.5),
        3: const pw.FlexColumnWidth(1.2), 4: const pw.FlexColumnWidth(1.2), 5: const pw.FlexColumnWidth(1.2)},
      rows: debtors.asMap().entries.map((e) {
        final i = e.key;
        final doc = e.value;
        return <String>['${i + 1}', doc['fio'] ?? '', doc['address'] ?? '', doc['account_number'] ?? '',
          _f(doc['total_charged']), _f(doc['total_debt_end'])];
      }).toList(),
      totals: () {
        double tc = 0, td = 0;
        for (final d in debtors) { tc += _n(d['total_charged']); td += _n(d['total_debt_end']); }
        return <String>['', 'ИТОГО', '', '${debtors.length}', _f(tc), _f(td)];
      }(),
    );
  }

  // ─── PDF: Сводка по домам ───
  List<pw.Page> _buildHouseSummaryPdf(String title, pw.Font ttf) {
    final houses = (_reportData?['houses'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    return _paginatedTable(
      ttf: ttf,
      title: title,
      subtitle: '${_formatPeriodString(_selectedPeriod ?? '')} • ${houses.length} домов',
      headers: ['#', 'Дом', 'Л/С', 'Начисл.', 'Оплач.', 'Долг', 'Собир.%'],
      columnWidths: {0: const pw.FixedColumnWidth(25), 1: const pw.FlexColumnWidth(3), 2: const pw.FixedColumnWidth(35),
        3: const pw.FlexColumnWidth(1.2), 4: const pw.FlexColumnWidth(1.2), 5: const pw.FlexColumnWidth(1.2), 6: const pw.FixedColumnWidth(45)},
      rows: houses.asMap().entries.map((e) {
        final i = e.key;
        final h = e.value;
        final ch = _n(h['total_charged']);
        final pd = _n(h['total_paid']);
        final coll = ch > 0 ? (pd / ch * 100).toStringAsFixed(1) : '—';
        return <String>['${i + 1}', h['name'] ?? '', '${h['count'] ?? 0}', _f(h['total_charged']), _f(h['total_paid']), _f(h['total_debt']), '$coll%'];
      }).toList(),
      totals: () {
        double tc = 0, tp = 0, td = 0; int cnt = 0;
        for (final h in houses) { tc += _n(h['total_charged']); tp += _n(h['total_paid']); td += _n(h['total_debt']); cnt += (h['count'] as int?) ?? 0; }
        final avg = tc > 0 ? (tp / tc * 100).toStringAsFixed(1) : '—';
        return <String>['', 'ИТОГО', '$cnt', _f(tc), _f(tp), _f(td), '$avg%'];
      }(),
    );
  }

  // ─── PDF: Помесячная динамика ───
  List<pw.Page> _buildMonthlyPdf(String title, pw.Font ttf) {
    final periods = (_reportData?['periods'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    return _paginatedTable(
      ttf: ttf,
      title: title,
      subtitle: '$_selectedLocationName • ${periods.length} периодов',
      headers: ['Период', 'Л/С', 'Начисл.', 'Оплач.', 'Долг', 'Собир.%'],
      columnWidths: {0: const pw.FlexColumnWidth(2), 1: const pw.FixedColumnWidth(35),
        2: const pw.FlexColumnWidth(1.2), 3: const pw.FlexColumnWidth(1.2), 4: const pw.FlexColumnWidth(1.2), 5: const pw.FixedColumnWidth(45)},
      rows: periods.map((p) {
        final ch = _n(p['total_charged']);
        final pd = _n(p['total_paid']);
        final coll = ch > 0 ? (pd / ch * 100).toStringAsFixed(1) : '—';
        return <String>[p['period_label'] ?? p['period'] ?? '', '${p['count'] ?? 0}',
          _f(p['total_charged']), _f(p['total_paid']), _f(p['total_debt']), '$coll%'];
      }).toList(),
    );
  }

  // ─── PDF: Реестр квитанций ───
  List<pw.Page> _buildReceiptsPdf(String title, pw.Font ttf) {
    final docs = (_reportData?['docs'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    return _paginatedTable(
      ttf: ttf,
      title: title,
      subtitle: '${_formatPeriodString(_selectedPeriod ?? '')} • $_selectedLocationName • ${docs.length} документов',
      headers: ['#', 'ФИО', 'Адрес', 'Л/С', 'Начисл.', 'Оплач.', 'Долг'],
      columnWidths: {0: const pw.FixedColumnWidth(25), 1: const pw.FlexColumnWidth(2.5), 2: const pw.FlexColumnWidth(2.5),
        3: const pw.FlexColumnWidth(1.2), 4: const pw.FlexColumnWidth(1), 5: const pw.FlexColumnWidth(1), 6: const pw.FlexColumnWidth(1)},
      rows: docs.asMap().entries.map((e) {
        final i = e.key;
        final d = e.value;
        return <String>['${i + 1}', d['fio'] ?? '', d['address'] ?? '', d['account_number'] ?? '',
          _f(d['total_charged']), _f(d['total_paid']), _f(d['total_debt_end'])];
      }).toList(),
      totals: () {
        double tc = 0, tp = 0, td = 0;
        for (final d in docs) { tc += _n(d['total_charged']); tp += _n(d['total_paid']); td += _n(d['total_debt_end']); }
        return <String>['', 'ИТОГО', '', '${docs.length}', _f(tc), _f(tp), _f(td)];
      }(),
    );
  }

  // ─── PDF: Льготы ───
  List<pw.Page> _buildBenefitsPdf(String title, pw.Font ttf) {
    final items = (_reportData?['benefits'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    return _paginatedTable(
      ttf: ttf,
      title: title,
      subtitle: '$_selectedLocationName • ${items.length} льготников',
      headers: ['#', 'ФИО', 'Категория', 'Скидка %'],
      columnWidths: {0: const pw.FixedColumnWidth(25), 1: const pw.FlexColumnWidth(3),
        2: const pw.FlexColumnWidth(2), 3: const pw.FixedColumnWidth(55)},
      rows: items.asMap().entries.map((e) {
        final i = e.key;
        final b = e.value;
        return <String>['${i + 1}', b['resident_name'] ?? b['fio'] ?? '', b['category'] ?? '',
          '${(b['discount_percent'] as num?)?.toStringAsFixed(1) ?? '—'}%'];
      }).toList(),
    );
  }

  // ─── Универсальный генератор постраничных таблиц ───
  List<pw.Page> _paginatedTable({
    required pw.Font ttf,
    required String title,
    String? subtitle,
    required List<String> headers,
    required Map<int, pw.TableColumnWidth> columnWidths,
    required List<List<String>> rows,
    List<String>? totals,
  }) {
    // Первая страница содержит title/subtitle → меньше строк
    const firstPageRows = 25;
    const otherPageRows = 35;
    final pages = <pw.Page>[];

    // Вычисляем разбивку по страницам
    int remaining = rows.length;
    int offset = 0;
    int pageIdx = 0;
    final pageSlices = <List<List<String>>>[];
    while (remaining > 0 || pageSlices.isEmpty) {
      final capacity = pageIdx == 0 ? firstPageRows : otherPageRows;
      final take = min(capacity, remaining);
      pageSlices.add(rows.sublist(offset, offset + take));
      offset += take;
      remaining -= take;
      pageIdx++;
      if (remaining <= 0) break;
    }
    final totalPages = pageSlices.length;

    for (var pageIdx = 0; pageIdx < totalPages; pageIdx++) {
      final pageRows = pageSlices[pageIdx];
      final isLastPage = pageIdx == totalPages - 1;

      pages.add(pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(24),
        theme: pw.ThemeData.withFont(base: ttf, bold: ttf),
        build: (pw.Context ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Заголовок только на первой странице
              if (pageIdx == 0) ...[
                pw.Text(title, style: pw.TextStyle(font: ttf, fontSize: 16, fontWeight: pw.FontWeight.bold)),
                if (subtitle != null)
                  pw.Text(subtitle, style: pw.TextStyle(font: ttf, fontSize: 10, color: PdfColors.grey700)),
                pw.SizedBox(height: 12),
              ],
              if (totalPages > 1)
                pw.Text('Стр. ${pageIdx + 1} из $totalPages', style: pw.TextStyle(font: ttf, fontSize: 8, color: PdfColors.grey)),
              pw.SizedBox(height: 4),
              // Таблица
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
                columnWidths: columnWidths,
                children: [
                  // Заголовок
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: headers.map((h) => pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(h, style: pw.TextStyle(font: ttf, fontSize: 8, fontWeight: pw.FontWeight.bold)),
                    )).toList(),
                  ),
                  // Строки
                  ...pageRows.map((row) => pw.TableRow(
                    children: row.map((cell) => pw.Padding(
                      padding: const pw.EdgeInsets.all(3),
                      child: pw.Text(cell, style: pw.TextStyle(font: ttf, fontSize: 7), maxLines: 2),
                    )).toList(),
                  )),
                  // Итого на последней странице
                  if (isLastPage && totals != null)
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                      children: totals.map((cell) => pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(cell, style: pw.TextStyle(font: ttf, fontSize: 8, fontWeight: pw.FontWeight.bold)),
                      )).toList(),
                    ),
                ],
              ),
            ],
          );
        },
      ));
    }
    return pages;
  }

  double _n(dynamic v) => (v as num?)?.toDouble() ?? 0;
  String _f(dynamic v) => _n(v).toStringAsFixed(0);

  bool _reportDataHasRows(String type) {
    if (_reportData == null) return false;
    switch (type) {
      case 'turnover':
      case 'debtors':
      case 'receipts':
        final docs = (_reportData?['docs'] as List?) ?? [];
        return docs.isNotEmpty;
      case 'house_summary':
        final houses = (_reportData?['houses'] as List?) ?? [];
        return houses.isNotEmpty;
      case 'monthly':
        final periods = (_reportData?['periods'] as List?) ?? [];
        return periods.isNotEmpty;
      case 'benefit_stats':
        final benefits = (_reportData?['benefits'] as List?) ?? [];
        return benefits.isNotEmpty;
      default:
        return false;
    }
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
        '/payment-documents/export/excel',
        queryParameters: params,
        options: Options(responseType: ResponseType.bytes),
      );

      if (resp.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final filename = 'report_${_selectedPeriod ?? 'all'}.xlsx';
        final file = File('${dir.path}/$filename');
        await file.writeAsBytes(resp.data as List<int>);

        if (mounted) {
          final savedPath = await FileExportHelper.exportFile(
            sourceFile: file,
            fileName: filename,
            mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            subject: 'Отчёт ЖКУ $_selectedPeriod',
          );
          if (savedPath != null && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('✅ Сохранено: $savedPath'), backgroundColor: Colors.green),
            );
          }
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
    final oldPeriod = _selectedPeriod;
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
    ).then((_) {
      // Перезагрузить отчёт если период изменился и отчёт уже открыт
      if (_selectedPeriod != oldPeriod && _reportData != null) {
        final type = _reportData!['type'] as String?;
        if (type != null) {
          _loadReport(type);
        }
      }
    });
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
      final data = resp.data;
      List<Map<String, dynamic>> locations;
      if (data is List) {
        locations = data.cast<Map<String, dynamic>>();
      } else if (data is Map && data.containsKey('items')) {
        locations = (data['items'] as List).cast<Map<String, dynamic>>();
      } else {
        locations = [];
      }

      if (!mounted) return;
      final oldLocationId = _selectedLocationId;
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

      // Перезагрузить отчёт если дом изменился и отчёт уже открыт
      if (_selectedLocationId != oldLocationId && _reportData != null) {
        final type = _reportData!['type'] as String?;
        if (type != null) {
          _loadReport(type);
        }
      }
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
