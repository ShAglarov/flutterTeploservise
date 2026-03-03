import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/activity_providers.dart';
import '../../models/activity_models.dart';
import '../../services/user_service.dart';
import '../base_card.dart';

class IncidentActivityCard extends ConsumerWidget {
  final int incidentId;

  const IncidentActivityCard({super.key, required this.incidentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityState = ref.watch(incidentActivityFeedProvider(incidentId));
    final usersMap = ref.watch(usersMapProvider).value ?? {};

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
                children: activities.map((activity) => _buildActivityItem(activity, usersMap)).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Ошибка: $err', style: const TextStyle(color: Colors.red))),
          ),
        ],
      ),
    );
  }
  Widget _buildActivityItem(IncidentActivity activity, Map<int, dynamic> usersMap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: Colors.white.withOpacity(0.1),
            child: const Icon(Icons.person, size: 16, color: Colors.white70),
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
                          fontSize: 15,
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
                const SizedBox(height: 6),
                _buildActionRow(activity),
                const SizedBox(height: 4),
                ..._buildCustomChangeWidgets(activity, usersMap),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(IncidentActivity activity) {
    Color iconColor = Colors.blue;
    IconData iconData = Icons.info;
    String actionSuffix = '';

    switch (activity.actionType) {
      case 'create':
        iconColor = Colors.green;
        iconData = Icons.add_circle;
        actionSuffix = 'создал инцидент';
        break;
      case 'update':
        iconColor = Colors.orange;
        iconData = Icons.edit_note;
        actionSuffix = 'изменил инцидент';
        break;
      case 'delete':
        iconColor = Colors.red;
        iconData = Icons.delete_forever;
        actionSuffix = 'удалил инцидент';
        break;
      case 'comment':
        iconColor = Colors.blue;
        iconData = Icons.comment;
        actionSuffix = 'оставил комментарий';
        break;
      default:
        actionSuffix = activity.message ?? 'выполнил действие';
    }

    return Row(
      children: [
        Icon(iconData, size: 18, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '${activity.userName ?? "Пользователь"} $actionSuffix',
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildCustomChangeWidgets(IncidentActivity activity, Map<int, dynamic> usersMap) {
    final widgets = <Widget>[];
    final changes = activity.parsedChanges;

    // Check for specific fields to show icons
    for (final change in changes) {
      final field = change.field;
      final newVal = change.newValue;

      if (field == 'affected_house_ids') {
        if (newVal is List) {
          widgets.add(_buildPrettyRow(Icons.business, 'Затронуто домов: ${newVal.length}', Colors.blueAccent));
          widgets.add(_buildPrettyRow(null, 'Затронутые дома:...', Colors.white54, isSub: true));
        }
      } else if (field == 'resource_hot_water_stopped' && _isTruthy(newVal)) {
        widgets.add(_buildPrettyRow(Icons.warning_amber_rounded, 'ГВС остановлено', Colors.orange));
      } else if (field == 'resource_heating_stopped' && _isTruthy(newVal)) {
        widgets.add(_buildPrettyRow(Icons.local_fire_department, 'Отопление остановлено', Colors.orange));
      } else if (field == 'assigned_to') {
        widgets.add(_buildPrettyRow(Icons.person_outline, 'Ответственный: ${_formatValue(change.oldValue, usersMap: usersMap)} → ${_formatValue(change.newValue, usersMap: usersMap)}', Colors.blue));
      } else if (['status', 'title', 'severity'].contains(field)) {
        // Generic fields with translation
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 26, top: 2),
            child: Text(
              '${_translateField(field)}: ${_formatValue(change.oldValue, usersMap: usersMap)} → ${_formatValue(change.newValue, usersMap: usersMap)}',
              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
            ),
          ),
        );
      }
    }
    return widgets;
  }

  Widget _buildPrettyRow(IconData? icon, String text, Color color, {bool isSub = false}) {
    return Padding(
      padding: EdgeInsets.only(left: isSub ? 44.0 : 26.0, top: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: TextStyle(
              color: isSub ? Colors.white.withOpacity(0.4) : Colors.white.withOpacity(0.9),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  bool _isTruthy(dynamic value) {
    if (value == null) return false;
    if (value is int) return value == 1;
    if (value is bool) return value;
    if (value is String) return value == '1' || value.toLowerCase() == 'true';
    return false;
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

  String _formatValue(dynamic value, {Map<int, dynamic>? usersMap}) {
    if (value == null) return 'Пусто';
    
    int? intVal;
    if (value is int) {
      intVal = value;
    } else if (value is String) {
      intVal = int.tryParse(value);
    }
    
    if (intVal != null && usersMap != null && usersMap.containsKey(intVal)) {
      final user = usersMap[intVal];
      if (user != null) {
        final fio = (user.lastName != null && user.firstName != null)
            ? '${user.lastName} ${user.firstName}'
            : (user.fullName ?? user.username ?? 'ID $intVal');
        
        if (user.position != null && user.position!.isNotEmpty) {
          return '$fio (${user.position})';
        }
        return fio;
      }
    }
    
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
