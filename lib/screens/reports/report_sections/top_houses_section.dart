import 'dart:math';
import 'package:flutter/material.dart';
import '../report_utils.dart';
import 'section_card.dart';

/// Секция 2: Топ домов по долгу.
class TopHousesSection extends StatelessWidget {
  final List<Map<String, dynamic>> houses;

  const TopHousesSection({super.key, required this.houses});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final maxDebt = houses.isNotEmpty
        ? houses.map((h) => (h['total_debt'] as num?)?.toDouble() ?? 0).reduce(max)
        : 1.0;

    return ReportSectionCard(
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
                          Text('${fmtMoney(debt)}₽', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                              color: debt > 0 ? Colors.red : Colors.green)),
                        ],
                      ),
                      const SizedBox(height: 8),
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
}
