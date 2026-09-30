import 'package:flutter/material.dart';
import 'section_card.dart';

/// Секция 9: Тренд собираемости.
class TrendSection extends StatelessWidget {
  final List<Map<String, dynamic>> trends;

  const TrendSection({super.key, required this.trends});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final avgDelta = trends.isNotEmpty
        ? trends.map((t) => (t['delta'] as num?)?.toDouble() ?? 0).reduce((a, b) => a + b) / trends.length
        : 0.0;

    return ReportSectionCard(
      icon: Icons.trending_up, title: 'Тренд собираемости', color: Colors.indigo,
      subtitle: trends.isEmpty ? 'Недостаточно данных' : 'Средний: ${avgDelta >= 0 ? "+" : ""}${avgDelta.toStringAsFixed(1)}% за период',
      child: trends.isEmpty
          ? const Center(child: Text('Нужно минимум 2 периода', style: TextStyle(fontSize: 13)))
          : Column(
              children: trends.map((t) {
                final delta = (t['delta'] as num?)?.toDouble() ?? 0;
                final coll = (t['collection'] as num?)?.toDouble() ?? 0;
                final isUp = delta >= 0;
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: (isUp ? Colors.green : Colors.red).withAlpha(isDark ? 12 : 6),
                    border: Border.all(color: (isUp ? Colors.green : Colors.red).withAlpha(30)),
                  ),
                  child: Row(
                    children: [
                      Icon(isUp ? Icons.arrow_upward : Icons.arrow_downward,
                          size: 18, color: isUp ? Colors.green : Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t['period_label'] ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            Text('Собираемость: ${coll.toStringAsFixed(1)}%',
                                style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: (isUp ? Colors.green : Colors.red).withAlpha(20),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${isUp ? "+" : ""}${delta.toStringAsFixed(1)}%',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                              color: isUp ? Colors.green : Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }
}
