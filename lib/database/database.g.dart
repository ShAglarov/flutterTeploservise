// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $AppUsersTable extends AppUsers with TableInfo<$AppUsersTable, AppUser> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppUsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    userId,
    username,
    fullName,
    email,
    role,
    isActive,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_users';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppUser> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    }
    if (data.containsKey('full_name')) {
      context.handle(
        _fullNameMeta,
        fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
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
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  AppUser map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppUser(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      ),
      fullName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_name'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $AppUsersTable createAlias(String alias) {
    return $AppUsersTable(attachedDatabase, alias);
  }
}

class AppUser extends DataClass implements Insertable<AppUser> {
  final String userId;
  final String? username;
  final String? fullName;
  final String? email;
  final String? role;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  const AppUser({
    required this.userId,
    this.username,
    this.fullName,
    this.email,
    this.role,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || username != null) {
      map['username'] = Variable<String>(username);
    }
    if (!nullToAbsent || fullName != null) {
      map['full_name'] = Variable<String>(fullName);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || role != null) {
      map['role'] = Variable<String>(role);
    }
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  AppUsersCompanion toCompanion(bool nullToAbsent) {
    return AppUsersCompanion(
      userId: Value(userId),
      username: username == null && nullToAbsent
          ? const Value.absent()
          : Value(username),
      fullName: fullName == null && nullToAbsent
          ? const Value.absent()
          : Value(fullName),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      role: role == null && nullToAbsent ? const Value.absent() : Value(role),
      isActive: Value(isActive),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory AppUser.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppUser(
      userId: serializer.fromJson<String>(json['userId']),
      username: serializer.fromJson<String?>(json['username']),
      fullName: serializer.fromJson<String?>(json['fullName']),
      email: serializer.fromJson<String?>(json['email']),
      role: serializer.fromJson<String?>(json['role']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'username': serializer.toJson<String?>(username),
      'fullName': serializer.toJson<String?>(fullName),
      'email': serializer.toJson<String?>(email),
      'role': serializer.toJson<String?>(role),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  AppUser copyWith({
    String? userId,
    Value<String?> username = const Value.absent(),
    Value<String?> fullName = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> role = const Value.absent(),
    bool? isActive,
    Value<DateTime?> createdAt = const Value.absent(),
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => AppUser(
    userId: userId ?? this.userId,
    username: username.present ? username.value : this.username,
    fullName: fullName.present ? fullName.value : this.fullName,
    email: email.present ? email.value : this.email,
    role: role.present ? role.value : this.role,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  AppUser copyWithCompanion(AppUsersCompanion data) {
    return AppUser(
      userId: data.userId.present ? data.userId.value : this.userId,
      username: data.username.present ? data.username.value : this.username,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      email: data.email.present ? data.email.value : this.email,
      role: data.role.present ? data.role.value : this.role,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppUser(')
          ..write('userId: $userId, ')
          ..write('username: $username, ')
          ..write('fullName: $fullName, ')
          ..write('email: $email, ')
          ..write('role: $role, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    userId,
    username,
    fullName,
    email,
    role,
    isActive,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppUser &&
          other.userId == this.userId &&
          other.username == this.username &&
          other.fullName == this.fullName &&
          other.email == this.email &&
          other.role == this.role &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class AppUsersCompanion extends UpdateCompanion<AppUser> {
  final Value<String> userId;
  final Value<String?> username;
  final Value<String?> fullName;
  final Value<String?> email;
  final Value<String?> role;
  final Value<bool> isActive;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const AppUsersCompanion({
    this.userId = const Value.absent(),
    this.username = const Value.absent(),
    this.fullName = const Value.absent(),
    this.email = const Value.absent(),
    this.role = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppUsersCompanion.insert({
    required String userId,
    this.username = const Value.absent(),
    this.fullName = const Value.absent(),
    this.email = const Value.absent(),
    this.role = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : userId = Value(userId);
  static Insertable<AppUser> custom({
    Expression<String>? userId,
    Expression<String>? username,
    Expression<String>? fullName,
    Expression<String>? email,
    Expression<String>? role,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (username != null) 'username': username,
      if (fullName != null) 'full_name': fullName,
      if (email != null) 'email': email,
      if (role != null) 'role': role,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppUsersCompanion copyWith({
    Value<String>? userId,
    Value<String?>? username,
    Value<String?>? fullName,
    Value<String?>? email,
    Value<String?>? role,
    Value<bool>? isActive,
    Value<DateTime?>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<int>? rowid,
  }) {
    return AppUsersCompanion(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppUsersCompanion(')
          ..write('userId: $userId, ')
          ..write('username: $username, ')
          ..write('fullName: $fullName, ')
          ..write('email: $email, ')
          ..write('role: $role, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BoilerHousesTable extends BoilerHouses
    with TableInfo<$BoilerHousesTable, BoilerHouse> {
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
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
    false,
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
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
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
    name,
    latitude,
    longitude,
    siteNumber,
    siteManager,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'boiler_houses';
  @override
  VerificationContext validateIntegrity(
    Insertable<BoilerHouse> instance, {
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
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
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
    if (data.containsKey('site_number')) {
      context.handle(
        _siteNumberMeta,
        siteNumber.isAcceptableOrUnknown(data['site_number']!, _siteNumberMeta),
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
  BoilerHouse map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BoilerHouse(
      backendId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}backend_id'],
      )!,
      boilerHouseUUID: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}boiler_house_u_u_i_d'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      siteNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}site_number'],
      ),
      siteManager: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}site_manager'],
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

class BoilerHouse extends DataClass implements Insertable<BoilerHouse> {
  final int backendId;
  final String? boilerHouseUUID;
  final String? name;
  final double latitude;
  final double longitude;
  final String? siteNumber;
  final String? siteManager;
  final DateTime? updatedAt;
  const BoilerHouse({
    required this.backendId,
    this.boilerHouseUUID,
    this.name,
    required this.latitude,
    required this.longitude,
    this.siteNumber,
    this.siteManager,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['backend_id'] = Variable<int>(backendId);
    if (!nullToAbsent || boilerHouseUUID != null) {
      map['boiler_house_u_u_i_d'] = Variable<String>(boilerHouseUUID);
    }
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    if (!nullToAbsent || siteNumber != null) {
      map['site_number'] = Variable<String>(siteNumber);
    }
    if (!nullToAbsent || siteManager != null) {
      map['site_manager'] = Variable<String>(siteManager);
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
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      latitude: Value(latitude),
      longitude: Value(longitude),
      siteNumber: siteNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(siteNumber),
      siteManager: siteManager == null && nullToAbsent
          ? const Value.absent()
          : Value(siteManager),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory BoilerHouse.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BoilerHouse(
      backendId: serializer.fromJson<int>(json['backendId']),
      boilerHouseUUID: serializer.fromJson<String?>(json['boilerHouseUUID']),
      name: serializer.fromJson<String?>(json['name']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      siteNumber: serializer.fromJson<String?>(json['siteNumber']),
      siteManager: serializer.fromJson<String?>(json['siteManager']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'backendId': serializer.toJson<int>(backendId),
      'boilerHouseUUID': serializer.toJson<String?>(boilerHouseUUID),
      'name': serializer.toJson<String?>(name),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'siteNumber': serializer.toJson<String?>(siteNumber),
      'siteManager': serializer.toJson<String?>(siteManager),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  BoilerHouse copyWith({
    int? backendId,
    Value<String?> boilerHouseUUID = const Value.absent(),
    Value<String?> name = const Value.absent(),
    double? latitude,
    double? longitude,
    Value<String?> siteNumber = const Value.absent(),
    Value<String?> siteManager = const Value.absent(),
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => BoilerHouse(
    backendId: backendId ?? this.backendId,
    boilerHouseUUID: boilerHouseUUID.present
        ? boilerHouseUUID.value
        : this.boilerHouseUUID,
    name: name.present ? name.value : this.name,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    siteNumber: siteNumber.present ? siteNumber.value : this.siteNumber,
    siteManager: siteManager.present ? siteManager.value : this.siteManager,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  BoilerHouse copyWithCompanion(BoilerHousesCompanion data) {
    return BoilerHouse(
      backendId: data.backendId.present ? data.backendId.value : this.backendId,
      boilerHouseUUID: data.boilerHouseUUID.present
          ? data.boilerHouseUUID.value
          : this.boilerHouseUUID,
      name: data.name.present ? data.name.value : this.name,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      siteNumber: data.siteNumber.present
          ? data.siteNumber.value
          : this.siteNumber,
      siteManager: data.siteManager.present
          ? data.siteManager.value
          : this.siteManager,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BoilerHouse(')
          ..write('backendId: $backendId, ')
          ..write('boilerHouseUUID: $boilerHouseUUID, ')
          ..write('name: $name, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('siteNumber: $siteNumber, ')
          ..write('siteManager: $siteManager, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    backendId,
    boilerHouseUUID,
    name,
    latitude,
    longitude,
    siteNumber,
    siteManager,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BoilerHouse &&
          other.backendId == this.backendId &&
          other.boilerHouseUUID == this.boilerHouseUUID &&
          other.name == this.name &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.siteNumber == this.siteNumber &&
          other.siteManager == this.siteManager &&
          other.updatedAt == this.updatedAt);
}

class BoilerHousesCompanion extends UpdateCompanion<BoilerHouse> {
  final Value<int> backendId;
  final Value<String?> boilerHouseUUID;
  final Value<String?> name;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<String?> siteNumber;
  final Value<String?> siteManager;
  final Value<DateTime?> updatedAt;
  const BoilerHousesCompanion({
    this.backendId = const Value.absent(),
    this.boilerHouseUUID = const Value.absent(),
    this.name = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.siteNumber = const Value.absent(),
    this.siteManager = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  BoilerHousesCompanion.insert({
    this.backendId = const Value.absent(),
    this.boilerHouseUUID = const Value.absent(),
    this.name = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.siteNumber = const Value.absent(),
    this.siteManager = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  static Insertable<BoilerHouse> custom({
    Expression<int>? backendId,
    Expression<String>? boilerHouseUUID,
    Expression<String>? name,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? siteNumber,
    Expression<String>? siteManager,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (backendId != null) 'backend_id': backendId,
      if (boilerHouseUUID != null) 'boiler_house_u_u_i_d': boilerHouseUUID,
      if (name != null) 'name': name,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (siteNumber != null) 'site_number': siteNumber,
      if (siteManager != null) 'site_manager': siteManager,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  BoilerHousesCompanion copyWith({
    Value<int>? backendId,
    Value<String?>? boilerHouseUUID,
    Value<String?>? name,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<String?>? siteNumber,
    Value<String?>? siteManager,
    Value<DateTime?>? updatedAt,
  }) {
    return BoilerHousesCompanion(
      backendId: backendId ?? this.backendId,
      boilerHouseUUID: boilerHouseUUID ?? this.boilerHouseUUID,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      siteNumber: siteNumber ?? this.siteNumber,
      siteManager: siteManager ?? this.siteManager,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (siteNumber.present) {
      map['site_number'] = Variable<String>(siteNumber.value);
    }
    if (siteManager.present) {
      map['site_manager'] = Variable<String>(siteManager.value);
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
          ..write('name: $name, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('siteNumber: $siteNumber, ')
          ..write('siteManager: $siteManager, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $SavedLocationsTable extends SavedLocations
    with TableInfo<$SavedLocationsTable, SavedLocation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavedLocationsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
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
    false,
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
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _managementCompanyIdMeta =
      const VerificationMeta('managementCompanyId');
  @override
  late final GeneratedColumn<String> managementCompanyId =
      GeneratedColumn<String>(
        'management_company_id',
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
  static const VerificationMeta _floorsMeta = const VerificationMeta('floors');
  @override
  late final GeneratedColumn<int> floors = GeneratedColumn<int>(
    'floors',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
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
  );
  static const VerificationMeta _roomsMeta = const VerificationMeta('rooms');
  @override
  late final GeneratedColumn<int> rooms = GeneratedColumn<int>(
    'rooms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
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
  static const VerificationMeta _providesHeatingMeta = const VerificationMeta(
    'providesHeating',
  );
  @override
  late final GeneratedColumn<bool> providesHeating = GeneratedColumn<bool>(
    'provides_heating',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("provides_heating" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _providesHotWaterMeta = const VerificationMeta(
    'providesHotWater',
  );
  @override
  late final GeneratedColumn<bool> providesHotWater = GeneratedColumn<bool>(
    'provides_hot_water',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("provides_hot_water" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
    locationUUID,
    name,
    latitude,
    longitude,
    managementCompanyId,
    boilerHouseId,
    floors,
    residentsCount,
    rooms,
    totalArea,
    yearBuilt,
    fiasHouseGuid,
    fiasAOGuid,
    providesHeating,
    providesHotWater,
    isStub,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'saved_locations';
  @override
  VerificationContext validateIntegrity(
    Insertable<SavedLocation> instance, {
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
    if (data.containsKey('location_u_u_i_d')) {
      context.handle(
        _locationUUIDMeta,
        locationUUID.isAcceptableOrUnknown(
          data['location_u_u_i_d']!,
          _locationUUIDMeta,
        ),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
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
    if (data.containsKey('management_company_id')) {
      context.handle(
        _managementCompanyIdMeta,
        managementCompanyId.isAcceptableOrUnknown(
          data['management_company_id']!,
          _managementCompanyIdMeta,
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
    if (data.containsKey('floors')) {
      context.handle(
        _floorsMeta,
        floors.isAcceptableOrUnknown(data['floors']!, _floorsMeta),
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
    if (data.containsKey('year_built')) {
      context.handle(
        _yearBuiltMeta,
        yearBuilt.isAcceptableOrUnknown(data['year_built']!, _yearBuiltMeta),
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
    if (data.containsKey('fias_a_o_guid')) {
      context.handle(
        _fiasAOGuidMeta,
        fiasAOGuid.isAcceptableOrUnknown(
          data['fias_a_o_guid']!,
          _fiasAOGuidMeta,
        ),
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
    if (data.containsKey('is_stub')) {
      context.handle(
        _isStubMeta,
        isStub.isAcceptableOrUnknown(data['is_stub']!, _isStubMeta),
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
  SavedLocation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavedLocation(
      backendId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}backend_id'],
      )!,
      locationUUID: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location_u_u_i_d'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      managementCompanyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}management_company_id'],
      ),
      boilerHouseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}boiler_house_id'],
      ),
      floors: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}floors'],
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
      yearBuilt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year_built'],
      ),
      fiasHouseGuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fias_house_guid'],
      ),
      fiasAOGuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fias_a_o_guid'],
      ),
      providesHeating: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}provides_heating'],
      )!,
      providesHotWater: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}provides_hot_water'],
      )!,
      isStub: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_stub'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $SavedLocationsTable createAlias(String alias) {
    return $SavedLocationsTable(attachedDatabase, alias);
  }
}

class SavedLocation extends DataClass implements Insertable<SavedLocation> {
  final int backendId;
  final String? locationUUID;
  final String? name;
  final double latitude;
  final double longitude;
  final String? managementCompanyId;
  final int? boilerHouseId;
  final int? floors;
  final int? residentsCount;
  final int? rooms;
  final double? totalArea;
  final int? yearBuilt;
  final String? fiasHouseGuid;
  final String? fiasAOGuid;
  final bool providesHeating;
  final bool providesHotWater;
  final bool isStub;
  final DateTime? updatedAt;
  const SavedLocation({
    required this.backendId,
    this.locationUUID,
    this.name,
    required this.latitude,
    required this.longitude,
    this.managementCompanyId,
    this.boilerHouseId,
    this.floors,
    this.residentsCount,
    this.rooms,
    this.totalArea,
    this.yearBuilt,
    this.fiasHouseGuid,
    this.fiasAOGuid,
    required this.providesHeating,
    required this.providesHotWater,
    required this.isStub,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['backend_id'] = Variable<int>(backendId);
    if (!nullToAbsent || locationUUID != null) {
      map['location_u_u_i_d'] = Variable<String>(locationUUID);
    }
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    if (!nullToAbsent || managementCompanyId != null) {
      map['management_company_id'] = Variable<String>(managementCompanyId);
    }
    if (!nullToAbsent || boilerHouseId != null) {
      map['boiler_house_id'] = Variable<int>(boilerHouseId);
    }
    if (!nullToAbsent || floors != null) {
      map['floors'] = Variable<int>(floors);
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
    if (!nullToAbsent || yearBuilt != null) {
      map['year_built'] = Variable<int>(yearBuilt);
    }
    if (!nullToAbsent || fiasHouseGuid != null) {
      map['fias_house_guid'] = Variable<String>(fiasHouseGuid);
    }
    if (!nullToAbsent || fiasAOGuid != null) {
      map['fias_a_o_guid'] = Variable<String>(fiasAOGuid);
    }
    map['provides_heating'] = Variable<bool>(providesHeating);
    map['provides_hot_water'] = Variable<bool>(providesHotWater);
    map['is_stub'] = Variable<bool>(isStub);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  SavedLocationsCompanion toCompanion(bool nullToAbsent) {
    return SavedLocationsCompanion(
      backendId: Value(backendId),
      locationUUID: locationUUID == null && nullToAbsent
          ? const Value.absent()
          : Value(locationUUID),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      latitude: Value(latitude),
      longitude: Value(longitude),
      managementCompanyId: managementCompanyId == null && nullToAbsent
          ? const Value.absent()
          : Value(managementCompanyId),
      boilerHouseId: boilerHouseId == null && nullToAbsent
          ? const Value.absent()
          : Value(boilerHouseId),
      floors: floors == null && nullToAbsent
          ? const Value.absent()
          : Value(floors),
      residentsCount: residentsCount == null && nullToAbsent
          ? const Value.absent()
          : Value(residentsCount),
      rooms: rooms == null && nullToAbsent
          ? const Value.absent()
          : Value(rooms),
      totalArea: totalArea == null && nullToAbsent
          ? const Value.absent()
          : Value(totalArea),
      yearBuilt: yearBuilt == null && nullToAbsent
          ? const Value.absent()
          : Value(yearBuilt),
      fiasHouseGuid: fiasHouseGuid == null && nullToAbsent
          ? const Value.absent()
          : Value(fiasHouseGuid),
      fiasAOGuid: fiasAOGuid == null && nullToAbsent
          ? const Value.absent()
          : Value(fiasAOGuid),
      providesHeating: Value(providesHeating),
      providesHotWater: Value(providesHotWater),
      isStub: Value(isStub),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory SavedLocation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavedLocation(
      backendId: serializer.fromJson<int>(json['backendId']),
      locationUUID: serializer.fromJson<String?>(json['locationUUID']),
      name: serializer.fromJson<String?>(json['name']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      managementCompanyId: serializer.fromJson<String?>(
        json['managementCompanyId'],
      ),
      boilerHouseId: serializer.fromJson<int?>(json['boilerHouseId']),
      floors: serializer.fromJson<int?>(json['floors']),
      residentsCount: serializer.fromJson<int?>(json['residentsCount']),
      rooms: serializer.fromJson<int?>(json['rooms']),
      totalArea: serializer.fromJson<double?>(json['totalArea']),
      yearBuilt: serializer.fromJson<int?>(json['yearBuilt']),
      fiasHouseGuid: serializer.fromJson<String?>(json['fiasHouseGuid']),
      fiasAOGuid: serializer.fromJson<String?>(json['fiasAOGuid']),
      providesHeating: serializer.fromJson<bool>(json['providesHeating']),
      providesHotWater: serializer.fromJson<bool>(json['providesHotWater']),
      isStub: serializer.fromJson<bool>(json['isStub']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'backendId': serializer.toJson<int>(backendId),
      'locationUUID': serializer.toJson<String?>(locationUUID),
      'name': serializer.toJson<String?>(name),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'managementCompanyId': serializer.toJson<String?>(managementCompanyId),
      'boilerHouseId': serializer.toJson<int?>(boilerHouseId),
      'floors': serializer.toJson<int?>(floors),
      'residentsCount': serializer.toJson<int?>(residentsCount),
      'rooms': serializer.toJson<int?>(rooms),
      'totalArea': serializer.toJson<double?>(totalArea),
      'yearBuilt': serializer.toJson<int?>(yearBuilt),
      'fiasHouseGuid': serializer.toJson<String?>(fiasHouseGuid),
      'fiasAOGuid': serializer.toJson<String?>(fiasAOGuid),
      'providesHeating': serializer.toJson<bool>(providesHeating),
      'providesHotWater': serializer.toJson<bool>(providesHotWater),
      'isStub': serializer.toJson<bool>(isStub),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  SavedLocation copyWith({
    int? backendId,
    Value<String?> locationUUID = const Value.absent(),
    Value<String?> name = const Value.absent(),
    double? latitude,
    double? longitude,
    Value<String?> managementCompanyId = const Value.absent(),
    Value<int?> boilerHouseId = const Value.absent(),
    Value<int?> floors = const Value.absent(),
    Value<int?> residentsCount = const Value.absent(),
    Value<int?> rooms = const Value.absent(),
    Value<double?> totalArea = const Value.absent(),
    Value<int?> yearBuilt = const Value.absent(),
    Value<String?> fiasHouseGuid = const Value.absent(),
    Value<String?> fiasAOGuid = const Value.absent(),
    bool? providesHeating,
    bool? providesHotWater,
    bool? isStub,
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => SavedLocation(
    backendId: backendId ?? this.backendId,
    locationUUID: locationUUID.present ? locationUUID.value : this.locationUUID,
    name: name.present ? name.value : this.name,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    managementCompanyId: managementCompanyId.present
        ? managementCompanyId.value
        : this.managementCompanyId,
    boilerHouseId: boilerHouseId.present
        ? boilerHouseId.value
        : this.boilerHouseId,
    floors: floors.present ? floors.value : this.floors,
    residentsCount: residentsCount.present
        ? residentsCount.value
        : this.residentsCount,
    rooms: rooms.present ? rooms.value : this.rooms,
    totalArea: totalArea.present ? totalArea.value : this.totalArea,
    yearBuilt: yearBuilt.present ? yearBuilt.value : this.yearBuilt,
    fiasHouseGuid: fiasHouseGuid.present
        ? fiasHouseGuid.value
        : this.fiasHouseGuid,
    fiasAOGuid: fiasAOGuid.present ? fiasAOGuid.value : this.fiasAOGuid,
    providesHeating: providesHeating ?? this.providesHeating,
    providesHotWater: providesHotWater ?? this.providesHotWater,
    isStub: isStub ?? this.isStub,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  SavedLocation copyWithCompanion(SavedLocationsCompanion data) {
    return SavedLocation(
      backendId: data.backendId.present ? data.backendId.value : this.backendId,
      locationUUID: data.locationUUID.present
          ? data.locationUUID.value
          : this.locationUUID,
      name: data.name.present ? data.name.value : this.name,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      managementCompanyId: data.managementCompanyId.present
          ? data.managementCompanyId.value
          : this.managementCompanyId,
      boilerHouseId: data.boilerHouseId.present
          ? data.boilerHouseId.value
          : this.boilerHouseId,
      floors: data.floors.present ? data.floors.value : this.floors,
      residentsCount: data.residentsCount.present
          ? data.residentsCount.value
          : this.residentsCount,
      rooms: data.rooms.present ? data.rooms.value : this.rooms,
      totalArea: data.totalArea.present ? data.totalArea.value : this.totalArea,
      yearBuilt: data.yearBuilt.present ? data.yearBuilt.value : this.yearBuilt,
      fiasHouseGuid: data.fiasHouseGuid.present
          ? data.fiasHouseGuid.value
          : this.fiasHouseGuid,
      fiasAOGuid: data.fiasAOGuid.present
          ? data.fiasAOGuid.value
          : this.fiasAOGuid,
      providesHeating: data.providesHeating.present
          ? data.providesHeating.value
          : this.providesHeating,
      providesHotWater: data.providesHotWater.present
          ? data.providesHotWater.value
          : this.providesHotWater,
      isStub: data.isStub.present ? data.isStub.value : this.isStub,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavedLocation(')
          ..write('backendId: $backendId, ')
          ..write('locationUUID: $locationUUID, ')
          ..write('name: $name, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('managementCompanyId: $managementCompanyId, ')
          ..write('boilerHouseId: $boilerHouseId, ')
          ..write('floors: $floors, ')
          ..write('residentsCount: $residentsCount, ')
          ..write('rooms: $rooms, ')
          ..write('totalArea: $totalArea, ')
          ..write('yearBuilt: $yearBuilt, ')
          ..write('fiasHouseGuid: $fiasHouseGuid, ')
          ..write('fiasAOGuid: $fiasAOGuid, ')
          ..write('providesHeating: $providesHeating, ')
          ..write('providesHotWater: $providesHotWater, ')
          ..write('isStub: $isStub, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    backendId,
    locationUUID,
    name,
    latitude,
    longitude,
    managementCompanyId,
    boilerHouseId,
    floors,
    residentsCount,
    rooms,
    totalArea,
    yearBuilt,
    fiasHouseGuid,
    fiasAOGuid,
    providesHeating,
    providesHotWater,
    isStub,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavedLocation &&
          other.backendId == this.backendId &&
          other.locationUUID == this.locationUUID &&
          other.name == this.name &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.managementCompanyId == this.managementCompanyId &&
          other.boilerHouseId == this.boilerHouseId &&
          other.floors == this.floors &&
          other.residentsCount == this.residentsCount &&
          other.rooms == this.rooms &&
          other.totalArea == this.totalArea &&
          other.yearBuilt == this.yearBuilt &&
          other.fiasHouseGuid == this.fiasHouseGuid &&
          other.fiasAOGuid == this.fiasAOGuid &&
          other.providesHeating == this.providesHeating &&
          other.providesHotWater == this.providesHotWater &&
          other.isStub == this.isStub &&
          other.updatedAt == this.updatedAt);
}

class SavedLocationsCompanion extends UpdateCompanion<SavedLocation> {
  final Value<int> backendId;
  final Value<String?> locationUUID;
  final Value<String?> name;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<String?> managementCompanyId;
  final Value<int?> boilerHouseId;
  final Value<int?> floors;
  final Value<int?> residentsCount;
  final Value<int?> rooms;
  final Value<double?> totalArea;
  final Value<int?> yearBuilt;
  final Value<String?> fiasHouseGuid;
  final Value<String?> fiasAOGuid;
  final Value<bool> providesHeating;
  final Value<bool> providesHotWater;
  final Value<bool> isStub;
  final Value<DateTime?> updatedAt;
  const SavedLocationsCompanion({
    this.backendId = const Value.absent(),
    this.locationUUID = const Value.absent(),
    this.name = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.managementCompanyId = const Value.absent(),
    this.boilerHouseId = const Value.absent(),
    this.floors = const Value.absent(),
    this.residentsCount = const Value.absent(),
    this.rooms = const Value.absent(),
    this.totalArea = const Value.absent(),
    this.yearBuilt = const Value.absent(),
    this.fiasHouseGuid = const Value.absent(),
    this.fiasAOGuid = const Value.absent(),
    this.providesHeating = const Value.absent(),
    this.providesHotWater = const Value.absent(),
    this.isStub = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  SavedLocationsCompanion.insert({
    this.backendId = const Value.absent(),
    this.locationUUID = const Value.absent(),
    this.name = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.managementCompanyId = const Value.absent(),
    this.boilerHouseId = const Value.absent(),
    this.floors = const Value.absent(),
    this.residentsCount = const Value.absent(),
    this.rooms = const Value.absent(),
    this.totalArea = const Value.absent(),
    this.yearBuilt = const Value.absent(),
    this.fiasHouseGuid = const Value.absent(),
    this.fiasAOGuid = const Value.absent(),
    this.providesHeating = const Value.absent(),
    this.providesHotWater = const Value.absent(),
    this.isStub = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  static Insertable<SavedLocation> custom({
    Expression<int>? backendId,
    Expression<String>? locationUUID,
    Expression<String>? name,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? managementCompanyId,
    Expression<int>? boilerHouseId,
    Expression<int>? floors,
    Expression<int>? residentsCount,
    Expression<int>? rooms,
    Expression<double>? totalArea,
    Expression<int>? yearBuilt,
    Expression<String>? fiasHouseGuid,
    Expression<String>? fiasAOGuid,
    Expression<bool>? providesHeating,
    Expression<bool>? providesHotWater,
    Expression<bool>? isStub,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (backendId != null) 'backend_id': backendId,
      if (locationUUID != null) 'location_u_u_i_d': locationUUID,
      if (name != null) 'name': name,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (managementCompanyId != null)
        'management_company_id': managementCompanyId,
      if (boilerHouseId != null) 'boiler_house_id': boilerHouseId,
      if (floors != null) 'floors': floors,
      if (residentsCount != null) 'residents_count': residentsCount,
      if (rooms != null) 'rooms': rooms,
      if (totalArea != null) 'total_area': totalArea,
      if (yearBuilt != null) 'year_built': yearBuilt,
      if (fiasHouseGuid != null) 'fias_house_guid': fiasHouseGuid,
      if (fiasAOGuid != null) 'fias_a_o_guid': fiasAOGuid,
      if (providesHeating != null) 'provides_heating': providesHeating,
      if (providesHotWater != null) 'provides_hot_water': providesHotWater,
      if (isStub != null) 'is_stub': isStub,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  SavedLocationsCompanion copyWith({
    Value<int>? backendId,
    Value<String?>? locationUUID,
    Value<String?>? name,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<String?>? managementCompanyId,
    Value<int?>? boilerHouseId,
    Value<int?>? floors,
    Value<int?>? residentsCount,
    Value<int?>? rooms,
    Value<double?>? totalArea,
    Value<int?>? yearBuilt,
    Value<String?>? fiasHouseGuid,
    Value<String?>? fiasAOGuid,
    Value<bool>? providesHeating,
    Value<bool>? providesHotWater,
    Value<bool>? isStub,
    Value<DateTime?>? updatedAt,
  }) {
    return SavedLocationsCompanion(
      backendId: backendId ?? this.backendId,
      locationUUID: locationUUID ?? this.locationUUID,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      managementCompanyId: managementCompanyId ?? this.managementCompanyId,
      boilerHouseId: boilerHouseId ?? this.boilerHouseId,
      floors: floors ?? this.floors,
      residentsCount: residentsCount ?? this.residentsCount,
      rooms: rooms ?? this.rooms,
      totalArea: totalArea ?? this.totalArea,
      yearBuilt: yearBuilt ?? this.yearBuilt,
      fiasHouseGuid: fiasHouseGuid ?? this.fiasHouseGuid,
      fiasAOGuid: fiasAOGuid ?? this.fiasAOGuid,
      providesHeating: providesHeating ?? this.providesHeating,
      providesHotWater: providesHotWater ?? this.providesHotWater,
      isStub: isStub ?? this.isStub,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (backendId.present) {
      map['backend_id'] = Variable<int>(backendId.value);
    }
    if (locationUUID.present) {
      map['location_u_u_i_d'] = Variable<String>(locationUUID.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (managementCompanyId.present) {
      map['management_company_id'] = Variable<String>(
        managementCompanyId.value,
      );
    }
    if (boilerHouseId.present) {
      map['boiler_house_id'] = Variable<int>(boilerHouseId.value);
    }
    if (floors.present) {
      map['floors'] = Variable<int>(floors.value);
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
    if (yearBuilt.present) {
      map['year_built'] = Variable<int>(yearBuilt.value);
    }
    if (fiasHouseGuid.present) {
      map['fias_house_guid'] = Variable<String>(fiasHouseGuid.value);
    }
    if (fiasAOGuid.present) {
      map['fias_a_o_guid'] = Variable<String>(fiasAOGuid.value);
    }
    if (providesHeating.present) {
      map['provides_heating'] = Variable<bool>(providesHeating.value);
    }
    if (providesHotWater.present) {
      map['provides_hot_water'] = Variable<bool>(providesHotWater.value);
    }
    if (isStub.present) {
      map['is_stub'] = Variable<bool>(isStub.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavedLocationsCompanion(')
          ..write('backendId: $backendId, ')
          ..write('locationUUID: $locationUUID, ')
          ..write('name: $name, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('managementCompanyId: $managementCompanyId, ')
          ..write('boilerHouseId: $boilerHouseId, ')
          ..write('floors: $floors, ')
          ..write('residentsCount: $residentsCount, ')
          ..write('rooms: $rooms, ')
          ..write('totalArea: $totalArea, ')
          ..write('yearBuilt: $yearBuilt, ')
          ..write('fiasHouseGuid: $fiasHouseGuid, ')
          ..write('fiasAOGuid: $fiasAOGuid, ')
          ..write('providesHeating: $providesHeating, ')
          ..write('providesHotWater: $providesHotWater, ')
          ..write('isStub: $isStub, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $IncidentsTable extends Incidents
    with TableInfo<$IncidentsTable, Incident> {
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
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<IncidentStatus?, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<IncidentStatus?>($IncidentsTable.$converterstatusn);
  static const VerificationMeta _severityMeta = const VerificationMeta(
    'severity',
  );
  @override
  late final GeneratedColumn<int> severity = GeneratedColumn<int>(
    'severity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _resourceHotWaterStoppedMeta =
      const VerificationMeta('resourceHotWaterStopped');
  @override
  late final GeneratedColumn<bool> resourceHotWaterStopped =
      GeneratedColumn<bool>(
        'resource_hot_water_stopped',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("resource_hot_water_stopped" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _resourceHeatingStoppedMeta =
      const VerificationMeta('resourceHeatingStopped');
  @override
  late final GeneratedColumn<bool> resourceHeatingStopped =
      GeneratedColumn<bool>(
        'resource_heating_stopped',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("resource_heating_stopped" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
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
  static const VerificationMeta _resolvedAtMeta = const VerificationMeta(
    'resolvedAt',
  );
  @override
  late final GeneratedColumn<DateTime> resolvedAt = GeneratedColumn<DateTime>(
    'resolved_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reportedByMeta = const VerificationMeta(
    'reportedBy',
  );
  @override
  late final GeneratedColumn<int> reportedBy = GeneratedColumn<int>(
    'reported_by',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
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
  @override
  List<GeneratedColumn> get $columns => [
    backendId,
    incidentUUID,
    boilerHouseId,
    title,
    description,
    status,
    severity,
    resourceHotWaterStopped,
    resourceHeatingStopped,
    createdAt,
    updatedAt,
    resolvedAt,
    reportedBy,
    assignedTo,
    notificationConfigType,
    notificationConfigRoleIds,
    notificationConfigUserIds,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'incidents';
  @override
  VerificationContext validateIntegrity(
    Insertable<Incident> instance, {
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
    if (data.containsKey('incident_u_u_i_d')) {
      context.handle(
        _incidentUUIDMeta,
        incidentUUID.isAcceptableOrUnknown(
          data['incident_u_u_i_d']!,
          _incidentUUIDMeta,
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
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('severity')) {
      context.handle(
        _severityMeta,
        severity.isAcceptableOrUnknown(data['severity']!, _severityMeta),
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
    if (data.containsKey('resource_heating_stopped')) {
      context.handle(
        _resourceHeatingStoppedMeta,
        resourceHeatingStopped.isAcceptableOrUnknown(
          data['resource_heating_stopped']!,
          _resourceHeatingStoppedMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('resolved_at')) {
      context.handle(
        _resolvedAtMeta,
        resolvedAt.isAcceptableOrUnknown(data['resolved_at']!, _resolvedAtMeta),
      );
    }
    if (data.containsKey('reported_by')) {
      context.handle(
        _reportedByMeta,
        reportedBy.isAcceptableOrUnknown(data['reported_by']!, _reportedByMeta),
      );
    }
    if (data.containsKey('assigned_to')) {
      context.handle(
        _assignedToMeta,
        assignedTo.isAcceptableOrUnknown(data['assigned_to']!, _assignedToMeta),
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
    if (data.containsKey('notification_config_role_ids')) {
      context.handle(
        _notificationConfigRoleIdsMeta,
        notificationConfigRoleIds.isAcceptableOrUnknown(
          data['notification_config_role_ids']!,
          _notificationConfigRoleIdsMeta,
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {backendId};
  @override
  Incident map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Incident(
      backendId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}backend_id'],
      )!,
      incidentUUID: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}incident_u_u_i_d'],
      ),
      boilerHouseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}boiler_house_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      status: $IncidentsTable.$converterstatusn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        ),
      ),
      severity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}severity'],
      )!,
      resourceHotWaterStopped: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}resource_hot_water_stopped'],
      )!,
      resourceHeatingStopped: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}resource_heating_stopped'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      resolvedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}resolved_at'],
      ),
      reportedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reported_by'],
      ),
      assignedTo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}assigned_to'],
      ),
      notificationConfigType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notification_config_type'],
      ),
      notificationConfigRoleIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notification_config_role_ids'],
      ),
      notificationConfigUserIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notification_config_user_ids'],
      ),
    );
  }

  @override
  $IncidentsTable createAlias(String alias) {
    return $IncidentsTable(attachedDatabase, alias);
  }

  static TypeConverter<IncidentStatus, String> $converterstatus =
      const IncidentStatusConverter();
  static TypeConverter<IncidentStatus?, String?> $converterstatusn =
      NullAwareTypeConverter.wrap($converterstatus);
}

class Incident extends DataClass implements Insertable<Incident> {
  final int backendId;
  final String? incidentUUID;
  final int? boilerHouseId;
  final String? title;
  final String? description;
  final IncidentStatus? status;
  final int severity;
  final bool resourceHotWaterStopped;
  final bool resourceHeatingStopped;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? resolvedAt;
  final int? reportedBy;
  final int? assignedTo;
  final String? notificationConfigType;
  final String? notificationConfigRoleIds;
  final String? notificationConfigUserIds;
  const Incident({
    required this.backendId,
    this.incidentUUID,
    this.boilerHouseId,
    this.title,
    this.description,
    this.status,
    required this.severity,
    required this.resourceHotWaterStopped,
    required this.resourceHeatingStopped,
    this.createdAt,
    this.updatedAt,
    this.resolvedAt,
    this.reportedBy,
    this.assignedTo,
    this.notificationConfigType,
    this.notificationConfigRoleIds,
    this.notificationConfigUserIds,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['backend_id'] = Variable<int>(backendId);
    if (!nullToAbsent || incidentUUID != null) {
      map['incident_u_u_i_d'] = Variable<String>(incidentUUID);
    }
    if (!nullToAbsent || boilerHouseId != null) {
      map['boiler_house_id'] = Variable<int>(boilerHouseId);
    }
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || status != null) {
      map['status'] = Variable<String>(
        $IncidentsTable.$converterstatusn.toSql(status),
      );
    }
    map['severity'] = Variable<int>(severity);
    map['resource_hot_water_stopped'] = Variable<bool>(resourceHotWaterStopped);
    map['resource_heating_stopped'] = Variable<bool>(resourceHeatingStopped);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || resolvedAt != null) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt);
    }
    if (!nullToAbsent || reportedBy != null) {
      map['reported_by'] = Variable<int>(reportedBy);
    }
    if (!nullToAbsent || assignedTo != null) {
      map['assigned_to'] = Variable<int>(assignedTo);
    }
    if (!nullToAbsent || notificationConfigType != null) {
      map['notification_config_type'] = Variable<String>(
        notificationConfigType,
      );
    }
    if (!nullToAbsent || notificationConfigRoleIds != null) {
      map['notification_config_role_ids'] = Variable<String>(
        notificationConfigRoleIds,
      );
    }
    if (!nullToAbsent || notificationConfigUserIds != null) {
      map['notification_config_user_ids'] = Variable<String>(
        notificationConfigUserIds,
      );
    }
    return map;
  }

  IncidentsCompanion toCompanion(bool nullToAbsent) {
    return IncidentsCompanion(
      backendId: Value(backendId),
      incidentUUID: incidentUUID == null && nullToAbsent
          ? const Value.absent()
          : Value(incidentUUID),
      boilerHouseId: boilerHouseId == null && nullToAbsent
          ? const Value.absent()
          : Value(boilerHouseId),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      status: status == null && nullToAbsent
          ? const Value.absent()
          : Value(status),
      severity: Value(severity),
      resourceHotWaterStopped: Value(resourceHotWaterStopped),
      resourceHeatingStopped: Value(resourceHeatingStopped),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      resolvedAt: resolvedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(resolvedAt),
      reportedBy: reportedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(reportedBy),
      assignedTo: assignedTo == null && nullToAbsent
          ? const Value.absent()
          : Value(assignedTo),
      notificationConfigType: notificationConfigType == null && nullToAbsent
          ? const Value.absent()
          : Value(notificationConfigType),
      notificationConfigRoleIds:
          notificationConfigRoleIds == null && nullToAbsent
          ? const Value.absent()
          : Value(notificationConfigRoleIds),
      notificationConfigUserIds:
          notificationConfigUserIds == null && nullToAbsent
          ? const Value.absent()
          : Value(notificationConfigUserIds),
    );
  }

  factory Incident.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Incident(
      backendId: serializer.fromJson<int>(json['backendId']),
      incidentUUID: serializer.fromJson<String?>(json['incidentUUID']),
      boilerHouseId: serializer.fromJson<int?>(json['boilerHouseId']),
      title: serializer.fromJson<String?>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      status: serializer.fromJson<IncidentStatus?>(json['status']),
      severity: serializer.fromJson<int>(json['severity']),
      resourceHotWaterStopped: serializer.fromJson<bool>(
        json['resourceHotWaterStopped'],
      ),
      resourceHeatingStopped: serializer.fromJson<bool>(
        json['resourceHeatingStopped'],
      ),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      resolvedAt: serializer.fromJson<DateTime?>(json['resolvedAt']),
      reportedBy: serializer.fromJson<int?>(json['reportedBy']),
      assignedTo: serializer.fromJson<int?>(json['assignedTo']),
      notificationConfigType: serializer.fromJson<String?>(
        json['notificationConfigType'],
      ),
      notificationConfigRoleIds: serializer.fromJson<String?>(
        json['notificationConfigRoleIds'],
      ),
      notificationConfigUserIds: serializer.fromJson<String?>(
        json['notificationConfigUserIds'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'backendId': serializer.toJson<int>(backendId),
      'incidentUUID': serializer.toJson<String?>(incidentUUID),
      'boilerHouseId': serializer.toJson<int?>(boilerHouseId),
      'title': serializer.toJson<String?>(title),
      'description': serializer.toJson<String?>(description),
      'status': serializer.toJson<IncidentStatus?>(status),
      'severity': serializer.toJson<int>(severity),
      'resourceHotWaterStopped': serializer.toJson<bool>(
        resourceHotWaterStopped,
      ),
      'resourceHeatingStopped': serializer.toJson<bool>(resourceHeatingStopped),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'resolvedAt': serializer.toJson<DateTime?>(resolvedAt),
      'reportedBy': serializer.toJson<int?>(reportedBy),
      'assignedTo': serializer.toJson<int?>(assignedTo),
      'notificationConfigType': serializer.toJson<String?>(
        notificationConfigType,
      ),
      'notificationConfigRoleIds': serializer.toJson<String?>(
        notificationConfigRoleIds,
      ),
      'notificationConfigUserIds': serializer.toJson<String?>(
        notificationConfigUserIds,
      ),
    };
  }

  Incident copyWith({
    int? backendId,
    Value<String?> incidentUUID = const Value.absent(),
    Value<int?> boilerHouseId = const Value.absent(),
    Value<String?> title = const Value.absent(),
    Value<String?> description = const Value.absent(),
    Value<IncidentStatus?> status = const Value.absent(),
    int? severity,
    bool? resourceHotWaterStopped,
    bool? resourceHeatingStopped,
    Value<DateTime?> createdAt = const Value.absent(),
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<DateTime?> resolvedAt = const Value.absent(),
    Value<int?> reportedBy = const Value.absent(),
    Value<int?> assignedTo = const Value.absent(),
    Value<String?> notificationConfigType = const Value.absent(),
    Value<String?> notificationConfigRoleIds = const Value.absent(),
    Value<String?> notificationConfigUserIds = const Value.absent(),
  }) => Incident(
    backendId: backendId ?? this.backendId,
    incidentUUID: incidentUUID.present ? incidentUUID.value : this.incidentUUID,
    boilerHouseId: boilerHouseId.present
        ? boilerHouseId.value
        : this.boilerHouseId,
    title: title.present ? title.value : this.title,
    description: description.present ? description.value : this.description,
    status: status.present ? status.value : this.status,
    severity: severity ?? this.severity,
    resourceHotWaterStopped:
        resourceHotWaterStopped ?? this.resourceHotWaterStopped,
    resourceHeatingStopped:
        resourceHeatingStopped ?? this.resourceHeatingStopped,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    resolvedAt: resolvedAt.present ? resolvedAt.value : this.resolvedAt,
    reportedBy: reportedBy.present ? reportedBy.value : this.reportedBy,
    assignedTo: assignedTo.present ? assignedTo.value : this.assignedTo,
    notificationConfigType: notificationConfigType.present
        ? notificationConfigType.value
        : this.notificationConfigType,
    notificationConfigRoleIds: notificationConfigRoleIds.present
        ? notificationConfigRoleIds.value
        : this.notificationConfigRoleIds,
    notificationConfigUserIds: notificationConfigUserIds.present
        ? notificationConfigUserIds.value
        : this.notificationConfigUserIds,
  );
  Incident copyWithCompanion(IncidentsCompanion data) {
    return Incident(
      backendId: data.backendId.present ? data.backendId.value : this.backendId,
      incidentUUID: data.incidentUUID.present
          ? data.incidentUUID.value
          : this.incidentUUID,
      boilerHouseId: data.boilerHouseId.present
          ? data.boilerHouseId.value
          : this.boilerHouseId,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      status: data.status.present ? data.status.value : this.status,
      severity: data.severity.present ? data.severity.value : this.severity,
      resourceHotWaterStopped: data.resourceHotWaterStopped.present
          ? data.resourceHotWaterStopped.value
          : this.resourceHotWaterStopped,
      resourceHeatingStopped: data.resourceHeatingStopped.present
          ? data.resourceHeatingStopped.value
          : this.resourceHeatingStopped,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      resolvedAt: data.resolvedAt.present
          ? data.resolvedAt.value
          : this.resolvedAt,
      reportedBy: data.reportedBy.present
          ? data.reportedBy.value
          : this.reportedBy,
      assignedTo: data.assignedTo.present
          ? data.assignedTo.value
          : this.assignedTo,
      notificationConfigType: data.notificationConfigType.present
          ? data.notificationConfigType.value
          : this.notificationConfigType,
      notificationConfigRoleIds: data.notificationConfigRoleIds.present
          ? data.notificationConfigRoleIds.value
          : this.notificationConfigRoleIds,
      notificationConfigUserIds: data.notificationConfigUserIds.present
          ? data.notificationConfigUserIds.value
          : this.notificationConfigUserIds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Incident(')
          ..write('backendId: $backendId, ')
          ..write('incidentUUID: $incidentUUID, ')
          ..write('boilerHouseId: $boilerHouseId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('status: $status, ')
          ..write('severity: $severity, ')
          ..write('resourceHotWaterStopped: $resourceHotWaterStopped, ')
          ..write('resourceHeatingStopped: $resourceHeatingStopped, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('reportedBy: $reportedBy, ')
          ..write('assignedTo: $assignedTo, ')
          ..write('notificationConfigType: $notificationConfigType, ')
          ..write('notificationConfigRoleIds: $notificationConfigRoleIds, ')
          ..write('notificationConfigUserIds: $notificationConfigUserIds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    backendId,
    incidentUUID,
    boilerHouseId,
    title,
    description,
    status,
    severity,
    resourceHotWaterStopped,
    resourceHeatingStopped,
    createdAt,
    updatedAt,
    resolvedAt,
    reportedBy,
    assignedTo,
    notificationConfigType,
    notificationConfigRoleIds,
    notificationConfigUserIds,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Incident &&
          other.backendId == this.backendId &&
          other.incidentUUID == this.incidentUUID &&
          other.boilerHouseId == this.boilerHouseId &&
          other.title == this.title &&
          other.description == this.description &&
          other.status == this.status &&
          other.severity == this.severity &&
          other.resourceHotWaterStopped == this.resourceHotWaterStopped &&
          other.resourceHeatingStopped == this.resourceHeatingStopped &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.resolvedAt == this.resolvedAt &&
          other.reportedBy == this.reportedBy &&
          other.assignedTo == this.assignedTo &&
          other.notificationConfigType == this.notificationConfigType &&
          other.notificationConfigRoleIds == this.notificationConfigRoleIds &&
          other.notificationConfigUserIds == this.notificationConfigUserIds);
}

class IncidentsCompanion extends UpdateCompanion<Incident> {
  final Value<int> backendId;
  final Value<String?> incidentUUID;
  final Value<int?> boilerHouseId;
  final Value<String?> title;
  final Value<String?> description;
  final Value<IncidentStatus?> status;
  final Value<int> severity;
  final Value<bool> resourceHotWaterStopped;
  final Value<bool> resourceHeatingStopped;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> resolvedAt;
  final Value<int?> reportedBy;
  final Value<int?> assignedTo;
  final Value<String?> notificationConfigType;
  final Value<String?> notificationConfigRoleIds;
  final Value<String?> notificationConfigUserIds;
  const IncidentsCompanion({
    this.backendId = const Value.absent(),
    this.incidentUUID = const Value.absent(),
    this.boilerHouseId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.status = const Value.absent(),
    this.severity = const Value.absent(),
    this.resourceHotWaterStopped = const Value.absent(),
    this.resourceHeatingStopped = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.resolvedAt = const Value.absent(),
    this.reportedBy = const Value.absent(),
    this.assignedTo = const Value.absent(),
    this.notificationConfigType = const Value.absent(),
    this.notificationConfigRoleIds = const Value.absent(),
    this.notificationConfigUserIds = const Value.absent(),
  });
  IncidentsCompanion.insert({
    this.backendId = const Value.absent(),
    this.incidentUUID = const Value.absent(),
    this.boilerHouseId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.status = const Value.absent(),
    this.severity = const Value.absent(),
    this.resourceHotWaterStopped = const Value.absent(),
    this.resourceHeatingStopped = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.resolvedAt = const Value.absent(),
    this.reportedBy = const Value.absent(),
    this.assignedTo = const Value.absent(),
    this.notificationConfigType = const Value.absent(),
    this.notificationConfigRoleIds = const Value.absent(),
    this.notificationConfigUserIds = const Value.absent(),
  });
  static Insertable<Incident> custom({
    Expression<int>? backendId,
    Expression<String>? incidentUUID,
    Expression<int>? boilerHouseId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? status,
    Expression<int>? severity,
    Expression<bool>? resourceHotWaterStopped,
    Expression<bool>? resourceHeatingStopped,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? resolvedAt,
    Expression<int>? reportedBy,
    Expression<int>? assignedTo,
    Expression<String>? notificationConfigType,
    Expression<String>? notificationConfigRoleIds,
    Expression<String>? notificationConfigUserIds,
  }) {
    return RawValuesInsertable({
      if (backendId != null) 'backend_id': backendId,
      if (incidentUUID != null) 'incident_u_u_i_d': incidentUUID,
      if (boilerHouseId != null) 'boiler_house_id': boilerHouseId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (status != null) 'status': status,
      if (severity != null) 'severity': severity,
      if (resourceHotWaterStopped != null)
        'resource_hot_water_stopped': resourceHotWaterStopped,
      if (resourceHeatingStopped != null)
        'resource_heating_stopped': resourceHeatingStopped,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (resolvedAt != null) 'resolved_at': resolvedAt,
      if (reportedBy != null) 'reported_by': reportedBy,
      if (assignedTo != null) 'assigned_to': assignedTo,
      if (notificationConfigType != null)
        'notification_config_type': notificationConfigType,
      if (notificationConfigRoleIds != null)
        'notification_config_role_ids': notificationConfigRoleIds,
      if (notificationConfigUserIds != null)
        'notification_config_user_ids': notificationConfigUserIds,
    });
  }

  IncidentsCompanion copyWith({
    Value<int>? backendId,
    Value<String?>? incidentUUID,
    Value<int?>? boilerHouseId,
    Value<String?>? title,
    Value<String?>? description,
    Value<IncidentStatus?>? status,
    Value<int>? severity,
    Value<bool>? resourceHotWaterStopped,
    Value<bool>? resourceHeatingStopped,
    Value<DateTime?>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<DateTime?>? resolvedAt,
    Value<int?>? reportedBy,
    Value<int?>? assignedTo,
    Value<String?>? notificationConfigType,
    Value<String?>? notificationConfigRoleIds,
    Value<String?>? notificationConfigUserIds,
  }) {
    return IncidentsCompanion(
      backendId: backendId ?? this.backendId,
      incidentUUID: incidentUUID ?? this.incidentUUID,
      boilerHouseId: boilerHouseId ?? this.boilerHouseId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      severity: severity ?? this.severity,
      resourceHotWaterStopped:
          resourceHotWaterStopped ?? this.resourceHotWaterStopped,
      resourceHeatingStopped:
          resourceHeatingStopped ?? this.resourceHeatingStopped,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      reportedBy: reportedBy ?? this.reportedBy,
      assignedTo: assignedTo ?? this.assignedTo,
      notificationConfigType:
          notificationConfigType ?? this.notificationConfigType,
      notificationConfigRoleIds:
          notificationConfigRoleIds ?? this.notificationConfigRoleIds,
      notificationConfigUserIds:
          notificationConfigUserIds ?? this.notificationConfigUserIds,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (backendId.present) {
      map['backend_id'] = Variable<int>(backendId.value);
    }
    if (incidentUUID.present) {
      map['incident_u_u_i_d'] = Variable<String>(incidentUUID.value);
    }
    if (boilerHouseId.present) {
      map['boiler_house_id'] = Variable<int>(boilerHouseId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $IncidentsTable.$converterstatusn.toSql(status.value),
      );
    }
    if (severity.present) {
      map['severity'] = Variable<int>(severity.value);
    }
    if (resourceHotWaterStopped.present) {
      map['resource_hot_water_stopped'] = Variable<bool>(
        resourceHotWaterStopped.value,
      );
    }
    if (resourceHeatingStopped.present) {
      map['resource_heating_stopped'] = Variable<bool>(
        resourceHeatingStopped.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (resolvedAt.present) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt.value);
    }
    if (reportedBy.present) {
      map['reported_by'] = Variable<int>(reportedBy.value);
    }
    if (assignedTo.present) {
      map['assigned_to'] = Variable<int>(assignedTo.value);
    }
    if (notificationConfigType.present) {
      map['notification_config_type'] = Variable<String>(
        notificationConfigType.value,
      );
    }
    if (notificationConfigRoleIds.present) {
      map['notification_config_role_ids'] = Variable<String>(
        notificationConfigRoleIds.value,
      );
    }
    if (notificationConfigUserIds.present) {
      map['notification_config_user_ids'] = Variable<String>(
        notificationConfigUserIds.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IncidentsCompanion(')
          ..write('backendId: $backendId, ')
          ..write('incidentUUID: $incidentUUID, ')
          ..write('boilerHouseId: $boilerHouseId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('status: $status, ')
          ..write('severity: $severity, ')
          ..write('resourceHotWaterStopped: $resourceHotWaterStopped, ')
          ..write('resourceHeatingStopped: $resourceHeatingStopped, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('reportedBy: $reportedBy, ')
          ..write('assignedTo: $assignedTo, ')
          ..write('notificationConfigType: $notificationConfigType, ')
          ..write('notificationConfigRoleIds: $notificationConfigRoleIds, ')
          ..write('notificationConfigUserIds: $notificationConfigUserIds')
          ..write(')'))
        .toString();
  }
}

class $AffectedHousesTable extends AffectedHouses
    with TableInfo<$AffectedHousesTable, AffectedHouse> {
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
    Insertable<AffectedHouse> instance, {
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
  AffectedHouse map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AffectedHouse(
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

class AffectedHouse extends DataClass implements Insertable<AffectedHouse> {
  final int incidentId;
  final int savedLocationId;
  const AffectedHouse({
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

  factory AffectedHouse.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AffectedHouse(
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

  AffectedHouse copyWith({int? incidentId, int? savedLocationId}) =>
      AffectedHouse(
        incidentId: incidentId ?? this.incidentId,
        savedLocationId: savedLocationId ?? this.savedLocationId,
      );
  AffectedHouse copyWithCompanion(AffectedHousesCompanion data) {
    return AffectedHouse(
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
    return (StringBuffer('AffectedHouse(')
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
      (other is AffectedHouse &&
          other.incidentId == this.incidentId &&
          other.savedLocationId == this.savedLocationId);
}

class AffectedHousesCompanion extends UpdateCompanion<AffectedHouse> {
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
  static Insertable<AffectedHouse> custom({
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

class $IncidentPhotosTable extends IncidentPhotos
    with TableInfo<$IncidentPhotosTable, IncidentPhoto> {
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
  );
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
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  @override
  List<GeneratedColumn> get $columns => [
    backendId,
    incidentId,
    url,
    thumbnailUrl,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'incident_photos';
  @override
  VerificationContext validateIntegrity(
    Insertable<IncidentPhoto> instance, {
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
    if (data.containsKey('incident_id')) {
      context.handle(
        _incidentIdMeta,
        incidentId.isAcceptableOrUnknown(data['incident_id']!, _incidentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_incidentIdMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
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
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {backendId};
  @override
  IncidentPhoto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IncidentPhoto(
      backendId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}backend_id'],
      )!,
      incidentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}incident_id'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      thumbnailUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail_url'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
    );
  }

  @override
  $IncidentPhotosTable createAlias(String alias) {
    return $IncidentPhotosTable(attachedDatabase, alias);
  }
}

class IncidentPhoto extends DataClass implements Insertable<IncidentPhoto> {
  final int backendId;
  final int incidentId;
  final String url;
  final String? thumbnailUrl;
  final DateTime? createdAt;
  const IncidentPhoto({
    required this.backendId,
    required this.incidentId,
    required this.url,
    this.thumbnailUrl,
    this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['backend_id'] = Variable<int>(backendId);
    map['incident_id'] = Variable<int>(incidentId);
    map['url'] = Variable<String>(url);
    if (!nullToAbsent || thumbnailUrl != null) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    return map;
  }

  IncidentPhotosCompanion toCompanion(bool nullToAbsent) {
    return IncidentPhotosCompanion(
      backendId: Value(backendId),
      incidentId: Value(incidentId),
      url: Value(url),
      thumbnailUrl: thumbnailUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailUrl),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
    );
  }

  factory IncidentPhoto.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IncidentPhoto(
      backendId: serializer.fromJson<int>(json['backendId']),
      incidentId: serializer.fromJson<int>(json['incidentId']),
      url: serializer.fromJson<String>(json['url']),
      thumbnailUrl: serializer.fromJson<String?>(json['thumbnailUrl']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'backendId': serializer.toJson<int>(backendId),
      'incidentId': serializer.toJson<int>(incidentId),
      'url': serializer.toJson<String>(url),
      'thumbnailUrl': serializer.toJson<String?>(thumbnailUrl),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
    };
  }

  IncidentPhoto copyWith({
    int? backendId,
    int? incidentId,
    String? url,
    Value<String?> thumbnailUrl = const Value.absent(),
    Value<DateTime?> createdAt = const Value.absent(),
  }) => IncidentPhoto(
    backendId: backendId ?? this.backendId,
    incidentId: incidentId ?? this.incidentId,
    url: url ?? this.url,
    thumbnailUrl: thumbnailUrl.present ? thumbnailUrl.value : this.thumbnailUrl,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
  );
  IncidentPhoto copyWithCompanion(IncidentPhotosCompanion data) {
    return IncidentPhoto(
      backendId: data.backendId.present ? data.backendId.value : this.backendId,
      incidentId: data.incidentId.present
          ? data.incidentId.value
          : this.incidentId,
      url: data.url.present ? data.url.value : this.url,
      thumbnailUrl: data.thumbnailUrl.present
          ? data.thumbnailUrl.value
          : this.thumbnailUrl,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IncidentPhoto(')
          ..write('backendId: $backendId, ')
          ..write('incidentId: $incidentId, ')
          ..write('url: $url, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(backendId, incidentId, url, thumbnailUrl, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IncidentPhoto &&
          other.backendId == this.backendId &&
          other.incidentId == this.incidentId &&
          other.url == this.url &&
          other.thumbnailUrl == this.thumbnailUrl &&
          other.createdAt == this.createdAt);
}

class IncidentPhotosCompanion extends UpdateCompanion<IncidentPhoto> {
  final Value<int> backendId;
  final Value<int> incidentId;
  final Value<String> url;
  final Value<String?> thumbnailUrl;
  final Value<DateTime?> createdAt;
  const IncidentPhotosCompanion({
    this.backendId = const Value.absent(),
    this.incidentId = const Value.absent(),
    this.url = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  IncidentPhotosCompanion.insert({
    this.backendId = const Value.absent(),
    required int incidentId,
    required String url,
    this.thumbnailUrl = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : incidentId = Value(incidentId),
       url = Value(url);
  static Insertable<IncidentPhoto> custom({
    Expression<int>? backendId,
    Expression<int>? incidentId,
    Expression<String>? url,
    Expression<String>? thumbnailUrl,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (backendId != null) 'backend_id': backendId,
      if (incidentId != null) 'incident_id': incidentId,
      if (url != null) 'url': url,
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  IncidentPhotosCompanion copyWith({
    Value<int>? backendId,
    Value<int>? incidentId,
    Value<String>? url,
    Value<String?>? thumbnailUrl,
    Value<DateTime?>? createdAt,
  }) {
    return IncidentPhotosCompanion(
      backendId: backendId ?? this.backendId,
      incidentId: incidentId ?? this.incidentId,
      url: url ?? this.url,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (backendId.present) {
      map['backend_id'] = Variable<int>(backendId.value);
    }
    if (incidentId.present) {
      map['incident_id'] = Variable<int>(incidentId.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (thumbnailUrl.present) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IncidentPhotosCompanion(')
          ..write('backendId: $backendId, ')
          ..write('incidentId: $incidentId, ')
          ..write('url: $url, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $PendingChangesTable extends PendingChanges
    with TableInfo<$PendingChangesTable, PendingChange> {
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
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
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
    false,
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
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityType,
    entityId,
    actionType,
    payload,
    priority,
    retryCount,
    syncStatus,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_changes';
  @override
  VerificationContext validateIntegrity(
    Insertable<PendingChange> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    }
    if (data.containsKey('action_type')) {
      context.handle(
        _actionTypeMeta,
        actionType.isAcceptableOrUnknown(data['action_type']!, _actionTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_actionTypeMeta);
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
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PendingChange map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingChange(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}entity_id'],
      ),
      actionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action_type'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      ),
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PendingChangesTable createAlias(String alias) {
    return $PendingChangesTable(attachedDatabase, alias);
  }
}

class PendingChange extends DataClass implements Insertable<PendingChange> {
  final int id;
  final String entityType;
  final int? entityId;
  final String actionType;
  final String? payload;
  final int priority;
  final int retryCount;
  final String syncStatus;
  final DateTime createdAt;
  const PendingChange({
    required this.id,
    required this.entityType,
    this.entityId,
    required this.actionType,
    this.payload,
    required this.priority,
    required this.retryCount,
    required this.syncStatus,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entity_type'] = Variable<String>(entityType);
    if (!nullToAbsent || entityId != null) {
      map['entity_id'] = Variable<int>(entityId);
    }
    map['action_type'] = Variable<String>(actionType);
    if (!nullToAbsent || payload != null) {
      map['payload'] = Variable<String>(payload);
    }
    map['priority'] = Variable<int>(priority);
    map['retry_count'] = Variable<int>(retryCount);
    map['sync_status'] = Variable<String>(syncStatus);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PendingChangesCompanion toCompanion(bool nullToAbsent) {
    return PendingChangesCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityId: entityId == null && nullToAbsent
          ? const Value.absent()
          : Value(entityId),
      actionType: Value(actionType),
      payload: payload == null && nullToAbsent
          ? const Value.absent()
          : Value(payload),
      priority: Value(priority),
      retryCount: Value(retryCount),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
    );
  }

  factory PendingChange.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingChange(
      id: serializer.fromJson<int>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<int?>(json['entityId']),
      actionType: serializer.fromJson<String>(json['actionType']),
      payload: serializer.fromJson<String?>(json['payload']),
      priority: serializer.fromJson<int>(json['priority']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<int?>(entityId),
      'actionType': serializer.toJson<String>(actionType),
      'payload': serializer.toJson<String?>(payload),
      'priority': serializer.toJson<int>(priority),
      'retryCount': serializer.toJson<int>(retryCount),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PendingChange copyWith({
    int? id,
    String? entityType,
    Value<int?> entityId = const Value.absent(),
    String? actionType,
    Value<String?> payload = const Value.absent(),
    int? priority,
    int? retryCount,
    String? syncStatus,
    DateTime? createdAt,
  }) => PendingChange(
    id: id ?? this.id,
    entityType: entityType ?? this.entityType,
    entityId: entityId.present ? entityId.value : this.entityId,
    actionType: actionType ?? this.actionType,
    payload: payload.present ? payload.value : this.payload,
    priority: priority ?? this.priority,
    retryCount: retryCount ?? this.retryCount,
    syncStatus: syncStatus ?? this.syncStatus,
    createdAt: createdAt ?? this.createdAt,
  );
  PendingChange copyWithCompanion(PendingChangesCompanion data) {
    return PendingChange(
      id: data.id.present ? data.id.value : this.id,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      actionType: data.actionType.present
          ? data.actionType.value
          : this.actionType,
      payload: data.payload.present ? data.payload.value : this.payload,
      priority: data.priority.present ? data.priority.value : this.priority,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingChange(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('actionType: $actionType, ')
          ..write('payload: $payload, ')
          ..write('priority: $priority, ')
          ..write('retryCount: $retryCount, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entityType,
    entityId,
    actionType,
    payload,
    priority,
    retryCount,
    syncStatus,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingChange &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.actionType == this.actionType &&
          other.payload == this.payload &&
          other.priority == this.priority &&
          other.retryCount == this.retryCount &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt);
}

class PendingChangesCompanion extends UpdateCompanion<PendingChange> {
  final Value<int> id;
  final Value<String> entityType;
  final Value<int?> entityId;
  final Value<String> actionType;
  final Value<String?> payload;
  final Value<int> priority;
  final Value<int> retryCount;
  final Value<String> syncStatus;
  final Value<DateTime> createdAt;
  const PendingChangesCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.actionType = const Value.absent(),
    this.payload = const Value.absent(),
    this.priority = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PendingChangesCompanion.insert({
    this.id = const Value.absent(),
    required String entityType,
    this.entityId = const Value.absent(),
    required String actionType,
    this.payload = const Value.absent(),
    this.priority = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : entityType = Value(entityType),
       actionType = Value(actionType);
  static Insertable<PendingChange> custom({
    Expression<int>? id,
    Expression<String>? entityType,
    Expression<int>? entityId,
    Expression<String>? actionType,
    Expression<String>? payload,
    Expression<int>? priority,
    Expression<int>? retryCount,
    Expression<String>? syncStatus,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (actionType != null) 'action_type': actionType,
      if (payload != null) 'payload': payload,
      if (priority != null) 'priority': priority,
      if (retryCount != null) 'retry_count': retryCount,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PendingChangesCompanion copyWith({
    Value<int>? id,
    Value<String>? entityType,
    Value<int?>? entityId,
    Value<String>? actionType,
    Value<String?>? payload,
    Value<int>? priority,
    Value<int>? retryCount,
    Value<String>? syncStatus,
    Value<DateTime>? createdAt,
  }) {
    return PendingChangesCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      actionType: actionType ?? this.actionType,
      payload: payload ?? this.payload,
      priority: priority ?? this.priority,
      retryCount: retryCount ?? this.retryCount,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<int>(entityId.value);
    }
    if (actionType.present) {
      map['action_type'] = Variable<String>(actionType.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
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
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingChangesCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('actionType: $actionType, ')
          ..write('payload: $payload, ')
          ..write('priority: $priority, ')
          ..write('retryCount: $retryCount, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ActionLogsTable extends ActionLogs
    with TableInfo<$ActionLogsTable, ActionLog> {
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
    Insertable<ActionLog> instance, {
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
  ActionLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActionLog(
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

class ActionLog extends DataClass implements Insertable<ActionLog> {
  final String id;
  final int? actionIdRaw;
  final String? boilerHouseID;
  final String? locationID;
  final String message;
  final String? scope;
  final String? screen;
  final DateTime timestamp;
  final String type;
  final String? userId;
  final String? userName;
  const ActionLog({
    required this.id,
    this.actionIdRaw,
    this.boilerHouseID,
    this.locationID,
    required this.message,
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

  factory ActionLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActionLog(
      id: serializer.fromJson<String>(json['id']),
      actionIdRaw: serializer.fromJson<int?>(json['actionIdRaw']),
      boilerHouseID: serializer.fromJson<String?>(json['boilerHouseID']),
      locationID: serializer.fromJson<String?>(json['locationID']),
      message: serializer.fromJson<String>(json['message']),
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
      'scope': serializer.toJson<String?>(scope),
      'screen': serializer.toJson<String?>(screen),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'type': serializer.toJson<String>(type),
      'userId': serializer.toJson<String?>(userId),
      'userName': serializer.toJson<String?>(userName),
    };
  }

  ActionLog copyWith({
    String? id,
    Value<int?> actionIdRaw = const Value.absent(),
    Value<String?> boilerHouseID = const Value.absent(),
    Value<String?> locationID = const Value.absent(),
    String? message,
    Value<String?> scope = const Value.absent(),
    Value<String?> screen = const Value.absent(),
    DateTime? timestamp,
    String? type,
    Value<String?> userId = const Value.absent(),
    Value<String?> userName = const Value.absent(),
  }) => ActionLog(
    id: id ?? this.id,
    actionIdRaw: actionIdRaw.present ? actionIdRaw.value : this.actionIdRaw,
    boilerHouseID: boilerHouseID.present
        ? boilerHouseID.value
        : this.boilerHouseID,
    locationID: locationID.present ? locationID.value : this.locationID,
    message: message ?? this.message,
    scope: scope.present ? scope.value : this.scope,
    screen: screen.present ? screen.value : this.screen,
    timestamp: timestamp ?? this.timestamp,
    type: type ?? this.type,
    userId: userId.present ? userId.value : this.userId,
    userName: userName.present ? userName.value : this.userName,
  );
  ActionLog copyWithCompanion(ActionLogsCompanion data) {
    return ActionLog(
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
    return (StringBuffer('ActionLog(')
          ..write('id: $id, ')
          ..write('actionIdRaw: $actionIdRaw, ')
          ..write('boilerHouseID: $boilerHouseID, ')
          ..write('locationID: $locationID, ')
          ..write('message: $message, ')
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
      (other is ActionLog &&
          other.id == this.id &&
          other.actionIdRaw == this.actionIdRaw &&
          other.boilerHouseID == this.boilerHouseID &&
          other.locationID == this.locationID &&
          other.message == this.message &&
          other.scope == this.scope &&
          other.screen == this.screen &&
          other.timestamp == this.timestamp &&
          other.type == this.type &&
          other.userId == this.userId &&
          other.userName == this.userName);
}

class ActionLogsCompanion extends UpdateCompanion<ActionLog> {
  final Value<String> id;
  final Value<int?> actionIdRaw;
  final Value<String?> boilerHouseID;
  final Value<String?> locationID;
  final Value<String> message;
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
  static Insertable<ActionLog> custom({
    Expression<String>? id,
    Expression<int>? actionIdRaw,
    Expression<String>? boilerHouseID,
    Expression<String>? locationID,
    Expression<String>? message,
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

class $ManagementCompaniesTable extends ManagementCompanies
    with TableInfo<$ManagementCompaniesTable, ManagementCompany> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ManagementCompaniesTable(this.attachedDatabase, [this._alias]);
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
    id,
    name,
    address,
    director,
    email,
    phone,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'management_companies';
  @override
  VerificationContext validateIntegrity(
    Insertable<ManagementCompany> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
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
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
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
  ManagementCompany map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ManagementCompany(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      director: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}director'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
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

class ManagementCompany extends DataClass
    implements Insertable<ManagementCompany> {
  final String id;
  final String name;
  final String? address;
  final String? director;
  final String? email;
  final String? phone;
  const ManagementCompany({
    required this.id,
    required this.name,
    this.address,
    this.director,
    this.email,
    this.phone,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || director != null) {
      map['director'] = Variable<String>(director);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    return map;
  }

  ManagementCompaniesCompanion toCompanion(bool nullToAbsent) {
    return ManagementCompaniesCompanion(
      id: Value(id),
      name: Value(name),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      director: director == null && nullToAbsent
          ? const Value.absent()
          : Value(director),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
    );
  }

  factory ManagementCompany.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ManagementCompany(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      address: serializer.fromJson<String?>(json['address']),
      director: serializer.fromJson<String?>(json['director']),
      email: serializer.fromJson<String?>(json['email']),
      phone: serializer.fromJson<String?>(json['phone']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'address': serializer.toJson<String?>(address),
      'director': serializer.toJson<String?>(director),
      'email': serializer.toJson<String?>(email),
      'phone': serializer.toJson<String?>(phone),
    };
  }

  ManagementCompany copyWith({
    String? id,
    String? name,
    Value<String?> address = const Value.absent(),
    Value<String?> director = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> phone = const Value.absent(),
  }) => ManagementCompany(
    id: id ?? this.id,
    name: name ?? this.name,
    address: address.present ? address.value : this.address,
    director: director.present ? director.value : this.director,
    email: email.present ? email.value : this.email,
    phone: phone.present ? phone.value : this.phone,
  );
  ManagementCompany copyWithCompanion(ManagementCompaniesCompanion data) {
    return ManagementCompany(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      address: data.address.present ? data.address.value : this.address,
      director: data.director.present ? data.director.value : this.director,
      email: data.email.present ? data.email.value : this.email,
      phone: data.phone.present ? data.phone.value : this.phone,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ManagementCompany(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('address: $address, ')
          ..write('director: $director, ')
          ..write('email: $email, ')
          ..write('phone: $phone')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, address, director, email, phone);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ManagementCompany &&
          other.id == this.id &&
          other.name == this.name &&
          other.address == this.address &&
          other.director == this.director &&
          other.email == this.email &&
          other.phone == this.phone);
}

class ManagementCompaniesCompanion extends UpdateCompanion<ManagementCompany> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> address;
  final Value<String?> director;
  final Value<String?> email;
  final Value<String?> phone;
  final Value<int> rowid;
  const ManagementCompaniesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.address = const Value.absent(),
    this.director = const Value.absent(),
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ManagementCompaniesCompanion.insert({
    required String id,
    required String name,
    this.address = const Value.absent(),
    this.director = const Value.absent(),
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<ManagementCompany> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? address,
    Expression<String>? director,
    Expression<String>? email,
    Expression<String>? phone,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (address != null) 'address': address,
      if (director != null) 'director': director,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ManagementCompaniesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? address,
    Value<String?>? director,
    Value<String?>? email,
    Value<String?>? phone,
    Value<int>? rowid,
  }) {
    return ManagementCompaniesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      director: director ?? this.director,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (director.present) {
      map['director'] = Variable<String>(director.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
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
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('address: $address, ')
          ..write('director: $director, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AppUsersTable appUsers = $AppUsersTable(this);
  late final $BoilerHousesTable boilerHouses = $BoilerHousesTable(this);
  late final $SavedLocationsTable savedLocations = $SavedLocationsTable(this);
  late final $IncidentsTable incidents = $IncidentsTable(this);
  late final $AffectedHousesTable affectedHouses = $AffectedHousesTable(this);
  late final $IncidentPhotosTable incidentPhotos = $IncidentPhotosTable(this);
  late final $PendingChangesTable pendingChanges = $PendingChangesTable(this);
  late final $ActionLogsTable actionLogs = $ActionLogsTable(this);
  late final $ManagementCompaniesTable managementCompanies =
      $ManagementCompaniesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    appUsers,
    boilerHouses,
    savedLocations,
    incidents,
    affectedHouses,
    incidentPhotos,
    pendingChanges,
    actionLogs,
    managementCompanies,
  ];
}

typedef $$AppUsersTableCreateCompanionBuilder =
    AppUsersCompanion Function({
      required String userId,
      Value<String?> username,
      Value<String?> fullName,
      Value<String?> email,
      Value<String?> role,
      Value<bool> isActive,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });
typedef $$AppUsersTableUpdateCompanionBuilder =
    AppUsersCompanion Function({
      Value<String> userId,
      Value<String?> username,
      Value<String?> fullName,
      Value<String?> email,
      Value<String?> role,
      Value<bool> isActive,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
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
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
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
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
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
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppUsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppUsersTable,
          AppUser,
          $$AppUsersTableFilterComposer,
          $$AppUsersTableOrderingComposer,
          $$AppUsersTableAnnotationComposer,
          $$AppUsersTableCreateCompanionBuilder,
          $$AppUsersTableUpdateCompanionBuilder,
          (AppUser, BaseReferences<_$AppDatabase, $AppUsersTable, AppUser>),
          AppUser,
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
                Value<String> userId = const Value.absent(),
                Value<String?> username = const Value.absent(),
                Value<String?> fullName = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> role = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppUsersCompanion(
                userId: userId,
                username: username,
                fullName: fullName,
                email: email,
                role: role,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                Value<String?> username = const Value.absent(),
                Value<String?> fullName = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> role = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppUsersCompanion.insert(
                userId: userId,
                username: username,
                fullName: fullName,
                email: email,
                role: role,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
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
      AppUser,
      $$AppUsersTableFilterComposer,
      $$AppUsersTableOrderingComposer,
      $$AppUsersTableAnnotationComposer,
      $$AppUsersTableCreateCompanionBuilder,
      $$AppUsersTableUpdateCompanionBuilder,
      (AppUser, BaseReferences<_$AppDatabase, $AppUsersTable, AppUser>),
      AppUser,
      PrefetchHooks Function()
    >;
typedef $$BoilerHousesTableCreateCompanionBuilder =
    BoilerHousesCompanion Function({
      Value<int> backendId,
      Value<String?> boilerHouseUUID,
      Value<String?> name,
      Value<double> latitude,
      Value<double> longitude,
      Value<String?> siteNumber,
      Value<String?> siteManager,
      Value<DateTime?> updatedAt,
    });
typedef $$BoilerHousesTableUpdateCompanionBuilder =
    BoilerHousesCompanion Function({
      Value<int> backendId,
      Value<String?> boilerHouseUUID,
      Value<String?> name,
      Value<double> latitude,
      Value<double> longitude,
      Value<String?> siteNumber,
      Value<String?> siteManager,
      Value<DateTime?> updatedAt,
    });

final class $$BoilerHousesTableReferences
    extends BaseReferences<_$AppDatabase, $BoilerHousesTable, BoilerHouse> {
  $$BoilerHousesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SavedLocationsTable, List<SavedLocation>>
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

  static MultiTypedResultKey<$IncidentsTable, List<Incident>>
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
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

  ColumnFilters<String> get siteNumber => $composableBuilder(
    column: $table.siteNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get siteManager => $composableBuilder(
    column: $table.siteManager,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
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

  ColumnOrderings<String> get siteNumber => $composableBuilder(
    column: $table.siteNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get siteManager => $composableBuilder(
    column: $table.siteManager,
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

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get siteNumber => $composableBuilder(
    column: $table.siteNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get siteManager => $composableBuilder(
    column: $table.siteManager,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

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
          BoilerHouse,
          $$BoilerHousesTableFilterComposer,
          $$BoilerHousesTableOrderingComposer,
          $$BoilerHousesTableAnnotationComposer,
          $$BoilerHousesTableCreateCompanionBuilder,
          $$BoilerHousesTableUpdateCompanionBuilder,
          (BoilerHouse, $$BoilerHousesTableReferences),
          BoilerHouse,
          PrefetchHooks Function({bool savedLocationsRefs, bool incidentsRefs})
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
                Value<String?> name = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<String?> siteNumber = const Value.absent(),
                Value<String?> siteManager = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
              }) => BoilerHousesCompanion(
                backendId: backendId,
                boilerHouseUUID: boilerHouseUUID,
                name: name,
                latitude: latitude,
                longitude: longitude,
                siteNumber: siteNumber,
                siteManager: siteManager,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> backendId = const Value.absent(),
                Value<String?> boilerHouseUUID = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<String?> siteNumber = const Value.absent(),
                Value<String?> siteManager = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
              }) => BoilerHousesCompanion.insert(
                backendId: backendId,
                boilerHouseUUID: boilerHouseUUID,
                name: name,
                latitude: latitude,
                longitude: longitude,
                siteNumber: siteNumber,
                siteManager: siteManager,
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
              ({savedLocationsRefs = false, incidentsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (savedLocationsRefs) db.savedLocations,
                    if (incidentsRefs) db.incidents,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (savedLocationsRefs)
                        await $_getPrefetchedData<
                          BoilerHouse,
                          $BoilerHousesTable,
                          SavedLocation
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
                          BoilerHouse,
                          $BoilerHousesTable,
                          Incident
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
      BoilerHouse,
      $$BoilerHousesTableFilterComposer,
      $$BoilerHousesTableOrderingComposer,
      $$BoilerHousesTableAnnotationComposer,
      $$BoilerHousesTableCreateCompanionBuilder,
      $$BoilerHousesTableUpdateCompanionBuilder,
      (BoilerHouse, $$BoilerHousesTableReferences),
      BoilerHouse,
      PrefetchHooks Function({bool savedLocationsRefs, bool incidentsRefs})
    >;
typedef $$SavedLocationsTableCreateCompanionBuilder =
    SavedLocationsCompanion Function({
      Value<int> backendId,
      Value<String?> locationUUID,
      Value<String?> name,
      Value<double> latitude,
      Value<double> longitude,
      Value<String?> managementCompanyId,
      Value<int?> boilerHouseId,
      Value<int?> floors,
      Value<int?> residentsCount,
      Value<int?> rooms,
      Value<double?> totalArea,
      Value<int?> yearBuilt,
      Value<String?> fiasHouseGuid,
      Value<String?> fiasAOGuid,
      Value<bool> providesHeating,
      Value<bool> providesHotWater,
      Value<bool> isStub,
      Value<DateTime?> updatedAt,
    });
typedef $$SavedLocationsTableUpdateCompanionBuilder =
    SavedLocationsCompanion Function({
      Value<int> backendId,
      Value<String?> locationUUID,
      Value<String?> name,
      Value<double> latitude,
      Value<double> longitude,
      Value<String?> managementCompanyId,
      Value<int?> boilerHouseId,
      Value<int?> floors,
      Value<int?> residentsCount,
      Value<int?> rooms,
      Value<double?> totalArea,
      Value<int?> yearBuilt,
      Value<String?> fiasHouseGuid,
      Value<String?> fiasAOGuid,
      Value<bool> providesHeating,
      Value<bool> providesHotWater,
      Value<bool> isStub,
      Value<DateTime?> updatedAt,
    });

final class $$SavedLocationsTableReferences
    extends BaseReferences<_$AppDatabase, $SavedLocationsTable, SavedLocation> {
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

  static MultiTypedResultKey<$AffectedHousesTable, List<AffectedHouse>>
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
            $_itemColumn<int>('backend_id')!,
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
  ColumnFilters<int> get backendId => $composableBuilder(
    column: $table.backendId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locationUUID => $composableBuilder(
    column: $table.locationUUID,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
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

  ColumnFilters<String> get managementCompanyId => $composableBuilder(
    column: $table.managementCompanyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get floors => $composableBuilder(
    column: $table.floors,
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

  ColumnFilters<int> get yearBuilt => $composableBuilder(
    column: $table.yearBuilt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fiasHouseGuid => $composableBuilder(
    column: $table.fiasHouseGuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fiasAOGuid => $composableBuilder(
    column: $table.fiasAOGuid,
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

  ColumnFilters<bool> get isStub => $composableBuilder(
    column: $table.isStub,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
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
  ColumnOrderings<int> get backendId => $composableBuilder(
    column: $table.backendId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locationUUID => $composableBuilder(
    column: $table.locationUUID,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
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

  ColumnOrderings<String> get managementCompanyId => $composableBuilder(
    column: $table.managementCompanyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get floors => $composableBuilder(
    column: $table.floors,
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

  ColumnOrderings<int> get yearBuilt => $composableBuilder(
    column: $table.yearBuilt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fiasHouseGuid => $composableBuilder(
    column: $table.fiasHouseGuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fiasAOGuid => $composableBuilder(
    column: $table.fiasAOGuid,
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

  ColumnOrderings<bool> get isStub => $composableBuilder(
    column: $table.isStub,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
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

class $$SavedLocationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SavedLocationsTable> {
  $$SavedLocationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get backendId =>
      $composableBuilder(column: $table.backendId, builder: (column) => column);

  GeneratedColumn<String> get locationUUID => $composableBuilder(
    column: $table.locationUUID,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get managementCompanyId => $composableBuilder(
    column: $table.managementCompanyId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get floors =>
      $composableBuilder(column: $table.floors, builder: (column) => column);

  GeneratedColumn<int> get residentsCount => $composableBuilder(
    column: $table.residentsCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rooms =>
      $composableBuilder(column: $table.rooms, builder: (column) => column);

  GeneratedColumn<double> get totalArea =>
      $composableBuilder(column: $table.totalArea, builder: (column) => column);

  GeneratedColumn<int> get yearBuilt =>
      $composableBuilder(column: $table.yearBuilt, builder: (column) => column);

  GeneratedColumn<String> get fiasHouseGuid => $composableBuilder(
    column: $table.fiasHouseGuid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fiasAOGuid => $composableBuilder(
    column: $table.fiasAOGuid,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get providesHeating => $composableBuilder(
    column: $table.providesHeating,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get providesHotWater => $composableBuilder(
    column: $table.providesHotWater,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isStub =>
      $composableBuilder(column: $table.isStub, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

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
          SavedLocation,
          $$SavedLocationsTableFilterComposer,
          $$SavedLocationsTableOrderingComposer,
          $$SavedLocationsTableAnnotationComposer,
          $$SavedLocationsTableCreateCompanionBuilder,
          $$SavedLocationsTableUpdateCompanionBuilder,
          (SavedLocation, $$SavedLocationsTableReferences),
          SavedLocation,
          PrefetchHooks Function({bool boilerHouseId, bool affectedHousesRefs})
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
                Value<int> backendId = const Value.absent(),
                Value<String?> locationUUID = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<String?> managementCompanyId = const Value.absent(),
                Value<int?> boilerHouseId = const Value.absent(),
                Value<int?> floors = const Value.absent(),
                Value<int?> residentsCount = const Value.absent(),
                Value<int?> rooms = const Value.absent(),
                Value<double?> totalArea = const Value.absent(),
                Value<int?> yearBuilt = const Value.absent(),
                Value<String?> fiasHouseGuid = const Value.absent(),
                Value<String?> fiasAOGuid = const Value.absent(),
                Value<bool> providesHeating = const Value.absent(),
                Value<bool> providesHotWater = const Value.absent(),
                Value<bool> isStub = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
              }) => SavedLocationsCompanion(
                backendId: backendId,
                locationUUID: locationUUID,
                name: name,
                latitude: latitude,
                longitude: longitude,
                managementCompanyId: managementCompanyId,
                boilerHouseId: boilerHouseId,
                floors: floors,
                residentsCount: residentsCount,
                rooms: rooms,
                totalArea: totalArea,
                yearBuilt: yearBuilt,
                fiasHouseGuid: fiasHouseGuid,
                fiasAOGuid: fiasAOGuid,
                providesHeating: providesHeating,
                providesHotWater: providesHotWater,
                isStub: isStub,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> backendId = const Value.absent(),
                Value<String?> locationUUID = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<String?> managementCompanyId = const Value.absent(),
                Value<int?> boilerHouseId = const Value.absent(),
                Value<int?> floors = const Value.absent(),
                Value<int?> residentsCount = const Value.absent(),
                Value<int?> rooms = const Value.absent(),
                Value<double?> totalArea = const Value.absent(),
                Value<int?> yearBuilt = const Value.absent(),
                Value<String?> fiasHouseGuid = const Value.absent(),
                Value<String?> fiasAOGuid = const Value.absent(),
                Value<bool> providesHeating = const Value.absent(),
                Value<bool> providesHotWater = const Value.absent(),
                Value<bool> isStub = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
              }) => SavedLocationsCompanion.insert(
                backendId: backendId,
                locationUUID: locationUUID,
                name: name,
                latitude: latitude,
                longitude: longitude,
                managementCompanyId: managementCompanyId,
                boilerHouseId: boilerHouseId,
                floors: floors,
                residentsCount: residentsCount,
                rooms: rooms,
                totalArea: totalArea,
                yearBuilt: yearBuilt,
                fiasHouseGuid: fiasHouseGuid,
                fiasAOGuid: fiasAOGuid,
                providesHeating: providesHeating,
                providesHotWater: providesHotWater,
                isStub: isStub,
                updatedAt: updatedAt,
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
              ({boilerHouseId = false, affectedHousesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
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

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (affectedHousesRefs)
                        await $_getPrefetchedData<
                          SavedLocation,
                          $SavedLocationsTable,
                          AffectedHouse
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
      SavedLocation,
      $$SavedLocationsTableFilterComposer,
      $$SavedLocationsTableOrderingComposer,
      $$SavedLocationsTableAnnotationComposer,
      $$SavedLocationsTableCreateCompanionBuilder,
      $$SavedLocationsTableUpdateCompanionBuilder,
      (SavedLocation, $$SavedLocationsTableReferences),
      SavedLocation,
      PrefetchHooks Function({bool boilerHouseId, bool affectedHousesRefs})
    >;
typedef $$IncidentsTableCreateCompanionBuilder =
    IncidentsCompanion Function({
      Value<int> backendId,
      Value<String?> incidentUUID,
      Value<int?> boilerHouseId,
      Value<String?> title,
      Value<String?> description,
      Value<IncidentStatus?> status,
      Value<int> severity,
      Value<bool> resourceHotWaterStopped,
      Value<bool> resourceHeatingStopped,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<DateTime?> resolvedAt,
      Value<int?> reportedBy,
      Value<int?> assignedTo,
      Value<String?> notificationConfigType,
      Value<String?> notificationConfigRoleIds,
      Value<String?> notificationConfigUserIds,
    });
typedef $$IncidentsTableUpdateCompanionBuilder =
    IncidentsCompanion Function({
      Value<int> backendId,
      Value<String?> incidentUUID,
      Value<int?> boilerHouseId,
      Value<String?> title,
      Value<String?> description,
      Value<IncidentStatus?> status,
      Value<int> severity,
      Value<bool> resourceHotWaterStopped,
      Value<bool> resourceHeatingStopped,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<DateTime?> resolvedAt,
      Value<int?> reportedBy,
      Value<int?> assignedTo,
      Value<String?> notificationConfigType,
      Value<String?> notificationConfigRoleIds,
      Value<String?> notificationConfigUserIds,
    });

final class $$IncidentsTableReferences
    extends BaseReferences<_$AppDatabase, $IncidentsTable, Incident> {
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

  static MultiTypedResultKey<$AffectedHousesTable, List<AffectedHouse>>
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

  static MultiTypedResultKey<$IncidentPhotosTable, List<IncidentPhoto>>
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

  ColumnFilters<String> get incidentUUID => $composableBuilder(
    column: $table.incidentUUID,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<IncidentStatus?, IncidentStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get resourceHotWaterStopped => $composableBuilder(
    column: $table.resourceHotWaterStopped,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get resourceHeatingStopped => $composableBuilder(
    column: $table.resourceHeatingStopped,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reportedBy => $composableBuilder(
    column: $table.reportedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get assignedTo => $composableBuilder(
    column: $table.assignedTo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notificationConfigType => $composableBuilder(
    column: $table.notificationConfigType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notificationConfigRoleIds => $composableBuilder(
    column: $table.notificationConfigRoleIds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notificationConfigUserIds => $composableBuilder(
    column: $table.notificationConfigUserIds,
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

  ColumnOrderings<String> get incidentUUID => $composableBuilder(
    column: $table.incidentUUID,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get resourceHotWaterStopped => $composableBuilder(
    column: $table.resourceHotWaterStopped,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get resourceHeatingStopped => $composableBuilder(
    column: $table.resourceHeatingStopped,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reportedBy => $composableBuilder(
    column: $table.reportedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get assignedTo => $composableBuilder(
    column: $table.assignedTo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notificationConfigType => $composableBuilder(
    column: $table.notificationConfigType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notificationConfigRoleIds => $composableBuilder(
    column: $table.notificationConfigRoleIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notificationConfigUserIds => $composableBuilder(
    column: $table.notificationConfigUserIds,
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

  GeneratedColumn<String> get incidentUUID => $composableBuilder(
    column: $table.incidentUUID,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<IncidentStatus?, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get severity =>
      $composableBuilder(column: $table.severity, builder: (column) => column);

  GeneratedColumn<bool> get resourceHotWaterStopped => $composableBuilder(
    column: $table.resourceHotWaterStopped,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get resourceHeatingStopped => $composableBuilder(
    column: $table.resourceHeatingStopped,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reportedBy => $composableBuilder(
    column: $table.reportedBy,
    builder: (column) => column,
  );

  GeneratedColumn<int> get assignedTo => $composableBuilder(
    column: $table.assignedTo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notificationConfigType => $composableBuilder(
    column: $table.notificationConfigType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notificationConfigRoleIds => $composableBuilder(
    column: $table.notificationConfigRoleIds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notificationConfigUserIds => $composableBuilder(
    column: $table.notificationConfigUserIds,
    builder: (column) => column,
  );

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
          Incident,
          $$IncidentsTableFilterComposer,
          $$IncidentsTableOrderingComposer,
          $$IncidentsTableAnnotationComposer,
          $$IncidentsTableCreateCompanionBuilder,
          $$IncidentsTableUpdateCompanionBuilder,
          (Incident, $$IncidentsTableReferences),
          Incident,
          PrefetchHooks Function({
            bool boilerHouseId,
            bool affectedHousesRefs,
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
                Value<String?> incidentUUID = const Value.absent(),
                Value<int?> boilerHouseId = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<IncidentStatus?> status = const Value.absent(),
                Value<int> severity = const Value.absent(),
                Value<bool> resourceHotWaterStopped = const Value.absent(),
                Value<bool> resourceHeatingStopped = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> resolvedAt = const Value.absent(),
                Value<int?> reportedBy = const Value.absent(),
                Value<int?> assignedTo = const Value.absent(),
                Value<String?> notificationConfigType = const Value.absent(),
                Value<String?> notificationConfigRoleIds = const Value.absent(),
                Value<String?> notificationConfigUserIds = const Value.absent(),
              }) => IncidentsCompanion(
                backendId: backendId,
                incidentUUID: incidentUUID,
                boilerHouseId: boilerHouseId,
                title: title,
                description: description,
                status: status,
                severity: severity,
                resourceHotWaterStopped: resourceHotWaterStopped,
                resourceHeatingStopped: resourceHeatingStopped,
                createdAt: createdAt,
                updatedAt: updatedAt,
                resolvedAt: resolvedAt,
                reportedBy: reportedBy,
                assignedTo: assignedTo,
                notificationConfigType: notificationConfigType,
                notificationConfigRoleIds: notificationConfigRoleIds,
                notificationConfigUserIds: notificationConfigUserIds,
              ),
          createCompanionCallback:
              ({
                Value<int> backendId = const Value.absent(),
                Value<String?> incidentUUID = const Value.absent(),
                Value<int?> boilerHouseId = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<IncidentStatus?> status = const Value.absent(),
                Value<int> severity = const Value.absent(),
                Value<bool> resourceHotWaterStopped = const Value.absent(),
                Value<bool> resourceHeatingStopped = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> resolvedAt = const Value.absent(),
                Value<int?> reportedBy = const Value.absent(),
                Value<int?> assignedTo = const Value.absent(),
                Value<String?> notificationConfigType = const Value.absent(),
                Value<String?> notificationConfigRoleIds = const Value.absent(),
                Value<String?> notificationConfigUserIds = const Value.absent(),
              }) => IncidentsCompanion.insert(
                backendId: backendId,
                incidentUUID: incidentUUID,
                boilerHouseId: boilerHouseId,
                title: title,
                description: description,
                status: status,
                severity: severity,
                resourceHotWaterStopped: resourceHotWaterStopped,
                resourceHeatingStopped: resourceHeatingStopped,
                createdAt: createdAt,
                updatedAt: updatedAt,
                resolvedAt: resolvedAt,
                reportedBy: reportedBy,
                assignedTo: assignedTo,
                notificationConfigType: notificationConfigType,
                notificationConfigRoleIds: notificationConfigRoleIds,
                notificationConfigUserIds: notificationConfigUserIds,
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
                incidentPhotosRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (affectedHousesRefs) db.affectedHouses,
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
                          Incident,
                          $IncidentsTable,
                          AffectedHouse
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
                      if (incidentPhotosRefs)
                        await $_getPrefetchedData<
                          Incident,
                          $IncidentsTable,
                          IncidentPhoto
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
      Incident,
      $$IncidentsTableFilterComposer,
      $$IncidentsTableOrderingComposer,
      $$IncidentsTableAnnotationComposer,
      $$IncidentsTableCreateCompanionBuilder,
      $$IncidentsTableUpdateCompanionBuilder,
      (Incident, $$IncidentsTableReferences),
      Incident,
      PrefetchHooks Function({
        bool boilerHouseId,
        bool affectedHousesRefs,
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
    extends BaseReferences<_$AppDatabase, $AffectedHousesTable, AffectedHouse> {
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
          AffectedHouse,
          $$AffectedHousesTableFilterComposer,
          $$AffectedHousesTableOrderingComposer,
          $$AffectedHousesTableAnnotationComposer,
          $$AffectedHousesTableCreateCompanionBuilder,
          $$AffectedHousesTableUpdateCompanionBuilder,
          (AffectedHouse, $$AffectedHousesTableReferences),
          AffectedHouse,
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
      AffectedHouse,
      $$AffectedHousesTableFilterComposer,
      $$AffectedHousesTableOrderingComposer,
      $$AffectedHousesTableAnnotationComposer,
      $$AffectedHousesTableCreateCompanionBuilder,
      $$AffectedHousesTableUpdateCompanionBuilder,
      (AffectedHouse, $$AffectedHousesTableReferences),
      AffectedHouse,
      PrefetchHooks Function({bool incidentId, bool savedLocationId})
    >;
typedef $$IncidentPhotosTableCreateCompanionBuilder =
    IncidentPhotosCompanion Function({
      Value<int> backendId,
      required int incidentId,
      required String url,
      Value<String?> thumbnailUrl,
      Value<DateTime?> createdAt,
    });
typedef $$IncidentPhotosTableUpdateCompanionBuilder =
    IncidentPhotosCompanion Function({
      Value<int> backendId,
      Value<int> incidentId,
      Value<String> url,
      Value<String?> thumbnailUrl,
      Value<DateTime?> createdAt,
    });

final class $$IncidentPhotosTableReferences
    extends BaseReferences<_$AppDatabase, $IncidentPhotosTable, IncidentPhoto> {
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

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
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

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
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

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

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
          IncidentPhoto,
          $$IncidentPhotosTableFilterComposer,
          $$IncidentPhotosTableOrderingComposer,
          $$IncidentPhotosTableAnnotationComposer,
          $$IncidentPhotosTableCreateCompanionBuilder,
          $$IncidentPhotosTableUpdateCompanionBuilder,
          (IncidentPhoto, $$IncidentPhotosTableReferences),
          IncidentPhoto,
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
                Value<int> incidentId = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String?> thumbnailUrl = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
              }) => IncidentPhotosCompanion(
                backendId: backendId,
                incidentId: incidentId,
                url: url,
                thumbnailUrl: thumbnailUrl,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> backendId = const Value.absent(),
                required int incidentId,
                required String url,
                Value<String?> thumbnailUrl = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
              }) => IncidentPhotosCompanion.insert(
                backendId: backendId,
                incidentId: incidentId,
                url: url,
                thumbnailUrl: thumbnailUrl,
                createdAt: createdAt,
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
      IncidentPhoto,
      $$IncidentPhotosTableFilterComposer,
      $$IncidentPhotosTableOrderingComposer,
      $$IncidentPhotosTableAnnotationComposer,
      $$IncidentPhotosTableCreateCompanionBuilder,
      $$IncidentPhotosTableUpdateCompanionBuilder,
      (IncidentPhoto, $$IncidentPhotosTableReferences),
      IncidentPhoto,
      PrefetchHooks Function({bool incidentId})
    >;
typedef $$PendingChangesTableCreateCompanionBuilder =
    PendingChangesCompanion Function({
      Value<int> id,
      required String entityType,
      Value<int?> entityId,
      required String actionType,
      Value<String?> payload,
      Value<int> priority,
      Value<int> retryCount,
      Value<String> syncStatus,
      Value<DateTime> createdAt,
    });
typedef $$PendingChangesTableUpdateCompanionBuilder =
    PendingChangesCompanion Function({
      Value<int> id,
      Value<String> entityType,
      Value<int?> entityId,
      Value<String> actionType,
      Value<String?> payload,
      Value<int> priority,
      Value<int> retryCount,
      Value<String> syncStatus,
      Value<DateTime> createdAt,
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

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actionType => $composableBuilder(
    column: $table.actionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
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

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actionType => $composableBuilder(
    column: $table.actionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
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

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get actionType => $composableBuilder(
    column: $table.actionType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payload =>
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

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PendingChangesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PendingChangesTable,
          PendingChange,
          $$PendingChangesTableFilterComposer,
          $$PendingChangesTableOrderingComposer,
          $$PendingChangesTableAnnotationComposer,
          $$PendingChangesTableCreateCompanionBuilder,
          $$PendingChangesTableUpdateCompanionBuilder,
          (
            PendingChange,
            BaseReferences<_$AppDatabase, $PendingChangesTable, PendingChange>,
          ),
          PendingChange,
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
                Value<String> entityType = const Value.absent(),
                Value<int?> entityId = const Value.absent(),
                Value<String> actionType = const Value.absent(),
                Value<String?> payload = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PendingChangesCompanion(
                id: id,
                entityType: entityType,
                entityId: entityId,
                actionType: actionType,
                payload: payload,
                priority: priority,
                retryCount: retryCount,
                syncStatus: syncStatus,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String entityType,
                Value<int?> entityId = const Value.absent(),
                required String actionType,
                Value<String?> payload = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PendingChangesCompanion.insert(
                id: id,
                entityType: entityType,
                entityId: entityId,
                actionType: actionType,
                payload: payload,
                priority: priority,
                retryCount: retryCount,
                syncStatus: syncStatus,
                createdAt: createdAt,
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
      PendingChange,
      $$PendingChangesTableFilterComposer,
      $$PendingChangesTableOrderingComposer,
      $$PendingChangesTableAnnotationComposer,
      $$PendingChangesTableCreateCompanionBuilder,
      $$PendingChangesTableUpdateCompanionBuilder,
      (
        PendingChange,
        BaseReferences<_$AppDatabase, $PendingChangesTable, PendingChange>,
      ),
      PendingChange,
      PrefetchHooks Function()
    >;
typedef $$ActionLogsTableCreateCompanionBuilder =
    ActionLogsCompanion Function({
      required String id,
      Value<int?> actionIdRaw,
      Value<String?> boilerHouseID,
      Value<String?> locationID,
      required String message,
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
          ActionLog,
          $$ActionLogsTableFilterComposer,
          $$ActionLogsTableOrderingComposer,
          $$ActionLogsTableAnnotationComposer,
          $$ActionLogsTableCreateCompanionBuilder,
          $$ActionLogsTableUpdateCompanionBuilder,
          (
            ActionLog,
            BaseReferences<_$AppDatabase, $ActionLogsTable, ActionLog>,
          ),
          ActionLog,
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
      ActionLog,
      $$ActionLogsTableFilterComposer,
      $$ActionLogsTableOrderingComposer,
      $$ActionLogsTableAnnotationComposer,
      $$ActionLogsTableCreateCompanionBuilder,
      $$ActionLogsTableUpdateCompanionBuilder,
      (ActionLog, BaseReferences<_$AppDatabase, $ActionLogsTable, ActionLog>),
      ActionLog,
      PrefetchHooks Function()
    >;
typedef $$ManagementCompaniesTableCreateCompanionBuilder =
    ManagementCompaniesCompanion Function({
      required String id,
      required String name,
      Value<String?> address,
      Value<String?> director,
      Value<String?> email,
      Value<String?> phone,
      Value<int> rowid,
    });
typedef $$ManagementCompaniesTableUpdateCompanionBuilder =
    ManagementCompaniesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> address,
      Value<String?> director,
      Value<String?> email,
      Value<String?> phone,
      Value<int> rowid,
    });

class $$ManagementCompaniesTableFilterComposer
    extends Composer<_$AppDatabase, $ManagementCompaniesTable> {
  $$ManagementCompaniesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
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

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );
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
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
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
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get director =>
      $composableBuilder(column: $table.director, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);
}

class $$ManagementCompaniesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ManagementCompaniesTable,
          ManagementCompany,
          $$ManagementCompaniesTableFilterComposer,
          $$ManagementCompaniesTableOrderingComposer,
          $$ManagementCompaniesTableAnnotationComposer,
          $$ManagementCompaniesTableCreateCompanionBuilder,
          $$ManagementCompaniesTableUpdateCompanionBuilder,
          (
            ManagementCompany,
            BaseReferences<
              _$AppDatabase,
              $ManagementCompaniesTable,
              ManagementCompany
            >,
          ),
          ManagementCompany,
          PrefetchHooks Function()
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
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> director = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ManagementCompaniesCompanion(
                id: id,
                name: name,
                address: address,
                director: director,
                email: email,
                phone: phone,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> address = const Value.absent(),
                Value<String?> director = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ManagementCompaniesCompanion.insert(
                id: id,
                name: name,
                address: address,
                director: director,
                email: email,
                phone: phone,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ManagementCompaniesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ManagementCompaniesTable,
      ManagementCompany,
      $$ManagementCompaniesTableFilterComposer,
      $$ManagementCompaniesTableOrderingComposer,
      $$ManagementCompaniesTableAnnotationComposer,
      $$ManagementCompaniesTableCreateCompanionBuilder,
      $$ManagementCompaniesTableUpdateCompanionBuilder,
      (
        ManagementCompany,
        BaseReferences<
          _$AppDatabase,
          $ManagementCompaniesTable,
          ManagementCompany
        >,
      ),
      ManagementCompany,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AppUsersTableTableManager get appUsers =>
      $$AppUsersTableTableManager(_db, _db.appUsers);
  $$BoilerHousesTableTableManager get boilerHouses =>
      $$BoilerHousesTableTableManager(_db, _db.boilerHouses);
  $$SavedLocationsTableTableManager get savedLocations =>
      $$SavedLocationsTableTableManager(_db, _db.savedLocations);
  $$IncidentsTableTableManager get incidents =>
      $$IncidentsTableTableManager(_db, _db.incidents);
  $$AffectedHousesTableTableManager get affectedHouses =>
      $$AffectedHousesTableTableManager(_db, _db.affectedHouses);
  $$IncidentPhotosTableTableManager get incidentPhotos =>
      $$IncidentPhotosTableTableManager(_db, _db.incidentPhotos);
  $$PendingChangesTableTableManager get pendingChanges =>
      $$PendingChangesTableTableManager(_db, _db.pendingChanges);
  $$ActionLogsTableTableManager get actionLogs =>
      $$ActionLogsTableTableManager(_db, _db.actionLogs);
  $$ManagementCompaniesTableTableManager get managementCompanies =>
      $$ManagementCompaniesTableTableManager(_db, _db.managementCompanies);
}
