import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'base_card.dart';

class IncidentCard extends StatelessWidget {
  final String title;
  final String location;
  final String timestamp;
  final String statusText;
  final bool isStatusActive;
  final String? assigneeName;
  final String? stoppedServicesText;
  final int affectedPopulationCount;
  final String? boilerHouseDetail;
  final String? broadcastText;
  final bool isUnsynced;
  final VoidCallback? onTap;

  const IncidentCard({
    super.key,
    required this.title,
    required this.location,
    required this.timestamp,
    required this.statusText,
    required this.isStatusActive,
    this.assigneeName,
    this.stoppedServicesText,
    required this.affectedPopulationCount,
    this.boilerHouseDetail,
    this.broadcastText,
    this.isUnsynced = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      elevation: isDark ? 0 : 2,
      shadowColor: isDark ? Colors.transparent : Colors.black.withAlpha(40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark 
            ? Theme.of(context).colorScheme.onSurface.withAlpha(25) 
            : const Color(0xFFD1D1D6), // iOS separator color
          width: 1,
        ),
      ),
      color: Theme.of(context).colorScheme.surface,
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 4,
                color: isStatusActive ? AppTheme.errorRed : AppTheme.successGreen,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              _buildStatusBadge(),
                              if (isUnsynced) ...[
                                const SizedBox(width: 8),
                                const Icon(Icons.cloud_upload_outlined, size: 16, color: AppTheme.warningOrange),
                              ],
                            ],
                          ),
                          Flexible(
                            child: Text(
                              timestamp,
                              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(180), fontSize: 12, fontWeight: FontWeight.w600),
                              textAlign: TextAlign.right,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        boilerHouseDetail ?? location,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                                            Divider(height: 1, color: Theme.of(context).colorScheme.onSurface.withAlpha(25)),
                      _buildActionRow(
                        context,
                        icon: Icons.account_circle,
                        text: assigneeName ?? 'Не назначен',
                        rightText: 'Assigned',
                      ),
                      if (broadcastText != null) ...[
                                              Divider(height: 1, color: Theme.of(context).colorScheme.onSurface.withAlpha(25)),
                        _buildActionRow(
                          context,
                          icon: Icons.campaign,
                          text: broadcastText!,
                        ),
                      ],
                      if (stoppedServicesText != null) ...[
                                              Divider(height: 1, color: Theme.of(context).colorScheme.onSurface.withAlpha(25)),
                        _buildActionRow(
                          context,
                          icon: Icons.warning_rounded,
                          iconColor: AppTheme.warningOrange,
                          text: 'Остановлено: $stoppedServicesText',
                        ),
                      ],
                      if (affectedPopulationCount > 0) ...[
                                              Divider(height: 1, color: Theme.of(context).colorScheme.onSurface.withAlpha(25)),
                        _buildActionRow(
                          context,
                          icon: Icons.people,
                          text: 'Без услуг: $affectedPopulationCount чел.',
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isStatusActive ? AppTheme.errorRed : AppTheme.successGreen,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statusText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionRow(
    BuildContext context, {
    required IconData icon,
    required String text,
    String? rightText,
    Color? iconColor,
  }) {
    final defaultIconColor = Theme.of(context).colorScheme.onSurface.withAlpha(140);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor ?? defaultIconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (rightText != null)
            Text(
              rightText,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(140),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}
