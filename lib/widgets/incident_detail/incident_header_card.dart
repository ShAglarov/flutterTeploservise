import 'package:flutter/material.dart';
import '../../models/incident_models.dart';
import '../../utils/app_theme.dart';
import '../base_card.dart';

class IncidentHeaderCard extends StatelessWidget {
  final IncidentResponse incident;
  final VoidCallback? onStatusToggle;
  final VoidCallback? onEdit;

  const IncidentHeaderCard({
    super.key,
    required this.incident,
    this.onStatusToggle,
    this.onEdit,
  });

  @override
  Widget build(BuildContext methodContext) {
    final statusColor = _getStatusColor(incident.status);
    final severityColor = _getSeverityColor(incident.severity);

    return BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      incident.title ?? 'Без названия',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${incident.id}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit, color: Colors.blue),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildBadge(
                incident.status?.name.toUpperCase() ?? 'UNKNOWN',
                statusColor,
              ),
              const SizedBox(width: 8),
              _buildBadge(
                'СЕРЬЕЗНОСТЬ: ${incident.severity ?? "1"}',
                severityColor,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTimeRow(Icons.play_arrow, 'Начало:', incident.createdAt),
          if (incident.resolvedAt != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: _buildTimeRow(Icons.check_circle, 'Решено:', incident.resolvedAt),
            ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onStatusToggle,
              style: ElevatedButton.styleFrom(
                backgroundColor: incident.status == IncidentStatus.resolved || incident.status == IncidentStatus.closed
                    ? Colors.blue
                    : Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                incident.status == IncidentStatus.resolved || incident.status == IncidentStatus.closed
                    ? 'ОТКРЫТЬ ПОВТОРНО'
                    : 'ЗАВЕРШИТЬ ИНЦИДЕНТ',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTimeRow(IconData icon, String label, String? time) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white.withOpacity(0.6)),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          time ?? '—',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(IncidentStatus? status) {
    return switch (status) {
      IncidentStatus.open => Colors.red,
      IncidentStatus.inProgress => Colors.orange,
      IncidentStatus.resolved => Colors.green,
      IncidentStatus.closed => Colors.blue,
      _ => Colors.grey,
    };
  }

  Color _getSeverityColor(String? severity) {
    return switch (severity) {
      '3' => Colors.red,
      '2' => Colors.yellow,
      '1' => Colors.green,
      _ => Colors.blue,
    };
  }
}
