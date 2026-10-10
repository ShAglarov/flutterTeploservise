import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../services/tenant_service.dart';

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
  RealColumn get lastLatitude => real().nullable().withDefault(const Constant(0.0))();
  RealColumn get lastLongitude => real().nullable().withDefault(const Constant(0.0))();
  BoolColumn get canEditOffline => boolean().withDefault(const Constant(false))();

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
  IntColumn get siteManagerId => integer().nullable().withDefault(const Constant(0))();
  TextColumn get siteNumber => text().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  // Количество котлов у котельной (для секции котлов в форме инцидента)
  IntColumn get totalBoilersCount => integer().nullable().withDefault(const Constant(1))();

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
  DateTimeColumn get createdAt => dateTime().nullable()();
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
  DateTimeColumn get resolvedAt => dateTime().nullable()();
  DateTimeColumn get startedAt => dateTime().nullable()();
  TextColumn get status => text().nullable()();
  TextColumn get type => text().nullable()();
  BoolColumn get autoResolveOnFinish => boolean().nullable().withDefault(const Constant(false))();
  // Управление котлами: JSON-список неработающих котлов, напр. "[1,3]"
  TextColumn get inactiveBoilerNumbers => text().nullable()();
  // Тумблер «Теплоноситель не поступает полностью»
  BoolColumn get supplyFullyStopped => boolean().nullable().withDefault(const Constant(false))();
  // Вычисленный цветовой статус: "normal" | "partial" | "full"
  TextColumn get colorStatus => text().nullable()();
  
  // Relationship
  IntColumn get boilerHouseId => integer().nullable().references(BoilerHouses, #backendId)();

  @override
  Set<Column> get primaryKey => {backendId};
}

// Intersect table for AffectedHouses relationship (Incident <-> SavedLocation)
// Индекс по incident_id ускоряет join и удаление по инциденту.
// BUGFIX: раньше индекс объявлялся через `@override List<Index> get indexes`,
// но у drift Table такого геттера нет — код компилировался как обычный
// неиспользуемый метод, и индекс НЕ попадал в схему (проверено: имени не было
// в database.g.dart). Правильный API — аннотация @TableIndex.
@TableIndex(name: 'affected_houses_incident_id', columns: {#incidentId})
@DataClassName('AffectedHouseDb')
class AffectedHouses extends Table {
  IntColumn get incidentId => integer().references(Incidents, #backendId)();
  IntColumn get savedLocationId => integer().references(SavedLocations, #backendId)();

  @override
  Set<Column> get primaryKey => {incidentId, savedLocationId};
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
  TextColumn get authorAvatarUrl => text().nullable()();
  
  // Relationship
  IntColumn get incidentId => integer().nullable().references(Incidents, #backendId)();

  @override
  Set<Column> get primaryKey => {backendId};
}

// Индекс по incident_id — см. комментарий у AffectedHouses: предыдущее
// объявление через геттер indexes не создавало индекс.
@TableIndex(name: 'incident_photos_incident_id', columns: {#incidentId})
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

  // Поля ГИС ЖКХ и характеристики помещения — по той же причине, что и
  // у домов: без них введённое вручную не возвращалось в карточку.
  IntColumn get backendId => integer().nullable()();
  IntColumn get locationId => integer().nullable()();
  TextColumn get cadastralNumber => text().nullable()();
  IntColumn get roomsCount => integer().nullable()();
  TextColumn get gisEls => text().nullable()();
  TextColumn get gisAccountType => text().nullable()();
  BoolColumn get gisIsTenant => boolean().nullable()();
  BoolColumn get gisIsSplit => boolean().nullable()();
  TextColumn get gisLastName => text().nullable()();
  TextColumn get gisFirstName => text().nullable()();
  TextColumn get gisMiddleName => text().nullable()();
  TextColumn get gisSnils => text().nullable()();
  TextColumn get gisDocType => text().nullable()();
  TextColumn get gisDocNumber => text().nullable()();
  TextColumn get gisDocSeries => text().nullable()();
  TextColumn get gisDocDate => text().nullable()();
  TextColumn get gisOgrn => text().nullable()();
  TextColumn get gisNza => text().nullable()();
  TextColumn get gisKpp => text().nullable()();
  RealColumn get livingArea => real().nullable()();
  RealColumn get heatedArea => real().nullable()();
  IntColumn get residentsCount => integer().nullable()();
  TextColumn get gisPremisesType => text().nullable()();
  TextColumn get gisPremisesNumber => text().nullable()();
  TextColumn get gisRoomNumber => text().nullable()();
  RealColumn get gisPaymentShare => real().nullable()();
  // Листы «Жилые/Нежилые помещения» шаблона МКД. Характеристика
  // помещения обязательна при «Информация подтверждена поставщиком»:
  // без неё портал отклоняет строку (INT004144).
  TextColumn get gisPremisesCharacteristic => text().nullable()();
  TextColumn get gisEntranceNumber => text().nullable()();
  BoolColumn get gisCommonProperty => boolean().nullable()();
  BoolColumn get gisConfirmed => boolean().nullable()();
  TextColumn get gisStatus => text().nullable()();

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
  RealColumn get tariff => real().nullable()();

  // Характеристики дома и поля ГИС ЖКХ.
  //
  // Без них введённое в карточке дома пропадало с экрана: форма читает
  // дом из локального кэша, а в кэше этих колонок не было — сервер
  // сохранял значения, но обратно они не приходили.
  TextColumn get cadastralNumber => text().nullable()();
  DateTimeColumn get commissioningDate => dateTime().nullable()();
  TextColumn get stoveType => text().nullable()();
  TextColumn get housingType => text().nullable()();
  IntColumn get entrancesCount => integer().nullable()();
  TextColumn get gisOktmo => text().nullable()();
  TextColumn get gisState => text().nullable()();
  TextColumn get gisLifecycleStage => text().nullable()();
  IntColumn get undergroundFloors => integer().nullable()();
  TextColumn get gisTimezone => text().nullable()();
  BoolColumn get gisCulturalHeritage => boolean().nullable()();
  BoolColumn get gisFederalProperty => boolean().nullable()();
  BoolColumn get gisMunicipalProperty => boolean().nullable()();
  TextColumn get gisHostelType => text().nullable()();
  TextColumn get gisStatus => text().nullable()();

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
// Платежные документы
// ----------------------------------------------------------------------
@DataClassName('PaymentDocumentDb')
class PaymentDocumentsLocal extends Table {
  IntColumn get backendId => integer().withDefault(const Constant(0))();
  IntColumn get accountId => integer().withDefault(const Constant(0))();
  TextColumn get periodDate => text().nullable()();
  
  // Отопление
  RealColumn get debtHeatingStart => real().nullable().withDefault(const Constant(0.0))();
  RealColumn get chargedHeating => real().nullable().withDefault(const Constant(0.0))();
  RealColumn get paidHeating => real().nullable().withDefault(const Constant(0.0))();
  RealColumn get recalcHeating => real().nullable().withDefault(const Constant(0.0))();
  RealColumn get debtHeatingEnd => real().nullable().withDefault(const Constant(0.0))();
  
  // ГВС
  RealColumn get debtHotWaterStart => real().nullable().withDefault(const Constant(0.0))();
  RealColumn get chargedHotWater => real().nullable().withDefault(const Constant(0.0))();
  RealColumn get paidHotWater => real().nullable().withDefault(const Constant(0.0))();
  RealColumn get recalcHotWater => real().nullable().withDefault(const Constant(0.0))();
  RealColumn get debtHotWaterEnd => real().nullable().withDefault(const Constant(0.0))();
  
  // Техобслуживание
  RealColumn get debtMaintenanceStart => real().nullable().withDefault(const Constant(0.0))();
  RealColumn get chargedMaintenance => real().nullable().withDefault(const Constant(0.0))();
  RealColumn get paidMaintenance => real().nullable().withDefault(const Constant(0.0))();
  RealColumn get recalcMaintenance => real().nullable().withDefault(const Constant(0.0))();
  RealColumn get debtMaintenanceEnd => real().nullable().withDefault(const Constant(0.0))();
  
  // ТБО
  RealColumn get debtWasteStart => real().nullable().withDefault(const Constant(0.0))();
  RealColumn get chargedWaste => real().nullable().withDefault(const Constant(0.0))();
  RealColumn get paidWaste => real().nullable().withDefault(const Constant(0.0))();
  RealColumn get recalcWaste => real().nullable().withDefault(const Constant(0.0))();
  RealColumn get debtWasteEnd => real().nullable().withDefault(const Constant(0.0))();
  
  // ОДН Электричество
  RealColumn get debtOdnElectricityStart => real().nullable().withDefault(const Constant(0.0))();
  RealColumn get chargedOdnElectricity => real().nullable().withDefault(const Constant(0.0))();
  RealColumn get paidOdnElectricity => real().nullable().withDefault(const Constant(0.0))();
  RealColumn get recalcOdnElectricity => real().nullable().withDefault(const Constant(0.0))();
  RealColumn get debtOdnElectricityEnd => real().nullable().withDefault(const Constant(0.0))();
  
  // ОДН Вода
  RealColumn get debtOdnWaterStart => real().nullable().withDefault(const Constant(0.0))();
  RealColumn get chargedOdnWater => real().nullable().withDefault(const Constant(0.0))();
  RealColumn get paidOdnWater => real().nullable().withDefault(const Constant(0.0))();
  RealColumn get recalcOdnWater => real().nullable().withDefault(const Constant(0.0))();
  RealColumn get debtOdnWaterEnd => real().nullable().withDefault(const Constant(0.0))();
  
  // Температура
  RealColumn get t30 => real().nullable().withDefault(const Constant(0.0))();
  RealColumn get t31 => real().nullable().withDefault(const Constant(0.0))();
  
  // Доп. данные
  IntColumn get residentsCount => integer().nullable()();
  RealColumn get fsValue => real().nullable()();
  TextColumn get importSource => text().nullable()();
  
  // Вычисляемые
  RealColumn get totalDebtStart => real().nullable()();
  RealColumn get totalDebtEnd => real().nullable()();
  RealColumn get totalCharged => real().nullable()();
  RealColumn get totalPaid => real().nullable()();
  
  // Данные из Account
  TextColumn get accountNumber => text().nullable()();
  TextColumn get fio => text().nullable()();
  TextColumn get accountAddress => text().nullable()();

  @override
  Set<Column> get primaryKey => {backendId};
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
  PaymentDocumentsLocal,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Конструктор для тестов: позволяет подсунуть in-memory sqlite вместо файла
  /// в каталоге документов, который в тестовой среде недоступен.
  AppDatabase.forTesting(super.executor);

  @override
  // 15: добавлены индексы affected_houses_incident_id и
  // incident_photos_incident_id. Бамп нужен, чтобы уже установленные копии
  // прошли onUpgrade и пересоздали схему с индексами.
  // 17: у лицевого счёта появились колонки листов «Жилые/Нежилые
  // помещения» шаблона МКД (характеристика помещения, номер подъезда,
  // общее имущество, признак подтверждения).
  int get schemaVersion => 17;

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
  // Пересоздаём БД при смене организации: иначе остался бы открытым файл
  // прежнего тенанта, и данные нового пользователя писались бы в чужой кэш.
  ref.watch(currentOrganizationProvider);
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();

    // MULTI-TENANCY: имя файла включает организацию.
    //
    // Локальная БД — кэш серверных данных. Если на одном устройстве
    // работают сотрудники двух управляющих компаний, общий `db.sqlite`
    // смешал бы их данные: после входа второго он до полной
    // пересинхронизации видел бы дома, лицевые счета и инциденты первого.
    // Отдельный файл на тенанта решает это физически.
    //
    // `db.sqlite` без суффикса остаётся для сессий без организации
    // (не вошли, суперадмин) — и это же прежний файл, поэтому у
    // единственного действующего клиента кэш не теряется при обновлении:
    // организацию он получит при следующем входе.
    final orgId = TenantService.currentOrganizationId;
    final name = orgId == null ? 'db.sqlite' : 'db_org_$orgId.sqlite';
    final file = File(p.join(dbFolder.path, name));

    return NativeDatabase.createInBackground(file, setup: (db) {
      // Enable Write-Ahead Logging to prevent SQLite lockups during concurrent read/writes
      db.execute('PRAGMA journal_mode=WAL;');
    });
  });
}
