// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ActionLogsTable extends ActionLogs
    with TableInfo<$ActionLogsTable, ActionLogDb> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActionLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionIdRawMeta = const VerificationMeta(
    'actionIdRaw',
  );
  @override
  late final GeneratedColumn<int> actionIdRaw = GeneratedColumn<int>(
    'action_id_raw',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _boilerHouseIDMeta = const VerificationMeta(
    'boilerHouseID',
  );
  @override
  late final GeneratedColumn<String> boilerHouseID = GeneratedColumn<String>(
    'boiler_house_i_d',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationIDMeta = const VerificationMeta(
    'locationID',
  );
  @override
  late final GeneratedColumn<String> locationID = GeneratedColumn<String>(
    'location_i_d',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _messageMeta = const VerificationMeta(
    'message',
  );
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
    'message',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _metadataMeta = const VerificationMeta(
    'metadata',
  );
  @override
  late final GeneratedColumn<Uint8List> metadata = GeneratedColumn<Uint8List>(
    'metadata',
    aliasedName,
    true,
    type: DriftSqlType.blob,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scopeMeta = const VerificationMeta('scope');
  @override
  late final GeneratedColumn<String> scope = GeneratedColumn<String>(
    'scope',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _screenMeta = const VerificationMeta('screen');
  @override
  late final GeneratedColumn<String> screen = GeneratedColumn<String>(
    'screen',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userNameMeta = const VerificationMeta(
    'userName',
  );
  @override
  late final GeneratedColumn<String> userName = GeneratedColumn<String>(
    'user_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    actionIdRaw,
    boilerHouseID,
    locationID,
    message,
    metadata,
    scope,
    screen,
    timestamp,
    type,
    userId,
    userName,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'action_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<ActionLogDb> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('action_id_raw')) {
      context.handle(
        _actionIdRawMeta,
        actionIdRaw.isAcceptableOrUnknown(
          data['action_id_raw']!,
          _actionIdRawMeta,
        ),
      );
    }
    if (data.containsKey('boiler_house_i_d')) {
      context.handle(
        _boilerHouseIDMeta,
        boilerHouseID.isAcceptableOrUnknown(
          data['boiler_house_i_d']!,
          _boilerHouseIDMeta,
        ),
      );
    }
    if (data.containsKey('location_i_d')) {
      context.handle(
        _locationIDMeta,
        locationID.isAcceptableOrUnknown(
          data['location_i_d']!,
          _locationIDMeta,
        ),
      );
    }
    if (data.containsKey('message')) {
      context.handle(
        _messageMeta,
        message.isAcceptableOrUnknown(data['message']!, _messageMeta),
      );
    } else if (isInserting) {
      context.missing(_messageMeta);
    }
    if (data.containsKey('metadata')) {
      context.handle(
        _metadataMeta,
        metadata.isAcceptableOrUnknown(data['metadata']!, _metadataMeta),
      );
    }
    if (data.containsKey('scope')) {
      context.handle(
        _scopeMeta,
        scope.isAcceptableOrUnknown(data['scope']!, _scopeMeta),
      );
    }
    if (data.containsKey('screen')) {
      context.handle(
        _screenMeta,
        screen.isAcceptableOrUnknown(data['screen']!, _screenMeta),
      );
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('user_name')) {
      context.handle(
        _userNameMeta,
        userName.isAcceptableOrUnknown(data['user_name']!, _userNameMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ActionLogDb map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActionLogDb(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      actionIdRaw: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}action_id_raw'],
      ),
      boilerHouseID: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}boiler_house_i_d'],
      ),
      locationID: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location_i_d'],
      ),
      message: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message'],
      )!,
      metadata: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}metadata'],
      ),
      scope: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope'],
      ),
      screen: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}screen'],
      ),
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
      userName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_name'],
      ),
    );
  }

  @override
  $ActionLogsTable createAlias(String alias) {
    return $ActionLogsTable(attachedDatabase, alias);
  }
}

class ActionLogDb extends DataClass implements Insertable<ActionLogDb> {
  final String id;
  final int? actionIdRaw;
  final String? boilerHouseID;
  final String? locationID;
  final String message;
  final Uint8List? metadata;
  final String? scope;
  final String? screen;
  final DateTime timestamp;
  final String type;
  final String? userId;
  final String? userName;
  const ActionLogDb({
    required this.id,
    this.actionIdRaw,
    this.boilerHouseID,
    this.locationID,
    required this.message,
    this.metadata,
    this.scope,
    this.screen,
    required this.timestamp,
    required this.type,
    this.userId,
    this.userName,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || actionIdRaw != null) {
      map['action_id_raw'] = Variable<int>(actionIdRaw);
    }
    if (!nullToAbsent || boilerHouseID != null) {
      map['boiler_house_i_d'] = Variable<String>(boilerHouseID);
    }
    if (!nullToAbsent || locationID != null) {
      map['location_i_d'] = Variable<String>(locationID);
    }
    map['message'] = Variable<String>(message);
    if (!nullToAbsent || metadata != null) {
      map['metadata'] = Variable<Uint8List>(metadata);
    }
    if (!nullToAbsent || scope != null) {
      map['scope'] = Variable<String>(scope);
    }
    if (!nullToAbsent || screen != null) {
      map['screen'] = Variable<String>(screen);
    }
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    if (!nullToAbsent || userName != null) {
      map['user_name'] = Variable<String>(userName);
    }
    return map;
  }

  ActionLogsCompanion toCompanion(bool nullToAbsent) {
    return ActionLogsCompanion(
      id: Value(id),
      actionIdRaw: actionIdRaw == null && nullToAbsent
          ? const Value.absent()
          : Value(actionIdRaw),
      boilerHouseID: boilerHouseID == null && nullToAbsent
          ? const Value.absent()
          : Value(boilerHouseID),
      locationID: locationID == null && nullToAbsent
          ? const Value.absent()
          : Value(locationID),
      message: Value(message),
      metadata: metadata == null && nullToAbsent
          ? const Value.absent()
          : Value(metadata),
      scope: scope == null && nullToAbsent
          ? const Value.absent()
          : Value(scope),
      screen: screen == null && nullToAbsent
          ? const Value.absent()
          : Value(screen),
      timestamp: Value(timestamp),
      type: Value(type),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      userName: userName == null && nullToAbsent
          ? const Value.absent()
          : Value(userName),
    );
  }

  factory ActionLogDb.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActionLogDb(
      id: serializer.fromJson<String>(json['id']),
      actionIdRaw: serializer.fromJson<int?>(json['actionIdRaw']),
      boilerHouseID: serializer.fromJson<String?>(json['boilerHouseID']),
      locationID: serializer.fromJson<String?>(json['locationID']),
      message: serializer.fromJson<String>(json['message']),
      metadata: serializer.fromJson<Uint8List?>(json['metadata']),
      scope: serializer.fromJson<String?>(json['scope']),
      screen: serializer.fromJson<String?>(json['screen']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      type: serializer.fromJson<String>(json['type']),
      userId: serializer.fromJson<String?>(json['userId']),
      userName: serializer.fromJson<String?>(json['userName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'actionIdRaw': serializer.toJson<int?>(actionIdRaw),
      'boilerHouseID': serializer.toJson<String?>(boilerHouseID),
      'locationID': serializer.toJson<String?>(locationID),
      'message': serializer.toJson<String>(message),
      'metadata': serializer.toJson<Uint8List?>(metadata),
      'scope': serializer.toJson<String?>(scope),
      'screen': serializer.toJson<String?>(screen),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'type': serializer.toJson<String>(type),
      'userId': serializer.toJson<String?>(userId),
      'userName': serializer.toJson<String?>(userName),
    };
  }

  ActionLogDb copyWith({
    String? id,
    Value<int?> actionIdRaw = const Value.absent(),
    Value<String?> boilerHouseID = const Value.absent(),
    Value<String?> locationID = const Value.absent(),
    String? message,
    Value<Uint8List?> metadata = const Value.absent(),
    Value<String?> scope = const Value.absent(),
    Value<String?> screen = const Value.absent(),
    DateTime? timestamp,
    String? type,
    Value<String?> userId = const Value.absent(),
    Value<String?> userName = const Value.absent(),
  }) => ActionLogDb(
    id: id ?? this.id,
    actionIdRaw: actionIdRaw.present ? actionIdRaw.value : this.actionIdRaw,
    boilerHouseID: boilerHouseID.present
        ? boilerHouseID.value
        : this.boilerHouseID,
    locationID: locationID.present ? locationID.value : this.locationID,
    message: message ?? this.message,
    metadata: metadata.present ? metadata.value : this.metadata,
    scope: scope.present ? scope.value : this.scope,
    screen: screen.present ? screen.value : this.screen,
    timestamp: timestamp ?? this.timestamp,
    type: type ?? this.type,
    userId: userId.present ? userId.value : this.userId,
    userName: userName.present ? userName.value : this.userName,
  );
  ActionLogDb copyWithCompanion(ActionLogsCompanion data) {
    return ActionLogDb(
      id: data.id.present ? data.id.value : this.id,
      actionIdRaw: data.actionIdRaw.present
          ? data.actionIdRaw.value
          : this.actionIdRaw,
      boilerHouseID: data.boilerHouseID.present
          ? data.boilerHouseID.value
          : this.boilerHouseID,
      locationID: data.locationID.present
          ? data.locationID.value
          : this.locationID,
      message: data.message.present ? data.message.value : this.message,
      metadata: data.metadata.present ? data.metadata.value : this.metadata,
      scope: data.scope.present ? data.scope.value : this.scope,
      screen: data.screen.present ? data.screen.value : this.screen,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      type: data.type.present ? data.type.value : this.type,
      userId: data.userId.present ? data.userId.value : this.userId,
      userName: data.userName.present ? data.userName.value : this.userName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActionLogDb(')
          ..write('id: $id, ')
          ..write('actionIdRaw: $actionIdRaw, ')
          ..write('boilerHouseID: $boilerHouseID, ')
          ..write('locationID: $locationID, ')
          ..write('message: $message, ')
          ..write('metadata: $metadata, ')
          ..write('scope: $scope, ')
          ..write('screen: $screen, ')
          ..write('timestamp: $timestamp, ')
          ..write('type: $type, ')
          ..write('userId: $userId, ')
          ..write('userName: $userName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    actionIdRaw,
    boilerHouseID,
    locationID,
    message,
    $driftBlobEquality.hash(metadata),
    scope,
    screen,
    timestamp,
    type,
    userId,
    userName,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActionLogDb &&
          other.id == this.id &&
          other.actionIdRaw == this.actionIdRaw &&
          other.boilerHouseID == this.boilerHouseID &&
          other.locationID == this.locationID &&
          other.message == this.message &&
          $driftBlobEquality.equals(other.metadata, this.metadata) &&
          other.scope == this.scope &&
          other.screen == this.screen &&
          other.timestamp == this.timestamp &&
          other.type == this.type &&
          other.userId == this.userId &&
          other.userName == this.userName);
}

class ActionLogsCompanion extends UpdateCompanion<ActionLogDb> {
  final Value<String> id;
  final Value<int?> actionIdRaw;
  final Value<String?> boilerHouseID;
  final Value<String?> locationID;
  final Value<String> message;
  final Value<Uint8List?> metadata;
  final Value<String?> scope;
  final Value<String?> screen;
  final Value<DateTime> timestamp;
  final Value<String> type;
  final Value<String?> userId;
  final Value<String?> userName;
  final Value<int> rowid;
  const ActionLogsCompanion({
    this.id = const Value.absent(),
    this.actionIdRaw = const Value.absent(),
    this.boilerHouseID = const Value.absent(),
    this.locationID = const Value.absent(),
    this.message = const Value.absent(),
    this.metadata = const Value.absent(),
    this.scope = const Value.absent(),
    this.screen = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.type = const Value.absent(),
    this.userId = const Value.absent(),
    this.userName = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActionLogsCompanion.insert({
    required String id,
    this.actionIdRaw = const Value.absent(),
    this.boilerHouseID = const Value.absent(),
    this.locationID = const Value.absent(),
    required String message,
    this.metadata = const Value.absent(),
    this.scope = const Value.absent(),
    this.screen = const Value.absent(),
    required DateTime timestamp,
    required String type,
    this.userId = const Value.absent(),
    this.userName = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       message = Value(message),
       timestamp = Value(timestamp),
       type = Value(type);
  static Insertable<ActionLogDb> custom({
    Expression<String>? id,
    Expression<int>? actionIdRaw,
    Expression<String>? boilerHouseID,
    Expression<String>? locationID,
    Expression<String>? message,
    Expression<Uint8List>? metadata,
    Expression<String>? scope,
    Expression<String>? screen,
    Expression<DateTime>? timestamp,
    Expression<String>? type,
    Expression<String>? userId,
    Expression<String>? userName,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (actionIdRaw != null) 'action_id_raw': actionIdRaw,
      if (boilerHouseID != null) 'boiler_house_i_d': boilerHouseID,
      if (locationID != null) 'location_i_d': locationID,
      if (message != null) 'message': message,
      if (metadata != null) 'metadata': metadata,
      if (scope != null) 'scope': scope,
      if (screen != null) 'screen': screen,
      if (timestamp != null) 'timestamp': timestamp,
      if (type != null) 'type': type,
      if (userId != null) 'user_id': userId,
      if (userName != null) 'user_name': userName,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActionLogsCompanion copyWith({
    Value<String>? id,
    Value<int?>? actionIdRaw,
    Value<String?>? boilerHouseID,
    Value<String?>? locationID,
    Value<String>? message,
    Value<Uint8List?>? metadata,
    Value<String?>? scope,
    Value<String?>? screen,
    Value<DateTime>? timestamp,
    Value<String>? type,
    Value<String?>? userId,
    Value<String?>? userName,
    Value<int>? rowid,
  }) {
    return ActionLogsCompanion(
      id: id ?? this.id,
      actionIdRaw: actionIdRaw ?? this.actionIdRaw,
      boilerHouseID: boilerHouseID ?? this.boilerHouseID,
      locationID: locationID ?? this.locationID,
      message: message ?? this.message,
      metadata: metadata ?? this.metadata,
      scope: scope ?? this.scope,
      screen: screen ?? this.screen,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (actionIdRaw.present) {
      map['action_id_raw'] = Variable<int>(actionIdRaw.value);
    }
    if (boilerHouseID.present) {
      map['boiler_house_i_d'] = Variable<String>(boilerHouseID.value);
    }
    if (locationID.present) {
      map['location_i_d'] = Variable<String>(locationID.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (metadata.present) {
      map['metadata'] = Variable<Uint8List>(metadata.value);
    }
    if (scope.present) {
      map['scope'] = Variable<String>(scope.value);
    }
    if (screen.present) {
      map['screen'] = Variable<String>(screen.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (userName.present) {
      map['user_name'] = Variable<String>(userName.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActionLogsCompanion(')
          ..write('id: $id, ')
          ..write('actionIdRaw: $actionIdRaw, ')
          ..write('boilerHouseID: $boilerHouseID, ')
          ..write('locationID: $locationID, ')
          ..write('message: $message, ')
          ..write('metadata: $metadata, ')
          ..write('scope: $scope, ')
          ..write('screen: $screen, ')
          ..write('timestamp: $timestamp, ')
          ..write('type: $type, ')
          ..write('userId: $userId, ')
          ..write('userName: $userName, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppUsersTable extends AppUsers
    with TableInfo<$AppUsersTable, AppUserDb> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppUsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _activeStatusMeta = const VerificationMeta(
    'activeStatus',
  );
  @override
  late final GeneratedColumn<String> activeStatus = GeneratedColumn<String>(
    'active_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _blockedAtMeta = const VerificationMeta(
    'blockedAt',
  );
  @override
  late final GeneratedColumn<DateTime> blockedAt = GeneratedColumn<DateTime>(
    'blocked_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _blockedByMeta = const VerificationMeta(
    'blockedBy',
  );
  @override
  late final GeneratedColumn<String> blockedBy = GeneratedColumn<String>(
    'blocked_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _blockedReasonMeta = const VerificationMeta(
    'blockedReason',
  );
  @override
  late final GeneratedColumn<String> blockedReason = GeneratedColumn<String>(
    'blocked_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customPermissionsMeta = const VerificationMeta(
    'customPermissions',
  );
  @override
  late final GeneratedColumn<String> customPermissions =
      GeneratedColumn<String>(
        'custom_permissions',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _deactivatedAtMeta = const VerificationMeta(
    'deactivatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deactivatedAt =
      GeneratedColumn<DateTime>(
        'deactivated_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedByMeta = const VerificationMeta(
    'deletedBy',
  );
  @override
  late final GeneratedColumn<String> deletedBy = GeneratedColumn<String>(
    'deleted_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailVerifiedMeta = const VerificationMeta(
    'emailVerified',
  );
  @override
  late final GeneratedColumn<bool> emailVerified = GeneratedColumn<bool>(
    'email_verified',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("email_verified" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _fullNameMeta = const VerificationMeta(
    'fullName',
  );
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
    'full_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _inviteSentAtMeta = const VerificationMeta(
    'inviteSentAt',
  );
  @override
  late final GeneratedColumn<DateTime> inviteSentAt = GeneratedColumn<DateTime>(
    'invite_sent_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _inviteTokenMeta = const VerificationMeta(
    'inviteToken',
  );
  @override
  late final GeneratedColumn<String> inviteToken = GeneratedColumn<String>(
    'invite_token',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _isAdminMeta = const VerificationMeta(
    'isAdmin',
  );
  @override
  late final GeneratedColumn<bool> isAdmin = GeneratedColumn<bool>(
    'is_admin',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_admin" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isBlockedMeta = const VerificationMeta(
    'isBlocked',
  );
  @override
  late final GeneratedColumn<bool> isBlocked = GeneratedColumn<bool>(
    'is_blocked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_blocked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isInvitePendingMeta = const VerificationMeta(
    'isInvitePending',
  );
  @override
  late final GeneratedColumn<bool> isInvitePending = GeneratedColumn<bool>(
    'is_invite_pending',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_invite_pending" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isOnlineMeta = const VerificationMeta(
    'isOnline',
  );
  @override
  late final GeneratedColumn<bool> isOnline = GeneratedColumn<bool>(
    'is_online',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_online" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isSoftDeletedMeta = const VerificationMeta(
    'isSoftDeleted',
  );
  @override
  late final GeneratedColumn<bool> isSoftDeleted = GeneratedColumn<bool>(
    'is_soft_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_soft_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isSystemMeta = const VerificationMeta(
    'isSystem',
  );
  @override
  late final GeneratedColumn<bool> isSystem = GeneratedColumn<bool>(
    'is_system',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_system" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lastActiveAtMeta = const VerificationMeta(
    'lastActiveAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastActiveAt = GeneratedColumn<DateTime>(
    'last_active_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastLoginAtMeta = const VerificationMeta(
    'lastLoginAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastLoginAt = GeneratedColumn<DateTime>(
    'last_login_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastPasswordResetAtMeta =
      const VerificationMeta('lastPasswordResetAt');
  @override
  late final GeneratedColumn<DateTime> lastPasswordResetAt =
      GeneratedColumn<DateTime>(
        'last_password_reset_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _metadataMeta = const VerificationMeta(
    'metadata',
  );
  @override
  late final GeneratedColumn<Uint8List> metadata = GeneratedColumn<Uint8List>(
    'metadata',
    aliasedName,
    true,
    type: DriftSqlType.blob,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _needsPasswordResetMeta =
      const VerificationMeta('needsPasswordReset');
  @override
  late final GeneratedColumn<bool> needsPasswordReset = GeneratedColumn<bool>(
    'needs_password_reset',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("needs_password_reset" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _passwordHashMeta = const VerificationMeta(
    'passwordHash',
  );
  @override
  late final GeneratedColumn<String> passwordHash = GeneratedColumn<String>(
    'password_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _passwordSaltMeta = const VerificationMeta(
    'passwordSalt',
  );
  @override
  late final GeneratedColumn<String> passwordSalt = GeneratedColumn<String>(
    'password_salt',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _passwordUpdatedAtMeta = const VerificationMeta(
    'passwordUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> passwordUpdatedAt =
      GeneratedColumn<DateTime>(
        'password_updated_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneVerifiedMeta = const VerificationMeta(
    'phoneVerified',
  );
  @override
  late final GeneratedColumn<bool> phoneVerified = GeneratedColumn<bool>(
    'phone_verified',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("phone_verified" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roleIdMeta = const VerificationMeta('roleId');
  @override
  late final GeneratedColumn<String> roleId = GeneratedColumn<String>(
    'role_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roleSnapshotMeta = const VerificationMeta(
    'roleSnapshot',
  );
  @override
  late final GeneratedColumn<String> roleSnapshot = GeneratedColumn<String>(
    'role_snapshot',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusChangedAtMeta = const VerificationMeta(
    'statusChangedAt',
  );
  @override
  late final GeneratedColumn<DateTime> statusChangedAt =
      GeneratedColumn<DateTime>(
        'status_changed_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _statusReasonMeta = const VerificationMeta(
    'statusReason',
  );
  @override
  late final GeneratedColumn<String> statusReason = GeneratedColumn<String>(
    'status_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedByMeta = const VerificationMeta(
    'updatedBy',
  );
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
    'updated_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userEmailMeta = const VerificationMeta(
    'userEmail',
  );
  @override
  late final GeneratedColumn<String> userEmail = GeneratedColumn<String>(
    'user_email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _verificationCodeMeta = const VerificationMeta(
    'verificationCode',
  );
  @override
  late final GeneratedColumn<String> verificationCode = GeneratedColumn<String>(
    'verification_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    activeStatus,
    blockedAt,
    blockedBy,
    blockedReason,
    createdAt,
    createdBy,
    customPermissions,
    deactivatedAt,
    deletedAt,
    deletedBy,
    displayName,
    emailVerified,
    fullName,
    inviteSentAt,
    inviteToken,
    isActive,
    isAdmin,
    isBlocked,
    isInvitePending,
    isOnline,
    isSoftDeleted,
    isSystem,
    lastActiveAt,
    lastLoginAt,
    lastPasswordResetAt,
    metadata,
    needsPasswordReset,
    notes,
    passwordHash,
    passwordSalt,
    passwordUpdatedAt,
    phone,
    phoneVerified,
    role,
    roleId,
    roleSnapshot,
    statusChangedAt,
    statusReason,
    updatedAt,
    updatedBy,
    userEmail,
    userId,
    username,
    verificationCode,
    id,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_users';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppUserDb> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('active_status')) {
      context.handle(
        _activeStatusMeta,
        activeStatus.isAcceptableOrUnknown(
          data['active_status']!,
          _activeStatusMeta,
        ),
      );
    }
    if (data.containsKey('blocked_at')) {
      context.handle(
        _blockedAtMeta,
        blockedAt.isAcceptableOrUnknown(data['blocked_at']!, _blockedAtMeta),
      );
    }
    if (data.containsKey('blocked_by')) {
      context.handle(
        _blockedByMeta,
        blockedBy.isAcceptableOrUnknown(data['blocked_by']!, _blockedByMeta),
      );
    }
    if (data.containsKey('blocked_reason')) {
      context.handle(
        _blockedReasonMeta,
        blockedReason.isAcceptableOrUnknown(
          data['blocked_reason']!,
          _blockedReasonMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('custom_permissions')) {
      context.handle(
        _customPermissionsMeta,
        customPermissions.isAcceptableOrUnknown(
          data['custom_permissions']!,
          _customPermissionsMeta,
        ),
      );
    }
    if (data.containsKey('deactivated_at')) {
      context.handle(
        _deactivatedAtMeta,
        deactivatedAt.isAcceptableOrUnknown(
          data['deactivated_at']!,
          _deactivatedAtMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('deleted_by')) {
      context.handle(
        _deletedByMeta,
        deletedBy.isAcceptableOrUnknown(data['deleted_by']!, _deletedByMeta),
      );
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    }
    if (data.containsKey('email_verified')) {
      context.handle(
        _emailVerifiedMeta,
        emailVerified.isAcceptableOrUnknown(
          data['email_verified']!,
          _emailVerifiedMeta,
        ),
      );
    }
    if (data.containsKey('full_name')) {
      context.handle(
        _fullNameMeta,
        fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta),
      );
    }
    if (data.containsKey('invite_sent_at')) {
      context.handle(
        _inviteSentAtMeta,
        inviteSentAt.isAcceptableOrUnknown(
          data['invite_sent_at']!,
          _inviteSentAtMeta,
        ),
      );
    }
    if (data.containsKey('invite_token')) {
      context.handle(
        _inviteTokenMeta,
        inviteToken.isAcceptableOrUnknown(
          data['invite_token']!,
          _inviteTokenMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('is_admin')) {
      context.handle(
        _isAdminMeta,
        isAdmin.isAcceptableOrUnknown(data['is_admin']!, _isAdminMeta),
      );
    }
    if (data.containsKey('is_blocked')) {
      context.handle(
        _isBlockedMeta,
        isBlocked.isAcceptableOrUnknown(data['is_blocked']!, _isBlockedMeta),
      );
    }
    if (data.containsKey('is_invite_pending')) {
      context.handle(
        _isInvitePendingMeta,
        isInvitePending.isAcceptableOrUnknown(
          data['is_invite_pending']!,
          _isInvitePendingMeta,
        ),
      );
    }
    if (data.containsKey('is_online')) {
      context.handle(
        _isOnlineMeta,
        isOnline.isAcceptableOrUnknown(data['is_online']!, _isOnlineMeta),
      );
    }
    if (data.containsKey('is_soft_deleted')) {
      context.handle(
        _isSoftDeletedMeta,
        isSoftDeleted.isAcceptableOrUnknown(
          data['is_soft_deleted']!,
          _isSoftDeletedMeta,
        ),
      );
    }
    if (data.containsKey('is_system')) {
      context.handle(
        _isSystemMeta,
        isSystem.isAcceptableOrUnknown(data['is_system']!, _isSystemMeta),
      );
    }
    if (data.containsKey('last_active_at')) {
      context.handle(
        _lastActiveAtMeta,
        lastActiveAt.isAcceptableOrUnknown(
          data['last_active_at']!,
          _lastActiveAtMeta,
        ),
      );
    }
    if (data.containsKey('last_login_at')) {
      context.handle(
        _lastLoginAtMeta,
        lastLoginAt.isAcceptableOrUnknown(
          data['last_login_at']!,
          _lastLoginAtMeta,
        ),
      );
    }
    if (data.containsKey('last_password_reset_at')) {
      context.handle(
        _lastPasswordResetAtMeta,
        lastPasswordResetAt.isAcceptableOrUnknown(
          data['last_password_reset_at']!,
          _lastPasswordResetAtMeta,
        ),
      );
    }
    if (data.containsKey('metadata')) {
      context.handle(
        _metadataMeta,
        metadata.isAcceptableOrUnknown(data['metadata']!, _metadataMeta),
      );
    }
    if (data.containsKey('needs_password_reset')) {
      context.handle(
        _needsPasswordResetMeta,
        needsPasswordReset.isAcceptableOrUnknown(
          data['needs_password_reset']!,
          _needsPasswordResetMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('password_hash')) {
      context.handle(
        _passwordHashMeta,
        passwordHash.isAcceptableOrUnknown(
          data['password_hash']!,
          _passwordHashMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_passwordHashMeta);
    }
    if (data.containsKey('password_salt')) {
      context.handle(
        _passwordSaltMeta,
        passwordSalt.isAcceptableOrUnknown(
          data['password_salt']!,
          _passwordSaltMeta,
        ),
      );
    }
    if (data.containsKey('password_updated_at')) {
      context.handle(
        _passwordUpdatedAtMeta,
        passwordUpdatedAt.isAcceptableOrUnknown(
          data['password_updated_at']!,
          _passwordUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('phone_verified')) {
      context.handle(
        _phoneVerifiedMeta,
        phoneVerified.isAcceptableOrUnknown(
          data['phone_verified']!,
          _phoneVerifiedMeta,
        ),
      );
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    }
    if (data.containsKey('role_id')) {
      context.handle(
        _roleIdMeta,
        roleId.isAcceptableOrUnknown(data['role_id']!, _roleIdMeta),
      );
    }
    if (data.containsKey('role_snapshot')) {
      context.handle(
        _roleSnapshotMeta,
        roleSnapshot.isAcceptableOrUnknown(
          data['role_snapshot']!,
          _roleSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('status_changed_at')) {
      context.handle(
        _statusChangedAtMeta,
        statusChangedAt.isAcceptableOrUnknown(
          data['status_changed_at']!,
          _statusChangedAtMeta,
        ),
      );
    }
    if (data.containsKey('status_reason')) {
      context.handle(
        _statusReasonMeta,
        statusReason.isAcceptableOrUnknown(
          data['status_reason']!,
          _statusReasonMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('updated_by')) {
      context.handle(
        _updatedByMeta,
        updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta),
      );
    }
    if (data.containsKey('user_email')) {
      context.handle(
        _userEmailMeta,
        userEmail.isAcceptableOrUnknown(data['user_email']!, _userEmailMeta),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    }
    if (data.containsKey('verification_code')) {
      context.handle(
        _verificationCodeMeta,
        verificationCode.isAcceptableOrUnknown(
          data['verification_code']!,
          _verificationCodeMeta,
        ),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppUserDb map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppUserDb(
      activeStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}active_status'],
      ),
      blockedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}blocked_at'],
      ),
      blockedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}blocked_by'],
      ),
      blockedReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}blocked_reason'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      ),
      customPermissions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_permissions'],
      ),
      deactivatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deactivated_at'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      deletedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_by'],
      ),
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      ),
      emailVerified: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}email_verified'],
      )!,
      fullName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_name'],
      ),
      inviteSentAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}invite_sent_at'],
      ),
      inviteToken: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invite_token'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      isAdmin: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_admin'],
      )!,
      isBlocked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_blocked'],
      )!,
      isInvitePending: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_invite_pending'],
      )!,
      isOnline: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_online'],
      )!,
      isSoftDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_soft_deleted'],
      )!,
      isSystem: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_system'],
      )!,
      lastActiveAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_active_at'],
      ),
      lastLoginAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_login_at'],
      ),
      lastPasswordResetAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_password_reset_at'],
      ),
      metadata: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}metadata'],
      ),
      needsPasswordReset: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}needs_password_reset'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      passwordHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}password_hash'],
      )!,
      passwordSalt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}password_salt'],
      ),
      passwordUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}password_updated_at'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      phoneVerified: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}phone_verified'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      ),
      roleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role_id'],
      ),
      roleSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role_snapshot'],
      ),
      statusChangedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}status_changed_at'],
      ),
      statusReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status_reason'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      updatedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by'],
      ),
      userEmail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_email'],
      ),
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      ),
      verificationCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}verification_code'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
    );
  }

  @override
  $AppUsersTable createAlias(String alias) {
    return $AppUsersTable(attachedDatabase, alias);
  }
}

class AppUserDb extends DataClass implements Insertable<AppUserDb> {
  final String? activeStatus;
  final DateTime? blockedAt;
  final String? blockedBy;
  final String? blockedReason;
  final DateTime? createdAt;
  final String? createdBy;
  final String? customPermissions;
  final DateTime? deactivatedAt;
  final DateTime? deletedAt;
  final String? deletedBy;
  final String? displayName;
  final bool emailVerified;
  final String? fullName;
  final DateTime? inviteSentAt;
  final String? inviteToken;
  final bool isActive;
  final bool isAdmin;
  final bool isBlocked;
  final bool isInvitePending;
  final bool isOnline;
  final bool isSoftDeleted;
  final bool isSystem;
  final DateTime? lastActiveAt;
  final DateTime? lastLoginAt;
  final DateTime? lastPasswordResetAt;
  final Uint8List? metadata;
  final bool needsPasswordReset;
  final String? notes;
  final String passwordHash;
  final String? passwordSalt;
  final DateTime? passwordUpdatedAt;
  final String? phone;
  final bool phoneVerified;
  final String? role;
  final String? roleId;
  final String? roleSnapshot;
  final DateTime? statusChangedAt;
  final String? statusReason;
  final DateTime? updatedAt;
  final String? updatedBy;
  final String? userEmail;
  final String? userId;
  final String? username;
  final String? verificationCode;
  final int id;
  const AppUserDb({
    this.activeStatus,
    this.blockedAt,
    this.blockedBy,
    this.blockedReason,
    this.createdAt,
    this.createdBy,
    this.customPermissions,
    this.deactivatedAt,
    this.deletedAt,
    this.deletedBy,
    this.displayName,
    required this.emailVerified,
    this.fullName,
    this.inviteSentAt,
    this.inviteToken,
    required this.isActive,
    required this.isAdmin,
    required this.isBlocked,
    required this.isInvitePending,
    required this.isOnline,
    required this.isSoftDeleted,
    required this.isSystem,
    this.lastActiveAt,
    this.lastLoginAt,
    this.lastPasswordResetAt,
    this.metadata,
    required this.needsPasswordReset,
    this.notes,
    required this.passwordHash,
    this.passwordSalt,
    this.passwordUpdatedAt,
    this.phone,
    required this.phoneVerified,
    this.role,
    this.roleId,
    this.roleSnapshot,
    this.statusChangedAt,
    this.statusReason,
    this.updatedAt,
    this.updatedBy,
    this.userEmail,
    this.userId,
    this.username,
    this.verificationCode,
    required this.id,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || activeStatus != null) {
      map['active_status'] = Variable<String>(activeStatus);
    }
    if (!nullToAbsent || blockedAt != null) {
      map['blocked_at'] = Variable<DateTime>(blockedAt);
    }
    if (!nullToAbsent || blockedBy != null) {
      map['blocked_by'] = Variable<String>(blockedBy);
    }
    if (!nullToAbsent || blockedReason != null) {
      map['blocked_reason'] = Variable<String>(blockedReason);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    if (!nullToAbsent || customPermissions != null) {
      map['custom_permissions'] = Variable<String>(customPermissions);
    }
    if (!nullToAbsent || deactivatedAt != null) {
      map['deactivated_at'] = Variable<DateTime>(deactivatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || deletedBy != null) {
      map['deleted_by'] = Variable<String>(deletedBy);
    }
    if (!nullToAbsent || displayName != null) {
      map['display_name'] = Variable<String>(displayName);
    }
    map['email_verified'] = Variable<bool>(emailVerified);
    if (!nullToAbsent || fullName != null) {
      map['full_name'] = Variable<String>(fullName);
    }
    if (!nullToAbsent || inviteSentAt != null) {
      map['invite_sent_at'] = Variable<DateTime>(inviteSentAt);
    }
    if (!nullToAbsent || inviteToken != null) {
      map['invite_token'] = Variable<String>(inviteToken);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['is_admin'] = Variable<bool>(isAdmin);
    map['is_blocked'] = Variable<bool>(isBlocked);
    map['is_invite_pending'] = Variable<bool>(isInvitePending);
    map['is_online'] = Variable<bool>(isOnline);
    map['is_soft_deleted'] = Variable<bool>(isSoftDeleted);
    map['is_system'] = Variable<bool>(isSystem);
    if (!nullToAbsent || lastActiveAt != null) {
      map['last_active_at'] = Variable<DateTime>(lastActiveAt);
    }
    if (!nullToAbsent || lastLoginAt != null) {
      map['last_login_at'] = Variable<DateTime>(lastLoginAt);
    }
    if (!nullToAbsent || lastPasswordResetAt != null) {
      map['last_password_reset_at'] = Variable<DateTime>(lastPasswordResetAt);
    }
    if (!nullToAbsent || metadata != null) {
      map['metadata'] = Variable<Uint8List>(metadata);
    }
    map['needs_password_reset'] = Variable<bool>(needsPasswordReset);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['password_hash'] = Variable<String>(passwordHash);
    if (!nullToAbsent || passwordSalt != null) {
      map['password_salt'] = Variable<String>(passwordSalt);
    }
    if (!nullToAbsent || passwordUpdatedAt != null) {
      map['password_updated_at'] = Variable<DateTime>(passwordUpdatedAt);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    map['phone_verified'] = Variable<bool>(phoneVerified);
    if (!nullToAbsent || role != null) {
      map['role'] = Variable<String>(role);
    }
    if (!nullToAbsent || roleId != null) {
      map['role_id'] = Variable<String>(roleId);
    }
    if (!nullToAbsent || roleSnapshot != null) {
      map['role_snapshot'] = Variable<String>(roleSnapshot);
    }
    if (!nullToAbsent || statusChangedAt != null) {
      map['status_changed_at'] = Variable<DateTime>(statusChangedAt);
    }
    if (!nullToAbsent || statusReason != null) {
      map['status_reason'] = Variable<String>(statusReason);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || updatedBy != null) {
      map['updated_by'] = Variable<String>(updatedBy);
    }
    if (!nullToAbsent || userEmail != null) {
      map['user_email'] = Variable<String>(userEmail);
    }
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    if (!nullToAbsent || username != null) {
      map['username'] = Variable<String>(username);
    }
    if (!nullToAbsent || verificationCode != null) {
      map['verification_code'] = Variable<String>(verificationCode);
    }
    map['id'] = Variable<int>(id);
    return map;
  }

  AppUsersCompanion toCompanion(bool nullToAbsent) {
    return AppUsersCompanion(
      activeStatus: activeStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(activeStatus),
      blockedAt: blockedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(blockedAt),
      blockedBy: blockedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(blockedBy),
      blockedReason: blockedReason == null && nullToAbsent
          ? const Value.absent()
          : Value(blockedReason),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      customPermissions: customPermissions == null && nullToAbsent
          ? const Value.absent()
          : Value(customPermissions),
      deactivatedAt: deactivatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deactivatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deletedBy: deletedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedBy),
      displayName: displayName == null && nullToAbsent
          ? const Value.absent()
          : Value(displayName),
      emailVerified: Value(emailVerified),
      fullName: fullName == null && nullToAbsent
          ? const Value.absent()
          : Value(fullName),
      inviteSentAt: inviteSentAt == null && nullToAbsent
          ? const Value.absent()
          : Value(inviteSentAt),
      inviteToken: inviteToken == null && nullToAbsent
          ? const Value.absent()
          : Value(inviteToken),
      isActive: Value(isActive),
      isAdmin: Value(isAdmin),
      isBlocked: Value(isBlocked),
      isInvitePending: Value(isInvitePending),
      isOnline: Value(isOnline),
      isSoftDeleted: Value(isSoftDeleted),
      isSystem: Value(isSystem),
      lastActiveAt: lastActiveAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastActiveAt),
      lastLoginAt: lastLoginAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastLoginAt),
      lastPasswordResetAt: lastPasswordResetAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPasswordResetAt),
      metadata: metadata == null && nullToAbsent
          ? const Value.absent()
          : Value(metadata),
      needsPasswordReset: Value(needsPasswordReset),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      passwordHash: Value(passwordHash),
      passwordSalt: passwordSalt == null && nullToAbsent
          ? const Value.absent()
          : Value(passwordSalt),
      passwordUpdatedAt: passwordUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(passwordUpdatedAt),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      phoneVerified: Value(phoneVerified),
      role: role == null && nullToAbsent ? const Value.absent() : Value(role),
      roleId: roleId == null && nullToAbsent
          ? const Value.absent()
          : Value(roleId),
      roleSnapshot: roleSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(roleSnapshot),
      statusChangedAt: statusChangedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(statusChangedAt),
      statusReason: statusReason == null && nullToAbsent
          ? const Value.absent()
          : Value(statusReason),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      updatedBy: updatedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedBy),
      userEmail: userEmail == null && nullToAbsent
          ? const Value.absent()
          : Value(userEmail),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      username: username == null && nullToAbsent
          ? const Value.absent()
          : Value(username),
      verificationCode: verificationCode == null && nullToAbsent
          ? const Value.absent()
          : Value(verificationCode),
      id: Value(id),
    );
  }

  factory AppUserDb.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppUserDb(
      activeStatus: serializer.fromJson<String?>(json['activeStatus']),
      blockedAt: serializer.fromJson<DateTime?>(json['blockedAt']),
      blockedBy: serializer.fromJson<String?>(json['blockedBy']),
      blockedReason: serializer.fromJson<String?>(json['blockedReason']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      customPermissions: serializer.fromJson<String?>(
        json['customPermissions'],
      ),
      deactivatedAt: serializer.fromJson<DateTime?>(json['deactivatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      deletedBy: serializer.fromJson<String?>(json['deletedBy']),
      displayName: serializer.fromJson<String?>(json['displayName']),
      emailVerified: serializer.fromJson<bool>(json['emailVerified']),
      fullName: serializer.fromJson<String?>(json['fullName']),
      inviteSentAt: serializer.fromJson<DateTime?>(json['inviteSentAt']),
      inviteToken: serializer.fromJson<String?>(json['inviteToken']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      isAdmin: serializer.fromJson<bool>(json['isAdmin']),
      isBlocked: serializer.fromJson<bool>(json['isBlocked']),
      isInvitePending: serializer.fromJson<bool>(json['isInvitePending']),
      isOnline: serializer.fromJson<bool>(json['isOnline']),
      isSoftDeleted: serializer.fromJson<bool>(json['isSoftDeleted']),
      isSystem: serializer.fromJson<bool>(json['isSystem']),
      lastActiveAt: serializer.fromJson<DateTime?>(json['lastActiveAt']),
      lastLoginAt: serializer.fromJson<DateTime?>(json['lastLoginAt']),
      lastPasswordResetAt: serializer.fromJson<DateTime?>(
        json['lastPasswordResetAt'],
      ),
      metadata: serializer.fromJson<Uint8List?>(json['metadata']),
      needsPasswordReset: serializer.fromJson<bool>(json['needsPasswordReset']),
      notes: serializer.fromJson<String?>(json['notes']),
      passwordHash: serializer.fromJson<String>(json['passwordHash']),
      passwordSalt: serializer.fromJson<String?>(json['passwordSalt']),
      passwordUpdatedAt: serializer.fromJson<DateTime?>(
        json['passwordUpdatedAt'],
      ),
      phone: serializer.fromJson<String?>(json['phone']),
      phoneVerified: serializer.fromJson<bool>(json['phoneVerified']),
      role: serializer.fromJson<String?>(json['role']),
      roleId: serializer.fromJson<String?>(json['roleId']),
      roleSnapshot: serializer.fromJson<String?>(json['roleSnapshot']),
      statusChangedAt: serializer.fromJson<DateTime?>(json['statusChangedAt']),
      statusReason: serializer.fromJson<String?>(json['statusReason']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      updatedBy: serializer.fromJson<String?>(json['updatedBy']),
      userEmail: serializer.fromJson<String?>(json['userEmail']),
      userId: serializer.fromJson<String?>(json['userId']),
      username: serializer.fromJson<String?>(json['username']),
      verificationCode: serializer.fromJson<String?>(json['verificationCode']),
      id: serializer.fromJson<int>(json['id']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'activeStatus': serializer.toJson<String?>(activeStatus),
      'blockedAt': serializer.toJson<DateTime?>(blockedAt),
      'blockedBy': serializer.toJson<String?>(blockedBy),
      'blockedReason': serializer.toJson<String?>(blockedReason),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'createdBy': serializer.toJson<String?>(createdBy),
      'customPermissions': serializer.toJson<String?>(customPermissions),
      'deactivatedAt': serializer.toJson<DateTime?>(deactivatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'deletedBy': serializer.toJson<String?>(deletedBy),
      'displayName': serializer.toJson<String?>(displayName),
      'emailVerified': serializer.toJson<bool>(emailVerified),
      'fullName': serializer.toJson<String?>(fullName),
      'inviteSentAt': serializer.toJson<DateTime?>(inviteSentAt),
      'inviteToken': serializer.toJson<String?>(inviteToken),
      'isActive': serializer.toJson<bool>(isActive),
      'isAdmin': serializer.toJson<bool>(isAdmin),
      'isBlocked': serializer.toJson<bool>(isBlocked),
      'isInvitePending': serializer.toJson<bool>(isInvitePending),
      'isOnline': serializer.toJson<bool>(isOnline),
      'isSoftDeleted': serializer.toJson<bool>(isSoftDeleted),
      'isSystem': serializer.toJson<bool>(isSystem),
      'lastActiveAt': serializer.toJson<DateTime?>(lastActiveAt),
      'lastLoginAt': serializer.toJson<DateTime?>(lastLoginAt),
      'lastPasswordResetAt': serializer.toJson<DateTime?>(lastPasswordResetAt),
      'metadata': serializer.toJson<Uint8List?>(metadata),
      'needsPasswordReset': serializer.toJson<bool>(needsPasswordReset),
      'notes': serializer.toJson<String?>(notes),
      'passwordHash': serializer.toJson<String>(passwordHash),
      'passwordSalt': serializer.toJson<String?>(passwordSalt),
      'passwordUpdatedAt': serializer.toJson<DateTime?>(passwordUpdatedAt),
      'phone': serializer.toJson<String?>(phone),
      'phoneVerified': serializer.toJson<bool>(phoneVerified),
      'role': serializer.toJson<String?>(role),
      'roleId': serializer.toJson<String?>(roleId),
      'roleSnapshot': serializer.toJson<String?>(roleSnapshot),
      'statusChangedAt': serializer.toJson<DateTime?>(statusChangedAt),
      'statusReason': serializer.toJson<String?>(statusReason),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'updatedBy': serializer.toJson<String?>(updatedBy),
      'userEmail': serializer.toJson<String?>(userEmail),
      'userId': serializer.toJson<String?>(userId),
      'username': serializer.toJson<String?>(username),
      'verificationCode': serializer.toJson<String?>(verificationCode),
      'id': serializer.toJson<int>(id),
    };
  }

  AppUserDb copyWith({
    Value<String?> activeStatus = const Value.absent(),
    Value<DateTime?> blockedAt = const Value.absent(),
    Value<String?> blockedBy = const Value.absent(),
    Value<String?> blockedReason = const Value.absent(),
    Value<DateTime?> createdAt = const Value.absent(),
    Value<String?> createdBy = const Value.absent(),
    Value<String?> customPermissions = const Value.absent(),
    Value<DateTime?> deactivatedAt = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<String?> deletedBy = const Value.absent(),
    Value<String?> displayName = const Value.absent(),
    bool? emailVerified,
    Value<String?> fullName = const Value.absent(),
    Value<DateTime?> inviteSentAt = const Value.absent(),
    Value<String?> inviteToken = const Value.absent(),
    bool? isActive,
    bool? isAdmin,
    bool? isBlocked,
    bool? isInvitePending,
    bool? isOnline,
    bool? isSoftDeleted,
    bool? isSystem,
    Value<DateTime?> lastActiveAt = const Value.absent(),
    Value<DateTime?> lastLoginAt = const Value.absent(),
    Value<DateTime?> lastPasswordResetAt = const Value.absent(),
    Value<Uint8List?> metadata = const Value.absent(),
    bool? needsPasswordReset,
    Value<String?> notes = const Value.absent(),
    String? passwordHash,
    Value<String?> passwordSalt = const Value.absent(),
    Value<DateTime?> passwordUpdatedAt = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    bool? phoneVerified,
    Value<String?> role = const Value.absent(),
    Value<String?> roleId = const Value.absent(),
    Value<String?> roleSnapshot = const Value.absent(),
    Value<DateTime?> statusChangedAt = const Value.absent(),
    Value<String?> statusReason = const Value.absent(),
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<String?> updatedBy = const Value.absent(),
    Value<String?> userEmail = const Value.absent(),
    Value<String?> userId = const Value.absent(),
    Value<String?> username = const Value.absent(),
    Value<String?> verificationCode = const Value.absent(),
    int? id,
  }) => AppUserDb(
    activeStatus: activeStatus.present ? activeStatus.value : this.activeStatus,
    blockedAt: blockedAt.present ? blockedAt.value : this.blockedAt,
    blockedBy: blockedBy.present ? blockedBy.value : this.blockedBy,
    blockedReason: blockedReason.present
        ? blockedReason.value
        : this.blockedReason,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    customPermissions: customPermissions.present
        ? customPermissions.value
        : this.customPermissions,
    deactivatedAt: deactivatedAt.present
        ? deactivatedAt.value
        : this.deactivatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    deletedBy: deletedBy.present ? deletedBy.value : this.deletedBy,
    displayName: displayName.present ? displayName.value : this.displayName,
    emailVerified: emailVerified ?? this.emailVerified,
    fullName: fullName.present ? fullName.value : this.fullName,
    inviteSentAt: inviteSentAt.present ? inviteSentAt.value : this.inviteSentAt,
    inviteToken: inviteToken.present ? inviteToken.value : this.inviteToken,
    isActive: isActive ?? this.isActive,
    isAdmin: isAdmin ?? this.isAdmin,
    isBlocked: isBlocked ?? this.isBlocked,
    isInvitePending: isInvitePending ?? this.isInvitePending,
    isOnline: isOnline ?? this.isOnline,
    isSoftDeleted: isSoftDeleted ?? this.isSoftDeleted,
    isSystem: isSystem ?? this.isSystem,
    lastActiveAt: lastActiveAt.present ? lastActiveAt.value : this.lastActiveAt,
    lastLoginAt: lastLoginAt.present ? lastLoginAt.value : this.lastLoginAt,
    lastPasswordResetAt: lastPasswordResetAt.present
        ? lastPasswordResetAt.value
        : this.lastPasswordResetAt,
    metadata: metadata.present ? metadata.value : this.metadata,
    needsPasswordReset: needsPasswordReset ?? this.needsPasswordReset,
    notes: notes.present ? notes.value : this.notes,
    passwordHash: passwordHash ?? this.passwordHash,
    passwordSalt: passwordSalt.present ? passwordSalt.value : this.passwordSalt,
    passwordUpdatedAt: passwordUpdatedAt.present
        ? passwordUpdatedAt.value
        : this.passwordUpdatedAt,
    phone: phone.present ? phone.value : this.phone,
    phoneVerified: phoneVerified ?? this.phoneVerified,
    role: role.present ? role.value : this.role,
    roleId: roleId.present ? roleId.value : this.roleId,
    roleSnapshot: roleSnapshot.present ? roleSnapshot.value : this.roleSnapshot,
    statusChangedAt: statusChangedAt.present
        ? statusChangedAt.value
        : this.statusChangedAt,
    statusReason: statusReason.present ? statusReason.value : this.statusReason,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    updatedBy: updatedBy.present ? updatedBy.value : this.updatedBy,
    userEmail: userEmail.present ? userEmail.value : this.userEmail,
    userId: userId.present ? userId.value : this.userId,
    username: username.present ? username.value : this.username,
    verificationCode: verificationCode.present
        ? verificationCode.value
        : this.verificationCode,
    id: id ?? this.id,
  );
  AppUserDb copyWithCompanion(AppUsersCompanion data) {
    return AppUserDb(
      activeStatus: data.activeStatus.present
          ? data.activeStatus.value
          : this.activeStatus,
      blockedAt: data.blockedAt.present ? data.blockedAt.value : this.blockedAt,
      blockedBy: data.blockedBy.present ? data.blockedBy.value : this.blockedBy,
      blockedReason: data.blockedReason.present
          ? data.blockedReason.value
          : this.blockedReason,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      customPermissions: data.customPermissions.present
          ? data.customPermissions.value
          : this.customPermissions,
      deactivatedAt: data.deactivatedAt.present
          ? data.deactivatedAt.value
          : this.deactivatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deletedBy: data.deletedBy.present ? data.deletedBy.value : this.deletedBy,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      emailVerified: data.emailVerified.present
          ? data.emailVerified.value
          : this.emailVerified,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      inviteSentAt: data.inviteSentAt.present
          ? data.inviteSentAt.value
          : this.inviteSentAt,
      inviteToken: data.inviteToken.present
          ? data.inviteToken.value
          : this.inviteToken,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      isAdmin: data.isAdmin.present ? data.isAdmin.value : this.isAdmin,
      isBlocked: data.isBlocked.present ? data.isBlocked.value : this.isBlocked,
      isInvitePending: data.isInvitePending.present
          ? data.isInvitePending.value
          : this.isInvitePending,
      isOnline: data.isOnline.present ? data.isOnline.value : this.isOnline,
      isSoftDeleted: data.isSoftDeleted.present
          ? data.isSoftDeleted.value
          : this.isSoftDeleted,
      isSystem: data.isSystem.present ? data.isSystem.value : this.isSystem,
      lastActiveAt: data.lastActiveAt.present
          ? data.lastActiveAt.value
          : this.lastActiveAt,
      lastLoginAt: data.lastLoginAt.present
          ? data.lastLoginAt.value
          : this.lastLoginAt,
      lastPasswordResetAt: data.lastPasswordResetAt.present
          ? data.lastPasswordResetAt.value
          : this.lastPasswordResetAt,
      metadata: data.metadata.present ? data.metadata.value : this.metadata,
      needsPasswordReset: data.needsPasswordReset.present
          ? data.needsPasswordReset.value
          : this.needsPasswordReset,
      notes: data.notes.present ? data.notes.value : this.notes,
      passwordHash: data.passwordHash.present
          ? data.passwordHash.value
          : this.passwordHash,
      passwordSalt: data.passwordSalt.present
          ? data.passwordSalt.value
          : this.passwordSalt,
      passwordUpdatedAt: data.passwordUpdatedAt.present
          ? data.passwordUpdatedAt.value
          : this.passwordUpdatedAt,
      phone: data.phone.present ? data.phone.value : this.phone,
      phoneVerified: data.phoneVerified.present
          ? data.phoneVerified.value
          : this.phoneVerified,
      role: data.role.present ? data.role.value : this.role,
      roleId: data.roleId.present ? data.roleId.value : this.roleId,
      roleSnapshot: data.roleSnapshot.present
          ? data.roleSnapshot.value
          : this.roleSnapshot,
      statusChangedAt: data.statusChangedAt.present
          ? data.statusChangedAt.value
          : this.statusChangedAt,
      statusReason: data.statusReason.present
          ? data.statusReason.value
          : this.statusReason,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      userEmail: data.userEmail.present ? data.userEmail.value : this.userEmail,
      userId: data.userId.present ? data.userId.value : this.userId,
      username: data.username.present ? data.username.value : this.username,
      verificationCode: data.verificationCode.present
          ? data.verificationCode.value
          : this.verificationCode,
      id: data.id.present ? data.id.value : this.id,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppUserDb(')
          ..write('activeStatus: $activeStatus, ')
          ..write('blockedAt: $blockedAt, ')
          ..write('blockedBy: $blockedBy, ')
          ..write('blockedReason: $blockedReason, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('customPermissions: $customPermissions, ')
          ..write('deactivatedAt: $deactivatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deletedBy: $deletedBy, ')
          ..write('displayName: $displayName, ')
          ..write('emailVerified: $emailVerified, ')
          ..write('fullName: $fullName, ')
          ..write('inviteSentAt: $inviteSentAt, ')
          ..write('inviteToken: $inviteToken, ')
          ..write('isActive: $isActive, ')
          ..write('isAdmin: $isAdmin, ')
          ..write('isBlocked: $isBlocked, ')
          ..write('isInvitePending: $isInvitePending, ')
          ..write('isOnline: $isOnline, ')
          ..write('isSoftDeleted: $isSoftDeleted, ')
          ..write('isSystem: $isSystem, ')
          ..write('lastActiveAt: $lastActiveAt, ')
          ..write('lastLoginAt: $lastLoginAt, ')
          ..write('lastPasswordResetAt: $lastPasswordResetAt, ')
          ..write('metadata: $metadata, ')
          ..write('needsPasswordReset: $needsPasswordReset, ')
          ..write('notes: $notes, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('passwordSalt: $passwordSalt, ')
          ..write('passwordUpdatedAt: $passwordUpdatedAt, ')
          ..write('phone: $phone, ')
          ..write('phoneVerified: $phoneVerified, ')
          ..write('role: $role, ')
          ..write('roleId: $roleId, ')
          ..write('roleSnapshot: $roleSnapshot, ')
          ..write('statusChangedAt: $statusChangedAt, ')
          ..write('statusReason: $statusReason, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('userEmail: $userEmail, ')
          ..write('userId: $userId, ')
          ..write('username: $username, ')
          ..write('verificationCode: $verificationCode, ')
          ..write('id: $id')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    activeStatus,
    blockedAt,
    blockedBy,
    blockedReason,
    createdAt,
    createdBy,
    customPermissions,
    deactivatedAt,
    deletedAt,
    deletedBy,
    displayName,
    emailVerified,
    fullName,
    inviteSentAt,
    inviteToken,
    isActive,
    isAdmin,
    isBlocked,
    isInvitePending,
    isOnline,
    isSoftDeleted,
    isSystem,
    lastActiveAt,
    lastLoginAt,
    lastPasswordResetAt,
    $driftBlobEquality.hash(metadata),
    needsPasswordReset,
    notes,
    passwordHash,
    passwordSalt,
    passwordUpdatedAt,
    phone,
    phoneVerified,
    role,
    roleId,
    roleSnapshot,
    statusChangedAt,
    statusReason,
    updatedAt,
    updatedBy,
    userEmail,
    userId,
    username,
    verificationCode,
    id,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppUserDb &&
          other.activeStatus == this.activeStatus &&
          other.blockedAt == this.blockedAt &&
          other.blockedBy == this.blockedBy &&
          other.blockedReason == this.blockedReason &&
          other.createdAt == this.createdAt &&
          other.createdBy == this.createdBy &&
          other.customPermissions == this.customPermissions &&
          other.deactivatedAt == this.deactivatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deletedBy == this.deletedBy &&
          other.displayName == this.displayName &&
          other.emailVerified == this.emailVerified &&
          other.fullName == this.fullName &&
          other.inviteSentAt == this.inviteSentAt &&
          other.inviteToken == this.inviteToken &&
          other.isActive == this.isActive &&
          other.isAdmin == this.isAdmin &&
          other.isBlocked == this.isBlocked &&
          other.isInvitePending == this.isInvitePending &&
          other.isOnline == this.isOnline &&
          other.isSoftDeleted == this.isSoftDeleted &&
          other.isSystem == this.isSystem &&
          other.lastActiveAt == this.lastActiveAt &&
          other.lastLoginAt == this.lastLoginAt &&
          other.lastPasswordResetAt == this.lastPasswordResetAt &&
          $driftBlobEquality.equals(other.metadata, this.metadata) &&
          other.needsPasswordReset == this.needsPasswordReset &&
          other.notes == this.notes &&
          other.passwordHash == this.passwordHash &&
          other.passwordSalt == this.passwordSalt &&
          other.passwordUpdatedAt == this.passwordUpdatedAt &&
          other.phone == this.phone &&
          other.phoneVerified == this.phoneVerified &&
          other.role == this.role &&
          other.roleId == this.roleId &&
          other.roleSnapshot == this.roleSnapshot &&
          other.statusChangedAt == this.statusChangedAt &&
          other.statusReason == this.statusReason &&
          other.updatedAt == this.updatedAt &&
          other.updatedBy == this.updatedBy &&
          other.userEmail == this.userEmail &&
          other.userId == this.userId &&
          other.username == this.username &&
          other.verificationCode == this.verificationCode &&
          other.id == this.id);
}

class AppUsersCompanion extends UpdateCompanion<AppUserDb> {
  final Value<String?> activeStatus;
  final Value<DateTime?> blockedAt;
  final Value<String?> blockedBy;
  final Value<String?> blockedReason;
  final Value<DateTime?> createdAt;
  final Value<String?> createdBy;
  final Value<String?> customPermissions;
  final Value<DateTime?> deactivatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> deletedBy;
  final Value<String?> displayName;
  final Value<bool> emailVerified;
  final Value<String?> fullName;
  final Value<DateTime?> inviteSentAt;
  final Value<String?> inviteToken;
  final Value<bool> isActive;
  final Value<bool> isAdmin;
  final Value<bool> isBlocked;
  final Value<bool> isInvitePending;
  final Value<bool> isOnline;
  final Value<bool> isSoftDeleted;
  final Value<bool> isSystem;
  final Value<DateTime?> lastActiveAt;
  final Value<DateTime?> lastLoginAt;
  final Value<DateTime?> lastPasswordResetAt;
  final Value<Uint8List?> metadata;
  final Value<bool> needsPasswordReset;
  final Value<String?> notes;
  final Value<String> passwordHash;
  final Value<String?> passwordSalt;
  final Value<DateTime?> passwordUpdatedAt;
  final Value<String?> phone;
  final Value<bool> phoneVerified;
  final Value<String?> role;
  final Value<String?> roleId;
  final Value<String?> roleSnapshot;
  final Value<DateTime?> statusChangedAt;
  final Value<String?> statusReason;
  final Value<DateTime?> updatedAt;
  final Value<String?> updatedBy;
  final Value<String?> userEmail;
  final Value<String?> userId;
  final Value<String?> username;
  final Value<String?> verificationCode;
  final Value<int> id;
  const AppUsersCompanion({
    this.activeStatus = const Value.absent(),
    this.blockedAt = const Value.absent(),
    this.blockedBy = const Value.absent(),
    this.blockedReason = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.customPermissions = const Value.absent(),
    this.deactivatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deletedBy = const Value.absent(),
    this.displayName = const Value.absent(),
    this.emailVerified = const Value.absent(),
    this.fullName = const Value.absent(),
    this.inviteSentAt = const Value.absent(),
    this.inviteToken = const Value.absent(),
    this.isActive = const Value.absent(),
    this.isAdmin = const Value.absent(),
    this.isBlocked = const Value.absent(),
    this.isInvitePending = const Value.absent(),
    this.isOnline = const Value.absent(),
    this.isSoftDeleted = const Value.absent(),
    this.isSystem = const Value.absent(),
    this.lastActiveAt = const Value.absent(),
    this.lastLoginAt = const Value.absent(),
    this.lastPasswordResetAt = const Value.absent(),
    this.metadata = const Value.absent(),
    this.needsPasswordReset = const Value.absent(),
    this.notes = const Value.absent(),
    this.passwordHash = const Value.absent(),
    this.passwordSalt = const Value.absent(),
    this.passwordUpdatedAt = const Value.absent(),
    this.phone = const Value.absent(),
    this.phoneVerified = const Value.absent(),
    this.role = const Value.absent(),
    this.roleId = const Value.absent(),
    this.roleSnapshot = const Value.absent(),
    this.statusChangedAt = const Value.absent(),
    this.statusReason = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.userEmail = const Value.absent(),
    this.userId = const Value.absent(),
    this.username = const Value.absent(),
    this.verificationCode = const Value.absent(),
    this.id = const Value.absent(),
  });
  AppUsersCompanion.insert({
    this.activeStatus = const Value.absent(),
    this.blockedAt = const Value.absent(),
    this.blockedBy = const Value.absent(),
    this.blockedReason = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.customPermissions = const Value.absent(),
    this.deactivatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deletedBy = const Value.absent(),
    this.displayName = const Value.absent(),
    this.emailVerified = const Value.absent(),
    this.fullName = const Value.absent(),
    this.inviteSentAt = const Value.absent(),
    this.inviteToken = const Value.absent(),
    this.isActive = const Value.absent(),
    this.isAdmin = const Value.absent(),
    this.isBlocked = const Value.absent(),
    this.isInvitePending = const Value.absent(),
    this.isOnline = const Value.absent(),
    this.isSoftDeleted = const Value.absent(),
    this.isSystem = const Value.absent(),
    this.lastActiveAt = const Value.absent(),
    this.lastLoginAt = const Value.absent(),
    this.lastPasswordResetAt = const Value.absent(),
    this.metadata = const Value.absent(),
    this.needsPasswordReset = const Value.absent(),
    this.notes = const Value.absent(),
    required String passwordHash,
    this.passwordSalt = const Value.absent(),
    this.passwordUpdatedAt = const Value.absent(),
    this.phone = const Value.absent(),
    this.phoneVerified = const Value.absent(),
    this.role = const Value.absent(),
    this.roleId = const Value.absent(),
    this.roleSnapshot = const Value.absent(),
    this.statusChangedAt = const Value.absent(),
    this.statusReason = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.userEmail = const Value.absent(),
    this.userId = const Value.absent(),
    this.username = const Value.absent(),
    this.verificationCode = const Value.absent(),
    this.id = const Value.absent(),
  }) : passwordHash = Value(passwordHash);
  static Insertable<AppUserDb> custom({
    Expression<String>? activeStatus,
    Expression<DateTime>? blockedAt,
    Expression<String>? blockedBy,
    Expression<String>? blockedReason,
    Expression<DateTime>? createdAt,
    Expression<String>? createdBy,
    Expression<String>? customPermissions,
    Expression<DateTime>? deactivatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? deletedBy,
    Expression<String>? displayName,
    Expression<bool>? emailVerified,
    Expression<String>? fullName,
    Expression<DateTime>? inviteSentAt,
    Expression<String>? inviteToken,
    Expression<bool>? isActive,
    Expression<bool>? isAdmin,
    Expression<bool>? isBlocked,
    Expression<bool>? isInvitePending,
    Expression<bool>? isOnline,
    Expression<bool>? isSoftDeleted,
    Expression<bool>? isSystem,
    Expression<DateTime>? lastActiveAt,
    Expression<DateTime>? lastLoginAt,
    Expression<DateTime>? lastPasswordResetAt,
    Expression<Uint8List>? metadata,
    Expression<bool>? needsPasswordReset,
    Expression<String>? notes,
    Expression<String>? passwordHash,
    Expression<String>? passwordSalt,
    Expression<DateTime>? passwordUpdatedAt,
    Expression<String>? phone,
    Expression<bool>? phoneVerified,
    Expression<String>? role,
    Expression<String>? roleId,
    Expression<String>? roleSnapshot,
    Expression<DateTime>? statusChangedAt,
    Expression<String>? statusReason,
    Expression<DateTime>? updatedAt,
    Expression<String>? updatedBy,
    Expression<String>? userEmail,
    Expression<String>? userId,
    Expression<String>? username,
    Expression<String>? verificationCode,
    Expression<int>? id,
  }) {
    return RawValuesInsertable({
      if (activeStatus != null) 'active_status': activeStatus,
      if (blockedAt != null) 'blocked_at': blockedAt,
      if (blockedBy != null) 'blocked_by': blockedBy,
      if (blockedReason != null) 'blocked_reason': blockedReason,
      if (createdAt != null) 'created_at': createdAt,
      if (createdBy != null) 'created_by': createdBy,
      if (customPermissions != null) 'custom_permissions': customPermissions,
      if (deactivatedAt != null) 'deactivated_at': deactivatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deletedBy != null) 'deleted_by': deletedBy,
      if (displayName != null) 'display_name': displayName,
      if (emailVerified != null) 'email_verified': emailVerified,
      if (fullName != null) 'full_name': fullName,
      if (inviteSentAt != null) 'invite_sent_at': inviteSentAt,
      if (inviteToken != null) 'invite_token': inviteToken,
      if (isActive != null) 'is_active': isActive,
      if (isAdmin != null) 'is_admin': isAdmin,
      if (isBlocked != null) 'is_blocked': isBlocked,
      if (isInvitePending != null) 'is_invite_pending': isInvitePending,
      if (isOnline != null) 'is_online': isOnline,
      if (isSoftDeleted != null) 'is_soft_deleted': isSoftDeleted,
      if (isSystem != null) 'is_system': isSystem,
      if (lastActiveAt != null) 'last_active_at': lastActiveAt,
      if (lastLoginAt != null) 'last_login_at': lastLoginAt,
      if (lastPasswordResetAt != null)
        'last_password_reset_at': lastPasswordResetAt,
      if (metadata != null) 'metadata': metadata,
      if (needsPasswordReset != null)
        'needs_password_reset': needsPasswordReset,
      if (notes != null) 'notes': notes,
      if (passwordHash != null) 'password_hash': passwordHash,
      if (passwordSalt != null) 'password_salt': passwordSalt,
      if (passwordUpdatedAt != null) 'password_updated_at': passwordUpdatedAt,
      if (phone != null) 'phone': phone,
      if (phoneVerified != null) 'phone_verified': phoneVerified,
      if (role != null) 'role': role,
      if (roleId != null) 'role_id': roleId,
      if (roleSnapshot != null) 'role_snapshot': roleSnapshot,
      if (statusChangedAt != null) 'status_changed_at': statusChangedAt,
      if (statusReason != null) 'status_reason': statusReason,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (userEmail != null) 'user_email': userEmail,
      if (userId != null) 'user_id': userId,
      if (username != null) 'username': username,
      if (verificationCode != null) 'verification_code': verificationCode,
      if (id != null) 'id': id,
    });
  }

  AppUsersCompanion copyWith({
    Value<String?>? activeStatus,
    Value<DateTime?>? blockedAt,
    Value<String?>? blockedBy,
    Value<String?>? blockedReason,
    Value<DateTime?>? createdAt,
    Value<String?>? createdBy,
    Value<String?>? customPermissions,
    Value<DateTime?>? deactivatedAt,
    Value<DateTime?>? deletedAt,
    Value<String?>? deletedBy,
    Value<String?>? displayName,
    Value<bool>? emailVerified,
    Value<String?>? fullName,
    Value<DateTime?>? inviteSentAt,
    Value<String?>? inviteToken,
    Value<bool>? isActive,
    Value<bool>? isAdmin,
    Value<bool>? isBlocked,
    Value<bool>? isInvitePending,
    Value<bool>? isOnline,
    Value<bool>? isSoftDeleted,
    Value<bool>? isSystem,
    Value<DateTime?>? lastActiveAt,
    Value<DateTime?>? lastLoginAt,
    Value<DateTime?>? lastPasswordResetAt,
    Value<Uint8List?>? metadata,
    Value<bool>? needsPasswordReset,
    Value<String?>? notes,
    Value<String>? passwordHash,
    Value<String?>? passwordSalt,
    Value<DateTime?>? passwordUpdatedAt,
    Value<String?>? phone,
    Value<bool>? phoneVerified,
    Value<String?>? role,
    Value<String?>? roleId,
    Value<String?>? roleSnapshot,
    Value<DateTime?>? statusChangedAt,
    Value<String?>? statusReason,
    Value<DateTime?>? updatedAt,
    Value<String?>? updatedBy,
    Value<String?>? userEmail,
    Value<String?>? userId,
    Value<String?>? username,
    Value<String?>? verificationCode,
    Value<int>? id,
  }) {
    return AppUsersCompanion(
      activeStatus: activeStatus ?? this.activeStatus,
      blockedAt: blockedAt ?? this.blockedAt,
      blockedBy: blockedBy ?? this.blockedBy,
      blockedReason: blockedReason ?? this.blockedReason,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      customPermissions: customPermissions ?? this.customPermissions,
      deactivatedAt: deactivatedAt ?? this.deactivatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deletedBy: deletedBy ?? this.deletedBy,
      displayName: displayName ?? this.displayName,
      emailVerified: emailVerified ?? this.emailVerified,
      fullName: fullName ?? this.fullName,
      inviteSentAt: inviteSentAt ?? this.inviteSentAt,
      inviteToken: inviteToken ?? this.inviteToken,
      isActive: isActive ?? this.isActive,
      isAdmin: isAdmin ?? this.isAdmin,
      isBlocked: isBlocked ?? this.isBlocked,
      isInvitePending: isInvitePending ?? this.isInvitePending,
      isOnline: isOnline ?? this.isOnline,
      isSoftDeleted: isSoftDeleted ?? this.isSoftDeleted,
      isSystem: isSystem ?? this.isSystem,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      lastPasswordResetAt: lastPasswordResetAt ?? this.lastPasswordResetAt,
      metadata: metadata ?? this.metadata,
      needsPasswordReset: needsPasswordReset ?? this.needsPasswordReset,
      notes: notes ?? this.notes,
      passwordHash: passwordHash ?? this.passwordHash,
      passwordSalt: passwordSalt ?? this.passwordSalt,
      passwordUpdatedAt: passwordUpdatedAt ?? this.passwordUpdatedAt,
      phone: phone ?? this.phone,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      role: role ?? this.role,
      roleId: roleId ?? this.roleId,
      roleSnapshot: roleSnapshot ?? this.roleSnapshot,
      statusChangedAt: statusChangedAt ?? this.statusChangedAt,
      statusReason: statusReason ?? this.statusReason,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      userEmail: userEmail ?? this.userEmail,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      verificationCode: verificationCode ?? this.verificationCode,
      id: id ?? this.id,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (activeStatus.present) {
      map['active_status'] = Variable<String>(activeStatus.value);
    }
    if (blockedAt.present) {
      map['blocked_at'] = Variable<DateTime>(blockedAt.value);
    }
    if (blockedBy.present) {
      map['blocked_by'] = Variable<String>(blockedBy.value);
    }
    if (blockedReason.present) {
      map['blocked_reason'] = Variable<String>(blockedReason.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (customPermissions.present) {
      map['custom_permissions'] = Variable<String>(customPermissions.value);
    }
    if (deactivatedAt.present) {
      map['deactivated_at'] = Variable<DateTime>(deactivatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (deletedBy.present) {
      map['deleted_by'] = Variable<String>(deletedBy.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (emailVerified.present) {
      map['email_verified'] = Variable<bool>(emailVerified.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (inviteSentAt.present) {
      map['invite_sent_at'] = Variable<DateTime>(inviteSentAt.value);
    }
    if (inviteToken.present) {
      map['invite_token'] = Variable<String>(inviteToken.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (isAdmin.present) {
      map['is_admin'] = Variable<bool>(isAdmin.value);
    }
    if (isBlocked.present) {
      map['is_blocked'] = Variable<bool>(isBlocked.value);
    }
    if (isInvitePending.present) {
      map['is_invite_pending'] = Variable<bool>(isInvitePending.value);
    }
    if (isOnline.present) {
      map['is_online'] = Variable<bool>(isOnline.value);
    }
    if (isSoftDeleted.present) {
      map['is_soft_deleted'] = Variable<bool>(isSoftDeleted.value);
    }
    if (isSystem.present) {
      map['is_system'] = Variable<bool>(isSystem.value);
    }
    if (lastActiveAt.present) {
      map['last_active_at'] = Variable<DateTime>(lastActiveAt.value);
    }
    if (lastLoginAt.present) {
      map['last_login_at'] = Variable<DateTime>(lastLoginAt.value);
    }
    if (lastPasswordResetAt.present) {
      map['last_password_reset_at'] = Variable<DateTime>(
        lastPasswordResetAt.value,
      );
    }
    if (metadata.present) {
      map['metadata'] = Variable<Uint8List>(metadata.value);
    }
    if (needsPasswordReset.present) {
      map['needs_password_reset'] = Variable<bool>(needsPasswordReset.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (passwordHash.present) {
      map['password_hash'] = Variable<String>(passwordHash.value);
    }
    if (passwordSalt.present) {
      map['password_salt'] = Variable<String>(passwordSalt.value);
    }
    if (passwordUpdatedAt.present) {
      map['password_updated_at'] = Variable<DateTime>(passwordUpdatedAt.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (phoneVerified.present) {
      map['phone_verified'] = Variable<bool>(phoneVerified.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (roleId.present) {
      map['role_id'] = Variable<String>(roleId.value);
    }
    if (roleSnapshot.present) {
      map['role_snapshot'] = Variable<String>(roleSnapshot.value);
    }
    if (statusChangedAt.present) {
      map['status_changed_at'] = Variable<DateTime>(statusChangedAt.value);
    }
    if (statusReason.present) {
      map['status_reason'] = Variable<String>(statusReason.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (userEmail.present) {
      map['user_email'] = Variable<String>(userEmail.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (verificationCode.present) {
      map['verification_code'] = Variable<String>(verificationCode.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppUsersCompanion(')
          ..write('activeStatus: $activeStatus, ')
          ..write('blockedAt: $blockedAt, ')
          ..write('blockedBy: $blockedBy, ')
          ..write('blockedReason: $blockedReason, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('customPermissions: $customPermissions, ')
          ..write('deactivatedAt: $deactivatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deletedBy: $deletedBy, ')
          ..write('displayName: $displayName, ')
          ..write('emailVerified: $emailVerified, ')
          ..write('fullName: $fullName, ')
          ..write('inviteSentAt: $inviteSentAt, ')
          ..write('inviteToken: $inviteToken, ')
          ..write('isActive: $isActive, ')
          ..write('isAdmin: $isAdmin, ')
          ..write('isBlocked: $isBlocked, ')
          ..write('isInvitePending: $isInvitePending, ')
          ..write('isOnline: $isOnline, ')
          ..write('isSoftDeleted: $isSoftDeleted, ')
          ..write('isSystem: $isSystem, ')
          ..write('lastActiveAt: $lastActiveAt, ')
          ..write('lastLoginAt: $lastLoginAt, ')
          ..write('lastPasswordResetAt: $lastPasswordResetAt, ')
          ..write('metadata: $metadata, ')
          ..write('needsPasswordReset: $needsPasswordReset, ')
          ..write('notes: $notes, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('passwordSalt: $passwordSalt, ')
          ..write('passwordUpdatedAt: $passwordUpdatedAt, ')
          ..write('phone: $phone, ')
          ..write('phoneVerified: $phoneVerified, ')
          ..write('role: $role, ')
          ..write('roleId: $roleId, ')
          ..write('roleSnapshot: $roleSnapshot, ')
          ..write('statusChangedAt: $statusChangedAt, ')
          ..write('statusReason: $statusReason, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('userEmail: $userEmail, ')
          ..write('userId: $userId, ')
          ..write('username: $username, ')
          ..write('verificationCode: $verificationCode, ')
          ..write('id: $id')
          ..write(')'))
        .toString();
  }
}

class $BoilerHousesTable extends BoilerHouses
    with TableInfo<$BoilerHousesTable, BoilerHouseDb> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BoilerHousesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _backendIdMeta = const VerificationMeta(
    'backendId',
  );
  @override
  late final GeneratedColumn<int> backendId = GeneratedColumn<int>(
    'backend_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _boilerHouseUUIDMeta = const VerificationMeta(
    'boilerHouseUUID',
  );
  @override
  late final GeneratedColumn<String> boilerHouseUUID = GeneratedColumn<String>(
    'boiler_house_u_u_i_d',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _siteManagerMeta = const VerificationMeta(
    'siteManager',
  );
  @override
  late final GeneratedColumn<String> siteManager = GeneratedColumn<String>(
    'site_manager',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _siteNumberMeta = const VerificationMeta(
    'siteNumber',
  );
  @override
  late final GeneratedColumn<String> siteNumber = GeneratedColumn<String>(
    'site_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    backendId,
    boilerHouseUUID,
    latitude,
    longitude,
    name,
    siteManager,
    siteNumber,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'boiler_houses';
  @override
  VerificationContext validateIntegrity(
    Insertable<BoilerHouseDb> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('backend_id')) {
      context.handle(
        _backendIdMeta,
        backendId.isAcceptableOrUnknown(data['backend_id']!, _backendIdMeta),
      );
    }
    if (data.containsKey('boiler_house_u_u_i_d')) {
      context.handle(
        _boilerHouseUUIDMeta,
        boilerHouseUUID.isAcceptableOrUnknown(
          data['boiler_house_u_u_i_d']!,
          _boilerHouseUUIDMeta,
        ),
      );
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('site_manager')) {
      context.handle(
        _siteManagerMeta,
        siteManager.isAcceptableOrUnknown(
          data['site_manager']!,
          _siteManagerMeta,
        ),
      );
    }
    if (data.containsKey('site_number')) {
      context.handle(
        _siteNumberMeta,
        siteNumber.isAcceptableOrUnknown(data['site_number']!, _siteNumberMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {backendId};
  @override
  BoilerHouseDb map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BoilerHouseDb(
      backendId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}backend_id'],
      )!,
      boilerHouseUUID: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}boiler_house_u_u_i_d'],
      ),
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      siteManager: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}site_manager'],
      ),
      siteNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}site_number'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $BoilerHousesTable createAlias(String alias) {
    return $BoilerHousesTable(attachedDatabase, alias);
  }
}

class BoilerHouseDb extends DataClass implements Insertable<BoilerHouseDb> {
  final int backendId;
  final String? boilerHouseUUID;
  final double? latitude;
  final double? longitude;
  final String? name;
  final String? siteManager;
  final String? siteNumber;
  final DateTime? updatedAt;
  const BoilerHouseDb({
    required this.backendId,
    this.boilerHouseUUID,
    this.latitude,
    this.longitude,
    this.name,
    this.siteManager,
    this.siteNumber,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['backend_id'] = Variable<int>(backendId);
    if (!nullToAbsent || boilerHouseUUID != null) {
      map['boiler_house_u_u_i_d'] = Variable<String>(boilerHouseUUID);
    }
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || siteManager != null) {
      map['site_manager'] = Variable<String>(siteManager);
    }
    if (!nullToAbsent || siteNumber != null) {
      map['site_number'] = Variable<String>(siteNumber);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  BoilerHousesCompanion toCompanion(bool nullToAbsent) {
    return BoilerHousesCompanion(
      backendId: Value(backendId),
      boilerHouseUUID: boilerHouseUUID == null && nullToAbsent
          ? const Value.absent()
          : Value(boilerHouseUUID),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      siteManager: siteManager == null && nullToAbsent
          ? const Value.absent()
          : Value(siteManager),
      siteNumber: siteNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(siteNumber),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory BoilerHouseDb.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BoilerHouseDb(
      backendId: serializer.fromJson<int>(json['backendId']),
      boilerHouseUUID: serializer.fromJson<String?>(json['boilerHouseUUID']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      name: serializer.fromJson<String?>(json['name']),
      siteManager: serializer.fromJson<String?>(json['siteManager']),
      siteNumber: serializer.fromJson<String?>(json['siteNumber']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'backendId': serializer.toJson<int>(backendId),
      'boilerHouseUUID': serializer.toJson<String?>(boilerHouseUUID),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'name': serializer.toJson<String?>(name),
      'siteManager': serializer.toJson<String?>(siteManager),
      'siteNumber': serializer.toJson<String?>(siteNumber),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  BoilerHouseDb copyWith({
    int? backendId,
    Value<String?> boilerHouseUUID = const Value.absent(),
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
    Value<String?> name = const Value.absent(),
    Value<String?> siteManager = const Value.absent(),
    Value<String?> siteNumber = const Value.absent(),
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => BoilerHouseDb(
    backendId: backendId ?? this.backendId,
    boilerHouseUUID: boilerHouseUUID.present
        ? boilerHouseUUID.value
        : this.boilerHouseUUID,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
    name: name.present ? name.value : this.name,
    siteManager: siteManager.present ? siteManager.value : this.siteManager,
    siteNumber: siteNumber.present ? siteNumber.value : this.siteNumber,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  BoilerHouseDb copyWithCompanion(BoilerHousesCompanion data) {
    return BoilerHouseDb(
      backendId: data.backendId.present ? data.backendId.value : this.backendId,
      boilerHouseUUID: data.boilerHouseUUID.present
          ? data.boilerHouseUUID.value
          : this.boilerHouseUUID,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      name: data.name.present ? data.name.value : this.name,
      siteManager: data.siteManager.present
          ? data.siteManager.value
          : this.siteManager,
      siteNumber: data.siteNumber.present
          ? data.siteNumber.value
          : this.siteNumber,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BoilerHouseDb(')
          ..write('backendId: $backendId, ')
          ..write('boilerHouseUUID: $boilerHouseUUID, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('name: $name, ')
          ..write('siteManager: $siteManager, ')
          ..write('siteNumber: $siteNumber, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    backendId,
    boilerHouseUUID,
    latitude,
    longitude,
    name,
    siteManager,
    siteNumber,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BoilerHouseDb &&
          other.backendId == this.backendId &&
          other.boilerHouseUUID == this.boilerHouseUUID &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.name == this.name &&
          other.siteManager == this.siteManager &&
          other.siteNumber == this.siteNumber &&
          other.updatedAt == this.updatedAt);
}

class BoilerHousesCompanion extends UpdateCompanion<BoilerHouseDb> {
  final Value<int> backendId;
  final Value<String?> boilerHouseUUID;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<String?> name;
  final Value<String?> siteManager;
  final Value<String?> siteNumber;
  final Value<DateTime?> updatedAt;
  const BoilerHousesCompanion({
    this.backendId = const Value.absent(),
    this.boilerHouseUUID = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.name = const Value.absent(),
    this.siteManager = const Value.absent(),
    this.siteNumber = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  BoilerHousesCompanion.insert({
    this.backendId = const Value.absent(),
    this.boilerHouseUUID = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.name = const Value.absent(),
    this.siteManager = const Value.absent(),
    this.siteNumber = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  static Insertable<BoilerHouseDb> custom({
    Expression<int>? backendId,
    Expression<String>? boilerHouseUUID,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? name,
    Expression<String>? siteManager,
    Expression<String>? siteNumber,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (backendId != null) 'backend_id': backendId,
      if (boilerHouseUUID != null) 'boiler_house_u_u_i_d': boilerHouseUUID,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (name != null) 'name': name,
      if (siteManager != null) 'site_manager': siteManager,
      if (siteNumber != null) 'site_number': siteNumber,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  BoilerHousesCompanion copyWith({
    Value<int>? backendId,
    Value<String?>? boilerHouseUUID,
    Value<double?>? latitude,
    Value<double?>? longitude,
    Value<String?>? name,
    Value<String?>? siteManager,
    Value<String?>? siteNumber,
    Value<DateTime?>? updatedAt,
  }) {
    return BoilerHousesCompanion(
      backendId: backendId ?? this.backendId,
      boilerHouseUUID: boilerHouseUUID ?? this.boilerHouseUUID,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      name: name ?? this.name,
      siteManager: siteManager ?? this.siteManager,
      siteNumber: siteNumber ?? this.siteNumber,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (backendId.present) {
      map['backend_id'] = Variable<int>(backendId.value);
    }
    if (boilerHouseUUID.present) {
      map['boiler_house_u_u_i_d'] = Variable<String>(boilerHouseUUID.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (siteManager.present) {
      map['site_manager'] = Variable<String>(siteManager.value);
    }
    if (siteNumber.present) {
      map['site_number'] = Variable<String>(siteNumber.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BoilerHousesCompanion(')
          ..write('backendId: $backendId, ')
          ..write('boilerHouseUUID: $boilerHouseUUID, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('name: $name, ')
          ..write('siteManager: $siteManager, ')
          ..write('siteNumber: $siteNumber, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $BoilerPhotosTable extends BoilerPhotos
    with TableInfo<$BoilerPhotosTable, BoilerPhotoDb> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BoilerPhotosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _backendIdMeta = const VerificationMeta(
    'backendId',
  );
  @override
  late final GeneratedColumn<int> backendId = GeneratedColumn<int>(
    'backend_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileSizeMeta = const VerificationMeta(
    'fileSize',
  );
  @override
  late final GeneratedColumn<int> fileSize = GeneratedColumn<int>(
    'file_size',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<int> height = GeneratedColumn<int>(
    'height',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sha256Meta = const VerificationMeta('sha256');
  @override
  late final GeneratedColumn<String> sha256 = GeneratedColumn<String>(
    'sha256',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _thumbJPEGMeta = const VerificationMeta(
    'thumbJPEG',
  );
  @override
  late final GeneratedColumn<Uint8List> thumbJPEG = GeneratedColumn<Uint8List>(
    'thumb_j_p_e_g',
    aliasedName,
    true,
    type: DriftSqlType.blob,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _thumbnailUrlMeta = const VerificationMeta(
    'thumbnailUrl',
  );
  @override
  late final GeneratedColumn<String> thumbnailUrl = GeneratedColumn<String>(
    'thumbnail_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<int> width = GeneratedColumn<int>(
    'width',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _boilerHouseIdMeta = const VerificationMeta(
    'boilerHouseId',
  );
  @override
  late final GeneratedColumn<int> boilerHouseId = GeneratedColumn<int>(
    'boiler_house_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES boiler_houses (backend_id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    backendId,
    createdAt,
    fileName,
    fileSize,
    height,
    id,
    sha256,
    thumbJPEG,
    thumbnailUrl,
    url,
    width,
    boilerHouseId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'boiler_photos';
  @override
  VerificationContext validateIntegrity(
    Insertable<BoilerPhotoDb> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('backend_id')) {
      context.handle(
        _backendIdMeta,
        backendId.isAcceptableOrUnknown(data['backend_id']!, _backendIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('file_size')) {
      context.handle(
        _fileSizeMeta,
        fileSize.isAcceptableOrUnknown(data['file_size']!, _fileSizeMeta),
      );
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('sha256')) {
      context.handle(
        _sha256Meta,
        sha256.isAcceptableOrUnknown(data['sha256']!, _sha256Meta),
      );
    }
    if (data.containsKey('thumb_j_p_e_g')) {
      context.handle(
        _thumbJPEGMeta,
        thumbJPEG.isAcceptableOrUnknown(data['thumb_j_p_e_g']!, _thumbJPEGMeta),
      );
    }
    if (data.containsKey('thumbnail_url')) {
      context.handle(
        _thumbnailUrlMeta,
        thumbnailUrl.isAcceptableOrUnknown(
          data['thumbnail_url']!,
          _thumbnailUrlMeta,
        ),
      );
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    }
    if (data.containsKey('width')) {
      context.handle(
        _widthMeta,
        width.isAcceptableOrUnknown(data['width']!, _widthMeta),
      );
    }
    if (data.containsKey('boiler_house_id')) {
      context.handle(
        _boilerHouseIdMeta,
        boilerHouseId.isAcceptableOrUnknown(
          data['boiler_house_id']!,
          _boilerHouseIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {backendId};
  @override
  BoilerPhotoDb map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BoilerPhotoDb(
      backendId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}backend_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
      fileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_name'],
      )!,
      fileSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}file_size'],
      ),
      height: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}height'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sha256'],
      ),
      thumbJPEG: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}thumb_j_p_e_g'],
      ),
      thumbnailUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail_url'],
      ),
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      ),
      width: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}width'],
      ),
      boilerHouseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}boiler_house_id'],
      ),
    );
  }

  @override
  $BoilerPhotosTable createAlias(String alias) {
    return $BoilerPhotosTable(attachedDatabase, alias);
  }
}

class BoilerPhotoDb extends DataClass implements Insertable<BoilerPhotoDb> {
  final int backendId;
  final DateTime? createdAt;
  final String fileName;
  final int? fileSize;
  final int? height;
  final String id;
  final String? sha256;
  final Uint8List? thumbJPEG;
  final String? thumbnailUrl;
  final String? url;
  final int? width;
  final int? boilerHouseId;
  const BoilerPhotoDb({
    required this.backendId,
    this.createdAt,
    required this.fileName,
    this.fileSize,
    this.height,
    required this.id,
    this.sha256,
    this.thumbJPEG,
    this.thumbnailUrl,
    this.url,
    this.width,
    this.boilerHouseId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['backend_id'] = Variable<int>(backendId);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    map['file_name'] = Variable<String>(fileName);
    if (!nullToAbsent || fileSize != null) {
      map['file_size'] = Variable<int>(fileSize);
    }
    if (!nullToAbsent || height != null) {
      map['height'] = Variable<int>(height);
    }
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || sha256 != null) {
      map['sha256'] = Variable<String>(sha256);
    }
    if (!nullToAbsent || thumbJPEG != null) {
      map['thumb_j_p_e_g'] = Variable<Uint8List>(thumbJPEG);
    }
    if (!nullToAbsent || thumbnailUrl != null) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl);
    }
    if (!nullToAbsent || url != null) {
      map['url'] = Variable<String>(url);
    }
    if (!nullToAbsent || width != null) {
      map['width'] = Variable<int>(width);
    }
    if (!nullToAbsent || boilerHouseId != null) {
      map['boiler_house_id'] = Variable<int>(boilerHouseId);
    }
    return map;
  }

  BoilerPhotosCompanion toCompanion(bool nullToAbsent) {
    return BoilerPhotosCompanion(
      backendId: Value(backendId),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      fileName: Value(fileName),
      fileSize: fileSize == null && nullToAbsent
          ? const Value.absent()
          : Value(fileSize),
      height: height == null && nullToAbsent
          ? const Value.absent()
          : Value(height),
      id: Value(id),
      sha256: sha256 == null && nullToAbsent
          ? const Value.absent()
          : Value(sha256),
      thumbJPEG: thumbJPEG == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbJPEG),
      thumbnailUrl: thumbnailUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailUrl),
      url: url == null && nullToAbsent ? const Value.absent() : Value(url),
      width: width == null && nullToAbsent
          ? const Value.absent()
          : Value(width),
      boilerHouseId: boilerHouseId == null && nullToAbsent
          ? const Value.absent()
          : Value(boilerHouseId),
    );
  }

  factory BoilerPhotoDb.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BoilerPhotoDb(
      backendId: serializer.fromJson<int>(json['backendId']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      fileName: serializer.fromJson<String>(json['fileName']),
      fileSize: serializer.fromJson<int?>(json['fileSize']),
      height: serializer.fromJson<int?>(json['height']),
      id: serializer.fromJson<String>(json['id']),
      sha256: serializer.fromJson<String?>(json['sha256']),
      thumbJPEG: serializer.fromJson<Uint8List?>(json['thumbJPEG']),
      thumbnailUrl: serializer.fromJson<String?>(json['thumbnailUrl']),
      url: serializer.fromJson<String?>(json['url']),
      width: serializer.fromJson<int?>(json['width']),
      boilerHouseId: serializer.fromJson<int?>(json['boilerHouseId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'backendId': serializer.toJson<int>(backendId),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'fileName': serializer.toJson<String>(fileName),
      'fileSize': serializer.toJson<int?>(fileSize),
      'height': serializer.toJson<int?>(height),
      'id': serializer.toJson<String>(id),
      'sha256': serializer.toJson<String?>(sha256),
      'thumbJPEG': serializer.toJson<Uint8List?>(thumbJPEG),
      'thumbnailUrl': serializer.toJson<String?>(thumbnailUrl),
      'url': serializer.toJson<String?>(url),
      'width': serializer.toJson<int?>(width),
      'boilerHouseId': serializer.toJson<int?>(boilerHouseId),
    };
  }

  BoilerPhotoDb copyWith({
    int? backendId,
    Value<DateTime?> createdAt = const Value.absent(),
    String? fileName,
    Value<int?> fileSize = const Value.absent(),
    Value<int?> height = const Value.absent(),
    String? id,
    Value<String?> sha256 = const Value.absent(),
    Value<Uint8List?> thumbJPEG = const Value.absent(),
    Value<String?> thumbnailUrl = const Value.absent(),
    Value<String?> url = const Value.absent(),
    Value<int?> width = const Value.absent(),
    Value<int?> boilerHouseId = const Value.absent(),
  }) => BoilerPhotoDb(
    backendId: backendId ?? this.backendId,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    fileName: fileName ?? this.fileName,
    fileSize: fileSize.present ? fileSize.value : this.fileSize,
    height: height.present ? height.value : this.height,
    id: id ?? this.id,
    sha256: sha256.present ? sha256.value : this.sha256,
    thumbJPEG: thumbJPEG.present ? thumbJPEG.value : this.thumbJPEG,
    thumbnailUrl: thumbnailUrl.present ? thumbnailUrl.value : this.thumbnailUrl,
    url: url.present ? url.value : this.url,
    width: width.present ? width.value : this.width,
    boilerHouseId: boilerHouseId.present
        ? boilerHouseId.value
        : this.boilerHouseId,
  );
  BoilerPhotoDb copyWithCompanion(BoilerPhotosCompanion data) {
    return BoilerPhotoDb(
      backendId: data.backendId.present ? data.backendId.value : this.backendId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      fileSize: data.fileSize.present ? data.fileSize.value : this.fileSize,
      height: data.height.present ? data.height.value : this.height,
      id: data.id.present ? data.id.value : this.id,
      sha256: data.sha256.present ? data.sha256.value : this.sha256,
      thumbJPEG: data.thumbJPEG.present ? data.thumbJPEG.value : this.thumbJPEG,
      thumbnailUrl: data.thumbnailUrl.present
          ? data.thumbnailUrl.value
          : this.thumbnailUrl,
      url: data.url.present ? data.url.value : this.url,
      width: data.width.present ? data.width.value : this.width,
      boilerHouseId: data.boilerHouseId.present
          ? data.boilerHouseId.value
          : this.boilerHouseId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BoilerPhotoDb(')
          ..write('backendId: $backendId, ')
          ..write('createdAt: $createdAt, ')
          ..write('fileName: $fileName, ')
          ..write('fileSize: $fileSize, ')
          ..write('height: $height, ')
          ..write('id: $id, ')
          ..write('sha256: $sha256, ')
          ..write('thumbJPEG: $thumbJPEG, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('url: $url, ')
          ..write('width: $width, ')
          ..write('boilerHouseId: $boilerHouseId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    backendId,
    createdAt,
    fileName,
    fileSize,
    height,
    id,
    sha256,
    $driftBlobEquality.hash(thumbJPEG),
    thumbnailUrl,
    url,
    width,
    boilerHouseId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BoilerPhotoDb &&
          other.backendId == this.backendId &&
          other.createdAt == this.createdAt &&
          other.fileName == this.fileName &&
          other.fileSize == this.fileSize &&
          other.height == this.height &&
          other.id == this.id &&
          other.sha256 == this.sha256 &&
          $driftBlobEquality.equals(other.thumbJPEG, this.thumbJPEG) &&
          other.thumbnailUrl == this.thumbnailUrl &&
          other.url == this.url &&
          other.width == this.width &&
          other.boilerHouseId == this.boilerHouseId);
}

class BoilerPhotosCompanion extends UpdateCompanion<BoilerPhotoDb> {
  final Value<int> backendId;
  final Value<DateTime?> createdAt;
  final Value<String> fileName;
  final Value<int?> fileSize;
  final Value<int?> height;
  final Value<String> id;
  final Value<String?> sha256;
  final Value<Uint8List?> thumbJPEG;
  final Value<String?> thumbnailUrl;
  final Value<String?> url;
  final Value<int?> width;
  final Value<int?> boilerHouseId;
  const BoilerPhotosCompanion({
    this.backendId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.fileName = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.height = const Value.absent(),
    this.id = const Value.absent(),
    this.sha256 = const Value.absent(),
    this.thumbJPEG = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
    this.url = const Value.absent(),
    this.width = const Value.absent(),
    this.boilerHouseId = const Value.absent(),
  });
  BoilerPhotosCompanion.insert({
    this.backendId = const Value.absent(),
    this.createdAt = const Value.absent(),
    required String fileName,
    this.fileSize = const Value.absent(),
    this.height = const Value.absent(),
    required String id,
    this.sha256 = const Value.absent(),
    this.thumbJPEG = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
    this.url = const Value.absent(),
    this.width = const Value.absent(),
    this.boilerHouseId = const Value.absent(),
  }) : fileName = Value(fileName),
       id = Value(id);
  static Insertable<BoilerPhotoDb> custom({
    Expression<int>? backendId,
    Expression<DateTime>? createdAt,
    Expression<String>? fileName,
    Expression<int>? fileSize,
    Expression<int>? height,
    Expression<String>? id,
    Expression<String>? sha256,
    Expression<Uint8List>? thumbJPEG,
    Expression<String>? thumbnailUrl,
    Expression<String>? url,
    Expression<int>? width,
    Expression<int>? boilerHouseId,
  }) {
    return RawValuesInsertable({
      if (backendId != null) 'backend_id': backendId,
      if (createdAt != null) 'created_at': createdAt,
      if (fileName != null) 'file_name': fileName,
      if (fileSize != null) 'file_size': fileSize,
      if (height != null) 'height': height,
      if (id != null) 'id': id,
      if (sha256 != null) 'sha256': sha256,
      if (thumbJPEG != null) 'thumb_j_p_e_g': thumbJPEG,
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
      if (url != null) 'url': url,
      if (width != null) 'width': width,
      if (boilerHouseId != null) 'boiler_house_id': boilerHouseId,
    });
  }

  BoilerPhotosCompanion copyWith({
    Value<int>? backendId,
    Value<DateTime?>? createdAt,
    Value<String>? fileName,
    Value<int?>? fileSize,
    Value<int?>? height,
    Value<String>? id,
    Value<String?>? sha256,
    Value<Uint8List?>? thumbJPEG,
    Value<String?>? thumbnailUrl,
    Value<String?>? url,
    Value<int?>? width,
    Value<int?>? boilerHouseId,
  }) {
    return BoilerPhotosCompanion(
      backendId: backendId ?? this.backendId,
      createdAt: createdAt ?? this.createdAt,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      height: height ?? this.height,
      id: id ?? this.id,
      sha256: sha256 ?? this.sha256,
      thumbJPEG: thumbJPEG ?? this.thumbJPEG,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      url: url ?? this.url,
      width: width ?? this.width,
      boilerHouseId: boilerHouseId ?? this.boilerHouseId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (backendId.present) {
      map['backend_id'] = Variable<int>(backendId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (fileSize.present) {
      map['file_size'] = Variable<int>(fileSize.value);
    }
    if (height.present) {
      map['height'] = Variable<int>(height.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sha256.present) {
      map['sha256'] = Variable<String>(sha256.value);
    }
    if (thumbJPEG.present) {
      map['thumb_j_p_e_g'] = Variable<Uint8List>(thumbJPEG.value);
    }
    if (thumbnailUrl.present) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (width.present) {
      map['width'] = Variable<int>(width.value);
    }
    if (boilerHouseId.present) {
      map['boiler_house_id'] = Variable<int>(boilerHouseId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BoilerPhotosCompanion(')
          ..write('backendId: $backendId, ')
          ..write('createdAt: $createdAt, ')
          ..write('fileName: $fileName, ')
          ..write('fileSize: $fileSize, ')
          ..write('height: $height, ')
          ..write('id: $id, ')
          ..write('sha256: $sha256, ')
          ..write('thumbJPEG: $thumbJPEG, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('url: $url, ')
          ..write('width: $width, ')
          ..write('boilerHouseId: $boilerHouseId')
          ..write(')'))
        .toString();
  }
}

class $ManagementCompaniesTable extends ManagementCompanies
    with TableInfo<$ManagementCompaniesTable, ManagementCompanyDb> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ManagementCompaniesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _companyUUIDMeta = const VerificationMeta(
    'companyUUID',
  );
  @override
  late final GeneratedColumn<String> companyUUID = GeneratedColumn<String>(
    'company_u_u_i_d',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _directorMeta = const VerificationMeta(
    'director',
  );
  @override
  late final GeneratedColumn<String> director = GeneratedColumn<String>(
    'director',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _normalizedNameMeta = const VerificationMeta(
    'normalizedName',
  );
  @override
  late final GeneratedColumn<String> normalizedName = GeneratedColumn<String>(
    'normalized_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    address,
    companyUUID,
    director,
    email,
    id,
    name,
    normalizedName,
    notes,
    phone,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'management_companies';
  @override
  VerificationContext validateIntegrity(
    Insertable<ManagementCompanyDb> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('company_u_u_i_d')) {
      context.handle(
        _companyUUIDMeta,
        companyUUID.isAcceptableOrUnknown(
          data['company_u_u_i_d']!,
          _companyUUIDMeta,
        ),
      );
    }
    if (data.containsKey('director')) {
      context.handle(
        _directorMeta,
        director.isAcceptableOrUnknown(data['director']!, _directorMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('normalized_name')) {
      context.handle(
        _normalizedNameMeta,
        normalizedName.isAcceptableOrUnknown(
          data['normalized_name']!,
          _normalizedNameMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ManagementCompanyDb map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ManagementCompanyDb(
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      companyUUID: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company_u_u_i_d'],
      ),
      director: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}director'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      normalizedName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_name'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
    );
  }

  @override
  $ManagementCompaniesTable createAlias(String alias) {
    return $ManagementCompaniesTable(attachedDatabase, alias);
  }
}

class ManagementCompanyDb extends DataClass
    implements Insertable<ManagementCompanyDb> {
  final String? address;
  final String? companyUUID;
  final String? director;
  final String? email;
  final String id;
  final String name;
  final String? normalizedName;
  final String? notes;
  final String? phone;
  const ManagementCompanyDb({
    this.address,
    this.companyUUID,
    this.director,
    this.email,
    required this.id,
    required this.name,
    this.normalizedName,
    this.notes,
    this.phone,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || companyUUID != null) {
      map['company_u_u_i_d'] = Variable<String>(companyUUID);
    }
    if (!nullToAbsent || director != null) {
      map['director'] = Variable<String>(director);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || normalizedName != null) {
      map['normalized_name'] = Variable<String>(normalizedName);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    return map;
  }

  ManagementCompaniesCompanion toCompanion(bool nullToAbsent) {
    return ManagementCompaniesCompanion(
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      companyUUID: companyUUID == null && nullToAbsent
          ? const Value.absent()
          : Value(companyUUID),
      director: director == null && nullToAbsent
          ? const Value.absent()
          : Value(director),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      id: Value(id),
      name: Value(name),
      normalizedName: normalizedName == null && nullToAbsent
          ? const Value.absent()
          : Value(normalizedName),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
    );
  }

  factory ManagementCompanyDb.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ManagementCompanyDb(
      address: serializer.fromJson<String?>(json['address']),
      companyUUID: serializer.fromJson<String?>(json['companyUUID']),
      director: serializer.fromJson<String?>(json['director']),
      email: serializer.fromJson<String?>(json['email']),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      normalizedName: serializer.fromJson<String?>(json['normalizedName']),
      notes: serializer.fromJson<String?>(json['notes']),
      phone: serializer.fromJson<String?>(json['phone']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'address': serializer.toJson<String?>(address),
      'companyUUID': serializer.toJson<String?>(companyUUID),
      'director': serializer.toJson<String?>(director),
      'email': serializer.toJson<String?>(email),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'normalizedName': serializer.toJson<String?>(normalizedName),
      'notes': serializer.toJson<String?>(notes),
      'phone': serializer.toJson<String?>(phone),
    };
  }

  ManagementCompanyDb copyWith({
    Value<String?> address = const Value.absent(),
    Value<String?> companyUUID = const Value.absent(),
    Value<String?> director = const Value.absent(),
    Value<String?> email = const Value.absent(),
    String? id,
    String? name,
    Value<String?> normalizedName = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<String?> phone = const Value.absent(),
  }) => ManagementCompanyDb(
    address: address.present ? address.value : this.address,
    companyUUID: companyUUID.present ? companyUUID.value : this.companyUUID,
    director: director.present ? director.value : this.director,
    email: email.present ? email.value : this.email,
    id: id ?? this.id,
    name: name ?? this.name,
    normalizedName: normalizedName.present
        ? normalizedName.value
        : this.normalizedName,
    notes: notes.present ? notes.value : this.notes,
    phone: phone.present ? phone.value : this.phone,
  );
  ManagementCompanyDb copyWithCompanion(ManagementCompaniesCompanion data) {
    return ManagementCompanyDb(
      address: data.address.present ? data.address.value : this.address,
      companyUUID: data.companyUUID.present
          ? data.companyUUID.value
          : this.companyUUID,
      director: data.director.present ? data.director.value : this.director,
      email: data.email.present ? data.email.value : this.email,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      normalizedName: data.normalizedName.present
          ? data.normalizedName.value
          : this.normalizedName,
      notes: data.notes.present ? data.notes.value : this.notes,
      phone: data.phone.present ? data.phone.value : this.phone,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ManagementCompanyDb(')
          ..write('address: $address, ')
          ..write('companyUUID: $companyUUID, ')
          ..write('director: $director, ')
          ..write('email: $email, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('notes: $notes, ')
          ..write('phone: $phone')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    address,
    companyUUID,
    director,
    email,
    id,
    name,
    normalizedName,
    notes,
    phone,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ManagementCompanyDb &&
          other.address == this.address &&
          other.companyUUID == this.companyUUID &&
          other.director == this.director &&
          other.email == this.email &&
          other.id == this.id &&
          other.name == this.name &&
          other.normalizedName == this.normalizedName &&
          other.notes == this.notes &&
          other.phone == this.phone);
}

class ManagementCompaniesCompanion
    extends UpdateCompanion<ManagementCompanyDb> {
  final Value<String?> address;
  final Value<String?> companyUUID;
  final Value<String?> director;
  final Value<String?> email;
  final Value<String> id;
  final Value<String> name;
  final Value<String?> normalizedName;
  final Value<String?> notes;
  final Value<String?> phone;
  final Value<int> rowid;
  const ManagementCompaniesCompanion({
    this.address = const Value.absent(),
    this.companyUUID = const Value.absent(),
    this.director = const Value.absent(),
    this.email = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.normalizedName = const Value.absent(),
    this.notes = const Value.absent(),
    this.phone = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ManagementCompaniesCompanion.insert({
    this.address = const Value.absent(),
    this.companyUUID = const Value.absent(),
    this.director = const Value.absent(),
    this.email = const Value.absent(),
    required String id,
    required String name,
    this.normalizedName = const Value.absent(),
    this.notes = const Value.absent(),
    this.phone = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<ManagementCompanyDb> custom({
    Expression<String>? address,
    Expression<String>? companyUUID,
    Expression<String>? director,
    Expression<String>? email,
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? normalizedName,
    Expression<String>? notes,
    Expression<String>? phone,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (address != null) 'address': address,
      if (companyUUID != null) 'company_u_u_i_d': companyUUID,
      if (director != null) 'director': director,
      if (email != null) 'email': email,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (normalizedName != null) 'normalized_name': normalizedName,
      if (notes != null) 'notes': notes,
      if (phone != null) 'phone': phone,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ManagementCompaniesCompanion copyWith({
    Value<String?>? address,
    Value<String?>? companyUUID,
    Value<String?>? director,
    Value<String?>? email,
    Value<String>? id,
    Value<String>? name,
    Value<String?>? normalizedName,
    Value<String?>? notes,
    Value<String?>? phone,
    Value<int>? rowid,
  }) {
    return ManagementCompaniesCompanion(
      address: address ?? this.address,
      companyUUID: companyUUID ?? this.companyUUID,
      director: director ?? this.director,
      email: email ?? this.email,
      id: id ?? this.id,
      name: name ?? this.name,
      normalizedName: normalizedName ?? this.normalizedName,
      notes: notes ?? this.notes,
      phone: phone ?? this.phone,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (companyUUID.present) {
      map['company_u_u_i_d'] = Variable<String>(companyUUID.value);
    }
    if (director.present) {
      map['director'] = Variable<String>(director.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (normalizedName.present) {
      map['normalized_name'] = Variable<String>(normalizedName.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ManagementCompaniesCompanion(')
          ..write('address: $address, ')
          ..write('companyUUID: $companyUUID, ')
          ..write('director: $director, ')
          ..write('email: $email, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('notes: $notes, ')
          ..write('phone: $phone, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SavedLocationsTable extends SavedLocations
    with TableInfo<$SavedLocationsTable, SavedLocationDb> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavedLocationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _accountsMeta = const VerificationMeta(
    'accounts',
  );
  @override
  late final GeneratedColumn<int> accounts = GeneratedColumn<int>(
    'accounts',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _backendIdMeta = const VerificationMeta(
    'backendId',
  );
  @override
  late final GeneratedColumn<int> backendId = GeneratedColumn<int>(
    'backend_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fiasAOGuidMeta = const VerificationMeta(
    'fiasAOGuid',
  );
  @override
  late final GeneratedColumn<String> fiasAOGuid = GeneratedColumn<String>(
    'fias_a_o_guid',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fiasHouseGuidMeta = const VerificationMeta(
    'fiasHouseGuid',
  );
  @override
  late final GeneratedColumn<String> fiasHouseGuid = GeneratedColumn<String>(
    'fias_house_guid',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _floorsMeta = const VerificationMeta('floors');
  @override
  late final GeneratedColumn<int> floors = GeneratedColumn<int>(
    'floors',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isStubMeta = const VerificationMeta('isStub');
  @override
  late final GeneratedColumn<bool> isStub = GeneratedColumn<bool>(
    'is_stub',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_stub" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _locationUUIDMeta = const VerificationMeta(
    'locationUUID',
  );
  @override
  late final GeneratedColumn<String> locationUUID = GeneratedColumn<String>(
    'location_u_u_i_d',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _managementCompanyMeta = const VerificationMeta(
    'managementCompany',
  );
  @override
  late final GeneratedColumn<String> managementCompany =
      GeneratedColumn<String>(
        'management_company',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _providesHeatingMeta = const VerificationMeta(
    'providesHeating',
  );
  @override
  late final GeneratedColumn<bool> providesHeating = GeneratedColumn<bool>(
    'provides_heating',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("provides_heating" IN (0, 1))',
    ),
  );
  static const VerificationMeta _providesHotWaterMeta = const VerificationMeta(
    'providesHotWater',
  );
  @override
  late final GeneratedColumn<bool> providesHotWater = GeneratedColumn<bool>(
    'provides_hot_water',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("provides_hot_water" IN (0, 1))',
    ),
  );
  static const VerificationMeta _residentsCountMeta = const VerificationMeta(
    'residentsCount',
  );
  @override
  late final GeneratedColumn<int> residentsCount = GeneratedColumn<int>(
    'residents_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _roomsMeta = const VerificationMeta('rooms');
  @override
  late final GeneratedColumn<int> rooms = GeneratedColumn<int>(
    'rooms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalAreaMeta = const VerificationMeta(
    'totalArea',
  );
  @override
  late final GeneratedColumn<double> totalArea = GeneratedColumn<double>(
    'total_area',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _yearBuiltMeta = const VerificationMeta(
    'yearBuilt',
  );
  @override
  late final GeneratedColumn<int> yearBuilt = GeneratedColumn<int>(
    'year_built',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _managementCompanyNameMeta =
      const VerificationMeta('managementCompanyName');
  @override
  late final GeneratedColumn<String> managementCompanyName =
      GeneratedColumn<String>(
        'management_company_name',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _boilerHouseIdMeta = const VerificationMeta(
    'boilerHouseId',
  );
  @override
  late final GeneratedColumn<int> boilerHouseId = GeneratedColumn<int>(
    'boiler_house_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES boiler_houses (backend_id)',
    ),
  );
  static const VerificationMeta _managementCompanyRefIdMeta =
      const VerificationMeta('managementCompanyRefId');
  @override
  late final GeneratedColumn<String> managementCompanyRefId =
      GeneratedColumn<String>(
        'management_company_ref_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES management_companies (id)',
        ),
      );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    accounts,
    backendId,
    fiasAOGuid,
    fiasHouseGuid,
    floors,
    isStub,
    latitude,
    locationUUID,
    longitude,
    managementCompany,
    name,
    providesHeating,
    providesHotWater,
    residentsCount,
    rooms,
    totalArea,
    updatedAt,
    yearBuilt,
    managementCompanyName,
    boilerHouseId,
    managementCompanyRefId,
    id,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'saved_locations';
  @override
  VerificationContext validateIntegrity(
    Insertable<SavedLocationDb> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('accounts')) {
      context.handle(
        _accountsMeta,
        accounts.isAcceptableOrUnknown(data['accounts']!, _accountsMeta),
      );
    }
    if (data.containsKey('backend_id')) {
      context.handle(
        _backendIdMeta,
        backendId.isAcceptableOrUnknown(data['backend_id']!, _backendIdMeta),
      );
    }
    if (data.containsKey('fias_a_o_guid')) {
      context.handle(
        _fiasAOGuidMeta,
        fiasAOGuid.isAcceptableOrUnknown(
          data['fias_a_o_guid']!,
          _fiasAOGuidMeta,
        ),
      );
    }
    if (data.containsKey('fias_house_guid')) {
      context.handle(
        _fiasHouseGuidMeta,
        fiasHouseGuid.isAcceptableOrUnknown(
          data['fias_house_guid']!,
          _fiasHouseGuidMeta,
        ),
      );
    }
    if (data.containsKey('floors')) {
      context.handle(
        _floorsMeta,
        floors.isAcceptableOrUnknown(data['floors']!, _floorsMeta),
      );
    }
    if (data.containsKey('is_stub')) {
      context.handle(
        _isStubMeta,
        isStub.isAcceptableOrUnknown(data['is_stub']!, _isStubMeta),
      );
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('location_u_u_i_d')) {
      context.handle(
        _locationUUIDMeta,
        locationUUID.isAcceptableOrUnknown(
          data['location_u_u_i_d']!,
          _locationUUIDMeta,
        ),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    if (data.containsKey('management_company')) {
      context.handle(
        _managementCompanyMeta,
        managementCompany.isAcceptableOrUnknown(
          data['management_company']!,
          _managementCompanyMeta,
        ),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('provides_heating')) {
      context.handle(
        _providesHeatingMeta,
        providesHeating.isAcceptableOrUnknown(
          data['provides_heating']!,
          _providesHeatingMeta,
        ),
      );
    }
    if (data.containsKey('provides_hot_water')) {
      context.handle(
        _providesHotWaterMeta,
        providesHotWater.isAcceptableOrUnknown(
          data['provides_hot_water']!,
          _providesHotWaterMeta,
        ),
      );
    }
    if (data.containsKey('residents_count')) {
      context.handle(
        _residentsCountMeta,
        residentsCount.isAcceptableOrUnknown(
          data['residents_count']!,
          _residentsCountMeta,
        ),
      );
    }
    if (data.containsKey('rooms')) {
      context.handle(
        _roomsMeta,
        rooms.isAcceptableOrUnknown(data['rooms']!, _roomsMeta),
      );
    }
    if (data.containsKey('total_area')) {
      context.handle(
        _totalAreaMeta,
        totalArea.isAcceptableOrUnknown(data['total_area']!, _totalAreaMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('year_built')) {
      context.handle(
        _yearBuiltMeta,
        yearBuilt.isAcceptableOrUnknown(data['year_built']!, _yearBuiltMeta),
      );
    }
    if (data.containsKey('management_company_name')) {
      context.handle(
        _managementCompanyNameMeta,
        managementCompanyName.isAcceptableOrUnknown(
          data['management_company_name']!,
          _managementCompanyNameMeta,
        ),
      );
    }
    if (data.containsKey('boiler_house_id')) {
      context.handle(
        _boilerHouseIdMeta,
        boilerHouseId.isAcceptableOrUnknown(
          data['boiler_house_id']!,
          _boilerHouseIdMeta,
        ),
      );
    }
    if (data.containsKey('management_company_ref_id')) {
      context.handle(
        _managementCompanyRefIdMeta,
        managementCompanyRefId.isAcceptableOrUnknown(
          data['management_company_ref_id']!,
          _managementCompanyRefIdMeta,
        ),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SavedLocationDb map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavedLocationDb(
      accounts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}accounts'],
      ),
      backendId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}backend_id'],
      ),
      fiasAOGuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fias_a_o_guid'],
      ),
      fiasHouseGuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fias_house_guid'],
      ),
      floors: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}floors'],
      ),
      isStub: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_stub'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      locationUUID: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location_u_u_i_d'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
      managementCompany: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}management_company'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      providesHeating: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}provides_heating'],
      ),
      providesHotWater: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}provides_hot_water'],
      ),
      residentsCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}residents_count'],
      ),
      rooms: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rooms'],
      ),
      totalArea: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_area'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      yearBuilt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year_built'],
      ),
      managementCompanyName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}management_company_name'],
      ),
      boilerHouseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}boiler_house_id'],
      ),
      managementCompanyRefId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}management_company_ref_id'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
    );
  }

  @override
  $SavedLocationsTable createAlias(String alias) {
    return $SavedLocationsTable(attachedDatabase, alias);
  }
}

class SavedLocationDb extends DataClass implements Insertable<SavedLocationDb> {
  final int? accounts;
  final int? backendId;
  final String? fiasAOGuid;
  final String? fiasHouseGuid;
  final int? floors;
  final bool isStub;
  final double? latitude;
  final String? locationUUID;
  final double? longitude;
  final String? managementCompany;
  final String? name;
  final bool? providesHeating;
  final bool? providesHotWater;
  final int? residentsCount;
  final int? rooms;
  final double? totalArea;
  final DateTime? updatedAt;
  final int? yearBuilt;
  final String? managementCompanyName;
  final int? boilerHouseId;
  final String? managementCompanyRefId;
  final int id;
  const SavedLocationDb({
    this.accounts,
    this.backendId,
    this.fiasAOGuid,
    this.fiasHouseGuid,
    this.floors,
    required this.isStub,
    this.latitude,
    this.locationUUID,
    this.longitude,
    this.managementCompany,
    this.name,
    this.providesHeating,
    this.providesHotWater,
    this.residentsCount,
    this.rooms,
    this.totalArea,
    this.updatedAt,
    this.yearBuilt,
    this.managementCompanyName,
    this.boilerHouseId,
    this.managementCompanyRefId,
    required this.id,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || accounts != null) {
      map['accounts'] = Variable<int>(accounts);
    }
    if (!nullToAbsent || backendId != null) {
      map['backend_id'] = Variable<int>(backendId);
    }
    if (!nullToAbsent || fiasAOGuid != null) {
      map['fias_a_o_guid'] = Variable<String>(fiasAOGuid);
    }
    if (!nullToAbsent || fiasHouseGuid != null) {
      map['fias_house_guid'] = Variable<String>(fiasHouseGuid);
    }
    if (!nullToAbsent || floors != null) {
      map['floors'] = Variable<int>(floors);
    }
    map['is_stub'] = Variable<bool>(isStub);
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || locationUUID != null) {
      map['location_u_u_i_d'] = Variable<String>(locationUUID);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    if (!nullToAbsent || managementCompany != null) {
      map['management_company'] = Variable<String>(managementCompany);
    }
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || providesHeating != null) {
      map['provides_heating'] = Variable<bool>(providesHeating);
    }
    if (!nullToAbsent || providesHotWater != null) {
      map['provides_hot_water'] = Variable<bool>(providesHotWater);
    }
    if (!nullToAbsent || residentsCount != null) {
      map['residents_count'] = Variable<int>(residentsCount);
    }
    if (!nullToAbsent || rooms != null) {
      map['rooms'] = Variable<int>(rooms);
    }
    if (!nullToAbsent || totalArea != null) {
      map['total_area'] = Variable<double>(totalArea);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || yearBuilt != null) {
      map['year_built'] = Variable<int>(yearBuilt);
    }
    if (!nullToAbsent || managementCompanyName != null) {
      map['management_company_name'] = Variable<String>(managementCompanyName);
    }
    if (!nullToAbsent || boilerHouseId != null) {
      map['boiler_house_id'] = Variable<int>(boilerHouseId);
    }
    if (!nullToAbsent || managementCompanyRefId != null) {
      map['management_company_ref_id'] = Variable<String>(
        managementCompanyRefId,
      );
    }
    map['id'] = Variable<int>(id);
    return map;
  }

  SavedLocationsCompanion toCompanion(bool nullToAbsent) {
    return SavedLocationsCompanion(
      accounts: accounts == null && nullToAbsent
          ? const Value.absent()
          : Value(accounts),
      backendId: backendId == null && nullToAbsent
          ? const Value.absent()
          : Value(backendId),
      fiasAOGuid: fiasAOGuid == null && nullToAbsent
          ? const Value.absent()
          : Value(fiasAOGuid),
      fiasHouseGuid: fiasHouseGuid == null && nullToAbsent
          ? const Value.absent()
          : Value(fiasHouseGuid),
      floors: floors == null && nullToAbsent
          ? const Value.absent()
          : Value(floors),
      isStub: Value(isStub),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      locationUUID: locationUUID == null && nullToAbsent
          ? const Value.absent()
          : Value(locationUUID),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      managementCompany: managementCompany == null && nullToAbsent
          ? const Value.absent()
          : Value(managementCompany),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      providesHeating: providesHeating == null && nullToAbsent
          ? const Value.absent()
          : Value(providesHeating),
      providesHotWater: providesHotWater == null && nullToAbsent
          ? const Value.absent()
          : Value(providesHotWater),
      residentsCount: residentsCount == null && nullToAbsent
          ? const Value.absent()
          : Value(residentsCount),
      rooms: rooms == null && nullToAbsent
          ? const Value.absent()
          : Value(rooms),
      totalArea: totalArea == null && nullToAbsent
          ? const Value.absent()
          : Value(totalArea),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      yearBuilt: yearBuilt == null && nullToAbsent
          ? const Value.absent()
          : Value(yearBuilt),
      managementCompanyName: managementCompanyName == null && nullToAbsent
          ? const Value.absent()
          : Value(managementCompanyName),
      boilerHouseId: boilerHouseId == null && nullToAbsent
          ? const Value.absent()
          : Value(boilerHouseId),
      managementCompanyRefId: managementCompanyRefId == null && nullToAbsent
          ? const Value.absent()
          : Value(managementCompanyRefId),
      id: Value(id),
    );
  }

  factory SavedLocationDb.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavedLocationDb(
      accounts: serializer.fromJson<int?>(json['accounts']),
      backendId: serializer.fromJson<int?>(json['backendId']),
      fiasAOGuid: serializer.fromJson<String?>(json['fiasAOGuid']),
      fiasHouseGuid: serializer.fromJson<String?>(json['fiasHouseGuid']),
      floors: serializer.fromJson<int?>(json['floors']),
      isStub: serializer.fromJson<bool>(json['isStub']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      locationUUID: serializer.fromJson<String?>(json['locationUUID']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      managementCompany: serializer.fromJson<String?>(
        json['managementCompany'],
      ),
      name: serializer.fromJson<String?>(json['name']),
      providesHeating: serializer.fromJson<bool?>(json['providesHeating']),
      providesHotWater: serializer.fromJson<bool?>(json['providesHotWater']),
      residentsCount: serializer.fromJson<int?>(json['residentsCount']),
      rooms: serializer.fromJson<int?>(json['rooms']),
      totalArea: serializer.fromJson<double?>(json['totalArea']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      yearBuilt: serializer.fromJson<int?>(json['yearBuilt']),
      managementCompanyName: serializer.fromJson<String?>(
        json['managementCompanyName'],
      ),
      boilerHouseId: serializer.fromJson<int?>(json['boilerHouseId']),
      managementCompanyRefId: serializer.fromJson<String?>(
        json['managementCompanyRefId'],
      ),
      id: serializer.fromJson<int>(json['id']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'accounts': serializer.toJson<int?>(accounts),
      'backendId': serializer.toJson<int?>(backendId),
      'fiasAOGuid': serializer.toJson<String?>(fiasAOGuid),
      'fiasHouseGuid': serializer.toJson<String?>(fiasHouseGuid),
      'floors': serializer.toJson<int?>(floors),
      'isStub': serializer.toJson<bool>(isStub),
      'latitude': serializer.toJson<double?>(latitude),
      'locationUUID': serializer.toJson<String?>(locationUUID),
      'longitude': serializer.toJson<double?>(longitude),
      'managementCompany': serializer.toJson<String?>(managementCompany),
      'name': serializer.toJson<String?>(name),
      'providesHeating': serializer.toJson<bool?>(providesHeating),
      'providesHotWater': serializer.toJson<bool?>(providesHotWater),
      'residentsCount': serializer.toJson<int?>(residentsCount),
      'rooms': serializer.toJson<int?>(rooms),
      'totalArea': serializer.toJson<double?>(totalArea),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'yearBuilt': serializer.toJson<int?>(yearBuilt),
      'managementCompanyName': serializer.toJson<String?>(
        managementCompanyName,
      ),
      'boilerHouseId': serializer.toJson<int?>(boilerHouseId),
      'managementCompanyRefId': serializer.toJson<String?>(
        managementCompanyRefId,
      ),
      'id': serializer.toJson<int>(id),
    };
  }

  SavedLocationDb copyWith({
    Value<int?> accounts = const Value.absent(),
    Value<int?> backendId = const Value.absent(),
    Value<String?> fiasAOGuid = const Value.absent(),
    Value<String?> fiasHouseGuid = const Value.absent(),
    Value<int?> floors = const Value.absent(),
    bool? isStub,
    Value<double?> latitude = const Value.absent(),
    Value<String?> locationUUID = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
    Value<String?> managementCompany = const Value.absent(),
    Value<String?> name = const Value.absent(),
    Value<bool?> providesHeating = const Value.absent(),
    Value<bool?> providesHotWater = const Value.absent(),
    Value<int?> residentsCount = const Value.absent(),
    Value<int?> rooms = const Value.absent(),
    Value<double?> totalArea = const Value.absent(),
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<int?> yearBuilt = const Value.absent(),
    Value<String?> managementCompanyName = const Value.absent(),
    Value<int?> boilerHouseId = const Value.absent(),
    Value<String?> managementCompanyRefId = const Value.absent(),
    int? id,
  }) => SavedLocationDb(
    accounts: accounts.present ? accounts.value : this.accounts,
    backendId: backendId.present ? backendId.value : this.backendId,
    fiasAOGuid: fiasAOGuid.present ? fiasAOGuid.value : this.fiasAOGuid,
    fiasHouseGuid: fiasHouseGuid.present
        ? fiasHouseGuid.value
        : this.fiasHouseGuid,
    floors: floors.present ? floors.value : this.floors,
    isStub: isStub ?? this.isStub,
    latitude: latitude.present ? latitude.value : this.latitude,
    locationUUID: locationUUID.present ? locationUUID.value : this.locationUUID,
    longitude: longitude.present ? longitude.value : this.longitude,
    managementCompany: managementCompany.present
        ? managementCompany.value
        : this.managementCompany,
    name: name.present ? name.value : this.name,
    providesHeating: providesHeating.present
        ? providesHeating.value
        : this.providesHeating,
    providesHotWater: providesHotWater.present
        ? providesHotWater.value
        : this.providesHotWater,
    residentsCount: residentsCount.present
        ? residentsCount.value
        : this.residentsCount,
    rooms: rooms.present ? rooms.value : this.rooms,
    totalArea: totalArea.present ? totalArea.value : this.totalArea,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    yearBuilt: yearBuilt.present ? yearBuilt.value : this.yearBuilt,
    managementCompanyName: managementCompanyName.present
        ? managementCompanyName.value
        : this.managementCompanyName,
    boilerHouseId: boilerHouseId.present
        ? boilerHouseId.value
        : this.boilerHouseId,
    managementCompanyRefId: managementCompanyRefId.present
        ? managementCompanyRefId.value
        : this.managementCompanyRefId,
    id: id ?? this.id,
  );
  SavedLocationDb copyWithCompanion(SavedLocationsCompanion data) {
    return SavedLocationDb(
      accounts: data.accounts.present ? data.accounts.value : this.accounts,
      backendId: data.backendId.present ? data.backendId.value : this.backendId,
      fiasAOGuid: data.fiasAOGuid.present
          ? data.fiasAOGuid.value
          : this.fiasAOGuid,
      fiasHouseGuid: data.fiasHouseGuid.present
          ? data.fiasHouseGuid.value
          : this.fiasHouseGuid,
      floors: data.floors.present ? data.floors.value : this.floors,
      isStub: data.isStub.present ? data.isStub.value : this.isStub,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      locationUUID: data.locationUUID.present
          ? data.locationUUID.value
          : this.locationUUID,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      managementCompany: data.managementCompany.present
          ? data.managementCompany.value
          : this.managementCompany,
      name: data.name.present ? data.name.value : this.name,
      providesHeating: data.providesHeating.present
          ? data.providesHeating.value
          : this.providesHeating,
      providesHotWater: data.providesHotWater.present
          ? data.providesHotWater.value
          : this.providesHotWater,
      residentsCount: data.residentsCount.present
          ? data.residentsCount.value
          : this.residentsCount,
      rooms: data.rooms.present ? data.rooms.value : this.rooms,
      totalArea: data.totalArea.present ? data.totalArea.value : this.totalArea,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      yearBuilt: data.yearBuilt.present ? data.yearBuilt.value : this.yearBuilt,
      managementCompanyName: data.managementCompanyName.present
          ? data.managementCompanyName.value
          : this.managementCompanyName,
      boilerHouseId: data.boilerHouseId.present
          ? data.boilerHouseId.value
          : this.boilerHouseId,
      managementCompanyRefId: data.managementCompanyRefId.present
          ? data.managementCompanyRefId.value
          : this.managementCompanyRefId,
      id: data.id.present ? data.id.value : this.id,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavedLocationDb(')
          ..write('accounts: $accounts, ')
          ..write('backendId: $backendId, ')
          ..write('fiasAOGuid: $fiasAOGuid, ')
          ..write('fiasHouseGuid: $fiasHouseGuid, ')
          ..write('floors: $floors, ')
          ..write('isStub: $isStub, ')
          ..write('latitude: $latitude, ')
          ..write('locationUUID: $locationUUID, ')
          ..write('longitude: $longitude, ')
          ..write('managementCompany: $managementCompany, ')
          ..write('name: $name, ')
          ..write('providesHeating: $providesHeating, ')
          ..write('providesHotWater: $providesHotWater, ')
          ..write('residentsCount: $residentsCount, ')
          ..write('rooms: $rooms, ')
          ..write('totalArea: $totalArea, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('yearBuilt: $yearBuilt, ')
          ..write('managementCompanyName: $managementCompanyName, ')
          ..write('boilerHouseId: $boilerHouseId, ')
          ..write('managementCompanyRefId: $managementCompanyRefId, ')
          ..write('id: $id')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    accounts,
    backendId,
    fiasAOGuid,
    fiasHouseGuid,
    floors,
    isStub,
    latitude,
    locationUUID,
    longitude,
    managementCompany,
    name,
    providesHeating,
    providesHotWater,
    residentsCount,
    rooms,
    totalArea,
    updatedAt,
    yearBuilt,
    managementCompanyName,
    boilerHouseId,
    managementCompanyRefId,
    id,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavedLocationDb &&
          other.accounts == this.accounts &&
          other.backendId == this.backendId &&
          other.fiasAOGuid == this.fiasAOGuid &&
          other.fiasHouseGuid == this.fiasHouseGuid &&
          other.floors == this.floors &&
          other.isStub == this.isStub &&
          other.latitude == this.latitude &&
          other.locationUUID == this.locationUUID &&
          other.longitude == this.longitude &&
          other.managementCompany == this.managementCompany &&
          other.name == this.name &&
          other.providesHeating == this.providesHeating &&
          other.providesHotWater == this.providesHotWater &&
          other.residentsCount == this.residentsCount &&
          other.rooms == this.rooms &&
          other.totalArea == this.totalArea &&
          other.updatedAt == this.updatedAt &&
          other.yearBuilt == this.yearBuilt &&
          other.managementCompanyName == this.managementCompanyName &&
          other.boilerHouseId == this.boilerHouseId &&
          other.managementCompanyRefId == this.managementCompanyRefId &&
          other.id == this.id);
}

class SavedLocationsCompanion extends UpdateCompanion<SavedLocationDb> {
  final Value<int?> accounts;
  final Value<int?> backendId;
  final Value<String?> fiasAOGuid;
  final Value<String?> fiasHouseGuid;
  final Value<int?> floors;
  final Value<bool> isStub;
  final Value<double?> latitude;
  final Value<String?> locationUUID;
  final Value<double?> longitude;
  final Value<String?> managementCompany;
  final Value<String?> name;
  final Value<bool?> providesHeating;
  final Value<bool?> providesHotWater;
  final Value<int?> residentsCount;
  final Value<int?> rooms;
  final Value<double?> totalArea;
  final Value<DateTime?> updatedAt;
  final Value<int?> yearBuilt;
  final Value<String?> managementCompanyName;
  final Value<int?> boilerHouseId;
  final Value<String?> managementCompanyRefId;
  final Value<int> id;
  const SavedLocationsCompanion({
    this.accounts = const Value.absent(),
    this.backendId = const Value.absent(),
    this.fiasAOGuid = const Value.absent(),
    this.fiasHouseGuid = const Value.absent(),
    this.floors = const Value.absent(),
    this.isStub = const Value.absent(),
    this.latitude = const Value.absent(),
    this.locationUUID = const Value.absent(),
    this.longitude = const Value.absent(),
    this.managementCompany = const Value.absent(),
    this.name = const Value.absent(),
    this.providesHeating = const Value.absent(),
    this.providesHotWater = const Value.absent(),
    this.residentsCount = const Value.absent(),
    this.rooms = const Value.absent(),
    this.totalArea = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.yearBuilt = const Value.absent(),
    this.managementCompanyName = const Value.absent(),
    this.boilerHouseId = const Value.absent(),
    this.managementCompanyRefId = const Value.absent(),
    this.id = const Value.absent(),
  });
  SavedLocationsCompanion.insert({
    this.accounts = const Value.absent(),
    this.backendId = const Value.absent(),
    this.fiasAOGuid = const Value.absent(),
    this.fiasHouseGuid = const Value.absent(),
    this.floors = const Value.absent(),
    this.isStub = const Value.absent(),
    this.latitude = const Value.absent(),
    this.locationUUID = const Value.absent(),
    this.longitude = const Value.absent(),
    this.managementCompany = const Value.absent(),
    this.name = const Value.absent(),
    this.providesHeating = const Value.absent(),
    this.providesHotWater = const Value.absent(),
    this.residentsCount = const Value.absent(),
    this.rooms = const Value.absent(),
    this.totalArea = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.yearBuilt = const Value.absent(),
    this.managementCompanyName = const Value.absent(),
    this.boilerHouseId = const Value.absent(),
    this.managementCompanyRefId = const Value.absent(),
    this.id = const Value.absent(),
  });
  static Insertable<SavedLocationDb> custom({
    Expression<int>? accounts,
    Expression<int>? backendId,
    Expression<String>? fiasAOGuid,
    Expression<String>? fiasHouseGuid,
    Expression<int>? floors,
    Expression<bool>? isStub,
    Expression<double>? latitude,
    Expression<String>? locationUUID,
    Expression<double>? longitude,
    Expression<String>? managementCompany,
    Expression<String>? name,
    Expression<bool>? providesHeating,
    Expression<bool>? providesHotWater,
    Expression<int>? residentsCount,
    Expression<int>? rooms,
    Expression<double>? totalArea,
    Expression<DateTime>? updatedAt,
    Expression<int>? yearBuilt,
    Expression<String>? managementCompanyName,
    Expression<int>? boilerHouseId,
    Expression<String>? managementCompanyRefId,
    Expression<int>? id,
  }) {
    return RawValuesInsertable({
      if (accounts != null) 'accounts': accounts,
      if (backendId != null) 'backend_id': backendId,
      if (fiasAOGuid != null) 'fias_a_o_guid': fiasAOGuid,
      if (fiasHouseGuid != null) 'fias_house_guid': fiasHouseGuid,
      if (floors != null) 'floors': floors,
      if (isStub != null) 'is_stub': isStub,
      if (latitude != null) 'latitude': latitude,
      if (locationUUID != null) 'location_u_u_i_d': locationUUID,
      if (longitude != null) 'longitude': longitude,
      if (managementCompany != null) 'management_company': managementCompany,
      if (name != null) 'name': name,
      if (providesHeating != null) 'provides_heating': providesHeating,
      if (providesHotWater != null) 'provides_hot_water': providesHotWater,
      if (residentsCount != null) 'residents_count': residentsCount,
      if (rooms != null) 'rooms': rooms,
      if (totalArea != null) 'total_area': totalArea,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (yearBuilt != null) 'year_built': yearBuilt,
      if (managementCompanyName != null)
        'management_company_name': managementCompanyName,
      if (boilerHouseId != null) 'boiler_house_id': boilerHouseId,
      if (managementCompanyRefId != null)
        'management_company_ref_id': managementCompanyRefId,
      if (id != null) 'id': id,
    });
  }

  SavedLocationsCompanion copyWith({
    Value<int?>? accounts,
    Value<int?>? backendId,
    Value<String?>? fiasAOGuid,
    Value<String?>? fiasHouseGuid,
    Value<int?>? floors,
    Value<bool>? isStub,
    Value<double?>? latitude,
    Value<String?>? locationUUID,
    Value<double?>? longitude,
    Value<String?>? managementCompany,
    Value<String?>? name,
    Value<bool?>? providesHeating,
    Value<bool?>? providesHotWater,
    Value<int?>? residentsCount,
    Value<int?>? rooms,
    Value<double?>? totalArea,
    Value<DateTime?>? updatedAt,
    Value<int?>? yearBuilt,
    Value<String?>? managementCompanyName,
    Value<int?>? boilerHouseId,
    Value<String?>? managementCompanyRefId,
    Value<int>? id,
  }) {
    return SavedLocationsCompanion(
      accounts: accounts ?? this.accounts,
      backendId: backendId ?? this.backendId,
      fiasAOGuid: fiasAOGuid ?? this.fiasAOGuid,
      fiasHouseGuid: fiasHouseGuid ?? this.fiasHouseGuid,
      floors: floors ?? this.floors,
      isStub: isStub ?? this.isStub,
      latitude: latitude ?? this.latitude,
      locationUUID: locationUUID ?? this.locationUUID,
      longitude: longitude ?? this.longitude,
      managementCompany: managementCompany ?? this.managementCompany,
      name: name ?? this.name,
      providesHeating: providesHeating ?? this.providesHeating,
      providesHotWater: providesHotWater ?? this.providesHotWater,
      residentsCount: residentsCount ?? this.residentsCount,
      rooms: rooms ?? this.rooms,
      totalArea: totalArea ?? this.totalArea,
      updatedAt: updatedAt ?? this.updatedAt,
      yearBuilt: yearBuilt ?? this.yearBuilt,
      managementCompanyName:
          managementCompanyName ?? this.managementCompanyName,
      boilerHouseId: boilerHouseId ?? this.boilerHouseId,
      managementCompanyRefId:
          managementCompanyRefId ?? this.managementCompanyRefId,
      id: id ?? this.id,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (accounts.present) {
      map['accounts'] = Variable<int>(accounts.value);
    }
    if (backendId.present) {
      map['backend_id'] = Variable<int>(backendId.value);
    }
    if (fiasAOGuid.present) {
      map['fias_a_o_guid'] = Variable<String>(fiasAOGuid.value);
    }
    if (fiasHouseGuid.present) {
      map['fias_house_guid'] = Variable<String>(fiasHouseGuid.value);
    }
    if (floors.present) {
      map['floors'] = Variable<int>(floors.value);
    }
    if (isStub.present) {
      map['is_stub'] = Variable<bool>(isStub.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (locationUUID.present) {
      map['location_u_u_i_d'] = Variable<String>(locationUUID.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (managementCompany.present) {
      map['management_company'] = Variable<String>(managementCompany.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (providesHeating.present) {
      map['provides_heating'] = Variable<bool>(providesHeating.value);
    }
    if (providesHotWater.present) {
      map['provides_hot_water'] = Variable<bool>(providesHotWater.value);
    }
    if (residentsCount.present) {
      map['residents_count'] = Variable<int>(residentsCount.value);
    }
    if (rooms.present) {
      map['rooms'] = Variable<int>(rooms.value);
    }
    if (totalArea.present) {
      map['total_area'] = Variable<double>(totalArea.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (yearBuilt.present) {
      map['year_built'] = Variable<int>(yearBuilt.value);
    }
    if (managementCompanyName.present) {
      map['management_company_name'] = Variable<String>(
        managementCompanyName.value,
      );
    }
    if (boilerHouseId.present) {
      map['boiler_house_id'] = Variable<int>(boilerHouseId.value);
    }
    if (managementCompanyRefId.present) {
      map['management_company_ref_id'] = Variable<String>(
        managementCompanyRefId.value,
      );
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavedLocationsCompanion(')
          ..write('accounts: $accounts, ')
          ..write('backendId: $backendId, ')
          ..write('fiasAOGuid: $fiasAOGuid, ')
          ..write('fiasHouseGuid: $fiasHouseGuid, ')
          ..write('floors: $floors, ')
          ..write('isStub: $isStub, ')
          ..write('latitude: $latitude, ')
          ..write('locationUUID: $locationUUID, ')
          ..write('longitude: $longitude, ')
          ..write('managementCompany: $managementCompany, ')
          ..write('name: $name, ')
          ..write('providesHeating: $providesHeating, ')
          ..write('providesHotWater: $providesHotWater, ')
          ..write('residentsCount: $residentsCount, ')
          ..write('rooms: $rooms, ')
          ..write('totalArea: $totalArea, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('yearBuilt: $yearBuilt, ')
          ..write('managementCompanyName: $managementCompanyName, ')
          ..write('boilerHouseId: $boilerHouseId, ')
          ..write('managementCompanyRefId: $managementCompanyRefId, ')
          ..write('id: $id')
          ..write(')'))
        .toString();
  }
}

class $HousePhotosTable extends HousePhotos
    with TableInfo<$HousePhotosTable, HousePhotoDb> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HousePhotosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _backendIdMeta = const VerificationMeta(
    'backendId',
  );
  @override
  late final GeneratedColumn<int> backendId = GeneratedColumn<int>(
    'backend_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileSizeMeta = const VerificationMeta(
    'fileSize',
  );
  @override
  late final GeneratedColumn<int> fileSize = GeneratedColumn<int>(
    'file_size',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<int> height = GeneratedColumn<int>(
    'height',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sha256Meta = const VerificationMeta('sha256');
  @override
  late final GeneratedColumn<String> sha256 = GeneratedColumn<String>(
    'sha256',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _thumbJPEGMeta = const VerificationMeta(
    'thumbJPEG',
  );
  @override
  late final GeneratedColumn<Uint8List> thumbJPEG = GeneratedColumn<Uint8List>(
    'thumb_j_p_e_g',
    aliasedName,
    true,
    type: DriftSqlType.blob,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _thumbnailUrlMeta = const VerificationMeta(
    'thumbnailUrl',
  );
  @override
  late final GeneratedColumn<String> thumbnailUrl = GeneratedColumn<String>(
    'thumbnail_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<int> width = GeneratedColumn<int>(
    'width',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _houseIdMeta = const VerificationMeta(
    'houseId',
  );
  @override
  late final GeneratedColumn<int> houseId = GeneratedColumn<int>(
    'house_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES saved_locations (backend_id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    backendId,
    createdAt,
    fileName,
    fileSize,
    height,
    id,
    sha256,
    thumbJPEG,
    thumbnailUrl,
    url,
    width,
    houseId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'house_photos';
  @override
  VerificationContext validateIntegrity(
    Insertable<HousePhotoDb> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('backend_id')) {
      context.handle(
        _backendIdMeta,
        backendId.isAcceptableOrUnknown(data['backend_id']!, _backendIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('file_size')) {
      context.handle(
        _fileSizeMeta,
        fileSize.isAcceptableOrUnknown(data['file_size']!, _fileSizeMeta),
      );
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('sha256')) {
      context.handle(
        _sha256Meta,
        sha256.isAcceptableOrUnknown(data['sha256']!, _sha256Meta),
      );
    } else if (isInserting) {
      context.missing(_sha256Meta);
    }
    if (data.containsKey('thumb_j_p_e_g')) {
      context.handle(
        _thumbJPEGMeta,
        thumbJPEG.isAcceptableOrUnknown(data['thumb_j_p_e_g']!, _thumbJPEGMeta),
      );
    }
    if (data.containsKey('thumbnail_url')) {
      context.handle(
        _thumbnailUrlMeta,
        thumbnailUrl.isAcceptableOrUnknown(
          data['thumbnail_url']!,
          _thumbnailUrlMeta,
        ),
      );
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    }
    if (data.containsKey('width')) {
      context.handle(
        _widthMeta,
        width.isAcceptableOrUnknown(data['width']!, _widthMeta),
      );
    }
    if (data.containsKey('house_id')) {
      context.handle(
        _houseIdMeta,
        houseId.isAcceptableOrUnknown(data['house_id']!, _houseIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {backendId};
  @override
  HousePhotoDb map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HousePhotoDb(
      backendId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}backend_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      fileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_name'],
      )!,
      fileSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}file_size'],
      ),
      height: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}height'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sha256'],
      )!,
      thumbJPEG: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}thumb_j_p_e_g'],
      ),
      thumbnailUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail_url'],
      ),
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      ),
      width: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}width'],
      ),
      houseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}house_id'],
      ),
    );
  }

  @override
  $HousePhotosTable createAlias(String alias) {
    return $HousePhotosTable(attachedDatabase, alias);
  }
}

class HousePhotoDb extends DataClass implements Insertable<HousePhotoDb> {
  final int backendId;
  final DateTime createdAt;
  final String fileName;
  final int? fileSize;
  final int? height;
  final String id;
  final String sha256;
  final Uint8List? thumbJPEG;
  final String? thumbnailUrl;
  final String? url;
  final int? width;
  final int? houseId;
  const HousePhotoDb({
    required this.backendId,
    required this.createdAt,
    required this.fileName,
    this.fileSize,
    this.height,
    required this.id,
    required this.sha256,
    this.thumbJPEG,
    this.thumbnailUrl,
    this.url,
    this.width,
    this.houseId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['backend_id'] = Variable<int>(backendId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['file_name'] = Variable<String>(fileName);
    if (!nullToAbsent || fileSize != null) {
      map['file_size'] = Variable<int>(fileSize);
    }
    if (!nullToAbsent || height != null) {
      map['height'] = Variable<int>(height);
    }
    map['id'] = Variable<String>(id);
    map['sha256'] = Variable<String>(sha256);
    if (!nullToAbsent || thumbJPEG != null) {
      map['thumb_j_p_e_g'] = Variable<Uint8List>(thumbJPEG);
    }
    if (!nullToAbsent || thumbnailUrl != null) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl);
    }
    if (!nullToAbsent || url != null) {
      map['url'] = Variable<String>(url);
    }
    if (!nullToAbsent || width != null) {
      map['width'] = Variable<int>(width);
    }
    if (!nullToAbsent || houseId != null) {
      map['house_id'] = Variable<int>(houseId);
    }
    return map;
  }

  HousePhotosCompanion toCompanion(bool nullToAbsent) {
    return HousePhotosCompanion(
      backendId: Value(backendId),
      createdAt: Value(createdAt),
      fileName: Value(fileName),
      fileSize: fileSize == null && nullToAbsent
          ? const Value.absent()
          : Value(fileSize),
      height: height == null && nullToAbsent
          ? const Value.absent()
          : Value(height),
      id: Value(id),
      sha256: Value(sha256),
      thumbJPEG: thumbJPEG == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbJPEG),
      thumbnailUrl: thumbnailUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailUrl),
      url: url == null && nullToAbsent ? const Value.absent() : Value(url),
      width: width == null && nullToAbsent
          ? const Value.absent()
          : Value(width),
      houseId: houseId == null && nullToAbsent
          ? const Value.absent()
          : Value(houseId),
    );
  }

  factory HousePhotoDb.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HousePhotoDb(
      backendId: serializer.fromJson<int>(json['backendId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      fileName: serializer.fromJson<String>(json['fileName']),
      fileSize: serializer.fromJson<int?>(json['fileSize']),
      height: serializer.fromJson<int?>(json['height']),
      id: serializer.fromJson<String>(json['id']),
      sha256: serializer.fromJson<String>(json['sha256']),
      thumbJPEG: serializer.fromJson<Uint8List?>(json['thumbJPEG']),
      thumbnailUrl: serializer.fromJson<String?>(json['thumbnailUrl']),
      url: serializer.fromJson<String?>(json['url']),
      width: serializer.fromJson<int?>(json['width']),
      houseId: serializer.fromJson<int?>(json['houseId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'backendId': serializer.toJson<int>(backendId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'fileName': serializer.toJson<String>(fileName),
      'fileSize': serializer.toJson<int?>(fileSize),
      'height': serializer.toJson<int?>(height),
      'id': serializer.toJson<String>(id),
      'sha256': serializer.toJson<String>(sha256),
      'thumbJPEG': serializer.toJson<Uint8List?>(thumbJPEG),
      'thumbnailUrl': serializer.toJson<String?>(thumbnailUrl),
      'url': serializer.toJson<String?>(url),
      'width': serializer.toJson<int?>(width),
      'houseId': serializer.toJson<int?>(houseId),
    };
  }

  HousePhotoDb copyWith({
    int? backendId,
    DateTime? createdAt,
    String? fileName,
    Value<int?> fileSize = const Value.absent(),
    Value<int?> height = const Value.absent(),
    String? id,
    String? sha256,
    Value<Uint8List?> thumbJPEG = const Value.absent(),
    Value<String?> thumbnailUrl = const Value.absent(),
    Value<String?> url = const Value.absent(),
    Value<int?> width = const Value.absent(),
    Value<int?> houseId = const Value.absent(),
  }) => HousePhotoDb(
    backendId: backendId ?? this.backendId,
    createdAt: createdAt ?? this.createdAt,
    fileName: fileName ?? this.fileName,
    fileSize: fileSize.present ? fileSize.value : this.fileSize,
    height: height.present ? height.value : this.height,
    id: id ?? this.id,
    sha256: sha256 ?? this.sha256,
    thumbJPEG: thumbJPEG.present ? thumbJPEG.value : this.thumbJPEG,
    thumbnailUrl: thumbnailUrl.present ? thumbnailUrl.value : this.thumbnailUrl,
    url: url.present ? url.value : this.url,
    width: width.present ? width.value : this.width,
    houseId: houseId.present ? houseId.value : this.houseId,
  );
  HousePhotoDb copyWithCompanion(HousePhotosCompanion data) {
    return HousePhotoDb(
      backendId: data.backendId.present ? data.backendId.value : this.backendId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      fileSize: data.fileSize.present ? data.fileSize.value : this.fileSize,
      height: data.height.present ? data.height.value : this.height,
      id: data.id.present ? data.id.value : this.id,
      sha256: data.sha256.present ? data.sha256.value : this.sha256,
      thumbJPEG: data.thumbJPEG.present ? data.thumbJPEG.value : this.thumbJPEG,
      thumbnailUrl: data.thumbnailUrl.present
          ? data.thumbnailUrl.value
          : this.thumbnailUrl,
      url: data.url.present ? data.url.value : this.url,
      width: data.width.present ? data.width.value : this.width,
      houseId: data.houseId.present ? data.houseId.value : this.houseId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HousePhotoDb(')
          ..write('backendId: $backendId, ')
          ..write('createdAt: $createdAt, ')
          ..write('fileName: $fileName, ')
          ..write('fileSize: $fileSize, ')
          ..write('height: $height, ')
          ..write('id: $id, ')
          ..write('sha256: $sha256, ')
          ..write('thumbJPEG: $thumbJPEG, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('url: $url, ')
          ..write('width: $width, ')
          ..write('houseId: $houseId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    backendId,
    createdAt,
    fileName,
    fileSize,
    height,
    id,
    sha256,
    $driftBlobEquality.hash(thumbJPEG),
    thumbnailUrl,
    url,
    width,
    houseId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HousePhotoDb &&
          other.backendId == this.backendId &&
          other.createdAt == this.createdAt &&
          other.fileName == this.fileName &&
          other.fileSize == this.fileSize &&
          other.height == this.height &&
          other.id == this.id &&
          other.sha256 == this.sha256 &&
          $driftBlobEquality.equals(other.thumbJPEG, this.thumbJPEG) &&
          other.thumbnailUrl == this.thumbnailUrl &&
          other.url == this.url &&
          other.width == this.width &&
          other.houseId == this.houseId);
}

class HousePhotosCompanion extends UpdateCompanion<HousePhotoDb> {
  final Value<int> backendId;
  final Value<DateTime> createdAt;
  final Value<String> fileName;
  final Value<int?> fileSize;
  final Value<int?> height;
  final Value<String> id;
  final Value<String> sha256;
  final Value<Uint8List?> thumbJPEG;
  final Value<String?> thumbnailUrl;
  final Value<String?> url;
  final Value<int?> width;
  final Value<int?> houseId;
  const HousePhotosCompanion({
    this.backendId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.fileName = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.height = const Value.absent(),
    this.id = const Value.absent(),
    this.sha256 = const Value.absent(),
    this.thumbJPEG = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
    this.url = const Value.absent(),
    this.width = const Value.absent(),
    this.houseId = const Value.absent(),
  });
  HousePhotosCompanion.insert({
    this.backendId = const Value.absent(),
    required DateTime createdAt,
    required String fileName,
    this.fileSize = const Value.absent(),
    this.height = const Value.absent(),
    required String id,
    required String sha256,
    this.thumbJPEG = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
    this.url = const Value.absent(),
    this.width = const Value.absent(),
    this.houseId = const Value.absent(),
  }) : createdAt = Value(createdAt),
       fileName = Value(fileName),
       id = Value(id),
       sha256 = Value(sha256);
  static Insertable<HousePhotoDb> custom({
    Expression<int>? backendId,
    Expression<DateTime>? createdAt,
    Expression<String>? fileName,
    Expression<int>? fileSize,
    Expression<int>? height,
    Expression<String>? id,
    Expression<String>? sha256,
    Expression<Uint8List>? thumbJPEG,
    Expression<String>? thumbnailUrl,
    Expression<String>? url,
    Expression<int>? width,
    Expression<int>? houseId,
  }) {
    return RawValuesInsertable({
      if (backendId != null) 'backend_id': backendId,
      if (createdAt != null) 'created_at': createdAt,
      if (fileName != null) 'file_name': fileName,
      if (fileSize != null) 'file_size': fileSize,
      if (height != null) 'height': height,
      if (id != null) 'id': id,
      if (sha256 != null) 'sha256': sha256,
      if (thumbJPEG != null) 'thumb_j_p_e_g': thumbJPEG,
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
      if (url != null) 'url': url,
      if (width != null) 'width': width,
      if (houseId != null) 'house_id': houseId,
    });
  }

  HousePhotosCompanion copyWith({
    Value<int>? backendId,
    Value<DateTime>? createdAt,
    Value<String>? fileName,
    Value<int?>? fileSize,
    Value<int?>? height,
    Value<String>? id,
    Value<String>? sha256,
    Value<Uint8List?>? thumbJPEG,
    Value<String?>? thumbnailUrl,
    Value<String?>? url,
    Value<int?>? width,
    Value<int?>? houseId,
  }) {
    return HousePhotosCompanion(
      backendId: backendId ?? this.backendId,
      createdAt: createdAt ?? this.createdAt,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      height: height ?? this.height,
      id: id ?? this.id,
      sha256: sha256 ?? this.sha256,
      thumbJPEG: thumbJPEG ?? this.thumbJPEG,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      url: url ?? this.url,
      width: width ?? this.width,
      houseId: houseId ?? this.houseId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (backendId.present) {
      map['backend_id'] = Variable<int>(backendId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (fileSize.present) {
      map['file_size'] = Variable<int>(fileSize.value);
    }
    if (height.present) {
      map['height'] = Variable<int>(height.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sha256.present) {
      map['sha256'] = Variable<String>(sha256.value);
    }
    if (thumbJPEG.present) {
      map['thumb_j_p_e_g'] = Variable<Uint8List>(thumbJPEG.value);
    }
    if (thumbnailUrl.present) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (width.present) {
      map['width'] = Variable<int>(width.value);
    }
    if (houseId.present) {
      map['house_id'] = Variable<int>(houseId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HousePhotosCompanion(')
          ..write('backendId: $backendId, ')
          ..write('createdAt: $createdAt, ')
          ..write('fileName: $fileName, ')
          ..write('fileSize: $fileSize, ')
          ..write('height: $height, ')
          ..write('id: $id, ')
          ..write('sha256: $sha256, ')
          ..write('thumbJPEG: $thumbJPEG, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('url: $url, ')
          ..write('width: $width, ')
          ..write('houseId: $houseId')
          ..write(')'))
        .toString();
  }
}

class $IncidentsTable extends Incidents
    with TableInfo<$IncidentsTable, IncidentDb> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IncidentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _backendIdMeta = const VerificationMeta(
    'backendId',
  );
  @override
  late final GeneratedColumn<int> backendId = GeneratedColumn<int>(
    'backend_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _assignedToMeta = const VerificationMeta(
    'assignedTo',
  );
  @override
  late final GeneratedColumn<int> assignedTo = GeneratedColumn<int>(
    'assigned_to',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _detailsMeta = const VerificationMeta(
    'details',
  );
  @override
  late final GeneratedColumn<String> details = GeneratedColumn<String>(
    'details',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _finishedAtMeta = const VerificationMeta(
    'finishedAt',
  );
  @override
  late final GeneratedColumn<DateTime> finishedAt = GeneratedColumn<DateTime>(
    'finished_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _incidentUUIDMeta = const VerificationMeta(
    'incidentUUID',
  );
  @override
  late final GeneratedColumn<String> incidentUUID = GeneratedColumn<String>(
    'incident_u_u_i_d',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastLocalEditAtMeta = const VerificationMeta(
    'lastLocalEditAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastLocalEditAt =
      GeneratedColumn<DateTime>(
        'last_local_edit_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastServerUpdateAtMeta =
      const VerificationMeta('lastServerUpdateAt');
  @override
  late final GeneratedColumn<DateTime> lastServerUpdateAt =
      GeneratedColumn<DateTime>(
        'last_server_update_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _localPendingAckMeta = const VerificationMeta(
    'localPendingAck',
  );
  @override
  late final GeneratedColumn<bool> localPendingAck = GeneratedColumn<bool>(
    'local_pending_ack',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("local_pending_ack" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _notificationConfigRoleIdsMeta =
      const VerificationMeta('notificationConfigRoleIds');
  @override
  late final GeneratedColumn<String> notificationConfigRoleIds =
      GeneratedColumn<String>(
        'notification_config_role_ids',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _notificationConfigTypeMeta =
      const VerificationMeta('notificationConfigType');
  @override
  late final GeneratedColumn<String> notificationConfigType =
      GeneratedColumn<String>(
        'notification_config_type',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _notificationConfigUserIdsMeta =
      const VerificationMeta('notificationConfigUserIds');
  @override
  late final GeneratedColumn<String> notificationConfigUserIds =
      GeneratedColumn<String>(
        'notification_config_user_ids',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _resourceHeatingStoppedMeta =
      const VerificationMeta('resourceHeatingStopped');
  @override
  late final GeneratedColumn<bool> resourceHeatingStopped =
      GeneratedColumn<bool>(
        'resource_heating_stopped',
        aliasedName,
        true,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("resource_heating_stopped" IN (0, 1))',
        ),
      );
  static const VerificationMeta _resourceHotWaterStoppedMeta =
      const VerificationMeta('resourceHotWaterStopped');
  @override
  late final GeneratedColumn<bool> resourceHotWaterStopped =
      GeneratedColumn<bool>(
        'resource_hot_water_stopped',
        aliasedName,
        true,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("resource_hot_water_stopped" IN (0, 1))',
        ),
      );
  static const VerificationMeta _severityMeta = const VerificationMeta(
    'severity',
  );
  @override
  late final GeneratedColumn<int> severity = GeneratedColumn<int>(
    'severity',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _boilerHouseIdMeta = const VerificationMeta(
    'boilerHouseId',
  );
  @override
  late final GeneratedColumn<int> boilerHouseId = GeneratedColumn<int>(
    'boiler_house_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES boiler_houses (backend_id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    backendId,
    assignedTo,
    details,
    finishedAt,
    incidentUUID,
    lastLocalEditAt,
    lastServerUpdateAt,
    localPendingAck,
    notificationConfigRoleIds,
    notificationConfigType,
    notificationConfigUserIds,
    resourceHeatingStopped,
    resourceHotWaterStopped,
    severity,
    startedAt,
    status,
    type,
    boilerHouseId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'incidents';
  @override
  VerificationContext validateIntegrity(
    Insertable<IncidentDb> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('backend_id')) {
      context.handle(
        _backendIdMeta,
        backendId.isAcceptableOrUnknown(data['backend_id']!, _backendIdMeta),
      );
    }
    if (data.containsKey('assigned_to')) {
      context.handle(
        _assignedToMeta,
        assignedTo.isAcceptableOrUnknown(data['assigned_to']!, _assignedToMeta),
      );
    }
    if (data.containsKey('details')) {
      context.handle(
        _detailsMeta,
        details.isAcceptableOrUnknown(data['details']!, _detailsMeta),
      );
    }
    if (data.containsKey('finished_at')) {
      context.handle(
        _finishedAtMeta,
        finishedAt.isAcceptableOrUnknown(data['finished_at']!, _finishedAtMeta),
      );
    }
    if (data.containsKey('incident_u_u_i_d')) {
      context.handle(
        _incidentUUIDMeta,
        incidentUUID.isAcceptableOrUnknown(
          data['incident_u_u_i_d']!,
          _incidentUUIDMeta,
        ),
      );
    }
    if (data.containsKey('last_local_edit_at')) {
      context.handle(
        _lastLocalEditAtMeta,
        lastLocalEditAt.isAcceptableOrUnknown(
          data['last_local_edit_at']!,
          _lastLocalEditAtMeta,
        ),
      );
    }
    if (data.containsKey('last_server_update_at')) {
      context.handle(
        _lastServerUpdateAtMeta,
        lastServerUpdateAt.isAcceptableOrUnknown(
          data['last_server_update_at']!,
          _lastServerUpdateAtMeta,
        ),
      );
    }
    if (data.containsKey('local_pending_ack')) {
      context.handle(
        _localPendingAckMeta,
        localPendingAck.isAcceptableOrUnknown(
          data['local_pending_ack']!,
          _localPendingAckMeta,
        ),
      );
    }
    if (data.containsKey('notification_config_role_ids')) {
      context.handle(
        _notificationConfigRoleIdsMeta,
        notificationConfigRoleIds.isAcceptableOrUnknown(
          data['notification_config_role_ids']!,
          _notificationConfigRoleIdsMeta,
        ),
      );
    }
    if (data.containsKey('notification_config_type')) {
      context.handle(
        _notificationConfigTypeMeta,
        notificationConfigType.isAcceptableOrUnknown(
          data['notification_config_type']!,
          _notificationConfigTypeMeta,
        ),
      );
    }
    if (data.containsKey('notification_config_user_ids')) {
      context.handle(
        _notificationConfigUserIdsMeta,
        notificationConfigUserIds.isAcceptableOrUnknown(
          data['notification_config_user_ids']!,
          _notificationConfigUserIdsMeta,
        ),
      );
    }
    if (data.containsKey('resource_heating_stopped')) {
      context.handle(
        _resourceHeatingStoppedMeta,
        resourceHeatingStopped.isAcceptableOrUnknown(
          data['resource_heating_stopped']!,
          _resourceHeatingStoppedMeta,
        ),
      );
    }
    if (data.containsKey('resource_hot_water_stopped')) {
      context.handle(
        _resourceHotWaterStoppedMeta,
        resourceHotWaterStopped.isAcceptableOrUnknown(
          data['resource_hot_water_stopped']!,
          _resourceHotWaterStoppedMeta,
        ),
      );
    }
    if (data.containsKey('severity')) {
      context.handle(
        _severityMeta,
        severity.isAcceptableOrUnknown(data['severity']!, _severityMeta),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('boiler_house_id')) {
      context.handle(
        _boilerHouseIdMeta,
        boilerHouseId.isAcceptableOrUnknown(
          data['boiler_house_id']!,
          _boilerHouseIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {backendId};
  @override
  IncidentDb map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IncidentDb(
      backendId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}backend_id'],
      )!,
      assignedTo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}assigned_to'],
      ),
      details: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}details'],
      ),
      finishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}finished_at'],
      ),
      incidentUUID: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}incident_u_u_i_d'],
      ),
      lastLocalEditAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_local_edit_at'],
      ),
      lastServerUpdateAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_server_update_at'],
      ),
      localPendingAck: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}local_pending_ack'],
      ),
      notificationConfigRoleIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notification_config_role_ids'],
      ),
      notificationConfigType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notification_config_type'],
      ),
      notificationConfigUserIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notification_config_user_ids'],
      ),
      resourceHeatingStopped: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}resource_heating_stopped'],
      ),
      resourceHotWaterStopped: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}resource_hot_water_stopped'],
      ),
      severity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}severity'],
      ),
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      ),
      boilerHouseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}boiler_house_id'],
      ),
    );
  }

  @override
  $IncidentsTable createAlias(String alias) {
    return $IncidentsTable(attachedDatabase, alias);
  }
}

class IncidentDb extends DataClass implements Insertable<IncidentDb> {
  final int backendId;
  final int? assignedTo;
  final String? details;
  final DateTime? finishedAt;
  final String? incidentUUID;
  final DateTime? lastLocalEditAt;
  final DateTime? lastServerUpdateAt;
  final bool? localPendingAck;
  final String? notificationConfigRoleIds;
  final String? notificationConfigType;
  final String? notificationConfigUserIds;
  final bool? resourceHeatingStopped;
  final bool? resourceHotWaterStopped;
  final int? severity;
  final DateTime? startedAt;
  final String? status;
  final String? type;
  final int? boilerHouseId;
  const IncidentDb({
    required this.backendId,
    this.assignedTo,
    this.details,
    this.finishedAt,
    this.incidentUUID,
    this.lastLocalEditAt,
    this.lastServerUpdateAt,
    this.localPendingAck,
    this.notificationConfigRoleIds,
    this.notificationConfigType,
    this.notificationConfigUserIds,
    this.resourceHeatingStopped,
    this.resourceHotWaterStopped,
    this.severity,
    this.startedAt,
    this.status,
    this.type,
    this.boilerHouseId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['backend_id'] = Variable<int>(backendId);
    if (!nullToAbsent || assignedTo != null) {
      map['assigned_to'] = Variable<int>(assignedTo);
    }
    if (!nullToAbsent || details != null) {
      map['details'] = Variable<String>(details);
    }
    if (!nullToAbsent || finishedAt != null) {
      map['finished_at'] = Variable<DateTime>(finishedAt);
    }
    if (!nullToAbsent || incidentUUID != null) {
      map['incident_u_u_i_d'] = Variable<String>(incidentUUID);
    }
    if (!nullToAbsent || lastLocalEditAt != null) {
      map['last_local_edit_at'] = Variable<DateTime>(lastLocalEditAt);
    }
    if (!nullToAbsent || lastServerUpdateAt != null) {
      map['last_server_update_at'] = Variable<DateTime>(lastServerUpdateAt);
    }
    if (!nullToAbsent || localPendingAck != null) {
      map['local_pending_ack'] = Variable<bool>(localPendingAck);
    }
    if (!nullToAbsent || notificationConfigRoleIds != null) {
      map['notification_config_role_ids'] = Variable<String>(
        notificationConfigRoleIds,
      );
    }
    if (!nullToAbsent || notificationConfigType != null) {
      map['notification_config_type'] = Variable<String>(
        notificationConfigType,
      );
    }
    if (!nullToAbsent || notificationConfigUserIds != null) {
      map['notification_config_user_ids'] = Variable<String>(
        notificationConfigUserIds,
      );
    }
    if (!nullToAbsent || resourceHeatingStopped != null) {
      map['resource_heating_stopped'] = Variable<bool>(resourceHeatingStopped);
    }
    if (!nullToAbsent || resourceHotWaterStopped != null) {
      map['resource_hot_water_stopped'] = Variable<bool>(
        resourceHotWaterStopped,
      );
    }
    if (!nullToAbsent || severity != null) {
      map['severity'] = Variable<int>(severity);
    }
    if (!nullToAbsent || startedAt != null) {
      map['started_at'] = Variable<DateTime>(startedAt);
    }
    if (!nullToAbsent || status != null) {
      map['status'] = Variable<String>(status);
    }
    if (!nullToAbsent || type != null) {
      map['type'] = Variable<String>(type);
    }
    if (!nullToAbsent || boilerHouseId != null) {
      map['boiler_house_id'] = Variable<int>(boilerHouseId);
    }
    return map;
  }

  IncidentsCompanion toCompanion(bool nullToAbsent) {
    return IncidentsCompanion(
      backendId: Value(backendId),
      assignedTo: assignedTo == null && nullToAbsent
          ? const Value.absent()
          : Value(assignedTo),
      details: details == null && nullToAbsent
          ? const Value.absent()
          : Value(details),
      finishedAt: finishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(finishedAt),
      incidentUUID: incidentUUID == null && nullToAbsent
          ? const Value.absent()
          : Value(incidentUUID),
      lastLocalEditAt: lastLocalEditAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastLocalEditAt),
      lastServerUpdateAt: lastServerUpdateAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastServerUpdateAt),
      localPendingAck: localPendingAck == null && nullToAbsent
          ? const Value.absent()
          : Value(localPendingAck),
      notificationConfigRoleIds:
          notificationConfigRoleIds == null && nullToAbsent
          ? const Value.absent()
          : Value(notificationConfigRoleIds),
      notificationConfigType: notificationConfigType == null && nullToAbsent
          ? const Value.absent()
          : Value(notificationConfigType),
      notificationConfigUserIds:
          notificationConfigUserIds == null && nullToAbsent
          ? const Value.absent()
          : Value(notificationConfigUserIds),
      resourceHeatingStopped: resourceHeatingStopped == null && nullToAbsent
          ? const Value.absent()
          : Value(resourceHeatingStopped),
      resourceHotWaterStopped: resourceHotWaterStopped == null && nullToAbsent
          ? const Value.absent()
          : Value(resourceHotWaterStopped),
      severity: severity == null && nullToAbsent
          ? const Value.absent()
          : Value(severity),
      startedAt: startedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(startedAt),
      status: status == null && nullToAbsent
          ? const Value.absent()
          : Value(status),
      type: type == null && nullToAbsent ? const Value.absent() : Value(type),
      boilerHouseId: boilerHouseId == null && nullToAbsent
          ? const Value.absent()
          : Value(boilerHouseId),
    );
  }

  factory IncidentDb.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IncidentDb(
      backendId: serializer.fromJson<int>(json['backendId']),
      assignedTo: serializer.fromJson<int?>(json['assignedTo']),
      details: serializer.fromJson<String?>(json['details']),
      finishedAt: serializer.fromJson<DateTime?>(json['finishedAt']),
      incidentUUID: serializer.fromJson<String?>(json['incidentUUID']),
      lastLocalEditAt: serializer.fromJson<DateTime?>(json['lastLocalEditAt']),
      lastServerUpdateAt: serializer.fromJson<DateTime?>(
        json['lastServerUpdateAt'],
      ),
      localPendingAck: serializer.fromJson<bool?>(json['localPendingAck']),
      notificationConfigRoleIds: serializer.fromJson<String?>(
        json['notificationConfigRoleIds'],
      ),
      notificationConfigType: serializer.fromJson<String?>(
        json['notificationConfigType'],
      ),
      notificationConfigUserIds: serializer.fromJson<String?>(
        json['notificationConfigUserIds'],
      ),
      resourceHeatingStopped: serializer.fromJson<bool?>(
        json['resourceHeatingStopped'],
      ),
      resourceHotWaterStopped: serializer.fromJson<bool?>(
        json['resourceHotWaterStopped'],
      ),
      severity: serializer.fromJson<int?>(json['severity']),
      startedAt: serializer.fromJson<DateTime?>(json['startedAt']),
      status: serializer.fromJson<String?>(json['status']),
      type: serializer.fromJson<String?>(json['type']),
      boilerHouseId: serializer.fromJson<int?>(json['boilerHouseId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'backendId': serializer.toJson<int>(backendId),
      'assignedTo': serializer.toJson<int?>(assignedTo),
      'details': serializer.toJson<String?>(details),
      'finishedAt': serializer.toJson<DateTime?>(finishedAt),
      'incidentUUID': serializer.toJson<String?>(incidentUUID),
      'lastLocalEditAt': serializer.toJson<DateTime?>(lastLocalEditAt),
      'lastServerUpdateAt': serializer.toJson<DateTime?>(lastServerUpdateAt),
      'localPendingAck': serializer.toJson<bool?>(localPendingAck),
      'notificationConfigRoleIds': serializer.toJson<String?>(
        notificationConfigRoleIds,
      ),
      'notificationConfigType': serializer.toJson<String?>(
        notificationConfigType,
      ),
      'notificationConfigUserIds': serializer.toJson<String?>(
        notificationConfigUserIds,
      ),
      'resourceHeatingStopped': serializer.toJson<bool?>(
        resourceHeatingStopped,
      ),
      'resourceHotWaterStopped': serializer.toJson<bool?>(
        resourceHotWaterStopped,
      ),
      'severity': serializer.toJson<int?>(severity),
      'startedAt': serializer.toJson<DateTime?>(startedAt),
      'status': serializer.toJson<String?>(status),
      'type': serializer.toJson<String?>(type),
      'boilerHouseId': serializer.toJson<int?>(boilerHouseId),
    };
  }

  IncidentDb copyWith({
    int? backendId,
    Value<int?> assignedTo = const Value.absent(),
    Value<String?> details = const Value.absent(),
    Value<DateTime?> finishedAt = const Value.absent(),
    Value<String?> incidentUUID = const Value.absent(),
    Value<DateTime?> lastLocalEditAt = const Value.absent(),
    Value<DateTime?> lastServerUpdateAt = const Value.absent(),
    Value<bool?> localPendingAck = const Value.absent(),
    Value<String?> notificationConfigRoleIds = const Value.absent(),
    Value<String?> notificationConfigType = const Value.absent(),
    Value<String?> notificationConfigUserIds = const Value.absent(),
    Value<bool?> resourceHeatingStopped = const Value.absent(),
    Value<bool?> resourceHotWaterStopped = const Value.absent(),
    Value<int?> severity = const Value.absent(),
    Value<DateTime?> startedAt = const Value.absent(),
    Value<String?> status = const Value.absent(),
    Value<String?> type = const Value.absent(),
    Value<int?> boilerHouseId = const Value.absent(),
  }) => IncidentDb(
    backendId: backendId ?? this.backendId,
    assignedTo: assignedTo.present ? assignedTo.value : this.assignedTo,
    details: details.present ? details.value : this.details,
    finishedAt: finishedAt.present ? finishedAt.value : this.finishedAt,
    incidentUUID: incidentUUID.present ? incidentUUID.value : this.incidentUUID,
    lastLocalEditAt: lastLocalEditAt.present
        ? lastLocalEditAt.value
        : this.lastLocalEditAt,
    lastServerUpdateAt: lastServerUpdateAt.present
        ? lastServerUpdateAt.value
        : this.lastServerUpdateAt,
    localPendingAck: localPendingAck.present
        ? localPendingAck.value
        : this.localPendingAck,
    notificationConfigRoleIds: notificationConfigRoleIds.present
        ? notificationConfigRoleIds.value
        : this.notificationConfigRoleIds,
    notificationConfigType: notificationConfigType.present
        ? notificationConfigType.value
        : this.notificationConfigType,
    notificationConfigUserIds: notificationConfigUserIds.present
        ? notificationConfigUserIds.value
        : this.notificationConfigUserIds,
    resourceHeatingStopped: resourceHeatingStopped.present
        ? resourceHeatingStopped.value
        : this.resourceHeatingStopped,
    resourceHotWaterStopped: resourceHotWaterStopped.present
        ? resourceHotWaterStopped.value
        : this.resourceHotWaterStopped,
    severity: severity.present ? severity.value : this.severity,
    startedAt: startedAt.present ? startedAt.value : this.startedAt,
    status: status.present ? status.value : this.status,
    type: type.present ? type.value : this.type,
    boilerHouseId: boilerHouseId.present
        ? boilerHouseId.value
        : this.boilerHouseId,
  );
  IncidentDb copyWithCompanion(IncidentsCompanion data) {
    return IncidentDb(
      backendId: data.backendId.present ? data.backendId.value : this.backendId,
      assignedTo: data.assignedTo.present
          ? data.assignedTo.value
          : this.assignedTo,
      details: data.details.present ? data.details.value : this.details,
      finishedAt: data.finishedAt.present
          ? data.finishedAt.value
          : this.finishedAt,
      incidentUUID: data.incidentUUID.present
          ? data.incidentUUID.value
          : this.incidentUUID,
      lastLocalEditAt: data.lastLocalEditAt.present
          ? data.lastLocalEditAt.value
          : this.lastLocalEditAt,
      lastServerUpdateAt: data.lastServerUpdateAt.present
          ? data.lastServerUpdateAt.value
          : this.lastServerUpdateAt,
      localPendingAck: data.localPendingAck.present
          ? data.localPendingAck.value
          : this.localPendingAck,
      notificationConfigRoleIds: data.notificationConfigRoleIds.present
          ? data.notificationConfigRoleIds.value
          : this.notificationConfigRoleIds,
      notificationConfigType: data.notificationConfigType.present
          ? data.notificationConfigType.value
          : this.notificationConfigType,
      notificationConfigUserIds: data.notificationConfigUserIds.present
          ? data.notificationConfigUserIds.value
          : this.notificationConfigUserIds,
      resourceHeatingStopped: data.resourceHeatingStopped.present
          ? data.resourceHeatingStopped.value
          : this.resourceHeatingStopped,
      resourceHotWaterStopped: data.resourceHotWaterStopped.present
          ? data.resourceHotWaterStopped.value
          : this.resourceHotWaterStopped,
      severity: data.severity.present ? data.severity.value : this.severity,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      status: data.status.present ? data.status.value : this.status,
      type: data.type.present ? data.type.value : this.type,
      boilerHouseId: data.boilerHouseId.present
          ? data.boilerHouseId.value
          : this.boilerHouseId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IncidentDb(')
          ..write('backendId: $backendId, ')
          ..write('assignedTo: $assignedTo, ')
          ..write('details: $details, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('incidentUUID: $incidentUUID, ')
          ..write('lastLocalEditAt: $lastLocalEditAt, ')
          ..write('lastServerUpdateAt: $lastServerUpdateAt, ')
          ..write('localPendingAck: $localPendingAck, ')
          ..write('notificationConfigRoleIds: $notificationConfigRoleIds, ')
          ..write('notificationConfigType: $notificationConfigType, ')
          ..write('notificationConfigUserIds: $notificationConfigUserIds, ')
          ..write('resourceHeatingStopped: $resourceHeatingStopped, ')
          ..write('resourceHotWaterStopped: $resourceHotWaterStopped, ')
          ..write('severity: $severity, ')
          ..write('startedAt: $startedAt, ')
          ..write('status: $status, ')
          ..write('type: $type, ')
          ..write('boilerHouseId: $boilerHouseId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    backendId,
    assignedTo,
    details,
    finishedAt,
    incidentUUID,
    lastLocalEditAt,
    lastServerUpdateAt,
    localPendingAck,
    notificationConfigRoleIds,
    notificationConfigType,
    notificationConfigUserIds,
    resourceHeatingStopped,
    resourceHotWaterStopped,
    severity,
    startedAt,
    status,
    type,
    boilerHouseId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IncidentDb &&
          other.backendId == this.backendId &&
          other.assignedTo == this.assignedTo &&
          other.details == this.details &&
          other.finishedAt == this.finishedAt &&
          other.incidentUUID == this.incidentUUID &&
          other.lastLocalEditAt == this.lastLocalEditAt &&
          other.lastServerUpdateAt == this.lastServerUpdateAt &&
          other.localPendingAck == this.localPendingAck &&
          other.notificationConfigRoleIds == this.notificationConfigRoleIds &&
          other.notificationConfigType == this.notificationConfigType &&
          other.notificationConfigUserIds == this.notificationConfigUserIds &&
          other.resourceHeatingStopped == this.resourceHeatingStopped &&
          other.resourceHotWaterStopped == this.resourceHotWaterStopped &&
          other.severity == this.severity &&
          other.startedAt == this.startedAt &&
          other.status == this.status &&
          other.type == this.type &&
          other.boilerHouseId == this.boilerHouseId);
}

class IncidentsCompanion extends UpdateCompanion<IncidentDb> {
  final Value<int> backendId;
  final Value<int?> assignedTo;
  final Value<String?> details;
  final Value<DateTime?> finishedAt;
  final Value<String?> incidentUUID;
  final Value<DateTime?> lastLocalEditAt;
  final Value<DateTime?> lastServerUpdateAt;
  final Value<bool?> localPendingAck;
  final Value<String?> notificationConfigRoleIds;
  final Value<String?> notificationConfigType;
  final Value<String?> notificationConfigUserIds;
  final Value<bool?> resourceHeatingStopped;
  final Value<bool?> resourceHotWaterStopped;
  final Value<int?> severity;
  final Value<DateTime?> startedAt;
  final Value<String?> status;
  final Value<String?> type;
  final Value<int?> boilerHouseId;
  const IncidentsCompanion({
    this.backendId = const Value.absent(),
    this.assignedTo = const Value.absent(),
    this.details = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.incidentUUID = const Value.absent(),
    this.lastLocalEditAt = const Value.absent(),
    this.lastServerUpdateAt = const Value.absent(),
    this.localPendingAck = const Value.absent(),
    this.notificationConfigRoleIds = const Value.absent(),
    this.notificationConfigType = const Value.absent(),
    this.notificationConfigUserIds = const Value.absent(),
    this.resourceHeatingStopped = const Value.absent(),
    this.resourceHotWaterStopped = const Value.absent(),
    this.severity = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.type = const Value.absent(),
    this.boilerHouseId = const Value.absent(),
  });
  IncidentsCompanion.insert({
    this.backendId = const Value.absent(),
    this.assignedTo = const Value.absent(),
    this.details = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.incidentUUID = const Value.absent(),
    this.lastLocalEditAt = const Value.absent(),
    this.lastServerUpdateAt = const Value.absent(),
    this.localPendingAck = const Value.absent(),
    this.notificationConfigRoleIds = const Value.absent(),
    this.notificationConfigType = const Value.absent(),
    this.notificationConfigUserIds = const Value.absent(),
    this.resourceHeatingStopped = const Value.absent(),
    this.resourceHotWaterStopped = const Value.absent(),
    this.severity = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.type = const Value.absent(),
    this.boilerHouseId = const Value.absent(),
  });
  static Insertable<IncidentDb> custom({
    Expression<int>? backendId,
    Expression<int>? assignedTo,
    Expression<String>? details,
    Expression<DateTime>? finishedAt,
    Expression<String>? incidentUUID,
    Expression<DateTime>? lastLocalEditAt,
    Expression<DateTime>? lastServerUpdateAt,
    Expression<bool>? localPendingAck,
    Expression<String>? notificationConfigRoleIds,
    Expression<String>? notificationConfigType,
    Expression<String>? notificationConfigUserIds,
    Expression<bool>? resourceHeatingStopped,
    Expression<bool>? resourceHotWaterStopped,
    Expression<int>? severity,
    Expression<DateTime>? startedAt,
    Expression<String>? status,
    Expression<String>? type,
    Expression<int>? boilerHouseId,
  }) {
    return RawValuesInsertable({
      if (backendId != null) 'backend_id': backendId,
      if (assignedTo != null) 'assigned_to': assignedTo,
      if (details != null) 'details': details,
      if (finishedAt != null) 'finished_at': finishedAt,
      if (incidentUUID != null) 'incident_u_u_i_d': incidentUUID,
      if (lastLocalEditAt != null) 'last_local_edit_at': lastLocalEditAt,
      if (lastServerUpdateAt != null)
        'last_server_update_at': lastServerUpdateAt,
      if (localPendingAck != null) 'local_pending_ack': localPendingAck,
      if (notificationConfigRoleIds != null)
        'notification_config_role_ids': notificationConfigRoleIds,
      if (notificationConfigType != null)
        'notification_config_type': notificationConfigType,
      if (notificationConfigUserIds != null)
        'notification_config_user_ids': notificationConfigUserIds,
      if (resourceHeatingStopped != null)
        'resource_heating_stopped': resourceHeatingStopped,
      if (resourceHotWaterStopped != null)
        'resource_hot_water_stopped': resourceHotWaterStopped,
      if (severity != null) 'severity': severity,
      if (startedAt != null) 'started_at': startedAt,
      if (status != null) 'status': status,
      if (type != null) 'type': type,
      if (boilerHouseId != null) 'boiler_house_id': boilerHouseId,
    });
  }

  IncidentsCompanion copyWith({
    Value<int>? backendId,
    Value<int?>? assignedTo,
    Value<String?>? details,
    Value<DateTime?>? finishedAt,
    Value<String?>? incidentUUID,
    Value<DateTime?>? lastLocalEditAt,
    Value<DateTime?>? lastServerUpdateAt,
    Value<bool?>? localPendingAck,
    Value<String?>? notificationConfigRoleIds,
    Value<String?>? notificationConfigType,
    Value<String?>? notificationConfigUserIds,
    Value<bool?>? resourceHeatingStopped,
    Value<bool?>? resourceHotWaterStopped,
    Value<int?>? severity,
    Value<DateTime?>? startedAt,
    Value<String?>? status,
    Value<String?>? type,
    Value<int?>? boilerHouseId,
  }) {
    return IncidentsCompanion(
      backendId: backendId ?? this.backendId,
      assignedTo: assignedTo ?? this.assignedTo,
      details: details ?? this.details,
      finishedAt: finishedAt ?? this.finishedAt,
      incidentUUID: incidentUUID ?? this.incidentUUID,
      lastLocalEditAt: lastLocalEditAt ?? this.lastLocalEditAt,
      lastServerUpdateAt: lastServerUpdateAt ?? this.lastServerUpdateAt,
      localPendingAck: localPendingAck ?? this.localPendingAck,
      notificationConfigRoleIds:
          notificationConfigRoleIds ?? this.notificationConfigRoleIds,
      notificationConfigType:
          notificationConfigType ?? this.notificationConfigType,
      notificationConfigUserIds:
          notificationConfigUserIds ?? this.notificationConfigUserIds,
      resourceHeatingStopped:
          resourceHeatingStopped ?? this.resourceHeatingStopped,
      resourceHotWaterStopped:
          resourceHotWaterStopped ?? this.resourceHotWaterStopped,
      severity: severity ?? this.severity,
      startedAt: startedAt ?? this.startedAt,
      status: status ?? this.status,
      type: type ?? this.type,
      boilerHouseId: boilerHouseId ?? this.boilerHouseId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (backendId.present) {
      map['backend_id'] = Variable<int>(backendId.value);
    }
    if (assignedTo.present) {
      map['assigned_to'] = Variable<int>(assignedTo.value);
    }
    if (details.present) {
      map['details'] = Variable<String>(details.value);
    }
    if (finishedAt.present) {
      map['finished_at'] = Variable<DateTime>(finishedAt.value);
    }
    if (incidentUUID.present) {
      map['incident_u_u_i_d'] = Variable<String>(incidentUUID.value);
    }
    if (lastLocalEditAt.present) {
      map['last_local_edit_at'] = Variable<DateTime>(lastLocalEditAt.value);
    }
    if (lastServerUpdateAt.present) {
      map['last_server_update_at'] = Variable<DateTime>(
        lastServerUpdateAt.value,
      );
    }
    if (localPendingAck.present) {
      map['local_pending_ack'] = Variable<bool>(localPendingAck.value);
    }
    if (notificationConfigRoleIds.present) {
      map['notification_config_role_ids'] = Variable<String>(
        notificationConfigRoleIds.value,
      );
    }
    if (notificationConfigType.present) {
      map['notification_config_type'] = Variable<String>(
        notificationConfigType.value,
      );
    }
    if (notificationConfigUserIds.present) {
      map['notification_config_user_ids'] = Variable<String>(
        notificationConfigUserIds.value,
      );
    }
    if (resourceHeatingStopped.present) {
      map['resource_heating_stopped'] = Variable<bool>(
        resourceHeatingStopped.value,
      );
    }
    if (resourceHotWaterStopped.present) {
      map['resource_hot_water_stopped'] = Variable<bool>(
        resourceHotWaterStopped.value,
      );
    }
    if (severity.present) {
      map['severity'] = Variable<int>(severity.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (boilerHouseId.present) {
      map['boiler_house_id'] = Variable<int>(boilerHouseId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IncidentsCompanion(')
          ..write('backendId: $backendId, ')
          ..write('assignedTo: $assignedTo, ')
          ..write('details: $details, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('incidentUUID: $incidentUUID, ')
          ..write('lastLocalEditAt: $lastLocalEditAt, ')
          ..write('lastServerUpdateAt: $lastServerUpdateAt, ')
          ..write('localPendingAck: $localPendingAck, ')
          ..write('notificationConfigRoleIds: $notificationConfigRoleIds, ')
          ..write('notificationConfigType: $notificationConfigType, ')
          ..write('notificationConfigUserIds: $notificationConfigUserIds, ')
          ..write('resourceHeatingStopped: $resourceHeatingStopped, ')
          ..write('resourceHotWaterStopped: $resourceHotWaterStopped, ')
          ..write('severity: $severity, ')
          ..write('startedAt: $startedAt, ')
          ..write('status: $status, ')
          ..write('type: $type, ')
          ..write('boilerHouseId: $boilerHouseId')
          ..write(')'))
        .toString();
  }
}

class $AffectedHousesTable extends AffectedHouses
    with TableInfo<$AffectedHousesTable, AffectedHouseDb> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AffectedHousesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _incidentIdMeta = const VerificationMeta(
    'incidentId',
  );
  @override
  late final GeneratedColumn<int> incidentId = GeneratedColumn<int>(
    'incident_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES incidents (backend_id)',
    ),
  );
  static const VerificationMeta _savedLocationIdMeta = const VerificationMeta(
    'savedLocationId',
  );
  @override
  late final GeneratedColumn<int> savedLocationId = GeneratedColumn<int>(
    'saved_location_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES saved_locations (backend_id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [incidentId, savedLocationId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'affected_houses';
  @override
  VerificationContext validateIntegrity(
    Insertable<AffectedHouseDb> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('incident_id')) {
      context.handle(
        _incidentIdMeta,
        incidentId.isAcceptableOrUnknown(data['incident_id']!, _incidentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_incidentIdMeta);
    }
    if (data.containsKey('saved_location_id')) {
      context.handle(
        _savedLocationIdMeta,
        savedLocationId.isAcceptableOrUnknown(
          data['saved_location_id']!,
          _savedLocationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_savedLocationIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {incidentId, savedLocationId};
  @override
  AffectedHouseDb map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AffectedHouseDb(
      incidentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}incident_id'],
      )!,
      savedLocationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}saved_location_id'],
      )!,
    );
  }

  @override
  $AffectedHousesTable createAlias(String alias) {
    return $AffectedHousesTable(attachedDatabase, alias);
  }
}

class AffectedHouseDb extends DataClass implements Insertable<AffectedHouseDb> {
  final int incidentId;
  final int savedLocationId;
  const AffectedHouseDb({
    required this.incidentId,
    required this.savedLocationId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['incident_id'] = Variable<int>(incidentId);
    map['saved_location_id'] = Variable<int>(savedLocationId);
    return map;
  }

  AffectedHousesCompanion toCompanion(bool nullToAbsent) {
    return AffectedHousesCompanion(
      incidentId: Value(incidentId),
      savedLocationId: Value(savedLocationId),
    );
  }

  factory AffectedHouseDb.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AffectedHouseDb(
      incidentId: serializer.fromJson<int>(json['incidentId']),
      savedLocationId: serializer.fromJson<int>(json['savedLocationId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'incidentId': serializer.toJson<int>(incidentId),
      'savedLocationId': serializer.toJson<int>(savedLocationId),
    };
  }

  AffectedHouseDb copyWith({int? incidentId, int? savedLocationId}) =>
      AffectedHouseDb(
        incidentId: incidentId ?? this.incidentId,
        savedLocationId: savedLocationId ?? this.savedLocationId,
      );
  AffectedHouseDb copyWithCompanion(AffectedHousesCompanion data) {
    return AffectedHouseDb(
      incidentId: data.incidentId.present
          ? data.incidentId.value
          : this.incidentId,
      savedLocationId: data.savedLocationId.present
          ? data.savedLocationId.value
          : this.savedLocationId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AffectedHouseDb(')
          ..write('incidentId: $incidentId, ')
          ..write('savedLocationId: $savedLocationId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(incidentId, savedLocationId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AffectedHouseDb &&
          other.incidentId == this.incidentId &&
          other.savedLocationId == this.savedLocationId);
}

class AffectedHousesCompanion extends UpdateCompanion<AffectedHouseDb> {
  final Value<int> incidentId;
  final Value<int> savedLocationId;
  final Value<int> rowid;
  const AffectedHousesCompanion({
    this.incidentId = const Value.absent(),
    this.savedLocationId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AffectedHousesCompanion.insert({
    required int incidentId,
    required int savedLocationId,
    this.rowid = const Value.absent(),
  }) : incidentId = Value(incidentId),
       savedLocationId = Value(savedLocationId);
  static Insertable<AffectedHouseDb> custom({
    Expression<int>? incidentId,
    Expression<int>? savedLocationId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (incidentId != null) 'incident_id': incidentId,
      if (savedLocationId != null) 'saved_location_id': savedLocationId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AffectedHousesCompanion copyWith({
    Value<int>? incidentId,
    Value<int>? savedLocationId,
    Value<int>? rowid,
  }) {
    return AffectedHousesCompanion(
      incidentId: incidentId ?? this.incidentId,
      savedLocationId: savedLocationId ?? this.savedLocationId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (incidentId.present) {
      map['incident_id'] = Variable<int>(incidentId.value);
    }
    if (savedLocationId.present) {
      map['saved_location_id'] = Variable<int>(savedLocationId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AffectedHousesCompanion(')
          ..write('incidentId: $incidentId, ')
          ..write('savedLocationId: $savedLocationId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IncidentCommentsTable extends IncidentComments
    with TableInfo<$IncidentCommentsTable, IncidentCommentDb> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IncidentCommentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _backendIdMeta = const VerificationMeta(
    'backendId',
  );
  @override
  late final GeneratedColumn<int> backendId = GeneratedColumn<int>(
    'backend_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSystemMessageMeta = const VerificationMeta(
    'isSystemMessage',
  );
  @override
  late final GeneratedColumn<bool> isSystemMessage = GeneratedColumn<bool>(
    'is_system_message',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_system_message" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _commentTextMeta = const VerificationMeta(
    'commentText',
  );
  @override
  late final GeneratedColumn<String> commentText = GeneratedColumn<String>(
    'comment_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _authorNameMeta = const VerificationMeta(
    'authorName',
  );
  @override
  late final GeneratedColumn<String> authorName = GeneratedColumn<String>(
    'author_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _authorPositionMeta = const VerificationMeta(
    'authorPosition',
  );
  @override
  late final GeneratedColumn<String> authorPosition = GeneratedColumn<String>(
    'author_position',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _incidentIdMeta = const VerificationMeta(
    'incidentId',
  );
  @override
  late final GeneratedColumn<int> incidentId = GeneratedColumn<int>(
    'incident_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES incidents (backend_id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    backendId,
    createdAt,
    id,
    isSystemMessage,
    commentText,
    userId,
    authorName,
    authorPosition,
    incidentId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'incident_comments';
  @override
  VerificationContext validateIntegrity(
    Insertable<IncidentCommentDb> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('backend_id')) {
      context.handle(
        _backendIdMeta,
        backendId.isAcceptableOrUnknown(data['backend_id']!, _backendIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('is_system_message')) {
      context.handle(
        _isSystemMessageMeta,
        isSystemMessage.isAcceptableOrUnknown(
          data['is_system_message']!,
          _isSystemMessageMeta,
        ),
      );
    }
    if (data.containsKey('comment_text')) {
      context.handle(
        _commentTextMeta,
        commentText.isAcceptableOrUnknown(
          data['comment_text']!,
          _commentTextMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_commentTextMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('author_name')) {
      context.handle(
        _authorNameMeta,
        authorName.isAcceptableOrUnknown(data['author_name']!, _authorNameMeta),
      );
    }
    if (data.containsKey('author_position')) {
      context.handle(
        _authorPositionMeta,
        authorPosition.isAcceptableOrUnknown(
          data['author_position']!,
          _authorPositionMeta,
        ),
      );
    }
    if (data.containsKey('incident_id')) {
      context.handle(
        _incidentIdMeta,
        incidentId.isAcceptableOrUnknown(data['incident_id']!, _incidentIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {backendId};
  @override
  IncidentCommentDb map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IncidentCommentDb(
      backendId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}backend_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      isSystemMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_system_message'],
      )!,
      commentText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}comment_text'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      ),
      authorName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author_name'],
      ),
      authorPosition: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author_position'],
      ),
      incidentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}incident_id'],
      ),
    );
  }

  @override
  $IncidentCommentsTable createAlias(String alias) {
    return $IncidentCommentsTable(attachedDatabase, alias);
  }
}

class IncidentCommentDb extends DataClass
    implements Insertable<IncidentCommentDb> {
  final int backendId;
  final DateTime createdAt;
  final String id;
  final bool isSystemMessage;
  final String commentText;
  final int? userId;
  final String? authorName;
  final String? authorPosition;
  final int? incidentId;
  const IncidentCommentDb({
    required this.backendId,
    required this.createdAt,
    required this.id,
    required this.isSystemMessage,
    required this.commentText,
    this.userId,
    this.authorName,
    this.authorPosition,
    this.incidentId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['backend_id'] = Variable<int>(backendId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['id'] = Variable<String>(id);
    map['is_system_message'] = Variable<bool>(isSystemMessage);
    map['comment_text'] = Variable<String>(commentText);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<int>(userId);
    }
    if (!nullToAbsent || authorName != null) {
      map['author_name'] = Variable<String>(authorName);
    }
    if (!nullToAbsent || authorPosition != null) {
      map['author_position'] = Variable<String>(authorPosition);
    }
    if (!nullToAbsent || incidentId != null) {
      map['incident_id'] = Variable<int>(incidentId);
    }
    return map;
  }

  IncidentCommentsCompanion toCompanion(bool nullToAbsent) {
    return IncidentCommentsCompanion(
      backendId: Value(backendId),
      createdAt: Value(createdAt),
      id: Value(id),
      isSystemMessage: Value(isSystemMessage),
      commentText: Value(commentText),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      authorName: authorName == null && nullToAbsent
          ? const Value.absent()
          : Value(authorName),
      authorPosition: authorPosition == null && nullToAbsent
          ? const Value.absent()
          : Value(authorPosition),
      incidentId: incidentId == null && nullToAbsent
          ? const Value.absent()
          : Value(incidentId),
    );
  }

  factory IncidentCommentDb.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IncidentCommentDb(
      backendId: serializer.fromJson<int>(json['backendId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      id: serializer.fromJson<String>(json['id']),
      isSystemMessage: serializer.fromJson<bool>(json['isSystemMessage']),
      commentText: serializer.fromJson<String>(json['commentText']),
      userId: serializer.fromJson<int?>(json['userId']),
      authorName: serializer.fromJson<String?>(json['authorName']),
      authorPosition: serializer.fromJson<String?>(json['authorPosition']),
      incidentId: serializer.fromJson<int?>(json['incidentId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'backendId': serializer.toJson<int>(backendId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'id': serializer.toJson<String>(id),
      'isSystemMessage': serializer.toJson<bool>(isSystemMessage),
      'commentText': serializer.toJson<String>(commentText),
      'userId': serializer.toJson<int?>(userId),
      'authorName': serializer.toJson<String?>(authorName),
      'authorPosition': serializer.toJson<String?>(authorPosition),
      'incidentId': serializer.toJson<int?>(incidentId),
    };
  }

  IncidentCommentDb copyWith({
    int? backendId,
    DateTime? createdAt,
    String? id,
    bool? isSystemMessage,
    String? commentText,
    Value<int?> userId = const Value.absent(),
    Value<String?> authorName = const Value.absent(),
    Value<String?> authorPosition = const Value.absent(),
    Value<int?> incidentId = const Value.absent(),
  }) => IncidentCommentDb(
    backendId: backendId ?? this.backendId,
    createdAt: createdAt ?? this.createdAt,
    id: id ?? this.id,
    isSystemMessage: isSystemMessage ?? this.isSystemMessage,
    commentText: commentText ?? this.commentText,
    userId: userId.present ? userId.value : this.userId,
    authorName: authorName.present ? authorName.value : this.authorName,
    authorPosition: authorPosition.present
        ? authorPosition.value
        : this.authorPosition,
    incidentId: incidentId.present ? incidentId.value : this.incidentId,
  );
  IncidentCommentDb copyWithCompanion(IncidentCommentsCompanion data) {
    return IncidentCommentDb(
      backendId: data.backendId.present ? data.backendId.value : this.backendId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      id: data.id.present ? data.id.value : this.id,
      isSystemMessage: data.isSystemMessage.present
          ? data.isSystemMessage.value
          : this.isSystemMessage,
      commentText: data.commentText.present
          ? data.commentText.value
          : this.commentText,
      userId: data.userId.present ? data.userId.value : this.userId,
      authorName: data.authorName.present
          ? data.authorName.value
          : this.authorName,
      authorPosition: data.authorPosition.present
          ? data.authorPosition.value
          : this.authorPosition,
      incidentId: data.incidentId.present
          ? data.incidentId.value
          : this.incidentId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IncidentCommentDb(')
          ..write('backendId: $backendId, ')
          ..write('createdAt: $createdAt, ')
          ..write('id: $id, ')
          ..write('isSystemMessage: $isSystemMessage, ')
          ..write('commentText: $commentText, ')
          ..write('userId: $userId, ')
          ..write('authorName: $authorName, ')
          ..write('authorPosition: $authorPosition, ')
          ..write('incidentId: $incidentId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    backendId,
    createdAt,
    id,
    isSystemMessage,
    commentText,
    userId,
    authorName,
    authorPosition,
    incidentId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IncidentCommentDb &&
          other.backendId == this.backendId &&
          other.createdAt == this.createdAt &&
          other.id == this.id &&
          other.isSystemMessage == this.isSystemMessage &&
          other.commentText == this.commentText &&
          other.userId == this.userId &&
          other.authorName == this.authorName &&
          other.authorPosition == this.authorPosition &&
          other.incidentId == this.incidentId);
}

class IncidentCommentsCompanion extends UpdateCompanion<IncidentCommentDb> {
  final Value<int> backendId;
  final Value<DateTime> createdAt;
  final Value<String> id;
  final Value<bool> isSystemMessage;
  final Value<String> commentText;
  final Value<int?> userId;
  final Value<String?> authorName;
  final Value<String?> authorPosition;
  final Value<int?> incidentId;
  const IncidentCommentsCompanion({
    this.backendId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.id = const Value.absent(),
    this.isSystemMessage = const Value.absent(),
    this.commentText = const Value.absent(),
    this.userId = const Value.absent(),
    this.authorName = const Value.absent(),
    this.authorPosition = const Value.absent(),
    this.incidentId = const Value.absent(),
  });
  IncidentCommentsCompanion.insert({
    this.backendId = const Value.absent(),
    required DateTime createdAt,
    required String id,
    this.isSystemMessage = const Value.absent(),
    required String commentText,
    this.userId = const Value.absent(),
    this.authorName = const Value.absent(),
    this.authorPosition = const Value.absent(),
    this.incidentId = const Value.absent(),
  }) : createdAt = Value(createdAt),
       id = Value(id),
       commentText = Value(commentText);
  static Insertable<IncidentCommentDb> custom({
    Expression<int>? backendId,
    Expression<DateTime>? createdAt,
    Expression<String>? id,
    Expression<bool>? isSystemMessage,
    Expression<String>? commentText,
    Expression<int>? userId,
    Expression<String>? authorName,
    Expression<String>? authorPosition,
    Expression<int>? incidentId,
  }) {
    return RawValuesInsertable({
      if (backendId != null) 'backend_id': backendId,
      if (createdAt != null) 'created_at': createdAt,
      if (id != null) 'id': id,
      if (isSystemMessage != null) 'is_system_message': isSystemMessage,
      if (commentText != null) 'comment_text': commentText,
      if (userId != null) 'user_id': userId,
      if (authorName != null) 'author_name': authorName,
      if (authorPosition != null) 'author_position': authorPosition,
      if (incidentId != null) 'incident_id': incidentId,
    });
  }

  IncidentCommentsCompanion copyWith({
    Value<int>? backendId,
    Value<DateTime>? createdAt,
    Value<String>? id,
    Value<bool>? isSystemMessage,
    Value<String>? commentText,
    Value<int?>? userId,
    Value<String?>? authorName,
    Value<String?>? authorPosition,
    Value<int?>? incidentId,
  }) {
    return IncidentCommentsCompanion(
      backendId: backendId ?? this.backendId,
      createdAt: createdAt ?? this.createdAt,
      id: id ?? this.id,
      isSystemMessage: isSystemMessage ?? this.isSystemMessage,
      commentText: commentText ?? this.commentText,
      userId: userId ?? this.userId,
      authorName: authorName ?? this.authorName,
      authorPosition: authorPosition ?? this.authorPosition,
      incidentId: incidentId ?? this.incidentId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (backendId.present) {
      map['backend_id'] = Variable<int>(backendId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (isSystemMessage.present) {
      map['is_system_message'] = Variable<bool>(isSystemMessage.value);
    }
    if (commentText.present) {
      map['comment_text'] = Variable<String>(commentText.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (authorName.present) {
      map['author_name'] = Variable<String>(authorName.value);
    }
    if (authorPosition.present) {
      map['author_position'] = Variable<String>(authorPosition.value);
    }
    if (incidentId.present) {
      map['incident_id'] = Variable<int>(incidentId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IncidentCommentsCompanion(')
          ..write('backendId: $backendId, ')
          ..write('createdAt: $createdAt, ')
          ..write('id: $id, ')
          ..write('isSystemMessage: $isSystemMessage, ')
          ..write('commentText: $commentText, ')
          ..write('userId: $userId, ')
          ..write('authorName: $authorName, ')
          ..write('authorPosition: $authorPosition, ')
          ..write('incidentId: $incidentId')
          ..write(')'))
        .toString();
  }
}

class $IncidentPhotosTable extends IncidentPhotos
    with TableInfo<$IncidentPhotosTable, IncidentPhotoDb> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IncidentPhotosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _backendIdMeta = const VerificationMeta(
    'backendId',
  );
  @override
  late final GeneratedColumn<int> backendId = GeneratedColumn<int>(
    'backend_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileSizeMeta = const VerificationMeta(
    'fileSize',
  );
  @override
  late final GeneratedColumn<int> fileSize = GeneratedColumn<int>(
    'file_size',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<int> height = GeneratedColumn<int>(
    'height',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sha256Meta = const VerificationMeta('sha256');
  @override
  late final GeneratedColumn<String> sha256 = GeneratedColumn<String>(
    'sha256',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _thumbJPEGMeta = const VerificationMeta(
    'thumbJPEG',
  );
  @override
  late final GeneratedColumn<Uint8List> thumbJPEG = GeneratedColumn<Uint8List>(
    'thumb_j_p_e_g',
    aliasedName,
    true,
    type: DriftSqlType.blob,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _thumbnailUrlMeta = const VerificationMeta(
    'thumbnailUrl',
  );
  @override
  late final GeneratedColumn<String> thumbnailUrl = GeneratedColumn<String>(
    'thumbnail_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<int> width = GeneratedColumn<int>(
    'width',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _incidentIdMeta = const VerificationMeta(
    'incidentId',
  );
  @override
  late final GeneratedColumn<int> incidentId = GeneratedColumn<int>(
    'incident_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES incidents (backend_id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    backendId,
    createdAt,
    fileName,
    fileSize,
    height,
    id,
    sha256,
    thumbJPEG,
    thumbnailUrl,
    url,
    width,
    incidentId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'incident_photos';
  @override
  VerificationContext validateIntegrity(
    Insertable<IncidentPhotoDb> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('backend_id')) {
      context.handle(
        _backendIdMeta,
        backendId.isAcceptableOrUnknown(data['backend_id']!, _backendIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('file_size')) {
      context.handle(
        _fileSizeMeta,
        fileSize.isAcceptableOrUnknown(data['file_size']!, _fileSizeMeta),
      );
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('sha256')) {
      context.handle(
        _sha256Meta,
        sha256.isAcceptableOrUnknown(data['sha256']!, _sha256Meta),
      );
    }
    if (data.containsKey('thumb_j_p_e_g')) {
      context.handle(
        _thumbJPEGMeta,
        thumbJPEG.isAcceptableOrUnknown(data['thumb_j_p_e_g']!, _thumbJPEGMeta),
      );
    }
    if (data.containsKey('thumbnail_url')) {
      context.handle(
        _thumbnailUrlMeta,
        thumbnailUrl.isAcceptableOrUnknown(
          data['thumbnail_url']!,
          _thumbnailUrlMeta,
        ),
      );
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    }
    if (data.containsKey('width')) {
      context.handle(
        _widthMeta,
        width.isAcceptableOrUnknown(data['width']!, _widthMeta),
      );
    }
    if (data.containsKey('incident_id')) {
      context.handle(
        _incidentIdMeta,
        incidentId.isAcceptableOrUnknown(data['incident_id']!, _incidentIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {backendId};
  @override
  IncidentPhotoDb map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IncidentPhotoDb(
      backendId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}backend_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
      fileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_name'],
      )!,
      fileSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}file_size'],
      ),
      height: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}height'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sha256'],
      ),
      thumbJPEG: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}thumb_j_p_e_g'],
      ),
      thumbnailUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail_url'],
      ),
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      ),
      width: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}width'],
      ),
      incidentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}incident_id'],
      ),
    );
  }

  @override
  $IncidentPhotosTable createAlias(String alias) {
    return $IncidentPhotosTable(attachedDatabase, alias);
  }
}

class IncidentPhotoDb extends DataClass implements Insertable<IncidentPhotoDb> {
  final int backendId;
  final DateTime? createdAt;
  final String fileName;
  final int? fileSize;
  final int? height;
  final String id;
  final String? sha256;
  final Uint8List? thumbJPEG;
  final String? thumbnailUrl;
  final String? url;
  final int? width;
  final int? incidentId;
  const IncidentPhotoDb({
    required this.backendId,
    this.createdAt,
    required this.fileName,
    this.fileSize,
    this.height,
    required this.id,
    this.sha256,
    this.thumbJPEG,
    this.thumbnailUrl,
    this.url,
    this.width,
    this.incidentId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['backend_id'] = Variable<int>(backendId);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    map['file_name'] = Variable<String>(fileName);
    if (!nullToAbsent || fileSize != null) {
      map['file_size'] = Variable<int>(fileSize);
    }
    if (!nullToAbsent || height != null) {
      map['height'] = Variable<int>(height);
    }
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || sha256 != null) {
      map['sha256'] = Variable<String>(sha256);
    }
    if (!nullToAbsent || thumbJPEG != null) {
      map['thumb_j_p_e_g'] = Variable<Uint8List>(thumbJPEG);
    }
    if (!nullToAbsent || thumbnailUrl != null) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl);
    }
    if (!nullToAbsent || url != null) {
      map['url'] = Variable<String>(url);
    }
    if (!nullToAbsent || width != null) {
      map['width'] = Variable<int>(width);
    }
    if (!nullToAbsent || incidentId != null) {
      map['incident_id'] = Variable<int>(incidentId);
    }
    return map;
  }

  IncidentPhotosCompanion toCompanion(bool nullToAbsent) {
    return IncidentPhotosCompanion(
      backendId: Value(backendId),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      fileName: Value(fileName),
      fileSize: fileSize == null && nullToAbsent
          ? const Value.absent()
          : Value(fileSize),
      height: height == null && nullToAbsent
          ? const Value.absent()
          : Value(height),
      id: Value(id),
      sha256: sha256 == null && nullToAbsent
          ? const Value.absent()
          : Value(sha256),
      thumbJPEG: thumbJPEG == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbJPEG),
      thumbnailUrl: thumbnailUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailUrl),
      url: url == null && nullToAbsent ? const Value.absent() : Value(url),
      width: width == null && nullToAbsent
          ? const Value.absent()
          : Value(width),
      incidentId: incidentId == null && nullToAbsent
          ? const Value.absent()
          : Value(incidentId),
    );
  }

  factory IncidentPhotoDb.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IncidentPhotoDb(
      backendId: serializer.fromJson<int>(json['backendId']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      fileName: serializer.fromJson<String>(json['fileName']),
      fileSize: serializer.fromJson<int?>(json['fileSize']),
      height: serializer.fromJson<int?>(json['height']),
      id: serializer.fromJson<String>(json['id']),
      sha256: serializer.fromJson<String?>(json['sha256']),
      thumbJPEG: serializer.fromJson<Uint8List?>(json['thumbJPEG']),
      thumbnailUrl: serializer.fromJson<String?>(json['thumbnailUrl']),
      url: serializer.fromJson<String?>(json['url']),
      width: serializer.fromJson<int?>(json['width']),
      incidentId: serializer.fromJson<int?>(json['incidentId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'backendId': serializer.toJson<int>(backendId),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'fileName': serializer.toJson<String>(fileName),
      'fileSize': serializer.toJson<int?>(fileSize),
      'height': serializer.toJson<int?>(height),
      'id': serializer.toJson<String>(id),
      'sha256': serializer.toJson<String?>(sha256),
      'thumbJPEG': serializer.toJson<Uint8List?>(thumbJPEG),
      'thumbnailUrl': serializer.toJson<String?>(thumbnailUrl),
      'url': serializer.toJson<String?>(url),
      'width': serializer.toJson<int?>(width),
      'incidentId': serializer.toJson<int?>(incidentId),
    };
  }

  IncidentPhotoDb copyWith({
    int? backendId,
    Value<DateTime?> createdAt = const Value.absent(),
    String? fileName,
    Value<int?> fileSize = const Value.absent(),
    Value<int?> height = const Value.absent(),
    String? id,
    Value<String?> sha256 = const Value.absent(),
    Value<Uint8List?> thumbJPEG = const Value.absent(),
    Value<String?> thumbnailUrl = const Value.absent(),
    Value<String?> url = const Value.absent(),
    Value<int?> width = const Value.absent(),
    Value<int?> incidentId = const Value.absent(),
  }) => IncidentPhotoDb(
    backendId: backendId ?? this.backendId,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    fileName: fileName ?? this.fileName,
    fileSize: fileSize.present ? fileSize.value : this.fileSize,
    height: height.present ? height.value : this.height,
    id: id ?? this.id,
    sha256: sha256.present ? sha256.value : this.sha256,
    thumbJPEG: thumbJPEG.present ? thumbJPEG.value : this.thumbJPEG,
    thumbnailUrl: thumbnailUrl.present ? thumbnailUrl.value : this.thumbnailUrl,
    url: url.present ? url.value : this.url,
    width: width.present ? width.value : this.width,
    incidentId: incidentId.present ? incidentId.value : this.incidentId,
  );
  IncidentPhotoDb copyWithCompanion(IncidentPhotosCompanion data) {
    return IncidentPhotoDb(
      backendId: data.backendId.present ? data.backendId.value : this.backendId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      fileSize: data.fileSize.present ? data.fileSize.value : this.fileSize,
      height: data.height.present ? data.height.value : this.height,
      id: data.id.present ? data.id.value : this.id,
      sha256: data.sha256.present ? data.sha256.value : this.sha256,
      thumbJPEG: data.thumbJPEG.present ? data.thumbJPEG.value : this.thumbJPEG,
      thumbnailUrl: data.thumbnailUrl.present
          ? data.thumbnailUrl.value
          : this.thumbnailUrl,
      url: data.url.present ? data.url.value : this.url,
      width: data.width.present ? data.width.value : this.width,
      incidentId: data.incidentId.present
          ? data.incidentId.value
          : this.incidentId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IncidentPhotoDb(')
          ..write('backendId: $backendId, ')
          ..write('createdAt: $createdAt, ')
          ..write('fileName: $fileName, ')
          ..write('fileSize: $fileSize, ')
          ..write('height: $height, ')
          ..write('id: $id, ')
          ..write('sha256: $sha256, ')
          ..write('thumbJPEG: $thumbJPEG, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('url: $url, ')
          ..write('width: $width, ')
          ..write('incidentId: $incidentId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    backendId,
    createdAt,
    fileName,
    fileSize,
    height,
    id,
    sha256,
    $driftBlobEquality.hash(thumbJPEG),
    thumbnailUrl,
    url,
    width,
    incidentId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IncidentPhotoDb &&
          other.backendId == this.backendId &&
          other.createdAt == this.createdAt &&
          other.fileName == this.fileName &&
          other.fileSize == this.fileSize &&
          other.height == this.height &&
          other.id == this.id &&
          other.sha256 == this.sha256 &&
          $driftBlobEquality.equals(other.thumbJPEG, this.thumbJPEG) &&
          other.thumbnailUrl == this.thumbnailUrl &&
          other.url == this.url &&
          other.width == this.width &&
          other.incidentId == this.incidentId);
}

class IncidentPhotosCompanion extends UpdateCompanion<IncidentPhotoDb> {
  final Value<int> backendId;
  final Value<DateTime?> createdAt;
  final Value<String> fileName;
  final Value<int?> fileSize;
  final Value<int?> height;
  final Value<String> id;
  final Value<String?> sha256;
  final Value<Uint8List?> thumbJPEG;
  final Value<String?> thumbnailUrl;
  final Value<String?> url;
  final Value<int?> width;
  final Value<int?> incidentId;
  const IncidentPhotosCompanion({
    this.backendId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.fileName = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.height = const Value.absent(),
    this.id = const Value.absent(),
    this.sha256 = const Value.absent(),
    this.thumbJPEG = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
    this.url = const Value.absent(),
    this.width = const Value.absent(),
    this.incidentId = const Value.absent(),
  });
  IncidentPhotosCompanion.insert({
    this.backendId = const Value.absent(),
    this.createdAt = const Value.absent(),
    required String fileName,
    this.fileSize = const Value.absent(),
    this.height = const Value.absent(),
    required String id,
    this.sha256 = const Value.absent(),
    this.thumbJPEG = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
    this.url = const Value.absent(),
    this.width = const Value.absent(),
    this.incidentId = const Value.absent(),
  }) : fileName = Value(fileName),
       id = Value(id);
  static Insertable<IncidentPhotoDb> custom({
    Expression<int>? backendId,
    Expression<DateTime>? createdAt,
    Expression<String>? fileName,
    Expression<int>? fileSize,
    Expression<int>? height,
    Expression<String>? id,
    Expression<String>? sha256,
    Expression<Uint8List>? thumbJPEG,
    Expression<String>? thumbnailUrl,
    Expression<String>? url,
    Expression<int>? width,
    Expression<int>? incidentId,
  }) {
    return RawValuesInsertable({
      if (backendId != null) 'backend_id': backendId,
      if (createdAt != null) 'created_at': createdAt,
      if (fileName != null) 'file_name': fileName,
      if (fileSize != null) 'file_size': fileSize,
      if (height != null) 'height': height,
      if (id != null) 'id': id,
      if (sha256 != null) 'sha256': sha256,
      if (thumbJPEG != null) 'thumb_j_p_e_g': thumbJPEG,
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
      if (url != null) 'url': url,
      if (width != null) 'width': width,
      if (incidentId != null) 'incident_id': incidentId,
    });
  }

  IncidentPhotosCompanion copyWith({
    Value<int>? backendId,
    Value<DateTime?>? createdAt,
    Value<String>? fileName,
    Value<int?>? fileSize,
    Value<int?>? height,
    Value<String>? id,
    Value<String?>? sha256,
    Value<Uint8List?>? thumbJPEG,
    Value<String?>? thumbnailUrl,
    Value<String?>? url,
    Value<int?>? width,
    Value<int?>? incidentId,
  }) {
    return IncidentPhotosCompanion(
      backendId: backendId ?? this.backendId,
      createdAt: createdAt ?? this.createdAt,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      height: height ?? this.height,
      id: id ?? this.id,
      sha256: sha256 ?? this.sha256,
      thumbJPEG: thumbJPEG ?? this.thumbJPEG,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      url: url ?? this.url,
      width: width ?? this.width,
      incidentId: incidentId ?? this.incidentId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (backendId.present) {
      map['backend_id'] = Variable<int>(backendId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (fileSize.present) {
      map['file_size'] = Variable<int>(fileSize.value);
    }
    if (height.present) {
      map['height'] = Variable<int>(height.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sha256.present) {
      map['sha256'] = Variable<String>(sha256.value);
    }
    if (thumbJPEG.present) {
      map['thumb_j_p_e_g'] = Variable<Uint8List>(thumbJPEG.value);
    }
    if (thumbnailUrl.present) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (width.present) {
      map['width'] = Variable<int>(width.value);
    }
    if (incidentId.present) {
      map['incident_id'] = Variable<int>(incidentId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IncidentPhotosCompanion(')
          ..write('backendId: $backendId, ')
          ..write('createdAt: $createdAt, ')
          ..write('fileName: $fileName, ')
          ..write('fileSize: $fileSize, ')
          ..write('height: $height, ')
          ..write('id: $id, ')
          ..write('sha256: $sha256, ')
          ..write('thumbJPEG: $thumbJPEG, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('url: $url, ')
          ..write('width: $width, ')
          ..write('incidentId: $incidentId')
          ..write(')'))
        .toString();
  }
}

class $MyAccountsTable extends MyAccounts
    with TableInfo<$MyAccountsTable, MyAccountDb> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MyAccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _accountNumberMeta = const VerificationMeta(
    'accountNumber',
  );
  @override
  late final GeneratedColumn<String> accountNumber = GeneratedColumn<String>(
    'account_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _areaMeta = const VerificationMeta('area');
  @override
  late final GeneratedColumn<double> area = GeneratedColumn<double>(
    'area',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _closeDateMeta = const VerificationMeta(
    'closeDate',
  );
  @override
  late final GeneratedColumn<DateTime> closeDate = GeneratedColumn<DateTime>(
    'close_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fioMeta = const VerificationMeta('fio');
  @override
  late final GeneratedColumn<String> fio = GeneratedColumn<String>(
    'fio',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _jkuIdentifierMeta = const VerificationMeta(
    'jkuIdentifier',
  );
  @override
  late final GeneratedColumn<String> jkuIdentifier = GeneratedColumn<String>(
    'jku_identifier',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationUUIDMeta = const VerificationMeta(
    'locationUUID',
  );
  @override
  late final GeneratedColumn<String> locationUUID = GeneratedColumn<String>(
    'location_u_u_i_d',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _openDateMeta = const VerificationMeta(
    'openDate',
  );
  @override
  late final GeneratedColumn<DateTime> openDate = GeneratedColumn<DateTime>(
    'open_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serviceTypeMeta = const VerificationMeta(
    'serviceType',
  );
  @override
  late final GeneratedColumn<String> serviceType = GeneratedColumn<String>(
    'service_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    accountNumber,
    address,
    area,
    closeDate,
    email,
    fio,
    jkuIdentifier,
    locationUUID,
    openDate,
    phone,
    serviceType,
    status,
    id,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'my_accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<MyAccountDb> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('account_number')) {
      context.handle(
        _accountNumberMeta,
        accountNumber.isAcceptableOrUnknown(
          data['account_number']!,
          _accountNumberMeta,
        ),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('area')) {
      context.handle(
        _areaMeta,
        area.isAcceptableOrUnknown(data['area']!, _areaMeta),
      );
    }
    if (data.containsKey('close_date')) {
      context.handle(
        _closeDateMeta,
        closeDate.isAcceptableOrUnknown(data['close_date']!, _closeDateMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('fio')) {
      context.handle(
        _fioMeta,
        fio.isAcceptableOrUnknown(data['fio']!, _fioMeta),
      );
    }
    if (data.containsKey('jku_identifier')) {
      context.handle(
        _jkuIdentifierMeta,
        jkuIdentifier.isAcceptableOrUnknown(
          data['jku_identifier']!,
          _jkuIdentifierMeta,
        ),
      );
    }
    if (data.containsKey('location_u_u_i_d')) {
      context.handle(
        _locationUUIDMeta,
        locationUUID.isAcceptableOrUnknown(
          data['location_u_u_i_d']!,
          _locationUUIDMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_locationUUIDMeta);
    }
    if (data.containsKey('open_date')) {
      context.handle(
        _openDateMeta,
        openDate.isAcceptableOrUnknown(data['open_date']!, _openDateMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('service_type')) {
      context.handle(
        _serviceTypeMeta,
        serviceType.isAcceptableOrUnknown(
          data['service_type']!,
          _serviceTypeMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MyAccountDb map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MyAccountDb(
      accountNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_number'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      area: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}area'],
      ),
      closeDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}close_date'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      fio: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fio'],
      ),
      jkuIdentifier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}jku_identifier'],
      ),
      locationUUID: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location_u_u_i_d'],
      )!,
      openDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}open_date'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      serviceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}service_type'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
    );
  }

  @override
  $MyAccountsTable createAlias(String alias) {
    return $MyAccountsTable(attachedDatabase, alias);
  }
}

class MyAccountDb extends DataClass implements Insertable<MyAccountDb> {
  final String? accountNumber;
  final String? address;
  final double? area;
  final DateTime? closeDate;
  final String? email;
  final String? fio;
  final String? jkuIdentifier;
  final String locationUUID;
  final DateTime? openDate;
  final String? phone;
  final String? serviceType;
  final String? status;
  final int id;
  const MyAccountDb({
    this.accountNumber,
    this.address,
    this.area,
    this.closeDate,
    this.email,
    this.fio,
    this.jkuIdentifier,
    required this.locationUUID,
    this.openDate,
    this.phone,
    this.serviceType,
    this.status,
    required this.id,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || accountNumber != null) {
      map['account_number'] = Variable<String>(accountNumber);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || area != null) {
      map['area'] = Variable<double>(area);
    }
    if (!nullToAbsent || closeDate != null) {
      map['close_date'] = Variable<DateTime>(closeDate);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || fio != null) {
      map['fio'] = Variable<String>(fio);
    }
    if (!nullToAbsent || jkuIdentifier != null) {
      map['jku_identifier'] = Variable<String>(jkuIdentifier);
    }
    map['location_u_u_i_d'] = Variable<String>(locationUUID);
    if (!nullToAbsent || openDate != null) {
      map['open_date'] = Variable<DateTime>(openDate);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || serviceType != null) {
      map['service_type'] = Variable<String>(serviceType);
    }
    if (!nullToAbsent || status != null) {
      map['status'] = Variable<String>(status);
    }
    map['id'] = Variable<int>(id);
    return map;
  }

  MyAccountsCompanion toCompanion(bool nullToAbsent) {
    return MyAccountsCompanion(
      accountNumber: accountNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(accountNumber),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      area: area == null && nullToAbsent ? const Value.absent() : Value(area),
      closeDate: closeDate == null && nullToAbsent
          ? const Value.absent()
          : Value(closeDate),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      fio: fio == null && nullToAbsent ? const Value.absent() : Value(fio),
      jkuIdentifier: jkuIdentifier == null && nullToAbsent
          ? const Value.absent()
          : Value(jkuIdentifier),
      locationUUID: Value(locationUUID),
      openDate: openDate == null && nullToAbsent
          ? const Value.absent()
          : Value(openDate),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      serviceType: serviceType == null && nullToAbsent
          ? const Value.absent()
          : Value(serviceType),
      status: status == null && nullToAbsent
          ? const Value.absent()
          : Value(status),
      id: Value(id),
    );
  }

  factory MyAccountDb.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MyAccountDb(
      accountNumber: serializer.fromJson<String?>(json['accountNumber']),
      address: serializer.fromJson<String?>(json['address']),
      area: serializer.fromJson<double?>(json['area']),
      closeDate: serializer.fromJson<DateTime?>(json['closeDate']),
      email: serializer.fromJson<String?>(json['email']),
      fio: serializer.fromJson<String?>(json['fio']),
      jkuIdentifier: serializer.fromJson<String?>(json['jkuIdentifier']),
      locationUUID: serializer.fromJson<String>(json['locationUUID']),
      openDate: serializer.fromJson<DateTime?>(json['openDate']),
      phone: serializer.fromJson<String?>(json['phone']),
      serviceType: serializer.fromJson<String?>(json['serviceType']),
      status: serializer.fromJson<String?>(json['status']),
      id: serializer.fromJson<int>(json['id']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'accountNumber': serializer.toJson<String?>(accountNumber),
      'address': serializer.toJson<String?>(address),
      'area': serializer.toJson<double?>(area),
      'closeDate': serializer.toJson<DateTime?>(closeDate),
      'email': serializer.toJson<String?>(email),
      'fio': serializer.toJson<String?>(fio),
      'jkuIdentifier': serializer.toJson<String?>(jkuIdentifier),
      'locationUUID': serializer.toJson<String>(locationUUID),
      'openDate': serializer.toJson<DateTime?>(openDate),
      'phone': serializer.toJson<String?>(phone),
      'serviceType': serializer.toJson<String?>(serviceType),
      'status': serializer.toJson<String?>(status),
      'id': serializer.toJson<int>(id),
    };
  }

  MyAccountDb copyWith({
    Value<String?> accountNumber = const Value.absent(),
    Value<String?> address = const Value.absent(),
    Value<double?> area = const Value.absent(),
    Value<DateTime?> closeDate = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> fio = const Value.absent(),
    Value<String?> jkuIdentifier = const Value.absent(),
    String? locationUUID,
    Value<DateTime?> openDate = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<String?> serviceType = const Value.absent(),
    Value<String?> status = const Value.absent(),
    int? id,
  }) => MyAccountDb(
    accountNumber: accountNumber.present
        ? accountNumber.value
        : this.accountNumber,
    address: address.present ? address.value : this.address,
    area: area.present ? area.value : this.area,
    closeDate: closeDate.present ? closeDate.value : this.closeDate,
    email: email.present ? email.value : this.email,
    fio: fio.present ? fio.value : this.fio,
    jkuIdentifier: jkuIdentifier.present
        ? jkuIdentifier.value
        : this.jkuIdentifier,
    locationUUID: locationUUID ?? this.locationUUID,
    openDate: openDate.present ? openDate.value : this.openDate,
    phone: phone.present ? phone.value : this.phone,
    serviceType: serviceType.present ? serviceType.value : this.serviceType,
    status: status.present ? status.value : this.status,
    id: id ?? this.id,
  );
  MyAccountDb copyWithCompanion(MyAccountsCompanion data) {
    return MyAccountDb(
      accountNumber: data.accountNumber.present
          ? data.accountNumber.value
          : this.accountNumber,
      address: data.address.present ? data.address.value : this.address,
      area: data.area.present ? data.area.value : this.area,
      closeDate: data.closeDate.present ? data.closeDate.value : this.closeDate,
      email: data.email.present ? data.email.value : this.email,
      fio: data.fio.present ? data.fio.value : this.fio,
      jkuIdentifier: data.jkuIdentifier.present
          ? data.jkuIdentifier.value
          : this.jkuIdentifier,
      locationUUID: data.locationUUID.present
          ? data.locationUUID.value
          : this.locationUUID,
      openDate: data.openDate.present ? data.openDate.value : this.openDate,
      phone: data.phone.present ? data.phone.value : this.phone,
      serviceType: data.serviceType.present
          ? data.serviceType.value
          : this.serviceType,
      status: data.status.present ? data.status.value : this.status,
      id: data.id.present ? data.id.value : this.id,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MyAccountDb(')
          ..write('accountNumber: $accountNumber, ')
          ..write('address: $address, ')
          ..write('area: $area, ')
          ..write('closeDate: $closeDate, ')
          ..write('email: $email, ')
          ..write('fio: $fio, ')
          ..write('jkuIdentifier: $jkuIdentifier, ')
          ..write('locationUUID: $locationUUID, ')
          ..write('openDate: $openDate, ')
          ..write('phone: $phone, ')
          ..write('serviceType: $serviceType, ')
          ..write('status: $status, ')
          ..write('id: $id')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    accountNumber,
    address,
    area,
    closeDate,
    email,
    fio,
    jkuIdentifier,
    locationUUID,
    openDate,
    phone,
    serviceType,
    status,
    id,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MyAccountDb &&
          other.accountNumber == this.accountNumber &&
          other.address == this.address &&
          other.area == this.area &&
          other.closeDate == this.closeDate &&
          other.email == this.email &&
          other.fio == this.fio &&
          other.jkuIdentifier == this.jkuIdentifier &&
          other.locationUUID == this.locationUUID &&
          other.openDate == this.openDate &&
          other.phone == this.phone &&
          other.serviceType == this.serviceType &&
          other.status == this.status &&
          other.id == this.id);
}

class MyAccountsCompanion extends UpdateCompanion<MyAccountDb> {
  final Value<String?> accountNumber;
  final Value<String?> address;
  final Value<double?> area;
  final Value<DateTime?> closeDate;
  final Value<String?> email;
  final Value<String?> fio;
  final Value<String?> jkuIdentifier;
  final Value<String> locationUUID;
  final Value<DateTime?> openDate;
  final Value<String?> phone;
  final Value<String?> serviceType;
  final Value<String?> status;
  final Value<int> id;
  const MyAccountsCompanion({
    this.accountNumber = const Value.absent(),
    this.address = const Value.absent(),
    this.area = const Value.absent(),
    this.closeDate = const Value.absent(),
    this.email = const Value.absent(),
    this.fio = const Value.absent(),
    this.jkuIdentifier = const Value.absent(),
    this.locationUUID = const Value.absent(),
    this.openDate = const Value.absent(),
    this.phone = const Value.absent(),
    this.serviceType = const Value.absent(),
    this.status = const Value.absent(),
    this.id = const Value.absent(),
  });
  MyAccountsCompanion.insert({
    this.accountNumber = const Value.absent(),
    this.address = const Value.absent(),
    this.area = const Value.absent(),
    this.closeDate = const Value.absent(),
    this.email = const Value.absent(),
    this.fio = const Value.absent(),
    this.jkuIdentifier = const Value.absent(),
    required String locationUUID,
    this.openDate = const Value.absent(),
    this.phone = const Value.absent(),
    this.serviceType = const Value.absent(),
    this.status = const Value.absent(),
    this.id = const Value.absent(),
  }) : locationUUID = Value(locationUUID);
  static Insertable<MyAccountDb> custom({
    Expression<String>? accountNumber,
    Expression<String>? address,
    Expression<double>? area,
    Expression<DateTime>? closeDate,
    Expression<String>? email,
    Expression<String>? fio,
    Expression<String>? jkuIdentifier,
    Expression<String>? locationUUID,
    Expression<DateTime>? openDate,
    Expression<String>? phone,
    Expression<String>? serviceType,
    Expression<String>? status,
    Expression<int>? id,
  }) {
    return RawValuesInsertable({
      if (accountNumber != null) 'account_number': accountNumber,
      if (address != null) 'address': address,
      if (area != null) 'area': area,
      if (closeDate != null) 'close_date': closeDate,
      if (email != null) 'email': email,
      if (fio != null) 'fio': fio,
      if (jkuIdentifier != null) 'jku_identifier': jkuIdentifier,
      if (locationUUID != null) 'location_u_u_i_d': locationUUID,
      if (openDate != null) 'open_date': openDate,
      if (phone != null) 'phone': phone,
      if (serviceType != null) 'service_type': serviceType,
      if (status != null) 'status': status,
      if (id != null) 'id': id,
    });
  }

  MyAccountsCompanion copyWith({
    Value<String?>? accountNumber,
    Value<String?>? address,
    Value<double?>? area,
    Value<DateTime?>? closeDate,
    Value<String?>? email,
    Value<String?>? fio,
    Value<String?>? jkuIdentifier,
    Value<String>? locationUUID,
    Value<DateTime?>? openDate,
    Value<String?>? phone,
    Value<String?>? serviceType,
    Value<String?>? status,
    Value<int>? id,
  }) {
    return MyAccountsCompanion(
      accountNumber: accountNumber ?? this.accountNumber,
      address: address ?? this.address,
      area: area ?? this.area,
      closeDate: closeDate ?? this.closeDate,
      email: email ?? this.email,
      fio: fio ?? this.fio,
      jkuIdentifier: jkuIdentifier ?? this.jkuIdentifier,
      locationUUID: locationUUID ?? this.locationUUID,
      openDate: openDate ?? this.openDate,
      phone: phone ?? this.phone,
      serviceType: serviceType ?? this.serviceType,
      status: status ?? this.status,
      id: id ?? this.id,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (accountNumber.present) {
      map['account_number'] = Variable<String>(accountNumber.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (area.present) {
      map['area'] = Variable<double>(area.value);
    }
    if (closeDate.present) {
      map['close_date'] = Variable<DateTime>(closeDate.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (fio.present) {
      map['fio'] = Variable<String>(fio.value);
    }
    if (jkuIdentifier.present) {
      map['jku_identifier'] = Variable<String>(jkuIdentifier.value);
    }
    if (locationUUID.present) {
      map['location_u_u_i_d'] = Variable<String>(locationUUID.value);
    }
    if (openDate.present) {
      map['open_date'] = Variable<DateTime>(openDate.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (serviceType.present) {
      map['service_type'] = Variable<String>(serviceType.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MyAccountsCompanion(')
          ..write('accountNumber: $accountNumber, ')
          ..write('address: $address, ')
          ..write('area: $area, ')
          ..write('closeDate: $closeDate, ')
          ..write('email: $email, ')
          ..write('fio: $fio, ')
          ..write('jkuIdentifier: $jkuIdentifier, ')
          ..write('locationUUID: $locationUUID, ')
          ..write('openDate: $openDate, ')
          ..write('phone: $phone, ')
          ..write('serviceType: $serviceType, ')
          ..write('status: $status, ')
          ..write('id: $id')
          ..write(')'))
        .toString();
  }
}

class $PendingChangesTable extends PendingChanges
    with TableInfo<$PendingChangesTable, PendingChangeDb> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingChangesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _actionTypeMeta = const VerificationMeta(
    'actionType',
  );
  @override
  late final GeneratedColumn<String> actionType = GeneratedColumn<String>(
    'action_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<int> entityId = GeneratedColumn<int>(
    'entity_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<Uint8List> payload = GeneratedColumn<Uint8List>(
    'payload',
    aliasedName,
    true,
    type: DriftSqlType.blob,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    actionType,
    createdAt,
    entityId,
    entityType,
    payload,
    priority,
    retryCount,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_changes';
  @override
  VerificationContext validateIntegrity(
    Insertable<PendingChangeDb> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('action_type')) {
      context.handle(
        _actionTypeMeta,
        actionType.isAcceptableOrUnknown(data['action_type']!, _actionTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_actionTypeMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PendingChangeDb map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingChangeDb(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      actionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action_type'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}entity_id'],
      ),
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}payload'],
      ),
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      ),
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $PendingChangesTable createAlias(String alias) {
    return $PendingChangesTable(attachedDatabase, alias);
  }
}

class PendingChangeDb extends DataClass implements Insertable<PendingChangeDb> {
  final int id;
  final String actionType;
  final DateTime createdAt;
  final int? entityId;
  final String entityType;
  final Uint8List? payload;
  final int? priority;
  final int? retryCount;
  final String syncStatus;
  const PendingChangeDb({
    required this.id,
    required this.actionType,
    required this.createdAt,
    this.entityId,
    required this.entityType,
    this.payload,
    this.priority,
    this.retryCount,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['action_type'] = Variable<String>(actionType);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || entityId != null) {
      map['entity_id'] = Variable<int>(entityId);
    }
    map['entity_type'] = Variable<String>(entityType);
    if (!nullToAbsent || payload != null) {
      map['payload'] = Variable<Uint8List>(payload);
    }
    if (!nullToAbsent || priority != null) {
      map['priority'] = Variable<int>(priority);
    }
    if (!nullToAbsent || retryCount != null) {
      map['retry_count'] = Variable<int>(retryCount);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  PendingChangesCompanion toCompanion(bool nullToAbsent) {
    return PendingChangesCompanion(
      id: Value(id),
      actionType: Value(actionType),
      createdAt: Value(createdAt),
      entityId: entityId == null && nullToAbsent
          ? const Value.absent()
          : Value(entityId),
      entityType: Value(entityType),
      payload: payload == null && nullToAbsent
          ? const Value.absent()
          : Value(payload),
      priority: priority == null && nullToAbsent
          ? const Value.absent()
          : Value(priority),
      retryCount: retryCount == null && nullToAbsent
          ? const Value.absent()
          : Value(retryCount),
      syncStatus: Value(syncStatus),
    );
  }

  factory PendingChangeDb.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingChangeDb(
      id: serializer.fromJson<int>(json['id']),
      actionType: serializer.fromJson<String>(json['actionType']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      entityId: serializer.fromJson<int?>(json['entityId']),
      entityType: serializer.fromJson<String>(json['entityType']),
      payload: serializer.fromJson<Uint8List?>(json['payload']),
      priority: serializer.fromJson<int?>(json['priority']),
      retryCount: serializer.fromJson<int?>(json['retryCount']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'actionType': serializer.toJson<String>(actionType),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'entityId': serializer.toJson<int?>(entityId),
      'entityType': serializer.toJson<String>(entityType),
      'payload': serializer.toJson<Uint8List?>(payload),
      'priority': serializer.toJson<int?>(priority),
      'retryCount': serializer.toJson<int?>(retryCount),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  PendingChangeDb copyWith({
    int? id,
    String? actionType,
    DateTime? createdAt,
    Value<int?> entityId = const Value.absent(),
    String? entityType,
    Value<Uint8List?> payload = const Value.absent(),
    Value<int?> priority = const Value.absent(),
    Value<int?> retryCount = const Value.absent(),
    String? syncStatus,
  }) => PendingChangeDb(
    id: id ?? this.id,
    actionType: actionType ?? this.actionType,
    createdAt: createdAt ?? this.createdAt,
    entityId: entityId.present ? entityId.value : this.entityId,
    entityType: entityType ?? this.entityType,
    payload: payload.present ? payload.value : this.payload,
    priority: priority.present ? priority.value : this.priority,
    retryCount: retryCount.present ? retryCount.value : this.retryCount,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  PendingChangeDb copyWithCompanion(PendingChangesCompanion data) {
    return PendingChangeDb(
      id: data.id.present ? data.id.value : this.id,
      actionType: data.actionType.present
          ? data.actionType.value
          : this.actionType,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      payload: data.payload.present ? data.payload.value : this.payload,
      priority: data.priority.present ? data.priority.value : this.priority,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingChangeDb(')
          ..write('id: $id, ')
          ..write('actionType: $actionType, ')
          ..write('createdAt: $createdAt, ')
          ..write('entityId: $entityId, ')
          ..write('entityType: $entityType, ')
          ..write('payload: $payload, ')
          ..write('priority: $priority, ')
          ..write('retryCount: $retryCount, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    actionType,
    createdAt,
    entityId,
    entityType,
    $driftBlobEquality.hash(payload),
    priority,
    retryCount,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingChangeDb &&
          other.id == this.id &&
          other.actionType == this.actionType &&
          other.createdAt == this.createdAt &&
          other.entityId == this.entityId &&
          other.entityType == this.entityType &&
          $driftBlobEquality.equals(other.payload, this.payload) &&
          other.priority == this.priority &&
          other.retryCount == this.retryCount &&
          other.syncStatus == this.syncStatus);
}

class PendingChangesCompanion extends UpdateCompanion<PendingChangeDb> {
  final Value<int> id;
  final Value<String> actionType;
  final Value<DateTime> createdAt;
  final Value<int?> entityId;
  final Value<String> entityType;
  final Value<Uint8List?> payload;
  final Value<int?> priority;
  final Value<int?> retryCount;
  final Value<String> syncStatus;
  const PendingChangesCompanion({
    this.id = const Value.absent(),
    this.actionType = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.entityId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.payload = const Value.absent(),
    this.priority = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.syncStatus = const Value.absent(),
  });
  PendingChangesCompanion.insert({
    this.id = const Value.absent(),
    required String actionType,
    required DateTime createdAt,
    this.entityId = const Value.absent(),
    required String entityType,
    this.payload = const Value.absent(),
    this.priority = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.syncStatus = const Value.absent(),
  }) : actionType = Value(actionType),
       createdAt = Value(createdAt),
       entityType = Value(entityType);
  static Insertable<PendingChangeDb> custom({
    Expression<int>? id,
    Expression<String>? actionType,
    Expression<DateTime>? createdAt,
    Expression<int>? entityId,
    Expression<String>? entityType,
    Expression<Uint8List>? payload,
    Expression<int>? priority,
    Expression<int>? retryCount,
    Expression<String>? syncStatus,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (actionType != null) 'action_type': actionType,
      if (createdAt != null) 'created_at': createdAt,
      if (entityId != null) 'entity_id': entityId,
      if (entityType != null) 'entity_type': entityType,
      if (payload != null) 'payload': payload,
      if (priority != null) 'priority': priority,
      if (retryCount != null) 'retry_count': retryCount,
      if (syncStatus != null) 'sync_status': syncStatus,
    });
  }

  PendingChangesCompanion copyWith({
    Value<int>? id,
    Value<String>? actionType,
    Value<DateTime>? createdAt,
    Value<int?>? entityId,
    Value<String>? entityType,
    Value<Uint8List?>? payload,
    Value<int?>? priority,
    Value<int?>? retryCount,
    Value<String>? syncStatus,
  }) {
    return PendingChangesCompanion(
      id: id ?? this.id,
      actionType: actionType ?? this.actionType,
      createdAt: createdAt ?? this.createdAt,
      entityId: entityId ?? this.entityId,
      entityType: entityType ?? this.entityType,
      payload: payload ?? this.payload,
      priority: priority ?? this.priority,
      retryCount: retryCount ?? this.retryCount,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (actionType.present) {
      map['action_type'] = Variable<String>(actionType.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<int>(entityId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (payload.present) {
      map['payload'] = Variable<Uint8List>(payload.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingChangesCompanion(')
          ..write('id: $id, ')
          ..write('actionType: $actionType, ')
          ..write('createdAt: $createdAt, ')
          ..write('entityId: $entityId, ')
          ..write('entityType: $entityType, ')
          ..write('payload: $payload, ')
          ..write('priority: $priority, ')
          ..write('retryCount: $retryCount, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }
}

class $SyncMetadataTable extends SyncMetadata
    with TableInfo<$SyncMetadataTable, SyncMetadataDb> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncMetadataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _syncKeyMeta = const VerificationMeta(
    'syncKey',
  );
  @override
  late final GeneratedColumn<String> syncKey = GeneratedColumn<String>(
    'sync_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastActionIdMeta = const VerificationMeta(
    'lastActionId',
  );
  @override
  late final GeneratedColumn<int> lastActionId = GeneratedColumn<int>(
    'last_action_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastQueriedAtMeta = const VerificationMeta(
    'lastQueriedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastQueriedAt =
      GeneratedColumn<DateTime>(
        'last_queried_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [syncKey, lastActionId, lastQueriedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_metadata';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncMetadataDb> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sync_key')) {
      context.handle(
        _syncKeyMeta,
        syncKey.isAcceptableOrUnknown(data['sync_key']!, _syncKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_syncKeyMeta);
    }
    if (data.containsKey('last_action_id')) {
      context.handle(
        _lastActionIdMeta,
        lastActionId.isAcceptableOrUnknown(
          data['last_action_id']!,
          _lastActionIdMeta,
        ),
      );
    }
    if (data.containsKey('last_queried_at')) {
      context.handle(
        _lastQueriedAtMeta,
        lastQueriedAt.isAcceptableOrUnknown(
          data['last_queried_at']!,
          _lastQueriedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {syncKey};
  @override
  SyncMetadataDb map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncMetadataDb(
      syncKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_key'],
      )!,
      lastActionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_action_id'],
      )!,
      lastQueriedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_queried_at'],
      ),
    );
  }

  @override
  $SyncMetadataTable createAlias(String alias) {
    return $SyncMetadataTable(attachedDatabase, alias);
  }
}

class SyncMetadataDb extends DataClass implements Insertable<SyncMetadataDb> {
  final String syncKey;
  final int lastActionId;
  final DateTime? lastQueriedAt;
  const SyncMetadataDb({
    required this.syncKey,
    required this.lastActionId,
    this.lastQueriedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sync_key'] = Variable<String>(syncKey);
    map['last_action_id'] = Variable<int>(lastActionId);
    if (!nullToAbsent || lastQueriedAt != null) {
      map['last_queried_at'] = Variable<DateTime>(lastQueriedAt);
    }
    return map;
  }

  SyncMetadataCompanion toCompanion(bool nullToAbsent) {
    return SyncMetadataCompanion(
      syncKey: Value(syncKey),
      lastActionId: Value(lastActionId),
      lastQueriedAt: lastQueriedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastQueriedAt),
    );
  }

  factory SyncMetadataDb.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncMetadataDb(
      syncKey: serializer.fromJson<String>(json['syncKey']),
      lastActionId: serializer.fromJson<int>(json['lastActionId']),
      lastQueriedAt: serializer.fromJson<DateTime?>(json['lastQueriedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'syncKey': serializer.toJson<String>(syncKey),
      'lastActionId': serializer.toJson<int>(lastActionId),
      'lastQueriedAt': serializer.toJson<DateTime?>(lastQueriedAt),
    };
  }

  SyncMetadataDb copyWith({
    String? syncKey,
    int? lastActionId,
    Value<DateTime?> lastQueriedAt = const Value.absent(),
  }) => SyncMetadataDb(
    syncKey: syncKey ?? this.syncKey,
    lastActionId: lastActionId ?? this.lastActionId,
    lastQueriedAt: lastQueriedAt.present
        ? lastQueriedAt.value
        : this.lastQueriedAt,
  );
  SyncMetadataDb copyWithCompanion(SyncMetadataCompanion data) {
    return SyncMetadataDb(
      syncKey: data.syncKey.present ? data.syncKey.value : this.syncKey,
      lastActionId: data.lastActionId.present
          ? data.lastActionId.value
          : this.lastActionId,
      lastQueriedAt: data.lastQueriedAt.present
          ? data.lastQueriedAt.value
          : this.lastQueriedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetadataDb(')
          ..write('syncKey: $syncKey, ')
          ..write('lastActionId: $lastActionId, ')
          ..write('lastQueriedAt: $lastQueriedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(syncKey, lastActionId, lastQueriedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncMetadataDb &&
          other.syncKey == this.syncKey &&
          other.lastActionId == this.lastActionId &&
          other.lastQueriedAt == this.lastQueriedAt);
}

class SyncMetadataCompanion extends UpdateCompanion<SyncMetadataDb> {
  final Value<String> syncKey;
  final Value<int> lastActionId;
  final Value<DateTime?> lastQueriedAt;
  final Value<int> rowid;
  const SyncMetadataCompanion({
    this.syncKey = const Value.absent(),
    this.lastActionId = const Value.absent(),
    this.lastQueriedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncMetadataCompanion.insert({
    required String syncKey,
    this.lastActionId = const Value.absent(),
    this.lastQueriedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : syncKey = Value(syncKey);
  static Insertable<SyncMetadataDb> custom({
    Expression<String>? syncKey,
    Expression<int>? lastActionId,
    Expression<DateTime>? lastQueriedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (syncKey != null) 'sync_key': syncKey,
      if (lastActionId != null) 'last_action_id': lastActionId,
      if (lastQueriedAt != null) 'last_queried_at': lastQueriedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncMetadataCompanion copyWith({
    Value<String>? syncKey,
    Value<int>? lastActionId,
    Value<DateTime?>? lastQueriedAt,
    Value<int>? rowid,
  }) {
    return SyncMetadataCompanion(
      syncKey: syncKey ?? this.syncKey,
      lastActionId: lastActionId ?? this.lastActionId,
      lastQueriedAt: lastQueriedAt ?? this.lastQueriedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (syncKey.present) {
      map['sync_key'] = Variable<String>(syncKey.value);
    }
    if (lastActionId.present) {
      map['last_action_id'] = Variable<int>(lastActionId.value);
    }
    if (lastQueriedAt.present) {
      map['last_queried_at'] = Variable<DateTime>(lastQueriedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetadataCompanion(')
          ..write('syncKey: $syncKey, ')
          ..write('lastActionId: $lastActionId, ')
          ..write('lastQueriedAt: $lastQueriedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ActionLogsTable actionLogs = $ActionLogsTable(this);
  late final $AppUsersTable appUsers = $AppUsersTable(this);
  late final $BoilerHousesTable boilerHouses = $BoilerHousesTable(this);
  late final $BoilerPhotosTable boilerPhotos = $BoilerPhotosTable(this);
  late final $ManagementCompaniesTable managementCompanies =
      $ManagementCompaniesTable(this);
  late final $SavedLocationsTable savedLocations = $SavedLocationsTable(this);
  late final $HousePhotosTable housePhotos = $HousePhotosTable(this);
  late final $IncidentsTable incidents = $IncidentsTable(this);
  late final $AffectedHousesTable affectedHouses = $AffectedHousesTable(this);
  late final $IncidentCommentsTable incidentComments = $IncidentCommentsTable(
    this,
  );
  late final $IncidentPhotosTable incidentPhotos = $IncidentPhotosTable(this);
  late final $MyAccountsTable myAccounts = $MyAccountsTable(this);
  late final $PendingChangesTable pendingChanges = $PendingChangesTable(this);
  late final $SyncMetadataTable syncMetadata = $SyncMetadataTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    actionLogs,
    appUsers,
    boilerHouses,
    boilerPhotos,
    managementCompanies,
    savedLocations,
    housePhotos,
    incidents,
    affectedHouses,
    incidentComments,
    incidentPhotos,
    myAccounts,
    pendingChanges,
    syncMetadata,
  ];
}

typedef $$ActionLogsTableCreateCompanionBuilder =
    ActionLogsCompanion Function({
      required String id,
      Value<int?> actionIdRaw,
      Value<String?> boilerHouseID,
      Value<String?> locationID,
      required String message,
      Value<Uint8List?> metadata,
      Value<String?> scope,
      Value<String?> screen,
      required DateTime timestamp,
      required String type,
      Value<String?> userId,
      Value<String?> userName,
      Value<int> rowid,
    });
typedef $$ActionLogsTableUpdateCompanionBuilder =
    ActionLogsCompanion Function({
      Value<String> id,
      Value<int?> actionIdRaw,
      Value<String?> boilerHouseID,
      Value<String?> locationID,
      Value<String> message,
      Value<Uint8List?> metadata,
      Value<String?> scope,
      Value<String?> screen,
      Value<DateTime> timestamp,
      Value<String> type,
      Value<String?> userId,
      Value<String?> userName,
      Value<int> rowid,
    });

class $$ActionLogsTableFilterComposer
    extends Composer<_$AppDatabase, $ActionLogsTable> {
  $$ActionLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get actionIdRaw => $composableBuilder(
    column: $table.actionIdRaw,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get boilerHouseID => $composableBuilder(
    column: $table.boilerHouseID,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locationID => $composableBuilder(
    column: $table.locationID,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get screen => $composableBuilder(
    column: $table.screen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userName => $composableBuilder(
    column: $table.userName,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ActionLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $ActionLogsTable> {
  $$ActionLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get actionIdRaw => $composableBuilder(
    column: $table.actionIdRaw,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get boilerHouseID => $composableBuilder(
    column: $table.boilerHouseID,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locationID => $composableBuilder(
    column: $table.locationID,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get screen => $composableBuilder(
    column: $table.screen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userName => $composableBuilder(
    column: $table.userName,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ActionLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActionLogsTable> {
  $$ActionLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get actionIdRaw => $composableBuilder(
    column: $table.actionIdRaw,
    builder: (column) => column,
  );

  GeneratedColumn<String> get boilerHouseID => $composableBuilder(
    column: $table.boilerHouseID,
    builder: (column) => column,
  );

  GeneratedColumn<String> get locationID => $composableBuilder(
    column: $table.locationID,
    builder: (column) => column,
  );

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<Uint8List> get metadata =>
      $composableBuilder(column: $table.metadata, builder: (column) => column);

  GeneratedColumn<String> get scope =>
      $composableBuilder(column: $table.scope, builder: (column) => column);

  GeneratedColumn<String> get screen =>
      $composableBuilder(column: $table.screen, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get userName =>
      $composableBuilder(column: $table.userName, builder: (column) => column);
}

class $$ActionLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ActionLogsTable,
          ActionLogDb,
          $$ActionLogsTableFilterComposer,
          $$ActionLogsTableOrderingComposer,
          $$ActionLogsTableAnnotationComposer,
          $$ActionLogsTableCreateCompanionBuilder,
          $$ActionLogsTableUpdateCompanionBuilder,
          (
            ActionLogDb,
            BaseReferences<_$AppDatabase, $ActionLogsTable, ActionLogDb>,
          ),
          ActionLogDb,
          PrefetchHooks Function()
        > {
  $$ActionLogsTableTableManager(_$AppDatabase db, $ActionLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActionLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActionLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActionLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int?> actionIdRaw = const Value.absent(),
                Value<String?> boilerHouseID = const Value.absent(),
                Value<String?> locationID = const Value.absent(),
                Value<String> message = const Value.absent(),
                Value<Uint8List?> metadata = const Value.absent(),
                Value<String?> scope = const Value.absent(),
                Value<String?> screen = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String?> userName = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActionLogsCompanion(
                id: id,
                actionIdRaw: actionIdRaw,
                boilerHouseID: boilerHouseID,
                locationID: locationID,
                message: message,
                metadata: metadata,
                scope: scope,
                screen: screen,
                timestamp: timestamp,
                type: type,
                userId: userId,
                userName: userName,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<int?> actionIdRaw = const Value.absent(),
                Value<String?> boilerHouseID = const Value.absent(),
                Value<String?> locationID = const Value.absent(),
                required String message,
                Value<Uint8List?> metadata = const Value.absent(),
                Value<String?> scope = const Value.absent(),
                Value<String?> screen = const Value.absent(),
                required DateTime timestamp,
                required String type,
                Value<String?> userId = const Value.absent(),
                Value<String?> userName = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActionLogsCompanion.insert(
                id: id,
                actionIdRaw: actionIdRaw,
                boilerHouseID: boilerHouseID,
                locationID: locationID,
                message: message,
                metadata: metadata,
                scope: scope,
                screen: screen,
                timestamp: timestamp,
                type: type,
                userId: userId,
                userName: userName,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ActionLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ActionLogsTable,
      ActionLogDb,
      $$ActionLogsTableFilterComposer,
      $$ActionLogsTableOrderingComposer,
      $$ActionLogsTableAnnotationComposer,
      $$ActionLogsTableCreateCompanionBuilder,
      $$ActionLogsTableUpdateCompanionBuilder,
      (
        ActionLogDb,
        BaseReferences<_$AppDatabase, $ActionLogsTable, ActionLogDb>,
      ),
      ActionLogDb,
      PrefetchHooks Function()
    >;
typedef $$AppUsersTableCreateCompanionBuilder =
    AppUsersCompanion Function({
      Value<String?> activeStatus,
      Value<DateTime?> blockedAt,
      Value<String?> blockedBy,
      Value<String?> blockedReason,
      Value<DateTime?> createdAt,
      Value<String?> createdBy,
      Value<String?> customPermissions,
      Value<DateTime?> deactivatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> deletedBy,
      Value<String?> displayName,
      Value<bool> emailVerified,
      Value<String?> fullName,
      Value<DateTime?> inviteSentAt,
      Value<String?> inviteToken,
      Value<bool> isActive,
      Value<bool> isAdmin,
      Value<bool> isBlocked,
      Value<bool> isInvitePending,
      Value<bool> isOnline,
      Value<bool> isSoftDeleted,
      Value<bool> isSystem,
      Value<DateTime?> lastActiveAt,
      Value<DateTime?> lastLoginAt,
      Value<DateTime?> lastPasswordResetAt,
      Value<Uint8List?> metadata,
      Value<bool> needsPasswordReset,
      Value<String?> notes,
      required String passwordHash,
      Value<String?> passwordSalt,
      Value<DateTime?> passwordUpdatedAt,
      Value<String?> phone,
      Value<bool> phoneVerified,
      Value<String?> role,
      Value<String?> roleId,
      Value<String?> roleSnapshot,
      Value<DateTime?> statusChangedAt,
      Value<String?> statusReason,
      Value<DateTime?> updatedAt,
      Value<String?> updatedBy,
      Value<String?> userEmail,
      Value<String?> userId,
      Value<String?> username,
      Value<String?> verificationCode,
      Value<int> id,
    });
typedef $$AppUsersTableUpdateCompanionBuilder =
    AppUsersCompanion Function({
      Value<String?> activeStatus,
      Value<DateTime?> blockedAt,
      Value<String?> blockedBy,
      Value<String?> blockedReason,
      Value<DateTime?> createdAt,
      Value<String?> createdBy,
      Value<String?> customPermissions,
      Value<DateTime?> deactivatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> deletedBy,
      Value<String?> displayName,
      Value<bool> emailVerified,
      Value<String?> fullName,
      Value<DateTime?> inviteSentAt,
      Value<String?> inviteToken,
      Value<bool> isActive,
      Value<bool> isAdmin,
      Value<bool> isBlocked,
      Value<bool> isInvitePending,
      Value<bool> isOnline,
      Value<bool> isSoftDeleted,
      Value<bool> isSystem,
      Value<DateTime?> lastActiveAt,
      Value<DateTime?> lastLoginAt,
      Value<DateTime?> lastPasswordResetAt,
      Value<Uint8List?> metadata,
      Value<bool> needsPasswordReset,
      Value<String?> notes,
      Value<String> passwordHash,
      Value<String?> passwordSalt,
      Value<DateTime?> passwordUpdatedAt,
      Value<String?> phone,
      Value<bool> phoneVerified,
      Value<String?> role,
      Value<String?> roleId,
      Value<String?> roleSnapshot,
      Value<DateTime?> statusChangedAt,
      Value<String?> statusReason,
      Value<DateTime?> updatedAt,
      Value<String?> updatedBy,
      Value<String?> userEmail,
      Value<String?> userId,
      Value<String?> username,
      Value<String?> verificationCode,
      Value<int> id,
    });

class $$AppUsersTableFilterComposer
    extends Composer<_$AppDatabase, $AppUsersTable> {
  $$AppUsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get activeStatus => $composableBuilder(
    column: $table.activeStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get blockedAt => $composableBuilder(
    column: $table.blockedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get blockedBy => $composableBuilder(
    column: $table.blockedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get blockedReason => $composableBuilder(
    column: $table.blockedReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customPermissions => $composableBuilder(
    column: $table.customPermissions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deactivatedAt => $composableBuilder(
    column: $table.deactivatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedBy => $composableBuilder(
    column: $table.deletedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get emailVerified => $composableBuilder(
    column: $table.emailVerified,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get inviteSentAt => $composableBuilder(
    column: $table.inviteSentAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get inviteToken => $composableBuilder(
    column: $table.inviteToken,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAdmin => $composableBuilder(
    column: $table.isAdmin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isBlocked => $composableBuilder(
    column: $table.isBlocked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isInvitePending => $composableBuilder(
    column: $table.isInvitePending,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isOnline => $composableBuilder(
    column: $table.isOnline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSoftDeleted => $composableBuilder(
    column: $table.isSoftDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastActiveAt => $composableBuilder(
    column: $table.lastActiveAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastLoginAt => $composableBuilder(
    column: $table.lastLoginAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastPasswordResetAt => $composableBuilder(
    column: $table.lastPasswordResetAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get needsPasswordReset => $composableBuilder(
    column: $table.needsPasswordReset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get passwordSalt => $composableBuilder(
    column: $table.passwordSalt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get passwordUpdatedAt => $composableBuilder(
    column: $table.passwordUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get phoneVerified => $composableBuilder(
    column: $table.phoneVerified,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get roleId => $composableBuilder(
    column: $table.roleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get roleSnapshot => $composableBuilder(
    column: $table.roleSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get statusChangedAt => $composableBuilder(
    column: $table.statusChangedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get statusReason => $composableBuilder(
    column: $table.statusReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userEmail => $composableBuilder(
    column: $table.userEmail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get verificationCode => $composableBuilder(
    column: $table.verificationCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppUsersTableOrderingComposer
    extends Composer<_$AppDatabase, $AppUsersTable> {
  $$AppUsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get activeStatus => $composableBuilder(
    column: $table.activeStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get blockedAt => $composableBuilder(
    column: $table.blockedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get blockedBy => $composableBuilder(
    column: $table.blockedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get blockedReason => $composableBuilder(
    column: $table.blockedReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customPermissions => $composableBuilder(
    column: $table.customPermissions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deactivatedAt => $composableBuilder(
    column: $table.deactivatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedBy => $composableBuilder(
    column: $table.deletedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get emailVerified => $composableBuilder(
    column: $table.emailVerified,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get inviteSentAt => $composableBuilder(
    column: $table.inviteSentAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get inviteToken => $composableBuilder(
    column: $table.inviteToken,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAdmin => $composableBuilder(
    column: $table.isAdmin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isBlocked => $composableBuilder(
    column: $table.isBlocked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isInvitePending => $composableBuilder(
    column: $table.isInvitePending,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isOnline => $composableBuilder(
    column: $table.isOnline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSoftDeleted => $composableBuilder(
    column: $table.isSoftDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastActiveAt => $composableBuilder(
    column: $table.lastActiveAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastLoginAt => $composableBuilder(
    column: $table.lastLoginAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastPasswordResetAt => $composableBuilder(
    column: $table.lastPasswordResetAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get needsPasswordReset => $composableBuilder(
    column: $table.needsPasswordReset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get passwordSalt => $composableBuilder(
    column: $table.passwordSalt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get passwordUpdatedAt => $composableBuilder(
    column: $table.passwordUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get phoneVerified => $composableBuilder(
    column: $table.phoneVerified,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get roleId => $composableBuilder(
    column: $table.roleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get roleSnapshot => $composableBuilder(
    column: $table.roleSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get statusChangedAt => $composableBuilder(
    column: $table.statusChangedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get statusReason => $composableBuilder(
    column: $table.statusReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userEmail => $composableBuilder(
    column: $table.userEmail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get verificationCode => $composableBuilder(
    column: $table.verificationCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppUsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppUsersTable> {
  $$AppUsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get activeStatus => $composableBuilder(
    column: $table.activeStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get blockedAt =>
      $composableBuilder(column: $table.blockedAt, builder: (column) => column);

  GeneratedColumn<String> get blockedBy =>
      $composableBuilder(column: $table.blockedBy, builder: (column) => column);

  GeneratedColumn<String> get blockedReason => $composableBuilder(
    column: $table.blockedReason,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get customPermissions => $composableBuilder(
    column: $table.customPermissions,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deactivatedAt => $composableBuilder(
    column: $table.deactivatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deletedBy =>
      $composableBuilder(column: $table.deletedBy, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get emailVerified => $composableBuilder(
    column: $table.emailVerified,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<DateTime> get inviteSentAt => $composableBuilder(
    column: $table.inviteSentAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get inviteToken => $composableBuilder(
    column: $table.inviteToken,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<bool> get isAdmin =>
      $composableBuilder(column: $table.isAdmin, builder: (column) => column);

  GeneratedColumn<bool> get isBlocked =>
      $composableBuilder(column: $table.isBlocked, builder: (column) => column);

  GeneratedColumn<bool> get isInvitePending => $composableBuilder(
    column: $table.isInvitePending,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isOnline =>
      $composableBuilder(column: $table.isOnline, builder: (column) => column);

  GeneratedColumn<bool> get isSoftDeleted => $composableBuilder(
    column: $table.isSoftDeleted,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSystem =>
      $composableBuilder(column: $table.isSystem, builder: (column) => column);

  GeneratedColumn<DateTime> get lastActiveAt => $composableBuilder(
    column: $table.lastActiveAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastLoginAt => $composableBuilder(
    column: $table.lastLoginAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastPasswordResetAt => $composableBuilder(
    column: $table.lastPasswordResetAt,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get metadata =>
      $composableBuilder(column: $table.metadata, builder: (column) => column);

  GeneratedColumn<bool> get needsPasswordReset => $composableBuilder(
    column: $table.needsPasswordReset,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => column,
  );

  GeneratedColumn<String> get passwordSalt => $composableBuilder(
    column: $table.passwordSalt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get passwordUpdatedAt => $composableBuilder(
    column: $table.passwordUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<bool> get phoneVerified => $composableBuilder(
    column: $table.phoneVerified,
    builder: (column) => column,
  );

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get roleId =>
      $composableBuilder(column: $table.roleId, builder: (column) => column);

  GeneratedColumn<String> get roleSnapshot => $composableBuilder(
    column: $table.roleSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get statusChangedAt => $composableBuilder(
    column: $table.statusChangedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get statusReason => $composableBuilder(
    column: $table.statusReason,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => column);

  GeneratedColumn<String> get userEmail =>
      $composableBuilder(column: $table.userEmail, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get verificationCode => $composableBuilder(
    column: $table.verificationCode,
    builder: (column) => column,
  );

  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);
}

class $$AppUsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppUsersTable,
          AppUserDb,
          $$AppUsersTableFilterComposer,
          $$AppUsersTableOrderingComposer,
          $$AppUsersTableAnnotationComposer,
          $$AppUsersTableCreateCompanionBuilder,
          $$AppUsersTableUpdateCompanionBuilder,
          (AppUserDb, BaseReferences<_$AppDatabase, $AppUsersTable, AppUserDb>),
          AppUserDb,
          PrefetchHooks Function()
        > {
  $$AppUsersTableTableManager(_$AppDatabase db, $AppUsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppUsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppUsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppUsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String?> activeStatus = const Value.absent(),
                Value<DateTime?> blockedAt = const Value.absent(),
                Value<String?> blockedBy = const Value.absent(),
                Value<String?> blockedReason = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String?> customPermissions = const Value.absent(),
                Value<DateTime?> deactivatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> deletedBy = const Value.absent(),
                Value<String?> displayName = const Value.absent(),
                Value<bool> emailVerified = const Value.absent(),
                Value<String?> fullName = const Value.absent(),
                Value<DateTime?> inviteSentAt = const Value.absent(),
                Value<String?> inviteToken = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<bool> isAdmin = const Value.absent(),
                Value<bool> isBlocked = const Value.absent(),
                Value<bool> isInvitePending = const Value.absent(),
                Value<bool> isOnline = const Value.absent(),
                Value<bool> isSoftDeleted = const Value.absent(),
                Value<bool> isSystem = const Value.absent(),
                Value<DateTime?> lastActiveAt = const Value.absent(),
                Value<DateTime?> lastLoginAt = const Value.absent(),
                Value<DateTime?> lastPasswordResetAt = const Value.absent(),
                Value<Uint8List?> metadata = const Value.absent(),
                Value<bool> needsPasswordReset = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> passwordHash = const Value.absent(),
                Value<String?> passwordSalt = const Value.absent(),
                Value<DateTime?> passwordUpdatedAt = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<bool> phoneVerified = const Value.absent(),
                Value<String?> role = const Value.absent(),
                Value<String?> roleId = const Value.absent(),
                Value<String?> roleSnapshot = const Value.absent(),
                Value<DateTime?> statusChangedAt = const Value.absent(),
                Value<String?> statusReason = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                Value<String?> userEmail = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String?> username = const Value.absent(),
                Value<String?> verificationCode = const Value.absent(),
                Value<int> id = const Value.absent(),
              }) => AppUsersCompanion(
                activeStatus: activeStatus,
                blockedAt: blockedAt,
                blockedBy: blockedBy,
                blockedReason: blockedReason,
                createdAt: createdAt,
                createdBy: createdBy,
                customPermissions: customPermissions,
                deactivatedAt: deactivatedAt,
                deletedAt: deletedAt,
                deletedBy: deletedBy,
                displayName: displayName,
                emailVerified: emailVerified,
                fullName: fullName,
                inviteSentAt: inviteSentAt,
                inviteToken: inviteToken,
                isActive: isActive,
                isAdmin: isAdmin,
                isBlocked: isBlocked,
                isInvitePending: isInvitePending,
                isOnline: isOnline,
                isSoftDeleted: isSoftDeleted,
                isSystem: isSystem,
                lastActiveAt: lastActiveAt,
                lastLoginAt: lastLoginAt,
                lastPasswordResetAt: lastPasswordResetAt,
                metadata: metadata,
                needsPasswordReset: needsPasswordReset,
                notes: notes,
                passwordHash: passwordHash,
                passwordSalt: passwordSalt,
                passwordUpdatedAt: passwordUpdatedAt,
                phone: phone,
                phoneVerified: phoneVerified,
                role: role,
                roleId: roleId,
                roleSnapshot: roleSnapshot,
                statusChangedAt: statusChangedAt,
                statusReason: statusReason,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                userEmail: userEmail,
                userId: userId,
                username: username,
                verificationCode: verificationCode,
                id: id,
              ),
          createCompanionCallback:
              ({
                Value<String?> activeStatus = const Value.absent(),
                Value<DateTime?> blockedAt = const Value.absent(),
                Value<String?> blockedBy = const Value.absent(),
                Value<String?> blockedReason = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String?> customPermissions = const Value.absent(),
                Value<DateTime?> deactivatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> deletedBy = const Value.absent(),
                Value<String?> displayName = const Value.absent(),
                Value<bool> emailVerified = const Value.absent(),
                Value<String?> fullName = const Value.absent(),
                Value<DateTime?> inviteSentAt = const Value.absent(),
                Value<String?> inviteToken = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<bool> isAdmin = const Value.absent(),
                Value<bool> isBlocked = const Value.absent(),
                Value<bool> isInvitePending = const Value.absent(),
                Value<bool> isOnline = const Value.absent(),
                Value<bool> isSoftDeleted = const Value.absent(),
                Value<bool> isSystem = const Value.absent(),
                Value<DateTime?> lastActiveAt = const Value.absent(),
                Value<DateTime?> lastLoginAt = const Value.absent(),
                Value<DateTime?> lastPasswordResetAt = const Value.absent(),
                Value<Uint8List?> metadata = const Value.absent(),
                Value<bool> needsPasswordReset = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required String passwordHash,
                Value<String?> passwordSalt = const Value.absent(),
                Value<DateTime?> passwordUpdatedAt = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<bool> phoneVerified = const Value.absent(),
                Value<String?> role = const Value.absent(),
                Value<String?> roleId = const Value.absent(),
                Value<String?> roleSnapshot = const Value.absent(),
                Value<DateTime?> statusChangedAt = const Value.absent(),
                Value<String?> statusReason = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                Value<String?> userEmail = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String?> username = const Value.absent(),
                Value<String?> verificationCode = const Value.absent(),
                Value<int> id = const Value.absent(),
              }) => AppUsersCompanion.insert(
                activeStatus: activeStatus,
                blockedAt: blockedAt,
                blockedBy: blockedBy,
                blockedReason: blockedReason,
                createdAt: createdAt,
                createdBy: createdBy,
                customPermissions: customPermissions,
                deactivatedAt: deactivatedAt,
                deletedAt: deletedAt,
                deletedBy: deletedBy,
                displayName: displayName,
                emailVerified: emailVerified,
                fullName: fullName,
                inviteSentAt: inviteSentAt,
                inviteToken: inviteToken,
                isActive: isActive,
                isAdmin: isAdmin,
                isBlocked: isBlocked,
                isInvitePending: isInvitePending,
                isOnline: isOnline,
                isSoftDeleted: isSoftDeleted,
                isSystem: isSystem,
                lastActiveAt: lastActiveAt,
                lastLoginAt: lastLoginAt,
                lastPasswordResetAt: lastPasswordResetAt,
                metadata: metadata,
                needsPasswordReset: needsPasswordReset,
                notes: notes,
                passwordHash: passwordHash,
                passwordSalt: passwordSalt,
                passwordUpdatedAt: passwordUpdatedAt,
                phone: phone,
                phoneVerified: phoneVerified,
                role: role,
                roleId: roleId,
                roleSnapshot: roleSnapshot,
                statusChangedAt: statusChangedAt,
                statusReason: statusReason,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                userEmail: userEmail,
                userId: userId,
                username: username,
                verificationCode: verificationCode,
                id: id,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppUsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppUsersTable,
      AppUserDb,
      $$AppUsersTableFilterComposer,
      $$AppUsersTableOrderingComposer,
      $$AppUsersTableAnnotationComposer,
      $$AppUsersTableCreateCompanionBuilder,
      $$AppUsersTableUpdateCompanionBuilder,
      (AppUserDb, BaseReferences<_$AppDatabase, $AppUsersTable, AppUserDb>),
      AppUserDb,
      PrefetchHooks Function()
    >;
typedef $$BoilerHousesTableCreateCompanionBuilder =
    BoilerHousesCompanion Function({
      Value<int> backendId,
      Value<String?> boilerHouseUUID,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<String?> name,
      Value<String?> siteManager,
      Value<String?> siteNumber,
      Value<DateTime?> updatedAt,
    });
typedef $$BoilerHousesTableUpdateCompanionBuilder =
    BoilerHousesCompanion Function({
      Value<int> backendId,
      Value<String?> boilerHouseUUID,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<String?> name,
      Value<String?> siteManager,
      Value<String?> siteNumber,
      Value<DateTime?> updatedAt,
    });

final class $$BoilerHousesTableReferences
    extends BaseReferences<_$AppDatabase, $BoilerHousesTable, BoilerHouseDb> {
  $$BoilerHousesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$BoilerPhotosTable, List<BoilerPhotoDb>>
  _boilerPhotosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.boilerPhotos,
    aliasName: $_aliasNameGenerator(
      db.boilerHouses.backendId,
      db.boilerPhotos.boilerHouseId,
    ),
  );

  $$BoilerPhotosTableProcessedTableManager get boilerPhotosRefs {
    final manager = $$BoilerPhotosTableTableManager($_db, $_db.boilerPhotos)
        .filter(
          (f) => f.boilerHouseId.backendId.sqlEquals(
            $_itemColumn<int>('backend_id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(_boilerPhotosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SavedLocationsTable, List<SavedLocationDb>>
  _savedLocationsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.savedLocations,
    aliasName: $_aliasNameGenerator(
      db.boilerHouses.backendId,
      db.savedLocations.boilerHouseId,
    ),
  );

  $$SavedLocationsTableProcessedTableManager get savedLocationsRefs {
    final manager = $$SavedLocationsTableTableManager($_db, $_db.savedLocations)
        .filter(
          (f) => f.boilerHouseId.backendId.sqlEquals(
            $_itemColumn<int>('backend_id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(_savedLocationsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$IncidentsTable, List<IncidentDb>>
  _incidentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.incidents,
    aliasName: $_aliasNameGenerator(
      db.boilerHouses.backendId,
      db.incidents.boilerHouseId,
    ),
  );

  $$IncidentsTableProcessedTableManager get incidentsRefs {
    final manager = $$IncidentsTableTableManager($_db, $_db.incidents).filter(
      (f) =>
          f.boilerHouseId.backendId.sqlEquals($_itemColumn<int>('backend_id')!),
    );

    final cache = $_typedResult.readTableOrNull(_incidentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BoilerHousesTableFilterComposer
    extends Composer<_$AppDatabase, $BoilerHousesTable> {
  $$BoilerHousesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get backendId => $composableBuilder(
    column: $table.backendId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get boilerHouseUUID => $composableBuilder(
    column: $table.boilerHouseUUID,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get siteManager => $composableBuilder(
    column: $table.siteManager,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get siteNumber => $composableBuilder(
    column: $table.siteNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> boilerPhotosRefs(
    Expression<bool> Function($$BoilerPhotosTableFilterComposer f) f,
  ) {
    final $$BoilerPhotosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.backendId,
      referencedTable: $db.boilerPhotos,
      getReferencedColumn: (t) => t.boilerHouseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BoilerPhotosTableFilterComposer(
            $db: $db,
            $table: $db.boilerPhotos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> savedLocationsRefs(
    Expression<bool> Function($$SavedLocationsTableFilterComposer f) f,
  ) {
    final $$SavedLocationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.backendId,
      referencedTable: $db.savedLocations,
      getReferencedColumn: (t) => t.boilerHouseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavedLocationsTableFilterComposer(
            $db: $db,
            $table: $db.savedLocations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> incidentsRefs(
    Expression<bool> Function($$IncidentsTableFilterComposer f) f,
  ) {
    final $$IncidentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.backendId,
      referencedTable: $db.incidents,
      getReferencedColumn: (t) => t.boilerHouseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IncidentsTableFilterComposer(
            $db: $db,
            $table: $db.incidents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BoilerHousesTableOrderingComposer
    extends Composer<_$AppDatabase, $BoilerHousesTable> {
  $$BoilerHousesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get backendId => $composableBuilder(
    column: $table.backendId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get boilerHouseUUID => $composableBuilder(
    column: $table.boilerHouseUUID,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get siteManager => $composableBuilder(
    column: $table.siteManager,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get siteNumber => $composableBuilder(
    column: $table.siteNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BoilerHousesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BoilerHousesTable> {
  $$BoilerHousesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get backendId =>
      $composableBuilder(column: $table.backendId, builder: (column) => column);

  GeneratedColumn<String> get boilerHouseUUID => $composableBuilder(
    column: $table.boilerHouseUUID,
    builder: (column) => column,
  );

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get siteManager => $composableBuilder(
    column: $table.siteManager,
    builder: (column) => column,
  );

  GeneratedColumn<String> get siteNumber => $composableBuilder(
    column: $table.siteNumber,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> boilerPhotosRefs<T extends Object>(
    Expression<T> Function($$BoilerPhotosTableAnnotationComposer a) f,
  ) {
    final $$BoilerPhotosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.backendId,
      referencedTable: $db.boilerPhotos,
      getReferencedColumn: (t) => t.boilerHouseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BoilerPhotosTableAnnotationComposer(
            $db: $db,
            $table: $db.boilerPhotos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> savedLocationsRefs<T extends Object>(
    Expression<T> Function($$SavedLocationsTableAnnotationComposer a) f,
  ) {
    final $$SavedLocationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.backendId,
      referencedTable: $db.savedLocations,
      getReferencedColumn: (t) => t.boilerHouseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavedLocationsTableAnnotationComposer(
            $db: $db,
            $table: $db.savedLocations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> incidentsRefs<T extends Object>(
    Expression<T> Function($$IncidentsTableAnnotationComposer a) f,
  ) {
    final $$IncidentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.backendId,
      referencedTable: $db.incidents,
      getReferencedColumn: (t) => t.boilerHouseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IncidentsTableAnnotationComposer(
            $db: $db,
            $table: $db.incidents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BoilerHousesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BoilerHousesTable,
          BoilerHouseDb,
          $$BoilerHousesTableFilterComposer,
          $$BoilerHousesTableOrderingComposer,
          $$BoilerHousesTableAnnotationComposer,
          $$BoilerHousesTableCreateCompanionBuilder,
          $$BoilerHousesTableUpdateCompanionBuilder,
          (BoilerHouseDb, $$BoilerHousesTableReferences),
          BoilerHouseDb,
          PrefetchHooks Function({
            bool boilerPhotosRefs,
            bool savedLocationsRefs,
            bool incidentsRefs,
          })
        > {
  $$BoilerHousesTableTableManager(_$AppDatabase db, $BoilerHousesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BoilerHousesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BoilerHousesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BoilerHousesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> backendId = const Value.absent(),
                Value<String?> boilerHouseUUID = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<String?> siteManager = const Value.absent(),
                Value<String?> siteNumber = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
              }) => BoilerHousesCompanion(
                backendId: backendId,
                boilerHouseUUID: boilerHouseUUID,
                latitude: latitude,
                longitude: longitude,
                name: name,
                siteManager: siteManager,
                siteNumber: siteNumber,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> backendId = const Value.absent(),
                Value<String?> boilerHouseUUID = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<String?> siteManager = const Value.absent(),
                Value<String?> siteNumber = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
              }) => BoilerHousesCompanion.insert(
                backendId: backendId,
                boilerHouseUUID: boilerHouseUUID,
                latitude: latitude,
                longitude: longitude,
                name: name,
                siteManager: siteManager,
                siteNumber: siteNumber,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BoilerHousesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                boilerPhotosRefs = false,
                savedLocationsRefs = false,
                incidentsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (boilerPhotosRefs) db.boilerPhotos,
                    if (savedLocationsRefs) db.savedLocations,
                    if (incidentsRefs) db.incidents,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (boilerPhotosRefs)
                        await $_getPrefetchedData<
                          BoilerHouseDb,
                          $BoilerHousesTable,
                          BoilerPhotoDb
                        >(
                          currentTable: table,
                          referencedTable: $$BoilerHousesTableReferences
                              ._boilerPhotosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BoilerHousesTableReferences(
                                db,
                                table,
                                p0,
                              ).boilerPhotosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.boilerHouseId == item.backendId,
                              ),
                          typedResults: items,
                        ),
                      if (savedLocationsRefs)
                        await $_getPrefetchedData<
                          BoilerHouseDb,
                          $BoilerHousesTable,
                          SavedLocationDb
                        >(
                          currentTable: table,
                          referencedTable: $$BoilerHousesTableReferences
                              ._savedLocationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BoilerHousesTableReferences(
                                db,
                                table,
                                p0,
                              ).savedLocationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.boilerHouseId == item.backendId,
                              ),
                          typedResults: items,
                        ),
                      if (incidentsRefs)
                        await $_getPrefetchedData<
                          BoilerHouseDb,
                          $BoilerHousesTable,
                          IncidentDb
                        >(
                          currentTable: table,
                          referencedTable: $$BoilerHousesTableReferences
                              ._incidentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BoilerHousesTableReferences(
                                db,
                                table,
                                p0,
                              ).incidentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.boilerHouseId == item.backendId,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$BoilerHousesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BoilerHousesTable,
      BoilerHouseDb,
      $$BoilerHousesTableFilterComposer,
      $$BoilerHousesTableOrderingComposer,
      $$BoilerHousesTableAnnotationComposer,
      $$BoilerHousesTableCreateCompanionBuilder,
      $$BoilerHousesTableUpdateCompanionBuilder,
      (BoilerHouseDb, $$BoilerHousesTableReferences),
      BoilerHouseDb,
      PrefetchHooks Function({
        bool boilerPhotosRefs,
        bool savedLocationsRefs,
        bool incidentsRefs,
      })
    >;
typedef $$BoilerPhotosTableCreateCompanionBuilder =
    BoilerPhotosCompanion Function({
      Value<int> backendId,
      Value<DateTime?> createdAt,
      required String fileName,
      Value<int?> fileSize,
      Value<int?> height,
      required String id,
      Value<String?> sha256,
      Value<Uint8List?> thumbJPEG,
      Value<String?> thumbnailUrl,
      Value<String?> url,
      Value<int?> width,
      Value<int?> boilerHouseId,
    });
typedef $$BoilerPhotosTableUpdateCompanionBuilder =
    BoilerPhotosCompanion Function({
      Value<int> backendId,
      Value<DateTime?> createdAt,
      Value<String> fileName,
      Value<int?> fileSize,
      Value<int?> height,
      Value<String> id,
      Value<String?> sha256,
      Value<Uint8List?> thumbJPEG,
      Value<String?> thumbnailUrl,
      Value<String?> url,
      Value<int?> width,
      Value<int?> boilerHouseId,
    });

final class $$BoilerPhotosTableReferences
    extends BaseReferences<_$AppDatabase, $BoilerPhotosTable, BoilerPhotoDb> {
  $$BoilerPhotosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BoilerHousesTable _boilerHouseIdTable(_$AppDatabase db) =>
      db.boilerHouses.createAlias(
        $_aliasNameGenerator(
          db.boilerPhotos.boilerHouseId,
          db.boilerHouses.backendId,
        ),
      );

  $$BoilerHousesTableProcessedTableManager? get boilerHouseId {
    final $_column = $_itemColumn<int>('boiler_house_id');
    if ($_column == null) return null;
    final manager = $$BoilerHousesTableTableManager(
      $_db,
      $_db.boilerHouses,
    ).filter((f) => f.backendId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_boilerHouseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BoilerPhotosTableFilterComposer
    extends Composer<_$AppDatabase, $BoilerPhotosTable> {
  $$BoilerPhotosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get backendId => $composableBuilder(
    column: $table.backendId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get thumbJPEG => $composableBuilder(
    column: $table.thumbJPEG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnFilters(column),
  );

  $$BoilerHousesTableFilterComposer get boilerHouseId {
    final $$BoilerHousesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.boilerHouseId,
      referencedTable: $db.boilerHouses,
      getReferencedColumn: (t) => t.backendId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BoilerHousesTableFilterComposer(
            $db: $db,
            $table: $db.boilerHouses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BoilerPhotosTableOrderingComposer
    extends Composer<_$AppDatabase, $BoilerPhotosTable> {
  $$BoilerPhotosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get backendId => $composableBuilder(
    column: $table.backendId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get thumbJPEG => $composableBuilder(
    column: $table.thumbJPEG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnOrderings(column),
  );

  $$BoilerHousesTableOrderingComposer get boilerHouseId {
    final $$BoilerHousesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.boilerHouseId,
      referencedTable: $db.boilerHouses,
      getReferencedColumn: (t) => t.backendId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BoilerHousesTableOrderingComposer(
            $db: $db,
            $table: $db.boilerHouses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BoilerPhotosTableAnnotationComposer
    extends Composer<_$AppDatabase, $BoilerPhotosTable> {
  $$BoilerPhotosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get backendId =>
      $composableBuilder(column: $table.backendId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<int> get fileSize =>
      $composableBuilder(column: $table.fileSize, builder: (column) => column);

  GeneratedColumn<int> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sha256 =>
      $composableBuilder(column: $table.sha256, builder: (column) => column);

  GeneratedColumn<Uint8List> get thumbJPEG =>
      $composableBuilder(column: $table.thumbJPEG, builder: (column) => column);

  GeneratedColumn<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<int> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  $$BoilerHousesTableAnnotationComposer get boilerHouseId {
    final $$BoilerHousesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.boilerHouseId,
      referencedTable: $db.boilerHouses,
      getReferencedColumn: (t) => t.backendId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BoilerHousesTableAnnotationComposer(
            $db: $db,
            $table: $db.boilerHouses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BoilerPhotosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BoilerPhotosTable,
          BoilerPhotoDb,
          $$BoilerPhotosTableFilterComposer,
          $$BoilerPhotosTableOrderingComposer,
          $$BoilerPhotosTableAnnotationComposer,
          $$BoilerPhotosTableCreateCompanionBuilder,
          $$BoilerPhotosTableUpdateCompanionBuilder,
          (BoilerPhotoDb, $$BoilerPhotosTableReferences),
          BoilerPhotoDb,
          PrefetchHooks Function({bool boilerHouseId})
        > {
  $$BoilerPhotosTableTableManager(_$AppDatabase db, $BoilerPhotosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BoilerPhotosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BoilerPhotosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BoilerPhotosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> backendId = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<String> fileName = const Value.absent(),
                Value<int?> fileSize = const Value.absent(),
                Value<int?> height = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String?> sha256 = const Value.absent(),
                Value<Uint8List?> thumbJPEG = const Value.absent(),
                Value<String?> thumbnailUrl = const Value.absent(),
                Value<String?> url = const Value.absent(),
                Value<int?> width = const Value.absent(),
                Value<int?> boilerHouseId = const Value.absent(),
              }) => BoilerPhotosCompanion(
                backendId: backendId,
                createdAt: createdAt,
                fileName: fileName,
                fileSize: fileSize,
                height: height,
                id: id,
                sha256: sha256,
                thumbJPEG: thumbJPEG,
                thumbnailUrl: thumbnailUrl,
                url: url,
                width: width,
                boilerHouseId: boilerHouseId,
              ),
          createCompanionCallback:
              ({
                Value<int> backendId = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                required String fileName,
                Value<int?> fileSize = const Value.absent(),
                Value<int?> height = const Value.absent(),
                required String id,
                Value<String?> sha256 = const Value.absent(),
                Value<Uint8List?> thumbJPEG = const Value.absent(),
                Value<String?> thumbnailUrl = const Value.absent(),
                Value<String?> url = const Value.absent(),
                Value<int?> width = const Value.absent(),
                Value<int?> boilerHouseId = const Value.absent(),
              }) => BoilerPhotosCompanion.insert(
                backendId: backendId,
                createdAt: createdAt,
                fileName: fileName,
                fileSize: fileSize,
                height: height,
                id: id,
                sha256: sha256,
                thumbJPEG: thumbJPEG,
                thumbnailUrl: thumbnailUrl,
                url: url,
                width: width,
                boilerHouseId: boilerHouseId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BoilerPhotosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({boilerHouseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (boilerHouseId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.boilerHouseId,
                                referencedTable: $$BoilerPhotosTableReferences
                                    ._boilerHouseIdTable(db),
                                referencedColumn: $$BoilerPhotosTableReferences
                                    ._boilerHouseIdTable(db)
                                    .backendId,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$BoilerPhotosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BoilerPhotosTable,
      BoilerPhotoDb,
      $$BoilerPhotosTableFilterComposer,
      $$BoilerPhotosTableOrderingComposer,
      $$BoilerPhotosTableAnnotationComposer,
      $$BoilerPhotosTableCreateCompanionBuilder,
      $$BoilerPhotosTableUpdateCompanionBuilder,
      (BoilerPhotoDb, $$BoilerPhotosTableReferences),
      BoilerPhotoDb,
      PrefetchHooks Function({bool boilerHouseId})
    >;
typedef $$ManagementCompaniesTableCreateCompanionBuilder =
    ManagementCompaniesCompanion Function({
      Value<String?> address,
      Value<String?> companyUUID,
      Value<String?> director,
      Value<String?> email,
      required String id,
      required String name,
      Value<String?> normalizedName,
      Value<String?> notes,
      Value<String?> phone,
      Value<int> rowid,
    });
typedef $$ManagementCompaniesTableUpdateCompanionBuilder =
    ManagementCompaniesCompanion Function({
      Value<String?> address,
      Value<String?> companyUUID,
      Value<String?> director,
      Value<String?> email,
      Value<String> id,
      Value<String> name,
      Value<String?> normalizedName,
      Value<String?> notes,
      Value<String?> phone,
      Value<int> rowid,
    });

final class $$ManagementCompaniesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ManagementCompaniesTable,
          ManagementCompanyDb
        > {
  $$ManagementCompaniesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$SavedLocationsTable, List<SavedLocationDb>>
  _savedLocationsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.savedLocations,
    aliasName: $_aliasNameGenerator(
      db.managementCompanies.id,
      db.savedLocations.managementCompanyRefId,
    ),
  );

  $$SavedLocationsTableProcessedTableManager get savedLocationsRefs {
    final manager = $$SavedLocationsTableTableManager($_db, $_db.savedLocations)
        .filter(
          (f) => f.managementCompanyRefId.id.sqlEquals(
            $_itemColumn<String>('id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(_savedLocationsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ManagementCompaniesTableFilterComposer
    extends Composer<_$AppDatabase, $ManagementCompaniesTable> {
  $$ManagementCompaniesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get companyUUID => $composableBuilder(
    column: $table.companyUUID,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get director => $composableBuilder(
    column: $table.director,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> savedLocationsRefs(
    Expression<bool> Function($$SavedLocationsTableFilterComposer f) f,
  ) {
    final $$SavedLocationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.savedLocations,
      getReferencedColumn: (t) => t.managementCompanyRefId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavedLocationsTableFilterComposer(
            $db: $db,
            $table: $db.savedLocations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ManagementCompaniesTableOrderingComposer
    extends Composer<_$AppDatabase, $ManagementCompaniesTable> {
  $$ManagementCompaniesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get companyUUID => $composableBuilder(
    column: $table.companyUUID,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get director => $composableBuilder(
    column: $table.director,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ManagementCompaniesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ManagementCompaniesTable> {
  $$ManagementCompaniesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get companyUUID => $composableBuilder(
    column: $table.companyUUID,
    builder: (column) => column,
  );

  GeneratedColumn<String> get director =>
      $composableBuilder(column: $table.director, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  Expression<T> savedLocationsRefs<T extends Object>(
    Expression<T> Function($$SavedLocationsTableAnnotationComposer a) f,
  ) {
    final $$SavedLocationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.savedLocations,
      getReferencedColumn: (t) => t.managementCompanyRefId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavedLocationsTableAnnotationComposer(
            $db: $db,
            $table: $db.savedLocations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ManagementCompaniesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ManagementCompaniesTable,
          ManagementCompanyDb,
          $$ManagementCompaniesTableFilterComposer,
          $$ManagementCompaniesTableOrderingComposer,
          $$ManagementCompaniesTableAnnotationComposer,
          $$ManagementCompaniesTableCreateCompanionBuilder,
          $$ManagementCompaniesTableUpdateCompanionBuilder,
          (ManagementCompanyDb, $$ManagementCompaniesTableReferences),
          ManagementCompanyDb,
          PrefetchHooks Function({bool savedLocationsRefs})
        > {
  $$ManagementCompaniesTableTableManager(
    _$AppDatabase db,
    $ManagementCompaniesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ManagementCompaniesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ManagementCompaniesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ManagementCompaniesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String?> address = const Value.absent(),
                Value<String?> companyUUID = const Value.absent(),
                Value<String?> director = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> normalizedName = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ManagementCompaniesCompanion(
                address: address,
                companyUUID: companyUUID,
                director: director,
                email: email,
                id: id,
                name: name,
                normalizedName: normalizedName,
                notes: notes,
                phone: phone,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String?> address = const Value.absent(),
                Value<String?> companyUUID = const Value.absent(),
                Value<String?> director = const Value.absent(),
                Value<String?> email = const Value.absent(),
                required String id,
                required String name,
                Value<String?> normalizedName = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ManagementCompaniesCompanion.insert(
                address: address,
                companyUUID: companyUUID,
                director: director,
                email: email,
                id: id,
                name: name,
                normalizedName: normalizedName,
                notes: notes,
                phone: phone,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ManagementCompaniesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({savedLocationsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (savedLocationsRefs) db.savedLocations,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (savedLocationsRefs)
                    await $_getPrefetchedData<
                      ManagementCompanyDb,
                      $ManagementCompaniesTable,
                      SavedLocationDb
                    >(
                      currentTable: table,
                      referencedTable: $$ManagementCompaniesTableReferences
                          ._savedLocationsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ManagementCompaniesTableReferences(
                            db,
                            table,
                            p0,
                          ).savedLocationsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.managementCompanyRefId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ManagementCompaniesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ManagementCompaniesTable,
      ManagementCompanyDb,
      $$ManagementCompaniesTableFilterComposer,
      $$ManagementCompaniesTableOrderingComposer,
      $$ManagementCompaniesTableAnnotationComposer,
      $$ManagementCompaniesTableCreateCompanionBuilder,
      $$ManagementCompaniesTableUpdateCompanionBuilder,
      (ManagementCompanyDb, $$ManagementCompaniesTableReferences),
      ManagementCompanyDb,
      PrefetchHooks Function({bool savedLocationsRefs})
    >;
typedef $$SavedLocationsTableCreateCompanionBuilder =
    SavedLocationsCompanion Function({
      Value<int?> accounts,
      Value<int?> backendId,
      Value<String?> fiasAOGuid,
      Value<String?> fiasHouseGuid,
      Value<int?> floors,
      Value<bool> isStub,
      Value<double?> latitude,
      Value<String?> locationUUID,
      Value<double?> longitude,
      Value<String?> managementCompany,
      Value<String?> name,
      Value<bool?> providesHeating,
      Value<bool?> providesHotWater,
      Value<int?> residentsCount,
      Value<int?> rooms,
      Value<double?> totalArea,
      Value<DateTime?> updatedAt,
      Value<int?> yearBuilt,
      Value<String?> managementCompanyName,
      Value<int?> boilerHouseId,
      Value<String?> managementCompanyRefId,
      Value<int> id,
    });
typedef $$SavedLocationsTableUpdateCompanionBuilder =
    SavedLocationsCompanion Function({
      Value<int?> accounts,
      Value<int?> backendId,
      Value<String?> fiasAOGuid,
      Value<String?> fiasHouseGuid,
      Value<int?> floors,
      Value<bool> isStub,
      Value<double?> latitude,
      Value<String?> locationUUID,
      Value<double?> longitude,
      Value<String?> managementCompany,
      Value<String?> name,
      Value<bool?> providesHeating,
      Value<bool?> providesHotWater,
      Value<int?> residentsCount,
      Value<int?> rooms,
      Value<double?> totalArea,
      Value<DateTime?> updatedAt,
      Value<int?> yearBuilt,
      Value<String?> managementCompanyName,
      Value<int?> boilerHouseId,
      Value<String?> managementCompanyRefId,
      Value<int> id,
    });

final class $$SavedLocationsTableReferences
    extends
        BaseReferences<_$AppDatabase, $SavedLocationsTable, SavedLocationDb> {
  $$SavedLocationsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $BoilerHousesTable _boilerHouseIdTable(_$AppDatabase db) =>
      db.boilerHouses.createAlias(
        $_aliasNameGenerator(
          db.savedLocations.boilerHouseId,
          db.boilerHouses.backendId,
        ),
      );

  $$BoilerHousesTableProcessedTableManager? get boilerHouseId {
    final $_column = $_itemColumn<int>('boiler_house_id');
    if ($_column == null) return null;
    final manager = $$BoilerHousesTableTableManager(
      $_db,
      $_db.boilerHouses,
    ).filter((f) => f.backendId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_boilerHouseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ManagementCompaniesTable _managementCompanyRefIdTable(
    _$AppDatabase db,
  ) => db.managementCompanies.createAlias(
    $_aliasNameGenerator(
      db.savedLocations.managementCompanyRefId,
      db.managementCompanies.id,
    ),
  );

  $$ManagementCompaniesTableProcessedTableManager? get managementCompanyRefId {
    final $_column = $_itemColumn<String>('management_company_ref_id');
    if ($_column == null) return null;
    final manager = $$ManagementCompaniesTableTableManager(
      $_db,
      $_db.managementCompanies,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(
      _managementCompanyRefIdTable($_db),
    );
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$HousePhotosTable, List<HousePhotoDb>>
  _housePhotosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.housePhotos,
    aliasName: $_aliasNameGenerator(
      db.savedLocations.backendId,
      db.housePhotos.houseId,
    ),
  );

  $$HousePhotosTableProcessedTableManager get housePhotosRefs {
    final manager = $$HousePhotosTableTableManager($_db, $_db.housePhotos)
        .filter(
          (f) => f.houseId.backendId.sqlEquals($_itemColumn<int>('backend_id')),
        );

    final cache = $_typedResult.readTableOrNull(_housePhotosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AffectedHousesTable, List<AffectedHouseDb>>
  _affectedHousesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.affectedHouses,
    aliasName: $_aliasNameGenerator(
      db.savedLocations.backendId,
      db.affectedHouses.savedLocationId,
    ),
  );

  $$AffectedHousesTableProcessedTableManager get affectedHousesRefs {
    final manager = $$AffectedHousesTableTableManager($_db, $_db.affectedHouses)
        .filter(
          (f) => f.savedLocationId.backendId.sqlEquals(
            $_itemColumn<int>('backend_id'),
          ),
        );

    final cache = $_typedResult.readTableOrNull(_affectedHousesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SavedLocationsTableFilterComposer
    extends Composer<_$AppDatabase, $SavedLocationsTable> {
  $$SavedLocationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get accounts => $composableBuilder(
    column: $table.accounts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get backendId => $composableBuilder(
    column: $table.backendId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fiasAOGuid => $composableBuilder(
    column: $table.fiasAOGuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fiasHouseGuid => $composableBuilder(
    column: $table.fiasHouseGuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get floors => $composableBuilder(
    column: $table.floors,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isStub => $composableBuilder(
    column: $table.isStub,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locationUUID => $composableBuilder(
    column: $table.locationUUID,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get managementCompany => $composableBuilder(
    column: $table.managementCompany,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get providesHeating => $composableBuilder(
    column: $table.providesHeating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get providesHotWater => $composableBuilder(
    column: $table.providesHotWater,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get residentsCount => $composableBuilder(
    column: $table.residentsCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rooms => $composableBuilder(
    column: $table.rooms,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalArea => $composableBuilder(
    column: $table.totalArea,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get yearBuilt => $composableBuilder(
    column: $table.yearBuilt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get managementCompanyName => $composableBuilder(
    column: $table.managementCompanyName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  $$BoilerHousesTableFilterComposer get boilerHouseId {
    final $$BoilerHousesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.boilerHouseId,
      referencedTable: $db.boilerHouses,
      getReferencedColumn: (t) => t.backendId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BoilerHousesTableFilterComposer(
            $db: $db,
            $table: $db.boilerHouses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ManagementCompaniesTableFilterComposer get managementCompanyRefId {
    final $$ManagementCompaniesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.managementCompanyRefId,
      referencedTable: $db.managementCompanies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ManagementCompaniesTableFilterComposer(
            $db: $db,
            $table: $db.managementCompanies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> housePhotosRefs(
    Expression<bool> Function($$HousePhotosTableFilterComposer f) f,
  ) {
    final $$HousePhotosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.backendId,
      referencedTable: $db.housePhotos,
      getReferencedColumn: (t) => t.houseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HousePhotosTableFilterComposer(
            $db: $db,
            $table: $db.housePhotos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> affectedHousesRefs(
    Expression<bool> Function($$AffectedHousesTableFilterComposer f) f,
  ) {
    final $$AffectedHousesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.backendId,
      referencedTable: $db.affectedHouses,
      getReferencedColumn: (t) => t.savedLocationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AffectedHousesTableFilterComposer(
            $db: $db,
            $table: $db.affectedHouses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SavedLocationsTableOrderingComposer
    extends Composer<_$AppDatabase, $SavedLocationsTable> {
  $$SavedLocationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get accounts => $composableBuilder(
    column: $table.accounts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get backendId => $composableBuilder(
    column: $table.backendId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fiasAOGuid => $composableBuilder(
    column: $table.fiasAOGuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fiasHouseGuid => $composableBuilder(
    column: $table.fiasHouseGuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get floors => $composableBuilder(
    column: $table.floors,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isStub => $composableBuilder(
    column: $table.isStub,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locationUUID => $composableBuilder(
    column: $table.locationUUID,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get managementCompany => $composableBuilder(
    column: $table.managementCompany,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get providesHeating => $composableBuilder(
    column: $table.providesHeating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get providesHotWater => $composableBuilder(
    column: $table.providesHotWater,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get residentsCount => $composableBuilder(
    column: $table.residentsCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rooms => $composableBuilder(
    column: $table.rooms,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalArea => $composableBuilder(
    column: $table.totalArea,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get yearBuilt => $composableBuilder(
    column: $table.yearBuilt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get managementCompanyName => $composableBuilder(
    column: $table.managementCompanyName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  $$BoilerHousesTableOrderingComposer get boilerHouseId {
    final $$BoilerHousesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.boilerHouseId,
      referencedTable: $db.boilerHouses,
      getReferencedColumn: (t) => t.backendId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BoilerHousesTableOrderingComposer(
            $db: $db,
            $table: $db.boilerHouses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ManagementCompaniesTableOrderingComposer get managementCompanyRefId {
    final $$ManagementCompaniesTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.managementCompanyRefId,
          referencedTable: $db.managementCompanies,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ManagementCompaniesTableOrderingComposer(
                $db: $db,
                $table: $db.managementCompanies,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$SavedLocationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SavedLocationsTable> {
  $$SavedLocationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get accounts =>
      $composableBuilder(column: $table.accounts, builder: (column) => column);

  GeneratedColumn<int> get backendId =>
      $composableBuilder(column: $table.backendId, builder: (column) => column);

  GeneratedColumn<String> get fiasAOGuid => $composableBuilder(
    column: $table.fiasAOGuid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fiasHouseGuid => $composableBuilder(
    column: $table.fiasHouseGuid,
    builder: (column) => column,
  );

  GeneratedColumn<int> get floors =>
      $composableBuilder(column: $table.floors, builder: (column) => column);

  GeneratedColumn<bool> get isStub =>
      $composableBuilder(column: $table.isStub, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<String> get locationUUID => $composableBuilder(
    column: $table.locationUUID,
    builder: (column) => column,
  );

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get managementCompany => $composableBuilder(
    column: $table.managementCompany,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get providesHeating => $composableBuilder(
    column: $table.providesHeating,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get providesHotWater => $composableBuilder(
    column: $table.providesHotWater,
    builder: (column) => column,
  );

  GeneratedColumn<int> get residentsCount => $composableBuilder(
    column: $table.residentsCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rooms =>
      $composableBuilder(column: $table.rooms, builder: (column) => column);

  GeneratedColumn<double> get totalArea =>
      $composableBuilder(column: $table.totalArea, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get yearBuilt =>
      $composableBuilder(column: $table.yearBuilt, builder: (column) => column);

  GeneratedColumn<String> get managementCompanyName => $composableBuilder(
    column: $table.managementCompanyName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  $$BoilerHousesTableAnnotationComposer get boilerHouseId {
    final $$BoilerHousesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.boilerHouseId,
      referencedTable: $db.boilerHouses,
      getReferencedColumn: (t) => t.backendId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BoilerHousesTableAnnotationComposer(
            $db: $db,
            $table: $db.boilerHouses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ManagementCompaniesTableAnnotationComposer get managementCompanyRefId {
    final $$ManagementCompaniesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.managementCompanyRefId,
          referencedTable: $db.managementCompanies,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ManagementCompaniesTableAnnotationComposer(
                $db: $db,
                $table: $db.managementCompanies,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> housePhotosRefs<T extends Object>(
    Expression<T> Function($$HousePhotosTableAnnotationComposer a) f,
  ) {
    final $$HousePhotosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.backendId,
      referencedTable: $db.housePhotos,
      getReferencedColumn: (t) => t.houseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HousePhotosTableAnnotationComposer(
            $db: $db,
            $table: $db.housePhotos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> affectedHousesRefs<T extends Object>(
    Expression<T> Function($$AffectedHousesTableAnnotationComposer a) f,
  ) {
    final $$AffectedHousesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.backendId,
      referencedTable: $db.affectedHouses,
      getReferencedColumn: (t) => t.savedLocationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AffectedHousesTableAnnotationComposer(
            $db: $db,
            $table: $db.affectedHouses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SavedLocationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SavedLocationsTable,
          SavedLocationDb,
          $$SavedLocationsTableFilterComposer,
          $$SavedLocationsTableOrderingComposer,
          $$SavedLocationsTableAnnotationComposer,
          $$SavedLocationsTableCreateCompanionBuilder,
          $$SavedLocationsTableUpdateCompanionBuilder,
          (SavedLocationDb, $$SavedLocationsTableReferences),
          SavedLocationDb,
          PrefetchHooks Function({
            bool boilerHouseId,
            bool managementCompanyRefId,
            bool housePhotosRefs,
            bool affectedHousesRefs,
          })
        > {
  $$SavedLocationsTableTableManager(
    _$AppDatabase db,
    $SavedLocationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavedLocationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavedLocationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SavedLocationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int?> accounts = const Value.absent(),
                Value<int?> backendId = const Value.absent(),
                Value<String?> fiasAOGuid = const Value.absent(),
                Value<String?> fiasHouseGuid = const Value.absent(),
                Value<int?> floors = const Value.absent(),
                Value<bool> isStub = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<String?> locationUUID = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<String?> managementCompany = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<bool?> providesHeating = const Value.absent(),
                Value<bool?> providesHotWater = const Value.absent(),
                Value<int?> residentsCount = const Value.absent(),
                Value<int?> rooms = const Value.absent(),
                Value<double?> totalArea = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int?> yearBuilt = const Value.absent(),
                Value<String?> managementCompanyName = const Value.absent(),
                Value<int?> boilerHouseId = const Value.absent(),
                Value<String?> managementCompanyRefId = const Value.absent(),
                Value<int> id = const Value.absent(),
              }) => SavedLocationsCompanion(
                accounts: accounts,
                backendId: backendId,
                fiasAOGuid: fiasAOGuid,
                fiasHouseGuid: fiasHouseGuid,
                floors: floors,
                isStub: isStub,
                latitude: latitude,
                locationUUID: locationUUID,
                longitude: longitude,
                managementCompany: managementCompany,
                name: name,
                providesHeating: providesHeating,
                providesHotWater: providesHotWater,
                residentsCount: residentsCount,
                rooms: rooms,
                totalArea: totalArea,
                updatedAt: updatedAt,
                yearBuilt: yearBuilt,
                managementCompanyName: managementCompanyName,
                boilerHouseId: boilerHouseId,
                managementCompanyRefId: managementCompanyRefId,
                id: id,
              ),
          createCompanionCallback:
              ({
                Value<int?> accounts = const Value.absent(),
                Value<int?> backendId = const Value.absent(),
                Value<String?> fiasAOGuid = const Value.absent(),
                Value<String?> fiasHouseGuid = const Value.absent(),
                Value<int?> floors = const Value.absent(),
                Value<bool> isStub = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<String?> locationUUID = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<String?> managementCompany = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<bool?> providesHeating = const Value.absent(),
                Value<bool?> providesHotWater = const Value.absent(),
                Value<int?> residentsCount = const Value.absent(),
                Value<int?> rooms = const Value.absent(),
                Value<double?> totalArea = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int?> yearBuilt = const Value.absent(),
                Value<String?> managementCompanyName = const Value.absent(),
                Value<int?> boilerHouseId = const Value.absent(),
                Value<String?> managementCompanyRefId = const Value.absent(),
                Value<int> id = const Value.absent(),
              }) => SavedLocationsCompanion.insert(
                accounts: accounts,
                backendId: backendId,
                fiasAOGuid: fiasAOGuid,
                fiasHouseGuid: fiasHouseGuid,
                floors: floors,
                isStub: isStub,
                latitude: latitude,
                locationUUID: locationUUID,
                longitude: longitude,
                managementCompany: managementCompany,
                name: name,
                providesHeating: providesHeating,
                providesHotWater: providesHotWater,
                residentsCount: residentsCount,
                rooms: rooms,
                totalArea: totalArea,
                updatedAt: updatedAt,
                yearBuilt: yearBuilt,
                managementCompanyName: managementCompanyName,
                boilerHouseId: boilerHouseId,
                managementCompanyRefId: managementCompanyRefId,
                id: id,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SavedLocationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                boilerHouseId = false,
                managementCompanyRefId = false,
                housePhotosRefs = false,
                affectedHousesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (housePhotosRefs) db.housePhotos,
                    if (affectedHousesRefs) db.affectedHouses,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (boilerHouseId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.boilerHouseId,
                                    referencedTable:
                                        $$SavedLocationsTableReferences
                                            ._boilerHouseIdTable(db),
                                    referencedColumn:
                                        $$SavedLocationsTableReferences
                                            ._boilerHouseIdTable(db)
                                            .backendId,
                                  )
                                  as T;
                        }
                        if (managementCompanyRefId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.managementCompanyRefId,
                                    referencedTable:
                                        $$SavedLocationsTableReferences
                                            ._managementCompanyRefIdTable(db),
                                    referencedColumn:
                                        $$SavedLocationsTableReferences
                                            ._managementCompanyRefIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (housePhotosRefs)
                        await $_getPrefetchedData<
                          SavedLocationDb,
                          $SavedLocationsTable,
                          HousePhotoDb
                        >(
                          currentTable: table,
                          referencedTable: $$SavedLocationsTableReferences
                              ._housePhotosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SavedLocationsTableReferences(
                                db,
                                table,
                                p0,
                              ).housePhotosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.houseId == item.backendId,
                              ),
                          typedResults: items,
                        ),
                      if (affectedHousesRefs)
                        await $_getPrefetchedData<
                          SavedLocationDb,
                          $SavedLocationsTable,
                          AffectedHouseDb
                        >(
                          currentTable: table,
                          referencedTable: $$SavedLocationsTableReferences
                              ._affectedHousesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SavedLocationsTableReferences(
                                db,
                                table,
                                p0,
                              ).affectedHousesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.savedLocationId == item.backendId,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SavedLocationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SavedLocationsTable,
      SavedLocationDb,
      $$SavedLocationsTableFilterComposer,
      $$SavedLocationsTableOrderingComposer,
      $$SavedLocationsTableAnnotationComposer,
      $$SavedLocationsTableCreateCompanionBuilder,
      $$SavedLocationsTableUpdateCompanionBuilder,
      (SavedLocationDb, $$SavedLocationsTableReferences),
      SavedLocationDb,
      PrefetchHooks Function({
        bool boilerHouseId,
        bool managementCompanyRefId,
        bool housePhotosRefs,
        bool affectedHousesRefs,
      })
    >;
typedef $$HousePhotosTableCreateCompanionBuilder =
    HousePhotosCompanion Function({
      Value<int> backendId,
      required DateTime createdAt,
      required String fileName,
      Value<int?> fileSize,
      Value<int?> height,
      required String id,
      required String sha256,
      Value<Uint8List?> thumbJPEG,
      Value<String?> thumbnailUrl,
      Value<String?> url,
      Value<int?> width,
      Value<int?> houseId,
    });
typedef $$HousePhotosTableUpdateCompanionBuilder =
    HousePhotosCompanion Function({
      Value<int> backendId,
      Value<DateTime> createdAt,
      Value<String> fileName,
      Value<int?> fileSize,
      Value<int?> height,
      Value<String> id,
      Value<String> sha256,
      Value<Uint8List?> thumbJPEG,
      Value<String?> thumbnailUrl,
      Value<String?> url,
      Value<int?> width,
      Value<int?> houseId,
    });

final class $$HousePhotosTableReferences
    extends BaseReferences<_$AppDatabase, $HousePhotosTable, HousePhotoDb> {
  $$HousePhotosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SavedLocationsTable _houseIdTable(_$AppDatabase db) =>
      db.savedLocations.createAlias(
        $_aliasNameGenerator(
          db.housePhotos.houseId,
          db.savedLocations.backendId,
        ),
      );

  $$SavedLocationsTableProcessedTableManager? get houseId {
    final $_column = $_itemColumn<int>('house_id');
    if ($_column == null) return null;
    final manager = $$SavedLocationsTableTableManager(
      $_db,
      $_db.savedLocations,
    ).filter((f) => f.backendId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_houseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$HousePhotosTableFilterComposer
    extends Composer<_$AppDatabase, $HousePhotosTable> {
  $$HousePhotosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get backendId => $composableBuilder(
    column: $table.backendId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get thumbJPEG => $composableBuilder(
    column: $table.thumbJPEG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnFilters(column),
  );

  $$SavedLocationsTableFilterComposer get houseId {
    final $$SavedLocationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.houseId,
      referencedTable: $db.savedLocations,
      getReferencedColumn: (t) => t.backendId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavedLocationsTableFilterComposer(
            $db: $db,
            $table: $db.savedLocations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HousePhotosTableOrderingComposer
    extends Composer<_$AppDatabase, $HousePhotosTable> {
  $$HousePhotosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get backendId => $composableBuilder(
    column: $table.backendId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get thumbJPEG => $composableBuilder(
    column: $table.thumbJPEG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnOrderings(column),
  );

  $$SavedLocationsTableOrderingComposer get houseId {
    final $$SavedLocationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.houseId,
      referencedTable: $db.savedLocations,
      getReferencedColumn: (t) => t.backendId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavedLocationsTableOrderingComposer(
            $db: $db,
            $table: $db.savedLocations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HousePhotosTableAnnotationComposer
    extends Composer<_$AppDatabase, $HousePhotosTable> {
  $$HousePhotosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get backendId =>
      $composableBuilder(column: $table.backendId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<int> get fileSize =>
      $composableBuilder(column: $table.fileSize, builder: (column) => column);

  GeneratedColumn<int> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sha256 =>
      $composableBuilder(column: $table.sha256, builder: (column) => column);

  GeneratedColumn<Uint8List> get thumbJPEG =>
      $composableBuilder(column: $table.thumbJPEG, builder: (column) => column);

  GeneratedColumn<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<int> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  $$SavedLocationsTableAnnotationComposer get houseId {
    final $$SavedLocationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.houseId,
      referencedTable: $db.savedLocations,
      getReferencedColumn: (t) => t.backendId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavedLocationsTableAnnotationComposer(
            $db: $db,
            $table: $db.savedLocations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HousePhotosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HousePhotosTable,
          HousePhotoDb,
          $$HousePhotosTableFilterComposer,
          $$HousePhotosTableOrderingComposer,
          $$HousePhotosTableAnnotationComposer,
          $$HousePhotosTableCreateCompanionBuilder,
          $$HousePhotosTableUpdateCompanionBuilder,
          (HousePhotoDb, $$HousePhotosTableReferences),
          HousePhotoDb,
          PrefetchHooks Function({bool houseId})
        > {
  $$HousePhotosTableTableManager(_$AppDatabase db, $HousePhotosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HousePhotosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HousePhotosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HousePhotosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> backendId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> fileName = const Value.absent(),
                Value<int?> fileSize = const Value.absent(),
                Value<int?> height = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> sha256 = const Value.absent(),
                Value<Uint8List?> thumbJPEG = const Value.absent(),
                Value<String?> thumbnailUrl = const Value.absent(),
                Value<String?> url = const Value.absent(),
                Value<int?> width = const Value.absent(),
                Value<int?> houseId = const Value.absent(),
              }) => HousePhotosCompanion(
                backendId: backendId,
                createdAt: createdAt,
                fileName: fileName,
                fileSize: fileSize,
                height: height,
                id: id,
                sha256: sha256,
                thumbJPEG: thumbJPEG,
                thumbnailUrl: thumbnailUrl,
                url: url,
                width: width,
                houseId: houseId,
              ),
          createCompanionCallback:
              ({
                Value<int> backendId = const Value.absent(),
                required DateTime createdAt,
                required String fileName,
                Value<int?> fileSize = const Value.absent(),
                Value<int?> height = const Value.absent(),
                required String id,
                required String sha256,
                Value<Uint8List?> thumbJPEG = const Value.absent(),
                Value<String?> thumbnailUrl = const Value.absent(),
                Value<String?> url = const Value.absent(),
                Value<int?> width = const Value.absent(),
                Value<int?> houseId = const Value.absent(),
              }) => HousePhotosCompanion.insert(
                backendId: backendId,
                createdAt: createdAt,
                fileName: fileName,
                fileSize: fileSize,
                height: height,
                id: id,
                sha256: sha256,
                thumbJPEG: thumbJPEG,
                thumbnailUrl: thumbnailUrl,
                url: url,
                width: width,
                houseId: houseId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$HousePhotosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({houseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (houseId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.houseId,
                                referencedTable: $$HousePhotosTableReferences
                                    ._houseIdTable(db),
                                referencedColumn: $$HousePhotosTableReferences
                                    ._houseIdTable(db)
                                    .backendId,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$HousePhotosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HousePhotosTable,
      HousePhotoDb,
      $$HousePhotosTableFilterComposer,
      $$HousePhotosTableOrderingComposer,
      $$HousePhotosTableAnnotationComposer,
      $$HousePhotosTableCreateCompanionBuilder,
      $$HousePhotosTableUpdateCompanionBuilder,
      (HousePhotoDb, $$HousePhotosTableReferences),
      HousePhotoDb,
      PrefetchHooks Function({bool houseId})
    >;
typedef $$IncidentsTableCreateCompanionBuilder =
    IncidentsCompanion Function({
      Value<int> backendId,
      Value<int?> assignedTo,
      Value<String?> details,
      Value<DateTime?> finishedAt,
      Value<String?> incidentUUID,
      Value<DateTime?> lastLocalEditAt,
      Value<DateTime?> lastServerUpdateAt,
      Value<bool?> localPendingAck,
      Value<String?> notificationConfigRoleIds,
      Value<String?> notificationConfigType,
      Value<String?> notificationConfigUserIds,
      Value<bool?> resourceHeatingStopped,
      Value<bool?> resourceHotWaterStopped,
      Value<int?> severity,
      Value<DateTime?> startedAt,
      Value<String?> status,
      Value<String?> type,
      Value<int?> boilerHouseId,
    });
typedef $$IncidentsTableUpdateCompanionBuilder =
    IncidentsCompanion Function({
      Value<int> backendId,
      Value<int?> assignedTo,
      Value<String?> details,
      Value<DateTime?> finishedAt,
      Value<String?> incidentUUID,
      Value<DateTime?> lastLocalEditAt,
      Value<DateTime?> lastServerUpdateAt,
      Value<bool?> localPendingAck,
      Value<String?> notificationConfigRoleIds,
      Value<String?> notificationConfigType,
      Value<String?> notificationConfigUserIds,
      Value<bool?> resourceHeatingStopped,
      Value<bool?> resourceHotWaterStopped,
      Value<int?> severity,
      Value<DateTime?> startedAt,
      Value<String?> status,
      Value<String?> type,
      Value<int?> boilerHouseId,
    });

final class $$IncidentsTableReferences
    extends BaseReferences<_$AppDatabase, $IncidentsTable, IncidentDb> {
  $$IncidentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BoilerHousesTable _boilerHouseIdTable(_$AppDatabase db) =>
      db.boilerHouses.createAlias(
        $_aliasNameGenerator(
          db.incidents.boilerHouseId,
          db.boilerHouses.backendId,
        ),
      );

  $$BoilerHousesTableProcessedTableManager? get boilerHouseId {
    final $_column = $_itemColumn<int>('boiler_house_id');
    if ($_column == null) return null;
    final manager = $$BoilerHousesTableTableManager(
      $_db,
      $_db.boilerHouses,
    ).filter((f) => f.backendId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_boilerHouseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$AffectedHousesTable, List<AffectedHouseDb>>
  _affectedHousesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.affectedHouses,
    aliasName: $_aliasNameGenerator(
      db.incidents.backendId,
      db.affectedHouses.incidentId,
    ),
  );

  $$AffectedHousesTableProcessedTableManager get affectedHousesRefs {
    final manager = $$AffectedHousesTableTableManager($_db, $_db.affectedHouses)
        .filter(
          (f) => f.incidentId.backendId.sqlEquals(
            $_itemColumn<int>('backend_id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(_affectedHousesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$IncidentCommentsTable, List<IncidentCommentDb>>
  _incidentCommentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.incidentComments,
    aliasName: $_aliasNameGenerator(
      db.incidents.backendId,
      db.incidentComments.incidentId,
    ),
  );

  $$IncidentCommentsTableProcessedTableManager get incidentCommentsRefs {
    final manager =
        $$IncidentCommentsTableTableManager($_db, $_db.incidentComments).filter(
          (f) => f.incidentId.backendId.sqlEquals(
            $_itemColumn<int>('backend_id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(
      _incidentCommentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$IncidentPhotosTable, List<IncidentPhotoDb>>
  _incidentPhotosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.incidentPhotos,
    aliasName: $_aliasNameGenerator(
      db.incidents.backendId,
      db.incidentPhotos.incidentId,
    ),
  );

  $$IncidentPhotosTableProcessedTableManager get incidentPhotosRefs {
    final manager = $$IncidentPhotosTableTableManager($_db, $_db.incidentPhotos)
        .filter(
          (f) => f.incidentId.backendId.sqlEquals(
            $_itemColumn<int>('backend_id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(_incidentPhotosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$IncidentsTableFilterComposer
    extends Composer<_$AppDatabase, $IncidentsTable> {
  $$IncidentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get backendId => $composableBuilder(
    column: $table.backendId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get assignedTo => $composableBuilder(
    column: $table.assignedTo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get details => $composableBuilder(
    column: $table.details,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get incidentUUID => $composableBuilder(
    column: $table.incidentUUID,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastLocalEditAt => $composableBuilder(
    column: $table.lastLocalEditAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastServerUpdateAt => $composableBuilder(
    column: $table.lastServerUpdateAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get localPendingAck => $composableBuilder(
    column: $table.localPendingAck,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notificationConfigRoleIds => $composableBuilder(
    column: $table.notificationConfigRoleIds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notificationConfigType => $composableBuilder(
    column: $table.notificationConfigType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notificationConfigUserIds => $composableBuilder(
    column: $table.notificationConfigUserIds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get resourceHeatingStopped => $composableBuilder(
    column: $table.resourceHeatingStopped,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get resourceHotWaterStopped => $composableBuilder(
    column: $table.resourceHotWaterStopped,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  $$BoilerHousesTableFilterComposer get boilerHouseId {
    final $$BoilerHousesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.boilerHouseId,
      referencedTable: $db.boilerHouses,
      getReferencedColumn: (t) => t.backendId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BoilerHousesTableFilterComposer(
            $db: $db,
            $table: $db.boilerHouses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> affectedHousesRefs(
    Expression<bool> Function($$AffectedHousesTableFilterComposer f) f,
  ) {
    final $$AffectedHousesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.backendId,
      referencedTable: $db.affectedHouses,
      getReferencedColumn: (t) => t.incidentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AffectedHousesTableFilterComposer(
            $db: $db,
            $table: $db.affectedHouses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> incidentCommentsRefs(
    Expression<bool> Function($$IncidentCommentsTableFilterComposer f) f,
  ) {
    final $$IncidentCommentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.backendId,
      referencedTable: $db.incidentComments,
      getReferencedColumn: (t) => t.incidentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IncidentCommentsTableFilterComposer(
            $db: $db,
            $table: $db.incidentComments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> incidentPhotosRefs(
    Expression<bool> Function($$IncidentPhotosTableFilterComposer f) f,
  ) {
    final $$IncidentPhotosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.backendId,
      referencedTable: $db.incidentPhotos,
      getReferencedColumn: (t) => t.incidentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IncidentPhotosTableFilterComposer(
            $db: $db,
            $table: $db.incidentPhotos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$IncidentsTableOrderingComposer
    extends Composer<_$AppDatabase, $IncidentsTable> {
  $$IncidentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get backendId => $composableBuilder(
    column: $table.backendId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get assignedTo => $composableBuilder(
    column: $table.assignedTo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get details => $composableBuilder(
    column: $table.details,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get incidentUUID => $composableBuilder(
    column: $table.incidentUUID,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastLocalEditAt => $composableBuilder(
    column: $table.lastLocalEditAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastServerUpdateAt => $composableBuilder(
    column: $table.lastServerUpdateAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get localPendingAck => $composableBuilder(
    column: $table.localPendingAck,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notificationConfigRoleIds => $composableBuilder(
    column: $table.notificationConfigRoleIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notificationConfigType => $composableBuilder(
    column: $table.notificationConfigType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notificationConfigUserIds => $composableBuilder(
    column: $table.notificationConfigUserIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get resourceHeatingStopped => $composableBuilder(
    column: $table.resourceHeatingStopped,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get resourceHotWaterStopped => $composableBuilder(
    column: $table.resourceHotWaterStopped,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  $$BoilerHousesTableOrderingComposer get boilerHouseId {
    final $$BoilerHousesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.boilerHouseId,
      referencedTable: $db.boilerHouses,
      getReferencedColumn: (t) => t.backendId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BoilerHousesTableOrderingComposer(
            $db: $db,
            $table: $db.boilerHouses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IncidentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $IncidentsTable> {
  $$IncidentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get backendId =>
      $composableBuilder(column: $table.backendId, builder: (column) => column);

  GeneratedColumn<int> get assignedTo => $composableBuilder(
    column: $table.assignedTo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get details =>
      $composableBuilder(column: $table.details, builder: (column) => column);

  GeneratedColumn<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get incidentUUID => $composableBuilder(
    column: $table.incidentUUID,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastLocalEditAt => $composableBuilder(
    column: $table.lastLocalEditAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastServerUpdateAt => $composableBuilder(
    column: $table.lastServerUpdateAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get localPendingAck => $composableBuilder(
    column: $table.localPendingAck,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notificationConfigRoleIds => $composableBuilder(
    column: $table.notificationConfigRoleIds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notificationConfigType => $composableBuilder(
    column: $table.notificationConfigType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notificationConfigUserIds => $composableBuilder(
    column: $table.notificationConfigUserIds,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get resourceHeatingStopped => $composableBuilder(
    column: $table.resourceHeatingStopped,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get resourceHotWaterStopped => $composableBuilder(
    column: $table.resourceHotWaterStopped,
    builder: (column) => column,
  );

  GeneratedColumn<int> get severity =>
      $composableBuilder(column: $table.severity, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  $$BoilerHousesTableAnnotationComposer get boilerHouseId {
    final $$BoilerHousesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.boilerHouseId,
      referencedTable: $db.boilerHouses,
      getReferencedColumn: (t) => t.backendId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BoilerHousesTableAnnotationComposer(
            $db: $db,
            $table: $db.boilerHouses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> affectedHousesRefs<T extends Object>(
    Expression<T> Function($$AffectedHousesTableAnnotationComposer a) f,
  ) {
    final $$AffectedHousesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.backendId,
      referencedTable: $db.affectedHouses,
      getReferencedColumn: (t) => t.incidentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AffectedHousesTableAnnotationComposer(
            $db: $db,
            $table: $db.affectedHouses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> incidentCommentsRefs<T extends Object>(
    Expression<T> Function($$IncidentCommentsTableAnnotationComposer a) f,
  ) {
    final $$IncidentCommentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.backendId,
      referencedTable: $db.incidentComments,
      getReferencedColumn: (t) => t.incidentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IncidentCommentsTableAnnotationComposer(
            $db: $db,
            $table: $db.incidentComments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> incidentPhotosRefs<T extends Object>(
    Expression<T> Function($$IncidentPhotosTableAnnotationComposer a) f,
  ) {
    final $$IncidentPhotosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.backendId,
      referencedTable: $db.incidentPhotos,
      getReferencedColumn: (t) => t.incidentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IncidentPhotosTableAnnotationComposer(
            $db: $db,
            $table: $db.incidentPhotos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$IncidentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IncidentsTable,
          IncidentDb,
          $$IncidentsTableFilterComposer,
          $$IncidentsTableOrderingComposer,
          $$IncidentsTableAnnotationComposer,
          $$IncidentsTableCreateCompanionBuilder,
          $$IncidentsTableUpdateCompanionBuilder,
          (IncidentDb, $$IncidentsTableReferences),
          IncidentDb,
          PrefetchHooks Function({
            bool boilerHouseId,
            bool affectedHousesRefs,
            bool incidentCommentsRefs,
            bool incidentPhotosRefs,
          })
        > {
  $$IncidentsTableTableManager(_$AppDatabase db, $IncidentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IncidentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IncidentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IncidentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> backendId = const Value.absent(),
                Value<int?> assignedTo = const Value.absent(),
                Value<String?> details = const Value.absent(),
                Value<DateTime?> finishedAt = const Value.absent(),
                Value<String?> incidentUUID = const Value.absent(),
                Value<DateTime?> lastLocalEditAt = const Value.absent(),
                Value<DateTime?> lastServerUpdateAt = const Value.absent(),
                Value<bool?> localPendingAck = const Value.absent(),
                Value<String?> notificationConfigRoleIds = const Value.absent(),
                Value<String?> notificationConfigType = const Value.absent(),
                Value<String?> notificationConfigUserIds = const Value.absent(),
                Value<bool?> resourceHeatingStopped = const Value.absent(),
                Value<bool?> resourceHotWaterStopped = const Value.absent(),
                Value<int?> severity = const Value.absent(),
                Value<DateTime?> startedAt = const Value.absent(),
                Value<String?> status = const Value.absent(),
                Value<String?> type = const Value.absent(),
                Value<int?> boilerHouseId = const Value.absent(),
              }) => IncidentsCompanion(
                backendId: backendId,
                assignedTo: assignedTo,
                details: details,
                finishedAt: finishedAt,
                incidentUUID: incidentUUID,
                lastLocalEditAt: lastLocalEditAt,
                lastServerUpdateAt: lastServerUpdateAt,
                localPendingAck: localPendingAck,
                notificationConfigRoleIds: notificationConfigRoleIds,
                notificationConfigType: notificationConfigType,
                notificationConfigUserIds: notificationConfigUserIds,
                resourceHeatingStopped: resourceHeatingStopped,
                resourceHotWaterStopped: resourceHotWaterStopped,
                severity: severity,
                startedAt: startedAt,
                status: status,
                type: type,
                boilerHouseId: boilerHouseId,
              ),
          createCompanionCallback:
              ({
                Value<int> backendId = const Value.absent(),
                Value<int?> assignedTo = const Value.absent(),
                Value<String?> details = const Value.absent(),
                Value<DateTime?> finishedAt = const Value.absent(),
                Value<String?> incidentUUID = const Value.absent(),
                Value<DateTime?> lastLocalEditAt = const Value.absent(),
                Value<DateTime?> lastServerUpdateAt = const Value.absent(),
                Value<bool?> localPendingAck = const Value.absent(),
                Value<String?> notificationConfigRoleIds = const Value.absent(),
                Value<String?> notificationConfigType = const Value.absent(),
                Value<String?> notificationConfigUserIds = const Value.absent(),
                Value<bool?> resourceHeatingStopped = const Value.absent(),
                Value<bool?> resourceHotWaterStopped = const Value.absent(),
                Value<int?> severity = const Value.absent(),
                Value<DateTime?> startedAt = const Value.absent(),
                Value<String?> status = const Value.absent(),
                Value<String?> type = const Value.absent(),
                Value<int?> boilerHouseId = const Value.absent(),
              }) => IncidentsCompanion.insert(
                backendId: backendId,
                assignedTo: assignedTo,
                details: details,
                finishedAt: finishedAt,
                incidentUUID: incidentUUID,
                lastLocalEditAt: lastLocalEditAt,
                lastServerUpdateAt: lastServerUpdateAt,
                localPendingAck: localPendingAck,
                notificationConfigRoleIds: notificationConfigRoleIds,
                notificationConfigType: notificationConfigType,
                notificationConfigUserIds: notificationConfigUserIds,
                resourceHeatingStopped: resourceHeatingStopped,
                resourceHotWaterStopped: resourceHotWaterStopped,
                severity: severity,
                startedAt: startedAt,
                status: status,
                type: type,
                boilerHouseId: boilerHouseId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$IncidentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                boilerHouseId = false,
                affectedHousesRefs = false,
                incidentCommentsRefs = false,
                incidentPhotosRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (affectedHousesRefs) db.affectedHouses,
                    if (incidentCommentsRefs) db.incidentComments,
                    if (incidentPhotosRefs) db.incidentPhotos,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (boilerHouseId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.boilerHouseId,
                                    referencedTable: $$IncidentsTableReferences
                                        ._boilerHouseIdTable(db),
                                    referencedColumn: $$IncidentsTableReferences
                                        ._boilerHouseIdTable(db)
                                        .backendId,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (affectedHousesRefs)
                        await $_getPrefetchedData<
                          IncidentDb,
                          $IncidentsTable,
                          AffectedHouseDb
                        >(
                          currentTable: table,
                          referencedTable: $$IncidentsTableReferences
                              ._affectedHousesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$IncidentsTableReferences(
                                db,
                                table,
                                p0,
                              ).affectedHousesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.incidentId == item.backendId,
                              ),
                          typedResults: items,
                        ),
                      if (incidentCommentsRefs)
                        await $_getPrefetchedData<
                          IncidentDb,
                          $IncidentsTable,
                          IncidentCommentDb
                        >(
                          currentTable: table,
                          referencedTable: $$IncidentsTableReferences
                              ._incidentCommentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$IncidentsTableReferences(
                                db,
                                table,
                                p0,
                              ).incidentCommentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.incidentId == item.backendId,
                              ),
                          typedResults: items,
                        ),
                      if (incidentPhotosRefs)
                        await $_getPrefetchedData<
                          IncidentDb,
                          $IncidentsTable,
                          IncidentPhotoDb
                        >(
                          currentTable: table,
                          referencedTable: $$IncidentsTableReferences
                              ._incidentPhotosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$IncidentsTableReferences(
                                db,
                                table,
                                p0,
                              ).incidentPhotosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.incidentId == item.backendId,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$IncidentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IncidentsTable,
      IncidentDb,
      $$IncidentsTableFilterComposer,
      $$IncidentsTableOrderingComposer,
      $$IncidentsTableAnnotationComposer,
      $$IncidentsTableCreateCompanionBuilder,
      $$IncidentsTableUpdateCompanionBuilder,
      (IncidentDb, $$IncidentsTableReferences),
      IncidentDb,
      PrefetchHooks Function({
        bool boilerHouseId,
        bool affectedHousesRefs,
        bool incidentCommentsRefs,
        bool incidentPhotosRefs,
      })
    >;
typedef $$AffectedHousesTableCreateCompanionBuilder =
    AffectedHousesCompanion Function({
      required int incidentId,
      required int savedLocationId,
      Value<int> rowid,
    });
typedef $$AffectedHousesTableUpdateCompanionBuilder =
    AffectedHousesCompanion Function({
      Value<int> incidentId,
      Value<int> savedLocationId,
      Value<int> rowid,
    });

final class $$AffectedHousesTableReferences
    extends
        BaseReferences<_$AppDatabase, $AffectedHousesTable, AffectedHouseDb> {
  $$AffectedHousesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $IncidentsTable _incidentIdTable(_$AppDatabase db) =>
      db.incidents.createAlias(
        $_aliasNameGenerator(
          db.affectedHouses.incidentId,
          db.incidents.backendId,
        ),
      );

  $$IncidentsTableProcessedTableManager get incidentId {
    final $_column = $_itemColumn<int>('incident_id')!;

    final manager = $$IncidentsTableTableManager(
      $_db,
      $_db.incidents,
    ).filter((f) => f.backendId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_incidentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SavedLocationsTable _savedLocationIdTable(_$AppDatabase db) =>
      db.savedLocations.createAlias(
        $_aliasNameGenerator(
          db.affectedHouses.savedLocationId,
          db.savedLocations.backendId,
        ),
      );

  $$SavedLocationsTableProcessedTableManager get savedLocationId {
    final $_column = $_itemColumn<int>('saved_location_id')!;

    final manager = $$SavedLocationsTableTableManager(
      $_db,
      $_db.savedLocations,
    ).filter((f) => f.backendId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_savedLocationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AffectedHousesTableFilterComposer
    extends Composer<_$AppDatabase, $AffectedHousesTable> {
  $$AffectedHousesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$IncidentsTableFilterComposer get incidentId {
    final $$IncidentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.incidentId,
      referencedTable: $db.incidents,
      getReferencedColumn: (t) => t.backendId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IncidentsTableFilterComposer(
            $db: $db,
            $table: $db.incidents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SavedLocationsTableFilterComposer get savedLocationId {
    final $$SavedLocationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.savedLocationId,
      referencedTable: $db.savedLocations,
      getReferencedColumn: (t) => t.backendId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavedLocationsTableFilterComposer(
            $db: $db,
            $table: $db.savedLocations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AffectedHousesTableOrderingComposer
    extends Composer<_$AppDatabase, $AffectedHousesTable> {
  $$AffectedHousesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$IncidentsTableOrderingComposer get incidentId {
    final $$IncidentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.incidentId,
      referencedTable: $db.incidents,
      getReferencedColumn: (t) => t.backendId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IncidentsTableOrderingComposer(
            $db: $db,
            $table: $db.incidents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SavedLocationsTableOrderingComposer get savedLocationId {
    final $$SavedLocationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.savedLocationId,
      referencedTable: $db.savedLocations,
      getReferencedColumn: (t) => t.backendId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavedLocationsTableOrderingComposer(
            $db: $db,
            $table: $db.savedLocations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AffectedHousesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AffectedHousesTable> {
  $$AffectedHousesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$IncidentsTableAnnotationComposer get incidentId {
    final $$IncidentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.incidentId,
      referencedTable: $db.incidents,
      getReferencedColumn: (t) => t.backendId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IncidentsTableAnnotationComposer(
            $db: $db,
            $table: $db.incidents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SavedLocationsTableAnnotationComposer get savedLocationId {
    final $$SavedLocationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.savedLocationId,
      referencedTable: $db.savedLocations,
      getReferencedColumn: (t) => t.backendId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavedLocationsTableAnnotationComposer(
            $db: $db,
            $table: $db.savedLocations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AffectedHousesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AffectedHousesTable,
          AffectedHouseDb,
          $$AffectedHousesTableFilterComposer,
          $$AffectedHousesTableOrderingComposer,
          $$AffectedHousesTableAnnotationComposer,
          $$AffectedHousesTableCreateCompanionBuilder,
          $$AffectedHousesTableUpdateCompanionBuilder,
          (AffectedHouseDb, $$AffectedHousesTableReferences),
          AffectedHouseDb,
          PrefetchHooks Function({bool incidentId, bool savedLocationId})
        > {
  $$AffectedHousesTableTableManager(
    _$AppDatabase db,
    $AffectedHousesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AffectedHousesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AffectedHousesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AffectedHousesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> incidentId = const Value.absent(),
                Value<int> savedLocationId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AffectedHousesCompanion(
                incidentId: incidentId,
                savedLocationId: savedLocationId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int incidentId,
                required int savedLocationId,
                Value<int> rowid = const Value.absent(),
              }) => AffectedHousesCompanion.insert(
                incidentId: incidentId,
                savedLocationId: savedLocationId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AffectedHousesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({incidentId = false, savedLocationId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (incidentId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.incidentId,
                                    referencedTable:
                                        $$AffectedHousesTableReferences
                                            ._incidentIdTable(db),
                                    referencedColumn:
                                        $$AffectedHousesTableReferences
                                            ._incidentIdTable(db)
                                            .backendId,
                                  )
                                  as T;
                        }
                        if (savedLocationId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.savedLocationId,
                                    referencedTable:
                                        $$AffectedHousesTableReferences
                                            ._savedLocationIdTable(db),
                                    referencedColumn:
                                        $$AffectedHousesTableReferences
                                            ._savedLocationIdTable(db)
                                            .backendId,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$AffectedHousesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AffectedHousesTable,
      AffectedHouseDb,
      $$AffectedHousesTableFilterComposer,
      $$AffectedHousesTableOrderingComposer,
      $$AffectedHousesTableAnnotationComposer,
      $$AffectedHousesTableCreateCompanionBuilder,
      $$AffectedHousesTableUpdateCompanionBuilder,
      (AffectedHouseDb, $$AffectedHousesTableReferences),
      AffectedHouseDb,
      PrefetchHooks Function({bool incidentId, bool savedLocationId})
    >;
typedef $$IncidentCommentsTableCreateCompanionBuilder =
    IncidentCommentsCompanion Function({
      Value<int> backendId,
      required DateTime createdAt,
      required String id,
      Value<bool> isSystemMessage,
      required String commentText,
      Value<int?> userId,
      Value<String?> authorName,
      Value<String?> authorPosition,
      Value<int?> incidentId,
    });
typedef $$IncidentCommentsTableUpdateCompanionBuilder =
    IncidentCommentsCompanion Function({
      Value<int> backendId,
      Value<DateTime> createdAt,
      Value<String> id,
      Value<bool> isSystemMessage,
      Value<String> commentText,
      Value<int?> userId,
      Value<String?> authorName,
      Value<String?> authorPosition,
      Value<int?> incidentId,
    });

final class $$IncidentCommentsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $IncidentCommentsTable,
          IncidentCommentDb
        > {
  $$IncidentCommentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $IncidentsTable _incidentIdTable(_$AppDatabase db) =>
      db.incidents.createAlias(
        $_aliasNameGenerator(
          db.incidentComments.incidentId,
          db.incidents.backendId,
        ),
      );

  $$IncidentsTableProcessedTableManager? get incidentId {
    final $_column = $_itemColumn<int>('incident_id');
    if ($_column == null) return null;
    final manager = $$IncidentsTableTableManager(
      $_db,
      $_db.incidents,
    ).filter((f) => f.backendId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_incidentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$IncidentCommentsTableFilterComposer
    extends Composer<_$AppDatabase, $IncidentCommentsTable> {
  $$IncidentCommentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get backendId => $composableBuilder(
    column: $table.backendId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSystemMessage => $composableBuilder(
    column: $table.isSystemMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get commentText => $composableBuilder(
    column: $table.commentText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authorName => $composableBuilder(
    column: $table.authorName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authorPosition => $composableBuilder(
    column: $table.authorPosition,
    builder: (column) => ColumnFilters(column),
  );

  $$IncidentsTableFilterComposer get incidentId {
    final $$IncidentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.incidentId,
      referencedTable: $db.incidents,
      getReferencedColumn: (t) => t.backendId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IncidentsTableFilterComposer(
            $db: $db,
            $table: $db.incidents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IncidentCommentsTableOrderingComposer
    extends Composer<_$AppDatabase, $IncidentCommentsTable> {
  $$IncidentCommentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get backendId => $composableBuilder(
    column: $table.backendId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSystemMessage => $composableBuilder(
    column: $table.isSystemMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get commentText => $composableBuilder(
    column: $table.commentText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authorName => $composableBuilder(
    column: $table.authorName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authorPosition => $composableBuilder(
    column: $table.authorPosition,
    builder: (column) => ColumnOrderings(column),
  );

  $$IncidentsTableOrderingComposer get incidentId {
    final $$IncidentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.incidentId,
      referencedTable: $db.incidents,
      getReferencedColumn: (t) => t.backendId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IncidentsTableOrderingComposer(
            $db: $db,
            $table: $db.incidents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IncidentCommentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $IncidentCommentsTable> {
  $$IncidentCommentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get backendId =>
      $composableBuilder(column: $table.backendId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get isSystemMessage => $composableBuilder(
    column: $table.isSystemMessage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get commentText => $composableBuilder(
    column: $table.commentText,
    builder: (column) => column,
  );

  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get authorName => $composableBuilder(
    column: $table.authorName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get authorPosition => $composableBuilder(
    column: $table.authorPosition,
    builder: (column) => column,
  );

  $$IncidentsTableAnnotationComposer get incidentId {
    final $$IncidentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.incidentId,
      referencedTable: $db.incidents,
      getReferencedColumn: (t) => t.backendId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IncidentsTableAnnotationComposer(
            $db: $db,
            $table: $db.incidents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IncidentCommentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IncidentCommentsTable,
          IncidentCommentDb,
          $$IncidentCommentsTableFilterComposer,
          $$IncidentCommentsTableOrderingComposer,
          $$IncidentCommentsTableAnnotationComposer,
          $$IncidentCommentsTableCreateCompanionBuilder,
          $$IncidentCommentsTableUpdateCompanionBuilder,
          (IncidentCommentDb, $$IncidentCommentsTableReferences),
          IncidentCommentDb,
          PrefetchHooks Function({bool incidentId})
        > {
  $$IncidentCommentsTableTableManager(
    _$AppDatabase db,
    $IncidentCommentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IncidentCommentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IncidentCommentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IncidentCommentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> backendId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<bool> isSystemMessage = const Value.absent(),
                Value<String> commentText = const Value.absent(),
                Value<int?> userId = const Value.absent(),
                Value<String?> authorName = const Value.absent(),
                Value<String?> authorPosition = const Value.absent(),
                Value<int?> incidentId = const Value.absent(),
              }) => IncidentCommentsCompanion(
                backendId: backendId,
                createdAt: createdAt,
                id: id,
                isSystemMessage: isSystemMessage,
                commentText: commentText,
                userId: userId,
                authorName: authorName,
                authorPosition: authorPosition,
                incidentId: incidentId,
              ),
          createCompanionCallback:
              ({
                Value<int> backendId = const Value.absent(),
                required DateTime createdAt,
                required String id,
                Value<bool> isSystemMessage = const Value.absent(),
                required String commentText,
                Value<int?> userId = const Value.absent(),
                Value<String?> authorName = const Value.absent(),
                Value<String?> authorPosition = const Value.absent(),
                Value<int?> incidentId = const Value.absent(),
              }) => IncidentCommentsCompanion.insert(
                backendId: backendId,
                createdAt: createdAt,
                id: id,
                isSystemMessage: isSystemMessage,
                commentText: commentText,
                userId: userId,
                authorName: authorName,
                authorPosition: authorPosition,
                incidentId: incidentId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$IncidentCommentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({incidentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (incidentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.incidentId,
                                referencedTable:
                                    $$IncidentCommentsTableReferences
                                        ._incidentIdTable(db),
                                referencedColumn:
                                    $$IncidentCommentsTableReferences
                                        ._incidentIdTable(db)
                                        .backendId,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$IncidentCommentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IncidentCommentsTable,
      IncidentCommentDb,
      $$IncidentCommentsTableFilterComposer,
      $$IncidentCommentsTableOrderingComposer,
      $$IncidentCommentsTableAnnotationComposer,
      $$IncidentCommentsTableCreateCompanionBuilder,
      $$IncidentCommentsTableUpdateCompanionBuilder,
      (IncidentCommentDb, $$IncidentCommentsTableReferences),
      IncidentCommentDb,
      PrefetchHooks Function({bool incidentId})
    >;
typedef $$IncidentPhotosTableCreateCompanionBuilder =
    IncidentPhotosCompanion Function({
      Value<int> backendId,
      Value<DateTime?> createdAt,
      required String fileName,
      Value<int?> fileSize,
      Value<int?> height,
      required String id,
      Value<String?> sha256,
      Value<Uint8List?> thumbJPEG,
      Value<String?> thumbnailUrl,
      Value<String?> url,
      Value<int?> width,
      Value<int?> incidentId,
    });
typedef $$IncidentPhotosTableUpdateCompanionBuilder =
    IncidentPhotosCompanion Function({
      Value<int> backendId,
      Value<DateTime?> createdAt,
      Value<String> fileName,
      Value<int?> fileSize,
      Value<int?> height,
      Value<String> id,
      Value<String?> sha256,
      Value<Uint8List?> thumbJPEG,
      Value<String?> thumbnailUrl,
      Value<String?> url,
      Value<int?> width,
      Value<int?> incidentId,
    });

final class $$IncidentPhotosTableReferences
    extends
        BaseReferences<_$AppDatabase, $IncidentPhotosTable, IncidentPhotoDb> {
  $$IncidentPhotosTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $IncidentsTable _incidentIdTable(_$AppDatabase db) =>
      db.incidents.createAlias(
        $_aliasNameGenerator(
          db.incidentPhotos.incidentId,
          db.incidents.backendId,
        ),
      );

  $$IncidentsTableProcessedTableManager? get incidentId {
    final $_column = $_itemColumn<int>('incident_id');
    if ($_column == null) return null;
    final manager = $$IncidentsTableTableManager(
      $_db,
      $_db.incidents,
    ).filter((f) => f.backendId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_incidentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$IncidentPhotosTableFilterComposer
    extends Composer<_$AppDatabase, $IncidentPhotosTable> {
  $$IncidentPhotosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get backendId => $composableBuilder(
    column: $table.backendId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get thumbJPEG => $composableBuilder(
    column: $table.thumbJPEG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnFilters(column),
  );

  $$IncidentsTableFilterComposer get incidentId {
    final $$IncidentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.incidentId,
      referencedTable: $db.incidents,
      getReferencedColumn: (t) => t.backendId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IncidentsTableFilterComposer(
            $db: $db,
            $table: $db.incidents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IncidentPhotosTableOrderingComposer
    extends Composer<_$AppDatabase, $IncidentPhotosTable> {
  $$IncidentPhotosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get backendId => $composableBuilder(
    column: $table.backendId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get thumbJPEG => $composableBuilder(
    column: $table.thumbJPEG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnOrderings(column),
  );

  $$IncidentsTableOrderingComposer get incidentId {
    final $$IncidentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.incidentId,
      referencedTable: $db.incidents,
      getReferencedColumn: (t) => t.backendId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IncidentsTableOrderingComposer(
            $db: $db,
            $table: $db.incidents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IncidentPhotosTableAnnotationComposer
    extends Composer<_$AppDatabase, $IncidentPhotosTable> {
  $$IncidentPhotosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get backendId =>
      $composableBuilder(column: $table.backendId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<int> get fileSize =>
      $composableBuilder(column: $table.fileSize, builder: (column) => column);

  GeneratedColumn<int> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sha256 =>
      $composableBuilder(column: $table.sha256, builder: (column) => column);

  GeneratedColumn<Uint8List> get thumbJPEG =>
      $composableBuilder(column: $table.thumbJPEG, builder: (column) => column);

  GeneratedColumn<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<int> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  $$IncidentsTableAnnotationComposer get incidentId {
    final $$IncidentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.incidentId,
      referencedTable: $db.incidents,
      getReferencedColumn: (t) => t.backendId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IncidentsTableAnnotationComposer(
            $db: $db,
            $table: $db.incidents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IncidentPhotosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IncidentPhotosTable,
          IncidentPhotoDb,
          $$IncidentPhotosTableFilterComposer,
          $$IncidentPhotosTableOrderingComposer,
          $$IncidentPhotosTableAnnotationComposer,
          $$IncidentPhotosTableCreateCompanionBuilder,
          $$IncidentPhotosTableUpdateCompanionBuilder,
          (IncidentPhotoDb, $$IncidentPhotosTableReferences),
          IncidentPhotoDb,
          PrefetchHooks Function({bool incidentId})
        > {
  $$IncidentPhotosTableTableManager(
    _$AppDatabase db,
    $IncidentPhotosTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IncidentPhotosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IncidentPhotosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IncidentPhotosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> backendId = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<String> fileName = const Value.absent(),
                Value<int?> fileSize = const Value.absent(),
                Value<int?> height = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String?> sha256 = const Value.absent(),
                Value<Uint8List?> thumbJPEG = const Value.absent(),
                Value<String?> thumbnailUrl = const Value.absent(),
                Value<String?> url = const Value.absent(),
                Value<int?> width = const Value.absent(),
                Value<int?> incidentId = const Value.absent(),
              }) => IncidentPhotosCompanion(
                backendId: backendId,
                createdAt: createdAt,
                fileName: fileName,
                fileSize: fileSize,
                height: height,
                id: id,
                sha256: sha256,
                thumbJPEG: thumbJPEG,
                thumbnailUrl: thumbnailUrl,
                url: url,
                width: width,
                incidentId: incidentId,
              ),
          createCompanionCallback:
              ({
                Value<int> backendId = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                required String fileName,
                Value<int?> fileSize = const Value.absent(),
                Value<int?> height = const Value.absent(),
                required String id,
                Value<String?> sha256 = const Value.absent(),
                Value<Uint8List?> thumbJPEG = const Value.absent(),
                Value<String?> thumbnailUrl = const Value.absent(),
                Value<String?> url = const Value.absent(),
                Value<int?> width = const Value.absent(),
                Value<int?> incidentId = const Value.absent(),
              }) => IncidentPhotosCompanion.insert(
                backendId: backendId,
                createdAt: createdAt,
                fileName: fileName,
                fileSize: fileSize,
                height: height,
                id: id,
                sha256: sha256,
                thumbJPEG: thumbJPEG,
                thumbnailUrl: thumbnailUrl,
                url: url,
                width: width,
                incidentId: incidentId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$IncidentPhotosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({incidentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (incidentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.incidentId,
                                referencedTable: $$IncidentPhotosTableReferences
                                    ._incidentIdTable(db),
                                referencedColumn:
                                    $$IncidentPhotosTableReferences
                                        ._incidentIdTable(db)
                                        .backendId,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$IncidentPhotosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IncidentPhotosTable,
      IncidentPhotoDb,
      $$IncidentPhotosTableFilterComposer,
      $$IncidentPhotosTableOrderingComposer,
      $$IncidentPhotosTableAnnotationComposer,
      $$IncidentPhotosTableCreateCompanionBuilder,
      $$IncidentPhotosTableUpdateCompanionBuilder,
      (IncidentPhotoDb, $$IncidentPhotosTableReferences),
      IncidentPhotoDb,
      PrefetchHooks Function({bool incidentId})
    >;
typedef $$MyAccountsTableCreateCompanionBuilder =
    MyAccountsCompanion Function({
      Value<String?> accountNumber,
      Value<String?> address,
      Value<double?> area,
      Value<DateTime?> closeDate,
      Value<String?> email,
      Value<String?> fio,
      Value<String?> jkuIdentifier,
      required String locationUUID,
      Value<DateTime?> openDate,
      Value<String?> phone,
      Value<String?> serviceType,
      Value<String?> status,
      Value<int> id,
    });
typedef $$MyAccountsTableUpdateCompanionBuilder =
    MyAccountsCompanion Function({
      Value<String?> accountNumber,
      Value<String?> address,
      Value<double?> area,
      Value<DateTime?> closeDate,
      Value<String?> email,
      Value<String?> fio,
      Value<String?> jkuIdentifier,
      Value<String> locationUUID,
      Value<DateTime?> openDate,
      Value<String?> phone,
      Value<String?> serviceType,
      Value<String?> status,
      Value<int> id,
    });

class $$MyAccountsTableFilterComposer
    extends Composer<_$AppDatabase, $MyAccountsTable> {
  $$MyAccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get accountNumber => $composableBuilder(
    column: $table.accountNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get area => $composableBuilder(
    column: $table.area,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get closeDate => $composableBuilder(
    column: $table.closeDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fio => $composableBuilder(
    column: $table.fio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jkuIdentifier => $composableBuilder(
    column: $table.jkuIdentifier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locationUUID => $composableBuilder(
    column: $table.locationUUID,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get openDate => $composableBuilder(
    column: $table.openDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serviceType => $composableBuilder(
    column: $table.serviceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MyAccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $MyAccountsTable> {
  $$MyAccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get accountNumber => $composableBuilder(
    column: $table.accountNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get area => $composableBuilder(
    column: $table.area,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get closeDate => $composableBuilder(
    column: $table.closeDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fio => $composableBuilder(
    column: $table.fio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jkuIdentifier => $composableBuilder(
    column: $table.jkuIdentifier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locationUUID => $composableBuilder(
    column: $table.locationUUID,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get openDate => $composableBuilder(
    column: $table.openDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serviceType => $composableBuilder(
    column: $table.serviceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MyAccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MyAccountsTable> {
  $$MyAccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get accountNumber => $composableBuilder(
    column: $table.accountNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<double> get area =>
      $composableBuilder(column: $table.area, builder: (column) => column);

  GeneratedColumn<DateTime> get closeDate =>
      $composableBuilder(column: $table.closeDate, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get fio =>
      $composableBuilder(column: $table.fio, builder: (column) => column);

  GeneratedColumn<String> get jkuIdentifier => $composableBuilder(
    column: $table.jkuIdentifier,
    builder: (column) => column,
  );

  GeneratedColumn<String> get locationUUID => $composableBuilder(
    column: $table.locationUUID,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get openDate =>
      $composableBuilder(column: $table.openDate, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get serviceType => $composableBuilder(
    column: $table.serviceType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);
}

class $$MyAccountsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MyAccountsTable,
          MyAccountDb,
          $$MyAccountsTableFilterComposer,
          $$MyAccountsTableOrderingComposer,
          $$MyAccountsTableAnnotationComposer,
          $$MyAccountsTableCreateCompanionBuilder,
          $$MyAccountsTableUpdateCompanionBuilder,
          (
            MyAccountDb,
            BaseReferences<_$AppDatabase, $MyAccountsTable, MyAccountDb>,
          ),
          MyAccountDb,
          PrefetchHooks Function()
        > {
  $$MyAccountsTableTableManager(_$AppDatabase db, $MyAccountsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MyAccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MyAccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MyAccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String?> accountNumber = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<double?> area = const Value.absent(),
                Value<DateTime?> closeDate = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> fio = const Value.absent(),
                Value<String?> jkuIdentifier = const Value.absent(),
                Value<String> locationUUID = const Value.absent(),
                Value<DateTime?> openDate = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> serviceType = const Value.absent(),
                Value<String?> status = const Value.absent(),
                Value<int> id = const Value.absent(),
              }) => MyAccountsCompanion(
                accountNumber: accountNumber,
                address: address,
                area: area,
                closeDate: closeDate,
                email: email,
                fio: fio,
                jkuIdentifier: jkuIdentifier,
                locationUUID: locationUUID,
                openDate: openDate,
                phone: phone,
                serviceType: serviceType,
                status: status,
                id: id,
              ),
          createCompanionCallback:
              ({
                Value<String?> accountNumber = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<double?> area = const Value.absent(),
                Value<DateTime?> closeDate = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> fio = const Value.absent(),
                Value<String?> jkuIdentifier = const Value.absent(),
                required String locationUUID,
                Value<DateTime?> openDate = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> serviceType = const Value.absent(),
                Value<String?> status = const Value.absent(),
                Value<int> id = const Value.absent(),
              }) => MyAccountsCompanion.insert(
                accountNumber: accountNumber,
                address: address,
                area: area,
                closeDate: closeDate,
                email: email,
                fio: fio,
                jkuIdentifier: jkuIdentifier,
                locationUUID: locationUUID,
                openDate: openDate,
                phone: phone,
                serviceType: serviceType,
                status: status,
                id: id,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MyAccountsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MyAccountsTable,
      MyAccountDb,
      $$MyAccountsTableFilterComposer,
      $$MyAccountsTableOrderingComposer,
      $$MyAccountsTableAnnotationComposer,
      $$MyAccountsTableCreateCompanionBuilder,
      $$MyAccountsTableUpdateCompanionBuilder,
      (
        MyAccountDb,
        BaseReferences<_$AppDatabase, $MyAccountsTable, MyAccountDb>,
      ),
      MyAccountDb,
      PrefetchHooks Function()
    >;
typedef $$PendingChangesTableCreateCompanionBuilder =
    PendingChangesCompanion Function({
      Value<int> id,
      required String actionType,
      required DateTime createdAt,
      Value<int?> entityId,
      required String entityType,
      Value<Uint8List?> payload,
      Value<int?> priority,
      Value<int?> retryCount,
      Value<String> syncStatus,
    });
typedef $$PendingChangesTableUpdateCompanionBuilder =
    PendingChangesCompanion Function({
      Value<int> id,
      Value<String> actionType,
      Value<DateTime> createdAt,
      Value<int?> entityId,
      Value<String> entityType,
      Value<Uint8List?> payload,
      Value<int?> priority,
      Value<int?> retryCount,
      Value<String> syncStatus,
    });

class $$PendingChangesTableFilterComposer
    extends Composer<_$AppDatabase, $PendingChangesTable> {
  $$PendingChangesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actionType => $composableBuilder(
    column: $table.actionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PendingChangesTableOrderingComposer
    extends Composer<_$AppDatabase, $PendingChangesTable> {
  $$PendingChangesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actionType => $composableBuilder(
    column: $table.actionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PendingChangesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PendingChangesTable> {
  $$PendingChangesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get actionType => $composableBuilder(
    column: $table.actionType,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );
}

class $$PendingChangesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PendingChangesTable,
          PendingChangeDb,
          $$PendingChangesTableFilterComposer,
          $$PendingChangesTableOrderingComposer,
          $$PendingChangesTableAnnotationComposer,
          $$PendingChangesTableCreateCompanionBuilder,
          $$PendingChangesTableUpdateCompanionBuilder,
          (
            PendingChangeDb,
            BaseReferences<
              _$AppDatabase,
              $PendingChangesTable,
              PendingChangeDb
            >,
          ),
          PendingChangeDb,
          PrefetchHooks Function()
        > {
  $$PendingChangesTableTableManager(
    _$AppDatabase db,
    $PendingChangesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingChangesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingChangesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PendingChangesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> actionType = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int?> entityId = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<Uint8List?> payload = const Value.absent(),
                Value<int?> priority = const Value.absent(),
                Value<int?> retryCount = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
              }) => PendingChangesCompanion(
                id: id,
                actionType: actionType,
                createdAt: createdAt,
                entityId: entityId,
                entityType: entityType,
                payload: payload,
                priority: priority,
                retryCount: retryCount,
                syncStatus: syncStatus,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String actionType,
                required DateTime createdAt,
                Value<int?> entityId = const Value.absent(),
                required String entityType,
                Value<Uint8List?> payload = const Value.absent(),
                Value<int?> priority = const Value.absent(),
                Value<int?> retryCount = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
              }) => PendingChangesCompanion.insert(
                id: id,
                actionType: actionType,
                createdAt: createdAt,
                entityId: entityId,
                entityType: entityType,
                payload: payload,
                priority: priority,
                retryCount: retryCount,
                syncStatus: syncStatus,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PendingChangesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PendingChangesTable,
      PendingChangeDb,
      $$PendingChangesTableFilterComposer,
      $$PendingChangesTableOrderingComposer,
      $$PendingChangesTableAnnotationComposer,
      $$PendingChangesTableCreateCompanionBuilder,
      $$PendingChangesTableUpdateCompanionBuilder,
      (
        PendingChangeDb,
        BaseReferences<_$AppDatabase, $PendingChangesTable, PendingChangeDb>,
      ),
      PendingChangeDb,
      PrefetchHooks Function()
    >;
typedef $$SyncMetadataTableCreateCompanionBuilder =
    SyncMetadataCompanion Function({
      required String syncKey,
      Value<int> lastActionId,
      Value<DateTime?> lastQueriedAt,
      Value<int> rowid,
    });
typedef $$SyncMetadataTableUpdateCompanionBuilder =
    SyncMetadataCompanion Function({
      Value<String> syncKey,
      Value<int> lastActionId,
      Value<DateTime?> lastQueriedAt,
      Value<int> rowid,
    });

class $$SyncMetadataTableFilterComposer
    extends Composer<_$AppDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get syncKey => $composableBuilder(
    column: $table.syncKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastActionId => $composableBuilder(
    column: $table.lastActionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastQueriedAt => $composableBuilder(
    column: $table.lastQueriedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncMetadataTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get syncKey => $composableBuilder(
    column: $table.syncKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastActionId => $composableBuilder(
    column: $table.lastActionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastQueriedAt => $composableBuilder(
    column: $table.lastQueriedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncMetadataTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get syncKey =>
      $composableBuilder(column: $table.syncKey, builder: (column) => column);

  GeneratedColumn<int> get lastActionId => $composableBuilder(
    column: $table.lastActionId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastQueriedAt => $composableBuilder(
    column: $table.lastQueriedAt,
    builder: (column) => column,
  );
}

class $$SyncMetadataTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncMetadataTable,
          SyncMetadataDb,
          $$SyncMetadataTableFilterComposer,
          $$SyncMetadataTableOrderingComposer,
          $$SyncMetadataTableAnnotationComposer,
          $$SyncMetadataTableCreateCompanionBuilder,
          $$SyncMetadataTableUpdateCompanionBuilder,
          (
            SyncMetadataDb,
            BaseReferences<_$AppDatabase, $SyncMetadataTable, SyncMetadataDb>,
          ),
          SyncMetadataDb,
          PrefetchHooks Function()
        > {
  $$SyncMetadataTableTableManager(_$AppDatabase db, $SyncMetadataTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncMetadataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncMetadataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncMetadataTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> syncKey = const Value.absent(),
                Value<int> lastActionId = const Value.absent(),
                Value<DateTime?> lastQueriedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncMetadataCompanion(
                syncKey: syncKey,
                lastActionId: lastActionId,
                lastQueriedAt: lastQueriedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String syncKey,
                Value<int> lastActionId = const Value.absent(),
                Value<DateTime?> lastQueriedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncMetadataCompanion.insert(
                syncKey: syncKey,
                lastActionId: lastActionId,
                lastQueriedAt: lastQueriedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncMetadataTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncMetadataTable,
      SyncMetadataDb,
      $$SyncMetadataTableFilterComposer,
      $$SyncMetadataTableOrderingComposer,
      $$SyncMetadataTableAnnotationComposer,
      $$SyncMetadataTableCreateCompanionBuilder,
      $$SyncMetadataTableUpdateCompanionBuilder,
      (
        SyncMetadataDb,
        BaseReferences<_$AppDatabase, $SyncMetadataTable, SyncMetadataDb>,
      ),
      SyncMetadataDb,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ActionLogsTableTableManager get actionLogs =>
      $$ActionLogsTableTableManager(_db, _db.actionLogs);
  $$AppUsersTableTableManager get appUsers =>
      $$AppUsersTableTableManager(_db, _db.appUsers);
  $$BoilerHousesTableTableManager get boilerHouses =>
      $$BoilerHousesTableTableManager(_db, _db.boilerHouses);
  $$BoilerPhotosTableTableManager get boilerPhotos =>
      $$BoilerPhotosTableTableManager(_db, _db.boilerPhotos);
  $$ManagementCompaniesTableTableManager get managementCompanies =>
      $$ManagementCompaniesTableTableManager(_db, _db.managementCompanies);
  $$SavedLocationsTableTableManager get savedLocations =>
      $$SavedLocationsTableTableManager(_db, _db.savedLocations);
  $$HousePhotosTableTableManager get housePhotos =>
      $$HousePhotosTableTableManager(_db, _db.housePhotos);
  $$IncidentsTableTableManager get incidents =>
      $$IncidentsTableTableManager(_db, _db.incidents);
  $$AffectedHousesTableTableManager get affectedHouses =>
      $$AffectedHousesTableTableManager(_db, _db.affectedHouses);
  $$IncidentCommentsTableTableManager get incidentComments =>
      $$IncidentCommentsTableTableManager(_db, _db.incidentComments);
  $$IncidentPhotosTableTableManager get incidentPhotos =>
      $$IncidentPhotosTableTableManager(_db, _db.incidentPhotos);
  $$MyAccountsTableTableManager get myAccounts =>
      $$MyAccountsTableTableManager(_db, _db.myAccounts);
  $$PendingChangesTableTableManager get pendingChanges =>
      $$PendingChangesTableTableManager(_db, _db.pendingChanges);
  $$SyncMetadataTableTableManager get syncMetadata =>
      $$SyncMetadataTableTableManager(_db, _db.syncMetadata);
}
