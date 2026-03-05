/// Models for Action Logs (журнал действий).
/// Matches the backend response from /api/v1/action-logs/

class ActionLogEntry {
  final int id;
  final String? uuid;
  final int userId;
  final String actionType;   // create, update, delete, login, logout
  final String entityType;   // boiler_house, incident, saved_location, account, user, etc.
  final dynamic entityId;    // int or String (UUID for management_company)
  final Map<String, dynamic>? changes;
  final Map<String, dynamic>? entityData;
  final DateTime timestamp;
  final String? deviceId;
  final String? message;
  final String? scope;
  final String? screen;
  final String? type;
  final String? userName;

  ActionLogEntry({
    required this.id,
    this.uuid,
    required this.userId,
    required this.actionType,
    required this.entityType,
    this.entityId,
    this.changes,
    this.entityData,
    required this.timestamp,
    this.deviceId,
    this.message,
    this.scope,
    this.screen,
    this.type,
    this.userName,
  });

  factory ActionLogEntry.fromJson(Map<String, dynamic> json) {
    return ActionLogEntry(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      uuid: json['uuid'] as String?,
      userId: json['user_id'] is int ? json['user_id'] : int.tryParse('${json['user_id']}') ?? 0,
      actionType: json['action_type'] as String? ?? '',
      entityType: json['entity_type'] as String? ?? '',
      entityId: json['entity_id'],
      changes: json['changes'] != null ? Map<String, dynamic>.from(json['changes'] as Map) : null,
      entityData: json['entity_data'] != null ? Map<String, dynamic>.from(json['entity_data'] as Map) : null,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      deviceId: json['device_id'] as String?,
      message: json['message'] as String?,
      scope: json['scope'] as String?,
      screen: json['screen'] as String?,
      type: json['type'] as String?,
      userName: json['user_name'] as String?,
    );
  }

  /// Human-readable description of the action.
  String get displayDescription {
    if (message != null && message!.isNotEmpty) return message!;

    return '$actionLabel $entityLabel #$entityId';
  }

  String get actionLabel {
    switch (actionType) {
      case 'create': return 'Создание';
      case 'update': return 'Обновление';
      case 'delete': return 'Удаление';
      case 'login':  return 'Вход';
      case 'logout': return 'Выход';
      default: return actionType;
    }
  }

  String get entityLabel {
    switch (entityType) {
      case 'boiler_house': return 'котельной';
      case 'incident': return 'инцидента';
      case 'saved_location': return 'дома';
      case 'account': return 'лицевого счёта';
      case 'user': return 'пользователя';
      case 'management_company': return 'управляющей компании';
      case 'incident_photo': return 'фото инцидента';
      case 'saved_location_photo': return 'фото дома';
      case 'boiler_house_photo': return 'фото котельной';
      default: return entityType;
    }
  }
}

class ActionLogUser {
  final int id;
  final String username;
  final String? fullName;

  ActionLogUser({
    required this.id,
    required this.username,
    this.fullName,
  });

  factory ActionLogUser.fromJson(Map<String, dynamic> json) {
    return ActionLogUser(
      id: json['id'] as int,
      username: json['username'] as String,
      fullName: json['full_name'] as String?,
    );
  }

  String get displayName => fullName ?? username;
}
