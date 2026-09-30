import 'package:flutter/material.dart';

/// Обёртка-карточка для секции отчёта с gradient header.
class ReportSectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final String? subtitle;
  final Widget child;

  const ReportSectionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
    required this.child,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDark ? theme.colorScheme.surface : Colors.white,
        border: Border.all(color: theme.dividerColor.withAlpha(isDark ? 30 : 60)),
        boxShadow: isDark ? null : [
          BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          // Gradient header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20),
              ),
              gradient: LinearGradient(
                colors: [
                  color.withAlpha(isDark ? 40 : 25),
                  color.withAlpha(isDark ? 15 : 8),
                ],
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withAlpha(isDark ? 50 : 30),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 20, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: color)),
                      if (subtitle != null)
                        Text(subtitle!, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }
}
