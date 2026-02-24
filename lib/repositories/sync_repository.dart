import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
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

  // ----------------------------------------------------------------------
  // Incidents
  // ----------------------------------------------------------------------

  Future<void> upsertIncidents(List<IncidentResponse> incidents) async {
    await _db.batch((batch) {
      for (final incident in incidents) {
        // Implement 'Server Wins' logic by resetting local changes flags when update received
        final companion = _db.incidents.insertCompanionFromResponse(incident).copyWith(
          localPendingAck: const Value(false),
          lastLocalEditAt: const Value(null),
        );
        batch.insert(
          _db.incidents,
          companion,
          mode: InsertMode.insertOrReplace,
        );

        if (incident.affectedHouseIds != null) {
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

        if (incident.photos != null) {
          for (final photo in incident.photos!) {
            batch.insert(
              _db.incidentPhotos,
              IncidentPhotosCompanion.insert(
                id: const Uuid().v4(), // Generate a UUID since backend doesn't provide one for the PK id column
                backendId: Value(photo.id),
                incidentId: Value(incident.id),
                url: Value(photo.url),
                fileName: 'photo_${photo.id}.jpg', // removed Value() wrapper
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

  Stream<List<IncidentResponse>> watchAllIncidents() {
    final query = _db.select(_db.incidents).join([
      leftOuterJoin(_db.boilerHouses, _db.boilerHouses.backendId.equalsExp(_db.incidents.boilerHouseId)),
    ]);
    
    return query.watch().asyncMap((rows) async {
      final List<IncidentResponse> responses = [];
      for (final row in rows) {
        final inc = row.readTable(_db.incidents);
        final bh = row.readTableOrNull(_db.boilerHouses);
        
        // photos + affected houses
        final photos = await (_db.select(_db.incidentPhotos)..where((t) => t.incidentId.equals(inc.backendId))).get();
        final affectedHouseRels = await (_db.select(_db.affectedHouses)..where((t) => t.incidentId.equals(inc.backendId))).get();
        
        List<SavedLocationDb> ahs = [];
        if (affectedHouseRels.isNotEmpty) {
          final ids = affectedHouseRels.map((e) => e.savedLocationId).toList();
          ahs = await (_db.select(_db.savedLocations)..where((t) => t.backendId.isIn(ids))).get();
        }
        
        responses.add(_mapIncidentToResponse(inc, boilerHouse: bh, affectedHouses: ahs, photos: photos));
      }
      return responses;
    });
  }

  Stream<IncidentResponse?> watchIncidentById(int backendId) {
    final query = _db.select(_db.incidents).join([
      leftOuterJoin(_db.boilerHouses, _db.boilerHouses.backendId.equalsExp(_db.incidents.boilerHouseId)),
    ])..where(_db.incidents.backendId.equals(backendId));
    
    return query.watchSingleOrNull().asyncMap((row) async {
      if (row == null) return null;
      final inc = row.readTable(_db.incidents);
      final bh = row.readTableOrNull(_db.boilerHouses);
      
      final photos = await (_db.select(_db.incidentPhotos)..where((t) => t.incidentId.equals(inc.backendId))).get();
      final affectedHouseRels = await (_db.select(_db.affectedHouses)..where((t) => t.incidentId.equals(inc.backendId))).get();
      
      List<SavedLocationDb> ahs = [];
      if (affectedHouseRels.isNotEmpty) {
        final ids = affectedHouseRels.map((e) => e.savedLocationId).toList();
        ahs = await (_db.select(_db.savedLocations)..where((t) => t.backendId.isIn(ids))).get();
      }
      return _mapIncidentToResponse(inc, boilerHouse: bh, affectedHouses: ahs, photos: photos);
    });
  }

  Future<void> saveIncidentOffline({IncidentCreate? create, IncidentUpdate? update}) async {
    final isCreate = create != null;
    final payload = (isCreate ? create.toJson() : update!.toJson());
    
    // 1. Assign local UUID
    final localUUID = isCreate ? const Uuid().v4() : update!.id.toString(); // For update, we use the real ID in payload but iOS queue uses ID.
    if (isCreate) {
      payload['localUUID'] = localUUID;
    }

    // 2. Generate a temporary backendId for newly created incidents (e.g. negative timestamp)
    final tempId = isCreate ? -(DateTime.now().millisecondsSinceEpoch ~/ 1000) : update!.id!;

    // 3. Write purely to local DB immediately
    await _db.batch((batch) {
      batch.insert(
        _db.incidents,
        IncidentsCompanion.insert(
          backendId: Value(tempId),
          incidentUUID: Value(isCreate ? localUUID : null),
          boilerHouseId: Value(isCreate ? create.boilerHouseId : update!.boilerHouseId),
          type: Value(isCreate ? create.title : update!.title),
          details: Value(isCreate ? create.description : update!.description),
          status: Value(isCreate ? create.status?.name : update!.status?.name),
          severity: Value(int.tryParse(isCreate ? (create.severity ?? '1') : (update!.severity ?? '1')) ?? 1),
          resourceHotWaterStopped: Value((isCreate ? create.resourceHotWaterStopped : update!.resourceHotWaterStopped) == 1),
          resourceHeatingStopped: Value((isCreate ? create.resourceHeatingStopped : update!.resourceHeatingStopped) == 1),
          lastLocalEditAt: Value(DateTime.now()),
          assignedTo: Value(isCreate ? create.assignedTo : update!.assignedTo),
          localPendingAck: const Value(true), // Mark as pending sync
        ),
        mode: InsertMode.insertOrReplace,
      );

      // Affected houses
      final affectedHouseIds = isCreate ? create.affectedHouseIds : update!.affectedHouseIds;
      if (affectedHouseIds != null) {
        // Delete old relations for updates (simplification)
        if (!isCreate) {
           (_db.delete(_db.affectedHouses)..where((t) => t.incidentId.equals(tempId))).go();
        }
        for (final houseId in affectedHouseIds) {
          batch.insert(
            _db.affectedHouses,
            AffectedHousesCompanion.insert(
              incidentId: tempId,
              savedLocationId: houseId,
            ),
            mode: InsertMode.insertOrIgnore,
          );
        }
      }
    });

    // 4. Enqueue for background sync
    await enqueueChange(
      entityType: 'incident',
      entityId: isCreate ? tempId : update!.id!,
      actionType: isCreate ? 'create' : 'update',
      payload: payload,
    );
  }

  Future<void> resolveTemporaryId(String entityType, int tempId, int realId) async {
    if (tempId > 0) return; // Not a temporary ID

    await _db.transaction(() async {
      if (entityType == 'incident') {
        // 1. Update the incident's backendId and clear pending flag
        await (_db.update(_db.incidents)..where((t) => t.backendId.equals(tempId)))
            .write(IncidentsCompanion(
              backendId: Value(realId),
              localPendingAck: const Value(false),
            ));
            
        // 2. Update foreign keys in affected houses
        await (_db.update(_db.affectedHouses)..where((t) => t.incidentId.equals(tempId)))
            .write(AffectedHousesCompanion(
              incidentId: Value(realId),
            ));
            
        // 3. Update foreign keys in incident photos
        await (_db.update(_db.incidentPhotos)..where((t) => t.incidentId.equals(tempId)))
            .write(IncidentPhotosCompanion(
              incidentId: Value(realId),
            ));
            
        // 4. Update foreign keys in incident comments
        await (_db.update(_db.incidentComments)..where((t) => t.incidentId.equals(tempId)))
            .write(IncidentCommentsCompanion(
              incidentId: Value(realId),
            ));
            
        // 5. Update pending changes queue
        await (_db.update(_db.pendingChanges)
            ..where((t) => t.entityType.equals(entityType) & t.entityId.equals(tempId)))
            .write(PendingChangesCompanion(
              entityId: Value(realId),
            ));
      }
    });
  }

  // ----------------------------------------------------------------------
  // Boiler Houses
  // ----------------------------------------------------------------------

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

  Stream<List<BoilerHouseResponse>> watchAllBoilerHouses() {
    return _db.select(_db.boilerHouses).watch().map((rows) {
      return rows.map((dbBh) => _mapBoilerHouseToResponse(dbBh)).toList();
    });
  }

  // ----------------------------------------------------------------------
  // Saved Locations
  // ----------------------------------------------------------------------

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
            // managementCompanyId is used as string in api? Yes
            // but we don't have it directly matching our schema unless we store it.
            // SavedLocationsDb has no managementCompanyId? Wait, we made SavedLocations.managementCompanyId integer?
            // Actually in database.dart I did: TextColumn get managementCompany => text().nullable()();
            // We use managementCompany for managementCompanyId? Yes or name?
            managementCompany: Value(loc.managementCompanyId),
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

  Stream<List<SavedLocationResponse>> watchAllLocations() {
    return _db.select(_db.savedLocations).watch().map((rows) {
      return rows.map((loc) => _mapLocationToResponse(loc)).toList();
    });
  }

  // ----------------------------------------------------------------------
  // Pending Changes (Queue)
  // ----------------------------------------------------------------------

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
            entityId: Value(entityId ?? 0),
            actionType: actionType,
            payload: Value(Uint8List.fromList(utf8.encode(jsonEncode(payload)))),
            priority: Value(priority),
            syncStatus: const Value('pending'),
            createdAt: DateTime.now(),
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

  // ----------------------------------------------------------------------
  // Sync Cursor (SyncMetadata)
  // ----------------------------------------------------------------------

  /// Get the last known sync cursor for a given key (e.g. 'global_sync_cursor').
  Future<int?> getSyncCursor(String key) async {
    final row = await (_db.select(_db.syncMetadata)
          ..where((t) => t.syncKey.equals(key)))
        .getSingleOrNull();
    return row?.lastActionId;
  }

  /// Update the sync cursor for a given key.
  Future<void> updateSyncCursor(String key, int actionId) async {
    await _db.into(_db.syncMetadata).insertOnConflictUpdate(
      SyncMetadataCompanion.insert(
        syncKey: key,
        lastActionId: Value(actionId),
        lastQueriedAt: Value(DateTime.now()),
      ),
    );
  }

  // ----------------------------------------------------------------------
  // Delete Entities (for action_type: delete from sync)
  // ----------------------------------------------------------------------

  Future<void> deleteIncident(int backendId) async {
    // Delete related affected houses and photos first
    await (_db.delete(_db.affectedHouses)..where((t) => t.incidentId.equals(backendId))).go();
    await (_db.delete(_db.incidentPhotos)..where((t) => t.incidentId.equals(backendId))).go();
    await (_db.delete(_db.incidents)..where((t) => t.backendId.equals(backendId))).go();
  }

  Future<void> deleteBoilerHouse(int backendId) async {
    await (_db.delete(_db.boilerHouses)..where((t) => t.backendId.equals(backendId))).go();
  }

  Future<void> deleteSavedLocation(int backendId) async {
    await (_db.delete(_db.savedLocations)..where((t) => t.backendId.equals(backendId))).go();
  }

  // ----------------------------------------------------------------------
  // Mapping Helpers
  // ----------------------------------------------------------------------

  IncidentResponse _mapIncidentToResponse(
    IncidentDb incident, {
    BoilerHouseDb? boilerHouse,
    List<SavedLocationDb>? affectedHouses,
    List<IncidentPhotoDb>? photos,
  }) {
    return IncidentResponse(
      id: incident.backendId,
      boilerHouseId: incident.boilerHouseId,
      title: incident.type, // type maps to title
      description: incident.details, // details maps to description
      status: IncidentStatus.fromAny(incident.status ?? 'open'),
      severity: incident.severity?.toString() ?? '1',
      resourceHotWaterStopped: (incident.resourceHotWaterStopped ?? false) ? 1 : 0,
      resourceHeatingStopped: (incident.resourceHeatingStopped ?? false) ? 1 : 0,
      createdAt: incident.startedAt?.toIso8601String() ?? incident.lastServerUpdateAt?.toIso8601String(),
      updatedAt: incident.lastServerUpdateAt?.toIso8601String() ?? incident.lastLocalEditAt?.toIso8601String(),
      resolvedAt: incident.finishedAt?.toIso8601String(),
      localUUID: incident.incidentUUID,
      localPendingAck: incident.localPendingAck,
      reportedBy: incident.assignedTo, // guessing mapping from API
      assignedTo: incident.assignedTo,
      affectedHouseIds: affectedHouses?.map((h) => h.backendId ?? 0).toList(),
      affectedHouseDetails: affectedHouses?.map((h) => AffectedHouseDetail(
        savedLocationId: h.backendId ?? 0,
        savedLocation: _mapSavedLocationToInfo(h),
      )).toList(),
      boilerHouse: boilerHouse != null ? BoilerHouseSummary(
        id: boilerHouse.backendId,
        address: boilerHouse.name ?? '', // name maps to address
        latitude: boilerHouse.latitude ?? 0.0,
        longitude: boilerHouse.longitude ?? 0.0,
        activeIncidentsCount: 0,
        hasActiveIncidents: 0,
        siteManager: boilerHouse.siteManager,
        siteNumber: boilerHouse.siteNumber,
      ) : null,
      photos: photos?.map((p) => PhotoInfo(
        id: p.backendId,
        url: p.url ?? '',
        thumbnailUrl: p.thumbnailUrl,
        createdAt: p.createdAt?.toIso8601String(),
      )).toList(),
      notificationConfig: (incident.notificationConfigType != null) 
        ? NotificationConfig(
            type: AudienceType.values.firstWhere(
              (e) => e.name == incident.notificationConfigType, 
              orElse: () => AudienceType.broadcast
            ),
            roleIds: incident.notificationConfigRoleIds?.split(',').where((s) => s.isNotEmpty).toList(),
            userIds: incident.notificationConfigUserIds?.split(',').where((s) => s.isNotEmpty).map(int.parse).toList(),
          )
        : null,
    );
  }

  SavedLocationInfo _mapSavedLocationToInfo(SavedLocationDb h) {
    return SavedLocationInfo(
      id: h.backendId ?? 0,
      name: h.name ?? '',
      latitude: h.latitude ?? 0.0,
      longitude: h.longitude ?? 0.0,
      floors: h.floors,
      rooms: h.rooms,
      totalArea: h.totalArea,
      residentsCount: h.residentsCount,
      yearBuilt: h.yearBuilt,
    );
  }

  BoilerHouseResponse _mapBoilerHouseToResponse(BoilerHouseDb bh) {
    return BoilerHouseResponse(
      id: bh.backendId,
      address: bh.name ?? '',
      latitude: bh.latitude ?? 0.0,
      longitude: bh.longitude ?? 0.0,
      siteNumber: bh.siteNumber,
      siteManager: bh.siteManager,
      boilerHouseUUID: bh.boilerHouseUUID,
      createdAt: bh.updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      updatedAt: bh.updatedAt?.toIso8601String(),
    );
  }

  SavedLocationResponse _mapLocationToResponse(SavedLocationDb loc) {
    return SavedLocationResponse(
      id: loc.backendId ?? 0,
      name: loc.name ?? '',
      latitude: loc.latitude ?? 0.0,
      longitude: loc.longitude ?? 0.0,
      managementCompanyId: loc.managementCompany, // Used managementCompany field holding the ID
      boilerHouseId: loc.boilerHouseId,
      floors: loc.floors,
      residentsCount: loc.residentsCount,
      rooms: loc.rooms,
      totalArea: loc.totalArea,
      yearBuilt: loc.yearBuilt,
      fiasHouseGuid: loc.fiasHouseGuid,
      fiasAOGuid: loc.fiasAOGuid,
      locationUUID: loc.locationUUID,
      providesHeating: loc.providesHeating,
      providesHotWater: loc.providesHotWater,
      createdAt: loc.updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      updatedAt: loc.updatedAt?.toIso8601String(),
    );
  }
}

extension IncidentsCompanionExtension on $IncidentsTable {
  IncidentsCompanion insertCompanionFromResponse(IncidentResponse incident) {
    return IncidentsCompanion.insert(
      backendId: Value(incident.id),
      incidentUUID: Value(incident.localUUID),
      boilerHouseId: Value(incident.boilerHouseId),
      type: Value(incident.title), // maps to title
      details: Value(incident.description), // maps to description
      status: Value(incident.status?.name),
      severity: Value(int.tryParse(incident.severity ?? '1') ?? 1),
      resourceHotWaterStopped: Value(incident.resourceHotWaterStopped == 1),
      resourceHeatingStopped: Value(incident.resourceHeatingStopped == 1),
      startedAt: Value(incident.createdAt != null ? DateTime.parse(incident.createdAt!) : null),
      lastServerUpdateAt: Value(incident.updatedAt != null ? DateTime.parse(incident.updatedAt!) : null),
      finishedAt: Value(incident.resolvedAt != null ? DateTime.parse(incident.resolvedAt!) : null),
      assignedTo: Value(incident.assignedTo),
      notificationConfigType: Value(incident.notificationConfig?.type.name),
      notificationConfigRoleIds: Value(incident.notificationConfig?.roleIds?.join(',')),
      notificationConfigUserIds: Value(incident.notificationConfig?.userIds?.join(',')),
    );
  }
}
