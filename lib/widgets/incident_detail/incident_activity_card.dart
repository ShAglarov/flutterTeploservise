import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/activity_providers.dart';
import '../../models/activity_models.dart';
import '../base_card.dart';

class IncidentActivityCard extends ConsumerWidget {
  final int incidentId;

  const IncidentActivityCard({super.key, required this.incidentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityState = ref.watch(incidentActivityFeedProvider(incidentId));

    return BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history, color: Colors.white.withOpacity(0.7), size: 20),
              const SizedBox(width: 8),
              const Text(
                'Лента активности',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          activityState.when(
            data: (activities) {
              if (activities.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Нет активности',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }
              return Column(
                children: activities.map((activity) => _buildActivityItem(activity)).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Ошибка: $err', style: const TextStyle(color: Colors.red))),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(IncidentActivity activity) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: Colors.grey[800],
            child: const Icon(Icons.person, size: 16, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        activity.userName ?? 'Неизвестный пользователь',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      _formatTime(activity.timestamp),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                _buildActionText(activity),
                if (activity.parsedChanges.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  ...activity.parsedChanges.map((change) => _buildChangeRow(change)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionText(IncidentActivity activity) {
    Color iconColor = Colors.blue;
    IconData iconData = Icons.info;
    String actionText = '';

    switch (activity.actionType) {
      case 'create':
        iconColor = Colors.green;
        iconData = Icons.add_circle_outline;
        actionText = 'создал(а) инцидент';
        break;
      case 'update':
        iconColor = Colors.orange;
        iconData = Icons.sync;
        actionText = 'изменил(а) инцидент';
        break;
      case 'delete':
        iconColor = Colors.red;
        iconData = Icons.delete_outline;
        actionText = 'удалил(а) инцидент';
        break;
      case 'comment':
        iconColor = Colors.blue;
        iconData = Icons.chat_bubble_outline;
        actionText = 'оставил(а) комментарий';
        break;
      default:
        actionText = activity.message ?? 'Выполнил действие';
    }

    return Row(
      children: [
        Icon(iconData, size: 14, color: iconColor),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            '${(activity.userName ?? "Неизвестный").split(' ').first} $actionText',
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildChangeRow(ActivityChange change) {
    return Padding(
      padding: const EdgeInsets.only(left: 18.0, top: 2.0),
      child: Text(
        '${_translateField(change.field)}: ${_formatValue(change.oldValue)} → ${_formatValue(change.newValue)}',
        style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
      ),
    );
  }

  String _translateField(String field) {
    switch (field) {
      case 'status': return 'Статус';
      case 'assigned_to': return 'Ответственный';
      case 'title': return 'Название';
      case 'description': return 'Описание';
      case 'severity': return 'Серьезность';
      default: return field;
    }
  }

  String _formatValue(dynamic value) {
    if (value == null) return 'Пусто';
    
    // Customize status translations based on backend returns
    if (value is String) {
      switch (value.toLowerCase()) {
        case 'open': return 'Открыт';
        case 'in_progress': return 'В работе';
        case 'resolved': return 'Решён';
        case 'closed': return 'Закрыт';
      }
    }
    return value.toString();
  }

  String _formatTime(String createdAt) {
    try {
      final dt = DateTime.parse(createdAt).toLocal();
      final now = DateTime.now();
      
      if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
        return DateFormat('HH:mm').format(dt);
      }
      return DateFormat('dd.MM.yyyy, HH:mm').format(dt);
    } catch (_) {
      return '';
    }
  }
}
