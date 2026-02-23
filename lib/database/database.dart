import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../models/incident_models.dart';

part 'database.g.dart';

// Tables

class AppUsers extends Table {
  TextColumn get userId => text()();
  TextColumn get username => text().nullable()();
  TextColumn get fullName => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get role => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {userId};
}

class BoilerHouses extends Table {
  IntColumn get backendId => integer()();
  TextColumn get boilerHouseUUID => text().nullable()();
  TextColumn get name => text().nullable()();
  RealColumn get latitude => real().withDefault(const Constant(0.0))();
  RealColumn get longitude => real().withDefault(const Constant(0.0))();
  TextColumn get siteNumber => text().nullable()();
  TextColumn get siteManager => text().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {backendId};
}

class SavedLocations extends Table {
  IntColumn get backendId => integer()();
  TextColumn get locationUUID => text().nullable()();
  TextColumn get name => text().nullable()();
  RealColumn get latitude => real().withDefault(const Constant(0.0))();
  RealColumn get longitude => real().withDefault(const Constant(0.0))();
  TextColumn get managementCompanyId => text().nullable()();
  IntColumn get boilerHouseId => integer().nullable().references(BoilerHouses, #backendId)();
  IntColumn get floors => integer().nullable()();
  IntColumn get residentsCount => integer().nullable()();
  IntColumn get rooms => integer().nullable()();
  RealColumn get totalArea => real().nullable()();
  IntColumn get yearBuilt => integer().nullable()();
  TextColumn get fiasHouseGuid => text().nullable()();
  TextColumn get fiasAOGuid => text().nullable()();
  BoolColumn get providesHeating => boolean().withDefault(const Constant(false))();
  BoolColumn get providesHotWater => boolean().withDefault(const Constant(false))();
  BoolColumn get isStub => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {backendId};
}

class Incidents extends Table {
  IntColumn get backendId => integer()();
  TextColumn get incidentUUID => text().nullable()();
  IntColumn get boilerHouseId => integer().nullable().references(BoilerHouses, #backendId)();
  TextColumn get title => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get status => text().map(const IncidentStatusConverter()).nullable()();
  IntColumn get severity => integer().withDefault(const Constant(1))();
  BoolColumn get resourceHotWaterStopped => boolean().withDefault(const Constant(false))();
  BoolColumn get resourceHeatingStopped => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get resolvedAt => dateTime().nullable()();
  IntColumn get reportedBy => integer().nullable()();
  IntColumn get assignedTo => integer().nullable()();
  
  // Notification Config
  TextColumn get notificationConfigType => text().nullable()();
  TextColumn get notificationConfigRoleIds => text().nullable()();
  TextColumn get notificationConfigUserIds => text().nullable()();
  
  @override
  Set<Column> get primaryKey => {backendId};
}

class AffectedHouses extends Table {
  IntColumn get incidentId => integer().references(Incidents, #backendId)();
  IntColumn get savedLocationId => integer().references(SavedLocations, #backendId)();

  @override
  Set<Column> get primaryKey => {incidentId, savedLocationId};
}

class IncidentComments extends Table {
  IntColumn get backendId => integer()();
  IntColumn get incidentId => integer().references(Incidents, #backendId)();
  TextColumn get text => text()();
  IntColumn get userId => integer()();
  TextColumn get userName => text().nullable()();
  BoolColumn get isSystemMessage => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {backendId};
}

class IncidentPhotos extends Table {
  IntColumn get backendId => integer()();
  IntColumn get incidentId => integer().references(Incidents, #backendId)();
  TextColumn get url => text()();
  TextColumn get thumbnailUrl => text().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {backendId};
}

class PendingChanges extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityType => text()();
  IntColumn get entityId => integer().nullable()();
  TextColumn get actionType => text()();
  TextColumn get payload => text().nullable()(); // JSON string
  IntColumn get priority => integer().withDefault(const Constant(1))();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class ActionLogs extends Table {
  TextColumn get id => text()(); // UUID
  IntColumn get actionIdRaw => integer().nullable()();
  TextColumn get boilerHouseID => text().nullable()();
  TextColumn get locationID => text().nullable()();
  TextColumn get message => text()();
  TextColumn get scope => text().nullable()();
  TextColumn get screen => text().nullable()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get type => text()();
  TextColumn get userId => text().nullable()();
  TextColumn get userName => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class ManagementCompanies extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get name => text()();
  TextColumn get address => text().nullable()();
  TextColumn get director => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get phone => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// Converters

class IncidentStatusConverter extends TypeConverter<IncidentStatus, String> {
  const IncidentStatusConverter();

  @override
  IncidentStatus fromSql(String fromDb) {
    return IncidentStatus.fromAny(fromDb);
  }

  @override
  String toSql(IncidentStatus value) {
    return value.name;
  }
}

@DriftDatabase(tables: [
  AppUsers,
  BoilerHouses,
  SavedLocations,
  Incidents,
  AffectedHouses,
  IncidentComments,
  IncidentPhotos,
  PendingChanges,
  ActionLogs,
  ManagementCompanies,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}
