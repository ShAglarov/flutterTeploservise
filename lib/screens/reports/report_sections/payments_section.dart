import 'package:flutter/material.dart';
import '../report_utils.dart';
import 'section_card.dart';

/// Секция 4: Последние оплаты.
class PaymentsSection extends StatelessWidget {
  final List items;
  final void Function(Map<String, dynamic>)? onPersonTap;

  const PaymentsSection({super.key, required this.items, this.onPersonTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ReportSectionCard(
      icon: Icons.payment, title: 'Последние оплаты', color: Colors.green,
      subtitle: '${items.length} абонентов',
      child: items.isEmpty
          ? const Center(child: Text('Нет оплат', style: TextStyle(fontSize: 13)))
          : Column(
              children: items.asMap().entries.map((e) {
                final i = e.key;
                final d = e.value as Map<String, dynamic>;
                final paid = (d['total_paid'] as num?)?.toDouble() ?? 0;
                final debt = (d['total_debt_end'] as num?)?.toDouble() ?? 0;
                final charged = (d['total_charged'] as num?)?.toDouble() ?? 0;
                final address = d['address'] as String? ?? '';
                final locationName = d['location_name'] as String? ?? '';

                String paidMonthsLabel = '';
                if (charged > 0 && paid > 0) {
                  final months = (paid / charged).floor();
                  if (months >= 1) paidMonthsLabel = '≈$months мес.';
                }

                final bool isOverpaid = debt < -0.01;
                final String debtLabel = isOverpaid
                    ? 'переплата: ${fmtMoney(debt.abs())}₽'
                    : 'долг: ${fmtMoney(debt)}₽';
                final Color debtColor = isOverpaid ? Colors.teal : (debt > 0.01 ? Colors.red : Colors.green);

                return InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: onPersonTap != null ? () => onPersonTap!(d) : null,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: theme.colorScheme.surfaceContainerHighest.withAlpha(isDark ? 30 : 20),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 24, child: Text('${i + 1}', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant))),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(d['fio'] ?? '', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                  maxLines: 2, overflow: TextOverflow.ellipsis),
                              if (locationName.isNotEmpty)
                                Text('🏠 $locationName',
                                    style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant),
                                    maxLines: 2, overflow: TextOverflow.ellipsis),
                              if (address.isNotEmpty)
                                Text('📍 $address',
                                    style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant),
                                    maxLines: 2, overflow: TextOverflow.ellipsis),
                              Text('ЛС: ${d['account_number'] ?? ''}',
                                  style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('+${fmtMoney(paid)}₽', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.green)),
                            Text(debtLabel, style: TextStyle(fontSize: 10, color: debtColor)),
                            if (paidMonthsLabel.isNotEmpty)
                              Text(paidMonthsLabel, style: TextStyle(fontSize: 9, color: theme.colorScheme.onSurfaceVariant)),
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
