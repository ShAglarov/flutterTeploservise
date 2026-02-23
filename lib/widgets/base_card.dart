import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class BaseCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;

  const BaseCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.cardCornerRadius),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(AppTheme.cardPadding),
          child: child,
        ),
      ),
    );
  }
}
