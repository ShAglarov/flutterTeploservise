import 'package:flutter/material.dart';
import '../report_utils.dart';
import 'section_card.dart';

/// Секция 10: Анализ перерасчётов.
class RecalcSection extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  const RecalcSection({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ReportSectionCard(
      icon: Icons.sync_alt, title: 'Анализ перерасчётов', color: Colors.deepOrange,
      subtitle: '${items.length} услуг с перерасчётами',
      child: items.isEmpty
          ? const Center(child: Text('Нет перерасчётов', style: TextStyle(fontSize: 13)))
          : Column(
              children: items.map((s) {
                final recalc = (s['recalc'] as num?)?.toDouble() ?? 0;
                final ratio = (s['recalc_ratio'] as num?)?.toDouble() ?? 0;
                final isAnomaly = s['is_anomaly'] == true;
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: (isAnomaly ? Colors.red : Colors.deepOrange).withAlpha(isDark ? 12 : 6),
                    border: Border.all(color: (isAnomaly ? Colors.red : Colors.deepOrange).withAlpha(30)),
                  ),
                  child: Row(
                    children: [
                      if (isAnomaly)
                        const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: Text('⚠️', style: TextStyle(fontSize: 16)),
                        ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s['label'] ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            Text('Начислено: ${fmtMoney((s['charged'] as num?)?.toDouble() ?? 0)}₽',
                                style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${recalc >= 0 ? "+" : ""}${fmtMoney(recalc)}₽',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                                  color: recalc >= 0 ? Colors.green : Colors.red)),
                          Text('${ratio.toStringAsFixed(1)}% от начисл.',
                              style: TextStyle(fontSize: 10, color: isAnomaly ? Colors.red : theme.colorScheme.onSurfaceVariant)),
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
