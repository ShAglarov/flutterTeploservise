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
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSeverityIndicator(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      location,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(context),
          const SizedBox(height: 12),
          if (stoppedServicesText != null) _buildResourcesSection(),
        ],
      ),
    );
  }

  Widget _buildSeverityIndicator() {
    return Container(
      width: 4,
      height: 40,
      decoration: BoxDecoration(
        color: isStatusActive ? AppTheme.errorRed : AppTheme.successGreen,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (isStatusActive ? AppTheme.errorRed : AppTheme.successGreen).withAlpha(30),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: (isStatusActive ? AppTheme.errorRed : AppTheme.successGreen).withAlpha(100),
          width: 1,
        ),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: isStatusActive ? AppTheme.errorRed : AppTheme.successGreen,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context) {
    return Row(
      children: [
        _buildInfoItem(Icons.access_time_filled, timestamp),
        const SizedBox(width: 16),
        _buildInfoItem(Icons.people_alt_rounded, '$affectedPopulationCount чел.'),
        if (assigneeName != null) ...[
          const SizedBox(width: 16),
          Expanded(child: _buildInfoItem(Icons.person, assigneeName!, isExpand: true)),
        ],
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String text, {bool isExpand = false}) {
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.white38),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white54, fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
    return isExpand ? Expanded(child: content) : content;
  }

  Widget _buildResourcesSection() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.block_flipped, size: 14, color: AppTheme.warningOrange),
          const SizedBox(width: 8),
          Text(
            'Отключено: $stoppedServicesText',
            style: const TextStyle(
              color: AppTheme.warningOrange,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
