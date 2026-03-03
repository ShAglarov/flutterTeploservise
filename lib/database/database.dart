import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

// ----------------------------------------------------------------------
// Exact 1-to-1 Mapping of iOS Swift CoreData Entities
// ----------------------------------------------------------------------

@DataClassName('ActionLogDb')
class ActionLogs extends Table {
  TextColumn get id => text()(); // UUID attributeType="UUID"
  IntColumn get actionIdRaw => integer().nullable()();
  TextColumn get boilerHouseID => text().nullable()();
  TextColumn get locationID => text().nullable()();
  TextColumn get message => text()();
  BlobColumn get metadata => blob().nullable()();
  TextColumn get scope => text().nullable()();
  TextColumn get screen => text().nullable()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get type => text()();
  TextColumn get userId => text().nullable()();
  TextColumn get userName => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('AppUserDb')
class AppUsers extends Table {
  TextColumn get activeStatus => text().nullable()();
  DateTimeColumn get blockedAt => dateTime().nullable()();
  TextColumn get blockedBy => text().nullable()();
  TextColumn get blockedReason => text().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  TextColumn get createdBy => text().nullable()();
  // using Text for Transformable (JSON string representation of NSDictionary)
  TextColumn get customPermissions => text().nullable()(); 
  DateTimeColumn get deactivatedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get deletedBy => text().nullable()();
  TextColumn get displayName => text().nullable()();
  BoolColumn get emailVerified => boolean().withDefault(const Constant(false))();
  TextColumn get fullName => text().nullable()();
  DateTimeColumn get inviteSentAt => dateTime().nullable()();
  TextColumn get inviteToken => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  BoolColumn get isAdmin => boolean().withDefault(const Constant(false))();
  BoolColumn get isBlocked => boolean().withDefault(const Constant(false))();
  BoolColumn get isInvitePending => boolean().withDefault(const Constant(false))();
  BoolColumn get isOnline => boolean().withDefault(const Constant(false))();
  BoolColumn get isSoftDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isSystem => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastActiveAt => dateTime().nullable()();
  DateTimeColumn get lastLoginAt => dateTime().nullable()();
  DateTimeColumn get lastPasswordResetAt => dateTime().nullable()();
  BlobColumn get metadata => blob().nullable()();
  BoolColumn get needsPasswordReset => boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();
  TextColumn get passwordHash => text()();
  TextColumn get passwordSalt => text().nullable()();
  DateTimeColumn get passwordUpdatedAt => dateTime().nullable()();
  TextColumn get phone => text().nullable()();
  BoolColumn get phoneVerified => boolean().withDefault(const Constant(false))();
  TextColumn get role => text().nullable()();
  TextColumn get roleId => text().nullable()();
  // using Text for Transformable
  TextColumn get roleSnapshot => text().nullable()();
  DateTimeColumn get statusChangedAt => dateTime().nullable()();
  TextColumn get statusReason => text().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  TextColumn get updatedBy => text().nullable()();
  TextColumn get userEmail => text().nullable()();
  TextColumn get userId => text().nullable()();
  TextColumn get username => text().nullable().unique()();
  TextColumn get verificationCode => text().nullable()();

  // CoreData allows an AppUser object to not have a clear primary key except username or objectID. 
  // We can use username as the PK or an auto-incrementing ID. Since username has a unique constraint, let's just let Drift auto-create an id for rowid, but 'username' is our unique identifier if we need one.
  // Actually drift requires ID if we don't define one, it uses rowid. We'll add an auto increment ID for safety.
  IntColumn get id => integer().autoIncrement()();
}

@DataClassName('BoilerHouseDb')
class BoilerHouses extends Table {
  IntColumn get backendId => integer().withDefault(const Constant(0))();
  TextColumn get boilerHouseUUID => text().nullable()();
  RealColumn get latitude => real().nullable().withDefault(const Constant(0.0))();
  RealColumn get longitude => real().nullable().withDefault(const Constant(0.0))();
  TextColumn get name => text().nullable()();
  TextColumn get siteManager => text().nullable()();
  TextColumn get siteNumber => text().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {backendId};
}

@DataClassName('BoilerPhotoDb')
class BoilerPhotos extends Table {
  IntColumn get backendId => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().nullable()();
  TextColumn get fileName => text()();
  IntColumn get fileSize => integer().nullable().withDefault(const Constant(0))();
  IntColumn get height => integer().nullable().withDefault(const Constant(0))();
  TextColumn get id => text()(); // UUID
  TextColumn get sha256 => text().nullable()();
  BlobColumn get thumbJPEG => blob().nullable()();
  TextColumn get thumbnailUrl => text().nullable()();
  TextColumn get url => text().nullable()();
  IntColumn get width => integer().nullable().withDefault(const Constant(0))();
  
  // Relationship
  IntColumn get boilerHouseId => integer().nullable().references(BoilerHouses, #backendId)();

  @override
  Set<Column> get primaryKey => {backendId};
}

@DataClassName('HousePhotoDb')
class HousePhotos extends Table {
  IntColumn get backendId => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get fileName => text()();
  IntColumn get fileSize => integer().nullable().withDefault(const Constant(0))();
  IntColumn get height => integer().nullable().withDefault(const Constant(0))();
  TextColumn get id => text()(); // UUID
  TextColumn get sha256 => text()();
  BlobColumn get thumbJPEG => blob().nullable()();
  TextColumn get thumbnailUrl => text().nullable()();
  TextColumn get url => text().nullable()();
  IntColumn get width => integer().nullable().withDefault(const Constant(0))();
  
  // Relationship
  IntColumn get houseId => integer().nullable().references(SavedLocations, #backendId)();

  @override
  Set<Column> get primaryKey => {backendId};
}

@DataClassName('IncidentDb')
class Incidents extends Table {
  IntColumn get backendId => integer().withDefault(const Constant(0))();
  IntColumn get assignedTo => integer().nullable().withDefault(const Constant(0))();
  TextColumn get details => text().nullable()();
  DateTimeColumn get finishedAt => dateTime().nullable()();
  TextColumn get incidentUUID => text().nullable()();
  DateTimeColumn get lastLocalEditAt => dateTime().nullable()();
  DateTimeColumn get lastServerUpdateAt => dateTime().nullable()();
  BoolColumn get localPendingAck => boolean().nullable().withDefault(const Constant(false))();
  TextColumn get notificationConfigRoleIds => text().nullable()();
  TextColumn get notificationConfigType => text().nullable()();
  TextColumn get notificationConfigUserIds => text().nullable()();
  BoolColumn get resourceHeatingStopped => boolean().nullable()();
  BoolColumn get resourceHotWaterStopped => boolean().nullable()();
  IntColumn get severity => integer().nullable().withDefault(const Constant(0))();
  DateTimeColumn get startedAt => dateTime().nullable()();
  TextColumn get status => text().nullable()();
  TextColumn get type => text().nullable()();
  
  // Relationship
  IntColumn get boilerHouseId => integer().nullable().references(BoilerHouses, #backendId)();

  @override
  Set<Column> get primaryKey => {backendId};
}

// Intersect table for AffectedHouses relationship (Incident <-> SavedLocation)
@DataClassName('AffectedHouseDb')
class AffectedHouses extends Table {
  IntColumn get incidentId => integer().references(Incidents, #backendId)();
  IntColumn get savedLocationId => integer().references(SavedLocations, #backendId)();

  @override
  Set<Column> get primaryKey => {incidentId, savedLocationId};

  // ADDED: Index for faster joins and deletion per incident
  @override
  List<Index> get indexes => [Index('affected_houses_incident_id', 'CREATE INDEX affected_houses_incident_id ON affected_houses (incident_id)')];
}

@DataClassName('IncidentCommentDb')
class IncidentComments extends Table {
  IntColumn get backendId => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get id => text()(); // UUID
  BoolColumn get isSystemMessage => boolean().withDefault(const Constant(false))();
  TextColumn get commentText => text()();
  IntColumn get userId => integer().nullable().withDefault(const Constant(0))();
  TextColumn get authorName => text().nullable()();
  TextColumn get authorPosition => text().nullable()();
  
  // Relationship
  IntColumn get incidentId => integer().nullable().references(Incidents, #backendId)();

  @override
  Set<Column> get primaryKey => {backendId};
}

@DataClassName('IncidentPhotoDb')
class IncidentPhotos extends Table {
  IntColumn get backendId => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().nullable()();
  TextColumn get fileName => text()();
  IntColumn get fileSize => integer().nullable().withDefault(const Constant(0))();
  IntColumn get height => integer().nullable().withDefault(const Constant(0))();
  TextColumn get id => text()(); // UUID
  TextColumn get sha256 => text().nullable()();
  BlobColumn get thumbJPEG => blob().nullable()();
  TextColumn get thumbnailUrl => text().nullable()();
  TextColumn get url => text().nullable()();
  IntColumn get width => integer().nullable().withDefault(const Constant(0))();
  
  // Relationship
  IntColumn get incidentId => integer().nullable().references(Incidents, #backendId)();

  @override
  Set<Column> get primaryKey => {backendId};

  // ADDED: Index for faster joins and deletion per incident
  @override
  List<Index> get indexes => [Index('incident_photos_incident_id', 'CREATE INDEX incident_photos_incident_id ON incident_photos (incident_id)')];
}

@DataClassName('ManagementCompanyDb')
class ManagementCompanies extends Table {
  TextColumn get address => text().nullable()();
  TextColumn get companyUUID => text().nullable()();
  TextColumn get director => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get id => text()(); // UUID
  TextColumn get name => text()(); // also uniquely constrained in CoreData
  TextColumn get normalizedName => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get phone => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('MyAccountDb')
class MyAccounts extends Table {
  TextColumn get accountNumber => text().nullable()();
  TextColumn get address => text().nullable()();
  RealColumn get area => real().nullable().withDefault(const Constant(0.0))();
  DateTimeColumn get closeDate => dateTime().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get fio => text().nullable()();
  TextColumn get jkuIdentifier => text().nullable()();
  TextColumn get locationUUID => text()(); // UUID
  DateTimeColumn get openDate => dateTime().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get serviceType => text().nullable()();
  TextColumn get status => text().nullable()();

  // We add an auto id to serve as simple PK. The unique constraint is on (locationUUID, accountNumber)
  IntColumn get id => integer().autoIncrement()();
}

@DataClassName('PendingChangeDb')
class PendingChanges extends Table {
  IntColumn get id => integer().autoIncrement()(); // SQLite requires a PK
  TextColumn get actionType => text()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get entityId => integer().nullable().withDefault(const Constant(0))();
  TextColumn get entityType => text()();
  BlobColumn get payload => blob().nullable()();
  IntColumn get priority => integer().nullable().withDefault(const Constant(1))();
  IntColumn get retryCount => integer().nullable().withDefault(const Constant(0))();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
}

@DataClassName('SavedLocationDb')
class SavedLocations extends Table {
  IntColumn get accounts => integer().nullable().withDefault(const Constant(0))();
  IntColumn get backendId => integer().nullable()(); // Notice it's optional in CoreData, but it's constrained unique
  TextColumn get fiasAOGuid => text().nullable()();
  TextColumn get fiasHouseGuid => text().nullable()();
  IntColumn get floors => integer().nullable().withDefault(const Constant(0))();
  BoolColumn get isStub => boolean().withDefault(const Constant(false))();
  RealColumn get latitude => real().nullable().withDefault(const Constant(0.0))();
  TextColumn get locationUUID => text().nullable()();
  RealColumn get longitude => real().nullable().withDefault(const Constant(0.0))();
  TextColumn get managementCompany => text().nullable()();
  TextColumn get name => text().nullable()();
  BoolColumn get providesHeating => boolean().nullable()();
  BoolColumn get providesHotWater => boolean().nullable()();
  IntColumn get residentsCount => integer().nullable().withDefault(const Constant(0))();
  IntColumn get rooms => integer().nullable().withDefault(const Constant(0))();
  RealColumn get totalArea => real().nullable().withDefault(const Constant(0.0))();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  IntColumn get yearBuilt => integer().nullable().withDefault(const Constant(0))();
  TextColumn get managementCompanyName => text().nullable()();

  // Relationships
  IntColumn get boilerHouseId => integer().nullable().references(BoilerHouses, #backendId)();
  TextColumn get managementCompanyRefId => text().nullable().references(ManagementCompanies, #id)();

  // We should make backendId primary key if it's there. 
  // However since backendId is nullable in iOS SavedLocation, we'll assign an auto-incremental primary key locally over it.
  IntColumn get id => integer().autoIncrement()();
}

// ----------------------------------------------------------------------
// New Table requested for Phase 7
// ----------------------------------------------------------------------
@DataClassName('SyncMetadataDb')
class SyncMetadata extends Table {
  TextColumn get syncKey => text()(); // e.g. "incidents", "boiler_houses"
  IntColumn get lastActionId => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastQueriedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {syncKey};
}

// ----------------------------------------------------------------------
// Database Definition
// ----------------------------------------------------------------------
@DriftDatabase(tables: [
  ActionLogs,
  AppUsers,
  BoilerHouses,
  BoilerPhotos,
  HousePhotos,
  Incidents,
  AffectedHouses,
  IncidentComments,
  IncidentPhotos,
  ManagementCompanies,
  MyAccounts,
  PendingChanges,
  SavedLocations,
  SyncMetadata,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) => m.createAll(),
    onUpgrade: (Migrator m, int from, int to) async {
      // Destructive migration: drop everything and recreate.
      // This is safe because the local DB is a cache; all data is
      // re-fetched from the server on next sync.
      for (final table in allTables) {
        await m.deleteTable(table.actualTableName);
      }
      await m.createAll();
    },
  );
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
    return NativeDatabase.createInBackground(file, setup: (db) {
      // Enable Write-Ahead Logging to prevent SQLite lockups during concurrent read/writes
      db.execute('PRAGMA journal_mode=WAL;');
    });
  });
}
