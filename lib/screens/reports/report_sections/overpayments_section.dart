import 'package:flutter/material.dart';
import '../report_utils.dart';
import 'section_card.dart';

/// Секция 7: Переплаты.
class OverpaymentsSection extends StatelessWidget {
  final List items;
  final void Function(Map<String, dynamic>)? onPersonTap;

  const OverpaymentsSection({super.key, required this.items, this.onPersonTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ReportSectionCard(
      icon: Icons.trending_down, title: 'Переплаты', color: Colors.teal,
      subtitle: '${items.length} абонентов',
      child: items.isEmpty
          ? const Center(child: Text('Нет переплат', style: TextStyle(fontSize: 13)))
          : Column(
              children: items.asMap().entries.map((e) {
                final i = e.key;
                final d = e.value as Map<String, dynamic>;
                final debt = (d['total_debt_end'] as num?)?.toDouble() ?? 0;
                final overpay = debt.abs();
                final locationName = d['location_name']?.toString() ?? '';
                final address = d['address']?.toString() ?? '';

                return InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: onPersonTap != null ? () => onPersonTap!(d) : null,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.teal.withAlpha(isDark ? 12 : 6),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 24, child: Text('${i + 1}', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant))),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(d['fio'] ?? '', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                  maxLines: 1, overflow: TextOverflow.ellipsis),
                              if (locationName.isNotEmpty)
                                Text('🏠 $locationName', style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant),
                                    maxLines: 1, overflow: TextOverflow.ellipsis),
                              if (address.isNotEmpty)
                                Text('📍 $address', style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant),
                                    maxLines: 1, overflow: TextOverflow.ellipsis),
                              Text('ЛС: ${d['account_number'] ?? ''}',
                                  style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant)),
                            ],
                          ),
                        ),
                        Text('+${fmtMoney(overpay)}₽', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.teal)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }
}
