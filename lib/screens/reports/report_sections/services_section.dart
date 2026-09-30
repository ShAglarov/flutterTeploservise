import 'dart:math';
import 'package:flutter/material.dart';
import '../report_utils.dart';
import 'section_card.dart';

/// Секция 6: Разбивка по услугам.
class ServicesSection extends StatelessWidget {
  final List<Map<String, dynamic>> services;

  const ServicesSection({super.key, required this.services});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final maxCharged = services.isNotEmpty
        ? services.map((s) => (s['charged'] as num?)?.toDouble() ?? 0).reduce(max)
        : 1.0;

    const svcColors = <String, Color>{
      'heating': Color(0xFFEF5350),
      'hot_water': Color(0xFFFFA726),
      'maintenance': Color(0xFF42A5F5),
      'waste': Color(0xFF8D6E63),
      'odn_electricity': Color(0xFFFFB300),
      'odn_water': Color(0xFF26C6DA),
    };

    return ReportSectionCard(
      icon: Icons.category, title: 'Разбивка по услугам', color: Colors.amber,
      subtitle: '${services.length} услуг',
      child: services.isEmpty
          ? const Center(child: Text('Нет данных', style: TextStyle(fontSize: 13)))
          : Column(
              children: services.map((s) {
                final charged = (s['charged'] as num?)?.toDouble() ?? 0;
                final paid = (s['paid'] as num?)?.toDouble() ?? 0;
                final debt = (s['debt'] as num?)?.toDouble() ?? 0;
                final color = svcColors[s['key']] ?? Colors.grey;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: color.withAlpha(isDark ? 15 : 8),
                    border: Border.all(color: color.withAlpha(30)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          Text(s['label'] ?? '', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: maxCharged > 0 ? (charged / maxCharged).clamp(0.0, 1.0) : 0,
                          backgroundColor: Colors.grey.withAlpha(30),
                          color: color, minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Начисл: ${fmtMoney(charged)}₽', style: TextStyle(fontSize: 10, color: color)),
                          Text('Оплач: ${fmtMoney(paid)}₽', style: const TextStyle(fontSize: 10, color: Colors.green)),
                          Text('Долг: ${fmtMoney(debt)}₽',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: debt > 0 ? Colors.red : Colors.green)),
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
