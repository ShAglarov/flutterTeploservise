import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/base_api_service.dart';
import '../../services/file_export_helper.dart';
import 'reports.dart';
import 'report_sections/report_sections.dart';

/// ═══════════════════════════════════════════════════════════════════════
/// Конструктор аналитических отчётов
/// ═══════════════════════════════════════════════════════════════════════

class CustomReportScreen extends ConsumerStatefulWidget {
  const CustomReportScreen({super.key});

  @override
  ConsumerState<CustomReportScreen> createState() => _CustomReportScreenState();
}

class _CustomReportScreenState extends ConsumerState<CustomReportScreen>
    with TickerProviderStateMixin, ReportFetchers {
  // ── Конфигурация ──
  final Map<String, bool> _sections = defaultSections();

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

  // ── Mixin getters ──
  @override String? get periodFrom => _periodFrom;
  @override String? get periodTo => _periodTo;
  @override int? get selectedLocationId => _selectedLocationId;
  @override int get topN => _topN;
  @override double get debtThreshold => _debtThreshold;
  @override Map<String, dynamic> get reportResult => _reportResult;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
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
          _periodFrom = periods.last;
          _periodTo = periods.first;
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
            IconButton(icon: const Icon(Icons.picture_as_pdf), tooltip: 'Экспорт PDF', onPressed: _exportPdf),
            IconButton(icon: const Icon(Icons.table_chart_outlined), tooltip: 'Экспорт CSV', onPressed: _exportCsv),
            IconButton(icon: const Icon(Icons.refresh), tooltip: 'Пересоздать', onPressed: _generateReport),
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
          child: Row(
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withAlpha(40)),
                ),
                child: Text('$_selectedCount секц.',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),

        // Контент
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ─── Пресеты ───
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _presetChip(theme, isDark, '📊', 'Руководителю',
                          ['summary', 'top_houses', 'monthly_dynamics', 'payment_trend', 'location_comparison']),
                      const SizedBox(width: 8),
                      _presetChip(theme, isDark, '💰', 'Бухгалтеру',
                          ['summary', 'by_services', 'recalc_analysis', 'last_payments', 'overpayments']),
                      const SizedBox(width: 8),
                      _presetChip(theme, isDark, '⚖️', 'Юристу',
                          ['top_debtors', 'debt_aging', 'overpayments']),
                      const SizedBox(width: 8),
                      _presetChip(theme, isDark, '✅', 'Все', _sections.keys.toList()),
                      const SizedBox(width: 8),
                      _presetChip(theme, isDark, '❌', 'Сброс', []),
                    ],
                  ),
                ),
              ),

              // ─── Секции (сгруппированные) ───
              _buildConfigCard(theme, isDark,
                icon: Icons.checklist_rtl,
                title: 'Секции отчёта',
                subtitle: '$_selectedCount из ${_sections.length} выбрано  •  ~${_estimateTime()}с',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _groupTitle(theme, '📊 Обзор'),
                    ...sectionDefinitions.where((s) =>
                        ['summary', 'monthly_dynamics', 'payment_trend'].contains(s.key))
                        .map((s) => _sectionCheckbox(theme, isDark, s)),
                    const SizedBox(height: 8),
                    _groupTitle(theme, '📋 Детализация'),
                    ...sectionDefinitions.where((s) =>
                        ['top_houses', 'top_debtors', 'best_payers', 'last_payments', 'location_comparison'].contains(s.key))
                        .map((s) => _sectionCheckbox(theme, isDark, s)),
                    const SizedBox(height: 8),
                    _groupTitle(theme, '🔍 Специальные'),
                    ...sectionDefinitions.where((s) =>
                        ['by_services', 'recalc_analysis', 'overpayments', 'debt_aging'].contains(s.key))
                        .map((s) => _sectionCheckbox(theme, isDark, s)),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ─── Период ───
              _buildConfigCard(theme, isDark,
                icon: Icons.date_range,
                title: 'Период',
                subtitle: _loadingPeriods ? 'Загрузка...' : '${formatPeriod(_periodFrom)} — ${formatPeriod(_periodTo)}',
                child: _loadingPeriods
                    ? const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
                    : Column(
                        children: [
                          Row(
                            children: [
                              Expanded(child: _periodSelector(theme, isDark, 'От', _periodFrom, (v) => setState(() => _periodFrom = v))),
                              const SizedBox(width: 12),
                              Expanded(child: _periodSelector(theme, isDark, 'До', _periodTo, (v) => setState(() => _periodTo = v))),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _periodPreset(theme, isDark, 'Последний', () {
                                  if (_allPeriods.isNotEmpty) setState(() { _periodFrom = _allPeriods.first; _periodTo = _allPeriods.first; });
                                }),
                                _periodPreset(theme, isDark, 'Последние 3', () {
                                  if (_allPeriods.isNotEmpty) setState(() {
                                    _periodTo = _allPeriods.first;
                                    _periodFrom = _allPeriods.length >= 3 ? _allPeriods[2] : _allPeriods.last;
                                  });
                                }),
                                _periodPreset(theme, isDark, 'Полгода', () {
                                  if (_allPeriods.isNotEmpty) setState(() {
                                    _periodTo = _allPeriods.first;
                                    _periodFrom = _allPeriods.length >= 6 ? _allPeriods[5] : _allPeriods.last;
                                  });
                                }),
                                _periodPreset(theme, isDark, 'Год', () {
                                  if (_allPeriods.isNotEmpty) setState(() {
                                    _periodTo = _allPeriods.first;
                                    _periodFrom = _allPeriods.length >= 12 ? _allPeriods[11] : _allPeriods.last;
                                  });
                                }),
                                _periodPreset(theme, isDark, 'Все', () {
                                  if (_allPeriods.isNotEmpty) setState(() { _periodFrom = _allPeriods.last; _periodTo = _allPeriods.first; });
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),

              const SizedBox(height: 16),

              // ─── Фильтр по дому ───
              _buildConfigCard(theme, isDark,
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
                        Expanded(child: Text(_selectedLocationName, style: const TextStyle(fontSize: 14))),
                        const Icon(Icons.chevron_right, size: 20),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ─── Параметры ───
              _buildConfigCard(theme, isDark,
                icon: Icons.tune,
                title: 'Параметры',
                subtitle: 'Топ-$_topN • Порог ${_debtThreshold.toStringAsFixed(0)}₽',
                child: Column(
                  children: [
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
                          onTap: _showTopNInput,
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
  // КОНФИГУРАТОР — виджеты-хелперы
  // ═══════════════════════════════════════════════════════════════════════

  Widget _sectionCheckbox(ThemeData theme, bool isDark, SectionDef s) {
    final isChecked = _sections[s.key] ?? false;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isChecked ? s.color.withAlpha(isDark ? 25 : 15) : Colors.transparent,
        border: Border.all(color: isChecked ? s.color.withAlpha(80) : Colors.transparent, width: 1),
      ),
      child: CheckboxListTile(
        value: isChecked,
        onChanged: (v) => setState(() => _sections[s.key] = v ?? false),
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: s.color.withAlpha(isDark ? 40 : 25), borderRadius: BorderRadius.circular(10)),
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

  Widget _presetChip(ThemeData theme, bool isDark, String emoji, String label, List<String> keys) {
    return ActionChip(
      avatar: Text(emoji, style: const TextStyle(fontSize: 14)),
      label: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      backgroundColor: isDark ? theme.colorScheme.surface : Colors.white,
      side: BorderSide(color: theme.dividerColor.withAlpha(60)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onPressed: () {
        setState(() {
          for (final k in _sections.keys) {
            _sections[k] = keys.contains(k);
          }
        });
      },
    );
  }

  Widget _groupTitle(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 4, bottom: 4),
      child: Text(title, style: TextStyle(
        fontSize: 12, fontWeight: FontWeight.w700,
        color: theme.colorScheme.onSurfaceVariant,
        letterSpacing: 0.5,
      )),
    );
  }

  String _estimateTime() {
    final networkSections = _sections.entries
        .where((e) => e.value && !derivedSections.contains(e.key))
        .length;
    return '${(networkSections * 0.5).ceil()}';
  }

  Widget _buildConfigCard(ThemeData theme, bool isDark, {
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
          Padding(padding: const EdgeInsets.all(12), child: child),
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
            if (n != null && n >= 1) { setState(() => _topN = n); Navigator.pop(ctx); }
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          FilledButton(
            onPressed: () {
              final n = int.tryParse(controller.text);
              if (n != null && n >= 1) { setState(() => _topN = n); Navigator.pop(ctx); }
            },
            child: const Text('Применить'),
          ),
        ],
      ),
    );
  }

  Widget _periodSelector(ThemeData theme, bool isDark, String label, String? value, void Function(String) onChanged) {
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
        child: Text(formatPeriod(value), style: const TextStyle(fontSize: 13)),
      ),
    );
  }

  Widget _periodPreset(ThemeData theme, bool isDark, String label, VoidCallback onTap) {
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
                      color: isSelected ? Theme.of(context).colorScheme.primary : null, size: 20,
                    ),
                    title: Text(formatPeriod(p), style: TextStyle(fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal)),
                    dense: true,
                    onTap: () { onChanged(p); Navigator.pop(ctx); },
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
              initialChildSize: 0.7, minChildSize: 0.4, maxChildSize: 0.9, expand: false,
              builder: (_, scrollCtrl) => Column(
                children: [
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
          _progressLabel = sectionDefinitions.firstWhere((s) => s.key == section, orElse: () => sectionDefinitions.first).title;
          _progress = done / total;
        });
        await fetchSection(dio, section);
        done++;
        setState(() => _progress = done / total);
      }
      setState(() { _isGenerating = false; _showResult = true; });
      _fadeController.forward();
    } catch (e) {
      setState(() { _isGenerating = false; _error = '$e'; });
    }
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
            AnimatedBuilder(
              animation: _pulseController,
              builder: (_, child) => Transform.scale(scale: 0.9 + _pulseController.value * 0.2, child: child),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)]),
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
                value: _progress, minHeight: 8,
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
          _buildSearchBar(theme, isDark),
          const SizedBox(height: 12),
          _buildAppliedFilters(theme, isDark),
          const SizedBox(height: 16),

          // Секции — делегированы виджетам
          if (_reportResult.containsKey('summary'))
            SummarySection(data: _reportResult['summary'] as Map<String, dynamic>? ?? {}),
          if (_reportResult.containsKey('top_houses'))
            TopHousesSection(houses: (_reportResult['top_houses'] as List?)?.cast<Map<String, dynamic>>() ?? []),
          if (_reportResult.containsKey('top_debtors'))
            TopDebtorsSection(
              items: _filteredList('top_debtors'),
              onPersonTap: _showPersonDetail,
            ),
          if (_reportResult.containsKey('last_payments'))
            PaymentsSection(
              items: _filteredList('last_payments'),
              onPersonTap: _showPersonDetail,
            ),
          if (_reportResult.containsKey('monthly_dynamics'))
            DynamicsSection(periods: (_reportResult['monthly_dynamics'] as List?)?.cast<Map<String, dynamic>>() ?? []),
          if (_reportResult.containsKey('by_services'))
            ServicesSection(services: (_reportResult['by_services'] as List?)?.cast<Map<String, dynamic>>() ?? []),
          if (_reportResult.containsKey('overpayments'))
            OverpaymentsSection(
              items: _filteredList('overpayments'),
              onPersonTap: _showPersonDetail,
            ),
          if (_reportResult.containsKey('best_payers'))
            BestPayersSection(
              items: _filteredList('best_payers'),
              onPersonTap: _showPersonDetail,
            ),
          if (_reportResult.containsKey('payment_trend'))
            TrendSection(trends: (_reportResult['payment_trend'] as List?)?.cast<Map<String, dynamic>>() ?? []),
          if (_reportResult.containsKey('recalc_analysis'))
            RecalcSection(items: (_reportResult['recalc_analysis'] as List?)?.cast<Map<String, dynamic>>() ?? []),
          if (_reportResult.containsKey('debt_aging'))
            DebtAgingSection(groups: (_reportResult['debt_aging'] as List?)?.cast<Map<String, dynamic>>() ?? []),
          if (_reportResult.containsKey('location_comparison'))
            ComparisonSection(items: (_reportResult['location_comparison'] as List?)?.cast<Map<String, dynamic>>() ?? []),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  /// Фильтрация списка по поисковому запросу.
  List _filteredList(String key) {
    final allItems = (_reportResult[key] as List?) ?? [];
    return filterItems<dynamic>(allItems, _searchQuery,
      (d) => (d as Map<String, dynamic>)['fio']?.toString() ?? '',
      getLocationName: (d) => (d as Map<String, dynamic>)['location_name']?.toString() ?? '',
      getAddress: (d) => (d as Map<String, dynamic>)['address']?.toString() ?? '',
      getAccountNumber: (d) => (d as Map<String, dynamic>)['account_number']?.toString() ?? '',
    );
  }

  Widget _buildAppliedFilters(ThemeData theme, bool isDark) {
    return Wrap(
      spacing: 6, runSpacing: 6,
      children: [
        _filterChipWidget(Icons.calendar_month, '${formatPeriod(_periodFrom)} — ${formatPeriod(_periodTo)}', Colors.blue),
        _filterChipWidget(Icons.home, _selectedLocationName, Colors.orange),
        _filterChipWidget(Icons.format_list_numbered, 'Топ-$_topN', Colors.purple),
        if (_debtThreshold > 0)
          _filterChipWidget(Icons.filter_alt, 'Порог: ${_debtThreshold.toStringAsFixed(0)}₽', Colors.red),
      ],
    );
  }

  Widget _filterChipWidget(IconData icon, String label, Color color) {
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
                onPressed: () => setState(() { _searchController.clear(); _searchQuery = ''; }),
              )
            : null,
        isDense: true,
        filled: true,
        fillColor: isDark ? theme.colorScheme.surfaceContainerHigh : Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
      onChanged: (v) => setState(() => _searchQuery = v.trim()),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // ЭКСПОРТ
  // ═══════════════════════════════════════════════════════════════════════

  Future<void> _exportPdf() async {
    setState(() => _isExporting = true);
    try {
      final periodLabel = '${formatPeriod(_periodFrom)} — ${formatPeriod(_periodTo)}';
      final file = await ReportExporter.exportPdf(
        reportResult: _reportResult,
        periodLabel: periodLabel,
        locationName: _selectedLocationName,
      );
      if (mounted) {
        final savedPath = await FileExportHelper.exportFile(
          sourceFile: file,
          fileName: file.path.split('/').last,
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

  Future<void> _exportCsv() async {
    setState(() => _isExporting = true);
    try {
      final periodLabel = '${formatPeriod(_periodFrom)} — ${formatPeriod(_periodTo)}';
      final file = await ReportExporter.exportCsv(
        reportResult: _reportResult,
        periodLabel: periodLabel,
        locationName: _selectedLocationName,
      );
      if (mounted) {
        final savedPath = await FileExportHelper.exportFile(
          sourceFile: file,
          fileName: file.path.split('/').last,
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
  // ДЕТАЛИ СОБСТВЕННИКА
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.65, minChildSize: 0.4, maxChildSize: 0.9, expand: false,
        builder: (_, scrollCtrl) => ListView(
          controller: scrollCtrl,
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Text(doc['fio'] ?? 'Без имени', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            if ((doc['location_name'] ?? '').toString().isNotEmpty)
              _detailRow(Icons.apartment, 'Дом', doc['location_name']),
            if ((doc['address'] ?? '').toString().isNotEmpty)
              _detailRow(Icons.place, 'Адрес', doc['address']),
            _detailRow(Icons.badge, 'Лицевой счёт', doc['account_number'] ?? '—'),
            const SizedBox(height: 16), const Divider(), const SizedBox(height: 8),
            Text('Финансы', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: theme.colorScheme.primary)),
            const SizedBox(height: 12),
            Row(children: [
              _detailMetric('Начислено', totalCharged, Colors.blue, isDark),
              const SizedBox(width: 8),
              _detailMetric('Оплачено', totalPaid, Colors.green, isDark),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              _detailMetric('Долг', totalDebt, totalDebt > 0 ? Colors.red : Colors.green, isDark),
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
                      Text('Собираемость', style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 16), const Divider(), const SizedBox(height: 8),
            Text('По услугам', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: theme.colorScheme.primary)),
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

  Widget _detailMetric(String label, double value, Color color, bool isDark) {
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
            Text('${fmtMoney(value)}₽', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
            Text(label, style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
