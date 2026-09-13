import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/base_api_service.dart';
import 'cashier_help_screen.dart';

/// Экран деталей платёжного документа — рабочее место кассира
class CashierDetailScreen extends ConsumerStatefulWidget {
  final int docId;
  const CashierDetailScreen({super.key, required this.docId});

  @override
  ConsumerState<CashierDetailScreen> createState() => _CashierDetailScreenState();
}

class _CashierDetailScreenState extends ConsumerState<CashierDetailScreen> {
  Map<String, dynamic>? _details;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final dio = ref.read(dioProvider);
      final resp = await dio.get('/payment-documents/${widget.docId}/details');
      setState(() { _details = resp.data; _isLoading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Карточка документа'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Инструкция',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CashierHelpScreen())),
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadDetails),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text('Ошибка: $_error', style: TextStyle(color: theme.colorScheme.error)),
                  const SizedBox(height: 12),
                  ElevatedButton(onPressed: _loadDetails, child: const Text('Повторить')),
                ]))
              : _buildContent(theme),
    );
  }

  Widget _buildContent(ThemeData theme) {
    final d = _details!;
    final services = d['services'] as List? ?? [];
    final totals = d['totals'] as Map<String, dynamic>? ?? {};

    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth > 800;
      final padding = isWide ? 24.0 : 12.0;

      final headerCard = _buildHeader(theme, d, totals, isWide);
      final tableCard = _buildServiceTable(theme, services, totals, isWide);
      final actionsCard = _buildActions(theme, isWide);

      if (isWide) {
        // ═══ Desktop: 2 колонки ═══
        return RefreshIndicator(
          onRefresh: _loadDetails,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: Column(children: [
              headerCard,
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Левая — таблица
                  Expanded(flex: 3, child: tableCard),
                  const SizedBox(width: 16),
                  // Правая — действия
                  Expanded(flex: 2, child: actionsCard),
                ],
              ),
            ]),
          ),
        );
      } else {
        // ═══ Mobile: 1 колонка ═══
        return RefreshIndicator(
          onRefresh: _loadDetails,
          child: ListView(
            padding: EdgeInsets.all(padding),
            children: [
              headerCard,
              const SizedBox(height: 12),
              tableCard,
              const SizedBox(height: 12),
              actionsCard,
              const SizedBox(height: 24),
            ],
          ),
        );
      }
    });
  }

  // ═══════ Шапка документа ═══════

  Widget _buildHeader(ThemeData theme, Map<String, dynamic> d, Map<String, dynamic> totals, bool isWide) {
    final totalDebt = (totals['debt_end'] as num?)?.toDouble() ?? 0;
    final debtColor = totalDebt > 0 ? Colors.red : Colors.green;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [theme.colorScheme.primaryContainer, theme.colorScheme.surface],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: EdgeInsets.all(isWide ? 20 : 14),
        child: isWide
            ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Левая часть — ФИО + адрес
                Expanded(child: _headerInfo(theme, d)),
                const SizedBox(width: 24),
                // Правая часть — итог
                _debtBadge(theme, totalDebt, debtColor, isWide),
              ])
            : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _headerInfo(theme, d),
                const SizedBox(height: 12),
                _debtBadge(theme, totalDebt, debtColor, isWide),
              ]),
      ),
    );
  }

  Widget _headerInfo(ThemeData theme, Map<String, dynamic> d) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        d['fio'] ?? '—',
        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 20),
        maxLines: 2, overflow: TextOverflow.ellipsis,
      ),
      const SizedBox(height: 8),
      _infoRow(Icons.credit_card, d['account_number'] ?? '—', theme),
      const SizedBox(height: 4),
      _infoRow(Icons.location_on, d['address'] ?? '—', theme),
      const SizedBox(height: 4),
      _infoRow(Icons.calendar_today, _formatPeriod(d['period_date']), theme, bold: true),
      if (d['area'] != null) ...[
        const SizedBox(height: 4),
        _infoRow(Icons.square_foot, '${d['area']} м²', theme),
      ],
    ]);
  }

  Widget _infoRow(IconData icon, String text, ThemeData theme, {bool bold = false}) {
    return Row(children: [
      Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
      const SizedBox(width: 8),
      Expanded(child: Text(text, style: theme.textTheme.bodyMedium?.copyWith(
        fontWeight: bold ? FontWeight.w600 : null,
      ))),
    ]);
  }

  Widget _debtBadge(ThemeData theme, double totalDebt, Color debtColor, bool isWide) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: debtColor.withAlpha(20),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: debtColor.withAlpha(60), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: isWide ? CrossAxisAlignment.end : CrossAxisAlignment.center,
        children: [
          Text('Итого долг', style: TextStyle(fontSize: 12, color: debtColor.withAlpha(180))),
          const SizedBox(height: 4),
          Text(
            '${_fmt(totalDebt)} ₽',
            style: TextStyle(fontSize: isWide ? 28 : 24, fontWeight: FontWeight.w800, color: debtColor),
          ),
        ],
      ),
    );
  }

  // ═══════ Таблица услуг (адаптивная) ═══════

  Widget _buildServiceTable(ThemeData theme, List services, Map<String, dynamic> totals, bool isWide) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(isWide ? 16 : 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8, left: 4),
              child: Text('Услуги', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            ),
            // Заголовок таблицы
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Row(children: [
                Expanded(flex: isWide ? 3 : 2, child: Text('Услуга', style: _headerStyle(theme))),
                Expanded(flex: 2, child: Text('Д.нач', style: _headerStyle(theme), textAlign: TextAlign.right)),
                Expanded(flex: 2, child: Text('Начис.', style: _headerStyle(theme), textAlign: TextAlign.right)),
                Expanded(flex: 2, child: Text('Оплат.', style: _headerStyle(theme), textAlign: TextAlign.right)),
                Expanded(flex: 2, child: Text('Перер.', style: _headerStyle(theme), textAlign: TextAlign.right)),
                Expanded(flex: 2, child: Text('Д.кон', style: _headerStyle(theme), textAlign: TextAlign.right)),
              ]),
            ),
            const SizedBox(height: 2),
            // Строки услуг
            ...services.map((s) => _serviceRow(theme, s, isWide)),
            // Итого
            Container(
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withAlpha(80),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: theme.colorScheme.primary.withAlpha(40)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Row(children: [
                Expanded(flex: isWide ? 3 : 2, child: Text('ИТОГО', style: _cellStyle(bold: true, size: isWide ? 14 : 12))),
                Expanded(flex: 2, child: Text(_fmt(totals['debt_start']), style: _cellStyle(bold: true, size: isWide ? 14 : 12), textAlign: TextAlign.right)),
                Expanded(flex: 2, child: Text(_fmt(totals['charged']), style: _cellStyle(bold: true, color: Colors.orange, size: isWide ? 14 : 12), textAlign: TextAlign.right)),
                Expanded(flex: 2, child: Text(_fmt(totals['paid']), style: _cellStyle(bold: true, color: Colors.green, size: isWide ? 14 : 12), textAlign: TextAlign.right)),
                Expanded(flex: 2, child: Text(_fmt(totals['recalc']), style: _cellStyle(bold: true, size: isWide ? 14 : 12), textAlign: TextAlign.right)),
                Expanded(flex: 2, child: Text(
                  _fmt(totals['debt_end']),
                  style: _cellStyle(bold: true, color: (totals['debt_end'] ?? 0) > 0 ? Colors.red : Colors.green, size: isWide ? 15 : 13),
                  textAlign: TextAlign.right,
                )),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _serviceRow(ThemeData theme, Map<String, dynamic> s, bool isWide) {
    final debtEnd = (s['debt_end'] as num?)?.toDouble() ?? 0;
    final fontSize = isWide ? 13.0 : 11.5;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.dividerColor.withAlpha(40))),
      ),
      child: Row(children: [
        Expanded(flex: isWide ? 3 : 2, child: Text(s['label'] ?? '', style: _cellStyle(size: fontSize), overflow: TextOverflow.ellipsis)),
        Expanded(flex: 2, child: Text(_fmt(s['debt_start']), style: _cellStyle(size: fontSize), textAlign: TextAlign.right)),
        Expanded(flex: 2, child: Text(_fmt(s['charged']), style: _cellStyle(color: Colors.orange, size: fontSize), textAlign: TextAlign.right)),
        Expanded(flex: 2, child: Text(_fmt(s['paid']), style: _cellStyle(color: Colors.green, size: fontSize), textAlign: TextAlign.right)),
        Expanded(flex: 2, child: Text(_fmt(s['recalc']), style: _cellStyle(
          color: (s['recalc'] ?? 0) < 0 ? Colors.green : ((s['recalc'] ?? 0) > 0 ? Colors.blue : null),
          size: fontSize,
        ), textAlign: TextAlign.right)),
        Expanded(flex: 2, child: Text(_fmt(s['debt_end']), style: _cellStyle(
          bold: true, color: debtEnd > 0 ? Colors.red : (debtEnd < 0 ? Colors.green : null),
          size: fontSize,
        ), textAlign: TextAlign.right)),
      ]),
    );
  }

  TextStyle _headerStyle(ThemeData theme) => TextStyle(
    fontSize: 11, fontWeight: FontWeight.w700,
    color: theme.colorScheme.onSurfaceVariant,
    letterSpacing: 0.3,
  );

  TextStyle _cellStyle({bool bold = false, Color? color, double size = 12}) => TextStyle(
    fontSize: size, fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
    color: color, fontFeatures: const [FontFeature.tabularFigures()],
  );

  // ═══════ Панель действий ═══════

  Widget _buildActions(ThemeData theme, bool isWide) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(isWide ? 16 : 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10, left: 4),
              child: Text('Операции', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            ),
            // Основные операции
            _actionTile(Icons.payments, '💰 Оплата по услуге', 'Внести оплату по конкретной услуге', Colors.green, () => _showPayDialog()),
            _actionTile(Icons.auto_fix_high, '🔄 Авто-оплата', 'Распределить общую сумму по долгам', Colors.teal, () => _showAutoPayDialog()),
            const Divider(height: 20),
            _actionTile(Icons.calculate, '📊 Перерасчёт', 'Увеличить или уменьшить начисление', Colors.blue, () => _showRecalcDialog()),
            _actionTile(Icons.add_circle_outline, '📝 Начисление', 'Добавить начисление по услуге', Colors.orange, () => _showChargeDialog()),
            _actionTile(Icons.edit_note, '✏️ Корректировка', 'Точная установка значения поля', Colors.deepOrange, () => _showCorrectionDialog()),
            const Divider(height: 20),
            _actionTile(Icons.history, '📋 История операций', 'Все изменения по документу', Colors.purple, () => _showHistory()),
            const Divider(height: 20),
            // Undo / Redo
            Row(children: [
              Expanded(child: _compactAction(Icons.undo, 'Отменить', Colors.grey.shade700, () => _confirmUndo())),
              const SizedBox(width: 8),
              Expanded(child: _compactAction(Icons.redo, 'Вернуть', Colors.blueGrey, () => _confirmRedo())),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _actionTile(IconData icon, String title, String subtitle, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          ])),
          Icon(Icons.chevron_right, size: 20, color: Colors.grey.shade400),
        ]),
      ),
    );
  }

  Widget _compactAction(IconData icon, String label, Color color, VoidCallback onTap) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18, color: color),
      label: Text(label, style: TextStyle(fontSize: 13, color: color)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        side: BorderSide(color: color.withAlpha(80)),
      ),
    );
  }

  // keep old _actionButton for compatibility with dialogs that might reference it
  Widget _actionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontSize: 13)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ═══════ Общий helper для стилизованного bottom sheet ═══════

  void _showStyledSheet({
    required String title,
    required IconData icon,
    required Color color,
    required Widget Function(BuildContext ctx, StateSetter setSheetState) bodyBuilder,
    required String actionLabel,
    required VoidCallback onAction,
    double initialSize = 0.6,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSheetState) {
        return Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.9),
          decoration: BoxDecoration(
            color: Theme.of(ctx).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            // Хэндл
            Center(child: Container(
              margin: const EdgeInsets.only(top: 10),
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(2)),
            )),
            // Заголовок
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [color.withAlpha(30), color.withAlpha(10)]),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: color.withAlpha(40)),
              ),
              child: Row(children: [
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(color: color.withAlpha(30), borderRadius: BorderRadius.circular(10)),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
              ]),
            ),
            const SizedBox(height: 12),
            // Контент
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: bodyBuilder(ctx, setSheetState),
              ),
            ),
            // Кнопки
            Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
              child: Row(children: [
                Expanded(child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text('Отмена'),
                )),
                const SizedBox(width: 12),
                Expanded(flex: 2, child: FilledButton.icon(
                  onPressed: () { Navigator.pop(ctx); onAction(); },
                  icon: Icon(icon, size: 18),
                  label: Text(actionLabel),
                  style: FilledButton.styleFrom(
                    backgroundColor: color,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                )),
              ]),
            ),
          ]),
        );
      }),
    );
  }

  Widget _styledInput(TextEditingController ctrl, String label, {String? suffix, bool signed = false, bool decimal = true, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: decimal ? TextInputType.numberWithOptions(decimal: true, signed: signed) : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          suffixText: suffix,
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(40),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withAlpha(80))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }

  Widget _serviceSelector(List services, String? selected, void Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Выберите услугу', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurfaceVariant)),
        const SizedBox(height: 8),
        ...services.map((s) {
          final key = s['key'] as String;
          final isSelected = selected == key;
          final debt = (s['debt_end'] as num?)?.toDouble() ?? 0;
          return GestureDetector(
            onTap: () => onChanged(key),
            child: Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).colorScheme.primaryContainer.withAlpha(100) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outlineVariant.withAlpha(60)),
              ),
              child: Row(children: [
                Container(
                  width: 20, height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                    border: Border.all(color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey, width: 2),
                  ),
                  child: isSelected ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(s['label'] ?? '', style: TextStyle(fontSize: 14, fontWeight: isSelected ? FontWeight.w600 : null))),
                Text('${_fmt(debt)} ₽', style: TextStyle(fontSize: 12, color: debt > 0 ? Colors.red : Colors.green, fontWeight: FontWeight.w500)),
              ]),
            ),
          );
        }),
        const SizedBox(height: 8),
      ],
    );
  }

  // ═══════ Диалог оплаты ═══════

  void _showPayDialog() {
    final services = (_details?['services'] as List?)?.where((s) => (s['debt_end'] ?? 0) > 0).toList() ?? [];
    if (services.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Нет долгов для оплаты')));
      return;
    }
    final controllers = <String, TextEditingController>{};
    for (final s in services) { controllers[s['key']] = TextEditingController(); }
    final noteCtrl = TextEditingController();

    _showStyledSheet(
      title: 'Оплата по услуге',
      icon: Icons.payments,
      color: Colors.green,
      actionLabel: 'Оплатить',
      onAction: () async {
        final body = <String, dynamic>{};
        controllers.forEach((key, ctrl) {
          final val = double.tryParse(ctrl.text.replaceAll(',', '.'));
          if (val != null && val > 0) body['paid_$key'] = val;
        });
        if (noteCtrl.text.isNotEmpty) body['note'] = noteCtrl.text;
        if (body.isEmpty) return;
        await _executeOperation('/payment-documents/${widget.docId}/pay', body, '💰 Оплата');
      },
      bodyBuilder: (ctx, _) => Column(mainAxisSize: MainAxisSize.min, children: [
        ...services.map((s) => _styledInput(controllers[s['key']]!, '${s['label']} (долг: ${_fmt(s['debt_end'])}₽)', suffix: '₽')),
        _styledInput(noteCtrl, 'Комментарий', decimal: false),
      ]),
    );
  }

  // ═══════ Диалог перерасчёта ═══════

  void _showRecalcDialog() {
    _showServiceAmountSheet(
      title: 'Перерасчёт',
      icon: Icons.calculate,
      color: Colors.blue,
      hint: 'Сумма (минус для уменьшения)',
      endpoint: '/payment-documents/${widget.docId}/recalc',
      opType: 'recalc',
      allowNegative: true,
    );
  }

  // ═══════ Диалог начисления ═══════

  void _showChargeDialog() {
    _showServiceAmountSheet(
      title: 'Начисление',
      icon: Icons.add_circle_outline,
      color: Colors.orange,
      hint: 'Сумма начисления',
      endpoint: '/payment-documents/${widget.docId}/charge',
      opType: 'charge',
      allowNegative: false,
    );
  }

  void _showServiceAmountSheet({
    required String title,
    required IconData icon,
    required Color color,
    required String hint,
    required String endpoint,
    required String opType,
    required bool allowNegative,
  }) {
    final services = _details?['services'] as List? ?? [];
    String? selectedService;
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();

    _showStyledSheet(
      title: title,
      icon: icon,
      color: color,
      actionLabel: 'Применить',
      onAction: () async {
        if (selectedService == null) return;
        final amount = double.tryParse(amountCtrl.text.replaceAll(',', '.'));
        if (amount == null || (!allowNegative && amount <= 0)) return;
        await _executeOperation(endpoint, {
          'service': selectedService,
          'amount': amount,
          if (noteCtrl.text.isNotEmpty) 'note': noteCtrl.text,
        }, '$title');
      },
      bodyBuilder: (ctx, setSheetState) => Column(mainAxisSize: MainAxisSize.min, children: [
        _serviceSelector(services, selectedService, (v) => setSheetState(() => selectedService = v)),
        _styledInput(amountCtrl, hint, suffix: '₽', signed: allowNegative),
        _styledInput(noteCtrl, 'Комментарий', decimal: false),
      ]),
    );
  }

  // ═══════ Авто-оплата ═══════

  void _showAutoPayDialog() {
    final totals = _details?['totals'] as Map<String, dynamic>? ?? {};
    final totalDebt = (totals['debt_end'] as num?)?.toDouble() ?? 0;
    if (totalDebt <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Нет долгов')));
      return;
    }
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();

    _showStyledSheet(
      title: 'Авто-оплата',
      icon: Icons.auto_fix_high,
      color: Colors.teal,
      actionLabel: 'Оплатить',
      onAction: () async {
        final amount = double.tryParse(amountCtrl.text.replaceAll(',', '.'));
        if (amount == null || amount <= 0) return;
        await _executeOperation('/payment-documents/${widget.docId}/pay-auto', {
          'total_amount': amount,
          if (noteCtrl.text.isNotEmpty) 'note': noteCtrl.text,
        }, '🔄 Авто-оплата');
      },
      bodyBuilder: (ctx, _) => Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          padding: const EdgeInsets.all(14),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.teal.withAlpha(15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.teal.withAlpha(40)),
          ),
          child: Row(children: [
            const Icon(Icons.info_outline, color: Colors.teal, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Общий долг: ${_fmt(totalDebt)} ₽', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 2),
              const Text('Сумма будет распределена пропорционально долгам', style: TextStyle(fontSize: 11, color: Colors.grey)),
            ])),
          ]),
        ),
        _styledInput(amountCtrl, 'Общая сумма оплаты', suffix: '₽'),
        _styledInput(noteCtrl, 'Комментарий', decimal: false),
      ]),
    );
  }

  // ═══════ Корректировка ═══════

  void _showCorrectionDialog() {
    final services = _details?['services'] as List? ?? [];
    String? selectedService;
    String? selectedField;
    final valueCtrl = TextEditingController();
    final noteCtrl = TextEditingController();

    final fieldLabels = {
      'debt_start': 'Долг на начало',
      'charged': 'Начислено',
      'paid': 'Оплачено',
      'recalc': 'Перерасчёт',
      'debt_end': 'Долг на конец',
    };
    final fieldIcons = {
      'debt_start': Icons.arrow_forward,
      'charged': Icons.receipt_long,
      'paid': Icons.payments,
      'recalc': Icons.calculate,
      'debt_end': Icons.arrow_back,
    };

    _showStyledSheet(
      title: 'Корректировка',
      icon: Icons.edit_note,
      color: Colors.deepOrange,
      initialSize: 0.85,
      actionLabel: 'Применить',
      onAction: () async {
        if (selectedService == null || selectedField == null) return;
        final value = double.tryParse(valueCtrl.text.replaceAll(',', '.'));
        if (value == null) return;
        if (noteCtrl.text.length < 3) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Укажите причину (мин 3 символа)')));
          return;
        }
        await _executeOperation('/payment-documents/${widget.docId}/correct', {
          'service': selectedService,
          'field': selectedField,
          'value': value,
          'note': noteCtrl.text,
        }, '✏️ Корректировка');
      },
      bodyBuilder: (ctx, setSheetState) => Column(mainAxisSize: MainAxisSize.min, children: [
        _serviceSelector(services, selectedService, (v) => setSheetState(() => selectedService = v)),
        const SizedBox(height: 4),
        Text('Выберите поле', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Theme.of(ctx).colorScheme.onSurfaceVariant)),
        const SizedBox(height: 8),
        ...fieldLabels.entries.map((e) {
          final isSelected = selectedField == e.key;
          final currentVal = selectedService != null ? _getServiceFieldValue(selectedService!, e.key) : null;
          return GestureDetector(
            onTap: () => setSheetState(() => selectedField = e.key),
            child: Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? Colors.deepOrange.withAlpha(20) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isSelected ? Colors.deepOrange : Theme.of(ctx).colorScheme.outlineVariant.withAlpha(60)),
              ),
              child: Row(children: [
                Icon(fieldIcons[e.key] ?? Icons.edit, size: 18, color: isSelected ? Colors.deepOrange : Colors.grey),
                const SizedBox(width: 12),
                Expanded(child: Text(e.value, style: TextStyle(fontSize: 13, fontWeight: isSelected ? FontWeight.w600 : null))),
                if (currentVal != null) Text('${_fmt(currentVal)} ₽', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ]),
            ),
          );
        }),
        const SizedBox(height: 12),
        _styledInput(valueCtrl, 'Новое значение', suffix: '₽', signed: true),
        _styledInput(noteCtrl, 'Причина (обязательно)', decimal: false),
      ]),
    );
  }

  dynamic _getServiceFieldValue(String serviceKey, String fieldKey) {
    final services = _details?['services'] as List? ?? [];
    final svc = services.firstWhere((s) => s['key'] == serviceKey, orElse: () => {});
    return svc[fieldKey] ?? 0;
  }

  // ═══════ Отмена / Redo ═══════

  void _confirmUndo() {
    _showConfirmSheet(
      title: 'Отменить последнее действие?',
      icon: Icons.undo,
      color: Colors.grey.shade700,
      description: 'Будет отменена последняя операция. Значение вернётся к состоянию до неё.\n\nМаксимум 10 отмен подряд.',
      actionLabel: 'Да, отменить',
      onAction: () async {
        try {
          final dio = ref.read(dioProvider);
          final resp = await dio.post('/payment-documents/${widget.docId}/undo');
          final data = resp.data;
          final undone = data['undone_operation'];
          final remaining = data['undos_remaining'];
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('⏪ Отменена: ${undone['type_label']} ${undone['service_label']} (${_fmt(undone['amount'])}₽). Осталось: $remaining'),
              backgroundColor: Colors.orange.shade800, duration: const Duration(seconds: 4),
            ));
          }
          await _loadDetails();
        } catch (e) {
          _showError(e);
        }
      },
    );
  }

  void _confirmRedo() {
    _showConfirmSheet(
      title: 'Вернуть отменённое действие?',
      icon: Icons.redo,
      color: Colors.blueGrey,
      description: 'Последняя отменённая операция будет восстановлена.',
      actionLabel: 'Да, вернуть',
      onAction: () async {
        try {
          final dio = ref.read(dioProvider);
          final resp = await dio.post('/payment-documents/${widget.docId}/redo');
          final data = resp.data;
          final restored = data['restored_operation'];
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('⏩ Восстановлена: ${restored['type_label']} ${restored['service_label']} (${_fmt(restored['amount'])}₽)'),
              backgroundColor: Colors.blueGrey, duration: const Duration(seconds: 4),
            ));
          }
          await _loadDetails();
        } catch (e) {
          _showError(e);
        }
      },
    );
  }

  void _showConfirmSheet({
    required String title, required IconData icon, required Color color,
    required String description, required String actionLabel, required VoidCallback onAction,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        decoration: BoxDecoration(
          color: Theme.of(ctx).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(color: color.withAlpha(25), borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 14),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 10),
          Text(description, style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.5), textAlign: TextAlign.center),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: OutlinedButton(
              onPressed: () => Navigator.pop(ctx),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Нет'),
            )),
            const SizedBox(width: 12),
            Expanded(flex: 2, child: FilledButton.icon(
              onPressed: () { Navigator.pop(ctx); onAction(); },
              icon: Icon(icon, size: 18),
              label: Text(actionLabel),
              style: FilledButton.styleFrom(backgroundColor: color, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            )),
          ]),
        ]),
      ),
    );
  }

  void _showError(dynamic e) {
    if (!mounted) return;
    String msg = 'Ошибка';
    if (e is DioException && e.response?.data != null) {
      msg = e.response!.data['detail'] ?? e.toString();
    } else {
      msg = e.toString();
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ $msg'), backgroundColor: Colors.red));
  }

  Future<void> _executeOperation(String endpoint, Map<String, dynamic> body, String label) async {
    try {
      final dio = ref.read(dioProvider);
      await dio.post(endpoint, data: body);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ $label выполнена'), backgroundColor: Colors.green));
      }
      await _loadDetails();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ Ошибка: $e'), backgroundColor: Colors.red));
      }
    }
  }

  // ═══════ История операций ═══════

  void _showHistory() async {
    try {
      final dio = ref.read(dioProvider);
      final resp = await dio.get('/payment-documents/${widget.docId}/operations');
      final ops = resp.data['operations'] as List? ?? [];

      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => DraggableScrollableSheet(
          initialChildSize: 0.75,
          maxChildSize: 0.95,
          expand: false,
          builder: (ctx, scroll) => Container(
            decoration: BoxDecoration(
              color: Theme.of(ctx).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(children: [
              // Хэндл
              Center(child: Container(
                margin: const EdgeInsets.only(top: 10),
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(2)),
              )),
              // Заголовок
              Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.purple.withAlpha(30), Colors.purple.withAlpha(10)]),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.purple.withAlpha(40)),
                ),
                child: Row(children: [
                  Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(color: Colors.purple.withAlpha(30), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.history, color: Colors.purple, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text('История операций', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.purple.withAlpha(20), borderRadius: BorderRadius.circular(8)),
                    child: Text('${ops.length}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.purple)),
                  ),
                ]),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ops.isEmpty
                    ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.history, size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text('Нет операций', style: TextStyle(fontSize: 15, color: Colors.grey.shade500)),
                      ]))
                    : ListView.separated(
                        controller: scroll,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        separatorBuilder: (_, __) => const SizedBox(height: 4),
                        itemCount: ops.length,
                        itemBuilder: (ctx, i) => _buildHistoryItem(ops[i] as Map<String, dynamic>),
                      ),
              ),
            ]),
          ),
        ),
      );
    } catch (e) {
      _showError(e);
    }
  }

  Widget _buildHistoryItem(Map<String, dynamic> op) {
    final amount = op['amount'] as num? ?? 0;
    final isPositive = amount >= 0;
    final isUndone = op['is_undone'] == true;
    final isUndoOp = op['operation_type'] == 'undo';
    final isRedoOp = op['operation_type'] == 'redo';
    final color = _opColor(op['operation_type']);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isUndone
            ? Colors.grey.withAlpha(15)
            : isUndoOp ? Colors.orange.withAlpha(10)
            : isRedoOp ? Colors.blueGrey.withAlpha(10) : null,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isUndone ? Colors.grey.withAlpha(30) : color.withAlpha(25)),
      ),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: isUndone ? Colors.grey.withAlpha(25) : color.withAlpha(25),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(child: Text(_opIcon(op['operation_type']), style: const TextStyle(fontSize: 16))),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            '${op['operation_label']} — ${op['service_label']}${isUndone ? ' (ОТМЕНЕНО)' : ''}',
            style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w500,
              decoration: isUndone ? TextDecoration.lineThrough : null,
              color: isUndone ? Colors.grey : null,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${isPositive ? '+' : ''}${amount.toStringAsFixed(2)}₽ • ${_formatDateTime(op['created_at'])}${op['note'] != null ? '\n${op['note']}' : ''}',
            style: TextStyle(fontSize: 11, color: isUndone ? Colors.grey.shade500 : Colors.grey.shade600, height: 1.4),
          ),
        ])),
        const SizedBox(width: 8),
        Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(_fmt(op['old_debt_end']), style: const TextStyle(fontSize: 10, color: Colors.grey)),
          Icon(Icons.arrow_downward, size: 10, color: Colors.grey.shade400),
          Text(_fmt(op['new_debt_end']), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold,
            color: isUndone ? Colors.grey : ((op['new_debt_end'] ?? 0) > 0 ? Colors.red : Colors.green))),
        ]),
      ]),
    );
  }

  Color _opColor(String? type) {
    switch (type) {
      case 'payment': return Colors.green;
      case 'recalc': return Colors.blue;
      case 'charge': return Colors.orange;
      case 'undo': return Colors.orange;
      case 'redo': return Colors.blueGrey;
      default: return Colors.grey;
    }
  }

  String _opIcon(String? type) {
    switch (type) {
      case 'payment': return '💰';
      case 'recalc': return '📊';
      case 'charge': return '📝';
      case 'undo': return '⏪';
      case 'redo': return '⏩';
      default: return '✏️';
    }
  }

  String _fmt(dynamic val) {
    if (val == null) return '0';
    final n = (val is num) ? val.toDouble() : double.tryParse(val.toString()) ?? 0;
    if (n == 0) return '0';
    return n.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
  }

  String _formatPeriod(String? date) {
    if (date == null) return '—';
    try {
      final d = DateTime.parse(date);
      const months = ['', 'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
        'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь'];
      return '${months[d.month]} ${d.year}';
    } catch (_) {
      return date;
    }
  }

  String _formatDateTime(String? dt) {
    if (dt == null) return '';
    try {
      final d = DateTime.parse(dt);
      return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')} ${d.hour}:${d.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dt;
    }
  }
}
