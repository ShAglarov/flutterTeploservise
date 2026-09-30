import 'package:flutter/material.dart';
import '../report_utils.dart';
import 'section_card.dart';

/// Секция 1: Общая сводка.
class SummarySection extends StatelessWidget {
  final Map<String, dynamic> data;

  const SummarySection({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final count = data['count'] as int? ?? 0;
    final totalCharged = (data['total_charged'] as num?)?.toDouble() ?? 0;
    final totalPaid = (data['total_paid'] as num?)?.toDouble() ?? 0;
    final totalDebt = (data['total_debt'] as num?)?.toDouble() ?? 0;
    final debtorsCount = data['debtors_count'] as int? ?? 0;
    final overpaidCount = data['overpaid_count'] as int? ?? 0;
    final collection = totalCharged > 0 ? (totalPaid / totalCharged * 100).clamp(0.0, 100.0) : 0.0;

    return ReportSectionCard(
      icon: Icons.pie_chart, title: 'Общая сводка', color: Colors.blue,
      subtitle: '$count лицевых счетов',
      child: Column(
        children: [
          Row(
            children: [
              _metricTile(theme, 'Начислено', '${fmtMoney(totalCharged)}₽', Colors.blue, Icons.receipt_long),
              const SizedBox(width: 8),
              _metricTile(theme, 'Оплачено', '${fmtMoney(totalPaid)}₽', Colors.green, Icons.check_circle),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _metricTile(theme, 'Долг', '${fmtMoney(totalDebt)}₽', totalDebt > 0 ? Colors.red : Colors.green, Icons.warning_amber),
              const SizedBox(width: 8),
              _metricTile(theme, 'Собираемость', '${collection.toStringAsFixed(1)}%',
                  collection >= 80 ? Colors.green : collection >= 50 ? Colors.orange : Colors.red, Icons.speed),
            ],
          ),
          const SizedBox(height: 12),
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
}
