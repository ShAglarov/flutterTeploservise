import 'dart:io';
import 'dart:ui';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/base_api_service.dart';
import '../services/file_export_helper.dart';
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
  /// id документов, у которых раскрыта расшифровка баланса в истории
  final Set<int> _expandedPeriods = {};

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
      final residentCard = _buildResidentCard(theme, d);
      final tableCard = _buildServiceTable(theme, services, totals, isWide);
      final actionsCard = _buildActions(theme, isWide);
      final periodHistoryCard = _buildPeriodHistory(theme, d);

      if (isWide) {
        // ═══ Desktop: 2 колонки ═══
        return RefreshIndicator(
          onRefresh: _loadDetails,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: Column(children: [
              headerCard,
              residentCard,
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Левая — таблица + история
                  Expanded(flex: 3, child: Column(children: [
                    tableCard,
                    const SizedBox(height: 16),
                    periodHistoryCard,
                  ])),
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
              residentCard,
              const SizedBox(height: 12),
              tableCard,
              const SizedBox(height: 12),
              actionsCard,
              const SizedBox(height: 12),
              periodHistoryCard,
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
      if (d['cadastral_number'] != null && d['cadastral_number'].toString().isNotEmpty) ...[
        const SizedBox(height: 4),
        _infoRow(Icons.pin, 'Кадастр: ${d['cadastral_number']}', theme),
      ],
      if (d['rooms_count'] != null) ...[
        const SizedBox(height: 4),
        _infoRow(Icons.meeting_room, 'Комнат: ${d['rooms_count']}', theme),
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

  // ═══════ Блок жильца (нанимателя) ═══════

  Widget _buildResidentCard(ThemeData theme, Map<String, dynamic> d) {
    final resident = d['resident'] as Map<String, dynamic>?;
    if (resident == null) return const SizedBox.shrink();

    final fullName = resident['full_name'] ?? resident['username'] ?? 'Без имени';
    final phone = resident['phone_number']?.toString() ?? '';
    final email = resident['email']?.toString() ?? '';
    final isBlocked = resident['is_blocked'] == true;

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isBlocked ? Colors.red.withAlpha(80) : Colors.green.withAlpha(80),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isBlocked ? Icons.person_off : Icons.person,
                    size: 18,
                    color: isBlocked ? Colors.red[700] : Colors.green[700],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Наниматель помещения',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isBlocked ? Colors.red[700] : Colors.green[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                fullName,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              if (phone.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.phone, size: 14, color: Colors.blue),
                  const SizedBox(width: 6),
                  Text(phone, style: const TextStyle(fontSize: 14, color: Colors.blue)),
                ]),
              ],
              if (email.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.email, size: 14, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(email, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                ]),
              ],
              if (isBlocked) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    '⛔ Жилец заблокирован',
                    style: TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
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

  // ═══════ История по месяцам ═══════

  Widget _buildPeriodHistory(ThemeData theme, Map<String, dynamic> d) {
    final history = d['period_history'] as List? ?? [];
    if (history.length <= 1) return const SizedBox.shrink();

    const months = ['', 'Янв', 'Фев', 'Мар', 'Апр', 'Май', 'Июн', 'Июл', 'Авг', 'Сен', 'Окт', 'Ноя', 'Дек'];

    String formatPeriod(String? iso) {
      if (iso == null) return '—';
      try {
        final dt = DateTime.parse(iso);
        return '${months[dt.month]} ${dt.year}';
      } catch (_) {
        return iso;
      }
    }

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.history, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text('История по месяцам', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const Spacer(),
              Text('${history.length} пер.', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            ]),
            const SizedBox(height: 12),
            // Заголовок
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(children: [
                const Expanded(flex: 3, child: Text('Период', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700))),
                const Expanded(flex: 2, child: Text('Начис.', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700), textAlign: TextAlign.right)),
                const Expanded(flex: 2, child: Text('Перерасч.', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700), textAlign: TextAlign.right)),
                const Expanded(flex: 2, child: Text('Оплач.', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700), textAlign: TextAlign.right)),
                const Expanded(flex: 2, child: Text('Баланс', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700), textAlign: TextAlign.right)),
                const SizedBox(width: 24),
              ]),
            ),
            const SizedBox(height: 4),
            // Строки
            ...history.map((p) {
              final isCurrent = p['is_current'] == true;
              final docId = p['id'] as int?;
              // Баланс: > 0 — долг, < 0 — переплата, 0 — расчёт закрыт
              final balance = (p['balance'] as num?)?.toDouble()
                  ?? (p['debt_end'] as num?)?.toDouble() ?? 0;
              final recalc = (p['recalc'] as num?)?.toDouble() ?? 0;
              final isExpanded = docId != null && _expandedPeriods.contains(docId);
              final Color? balanceColor = balance > 0.01
                  ? Colors.red.shade700
                  : (balance < -0.01 ? Colors.green.shade700 : null);

              return Column(children: [
              InkWell(
                onTap: isCurrent ? null : () {
                  // Навигация к карточке другого периода
                  final periodDocId = p['id'] as int?;
                  if (periodDocId != null) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => CashierDetailScreen(docId: periodDocId)),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isCurrent ? theme.colorScheme.primaryContainer.withAlpha(60) : null,
                    borderRadius: BorderRadius.circular(8),
                    border: isCurrent ? Border.all(color: theme.colorScheme.primary.withAlpha(40)) : null,
                  ),
                  child: Row(children: [
                    Expanded(flex: 3, child: Row(children: [
                      if (isCurrent) Icon(Icons.arrow_right, size: 16, color: theme.colorScheme.primary),
                      Text(
                        formatPeriod(p['period_date'] as String?),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                          color: isCurrent ? theme.colorScheme.primary : null,
                        ),
                      ),
                    ])),
                    Expanded(flex: 2, child: Text(
                      _fmt(p['charged']),
                      style: TextStyle(fontSize: 12, color: Colors.orange.shade700, fontFeatures: const [FontFeature.tabularFigures()]),
                      textAlign: TextAlign.right,
                    )),
                    Expanded(flex: 2, child: Text(
                      recalc.abs() < 0.01 ? '—' : _fmt(recalc),
                      style: TextStyle(
                        fontSize: 12,
                        color: recalc.abs() < 0.01 ? Colors.grey.shade500 : Colors.blue.shade700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                      textAlign: TextAlign.right,
                    )),
                    Expanded(flex: 2, child: Text(
                      _fmt(p['paid']),
                      style: TextStyle(fontSize: 12, color: Colors.green.shade700, fontFeatures: const [FontFeature.tabularFigures()]),
                      textAlign: TextAlign.right,
                    )),
                    Expanded(flex: 2, child: Text(
                      _fmt(balance),
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: balanceColor, fontFeatures: const [FontFeature.tabularFigures()]),
                      textAlign: TextAlign.right,
                    )),
                    SizedBox(
                      width: 24,
                      child: docId == null ? null : IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                        iconSize: 18,
                        icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more, color: Colors.grey.shade600),
                        tooltip: 'Расшифровка баланса',
                        onPressed: () => setState(() {
                          isExpanded ? _expandedPeriods.remove(docId) : _expandedPeriods.add(docId);
                        }),
                      ),
                    ),
                  ]),
                ),
              ),
              if (isExpanded) _buildBalanceBreakdown(theme, p, balance, recalc),
              ]);
            }),
          ],
        ),
      ),
    );
  }

  /// Расшифровка баланса периода:
  /// Баланс пред. + Начислено + Перерасчёт − Оплачено = Баланс
  Widget _buildBalanceBreakdown(
      ThemeData theme, Map<dynamic, dynamic> p, double balance, double recalc) {
    final charged = (p['charged'] as num?)?.toDouble() ?? 0;
    final paid = (p['paid'] as num?)?.toDouble() ?? 0;
    // prev_balance приходит с backend; если нет — восстанавливаем из уравнения
    final prevBalance = (p['prev_balance'] as num?)?.toDouble()
        ?? (balance - charged - recalc + paid);

    Widget line(String label, double value, {Color? color, bool bold = false, String? sign}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(children: [
          SizedBox(width: 14, child: Text(sign ?? '', style: TextStyle(fontSize: 12, color: Colors.grey.shade600))),
          Expanded(child: Text(label, style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade800,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
          ))),
          Text('${_fmt(value)} ₽', style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            fontFeatures: const [FontFeature.tabularFigures()],
          )),
        ]),
      );
    }

    final String verdict = balance > 0.01
        ? 'Долг'
        : (balance < -0.01 ? 'Переплата' : 'Расчёт закрыт');
    final Color verdictColor = balance > 0.01
        ? Colors.red.shade700
        : (balance < -0.01 ? Colors.green.shade700 : Colors.grey.shade700);

    return Container(
      margin: const EdgeInsets.only(left: 12, right: 12, bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(90),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        line('Баланс на начало периода', prevBalance,
            color: prevBalance > 0.01 ? Colors.red.shade700 : (prevBalance < -0.01 ? Colors.green.shade700 : null)),
        line('Начислено', charged, color: Colors.orange.shade700, sign: '+'),
        if (recalc.abs() >= 0.01)
          line('Перерасчёт', recalc, color: Colors.blue.shade700, sign: recalc >= 0 ? '+' : '−'),
        line('Оплачено', paid, color: Colors.green.shade700, sign: '−'),
        Divider(height: 12, color: Colors.grey.shade400),
        line('$verdict на конец периода', balance, color: verdictColor, bold: true, sign: '='),
      ]),
    );
  }

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
            _actionTile(Icons.receipt_long, '🧾 Выдать чек', 'Сформировать чек об оплате', Colors.indigo, () => _showReceipt()),
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

  static const _monthNames = ['Январь','Февраль','Март','Апрель','Май','Июнь','Июль','Август','Сентябрь','Октябрь','Ноябрь','Декабрь'];

  Widget _monthYearPickerRow(String label, DateTime date, void Function(DateTime) onChanged, {void Function(StateSetter)? setSheetStateRef}) {
    final formatted = '${_monthNames[date.month - 1]} ${date.year}';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          int selectedMonth = date.month;
          int selectedYear = date.year;
          final now = DateTime.now();
          final result = await showDialog<DateTime>(
            context: context,
            builder: (ctx) => StatefulBuilder(
              builder: (ctx, setDialogState) => AlertDialog(
                title: Text(label),
                content: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: DropdownButton<int>(
                        isExpanded: true,
                        value: selectedMonth,
                        items: List.generate(12, (i) => DropdownMenuItem(value: i + 1, child: Text(_monthNames[i]))),
                        onChanged: (v) => setDialogState(() => selectedMonth = v!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: DropdownButton<int>(
                        isExpanded: true,
                        value: selectedYear,
                        items: List.generate(now.year - 2019, (i) => DropdownMenuItem(value: 2020 + i, child: Text('${2020 + i}'))),
                        onChanged: (v) => setDialogState(() => selectedYear = v!),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
                  FilledButton(onPressed: () => Navigator.pop(ctx, DateTime(selectedYear, selectedMonth)), child: const Text('ОК')),
                ],
              ),
            ),
          );
          if (result != null) onChanged(result);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(40),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withAlpha(80)),
          ),
          child: Row(
            children: [
              Icon(Icons.date_range, size: 18, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 10),
              Expanded(child: Text(label, style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant))),
              Text(formatted, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _datePickerRow(String label, DateTime date, void Function(DateTime) onChanged) {
    final formatted = '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: date,
            firstDate: DateTime(2020),
            lastDate: DateTime.now(),
            locale: const Locale('ru'),
          );
          if (picked != null) onChanged(picked);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(40),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withAlpha(80)),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today, size: 18, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 10),
              Expanded(child: Text(label, style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant))),
              Text(formatted, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
            ],
          ),
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
    final currentServices = (_details?['services'] as List?)?.where((s) => (s['debt_end'] ?? 0) > 0).toList() ?? [];
    if (currentServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Нет долгов для оплаты')));
      return;
    }
    final controllers = <String, TextEditingController>{};
    for (final s in currentServices) { controllers[s['key']] = TextEditingController(); }
    final noteCtrl = TextEditingController();
    DateTime paymentDate = DateTime.now();

    // Период из текущего документа
    final periodStr = _details?['period_date'] as String?;
    DateTime docPeriod;
    if (periodStr != null) {
      docPeriod = DateTime.tryParse(periodStr) ?? DateTime.now();
    } else {
      docPeriod = DateTime.now();
    }
    // Дефолт period_from из estimated_period_from (рассчитан по долгу/площади/тарифу)
    final estimatedStr = _details?['estimated_period_from'] as String?;
    DateTime periodFrom;
    if (estimatedStr != null) {
      periodFrom = DateTime.tryParse(estimatedStr) ?? DateTime(docPeriod.year, docPeriod.month);
    } else {
      periodFrom = DateTime(docPeriod.year, docPeriod.month);
    }
    DateTime periodTo = DateTime(docPeriod.year, docPeriod.month);

    // Долги за выбранный период (обновляются динамически)
    List<Map<String, dynamic>> periodServices = List<Map<String, dynamic>>.from(currentServices);
    double periodTotalDebt = periodServices.fold(0.0, (sum, s) => sum + ((s['debt_end'] as num?)?.toDouble() ?? 0));
    bool loading = false;

    Future<void> _loadPeriodDebt(StateSetter setSheetState) async {
      setSheetState(() => loading = true);
      try {
        final dio = ref.read(dioProvider);
        final fromStr = '${periodFrom.year}-${periodFrom.month.toString().padLeft(2, '0')}-01';
        final toStr = '${periodTo.year}-${periodTo.month.toString().padLeft(2, '0')}-01';
        final resp = await dio.get('/payment-documents/${widget.docId}/period-debt', queryParameters: {
          'period_from': fromStr,
          'period_to': toStr,
        });
        final data = resp.data as Map<String, dynamic>;
        final svcs = (data['services'] as List?) ?? [];
        // Обновляем контроллеры — убираем старые, добавляем новые
        final newServices = <Map<String, dynamic>>[];
        for (final s in svcs) {
          final debt = (s['debt'] as num?)?.toDouble() ?? 0;
          if (debt > 0) {
            newServices.add(s);
            final key = s['key'] as String;
            if (!controllers.containsKey(key)) {
              controllers[key] = TextEditingController();
            }
          }
        }
        setSheetState(() {
          periodServices = newServices;
          periodTotalDebt = (data['total_debt'] as num?)?.toDouble() ?? 0;
          loading = false;
        });
      } catch (e) {
        setSheetState(() => loading = false);
      }
    }

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
        body['payment_date'] = '${paymentDate.year}-${paymentDate.month.toString().padLeft(2, '0')}-${paymentDate.day.toString().padLeft(2, '0')}';
        body['period_from'] = '${periodFrom.year}-${periodFrom.month.toString().padLeft(2, '0')}-01';
        body['period_to'] = '${periodTo.year}-${periodTo.month.toString().padLeft(2, '0')}-01';
        if (body.length <= 3) return;
        await _executeOperation('/payment-documents/${widget.docId}/pay', body, '💰 Оплата');
      },
      bodyBuilder: (ctx, setSheetState) {
        // Загрузить долг за estimated период при первом открытии
        if (!loading && estimatedStr != null && periodServices == currentServices) {
          Future.microtask(() => _loadPeriodDebt(setSheetState));
        }
        return Column(mainAxisSize: MainAxisSize.min, children: [
        _monthYearPickerRow('Период от', periodFrom, (d) {
          setSheetState(() => periodFrom = d);
          _loadPeriodDebt(setSheetState);
        }),
        _monthYearPickerRow('Период до', periodTo, (d) {
          setSheetState(() => periodTo = d);
          _loadPeriodDebt(setSheetState);
        }),
        if (loading)
          const Padding(padding: EdgeInsets.all(8), child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))))
        else ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text('Общий долг за период: ${_fmt(periodTotalDebt)}₽',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: periodTotalDebt > 0 ? Colors.red : Colors.green)),
          ),
          const Divider(height: 16),
          ...periodServices.map((s) {
            final key = s['key'] as String;
            final label = s['label'] ?? key;
            final debt = (s['debt'] as num?)?.toDouble() ?? (s['debt_end'] as num?)?.toDouble() ?? 0;
            if (!controllers.containsKey(key)) controllers[key] = TextEditingController();
            return _styledInput(controllers[key]!, '$label (долг: ${_fmt(debt)}₽)', suffix: '₽');
          }),
        ],
        _styledInput(noteCtrl, 'Комментарий', decimal: false),
        _datePickerRow('Дата платежа', paymentDate, (d) => setSheetState(() => paymentDate = d)),
      ]);},
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
    DateTime paymentDate = DateTime.now();

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
          'payment_date': '${paymentDate.year}-${paymentDate.month.toString().padLeft(2, '0')}-${paymentDate.day.toString().padLeft(2, '0')}',
        }, '$title');
      },
      bodyBuilder: (ctx, setSheetState) => Column(mainAxisSize: MainAxisSize.min, children: [
        _serviceSelector(services, selectedService, (v) => setSheetState(() => selectedService = v)),
        _styledInput(amountCtrl, hint, suffix: '₽', signed: allowNegative),
        _styledInput(noteCtrl, 'Комментарий', decimal: false),
        // Дата платежа
        _datePickerRow('Дата платежа', paymentDate, (d) => setSheetState(() => paymentDate = d)),
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
    DateTime paymentDate = DateTime.now();

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
          'payment_date': '${paymentDate.year}-${paymentDate.month.toString().padLeft(2, '0')}-${paymentDate.day.toString().padLeft(2, '0')}',
        }, '🔄 Авто-оплата');
      },
      bodyBuilder: (ctx, setSheetState) => Column(mainAxisSize: MainAxisSize.min, children: [
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
        _datePickerRow('Дата платежа', paymentDate, (d) => setSheetState(() => paymentDate = d)),
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

  // ═══════ Чек об оплате с расчётом периодов + QR ═══════

  void _showReceipt() async {
    final d = _details;
    if (d == null) return;

    // Загружаем данные чека с backend
    Map<String, dynamic>? receiptData;
    try {
      final dio = ref.read(dioProvider);
      final resp = await dio.get('/payment-documents/${widget.docId}/receipt-data');
      receiptData = resp.data as Map<String, dynamic>;
    } catch (e) {
      // Fallback — используем локальные данные
      receiptData = null;
    }

    final services = (receiptData?['services'] ?? d['services']) as List? ?? [];
    final totalPaid = (receiptData?['total_paid'] as num?)?.toDouble() ??
        services.fold<double>(0, (sum, s) => sum + ((s['paid'] as num?)?.toDouble() ?? 0));
    final totalDebt = (receiptData?['total_debt'] as num?)?.toDouble() ??
        services.fold<double>(0, (sum, s) => sum + ((s['debt_end'] as num?)?.toDouble() ?? 0));
    var qrString = receiptData?['qr_string'] as String?;
    final periodSummary = receiptData?['period_summary'] as String? ?? '';
    final periodCoverage = receiptData?['period_coverage'] as List? ?? [];
    final overpayment = (receiptData?['overpayment'] as num?)?.toDouble() ?? 0;
    final org = receiptData?['org'] as Map<String, dynamic>? ?? {};
    final periodLabel = receiptData?['period_label'] as String? ?? _formatPeriod(d['period_date']);

    // Fallback QR: если backend не вернул — генерим локально
    if ((qrString == null || qrString.isEmpty) && totalDebt > 0) {
      final accNum = d['account_number'] ?? '';
      final sumKopecks = (totalDebt * 100).toInt();
      qrString = 'ST00012'
          '|Purpose=Оплата ЖКУ л/с $accNum за $periodLabel'
          '|Sum=$sumKopecks';
    }

    if (totalPaid <= 0 && totalDebt <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Нет данных для формирования чека')),
        );
      }
      return;
    }

    final now = DateTime.now();
    final dateStr = '${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year}';
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 380,
            constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.85),
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // === Заголовок ===
                  const Icon(Icons.receipt_long, size: 40, color: Colors.indigo),
                  const SizedBox(height: 8),
                  const Text('ЧЕК ОБ ОПЛАТЕ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                  Text('$dateStr  $timeStr', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),

                  // Организация
                  if (org['name'] != null && (org['name'] as String).isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(org['name'], style: TextStyle(fontSize: 11, color: Colors.grey.shade700), textAlign: TextAlign.center),
                  ],
                  const SizedBox(height: 16),

                  _receiptDivider(),

                  // === Данные плательщика ===
                  _receiptRow('Плательщик:', receiptData?['fio'] ?? d['fio'] ?? '—'),
                  _receiptRow('Лицевой счёт:', receiptData?['account_number'] ?? d['account_number'] ?? '—'),
                  _receiptRow('Адрес:', receiptData?['address'] ?? d['address'] ?? '—'),
                  _receiptRow('Период:', periodLabel),
                  if ((receiptData?['area'] ?? d['area']) != null)
                    _receiptRow('Площадь:', '${receiptData?['area'] ?? d['area']} м²'),

                  _receiptDivider(),

                  // === Услуги ===
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Услуги:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                  ),
                  const SizedBox(height: 6),
                  ...services.where((s) => ((s['paid'] as num?)?.toDouble() ?? 0) > 0 || ((s['charged'] as num?)?.toDouble() ?? 0) > 0).map((s) {
                    final paid = (s['paid'] as num?)?.toDouble() ?? 0;
                    final charged = (s['charged'] as num?)?.toDouble() ?? 0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              s['label'] ?? s['key'] ?? '',
                              style: const TextStyle(fontSize: 12, color: Colors.black87),
                            ),
                          ),
                          if (paid > 0)
                            Text(
                              '${_fmt(paid)} ₽',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
                            )
                          else
                            Text(
                              'начисл. ${_fmt(charged)} ₽',
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                            ),
                        ],
                      ),
                    );
                  }),

                  _receiptDivider(),

                  // === Итого ===
                  if (totalPaid > 0)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('ИТОГО ОПЛАЧЕНО:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                        Text('${_fmt(totalPaid)} ₽', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                      ],
                    ),

                  const SizedBox(height: 4),

                  // Долг ИЛИ переплата — одновременно быть не может
                  if (totalDebt > 0.01)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Остаток долга:', style: TextStyle(fontSize: 12, color: Colors.red.shade700)),
                        Text(
                          '${_fmt(totalDebt)} ₽',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.red.shade700),
                        ),
                      ],
                    )
                  else if (overpayment > 0.01)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Переплата:', style: TextStyle(fontSize: 12, color: Colors.green.shade700)),
                        Text('${_fmt(overpayment)} ₽', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.green.shade700)),
                      ],
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Задолженности нет', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.green.shade700)),
                        Text('0.00 ₽', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.green.shade700)),
                      ],
                    ),

                  // === Покрытие периодов ===
                  if (periodCoverage.isNotEmpty) ...[
                    _receiptDivider(),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Расчёт по периодам:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87)),
                    ),
                    const SizedBox(height: 6),
                    Builder(builder: (_) {
                      // Группируем последовательные периоды с одинаковым статусом
                      final filtered = periodCoverage.where((c) => c['status'] != 'no_charges').toList();
                      final groups = <Map<String, dynamic>>[];
                      for (final c in filtered) {
                        final status = c['status'] as String? ?? '';
                        // partial — всегда отдельная строка (суммы разные)
                        if (status == 'partial' || groups.isEmpty || groups.last['status'] != status) {
                          groups.add({
                            'status': status,
                            'status_label': c['status_label'],
                            'first_label': c['period_label'],
                            'last_label': c['period_label'],
                            'count': 1,
                            'has_current': c['is_current'] == true,
                          });
                        } else {
                          final g = groups.last;
                          g['last_label'] = c['period_label'];
                          g['count'] = (g['count'] as int) + 1;
                          if (c['is_current'] == true) g['has_current'] = true;
                        }
                      }

                      return Column(
                        children: groups.map((g) {
                          final status = g['status'] as String;
                          Color statusColor;
                          IconData statusIcon;
                          switch (status) {
                            case 'paid':
                              statusColor = Colors.green;
                              statusIcon = Icons.check_circle;
                              break;
                            case 'partial':
                              statusColor = Colors.orange;
                              statusIcon = Icons.warning_amber;
                              break;
                            default:
                              statusColor = Colors.red;
                              statusIcon = Icons.cancel;
                          }
                          final count = g['count'] as int;
                          final label = count == 1
                              ? (g['first_label'] as String? ?? '')
                              : 'с ${g['first_label']} по ${g['last_label']}';
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                Icon(statusIcon, size: 14, color: statusColor),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    label,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.black87,
                                      fontWeight: g['has_current'] == true ? FontWeight.bold : null,
                                    ),
                                  ),
                                ),
                                Text(
                                  g['status_label'] as String? ?? '',
                                  style: TextStyle(fontSize: 10, color: statusColor, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    }),
                  ],

                  // === QR код для оплаты ===
                  if (qrString != null && qrString.isNotEmpty && totalDebt > 0) ...[
                    _receiptDivider(),
                    const Text('Оплата по QR-коду', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 4),
                    Text('Отсканируйте для оплаты', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                    const SizedBox(height: 8),
                    Center(
                      child: QrImageView(
                        data: qrString,
                        version: QrVersions.auto,
                        size: 160,
                        backgroundColor: Colors.white,
                        errorCorrectionLevel: QrErrorCorrectLevel.M,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('Сумма: ${_fmt(totalDebt)} ₽', style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
                  ],

                  _receiptDivider(),

                  // Банковские реквизиты
                  if (org['bank_name'] != null && (org['bank_name'] as String).isNotEmpty) ...[
                    Text(
                      'Банк: ${org['bank_name']}  БИК: ${org['bik'] ?? ''}  р/с: ${org['account_number'] ?? ''}',
                      style: TextStyle(fontSize: 9, color: Colors.grey.shade500),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                  ],

                  Text('Спасибо за оплату!', style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontStyle: FontStyle.italic)),

                  const SizedBox(height: 20),

                  // === Кнопки ===
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close, size: 16),
                          label: const Text('Закрыть'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey.shade700,
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _generateAndSharePdf(
                            receiptData ?? d, services, totalPaid, dateStr, timeStr,
                            qrString: qrString, periodCoverage: periodCoverage,
                            totalDebt: totalDebt, overpayment: overpayment, org: org,
                          ),
                          icon: const Icon(Icons.picture_as_pdf, size: 16),
                          label: const Text('PDF'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _receiptDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: List.generate(30, (_) => Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 1),
            height: 1,
            color: Colors.grey.shade300,
          ),
        )),
      ),
    );
  }

  Widget _receiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  /// Генерация QR-кода как PNG байтов (для вставки в PDF)
  Future<Uint8List> _generateQrPng(String data, {double size = 200}) async {
    final qrPainter = QrPainter(
      data: data,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.M,
      gapless: true,
    );
    final imageData = await qrPainter.toImageData(size);
    return imageData!.buffer.asUint8List();
  }

  Future<void> _generateAndSharePdf(
    Map<String, dynamic> d, List services, double totalPaid, String date, String time, {
    String? qrString, List? periodCoverage, double totalDebt = 0,
    double overpayment = 0, Map<String, dynamic>? org,
  }) async {
    try {
      final fontData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
      final ttf = pw.Font.ttf(fontData);

      final pdf = pw.Document(
        theme: pw.ThemeData.withFont(base: ttf, bold: ttf),
      );
      final paidServices = services.where((s) => ((s['paid'] as num?)?.toDouble() ?? 0) > 0).toList();
      // totalDebt уже посчитан по накопительному балансу (backend).
      // Fallback по sum(debt_end) недопустим: при переплате он даёт ложный долг.
      final debtEnd = totalDebt;

      // Генерируем QR PNG если есть строка и долг
      pw.MemoryImage? qrImage;
      if (qrString != null && qrString.isNotEmpty && debtEnd > 0) {
        try {
          final qrPng = await _generateQrPng(qrString, size: 300);
          qrImage = pw.MemoryImage(qrPng);
        } catch (_) {}
      }

      // Покрытие периодов для PDF
      final coverage = (periodCoverage ?? [])
          .where((c) => c['status'] != 'no_charges')
          .toList();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a5,
          margin: const pw.EdgeInsets.all(24),
          theme: pw.ThemeData.withFont(base: ttf, bold: ttf),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Заголовок
                pw.Center(
                  child: pw.Text('ЧЕК ОБ ОПЛАТЕ', style: pw.TextStyle(font: ttf, fontSize: 20, fontWeight: pw.FontWeight.bold)),
                ),
                pw.Center(
                  child: pw.Text('$date  $time', style: pw.TextStyle(font: ttf, fontSize: 10, color: PdfColors.grey700)),
                ),
                if (org != null && (org['name'] ?? '').toString().isNotEmpty)
                  pw.Center(
                    child: pw.Text(org['name'], style: pw.TextStyle(font: ttf, fontSize: 9, color: PdfColors.grey600)),
                  ),
                pw.SizedBox(height: 12),
                pw.Divider(thickness: 1.5),
                pw.SizedBox(height: 8),

                // Данные плательщика
                _pdfInfoRow('Плательщик:', d['fio'] ?? '—', ttf),
                _pdfInfoRow('Лицевой счёт:', d['account_number'] ?? '—', ttf),
                _pdfInfoRow('Адрес:', d['address'] ?? '—', ttf),
                _pdfInfoRow('Период:', d['period_label'] ?? _formatPeriod(d['period_date']), ttf),
                if (d['area'] != null) _pdfInfoRow('Площадь:', '${d['area']} м²', ttf),

                pw.SizedBox(height: 10),
                pw.Divider(),
                pw.SizedBox(height: 6),

                // Таблица услуг
                if (paidServices.isNotEmpty) ...[
                  pw.Text('Оплаченные услуги:', style: pw.TextStyle(font: ttf, fontSize: 11, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 4),
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
                    columnWidths: {0: const pw.FlexColumnWidth(3), 1: const pw.FlexColumnWidth(1)},
                    children: [
                      pw.TableRow(
                        decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                        children: [
                          pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Услуга', style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold, fontSize: 9))),
                          pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Сумма', style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold, fontSize: 9), textAlign: pw.TextAlign.right)),
                        ],
                      ),
                      ...paidServices.map((s) => pw.TableRow(
                        children: [
                          pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(s['label'] ?? s['key'] ?? '', style: pw.TextStyle(font: ttf, fontSize: 9))),
                          pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('${_fmt(s['paid'])} р.', style: pw.TextStyle(font: ttf, fontSize: 9), textAlign: pw.TextAlign.right)),
                        ],
                      )),
                    ],
                  ),
                  pw.SizedBox(height: 8),
                ],

                pw.Divider(thickness: 1.5),
                pw.SizedBox(height: 6),

                // Итого
                if (totalPaid > 0)
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('ИТОГО ОПЛАЧЕНО:', style: pw.TextStyle(font: ttf, fontSize: 13, fontWeight: pw.FontWeight.bold)),
                      pw.Text('${_fmt(totalPaid)} р.', style: pw.TextStyle(font: ttf, fontSize: 13, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                pw.SizedBox(height: 3),
                // Долг ИЛИ переплата — одновременно быть не может
                if (debtEnd > 0.01)
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Остаток долга:', style: pw.TextStyle(font: ttf, fontSize: 9, color: PdfColors.red700)),
                      pw.Text('${_fmt(debtEnd)} р.', style: pw.TextStyle(font: ttf, fontSize: 9, color: PdfColors.red700)),
                    ],
                  )
                else if (overpayment > 0.01)
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Переплата:', style: pw.TextStyle(font: ttf, fontSize: 9, color: PdfColors.green700)),
                      pw.Text('${_fmt(overpayment)} р.', style: pw.TextStyle(font: ttf, fontSize: 9, color: PdfColors.green700)),
                    ],
                  )
                else
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Задолженности нет', style: pw.TextStyle(font: ttf, fontSize: 9, color: PdfColors.green700)),
                      pw.Text('0.00 р.', style: pw.TextStyle(font: ttf, fontSize: 9, color: PdfColors.green700)),
                    ],
                  ),

                // Покрытие периодов — группируем в диапазоны
                if (coverage.isNotEmpty) ...[
                  pw.SizedBox(height: 8),
                  pw.Divider(),
                  pw.SizedBox(height: 4),
                  pw.Text('Расчёт по периодам:', style: pw.TextStyle(font: ttf, fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 3),
                  ...() {
                    final groups = <Map<String, dynamic>>[];
                    for (final c in coverage) {
                      final status = c['status'] as String? ?? '';
                      if (status == 'partial' || groups.isEmpty || groups.last['status'] != status) {
                        groups.add({'status': status, 'status_label': c['status_label'], 'first_label': c['period_label'], 'last_label': c['period_label'], 'count': 1});
                      } else {
                        groups.last['last_label'] = c['period_label'];
                        groups.last['count'] = (groups.last['count'] as int) + 1;
                      }
                    }
                    return groups.map((g) {
                      final status = g['status'] as String;
                      final color = status == 'paid' ? PdfColors.green700
                          : status == 'partial' ? PdfColors.orange700
                          : PdfColors.red700;
                      final marker = status == 'paid' ? '✓' : status == 'partial' ? '◐' : '✗';
                      final count = g['count'] as int;
                      final label = count == 1
                          ? (g['first_label'] as String? ?? '')
                          : 'с ${g['first_label']} по ${g['last_label']}';
                      return pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(vertical: 1),
                        child: pw.Row(children: [
                          pw.Text('$marker ', style: pw.TextStyle(font: ttf, fontSize: 9, color: color)),
                          pw.Expanded(child: pw.Text(label, style: pw.TextStyle(font: ttf, fontSize: 9))),
                          pw.Text(g['status_label'] as String? ?? '', style: pw.TextStyle(font: ttf, fontSize: 8, color: color)),
                        ]),
                      );
                    }).toList();
                  }(),
                ],

                // QR код
                if (qrImage != null) ...[
                  pw.SizedBox(height: 8),
                  pw.Divider(),
                  pw.SizedBox(height: 4),
                  pw.Center(child: pw.Text('Оплата по QR-коду', style: pw.TextStyle(font: ttf, fontSize: 10, fontWeight: pw.FontWeight.bold))),
                  pw.SizedBox(height: 4),
                  pw.Center(child: pw.Image(qrImage, width: 80, height: 80)),
                  pw.SizedBox(height: 2),
                  pw.Center(child: pw.Text('Отсканируйте для оплаты • ${_fmt(debtEnd)} р.', style: pw.TextStyle(font: ttf, fontSize: 8, color: PdfColors.grey600))),
                ],

                pw.SizedBox(height: 10),
                pw.Divider(),
                pw.SizedBox(height: 4),

                // Банковские реквизиты
                if (org != null && (org['bank_name'] ?? '').toString().isNotEmpty)
                  pw.Center(
                    child: pw.Text(
                      'Банк: ${org['bank_name']}  БИК: ${org['bik'] ?? ''}  р/с: ${org['account_number'] ?? ''}',
                      style: pw.TextStyle(font: ttf, fontSize: 7, color: PdfColors.grey500),
                    ),
                  ),

                pw.SizedBox(height: 4),
                pw.Center(
                  child: pw.Text('Спасибо за оплату!', style: pw.TextStyle(font: ttf, fontSize: 10, color: PdfColors.grey600)),
                ),
              ],
            );
          },
        ),
      );

      final dir = await getTemporaryDirectory();
      final fileName = 'check_${d['account_number'] ?? 'receipt'}_${date.replaceAll('.', '')}.pdf';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      if (mounted) {
        final savedPath = await FileExportHelper.exportFile(
          sourceFile: file,
          fileName: fileName,
          mimeType: 'application/pdf',
          subject: 'Чек об оплате — ${d['fio'] ?? ''}',
        );
        if (savedPath != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('✅ Чек сохранён: $savedPath'), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Ошибка генерации PDF: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  pw.Widget _pdfInfoRow(String label, String value, pw.Font ttf) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(width: 100, child: pw.Text(label, style: pw.TextStyle(font: ttf, fontSize: 10, color: PdfColors.grey700))),
          pw.Expanded(child: pw.Text(value, style: pw.TextStyle(font: ttf, fontSize: 10, fontWeight: pw.FontWeight.bold))),
        ],
      ),
    );
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
