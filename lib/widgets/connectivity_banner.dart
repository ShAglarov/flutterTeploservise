import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/connectivity_provider.dart';
import '../providers/offline_edit_permission.dart';

/// Баннер статуса подключения, аналогичный iOS WriteAccessController.
///
/// Два варианта:
/// - **Красный**: «Нет интернета — изменения временно недоступны»
///   (пользователь НЕ имеет права редактировать оффлайн)
/// - **Оранжевый**: «Нет интернета — изменения сохраняются локально»
///   (пользователь ИМЕЕТ право редактировать оффлайн)
/// - **Скрыт**: когда есть подключение к сети.
class ConnectivityBanner extends ConsumerWidget {
  /// Если true, добавляет отступ сверху равный SafeArea (statusBar).
  /// Используется когда баннер размещается в Stack поверх карты.
  final bool includeTopPadding;

  const ConnectivityBanner({super.key, this.includeTopPadding = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOffline = ref.watch(isOfflineProvider);
    if (!isOffline) return const SizedBox.shrink();

    final canEditOffline = ref.watch(canEditOfflineProvider);

    final Color bannerColor;
    final String bannerText;
    final IconData bannerIcon;

    if (canEditOffline) {
      bannerColor = Colors.orange.shade700;
      bannerText = 'Нет интернета — изменения сохраняются локально';
      bannerIcon = Icons.cloud_off_rounded;
    } else {
      bannerColor = Colors.red.shade700;
      bannerText = 'Нет интернета — изменения временно недоступны';
      bannerIcon = Icons.signal_wifi_off_rounded;
    }

    final topPadding = includeTopPadding ? MediaQuery.of(context).padding.top : 0.0;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: ValueKey(canEditOffline),
        width: double.infinity,
        padding: EdgeInsets.only(
          top: topPadding + 6,
          bottom: 6,
          left: 16,
          right: 16,
        ),
        decoration: BoxDecoration(
          color: bannerColor,
          boxShadow: [
            BoxShadow(
              color: bannerColor.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(bannerIcon, color: Colors.white, size: 14),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                bannerText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
