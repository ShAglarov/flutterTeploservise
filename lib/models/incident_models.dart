import 'package:json_annotation/json_annotation.dart';

part 'incident_models.g.dart';

enum IncidentStatus {
  @JsonValue('open')
  open,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('resolved')
  resolved,
  @JsonValue('closed')
  closed;

  String get title {
    return switch (this) {
      IncidentStatus.open => 'Открыт',
      IncidentStatus.inProgress => 'В работе',
      IncidentStatus.resolved => 'Решен',
      IncidentStatus.closed => 'Закрыт',
    };
  }

  static IncidentStatus fromAny(dynamic value) {
    if (value is String) {
      final normalized = value.toLowerCase();
      return switch (normalized) {
        'open' => IncidentStatus.open,
        'in_progress' || 'inprogress' => IncidentStatus.inProgress,
        'resolved' => IncidentStatus.resolved,
        'closed' => IncidentStatus.closed,
        _ => IncidentStatus.open,
      };
    } else if (value is Map<String, dynamic> && value.containsKey('value')) {
      return fromAny(value['value']);
    }
    return IncidentStatus.open;
  }
}

enum AudienceType {
  @JsonValue('broadcast')
  broadcast,
  @JsonValue('role_based')
  roleBased,
  @JsonValue('user_based')
  userBased;

  static AudienceType fromAny(dynamic value) {
    if (value is String) {
      final normalized = value.toLowerCase().replaceAll('_', '');
      return switch (normalized) {
        'broadcast' => AudienceType.broadcast,
        'rolebased' => AudienceType.roleBased,
        'userbased' => AudienceType.userBased,
        _ => AudienceType.broadcast,
      };
    }
    return AudienceType.broadcast;
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class NotificationConfig {
  @JsonKey(fromJson: AudienceType.fromAny)
  final AudienceType type;
  final List<String>? roleIds;
  final List<int>? userIds;

  NotificationConfig({
    required this.type,
    this.roleIds,
    this.userIds,
  });

  factory NotificationConfig.fromJson(Map<String, dynamic> json) => _$NotificationConfigFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationConfigToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class SavedLocationInfo {
  @JsonKey(fromJson: _idFromJson)
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final int? floors;
  final int? rooms;
  final double? totalArea;
  final int? residentsCount;
  final int? yearBuilt;

  SavedLocationInfo({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.floors,
    this.rooms,
    this.totalArea,
    this.residentsCount,
    this.yearBuilt,
  });

  factory SavedLocationInfo.fromJson(Map<String, dynamic> json) => _$SavedLocationInfoFromJson(json);
  Map<String, dynamic> toJson() => _$SavedLocationInfoToJson(this);
  
  static int _idFromJson(dynamic id) {
    if (id is int) return id;
    if (id is String) return int.tryParse(id) ?? 0;
    return 0;
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class AffectedHouseDetail {
  final int savedLocationId;
  final double? area;
  final String? status;
  final int? residentsCount;
  final String? notes;
  final SavedLocationInfo? savedLocation;

  AffectedHouseDetail({
    required this.savedLocationId,
    this.area,
    this.status,
    this.residentsCount,
    this.notes,
    this.savedLocation,
  });

  factory AffectedHouseDetail.fromJson(Map<String, dynamic> json) => _$AffectedHouseDetailFromJson(json);
  Map<String, dynamic> toJson() => _$AffectedHouseDetailToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class BoilerHouseSummary {
  final int id;
  final String address;
  final double latitude;
  final double longitude;
  final int activeIncidentsCount;
  final int hasActiveIncidents;
  final String? siteNumber;
  final String? siteManager;
  final int? totalBoilersCount;
  final String? boilerHouseColorStatus; // "normal", "partial", "full"

  BoilerHouseSummary({
    required this.id,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.activeIncidentsCount,
    required this.hasActiveIncidents,
    this.siteNumber,
    this.siteManager,
    this.totalBoilersCount,
    this.boilerHouseColorStatus,
  });

  bool get hasActiveIncidentsBool => hasActiveIncidents > 0;

  factory BoilerHouseSummary.fromJson(Map<String, dynamic> json) => _$BoilerHouseSummaryFromJson(json);
  Map<String, dynamic> toJson() => _$BoilerHouseSummaryToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class IncidentResponse {
  final int id;
  final int? boilerHouseId;
  final String? title;
  final String? description;
  
  @JsonKey(fromJson: IncidentStatus.fromAny)
  final IncidentStatus? status;
  
  final String? severity;
  final int? resourceHotWaterStopped;
  final int? resourceHeatingStopped;
  final int? reportedBy;
  final int? assignedTo;
  final String? createdAt;
  final String? updatedAt;
  final String? resolvedAt;
  
  // Поля для запланированных инцидентов
  final String? startedAt;
  final String? finishedAt;
  @JsonKey(name: 'is_scheduled', defaultValue: false)
  final bool isScheduled;
  
  @JsonKey(name: 'local_uuid')
  final String? localUUID;
  
  final bool? localPendingAck;
  
  final List<int>? affectedHouseIds;
  final List<AffectedHouseDetail>? affectedHouseDetails;
  final BoilerHouseSummary? boilerHouse;
  final List<PhotoInfo>? photos;
  final NotificationConfig? notificationConfig;
  
  // Поля для управления котлами
  final List<int>? inactiveBoilerNumbers; // [1, 3] — номера неработающих котлов
  final bool? supplyFullyStopped;          // тумблер "Не поступает полностью"
  final String? colorStatus;               // "normal", "partial", "full"
  
  /// Автоматически завершить инцидент по наступлении finishedAt
  final bool autoResolveOnFinish;

  IncidentResponse({
    required this.id,
    this.boilerHouseId,
    this.title,
    this.description,
    this.status,
    this.severity,
    this.resourceHotWaterStopped,
    this.resourceHeatingStopped,
    this.reportedBy,
    this.assignedTo,
    this.createdAt,
    this.updatedAt,
    this.resolvedAt,
    this.startedAt,
    this.finishedAt,
    this.isScheduled = false,
    this.localUUID,
    this.localPendingAck,
    this.affectedHouseIds,
    this.affectedHouseDetails,
    this.boilerHouse,
    this.photos,
    this.notificationConfig,
    this.inactiveBoilerNumbers,
    this.supplyFullyStopped,
    this.colorStatus,
    this.autoResolveOnFinish = false,
  });

  /// Проверяет локально, запланирован ли инцидент (startedAt в будущем).
  /// НЕ используем серверный isScheduled — он не обновляется при наступлении startedAt.
  /// Аналогично iOS-версии: проверяем только по локальному времени.
  bool get isScheduledLocal {
    if (status == IncidentStatus.resolved || status == IncidentStatus.closed) return false;
    if (startedAt == null) return false;
    final parsed = DateTime.tryParse(startedAt!);
    if (parsed == null) return false;
    return parsed.toLocal().isAfter(DateTime.now());
  }

  /// Проверяет, просрочен ли инцидент (finishedAt прошла, но статус не closed/resolved)
  bool get isOverdue {
    if (finishedAt == null) return false;
    if (status == IncidentStatus.resolved || status == IncidentStatus.closed) return false;
    final parsed = DateTime.tryParse(finishedAt!);
    if (parsed == null) return false;
    return parsed.toLocal().isBefore(DateTime.now());
  }

  factory IncidentResponse.fromJson(Map<String, dynamic> json) => _$IncidentResponseFromJson(json);
  Map<String, dynamic> toJson() => _$IncidentResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class PhotoInfo {
  final int id;
  final String url;
  @JsonKey(name: 'thumbnail_url')
  final String? thumbnailUrl;
  @JsonKey(name: 'created_at')
  final String? createdAt;

  PhotoInfo({
    required this.id,
    required this.url,
    this.thumbnailUrl,
    this.createdAt,
  });

  factory PhotoInfo.fromJson(Map<String, dynamic> json) => _$PhotoInfoFromJson(json);
  Map<String, dynamic> toJson() => _$PhotoInfoToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class AffectedHouseCreate {
  final int savedLocationId;
  final double? area;
  final String? status;
  final int? residentsCount;
  final String? notes;

  AffectedHouseCreate({
    required this.savedLocationId,
    this.area,
    this.status,
    this.residentsCount,
    this.notes,
  });

  factory AffectedHouseCreate.fromJson(Map<String, dynamic> json) => _$AffectedHouseCreateFromJson(json);
  Map<String, dynamic> toJson() => _$AffectedHouseCreateToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class IncidentCreate {
  final int boilerHouseId;
  final String title;
  final String? description;
  final IncidentStatus? status;
  final String? severity;
  final int? resourceHotWaterStopped;
  final int? resourceHeatingStopped;
  final int? assignedTo;
  final List<int>? affectedHouseIds;
  final List<AffectedHouseCreate>? affectedHouseDetails;
  @JsonKey(name: 'notification_config')
  final NotificationConfig? notificationConfig;
  final String? createdAt;
  final List<int>? inactiveBoilerNumbers;
  final bool? supplyFullyStopped;
  final String? startedAt;
  final String? finishedAt;
  final bool? autoResolveOnFinish;

  IncidentCreate({
    required this.boilerHouseId,
    required this.title,
    this.description,
    this.status,
    this.severity,
    this.resourceHotWaterStopped,
    this.resourceHeatingStopped,
    this.assignedTo,
    this.affectedHouseIds,
    this.affectedHouseDetails,
    this.notificationConfig,
    this.createdAt,
    this.inactiveBoilerNumbers,
    this.supplyFullyStopped,
    this.startedAt,
    this.finishedAt,
    this.autoResolveOnFinish,
  });

  factory IncidentCreate.fromJson(Map<String, dynamic> json) => _$IncidentCreateFromJson(json);
  Map<String, dynamic> toJson() => _$IncidentCreateToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class IncidentUpdate {
  final int? id;
  final int? boilerHouseId;
  final String? title;
  final String? description;
  final IncidentStatus? status;
  final String? severity;
  final int? resourceHotWaterStopped;
  final int? resourceHeatingStopped;
  final int? assignedTo;
  final List<int>? affectedHouseIds;
  final List<AffectedHouseCreate>? affectedHouseDetails;
  @JsonKey(name: 'notification_config')
  final NotificationConfig? notificationConfig;
  final String? createdAt;
  final String? resolvedAt;
  final List<int>? inactiveBoilerNumbers;
  final bool? supplyFullyStopped;
  final String? startedAt;
  final String? finishedAt;
  final bool? autoResolveOnFinish;

  IncidentUpdate({
    this.id,
    this.boilerHouseId,
    this.title,
    this.description,
    this.status,
    this.severity,
    this.resourceHotWaterStopped,
    this.resourceHeatingStopped,
    this.assignedTo,
    this.affectedHouseIds,
    this.affectedHouseDetails,
    this.notificationConfig,
    this.createdAt,
    this.resolvedAt,
    this.inactiveBoilerNumbers,
    this.supplyFullyStopped,
    this.startedAt,
    this.finishedAt,
    this.autoResolveOnFinish,
  });

  factory IncidentUpdate.fromJson(Map<String, dynamic> json) => _$IncidentUpdateFromJson(json);
  Map<String, dynamic> toJson() => _$IncidentUpdateToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class IncidentCommentAuthor {
  final int id;
  @JsonKey(name: 'full_name')
  final String? fullName;

  @JsonKey(name: 'first_name')
  final String? firstName;
  @JsonKey(name: 'last_name')
  final String? lastName;
  @JsonKey(name: 'middle_name')
  final String? middleName;
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;

  IncidentCommentAuthor({
    required this.id,
    this.fullName,
    this.firstName,
    this.lastName,
    this.middleName,
    this.avatarUrl,
  });

  String get formattedDisplayName {
    final first = firstName?.trim() ?? '';
    final last = lastName?.trim() ?? '';
    final middle = middleName?.trim() ?? '';

    final fioArray = [last, first, middle].where((s) => s.isNotEmpty).toList();
    if (fioArray.isNotEmpty) {
      return fioArray.join(' ');
    }
    return fullName ?? 'ID $id';
  }

  factory IncidentCommentAuthor.fromJson(Map<String, dynamic> json) => _$IncidentCommentAuthorFromJson(json);
  Map<String, dynamic> toJson() => _$IncidentCommentAuthorToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class IncidentComment {
  final int id;
  @JsonKey(name: 'incident_id')
  final int incidentId;
  final String text;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'user_id')
  final int userId;
  final IncidentCommentAuthor? author;
  @JsonKey(name: 'is_system_message', defaultValue: false)
  final bool isSystemMessage;

  IncidentComment({
    required this.id,
    required this.incidentId,
    required this.text,
    required this.createdAt,
    required this.userId,
    this.author,
    this.isSystemMessage = false,
  });

  factory IncidentComment.fromJson(Map<String, dynamic> json) => _$IncidentCommentFromJson(json);
  Map<String, dynamic> toJson() => _$IncidentCommentToJson(this);
}
