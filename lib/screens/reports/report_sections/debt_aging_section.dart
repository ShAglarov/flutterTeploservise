import 'dart:math';
import 'package:flutter/material.dart';
import '../report_utils.dart';
import 'section_card.dart';

/// Секция 11: Группировка долгов (Debt Aging).
class DebtAgingSection extends StatelessWidget {
  final List<Map<String, dynamic>> groups;

  const DebtAgingSection({super.key, required this.groups});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final maxCount = groups.isNotEmpty
        ? groups.map((g) => g['count'] as int).reduce(max).toDouble()
        : 1.0;
    final totalDebtors = groups.fold<int>(0, (sum, g) => sum + (g['count'] as int));

    return ReportSectionCard(
      icon: Icons.hourglass_bottom, title: 'Группировка долгов', color: Colors.brown,
      subtitle: '$totalDebtors должников',
      child: groups.isEmpty
          ? const Center(child: Text('Нет данных', style: TextStyle(fontSize: 13)))
          : Column(
              children: groups.map((g) {
                final count = g['count'] as int;
                final total = g['total'] as double;
                final color = g['color'] as Color? ?? Colors.brown;
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: color.withAlpha(isDark ? 12 : 6),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          Expanded(child: Text(g['label'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                          Text('$count чел.', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: maxCount > 0 ? (count / maxCount).clamp(0.0, 1.0) : 0,
                          backgroundColor: Colors.grey.withAlpha(30),
                          color: color, minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('Сумма: ${fmtMoney(total)}₽',
                          style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }
}
