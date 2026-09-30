import 'dart:math';
import 'package:flutter/material.dart';
import '../report_utils.dart';
import 'section_card.dart';

/// Секция 3: Топ должников.
class TopDebtorsSection extends StatelessWidget {
  final List items;
  final void Function(Map<String, dynamic>)? onPersonTap;

  const TopDebtorsSection({super.key, required this.items, this.onPersonTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ReportSectionCard(
      icon: Icons.person_off, title: 'Топ должников', color: Colors.red,
      subtitle: '${items.length} абонентов',
      child: items.isEmpty
          ? const Center(child: Text('Нет должников 🎉', style: TextStyle(fontSize: 13)))
          : Column(
              children: items.asMap().entries.map((e) {
                final i = e.key;
                final d = e.value as Map<String, dynamic>;
                final debt = (d['total_debt_end'] as num?)?.toDouble() ?? 0;
                final charged = (d['total_charged'] as num?)?.toDouble() ?? 0;
                final pct = charged > 0 ? (debt / charged * 100).clamp(0.0, 100.0) : 0.0;

                final Color sevColor;
                final String sevIcon;
                if (debt > 5000) { sevColor = Colors.red; sevIcon = '🔴'; }
                else if (debt > 1000) { sevColor = Colors.orange; sevIcon = '🟠'; }
                else { sevColor = Colors.amber.shade700; sevIcon = '🟡'; }

                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: onPersonTap != null ? () => onPersonTap!(d) : null,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: sevColor.withAlpha(50)),
                      color: sevColor.withAlpha(isDark ? 10 : 6),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 36, child: Column(children: [
                          Text('${i + 1}', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant)),
                          Text(sevIcon, style: const TextStyle(fontSize: 14)),
                        ])),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(d['fio'] ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                  maxLines: 1, overflow: TextOverflow.ellipsis),
                              Text('${d['address'] ?? ''} • ЛС: ${d['account_number'] ?? ''}',
                                  style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant),
                                  maxLines: 1, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 60,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(3),
                                      child: LinearProgressIndicator(
                                        value: charged > 0 ? min(debt / charged, 1.0) : 0,
                                        backgroundColor: Colors.grey.shade200,
                                        color: sevColor, minHeight: 5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text('${pct.toStringAsFixed(0)}%', style: TextStyle(fontSize: 10, color: sevColor)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${fmtMoney(debt)}₽', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: sevColor)),
                            Text('из ${fmtMoney(charged)}₽', style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }
}
