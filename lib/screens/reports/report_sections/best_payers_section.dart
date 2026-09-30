import 'package:flutter/material.dart';
import '../report_utils.dart';
import 'section_card.dart';

/// Секция 8: Лучшие плательщики.
class BestPayersSection extends StatelessWidget {
  final List items;
  final void Function(Map<String, dynamic>)? onPersonTap;

  const BestPayersSection({super.key, required this.items, this.onPersonTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ReportSectionCard(
      icon: Icons.star, title: 'Лучшие плательщики', color: Colors.purple,
      subtitle: '${items.length} абонентов',
      child: items.isEmpty
          ? const Center(child: Text('Нет данных', style: TextStyle(fontSize: 13)))
          : Column(
              children: items.asMap().entries.map((e) {
                final i = e.key;
                final d = e.value as Map<String, dynamic>;
                final pct = (d['_pay_percent'] as num?)?.toDouble() ?? 0;
                final paid = (d['total_paid'] as num?)?.toDouble() ?? 0;
                final locationName = d['location_name']?.toString() ?? '';
                final address = d['address']?.toString() ?? '';

                String medal = '';
                if (i == 0) medal = '🥇';
                if (i == 1) medal = '🥈';
                if (i == 2) medal = '🥉';

                return InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: onPersonTap != null ? () => onPersonTap!(d) : null,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: i < 3 ? Colors.purple.withAlpha(isDark ? 15 : 8) : Colors.transparent,
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 30, child: Text(
                          medal.isNotEmpty ? medal : '${i + 1}',
                          style: TextStyle(fontSize: medal.isNotEmpty ? 18 : 11, color: theme.colorScheme.onSurfaceVariant),
                        )),
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
                              Text('Оплачено: ${fmtMoney(paid)}₽',
                                  style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.purple.withAlpha(20),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text('${pct.toStringAsFixed(0)}%',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.purple)),
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
