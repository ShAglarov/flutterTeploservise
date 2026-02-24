import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../database/database.dart';
import '../models/incident_models.dart';
import '../models/boiler_house_models.dart';
import '../models/location_models.dart';
import '../utils/constants.dart';

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

  Future<void> upsertIncidentPhotos(int incidentId, List<PhotoInfo> photos) async {
    await _db.batch((batch) {
      for (final photo in photos) {
        batch.insert(
          _db.incidentPhotos,
          IncidentPhotosCompanion.insert(
            id: const Uuid().v4(),
            backendId: Value(photo.id),
            incidentId: Value(incidentId),
            url: Value(photo.url),
            fileName: 'photo_${photo.id}.jpg',
            thumbnailUrl: Value(photo.thumbnailUrl),
            createdAt: Value(photo.createdAt != null ? DateTime.parse(photo.createdAt!) : null),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  Stream<List<IncidentResponse>> watchAllIncidents() {
    final query = _db.select(_db.incidents).join([
      leftOuterJoin(_db.boilerHouses, _db.boilerHouses.backendId.equalsExp(_db.incidents.boilerHouseId)),
      leftOuterJoin(_db.incidentPhotos, _db.incidentPhotos.incidentId.equalsExp(_db.incidents.backendId)),
    ])..orderBy([OrderingTerm(expression: _db.incidents.startedAt, mode: OrderingMode.desc)]);
    
    return query.watch().asyncMap((rows) async {
      final List<IncidentResponse> responses = [];
      if (rows.isEmpty) return responses;

      final incidentIds = rows.map((r) => r.readTable(_db.incidents).backendId).toList();

      // Fetch all photos and affected houses in bulk for all incidents in the list
      final allPhotos = await (_db.select(_db.incidentPhotos)
            ..where((t) => t.incidentId.isIn(incidentIds)))
          .get();
      
      final allAffectedRels = await (_db.select(_db.affectedHouses)
            ..where((t) => t.incidentId.isIn(incidentIds)))
          .get();

      // Fetch SavedLocation details for those relations
      final locIds = allAffectedRels.map((e) => e.savedLocationId).toSet().toList();
      final allLocations = locIds.isEmpty 
          ? <SavedLocationDb>[] 
          : await (_db.select(_db.savedLocations)..where((t) => t.backendId.isIn(locIds))).get();

      final photosByIncident = <int, List<IncidentPhotoDb>>{};
      for (final p in allPhotos) {
        if (p.incidentId != null) {
          photosByIncident.putIfAbsent(p.incidentId!, () => []).add(p);
        }
      }

      final locsByIncident = <int, List<SavedLocationDb>>{};
      final locationMap = {for (var l in allLocations) l.backendId: l};
      for (final rel in allAffectedRels) {
        final loc = locationMap[rel.savedLocationId];
        if (loc != null) {
          locsByIncident.putIfAbsent(rel.incidentId, () => []).add(loc);
        }
      }
      
      for (final row in rows) {
        final inc = row.readTable(_db.incidents);
        final bh = row.readTableOrNull(_db.boilerHouses);
        
        responses.add(_mapIncidentToResponse(
          inc, 
          boilerHouse: bh, 
          affectedHouses: locsByIncident[inc.backendId], 
          photos: photosByIncident[inc.backendId]
        ));
      }
      return responses;
    });
  }

  Stream<IncidentResponse?> watchIncidentById(int backendId) {
    // Include incidentPhotos in the join just to trigger stream updates when photos change,
    // even though we fetch them separately in asyncMap to avoid complex grouping/deduplication.
    final query = _db.select(_db.incidents).join([
      leftOuterJoin(_db.boilerHouses, _db.boilerHouses.backendId.equalsExp(_db.incidents.boilerHouseId)),
      leftOuterJoin(_db.incidentPhotos, _db.incidentPhotos.incidentId.equalsExp(_db.incidents.backendId)),
    ])..where(_db.incidents.backendId.equals(backendId));
    
    return query.watch().asyncMap((rows) async {
      if (rows.isEmpty) return null;
      final row = rows.first; // Since we might have multiple rows due to photos join, take first
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
          startedAt: Value(DateTime.now()),
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
    if (locations.isEmpty) return;

    // КРИТИЧНО: SavedLocations использует autoIncrement id как PK, а не backendId.
    // Поэтому InsertMode.insertOrReplace НЕ заменяет существующие записи — каждый insert
    // создаёт новую строку, что приводит к массовому дублированию.
    // Решение: удаляем существующие записи по backendId, затем вставляем новые.
    final backendIds = locations.where((l) => l.id > 0).map((l) => l.id).toList();
    
    await _db.transaction(() async {
      // 1. Удаляем старые записи с этими backendId
      if (backendIds.isNotEmpty) {
        await (_db.delete(_db.savedLocations)
          ..where((t) => t.backendId.isIn(backendIds)))
          .go();
      }

      // 2. Вставляем новые записи
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
          );
        }
      });
    });
  }

  /// Удаление дубликатов SavedLocations, оставляя только одну запись на backendId.
  /// Вызывать при запуске приложения для очистки накопившихся дубликатов.
  Future<void> deduplicateSavedLocations() async {
    final allLocs = await _db.select(_db.savedLocations).get();
    final seen = <int>{};
    final toDelete = <int>[];

    for (final loc in allLocs) {
      final bid = loc.backendId;
      if (bid == null || bid == 0) continue;
      if (seen.contains(bid)) {
        toDelete.add(loc.id);
      } else {
        seen.add(bid);
      }
    }

    if (toDelete.isNotEmpty) {
      print('🧹 [SyncRepo] Removing ${toDelete.length} duplicate saved locations');
      await (_db.delete(_db.savedLocations)
        ..where((t) => t.id.isIn(toDelete)))
        .go();
    }
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

  Future<void> deleteIncidentPhoto(int backendId) async {
    // Find the incident ID for this photo first to trigger update
    final photo = await (_db.select(_db.incidentPhotos)
          ..where((t) => t.backendId.equals(backendId)))
        .getSingleOrNull();
    final incidentId = photo?.incidentId;

    await (_db.delete(_db.incidentPhotos)
          ..where((t) => t.backendId.equals(backendId)))
        .go();

    if (incidentId != null) {
      // Trigger update on the incident record to force streams to refresh
      await (_db.update(_db.incidents)..where((t) => t.backendId.equals(incidentId)))
          .write(
        IncidentsCompanion(lastLocalEditAt: Value(DateTime.now())),
      );
      print('🔥 [SyncRepo] Forced incident update after photo deletion, id=$incidentId');
    }
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
      photos: photos?.map((p) {
        // Derive base domain from AppConstants.baseUrl
        final apiUri = Uri.parse(AppConstants.baseUrl);
        final baseUrlPrefix = AppConstants.baseUrl.split('/api/v1')[0];
        
        final url = p.url ?? '';
        final thumb = p.thumbnailUrl;
        
        // Try to match if it should be under /api/v1 or root
        // If the URL from backend starts with /uploads, it might need the prefix
        final fullUrl = url.startsWith('http') ? url : '$baseUrlPrefix$url';
        final fullThumb = (thumb != null && !thumb.startsWith('http')) ? '$baseUrlPrefix$thumb' : thumb;
        
        return PhotoInfo(
          id: p.backendId,
          url: fullUrl,
          thumbnailUrl: fullThumb,
          createdAt: p.createdAt?.toIso8601String(),
        );
      }).toList(),
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
