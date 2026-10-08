import 'package:flutter/material.dart';

import 'section_card.dart';

/// Секции по кассе и платежам.
///
/// Все цифры приходят с сервера агрегированными: считать их на клиенте
/// из выборки с лимитом означало бы показывать срез вместо итога.

String _money(num? v) {
  final value = (v ?? 0).toDouble();
  final sign = value < 0 ? '−' : '';
  final abs = value.abs();
  final whole = abs.truncate();
  final cents = ((abs - whole) * 100).round();
  // Разряды пробелами: «1 234 567,89» читается, «1234567.89» — нет.
  final digits = whole.toString();
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write(' ');
    buf.write(digits[i]);
  }
  return cents > 0 ? '$sign$buf,${cents.toString().padLeft(2, '0')} ₽'
                   : '$sign$buf ₽';
}

String _period(String? iso) {
  if (iso == null) return '—';
  final d = DateTime.tryParse(iso);
  if (d == null) return iso;
  const m = ['', 'янв', 'фев', 'мар', 'апр', 'май', 'июн',
             'июл', 'авг', 'сен', 'окт', 'ноя', 'дек'];
  return '${m[d.month]} ${d.year}';
}

String _date(String? iso) {
  if (iso == null) return '—';
  final d = DateTime.tryParse(iso);
  if (d == null) return iso;
  return '${d.day.toString().padLeft(2, '0')}.'
      '${d.month.toString().padLeft(2, '0')}.${d.year}';
}

/// Плитка «метрика + подпись».
class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final String? hint;

  const _Metric({
    required this.label,
    required this.value,
    required this.color,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(fontSize: 11, color: cs.onSurface.withAlpha(165))),
          if (hint != null)
            Text(hint!,
                style: TextStyle(fontSize: 10, color: cs.onSurface.withAlpha(120))),
        ],
      ),
    );
  }
}

/// Кассовая смена: чем кассир закрывает день.
class CashierShiftSection extends StatelessWidget {
  final Map<String, dynamic> data;

  const CashierShiftSection({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final services =
        ((data['by_service'] as List?) ?? const []).cast<Map<String, dynamic>>();
    final cashiers =
        ((data['by_cashier'] as List?) ?? const []).cast<Map<String, dynamic>>();
    final undone = (data['undone'] as num?)?.toInt() ?? 0;

    return ReportSectionCard(
      icon: Icons.point_of_sale,
      title: 'Кассовая смена',
      color: Colors.green,
      subtitle: _date(data['date'] as String?),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Metric(label: 'Принято', value: _money(data['total'] as num?),
                  color: Colors.green),
              _Metric(label: 'Операций',
                  value: '${(data['operations'] as num?)?.toInt() ?? 0}',
                  color: Colors.blue),
              _Metric(label: 'Лицевых счетов',
                  value: '${(data['accounts'] as num?)?.toInt() ?? 0}',
                  color: Colors.indigo),
              _Metric(label: 'Средний платёж',
                  value: _money(data['average'] as num?), color: Colors.teal),
              if (undone > 0)
                // Отмены — повод проверить смену, поэтому красным.
                _Metric(label: 'Отмен', value: '$undone', color: Colors.red,
                    hint: 'в сумму не входят'),
            ],
          ),
          if (services.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text('По услугам',
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600,
                    color: cs.onSurface.withAlpha(175))),
            const SizedBox(height: 6),
            ...services.map((s) => _row(
                  context,
                  s['label']?.toString() ?? '—',
                  _money(s['amount'] as num?),
                  '${(s['count'] as num?)?.toInt() ?? 0} оп.',
                )),
          ],
          if (cashiers.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('По кассирам',
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600,
                    color: cs.onSurface.withAlpha(175))),
            const SizedBox(height: 6),
            ...cashiers.map((c) {
              final un = (c['undone'] as num?)?.toInt() ?? 0;
              return _row(
                context,
                c['cashier']?.toString() ?? '—',
                _money(c['amount'] as num?),
                '${(c['count'] as num?)?.toInt() ?? 0} оп.'
                    '${un > 0 ? ' · отмен $un' : ''}',
                warn: un > 0,
              );
            }),
          ],
          if (services.isEmpty && cashiers.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text('За этот день платежей не было',
                  style: TextStyle(fontSize: 13, color: cs.onSurface.withAlpha(150))),
            ),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value, String sub,
      {bool warn = false}) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12.5)),
                Text(sub,
                    style: TextStyle(
                        fontSize: 10.5,
                        color: warn ? Colors.red : cs.onSurface.withAlpha(140))),
              ],
            ),
          ),
          Text(value,
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

/// Реестр платежей: построчно для бухгалтерии.
class PaymentsRegisterSection extends StatelessWidget {
  final Map<String, dynamic> data;

  const PaymentsRegisterSection({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final rows = ((data['rows'] as List?) ?? const []).cast<Map<String, dynamic>>();
    final truncated = data['truncated'] == true;
    final count = (data['count'] as num?)?.toInt() ?? rows.length;

    return ReportSectionCard(
      icon: Icons.receipt_long,
      title: 'Реестр платежей',
      color: Colors.teal,
      subtitle: 'платежей: $count · итог: ${_money(data['total'] as num?)}',
      child: rows.isEmpty
          ? Text('За период платежей не было',
              style: TextStyle(fontSize: 13, color: cs.onSurface.withAlpha(150)))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (truncated)
                  // Честно говорим, что показаны не все строки: итог при
                  // этом посчитан по всему периоду.
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Показаны первые ${rows.length} из $count. '
                      'Итоговая сумма — по всему периоду.',
                      style: TextStyle(
                          fontSize: 11, color: Colors.orange.shade800),
                    ),
                  ),
                ...rows.take(60).map((r) => _entry(context, r)),
                if (rows.length > 60)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text('…и ещё ${rows.length - 60} в PDF',
                        style: TextStyle(
                            fontSize: 11, color: cs.onSurface.withAlpha(140))),
                  ),
              ],
            ),
    );
  }

  Widget _entry(BuildContext context, Map<String, dynamic> r) {
    final cs = Theme.of(context).colorScheme;
    final period = r['period_from'] as String?;
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${r['account_number'] ?? '—'} · ${r['fio'] ?? 'без имени'}',
                  style: const TextStyle(fontSize: 12.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  [
                    _date(r['date'] as String?),
                    if (r['time'] != null) r['time'].toString(),
                    r['service']?.toString() ?? '',
                    if (period != null) 'за ${_period(period)}',
                    r['cashier']?.toString() ?? '',
                  ].where((e) => e.isNotEmpty).join(' · '),
                  style: TextStyle(fontSize: 10.5, color: cs.onSurface.withAlpha(140)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(_money(r['amount'] as num?),
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

/// Работа кассиров за период.
class CashierPerformanceSection extends StatelessWidget {
  final List<Map<String, dynamic>> rows;

  const CashierPerformanceSection({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final total = rows.fold<double>(
        0, (a, r) => a + ((r['amount'] as num?)?.toDouble() ?? 0));

    return ReportSectionCard(
      icon: Icons.badge,
      title: 'Работа кассиров',
      color: Colors.indigo,
      subtitle: 'всего принято: ${_money(total)}',
      child: rows.isEmpty
          ? Text('Нет данных за период',
              style: TextStyle(fontSize: 13, color: cs.onSurface.withAlpha(150)))
          : Column(
              children: rows.map((r) {
                final amount = (r['amount'] as num?)?.toDouble() ?? 0;
                final share = total > 0 ? amount / total : 0.0;
                final undone = (r['undone'] as num?)?.toInt() ?? 0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(r['cashier']?.toString() ?? '—',
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w500)),
                          ),
                          Text(_money(amount),
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: share,
                          minHeight: 5,
                          backgroundColor: cs.onSurface.withAlpha(18),
                          valueColor: AlwaysStoppedAnimation(
                              undone > 0 ? Colors.orange : Colors.indigo),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${(r['count'] as num?)?.toInt() ?? 0} операций · '
                        'ЛС ${(r['accounts'] as num?)?.toInt() ?? 0} · '
                        'средний ${_money(r['average'] as num?)}'
                        '${undone > 0 ? ' · отмен $undone' : ''}',
                        style: TextStyle(
                            fontSize: 10.5,
                            color: undone > 0
                                ? Colors.orange.shade800
                                : cs.onSurface.withAlpha(140)),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }
}

/// Структура поступлений: текущее / долг / аванс.
class PaymentStructureSection extends StatelessWidget {
  final Map<String, dynamic> data;

  const PaymentStructureSection({super.key, required this.data});

  static const _colors = {
    'current': Colors.green,
    'debt': Colors.orange,
    'advance': Colors.blue,
  };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final buckets =
        ((data['buckets'] as List?) ?? const []).cast<Map<String, dynamic>>();
    final total = (data['total'] as num?)?.toDouble() ?? 0;

    return ReportSectionCard(
      icon: Icons.call_split,
      title: 'Структура поступлений',
      color: Colors.deepPurple,
      subtitle: 'всего: ${_money(total)}',
      child: total == 0
          ? Text('За период платежей не было',
              style: TextStyle(fontSize: 13, color: cs.onSurface.withAlpha(150)))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Полоса-пропорция: сразу видно, какая часть денег ушла в
                // долг, а не в текущие начисления.
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Row(
                    children: buckets.map((b) {
                      final share = (b['share'] as num?)?.toDouble() ?? 0;
                      if (share <= 0) return const SizedBox.shrink();
                      return Expanded(
                        flex: (share * 10).round().clamp(1, 1000),
                        child: Container(
                          height: 10,
                          color: _colors[b['key']] ?? Colors.grey,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
                ...buckets.map((b) {
                  final color = _colors[b['key']] ?? Colors.grey;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 7),
                    child: Row(
                      children: [
                        Container(width: 10, height: 10,
                            decoration: BoxDecoration(
                                color: color, shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(b['label']?.toString() ?? '—',
                              style: const TextStyle(fontSize: 12.5)),
                        ),
                        Text('${b['share'] ?? 0}%',
                            style: TextStyle(
                                fontSize: 11, color: cs.onSurface.withAlpha(150))),
                        const SizedBox(width: 10),
                        Text(_money(b['amount'] as num?),
                            style: const TextStyle(
                                fontSize: 12.5, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  );
                }),
              ],
            ),
    );
  }
}

/// Расширенная сводка собираемости.
class CollectionSummarySection extends StatelessWidget {
  final Map<String, dynamic> data;

  const CollectionSummarySection({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final current = (data['collection_current'] as num?)?.toDouble() ?? 0;
    final total = (data['collection_total'] as num?)?.toDouble() ?? 0;

    return ReportSectionCard(
      icon: Icons.account_balance_wallet,
      title: 'Собираемость',
      color: Colors.blue,
      subtitle: data['scope']?.toString() ?? 'вся база',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Metric(label: 'Начислено', value: _money(data['charged'] as num?),
                  color: Colors.blue),
              _Metric(label: 'Оплачено', value: _money(data['paid'] as num?),
                  color: Colors.green),
              _Metric(label: 'Долг на конец',
                  value: _money(data['debt_end'] as num?), color: Colors.red),
              _Metric(label: 'Должников',
                  value: '${(data['debtors_count'] as num?)?.toInt() ?? 0}',
                  color: Colors.orange),
              _Metric(label: 'Переплат',
                  value: '${(data['overpaid_count'] as num?)?.toInt() ?? 0}',
                  color: Colors.teal),
              _Metric(label: 'Средний долг',
                  value: _money(data['avg_debt'] as num?), color: Colors.brown),
            ],
          ),
          const SizedBox(height: 14),
          // Две цифры вместо одной: общая собираемость может быть выше
          // 100 %, когда гасят долги за прошлые месяцы, и раньше это
          // выглядело ошибкой в отчёте.
          _bar(context, 'Текущая собираемость', current, Colors.green,
              'оплата в счёт начислений периода'),
          const SizedBox(height: 8),
          _bar(context, 'Общая собираемость', total, Colors.blue,
              'все поступления к начисленному'),
          const SizedBox(height: 12),
          Text('Куда пошли деньги',
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600,
                  color: cs.onSurface.withAlpha(175))),
          const SizedBox(height: 6),
          _line(context, 'Текущие начисления', data['paid_current'] as num?),
          _line(context, 'Погашение долга', data['paid_debt'] as num?),
          _line(context, 'Аванс', data['paid_advance'] as num?),
        ],
      ),
    );
  }

  Widget _bar(BuildContext context, String label, double pct, Color color,
      String hint) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: const TextStyle(fontSize: 12.5))),
            Text('${pct.toStringAsFixed(1)} %',
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            // Полоса не должна уезжать за край при >100 %.
            value: (pct / 100).clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: cs.onSurface.withAlpha(18),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
        const SizedBox(height: 2),
        Text(hint,
            style: TextStyle(fontSize: 10, color: cs.onSurface.withAlpha(130))),
      ],
    );
  }

  Widget _line(BuildContext context, String label, num? value) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          children: [
            Expanded(child: Text(label, style: const TextStyle(fontSize: 12))),
            Text(_money(value),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      );
}

/// Распределение долгов по всей базе.
class DebtDistributionSection extends StatelessWidget {
  final Map<String, dynamic> data;

  const DebtDistributionSection({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final groups =
        ((data['groups'] as List?) ?? const []).cast<Map<String, dynamic>>();
    final totalDebt = (data['total_debt'] as num?)?.toDouble() ?? 0;
    final debtors = (data['total_debtors'] as num?)?.toInt() ?? 0;
    final maxCount = groups.fold<int>(
        1, (m, g) => ((g['count'] as num?)?.toInt() ?? 0) > m
            ? (g['count'] as num).toInt() : m);

    return ReportSectionCard(
      icon: Icons.bar_chart,
      title: 'Распределение долгов',
      color: Colors.red,
      // Подпись важна: прежняя версия считала по топ-50, и цифры в
      // отчёте расходились с оборотной ведомостью.
      subtitle: 'должников $debtors · ${_money(totalDebt)} · '
          '${data['scope'] ?? 'вся база'}',
      child: groups.isEmpty
          ? Text('Нет данных',
              style: TextStyle(fontSize: 13, color: cs.onSurface.withAlpha(150)))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...groups.where((g) => ((g['count'] as num?)?.toInt() ?? 0) > 0)
                    .map((g) {
                  final count = (g['count'] as num?)?.toInt() ?? 0;
                  final sum = (g['total'] as num?)?.toDouble() ?? 0;
                  final share = totalDebt > 0 ? sum / totalDebt : 0.0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(g['label']?.toString() ?? '—',
                                  style: const TextStyle(fontSize: 12.5)),
                            ),
                            Text('$count ЛС',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: cs.onSurface.withAlpha(150))),
                            const SizedBox(width: 10),
                            Text(_money(sum),
                                style: const TextStyle(
                                    fontSize: 12.5, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (count / maxCount).clamp(0.0, 1.0),
                            minHeight: 5,
                            backgroundColor: cs.onSurface.withAlpha(18),
                            valueColor: const AlwaysStoppedAnimation(Colors.red),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text('${(share * 100).toStringAsFixed(1)} % всего долга',
                            style: TextStyle(
                                fontSize: 10, color: cs.onSurface.withAlpha(130))),
                      ],
                    ),
                  );
                }),
                if ((data['no_debt_count'] as num?) != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Без долга: ${(data['no_debt_count'] as num).toInt()} ЛС',
                      style: TextStyle(
                          fontSize: 11.5, color: Colors.green.shade700),
                    ),
                  ),
              ],
            ),
    );
  }
}
