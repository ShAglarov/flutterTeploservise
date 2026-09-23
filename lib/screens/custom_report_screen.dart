import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../services/base_api_service.dart';
import '../services/file_export_helper.dart';

/// ═══════════════════════════════════════════════════════════════════════
/// Конструктор аналитических отчётов
/// ═══════════════════════════════════════════════════════════════════════
/// Пользователь выбирает секции (галочками), настраивает параметры,
/// генерирует персональный отчёт. Все данные — из существующих API.
/// ═══════════════════════════════════════════════════════════════════════

class CustomReportScreen extends ConsumerStatefulWidget {
  const CustomReportScreen({super.key});

  @override
  ConsumerState<CustomReportScreen> createState() => _CustomReportScreenState();
}

class _CustomReportScreenState extends ConsumerState<CustomReportScreen>
    with TickerProviderStateMixin {
  // ── Конфигурация ──
  final Map<String, bool> _sections = {
    'summary': true,
    'top_houses': false,
    'top_debtors': true,
    'last_payments': false,
    'monthly_dynamics': false,
    'by_services': false,
    'overpayments': false,
    'best_payers': false,
  };

  // Периоды
  List<String> _allPeriods = [];
  String? _periodFrom;
  String? _periodTo;
  bool _loadingPeriods = true;

  // Дом
  int? _selectedLocationId;
  String _selectedLocationName = 'Все дома';

  // Параметры
  int _topN = 10;
  double _debtThreshold = 0;

  // Результат
  bool _showResult = false;
  bool _isGenerating = false;
  double _progress = 0;
  String _progressLabel = '';
  Map<String, dynamic> _reportResult = {};
  String? _error;
  bool _isExporting = false;

  // Поиск в результатах
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Анимация
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _pulseController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _loadPeriods();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPeriods() async {
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
        _allPeriods = periods;
        if (periods.isNotEmpty) {
          _periodFrom = periods.last; // самый ранний
          _periodTo = periods.first;  // самый свежий
        }
      });
    } catch (e) {
      debugPrint('❌ Ошибка загрузки периодов: $e');
    }
    setState(() => _loadingPeriods = false);
  }

  int get _selectedCount => _sections.values.where((v) => v).length;

  // ═══════════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(_showResult ? 'Аналитический отчёт' : 'Конструктор отчётов'),
        leading: _showResult
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() {
                  _showResult = false;
                  _fadeController.reset();
                  _searchQuery = '';
                  _searchController.clear();
                }),
              )
            : null,
        actions: [
          if (_showResult && !_isExporting) ...[
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              tooltip: 'Экспорт PDF',
              onPressed: _exportPdf,
            ),
            IconButton(
              icon: const Icon(Icons.table_chart_outlined),
              tooltip: 'Экспорт CSV',
              onPressed: _exportCsv,
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Пересоздать',
              onPressed: _generateReport,
            ),
          ],
          if (_isExporting)
            const Padding(
              padding: EdgeInsets.all(14),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            ),
        ],
      ),
      body: _isGenerating
          ? _buildGeneratingView(theme, isDark)
          : _showResult
              ? _buildReportView(theme, isDark)
              : _buildConfigurator(theme, isDark),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // КОНФИГУРАТОР
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildConfigurator(ThemeData theme, bool isDark) {
    return Column(
      children: [
        // Хедер с градиентом
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: isDark
                  ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
                  : [const Color(0xFF667EEA), const Color(0xFF764BA2)],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(25),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.auto_graph, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Собери свой отчёт',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text('Выбери данные, период и параметры',
                          style: TextStyle(color: Colors.white.withAlpha(180), fontSize: 13)),
                      ],
                    ),
                  ),
                  // Бейдж с кол-вом секций
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(30),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withAlpha(40)),
                    ),
                    child: Text(
                      '$_selectedCount секц.',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Контент
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ─── Секции ───
              _buildConfigSection(
                theme, isDark,
                icon: Icons.checklist_rtl,
                title: 'Секции отчёта',
                subtitle: 'Выберите, что включить',
                child: Column(
                  children: _sectionDefinitions.map((s) => _buildSectionCheckbox(
                    theme, isDark, s,
                  )).toList(),
                ),
              ),

              const SizedBox(height: 16),

              // ─── Период ───
              _buildConfigSection(
                theme, isDark,
                icon: Icons.date_range,
                title: 'Период',
                subtitle: _loadingPeriods ? 'Загрузка...' : '${_formatPeriod(_periodFrom)} — ${_formatPeriod(_periodTo)}',
                child: _loadingPeriods
                    ? const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      )
                    : Column(
                        children: [
                          Row(
                            children: [
                              Expanded(child: _buildPeriodSelector(theme, isDark, 'От', _periodFrom, (v) => setState(() => _periodFrom = v))),
                              const SizedBox(width: 12),
                              Expanded(child: _buildPeriodSelector(theme, isDark, 'До', _periodTo, (v) => setState(() => _periodTo = v))),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Быстрые пресеты
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildPresetChip(theme, isDark, 'Последний', () {
                                  if (_allPeriods.isNotEmpty) setState(() { _periodFrom = _allPeriods.first; _periodTo = _allPeriods.first; });
                                }),
                                _buildPresetChip(theme, isDark, 'Последние 3', () {
                                  if (_allPeriods.isNotEmpty) setState(() {
                                    _periodTo = _allPeriods.first;
                                    _periodFrom = _allPeriods.length >= 3 ? _allPeriods[2] : _allPeriods.last;
                                  });
                                }),
                                _buildPresetChip(theme, isDark, 'Полгода', () {
                                  if (_allPeriods.isNotEmpty) setState(() {
                                    _periodTo = _allPeriods.first;
                                    _periodFrom = _allPeriods.length >= 6 ? _allPeriods[5] : _allPeriods.last;
                                  });
                                }),
                                _buildPresetChip(theme, isDark, 'Год', () {
                                  if (_allPeriods.isNotEmpty) setState(() {
                                    _periodTo = _allPeriods.first;
                                    _periodFrom = _allPeriods.length >= 12 ? _allPeriods[11] : _allPeriods.last;
                                  });
                                }),
                                _buildPresetChip(theme, isDark, 'Все', () {
                                  if (_allPeriods.isNotEmpty) setState(() {
                                    _periodFrom = _allPeriods.last; _periodTo = _allPeriods.first;
                                  });
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),

              const SizedBox(height: 16),

              // ─── Фильтр по дому ───
              _buildConfigSection(
                theme, isDark,
                icon: Icons.home_outlined,
                title: 'Дом',
                subtitle: _selectedLocationName,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _selectLocation,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.dividerColor.withAlpha(80)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.home, size: 20, color: theme.colorScheme.primary),
                        const SizedBox(width: 12),
                        Expanded(child: Text(_selectedLocationName,
                            style: const TextStyle(fontSize: 14))),
                        const Icon(Icons.chevron_right, size: 20),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ─── Параметры ───
              _buildConfigSection(
                theme, isDark,
                icon: Icons.tune,
                title: 'Параметры',
                subtitle: 'Топ-$_topN • Порог ${_debtThreshold.toStringAsFixed(0)}₽',
                child: Column(
                  children: [
                    // Топ-N
                    Row(
                      children: [
                        SizedBox(width: 100, child: Text('Топ-N:', style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant))),
                        Expanded(
                          child: Slider(
                            value: _topN.clamp(3, 50).toDouble(),
                            min: 3, max: 50, divisions: 47,
                            label: '$_topN',
                            onChanged: (v) => setState(() => _topN = v.round()),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _showTopNInput(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: theme.colorScheme.primary.withAlpha(20),
                              border: Border.all(color: theme.colorScheme.primary.withAlpha(60)),
                            ),
                            child: Text('$_topN', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: theme.colorScheme.primary)),
                          ),
                        ),
                      ],
                    ),
                    // Порог долга
                    Row(
                      children: [
                        SizedBox(width: 100, child: Text('Порог долга:', style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant))),
                        Expanded(
                          child: Slider(
                            value: _debtThreshold,
                            min: 0, max: 10000, divisions: 100,
                            label: '${_debtThreshold.toStringAsFixed(0)}₽',
                            onChanged: (v) => setState(() => _debtThreshold = v),
                          ),
                        ),
                        SizedBox(
                          width: 60,
                          child: Text('${_debtThreshold.toStringAsFixed(0)}₽', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ─── Кнопка генерации ───
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: _selectedCount > 0 ? _generateReport : null,
                  icon: const Icon(Icons.rocket_launch, size: 20),
                  label: Text('Сгенерировать отчёт ($_selectedCount секц.)',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    backgroundColor: isDark ? const Color(0xFF667EEA) : const Color(0xFF764BA2),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // СЕКЦИИ ОПРЕДЕЛЕНИЯ
  // ═══════════════════════════════════════════════════════════════════════

  static final _sectionDefinitions = <_SectionDef>[
    _SectionDef('summary', Icons.pie_chart, Colors.blue, 'Общая сводка', 'Начислено, оплачено, долг, % собираемости'),
    _SectionDef('top_houses', Icons.apartment, Colors.orange, 'Топ домов по долгу', 'Рейтинг домов с наибольшей задолженностью'),
    _SectionDef('top_debtors', Icons.person_off, Colors.red, 'Топ должников', 'Абоненты с максимальным долгом'),
    _SectionDef('last_payments', Icons.payment, Colors.green, 'Последние оплаты', 'Абоненты с ненулевой оплатой за период'),
    _SectionDef('monthly_dynamics', Icons.show_chart, Colors.cyan, 'Динамика по периодам', 'Тренды начислений и оплат по месяцам'),
    _SectionDef('by_services', Icons.category, Colors.amber, 'Разбивка по услугам', 'Детализация: отопление, ГВС, ТБО, ОДН и др.'),
    _SectionDef('overpayments', Icons.trending_down, Colors.teal, 'Переплаты', 'Абоненты с отрицательным долгом'),
    _SectionDef('best_payers', Icons.star, Colors.purple, 'Лучшие плательщики', 'Топ по проценту оплаты'),
  ];

  Widget _buildSectionCheckbox(ThemeData theme, bool isDark, _SectionDef s) {
    final isChecked = _sections[s.key] ?? false;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isChecked
            ? s.color.withAlpha(isDark ? 25 : 15)
            : Colors.transparent,
        border: Border.all(
          color: isChecked ? s.color.withAlpha(80) : Colors.transparent,
          width: 1,
        ),
      ),
      child: CheckboxListTile(
        value: isChecked,
        onChanged: (v) => setState(() => _sections[s.key] = v ?? false),
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: s.color.withAlpha(isDark ? 40 : 25),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(s.icon, size: 20, color: s.color),
        ),
        title: Text(s.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        subtitle: Text(s.subtitle, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant)),
        dense: true,
        controlAffinity: ListTileControlAffinity.trailing,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // UI HELPERS
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildConfigSection(ThemeData theme, bool isDark, {
    required IconData icon, required String title, required String subtitle,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDark ? theme.colorScheme.surface : Colors.white,
        border: Border.all(color: theme.dividerColor.withAlpha(isDark ? 30 : 60)),
        boxShadow: isDark ? null : [
          BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                Icon(icon, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      Text(subtitle, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: theme.dividerColor.withAlpha(40)),
          Padding(
            padding: const EdgeInsets.all(12),
            child: child,
          ),
        ],
      ),
    );
  }

  void _showTopNInput() {
    final controller = TextEditingController(text: '$_topN');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Количество записей', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Например: 100',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.format_list_numbered),
          ),
          onSubmitted: (v) {
            final n = int.tryParse(v);
            if (n != null && n >= 1) {
              setState(() => _topN = n);
              Navigator.pop(ctx);
            }
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          FilledButton(
            onPressed: () {
              final n = int.tryParse(controller.text);
              if (n != null && n >= 1) {
                setState(() => _topN = n);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Применить'),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(ThemeData theme, bool isDark, String label, String? value, void Function(String) onChanged) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _showPeriodPicker(value, onChanged),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
          prefixIcon: const Icon(Icons.calendar_month, size: 18),
        ),
        child: Text(
          _formatPeriod(value),
          style: const TextStyle(fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildPresetChip(ThemeData theme, bool isDark, String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(label, style: const TextStyle(fontSize: 11)),
        onPressed: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        backgroundColor: isDark ? theme.colorScheme.surfaceContainerHigh : Colors.grey.shade100,
      ),
    );
  }

  void _showPeriodPicker(String? current, void Function(String) onChanged) {
    if (_allPeriods.isEmpty) return;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SizedBox(
        height: 400,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text('Выбор периода', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                itemCount: _allPeriods.length,
                itemBuilder: (_, i) {
                  final p = _allPeriods[i];
                  final isSelected = p == current;
                  return ListTile(
                    leading: Icon(
                      isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                      color: isSelected ? Theme.of(context).colorScheme.primary : null,
                      size: 20,
                    ),
                    title: Text(_formatPeriod(p), style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                    )),
                    dense: true,
                    onTap: () {
                      onChanged(p);
                      Navigator.pop(ctx);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // ВЫБОР ДОМА
  // ═══════════════════════════════════════════════════════════════════════

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
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (ctx) {
          final searchCtrl = TextEditingController();
          var filtered = locations;
          return StatefulBuilder(
            builder: (ctx, setSheetState) => DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              expand: false,
              builder: (_, scrollCtrl) => Column(
                children: [
                  // Handle
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    width: 40, height: 4,
                    decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(2)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: searchCtrl,
                      decoration: InputDecoration(
                        hintText: 'Поиск дома...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        isDense: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onChanged: (q) {
                        setSheetState(() {
                          filtered = locations.where((l) =>
                            (l['name'] ?? '').toString().toLowerCase().contains(q.toLowerCase())
                          ).toList();
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      controller: scrollCtrl,
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
          );
        },
      );
    } catch (e) {
      debugPrint('❌ Ошибка загрузки домов: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // ГЕНЕРАЦИЯ ОТЧЁТА
  // ═══════════════════════════════════════════════════════════════════════

  Future<void> _generateReport() async {
    final selected = _sections.entries.where((e) => e.value).map((e) => e.key).toList();
    if (selected.isEmpty) return;

    setState(() {
      _isGenerating = true;
      _progress = 0;
      _progressLabel = 'Подготовка...';
      _error = null;
      _reportResult = {};
    });

    final dio = ref.read(dioProvider);
    final total = selected.length;
    var done = 0;

    try {
      for (final section in selected) {
        setState(() {
          _progressLabel = _sectionLabel(section);
          _progress = done / total;
        });

        switch (section) {
          case 'summary':
            await _fetchSummary(dio);
            break;
          case 'top_houses':
            await _fetchTopHouses(dio);
            break;
          case 'top_debtors':
            await _fetchTopDebtors(dio);
            break;
          case 'last_payments':
            await _fetchLastPayments(dio);
            break;
          case 'monthly_dynamics':
            await _fetchMonthlyDynamics(dio);
            break;
          case 'by_services':
            await _fetchByServices(dio);
            break;
          case 'overpayments':
            await _fetchOverpayments(dio);
            break;
          case 'best_payers':
            await _fetchBestPayers(dio);
            break;
        }

        done++;
        setState(() => _progress = done / total);
      }

      setState(() {
        _isGenerating = false;
        _showResult = true;
      });
      _fadeController.forward();
    } catch (e) {
      setState(() {
        _isGenerating = false;
        _error = '$e';
      });
    }
  }

  String _sectionLabel(String key) {
    return _sectionDefinitions.firstWhere((s) => s.key == key, orElse: () => _sectionDefinitions.first).title;
  }

  // ── Data fetchers ──

  Future<void> _fetchSummary(Dio dio) async {
    final resp = await dio.get('/payment-documents/statistics', queryParameters: {
      if (_periodTo != null) 'period_date': _periodTo,
      if (_selectedLocationId != null) 'location_id': _selectedLocationId,
    });
    _reportResult['summary'] = resp.data;
  }

  Future<void> _fetchTopHouses(Dio dio) async {
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

    final housesData = <Map<String, dynamic>>[];

    // Фильтруем по выбранному дому
    if (_selectedLocationId != null) {
      locations = locations.where((l) => l['id'] == _selectedLocationId).toList();
    }

    for (final loc in locations) {
      try {
        final statsResp = await dio.get('/payment-documents/statistics', queryParameters: {
          if (_periodTo != null) 'period_date': _periodTo,
          'location_id': loc['id'],
        });
        final stats = statsResp.data as Map<String, dynamic>? ?? {};
        final count = stats['count'] as int? ?? 0;
        if (count == 0) continue;
        final debt = (stats['total_debt'] as num?)?.toDouble() ?? 0;
        if (debt <= _debtThreshold) continue;

        housesData.add({
          'id': loc['id'],
          'name': loc['name'] ?? 'ID: ${loc['id']}',
          'count': count,
          'total_charged': (stats['total_charged'] as num?)?.toDouble() ?? 0,
          'total_paid': (stats['total_paid'] as num?)?.toDouble() ?? 0,
          'total_debt': debt,
          'debtors_count': stats['debtors_count'] as int? ?? 0,
        });
      } catch (_) {}
    }

    housesData.sort((a, b) => ((b['total_debt'] as double) - (a['total_debt'] as double)).sign.toInt());
    _reportResult['top_houses'] = housesData.take(_topN).toList();
  }

  Future<void> _fetchTopDebtors(Dio dio) async {
    final params = <String, dynamic>{
      'has_debt': true,
      'sort_by': 'debt_end',
      'sort_order': 'desc',
      'limit': _topN,
      if (_periodTo != null) 'period_date': _periodTo,
      if (_selectedLocationId != null) 'location_id': _selectedLocationId,
      if (_debtThreshold > 0) 'min_debt': _debtThreshold,
    };
    final resp = await dio.get('/payment-documents/', queryParameters: params);
    final data = resp.data;
    final List items = data is List ? data : (data is Map ? (data['items'] ?? []) : []);
    _reportResult['top_debtors'] = items;
  }

  Future<void> _fetchLastPayments(Dio dio) async {
    final params = <String, dynamic>{
      'sort_by': 'total_paid',
      'sort_order': 'desc',
      'limit': _topN,
      if (_periodTo != null) 'period_date': _periodTo,
      if (_selectedLocationId != null) 'location_id': _selectedLocationId,
    };
    final resp = await dio.get('/payment-documents/', queryParameters: params);
    final data = resp.data;
    final List items = data is List ? data : (data is Map ? (data['items'] ?? []) : []);
    // Фильтруем: только с ненулевой оплатой
    _reportResult['last_payments'] = items.where((d) {
      final paid = (d['total_paid'] as num?)?.toDouble() ?? 0;
      return paid > 0;
    }).toList();
  }

  Future<void> _fetchMonthlyDynamics(Dio dio) async {
    final params = <String, dynamic>{
      if (_selectedLocationId != null) 'location_id': _selectedLocationId,
    };
    final resp = await dio.get('/archives/periods', queryParameters: params);
    final List<dynamic> periods = resp.data is List ? resp.data : [];

    // Фильтруем по выбранному диапазону
    final fromDt = DateTime.tryParse(_periodFrom ?? '');
    final toDt = DateTime.tryParse(_periodTo ?? '');

    final filtered = periods.where((p) {
      final pDate = DateTime.tryParse(p['period']?.toString() ?? '');
      if (pDate == null) return true;
      if (fromDt != null && pDate.isBefore(fromDt)) return false;
      if (toDt != null && pDate.isAfter(toDt.add(const Duration(days: 31)))) return false;
      return true;
    }).toList();

    _reportResult['monthly_dynamics'] = filtered;
  }

  Future<void> _fetchByServices(Dio dio) async {
    final params = <String, dynamic>{
      'sort_by': 'debt_end',
      'sort_order': 'desc',
      'limit': 2000,
      if (_periodTo != null) 'period_date': _periodTo,
      if (_selectedLocationId != null) 'location_id': _selectedLocationId,
    };
    final resp = await dio.get('/payment-documents/', queryParameters: params);
    final data = resp.data;
    final List docs = data is List ? data : (data is Map ? (data['items'] ?? []) : []);

    // Агрегация по услугам на клиенте
    const services = ['heating', 'hot_water', 'maintenance', 'waste', 'odn_electricity', 'odn_water'];
    const labels = {
      'heating': 'Отопление', 'hot_water': 'ГВС', 'maintenance': 'Содержание',
      'waste': 'ТБО', 'odn_electricity': 'ОДН (эл)', 'odn_water': 'ОДН (вода)',
    };

    final result = <Map<String, dynamic>>[];
    for (final svc in services) {
      double ch = 0, pd = 0, debt = 0;
      for (final doc in docs) {
        ch += (doc['charged_$svc'] as num?)?.toDouble() ?? 0;
        pd += (doc['paid_$svc'] as num?)?.toDouble() ?? 0;
        debt += (doc['debt_${svc}_end'] as num?)?.toDouble() ?? 0;
      }
      if (ch > 0 || debt != 0) {
        result.add({'key': svc, 'label': labels[svc] ?? svc, 'charged': ch, 'paid': pd, 'debt': debt});
      }
    }
    result.sort((a, b) => ((b['charged'] as double) - (a['charged'] as double)).sign.toInt());
    _reportResult['by_services'] = result;
  }

  Future<void> _fetchOverpayments(Dio dio) async {
    final params = <String, dynamic>{
      'has_overpayment': true,
      'sort_by': 'debt_end',
      'sort_order': 'asc',
      'limit': _topN,
      if (_periodTo != null) 'period_date': _periodTo,
      if (_selectedLocationId != null) 'location_id': _selectedLocationId,
    };
    final resp = await dio.get('/payment-documents/', queryParameters: params);
    final data = resp.data;
    final List items = data is List ? data : (data is Map ? (data['items'] ?? []) : []);
    _reportResult['overpayments'] = items;
  }

  Future<void> _fetchBestPayers(Dio dio) async {
    final params = <String, dynamic>{
      'sort_by': 'total_paid',
      'sort_order': 'desc',
      'limit': 200,
      if (_periodTo != null) 'period_date': _periodTo,
      if (_selectedLocationId != null) 'location_id': _selectedLocationId,
    };
    final resp = await dio.get('/payment-documents/', queryParameters: params);
    final data = resp.data;
    final List items = data is List ? data : (data is Map ? (data['items'] ?? []) : []);

    // Считаем % оплаты, сортируем
    final scored = items.map((d) {
      final charged = (d['total_charged'] as num?)?.toDouble() ?? 0;
      final paid = (d['total_paid'] as num?)?.toDouble() ?? 0;
      final pct = charged > 0 ? (paid / charged * 100).clamp(0.0, 100.0) : 0.0;
      return {...(d as Map<String, dynamic>), '_pay_percent': pct};
    }).where((d) => (d['total_charged'] as num?)?.toDouble() != null && (d['total_charged'] as num).toDouble() > 0)
    .toList();

    scored.sort((a, b) => (b['_pay_percent'] as double).compareTo(a['_pay_percent'] as double));
    _reportResult['best_payers'] = scored.take(_topN).toList();
  }

  // ═══════════════════════════════════════════════════════════════════════
  // PROGRESS VIEW
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildGeneratingView(ThemeData theme, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated icon
            AnimatedBuilder(
              animation: _pulseController,
              builder: (_, child) => Transform.scale(
                scale: 0.9 + _pulseController.value * 0.2,
                child: child,
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF667EEA), const Color(0xFF764BA2)]
                        : [const Color(0xFF667EEA), const Color(0xFF764BA2)],
                  ),
                ),
                child: const Icon(Icons.auto_graph, color: Colors.white, size: 40),
              ),
            ),
            const SizedBox(height: 32),
            Text('Формирование отчёта', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface)),
            const SizedBox(height: 8),
            Text(_progressLabel, style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 24),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: _progress,
                minHeight: 8,
                backgroundColor: isDark ? Colors.white.withAlpha(15) : Colors.grey.shade200,
              ),
            ),
            const SizedBox(height: 12),
            Text('${(_progress * 100).toStringAsFixed(0)}%',
                style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // РЕЗУЛЬТАТ ОТЧЁТА
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildReportView(ThemeData theme, bool isDark) {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Ошибка', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface)),
              const SizedBox(height: 8),
              Text(_error!, style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              FilledButton(onPressed: _generateReport, child: const Text('Повторить')),
            ],
          ),
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Поиск
          _buildSearchBar(theme, isDark),
          const SizedBox(height: 12),

          // Фильтры (applied)
          _buildAppliedFilters(theme, isDark),
          const SizedBox(height: 16),

          // Секции
          if (_reportResult.containsKey('summary'))
            _buildSummaryCard(theme, isDark),
          if (_reportResult.containsKey('top_houses'))
            _buildTopHousesCard(theme, isDark),
          if (_reportResult.containsKey('top_debtors'))
            _buildTopDebtorsCard(theme, isDark),
          if (_reportResult.containsKey('last_payments'))
            _buildLastPaymentsCard(theme, isDark),
          if (_reportResult.containsKey('monthly_dynamics'))
            _buildMonthlyDynamicsCard(theme, isDark),
          if (_reportResult.containsKey('by_services'))
            _buildByServicesCard(theme, isDark),
          if (_reportResult.containsKey('overpayments'))
            _buildOverpaymentsCard(theme, isDark),
          if (_reportResult.containsKey('best_payers'))
            _buildBestPayersCard(theme, isDark),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildAppliedFilters(ThemeData theme, bool isDark) {
    return Wrap(
      spacing: 6, runSpacing: 6,
      children: [
        _filterChip(Icons.calendar_month, '${_formatPeriod(_periodFrom)} — ${_formatPeriod(_periodTo)}', Colors.blue),
        _filterChip(Icons.home, _selectedLocationName, Colors.orange),
        _filterChip(Icons.format_list_numbered, 'Топ-$_topN', Colors.purple),
        if (_debtThreshold > 0)
          _filterChip(Icons.filter_alt, 'Порог: ${_debtThreshold.toStringAsFixed(0)}₽', Colors.red),
      ],
    );
  }

  Widget _filterChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  // ─── REPORT SECTION CARDS ───

  Widget _reportSectionCard(ThemeData theme, bool isDark, {
    required IconData icon, required String title, required Color color,
    required Widget child, String? subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDark ? theme.colorScheme.surface : Colors.white,
        border: Border.all(color: theme.dividerColor.withAlpha(isDark ? 30 : 60)),
        boxShadow: isDark ? null : [
          BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          // Gradient header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20),
              ),
              gradient: LinearGradient(
                colors: [
                  color.withAlpha(isDark ? 40 : 25),
                  color.withAlpha(isDark ? 15 : 8),
                ],
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withAlpha(isDark ? 50 : 30),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 20, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: color)),
                      if (subtitle != null)
                        Text(subtitle, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 1. ОБЩАЯ СВОДКА
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildSummaryCard(ThemeData theme, bool isDark) {
    final data = _reportResult['summary'] as Map<String, dynamic>? ?? {};
    final count = data['count'] as int? ?? 0;
    final totalCharged = (data['total_charged'] as num?)?.toDouble() ?? 0;
    final totalPaid = (data['total_paid'] as num?)?.toDouble() ?? 0;
    final totalDebt = (data['total_debt'] as num?)?.toDouble() ?? 0;
    final debtorsCount = data['debtors_count'] as int? ?? 0;
    final overpaidCount = data['overpaid_count'] as int? ?? 0;
    final collection = totalCharged > 0 ? (totalPaid / totalCharged * 100).clamp(0.0, 100.0) : 0.0;

    return _reportSectionCard(theme, isDark,
      icon: Icons.pie_chart, title: 'Общая сводка', color: Colors.blue,
      subtitle: '$count лицевых счетов',
      child: Column(
        children: [
          // Главные метрики
          Row(
            children: [
              _metricTile(theme, 'Начислено', '${_fmtMoney(totalCharged)}₽', Colors.blue, Icons.receipt_long),
              const SizedBox(width: 8),
              _metricTile(theme, 'Оплачено', '${_fmtMoney(totalPaid)}₽', Colors.green, Icons.check_circle),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _metricTile(theme, 'Долг', '${_fmtMoney(totalDebt)}₽', totalDebt > 0 ? Colors.red : Colors.green, Icons.warning_amber),
              const SizedBox(width: 8),
              _metricTile(theme, 'Собираемость', '${collection.toStringAsFixed(1)}%',
                  collection >= 80 ? Colors.green : collection >= 50 ? Colors.orange : Colors.red, Icons.speed),
            ],
          ),
          const SizedBox(height: 12),
          // Дополнительно
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _miniCounter('Должники', debtorsCount, Colors.red),
              _miniCounter('С переплатой', overpaidCount, Colors.teal),
              _miniCounter('Всего ЛС', count, Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricTile(ThemeData theme, String label, String value, Color color, IconData icon) {
    final isDark = theme.brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: color.withAlpha(isDark ? 20 : 12),
          border: Border.all(color: color.withAlpha(40)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  Widget _miniCounter(String label, int value, Color color) {
    return Column(
      children: [
        Text('$value', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
        Text(label, style: TextStyle(fontSize: 10, color: color.withAlpha(180))),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 2. ТОП ДОМОВ
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildTopHousesCard(ThemeData theme, bool isDark) {
    final houses = (_reportResult['top_houses'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final maxDebt = houses.isNotEmpty
        ? houses.map((h) => (h['total_debt'] as num?)?.toDouble() ?? 0).reduce(max)
        : 1.0;

    return _reportSectionCard(theme, isDark,
      icon: Icons.apartment, title: 'Топ домов по долгу', color: Colors.orange,
      subtitle: '${houses.length} домов',
      child: houses.isEmpty
          ? const Center(child: Text('Нет данных', style: TextStyle(fontSize: 13)))
          : Column(
              children: houses.asMap().entries.map((e) {
                final i = e.key;
                final h = e.value;
                final debt = (h['total_debt'] as num?)?.toDouble() ?? 0;
                final charged = (h['total_charged'] as num?)?.toDouble() ?? 0;
                final paid = (h['total_paid'] as num?)?.toDouble() ?? 0;
                final collection = charged > 0 ? (paid / charged * 100).clamp(0.0, 100.0) : 0.0;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: theme.colorScheme.surfaceContainerHighest.withAlpha(isDark ? 40 : 30),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 28, height: 28,
                            decoration: BoxDecoration(
                              color: Colors.orange.withAlpha(30),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(child: Text('${i + 1}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.orange))),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Text(h['name'] ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                              maxLines: 1, overflow: TextOverflow.ellipsis)),
                          Text('${_fmtMoney(debt)}₽', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                              color: debt > 0 ? Colors.red : Colors.green)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: maxDebt > 0 ? (debt / maxDebt).clamp(0.0, 1.0) : 0,
                          backgroundColor: Colors.grey.withAlpha(30),
                          color: Colors.orange,
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text('${h['count']} ЛС', style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant)),
                          const Spacer(),
                          Text('Собираемость: ${collection.toStringAsFixed(0)}%',
                              style: TextStyle(fontSize: 10, color: collection >= 80 ? Colors.green : Colors.red)),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 3. ТОП ДОЛЖНИКОВ
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildTopDebtorsCard(ThemeData theme, bool isDark) {
    final allItems = (_reportResult['top_debtors'] as List?) ?? [];
    final items = _filterItems<dynamic>(allItems,
      (d) => (d as Map<String, dynamic>)['fio']?.toString() ?? '',
      getLocationName: (d) => (d as Map<String, dynamic>)['location_name']?.toString() ?? '',
      getAddress: (d) => (d as Map<String, dynamic>)['address']?.toString() ?? '',
      getAccountNumber: (d) => (d as Map<String, dynamic>)['account_number']?.toString() ?? '',
    );
    return _reportSectionCard(theme, isDark,
      icon: Icons.person_off, title: 'Топ должников', color: Colors.red,
      subtitle: '${items.length} абонентов',
      child: items.isEmpty
          ? Center(child: Text(_searchQuery.isNotEmpty ? 'Не найдено' : 'Нет должников 🎉', style: const TextStyle(fontSize: 13)))
          : Column(
              children: items.asMap().entries.map((e) {
                final i = e.key;
                final d = e.value as Map<String, dynamic>;
                final debt = (d['total_debt_end'] as num?)?.toDouble() ?? 0;
                final charged = (d['total_charged'] as num?)?.toDouble() ?? 0;
                final pct = charged > 0 ? (debt / charged * 100).clamp(0.0, 100.0) : 0.0;

                final Color sevColor;
                final String sevIcon;
                if (debt > 5000) { sevColor = Colors.red; sevIcon = '🔴'; }
                else if (debt > 1000) { sevColor = Colors.orange; sevIcon = '🟠'; }
                else { sevColor = Colors.amber.shade700; sevIcon = '🟡'; }

                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _showPersonDetail(d),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: sevColor.withAlpha(50)),
                      color: sevColor.withAlpha(isDark ? 10 : 6),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 36, child: Column(children: [
                          Text('${i + 1}', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant)),
                          Text(sevIcon, style: const TextStyle(fontSize: 14)),
                        ])),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(d['fio'] ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                  maxLines: 1, overflow: TextOverflow.ellipsis),
                              Text('${d['address'] ?? ''} • ЛС: ${d['account_number'] ?? ''}',
                                  style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant),
                                  maxLines: 1, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 60,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(3),
                                      child: LinearProgressIndicator(
                                        value: charged > 0 ? min(debt / charged, 1.0) : 0,
                                        backgroundColor: Colors.grey.shade200,
                                        color: sevColor, minHeight: 5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text('${pct.toStringAsFixed(0)}%', style: TextStyle(fontSize: 10, color: sevColor)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${_fmtMoney(debt)}₽', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: sevColor)),
                            Text('из ${_fmtMoney(charged)}₽', style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 4. ПОСЛЕДНИЕ ОПЛАТЫ
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildLastPaymentsCard(ThemeData theme, bool isDark) {
    final allItems = (_reportResult['last_payments'] as List?) ?? [];
    final items = _filterItems<dynamic>(allItems,
      (d) => (d as Map<String, dynamic>)['fio']?.toString() ?? '',
      getLocationName: (d) => (d as Map<String, dynamic>)['location_name']?.toString() ?? '',
      getAddress: (d) => (d as Map<String, dynamic>)['address']?.toString() ?? '',
      getAccountNumber: (d) => (d as Map<String, dynamic>)['account_number']?.toString() ?? '',
    );
    return _reportSectionCard(theme, isDark,
      icon: Icons.payment, title: 'Последние оплаты', color: Colors.green,
      subtitle: '${items.length} абонентов',
      child: items.isEmpty
          ? Center(child: Text(_searchQuery.isNotEmpty ? 'Не найдено' : 'Нет оплат', style: const TextStyle(fontSize: 13)))
          : Column(
              children: items.asMap().entries.map((e) {
                final i = e.key;
                final d = e.value as Map<String, dynamic>;
                final paid = (d['total_paid'] as num?)?.toDouble() ?? 0;
                final debt = (d['total_debt_end'] as num?)?.toDouble() ?? 0;
                final charged = (d['total_charged'] as num?)?.toDouble() ?? 0;
                final address = d['address'] as String? ?? '';
                final locationName = d['location_name'] as String? ?? '';

                String paidMonthsLabel = '';
                if (charged > 0 && paid > 0) {
                  final months = (paid / charged).floor();
                  if (months >= 1) paidMonthsLabel = '≈$months мес.';
                }

                final bool isOverpaid = debt < -0.01;
                final String debtLabel = isOverpaid
                    ? 'переплата: ${_fmtMoney(debt.abs())}₽'
                    : 'долг: ${_fmtMoney(debt)}₽';
                final Color debtColor = isOverpaid ? Colors.teal : (debt > 0.01 ? Colors.red : Colors.green);

                return InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => _showPersonDetail(d),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: theme.colorScheme.surfaceContainerHighest.withAlpha(isDark ? 30 : 20),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 24, child: Text('${i + 1}', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant))),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(d['fio'] ?? '', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                  maxLines: 2, overflow: TextOverflow.ellipsis),
                              if (locationName.isNotEmpty)
                                Text('🏠 $locationName',
                                    style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant),
                                    maxLines: 2, overflow: TextOverflow.ellipsis),
                              if (address.isNotEmpty)
                                Text('📍 $address',
                                    style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant),
                                    maxLines: 2, overflow: TextOverflow.ellipsis),
                              Text('ЛС: ${d['account_number'] ?? ''}',
                                  style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('+${_fmtMoney(paid)}₽', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.green)),
                            Text(debtLabel, style: TextStyle(fontSize: 10, color: debtColor)),
                            if (paidMonthsLabel.isNotEmpty)
                              Text(paidMonthsLabel, style: TextStyle(fontSize: 9, color: theme.colorScheme.onSurfaceVariant)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 5. ДИНАМИКА ПО ПЕРИОДАМ
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildMonthlyDynamicsCard(ThemeData theme, bool isDark) {
    final periods = (_reportResult['monthly_dynamics'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    double maxCharged = 1;
    for (final p in periods) {
      final ch = (p['total_charged'] as num?)?.toDouble() ?? 0;
      if (ch > maxCharged) maxCharged = ch;
    }

    return _reportSectionCard(theme, isDark,
      icon: Icons.show_chart, title: 'Динамика по периодам', color: Colors.cyan,
      subtitle: '${periods.length} периодов',
      child: periods.isEmpty
          ? const Center(child: Text('Нет данных', style: TextStyle(fontSize: 13)))
          : Column(
              children: periods.asMap().entries.map((e) {
                final p = e.value;
                final charged = (p['total_charged'] as num?)?.toDouble() ?? 0;
                final paid = (p['total_paid'] as num?)?.toDouble() ?? 0;
                final debt = (p['total_debt'] as num?)?.toDouble() ?? 0;
                final collection = charged > 0 ? (paid / charged * 100).clamp(0.0, 100.0) : 0.0;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: theme.colorScheme.surfaceContainerHighest.withAlpha(isDark ? 30 : 20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(p['period_label'] ?? _formatPeriod(p['period']?.toString()),
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                          const Spacer(),
                          Text('${p['count'] ?? 0} ЛС', style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Начислено
                      _miniBar('Начисл.', charged, maxCharged, Colors.blue, theme),
                      const SizedBox(height: 4),
                      _miniBar('Оплач.', paid, maxCharged, Colors.green, theme),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text('Долг: ${_fmtMoney(debt)}₽',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: debt > 0 ? Colors.red : Colors.green)),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: (collection >= 80 ? Colors.green : Colors.red).withAlpha(20),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('${collection.toStringAsFixed(0)}%',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                                    color: collection >= 80 ? Colors.green : Colors.red)),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _miniBar(String label, double value, double maxVal, Color color, ThemeData theme) {
    return Row(
      children: [
        SizedBox(width: 55, child: Text(label, style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant))),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: maxVal > 0 ? (value / maxVal).clamp(0.0, 1.0) : 0,
              backgroundColor: Colors.grey.withAlpha(30),
              color: color, minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(width: 65, child: Text('${_fmtMoney(value)}₽', textAlign: TextAlign.right,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color))),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 6. ПО УСЛУГАМ
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildByServicesCard(ThemeData theme, bool isDark) {
    final services = (_reportResult['by_services'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final maxCharged = services.isNotEmpty
        ? services.map((s) => (s['charged'] as num?)?.toDouble() ?? 0).reduce(max)
        : 1.0;

    final svcColors = {
      'heating': Colors.red.shade400,
      'hot_water': Colors.orange.shade400,
      'maintenance': Colors.blue.shade400,
      'waste': Colors.brown.shade400,
      'odn_electricity': Colors.amber.shade600,
      'odn_water': Colors.cyan.shade400,
    };

    return _reportSectionCard(theme, isDark,
      icon: Icons.category, title: 'Разбивка по услугам', color: Colors.amber,
      subtitle: '${services.length} услуг',
      child: services.isEmpty
          ? const Center(child: Text('Нет данных', style: TextStyle(fontSize: 13)))
          : Column(
              children: services.map((s) {
                final charged = (s['charged'] as num?)?.toDouble() ?? 0;
                final paid = (s['paid'] as num?)?.toDouble() ?? 0;
                final debt = (s['debt'] as num?)?.toDouble() ?? 0;
                final color = svcColors[s['key']] ?? Colors.grey;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: color.withAlpha(isDark ? 15 : 8),
                    border: Border.all(color: color.withAlpha(30)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8, height: 8,
                            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 8),
                          Text(s['label'] ?? '', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: maxCharged > 0 ? (charged / maxCharged).clamp(0.0, 1.0) : 0,
                          backgroundColor: Colors.grey.withAlpha(30),
                          color: color, minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Начисл: ${_fmtMoney(charged)}₽', style: TextStyle(fontSize: 10, color: color)),
                          Text('Оплач: ${_fmtMoney(paid)}₽', style: const TextStyle(fontSize: 10, color: Colors.green)),
                          Text('Долг: ${_fmtMoney(debt)}₽',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: debt > 0 ? Colors.red : Colors.green)),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 7. ПЕРЕПЛАТЫ
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildOverpaymentsCard(ThemeData theme, bool isDark) {
    final allItems = (_reportResult['overpayments'] as List?) ?? [];
    final items = _filterItems<dynamic>(allItems,
      (d) => (d as Map<String, dynamic>)['fio']?.toString() ?? '',
      getLocationName: (d) => (d as Map<String, dynamic>)['location_name']?.toString() ?? '',
      getAddress: (d) => (d as Map<String, dynamic>)['address']?.toString() ?? '',
      getAccountNumber: (d) => (d as Map<String, dynamic>)['account_number']?.toString() ?? '',
    );
    return _reportSectionCard(theme, isDark,
      icon: Icons.trending_down, title: 'Переплаты', color: Colors.teal,
      subtitle: '${items.length} абонентов',
      child: items.isEmpty
          ? Center(child: Text(_searchQuery.isNotEmpty ? 'Не найдено' : 'Нет переплат', style: const TextStyle(fontSize: 13)))
          : Column(
              children: items.asMap().entries.map((e) {
                final i = e.key;
                final d = e.value as Map<String, dynamic>;
                final debt = (d['total_debt_end'] as num?)?.toDouble() ?? 0;
                final overpay = debt.abs();
                final locationName = d['location_name']?.toString() ?? '';
                final address = d['address']?.toString() ?? '';

                return InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => _showPersonDetail(d),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.teal.withAlpha(isDark ? 12 : 6),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 24, child: Text('${i + 1}', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant))),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(d['fio'] ?? '', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                  maxLines: 1, overflow: TextOverflow.ellipsis),
                              if (locationName.isNotEmpty)
                                Text('🏠 $locationName', style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant),
                                    maxLines: 1, overflow: TextOverflow.ellipsis),
                              if (address.isNotEmpty)
                                Text('📍 $address', style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant),
                                    maxLines: 1, overflow: TextOverflow.ellipsis),
                              Text('ЛС: ${d['account_number'] ?? ''}',
                                  style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant)),
                            ],
                          ),
                        ),
                        Text('+${_fmtMoney(overpay)}₽', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.teal)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 8. ЛУЧШИЕ ПЛАТЕЛЬЩИКИ
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildBestPayersCard(ThemeData theme, bool isDark) {
    final allItems = (_reportResult['best_payers'] as List?) ?? [];
    final items = _filterItems<dynamic>(allItems,
      (d) => (d as Map<String, dynamic>)['fio']?.toString() ?? '',
      getLocationName: (d) => (d as Map<String, dynamic>)['location_name']?.toString() ?? '',
      getAddress: (d) => (d as Map<String, dynamic>)['address']?.toString() ?? '',
      getAccountNumber: (d) => (d as Map<String, dynamic>)['account_number']?.toString() ?? '',
    );
    return _reportSectionCard(theme, isDark,
      icon: Icons.star, title: 'Лучшие плательщики', color: Colors.purple,
      subtitle: '${items.length} абонентов',
      child: items.isEmpty
          ? Center(child: Text(_searchQuery.isNotEmpty ? 'Не найдено' : 'Нет данных', style: const TextStyle(fontSize: 13)))
          : Column(
              children: items.asMap().entries.map((e) {
                final i = e.key;
                final d = e.value as Map<String, dynamic>;
                final pct = (d['_pay_percent'] as num?)?.toDouble() ?? 0;
                final paid = (d['total_paid'] as num?)?.toDouble() ?? 0;
                final locationName = d['location_name']?.toString() ?? '';
                final address = d['address']?.toString() ?? '';

                String medal = '';
                if (i == 0) medal = '🥇';
                if (i == 1) medal = '🥈';
                if (i == 2) medal = '🥉';

                return InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => _showPersonDetail(d),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: i < 3 ? Colors.purple.withAlpha(isDark ? 15 : 8) : Colors.transparent,
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 30, child: Text(
                          medal.isNotEmpty ? medal : '${i + 1}',
                          style: TextStyle(fontSize: medal.isNotEmpty ? 18 : 11, color: theme.colorScheme.onSurfaceVariant),
                        )),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(d['fio'] ?? '', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                  maxLines: 1, overflow: TextOverflow.ellipsis),
                              if (locationName.isNotEmpty)
                                Text('🏠 $locationName', style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant),
                                    maxLines: 1, overflow: TextOverflow.ellipsis),
                              if (address.isNotEmpty)
                                Text('📍 $address', style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant),
                                    maxLines: 1, overflow: TextOverflow.ellipsis),
                              Text('Оплачено: ${_fmtMoney(paid)}₽',
                                  style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.purple.withAlpha(20),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text('${pct.toStringAsFixed(0)}%',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.purple)),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // ЭКСПОРТ PDF
  // ═══════════════════════════════════════════════════════════════════════

  Future<void> _exportPdf() async {
    setState(() => _isExporting = true);
    try {
      // Загружаем кириллический шрифт
      final fontData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
      final ttf = pw.Font.ttf(fontData);

      final pdf = pw.Document(
        theme: pw.ThemeData.withFont(base: ttf, bold: ttf),
      );
      final periodLabel = '${_formatPeriod(_periodFrom)} — ${_formatPeriod(_periodTo)}';

      pdf.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Аналитический отчёт', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            pw.Text('Период: $periodLabel • Дом: $_selectedLocationName',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
            pw.Divider(),
          ],
        ),
        footer: (ctx) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('TeploService', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
            pw.Text('Стр. ${ctx.pageNumber}/${ctx.pagesCount}',
                style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
          ],
        ),
        build: (ctx) => [
          // SUMMARY
          if (_reportResult.containsKey('summary')) ...[
            _pdfSectionTitle('Общая сводка'),
            _pdfSummaryTable(),
            pw.SizedBox(height: 12),
          ],
          // TOP HOUSES
          if (_reportResult.containsKey('top_houses')) ...[
            _pdfSectionTitle('Топ домов по долгу'),
            _pdfTopHousesTable(),
            pw.SizedBox(height: 12),
          ],
          // TOP DEBTORS
          if (_reportResult.containsKey('top_debtors')) ...[
            _pdfSectionTitle('Топ должников'),
            _pdfDebtorsTable(),
            pw.SizedBox(height: 12),
          ],
          // LAST PAYMENTS
          if (_reportResult.containsKey('last_payments')) ...[
            _pdfSectionTitle('Последние оплаты'),
            _pdfPaymentsTable(),
            pw.SizedBox(height: 12),
          ],
          // MONTHLY DYNAMICS
          if (_reportResult.containsKey('monthly_dynamics')) ...[
            _pdfSectionTitle('Динамика по периодам'),
            _pdfMonthlyTable(),
            pw.SizedBox(height: 12),
          ],
          // BY SERVICES
          if (_reportResult.containsKey('by_services')) ...[
            _pdfSectionTitle('Разбивка по услугам'),
            _pdfServicesTable(),
            pw.SizedBox(height: 12),
          ],
          // OVERPAYMENTS
          if (_reportResult.containsKey('overpayments')) ...[
            _pdfSectionTitle('Переплаты'),
            _pdfOverpaymentsTable(),
            pw.SizedBox(height: 12),
          ],
          // BEST PAYERS
          if (_reportResult.containsKey('best_payers')) ...[
            _pdfSectionTitle('Лучшие плательщики'),
            _pdfBestPayersTable(),
          ],
        ],
      ));

      final dir = await getTemporaryDirectory();
      final fileName = 'report_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      if (mounted) {
        final savedPath = await FileExportHelper.exportFile(
          sourceFile: file,
          fileName: fileName,
          mimeType: 'application/pdf',
          subject: 'Аналитический отчёт TeploService',
        );
        if (savedPath != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('✅ Сохранено: $savedPath'), backgroundColor: Colors.green),
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

  // ── PDF helpers ──

  pw.Widget _pdfSectionTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Text(title, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800)),
    );
  }

  pw.Widget _pdfSummaryTable() {
    final data = _reportResult['summary'] as Map<String, dynamic>? ?? {};
    final totalCharged = (data['total_charged'] as num?)?.toDouble() ?? 0;
    final totalPaid = (data['total_paid'] as num?)?.toDouble() ?? 0;
    final totalDebt = (data['total_debt'] as num?)?.toDouble() ?? 0;
    final count = data['count'] as int? ?? 0;
    final debtorsCount = data['debtors_count'] as int? ?? 0;
    final collection = totalCharged > 0 ? (totalPaid / totalCharged * 100).clamp(0.0, 100.0) : 0.0;

    return pw.TableHelper.fromTextArray(
      headers: ['Показатель', 'Значение'],
      data: [
        ['Лицевых счетов', '$count'],
        ['Начислено', '${totalCharged.toStringAsFixed(2)} ₽'],
        ['Оплачено', '${totalPaid.toStringAsFixed(2)} ₽'],
        ['Долг', '${totalDebt.toStringAsFixed(2)} ₽'],
        ['Должников', '$debtorsCount'],
        ['Собираемость', '${collection.toStringAsFixed(1)}%'],
      ],
      cellStyle: const pw.TextStyle(fontSize: 9),
      headerStyle: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
      cellAlignments: {0: pw.Alignment.centerLeft, 1: pw.Alignment.centerRight},
    );
  }

  pw.Widget _pdfTopHousesTable() {
    final houses = (_reportResult['top_houses'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    return pw.TableHelper.fromTextArray(
      headers: ['#', 'Дом', 'ЛС', 'Начислено', 'Оплачено', 'Долг'],
      data: houses.asMap().entries.map((e) {
        final h = e.value;
        return [
          '${e.key + 1}',
          h['name'] ?? '',
          '${h['count'] ?? 0}',
          '${((h['total_charged'] as num?)?.toDouble() ?? 0).toStringAsFixed(2)}',
          '${((h['total_paid'] as num?)?.toDouble() ?? 0).toStringAsFixed(2)}',
          '${((h['total_debt'] as num?)?.toDouble() ?? 0).toStringAsFixed(2)}',
        ];
      }).toList(),
      cellStyle: const pw.TextStyle(fontSize: 8),
      headerStyle: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.orange50),
      cellAlignments: {0: pw.Alignment.center, 3: pw.Alignment.centerRight, 4: pw.Alignment.centerRight, 5: pw.Alignment.centerRight},
    );
  }

  pw.Widget _pdfDebtorsTable() {
    final items = (_reportResult['top_debtors'] as List?) ?? [];
    return pw.TableHelper.fromTextArray(
      headers: ['#', 'ФИО', 'Адрес', 'ЛС', 'Начислено', 'Долг'],
      data: items.asMap().entries.map((e) {
        final d = e.value as Map<String, dynamic>;
        return [
          '${e.key + 1}',
          d['fio'] ?? '',
          d['address'] ?? '',
          d['account_number'] ?? '',
          '${((d['total_charged'] as num?)?.toDouble() ?? 0).toStringAsFixed(2)}',
          '${((d['total_debt_end'] as num?)?.toDouble() ?? 0).toStringAsFixed(2)}',
        ];
      }).toList(),
      cellStyle: const pw.TextStyle(fontSize: 8),
      headerStyle: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.red50),
      cellAlignments: {0: pw.Alignment.center, 4: pw.Alignment.centerRight, 5: pw.Alignment.centerRight},
    );
  }

  pw.Widget _pdfPaymentsTable() {
    final items = (_reportResult['last_payments'] as List?) ?? [];
    return pw.TableHelper.fromTextArray(
      headers: ['#', 'ФИО', 'Дом', 'Адрес', 'ЛС', 'Оплачено', 'Долг/Переплата', 'Мес.'],
      data: items.asMap().entries.map((e) {
        final d = e.value as Map<String, dynamic>;
        final paid = (d['total_paid'] as num?)?.toDouble() ?? 0;
        final debt = (d['total_debt_end'] as num?)?.toDouble() ?? 0;
        final charged = (d['total_charged'] as num?)?.toDouble() ?? 0;
        final isOverpaid = debt < -0.01;
        final debtStr = isOverpaid
            ? '+${debt.abs().toStringAsFixed(2)} (переплата)'
            : debt.toStringAsFixed(2);
        final months = charged > 0 ? (paid / charged).floor() : 0;
        return [
          '${e.key + 1}',
          d['fio'] ?? '',
          d['location_name'] ?? '',
          d['address'] ?? '',
          d['account_number'] ?? '',
          paid.toStringAsFixed(2),
          debtStr,
          months >= 1 ? '$months' : '-',
        ];
      }).toList(),
      cellStyle: const pw.TextStyle(fontSize: 7),
      headerStyle: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.green50),
      cellAlignments: {0: pw.Alignment.center, 5: pw.Alignment.centerRight, 6: pw.Alignment.centerRight, 7: pw.Alignment.center},
    );
  }

  pw.Widget _pdfMonthlyTable() {
    final periods = (_reportResult['monthly_dynamics'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    return pw.TableHelper.fromTextArray(
      headers: ['Период', 'ЛС', 'Начислено', 'Оплачено', 'Долг', '%'],
      data: periods.map((p) {
        final charged = (p['total_charged'] as num?)?.toDouble() ?? 0;
        final paid = (p['total_paid'] as num?)?.toDouble() ?? 0;
        final debt = (p['total_debt'] as num?)?.toDouble() ?? 0;
        final coll = charged > 0 ? (paid / charged * 100).clamp(0.0, 100.0) : 0.0;
        return [
          p['period_label'] ?? p['period'] ?? '',
          '${p['count'] ?? 0}',
          charged.toStringAsFixed(2),
          paid.toStringAsFixed(2),
          debt.toStringAsFixed(2),
          '${coll.toStringAsFixed(1)}%',
        ];
      }).toList(),
      cellStyle: const pw.TextStyle(fontSize: 8),
      headerStyle: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.cyan50),
      cellAlignments: {1: pw.Alignment.center, 2: pw.Alignment.centerRight, 3: pw.Alignment.centerRight, 4: pw.Alignment.centerRight, 5: pw.Alignment.centerRight},
    );
  }

  pw.Widget _pdfServicesTable() {
    final services = (_reportResult['by_services'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    return pw.TableHelper.fromTextArray(
      headers: ['Услуга', 'Начислено', 'Оплачено', 'Долг'],
      data: services.map((s) {
        return [
          s['label'] ?? '',
          '${((s['charged'] as num?)?.toDouble() ?? 0).toStringAsFixed(2)}',
          '${((s['paid'] as num?)?.toDouble() ?? 0).toStringAsFixed(2)}',
          '${((s['debt'] as num?)?.toDouble() ?? 0).toStringAsFixed(2)}',
        ];
      }).toList(),
      cellStyle: const pw.TextStyle(fontSize: 8),
      headerStyle: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.amber50),
      cellAlignments: {1: pw.Alignment.centerRight, 2: pw.Alignment.centerRight, 3: pw.Alignment.centerRight},
    );
  }

  pw.Widget _pdfOverpaymentsTable() {
    final items = (_reportResult['overpayments'] as List?) ?? [];
    return pw.TableHelper.fromTextArray(
      headers: ['#', 'ФИО', 'Дом', 'Адрес', 'ЛС', 'Переплата'],
      data: items.asMap().entries.map((e) {
        final d = e.value as Map<String, dynamic>;
        final debt = (d['total_debt_end'] as num?)?.toDouble() ?? 0;
        return [
          '${e.key + 1}',
          d['fio'] ?? '',
          d['location_name'] ?? '',
          d['address'] ?? '',
          d['account_number'] ?? '',
          '${debt.abs().toStringAsFixed(2)}',
        ];
      }).toList(),
      cellStyle: const pw.TextStyle(fontSize: 8),
      headerStyle: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.teal50),
      cellAlignments: {0: pw.Alignment.center, 5: pw.Alignment.centerRight},
    );
  }

  pw.Widget _pdfBestPayersTable() {
    final items = (_reportResult['best_payers'] as List?) ?? [];
    return pw.TableHelper.fromTextArray(
      headers: ['#', 'ФИО', 'Дом', 'Адрес', 'ЛС', 'Оплачено', '% оплаты'],
      data: items.asMap().entries.map((e) {
        final d = e.value as Map<String, dynamic>;
        final paid = (d['total_paid'] as num?)?.toDouble() ?? 0;
        final pct = (d['_pay_percent'] as num?)?.toDouble() ?? 0;
        return [
          '${e.key + 1}',
          d['fio'] ?? '',
          d['location_name'] ?? '',
          d['address'] ?? '',
          d['account_number'] ?? '',
          paid.toStringAsFixed(2),
          '${pct.toStringAsFixed(1)}%',
        ];
      }).toList(),
      cellStyle: const pw.TextStyle(fontSize: 7),
      headerStyle: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.purple50),
      cellAlignments: {0: pw.Alignment.center, 5: pw.Alignment.centerRight, 6: pw.Alignment.centerRight},
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // ЭКСПОРТ CSV
  // ═══════════════════════════════════════════════════════════════════════

  Future<void> _exportCsv() async {
    setState(() => _isExporting = true);
    try {
      final buf = StringBuffer();
      buf.writeln('Аналитический отчёт TeploService');
      buf.writeln('Период: ${_formatPeriod(_periodFrom)} — ${_formatPeriod(_periodTo)}');
      buf.writeln('Дом: $_selectedLocationName');
      buf.writeln();

      // SUMMARY
      if (_reportResult.containsKey('summary')) {
        final data = _reportResult['summary'] as Map<String, dynamic>? ?? {};
        buf.writeln('=== ОБЩАЯ СВОДКА ===');
        buf.writeln('Показатель;Значение');
        buf.writeln('Лицевых счетов;${data['count'] ?? 0}');
        buf.writeln('Начислено;${(data['total_charged'] as num?)?.toDouble() ?? 0}');
        buf.writeln('Оплачено;${(data['total_paid'] as num?)?.toDouble() ?? 0}');
        buf.writeln('Долг;${(data['total_debt'] as num?)?.toDouble() ?? 0}');
        buf.writeln('Должников;${data['debtors_count'] ?? 0}');
        buf.writeln();
      }

      // TOP HOUSES
      if (_reportResult.containsKey('top_houses')) {
        final houses = (_reportResult['top_houses'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        buf.writeln('=== ТОП ДОМОВ ===');
        buf.writeln('#;Дом;ЛС;Начислено;Оплачено;Долг');
        for (var i = 0; i < houses.length; i++) {
          final h = houses[i];
          buf.writeln('${i + 1};${h['name']};${h['count']};${h['total_charged']};${h['total_paid']};${h['total_debt']}');
        }
        buf.writeln();
      }

      // TOP DEBTORS
      if (_reportResult.containsKey('top_debtors')) {
        final items = (_reportResult['top_debtors'] as List?) ?? [];
        buf.writeln('=== ТОП ДОЛЖНИКОВ ===');
        buf.writeln('#;ФИО;Адрес;ЛС;Начислено;Долг');
        for (var i = 0; i < items.length; i++) {
          final d = items[i] as Map<String, dynamic>;
          buf.writeln('${i + 1};${d['fio']};${d['address']};${d['account_number']};${d['total_charged']};${d['total_debt_end']}');
        }
        buf.writeln();
      }

      // LAST PAYMENTS
      if (_reportResult.containsKey('last_payments')) {
        final items = (_reportResult['last_payments'] as List?) ?? [];
        buf.writeln('=== ПОСЛЕДНИЕ ОПЛАТЫ ===');
        buf.writeln('#;ФИО;Дом;Адрес;ЛС;Оплачено;Долг/Переплата;Мес.');
        for (var i = 0; i < items.length; i++) {
          final d = items[i] as Map<String, dynamic>;
          final paid = (d['total_paid'] as num?)?.toDouble() ?? 0;
          final debt = (d['total_debt_end'] as num?)?.toDouble() ?? 0;
          final charged = (d['total_charged'] as num?)?.toDouble() ?? 0;
          final isOverpaid = debt < -0.01;
          final debtStr = isOverpaid ? '+${debt.abs().toStringAsFixed(2)} (переплата)' : debt.toStringAsFixed(2);
          final months = charged > 0 ? (paid / charged).floor() : 0;
          buf.writeln('${i + 1};${d['fio']};${d['location_name'] ?? ''};${d['address'] ?? ''};${d['account_number']};${paid.toStringAsFixed(2)};$debtStr;${months >= 1 ? '$months' : '-'}');
        }
        buf.writeln();
      }

      // MONTHLY
      if (_reportResult.containsKey('monthly_dynamics')) {
        final periods = (_reportResult['monthly_dynamics'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        buf.writeln('=== ДИНАМИКА ===');
        buf.writeln('Период;ЛС;Начислено;Оплачено;Долг');
        for (final p in periods) {
          buf.writeln('${p['period_label'] ?? p['period']};${p['count']};${p['total_charged']};${p['total_paid']};${p['total_debt']}');
        }
        buf.writeln();
      }

      // BY SERVICES
      if (_reportResult.containsKey('by_services')) {
        final svcs = (_reportResult['by_services'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        buf.writeln('=== ПО УСЛУГАМ ===');
        buf.writeln('Услуга;Начислено;Оплачено;Долг');
        for (final s in svcs) {
          buf.writeln('${s['label']};${s['charged']};${s['paid']};${s['debt']}');
        }
        buf.writeln();
      }

      // OVERPAYMENTS
      if (_reportResult.containsKey('overpayments')) {
        final items = (_reportResult['overpayments'] as List?) ?? [];
        buf.writeln('=== ПЕРЕПЛАТЫ ===');
        buf.writeln('#;ФИО;Дом;Адрес;ЛС;Переплата');
        for (var i = 0; i < items.length; i++) {
          final d = items[i] as Map<String, dynamic>;
          final debt = (d['total_debt_end'] as num?)?.toDouble() ?? 0;
          buf.writeln('${i + 1};${d['fio']};${d['location_name'] ?? ''};${d['address'] ?? ''};${d['account_number']};${debt.abs()}');
        }
        buf.writeln();
      }

      // BEST PAYERS
      if (_reportResult.containsKey('best_payers')) {
        final items = (_reportResult['best_payers'] as List?) ?? [];
        buf.writeln('=== ЛУЧШИЕ ПЛАТЕЛЬЩИКИ ===');
        buf.writeln('#;ФИО;Дом;Адрес;ЛС;Оплачено;% оплаты');
        for (var i = 0; i < items.length; i++) {
          final d = items[i] as Map<String, dynamic>;
          buf.writeln('${i + 1};${d['fio']};${d['location_name'] ?? ''};${d['address'] ?? ''};${d['account_number']};${d['total_paid']};${(d['_pay_percent'] as num?)?.toDouble().toStringAsFixed(1) ?? '0'}%');
        }
      }

      final dir = await getTemporaryDirectory();
      final fileName = 'report_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(utf8.encode(buf.toString()), flush: true);

      if (mounted) {
        final savedPath = await FileExportHelper.exportFile(
          sourceFile: file,
          fileName: fileName,
          mimeType: 'text/csv',
          subject: 'Аналитический отчёт TeploService (CSV)',
        );
        if (savedPath != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('✅ Сохранено: $savedPath'), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Ошибка CSV: $e'), backgroundColor: Colors.red),
        );
      }
    }
    setState(() => _isExporting = false);
  }

  // ═══════════════════════════════════════════════════════════════════════
  // ПОИСК В РЕЗУЛЬТАТАХ
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildSearchBar(ThemeData theme, bool isDark) {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Поиск: ФИО или дом,кв (напр. 33,4)',
        hintStyle: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant.withAlpha(150)),
        prefixIcon: const Icon(Icons.search, size: 20),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () => setState(() {
                  _searchController.clear();
                  _searchQuery = '';
                }),
              )
            : null,
        isDense: true,
        filled: true,
        fillColor: isDark ? theme.colorScheme.surfaceContainerHigh : Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
      onChanged: (v) => setState(() => _searchQuery = v.trim()),
    );
  }

  /// Фильтрует список документов по поисковому запросу.
  /// Формат "33,4" → дом содержит "33" И адрес содержит "4".
  /// Иначе — поиск по ФИО, адресу, ЛС.
  List<T> _filterItems<T>(List<T> items, String Function(T) getFio,
      {String Function(T)? getLocationName, String Function(T)? getAddress,
      String Function(T)? getAccountNumber}) {
    if (_searchQuery.isEmpty) return items;
    final q = _searchQuery.toLowerCase();

    // Формат "дом,кв"
    if (q.contains(',')) {
      final parts = q.split(',');
      final housePart = parts[0].trim();
      final aptPart = parts.length > 1 ? parts[1].trim() : '';
      return items.where((item) {
        final loc = (getLocationName?.call(item) ?? '').toLowerCase();
        final addr = (getAddress?.call(item) ?? '').toLowerCase();
        final matchHouse = housePart.isEmpty || loc.contains(housePart) || addr.contains(housePart);
        final matchApt = aptPart.isEmpty || addr.contains(aptPart);
        return matchHouse && matchApt;
      }).toList();
    }

    // Обычный поиск
    return items.where((item) {
      final fio = getFio(item).toLowerCase();
      final loc = (getLocationName?.call(item) ?? '').toLowerCase();
      final addr = (getAddress?.call(item) ?? '').toLowerCase();
      final acc = (getAccountNumber?.call(item) ?? '').toLowerCase();
      return fio.contains(q) || loc.contains(q) || addr.contains(q) || acc.contains(q);
    }).toList();
  }

  // ═══════════════════════════════════════════════════════════════════════
  // ДЕТАЛИ СОБСТВЕННИКА (bottom sheet)
  // ═══════════════════════════════════════════════════════════════════════

  void _showPersonDetail(Map<String, dynamic> doc) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    const services = ['heating', 'hot_water', 'maintenance', 'waste', 'odn_electricity', 'odn_water'];
    const serviceLabels = {
      'heating': 'Отопление', 'hot_water': 'ГВС', 'maintenance': 'Содержание',
      'waste': 'ТБО', 'odn_electricity': 'ОДН (эл)', 'odn_water': 'ОДН (вода)',
    };

    final totalCharged = (doc['total_charged'] as num?)?.toDouble() ?? 0;
    final totalPaid = (doc['total_paid'] as num?)?.toDouble() ?? 0;
    final totalDebt = (doc['total_debt_end'] as num?)?.toDouble() ?? 0;
    final collection = totalCharged > 0 ? (totalPaid / totalCharged * 100).clamp(0.0, 100.0) : 0.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollCtrl) => ListView(
          controller: scrollCtrl,
          padding: const EdgeInsets.all(20),
          children: [
            // Handle
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // ФИО
            Text(doc['fio'] ?? 'Без имени',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),

            // Дом, адрес, ЛС
            if ((doc['location_name'] ?? '').toString().isNotEmpty)
              _detailRow(Icons.apartment, 'Дом', doc['location_name']),
            if ((doc['address'] ?? '').toString().isNotEmpty)
              _detailRow(Icons.place, 'Адрес', doc['address']),
            _detailRow(Icons.badge, 'Лицевой счёт', doc['account_number'] ?? '—'),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),

            // Финансы
            Text('Финансы', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary)),
            const SizedBox(height: 12),
            Row(
              children: [
                _detailMetric('Начислено', totalCharged, Colors.blue),
                const SizedBox(width: 8),
                _detailMetric('Оплачено', totalPaid, Colors.green),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _detailMetric('Долг', totalDebt, totalDebt > 0 ? Colors.red : Colors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: (collection >= 80 ? Colors.green : Colors.red).withAlpha(isDark ? 20 : 12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${collection.toStringAsFixed(1)}%',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800,
                                color: collection >= 80 ? Colors.green : Colors.red)),
                        Text('Собираемость', style: TextStyle(fontSize: 10,
                            color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),

            // Детализация по услугам
            Text('По услугам', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary)),
            const SizedBox(height: 8),

            ...services.where((svc) {
              final ch = (doc['charged_$svc'] as num?)?.toDouble() ?? 0;
              final de = (doc['debt_${svc}_end'] as num?)?.toDouble() ?? 0;
              return ch != 0 || de != 0;
            }).map((svc) {
              final ch = (doc['charged_$svc'] as num?)?.toDouble() ?? 0;
              final pd = (doc['paid_$svc'] as num?)?.toDouble() ?? 0;
              final de = (doc['debt_${svc}_end'] as num?)?.toDouble() ?? 0;
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: isDark ? theme.colorScheme.surfaceContainerHigh : Colors.grey.shade50,
                ),
                child: Row(
                  children: [
                    Expanded(flex: 3, child: Text(serviceLabels[svc] ?? svc,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                    Expanded(flex: 2, child: Text('${ch.toStringAsFixed(0)}₽',
                        style: const TextStyle(fontSize: 11, color: Colors.blue), textAlign: TextAlign.right)),
                    Expanded(flex: 2, child: Text('${pd.toStringAsFixed(0)}₽',
                        style: const TextStyle(fontSize: 11, color: Colors.green), textAlign: TextAlign.right)),
                    Expanded(flex: 2, child: Text('${de.toStringAsFixed(0)}₽',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                            color: de > 0 ? Colors.red : Colors.green), textAlign: TextAlign.right)),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Text('$label: ', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  Widget _detailMetric(String label, double value, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: color.withAlpha(isDark ? 20 : 12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${_fmtMoney(value)}₽',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
            Text(label, style: TextStyle(fontSize: 10,
                color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // УТИЛИТЫ
  // ═══════════════════════════════════════════════════════════════════════

  String _formatPeriod(String? s) {
    if (s == null) return '—';
    final dt = DateTime.tryParse(s);
    if (dt == null) return s;
    const months = [
      '', 'Янв', 'Фев', 'Мар', 'Апр', 'Май', 'Июн',
      'Июл', 'Авг', 'Сен', 'Окт', 'Ноя', 'Дек',
    ];
    return '${months[dt.month]} ${dt.year}';
  }

  String _fmtMoney(double v) {
    if (v.abs() >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v.abs() >= 10000) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Модели
// ═══════════════════════════════════════════════════════════════════════

class _SectionDef {
  final String key;
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _SectionDef(this.key, this.icon, this.color, this.title, this.subtitle);
}
