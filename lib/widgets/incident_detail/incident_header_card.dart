import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/user_service.dart';
import '../../models/api_models.dart';
import '../../models/incident_models.dart';
import '../../models/user_role.dart';
import '../base_card.dart';

class IncidentHeaderCard extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(usersProvider);
    final users = usersAsync.value ?? [];
    
    String getUsername(int? id) {
      if (id == null) return "Не назначен";
      final user = users.firstWhere(
        (u) => u.id == id, 
        orElse: () => APIUserResponse(
          id: id, 
          username: 'ID $id', 
          email: '',
          createdAt: DateTime.now().toIso8601String(),
          role: UserRole.viewer,
        ),
      );
      return user.fullName ?? user.username;
    }

    String getNotificationTarget() {
      final config = incident.notificationConfig;
      if (config == null || config.type == AudienceType.broadcast) return "Всем пользователям";
      if (config.type == AudienceType.roleBased) {
        final roleIds = config.roleIds ?? [];
        if (roleIds.isEmpty) return "Никому (роли не выбраны)";
        if (roleIds.length == 1) {
          final role = UserRole.fromAnyString(roleIds.first);
          return "Роль: ${role.title}";
        }
        return "Выбрано ролей: ${roleIds.length}";
      }
      if (config.type == AudienceType.userBased) {
        final ids = config.userIds ?? [];
        if (ids.isEmpty) return "Никому (список пуст)";
        if (ids.length == 1) return getUsername(ids.first);
        return "Выбрано: ${ids.length}";
      }
      return "Всем";
    }

    bool isActive = incident.status != IncidentStatus.resolved && incident.status != IncidentStatus.closed;
    
    // Format date
    String dateStr = '';
    if (incident.createdAt != null) {
      try {
        final dt = DateTime.parse(incident.createdAt!).toLocal();
        dateStr = DateFormat('dd.MM.yyyy HH:mm').format(dt);
      } catch (_) {
        dateStr = incident.createdAt!;
      }
    }

    String stoppedResources = '';
    List<String> stopped = [];
    if (incident.resourceHotWaterStopped == 1) stopped.add('ГВС');
    if (incident.resourceHeatingStopped == 1) stopped.add('Отопление');
    if (stopped.isNotEmpty) {
      stoppedResources = stopped.join(', ');
    }

    return BaseCard(
      child: Stack(
        children: [
          // Left accent line
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 3,
            child: Container(
              decoration: BoxDecoration(
                color: isActive ? Colors.red : Colors.green,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isActive ? Colors.red : Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isActive ? 'АКТИВЕН' : 'РЕШЁН',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      dateStr,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
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
                  incident.boilerHouse?.address ?? 'Адрес не указан',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 16),
                Divider(color: Colors.white.withOpacity(0.1), height: 1),
                const SizedBox(height: 16),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.grey[800],
                      child: const Icon(Icons.person, size: 16, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        getUsername(incident.assignedTo),
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                    Text(
                      'Ответственный',
                      style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(color: Colors.white.withOpacity(0.1), height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.campaign, size: 20, color: Colors.white.withOpacity(0.6)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        getNotificationTarget(),
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                  ],
                ),
                if (stoppedResources.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Divider(color: Colors.white.withOpacity(0.1), height: 1),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 20, color: Colors.orange),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Остановлено: $stoppedResources',
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onEdit,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.white.withOpacity(0.2)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Редактировать', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onStatusToggle,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isActive ? Colors.red : Colors.blue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          isActive ? 'Закрыть инцидент' : 'Открыть повторно',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
