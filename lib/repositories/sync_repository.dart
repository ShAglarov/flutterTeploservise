import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart';
import '../models/incident_models.dart';
import '../models/boiler_house_models.dart';
import '../models/location_models.dart';

final syncRepositoryProvider = Provider<SyncRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return SyncRepository(db);
});

class SyncRepository {
  final AppDatabase _db;

  SyncRepository(this._db);

  // --- Incidents ---

  Future<void> upsertIncidents(List<IncidentResponse> incidents) async {
    await _db.batch((batch) {
      for (final incident in incidents) {
        batch.insert(
          _db.incidents,
          _db.incidents.insertCompanionFromResponse(incident),
          mode: InsertMode.insertOrReplace,
        );

        // Update Affected Houses
        if (incident.affectedHouseIds != null) {
          // Note: In a real app we might want to delete old ones first
          // but Drift batch doesn't easily support batch delete + insert in order
          // so we handle it simply for now.
          for (final houseId in incident.affectedHouseIds!) {
            batch.insert(
              _db.affectedHouses,
              AffectedHousesCompanion.insert(
                incidentId: incident.id,
                savedLocationId: houseId,
              ),
              mode: InsertMode.insertOrIgnore,
            );
          }
        }

        // Update Photos
        if (incident.photos != null) {
          for (final photo in incident.photos!) {
            batch.insert(
              _db.incidentPhotos,
              IncidentPhotosCompanion.insert(
                backendId: Value(photo.id),
                incidentId: incident.id,
                url: photo.url,
                thumbnailUrl: Value(photo.thumbnailUrl),
                createdAt: Value(photo.createdAt != null ? DateTime.parse(photo.createdAt!) : null),
              ),
              mode: InsertMode.insertOrReplace,
            );
          }
        }
      }
    });
  }

  Stream<List<IncidentDb>> watchAllIncidents() {
    return _db.select(_db.incidents).watch();
  }

  Stream<IncidentDb?> watchIncidentById(int backendId) {
    return (_db.select(_db.incidents)..where((t) => t.backendId.equals(backendId)))
        .watchSingleOrNull();
  }

  // --- Boiler Houses ---

  Future<void> upsertBoilerHouses(List<BoilerHouseResponse> boilerHouses) async {
    await _db.batch((batch) {
      for (final bh in boilerHouses) {
        batch.insert(
          _db.boilerHouses,
          BoilerHousesCompanion.insert(
            backendId: Value(bh.id),
            boilerHouseUUID: Value(bh.boilerHouseUUID),
            name: Value(bh.address),
            latitude: Value(bh.latitude),
            longitude: Value(bh.longitude),
            siteNumber: Value(bh.siteNumber),
            siteManager: Value(bh.siteManager),
            updatedAt: Value(bh.updatedAt != null ? DateTime.parse(bh.updatedAt!) : null),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  // --- Saved Locations ---

  Future<void> upsertSavedLocations(List<SavedLocationResponse> locations) async {
    await _db.batch((batch) {
      for (final loc in locations) {
        batch.insert(
          _db.savedLocations,
          SavedLocationsCompanion.insert(
            backendId: Value(loc.id),
            locationUUID: Value(loc.locationUUID),
            name: Value(loc.name),
            latitude: Value(loc.latitude),
            longitude: Value(loc.longitude),
            managementCompanyId: Value(loc.managementCompanyId),
            boilerHouseId: Value(loc.boilerHouseId),
            floors: Value(loc.floors),
            residentsCount: Value(loc.residentsCount),
            rooms: Value(loc.rooms),
            totalArea: Value(loc.totalArea),
            yearBuilt: Value(loc.yearBuilt),
            fiasHouseGuid: Value(loc.fiasHouseGuid),
            fiasAOGuid: Value(loc.fiasAOGuid),
            providesHeating: Value(loc.providesHeating ?? false),
            providesHotWater: Value(loc.providesHotWater ?? false),
            updatedAt: Value(loc.updatedAt != null ? DateTime.parse(loc.updatedAt!) : null),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  // --- Pending Changes ---

  Future<void> enqueueChange({
    required String entityType,
    int? entityId,
    required String actionType,
    required Map<String, dynamic> payload,
    int priority = 1,
  }) async {
    await _db.into(_db.pendingChanges).insert(
          PendingChangesCompanion.insert(
            entityType: entityType,
            entityId: Value(entityId),
            actionType: actionType,
            payload: Value(jsonEncode(payload)),
            priority: Value(priority),
            syncStatus: const Value('pending'),
            createdAt: Value(DateTime.now()),
          ),
        );
  }

  Future<List<PendingChangeDb>> getPendingChanges() {
    return (_db.select(_db.pendingChanges)
          ..where((t) => t.syncStatus.equals('pending'))
          ..orderBy([
            (t) => OrderingTerm(expression: t.priority, mode: OrderingMode.asc),
            (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.asc),
          ]))
        .get();
  }

  Future<void> updatePendingStatus(int id, String status, {int? retryCount}) async {
    await (_db.update(_db.pendingChanges)..where((t) => t.id.equals(id))).write(
      PendingChangesCompanion(
        syncStatus: Value(status),
        retryCount: retryCount != null ? Value(retryCount) : const Value.absent(),
      ),
    );
  }
}

// Helper extension for easier mapping
extension IncidentsCompanionExtension on $IncidentsTable {
  IncidentsCompanion insertCompanionFromResponse(IncidentResponse incident) {
    return IncidentsCompanion.insert(
      backendId: Value(incident.id),
      incidentUUID: Value(incident.localUUID),
      boilerHouseId: Value(incident.boilerHouseId),
      title: Value(incident.title),
      description: Value(incident.description),
      status: Value(incident.status),
      severity: Value(int.tryParse(incident.severity ?? '1') ?? 1),
      resourceHotWaterStopped: Value(incident.resourceHotWaterStopped == 1),
      resourceHeatingStopped: Value(incident.resourceHeatingStopped == 1),
      createdAt: Value(incident.createdAt != null ? DateTime.parse(incident.createdAt!) : null),
      updatedAt: Value(incident.updatedAt != null ? DateTime.parse(incident.updatedAt!) : null),
      resolvedAt: Value(incident.resolvedAt != null ? DateTime.parse(incident.resolvedAt!) : null),
      reportedBy: Value(incident.reportedBy),
      assignedTo: Value(incident.assignedTo),
      notificationConfigType: Value(incident.notificationConfig?.type.name),
      notificationConfigRoleIds: Value(incident.notificationConfig?.roleIds?.join(',')),
      notificationConfigUserIds: Value(incident.notificationConfig?.userIds?.join(',')),
    );
  }
}
