import 'package:flutter/material.dart';
import '../report_utils.dart';
import 'section_card.dart';

/// Секция 5: Динамика по периодам.
class DynamicsSection extends StatelessWidget {
  final List<Map<String, dynamic>> periods;

  const DynamicsSection({super.key, required this.periods});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    double maxCharged = 1;
    for (final p in periods) {
      final ch = (p['total_charged'] as num?)?.toDouble() ?? 0;
      if (ch > maxCharged) maxCharged = ch;
    }

    return ReportSectionCard(
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
                          Text(p['period_label'] ?? formatPeriod(p['period']?.toString()),
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                          const Spacer(),
                          Text('${p['count'] ?? 0} ЛС', style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _miniBar('Начисл.', charged, maxCharged, Colors.blue, theme),
                      const SizedBox(height: 4),
                      _miniBar('Оплач.', paid, maxCharged, Colors.green, theme),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text('Долг: ${fmtMoney(debt)}₽',
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
        SizedBox(width: 65, child: Text('${fmtMoney(value)}₽', textAlign: TextAlign.right,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color))),
      ],
    );
  }
}
