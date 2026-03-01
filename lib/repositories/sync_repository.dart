import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
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
    if (incidents.isEmpty) return;
    
    final incidentIds = incidents.map((i) => i.id).toList();

    await _db.transaction(() async {
      // 1. Clear old relations for these incidents to ensure consistency
      await (_db.delete(_db.affectedHouses)
            ..where((t) => t.incidentId.isIn(incidentIds)))
          .go();

      // 1.5. Clean up temporary offline duplicate rows that have the same incidentUUID
      for (final incident in incidents) {
        if (incident.localUUID != null && incident.localUUID!.isNotEmpty) {
          // Find any existing offline record with this UUID that isn't the real backend ID
          final existingLocals = await (_db.select(_db.incidents)
                ..where((t) => t.incidentUUID.equals(incident.localUUID!) & t.backendId.equals(incident.id).not()))
              .get();
              
          for (final local in existingLocals) {
            // Delete the offline relations and the offline incident itself
            await (_db.delete(_db.affectedHouses)..where((t) => t.incidentId.equals(local.backendId))).go();
            await (_db.delete(_db.incidentPhotos)..where((t) => t.incidentId.equals(local.backendId))).go();
            await (_db.delete(_db.incidents)..where((t) => t.backendId.equals(local.backendId))).go();
            dev.log('🗑️ [SyncRepo] Deleted ghost offline incident ${local.backendId} matching UUID ${incident.localUUID}', name: 'SYNC');
          }
        }
      }

      // 2. Batch insert/replace the incidents and their relations
      await _db.batch((batch) {
        for (final incident in incidents) {
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
                  id: const Uuid().v4(),
                  backendId: Value(photo.id),
                  incidentId: Value(incident.id),
                  url: Value(photo.url),
                  fileName: 'photo_${photo.id}.jpg',
                  thumbnailUrl: Value(photo.thumbnailUrl),
                  createdAt: Value(photo.createdAt != null ? DateTime.parse(photo.createdAt!) : null),
                ),
                mode: InsertMode.insertOrReplace,
              );
            }
          }
        }
      });
    });
    
    dev.log('✅ [SyncRepo] Upserted ${incidents.length} incidents', name: 'SYNC');
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
    ])..orderBy([OrderingTerm(expression: _db.incidents.startedAt, mode: OrderingMode.desc)]);

    return _db.customSelect(
      'SELECT 1',
      readsFrom: {
        _db.incidents,
        _db.boilerHouses,
        _db.incidentPhotos,
        _db.affectedHouses,
        _db.savedLocations,
      },
    ).watch()
      .transform(_DebounceStreamTransformer(const Duration(milliseconds: 100)))
      .asyncMap((_) async {
        final rows = await query.get();
        final stopwatch = Stopwatch()..start();
        dev.log('⚡️ [watchAllIncidents] SQLite emit. Rows: ${rows.length}', name: 'SYNC_PERF');
        
        if (rows.isEmpty) return <IncidentResponse>[];

        final incidentIds = rows.map((r) => r.readTable(_db.incidents).backendId).toList();

        // 1. Batch fetch all relations for these incidents in parallel
        final results = await Future.wait([
          // Photos
          (_db.select(_db.incidentPhotos)..where((t) => t.incidentId.isIn(incidentIds))).get(),
          // Affected houses mapping (join to get SavedLocation details)
          (_db.select(_db.affectedHouses).join([
            innerJoin(_db.savedLocations, _db.savedLocations.backendId.equalsExp(_db.affectedHouses.savedLocationId)),
          ])..where(_db.affectedHouses.incidentId.isIn(incidentIds))).get(),
        ]);

        final fetchMs = stopwatch.elapsedMilliseconds;
        
        final allPhotos = results[0] as List<IncidentPhotoDb>;
        final allAffectedHouses = results[1] as List<TypedResult>;

        // Organize relations by incident ID for O(1) access
        final photosByIncident = <int, List<IncidentPhotoDb>>{};
        for (final p in allPhotos) {
          final id = p.incidentId ?? 0;
          photosByIncident.putIfAbsent(id, () => []).add(p);
        }

        final housesByIncident = <int, List<TypedResult>>{};
        for (final row in allAffectedHouses) {
          final id = row.readTable(_db.affectedHouses).incidentId;
          housesByIncident.putIfAbsent(id, () => []).add(row);
        }

        final responses = <IncidentResponse>[];
        for (final row in rows) {
          final inc = row.readTable(_db.incidents);
          final bh = row.readTableOrNull(_db.boilerHouses);
          final incidentId = inc.backendId;

          final res = _mapIncidentToResponse(
            inc,
            boilerHouse: bh,
            affectedHousesRows: housesByIncident[incidentId] ?? [],
            photos: photosByIncident[incidentId] ?? [],
          );

          responses.add(res);
        }
        
        stopwatch.stop();
        dev.log('🏁 [watchAllIncidents] Done. RelFetch=$fetchMs ms, TotalMap=${stopwatch.elapsedMilliseconds} ms', name: 'SYNC_PERF');
        return responses;
      });
  }

  Stream<IncidentResponse?> watchIncidentById(int backendId) {
    final query = _db.select(_db.incidents).join([
      leftOuterJoin(_db.boilerHouses, _db.boilerHouses.backendId.equalsExp(_db.incidents.boilerHouseId)),
    ])..where(_db.incidents.backendId.equals(backendId));
    
    return query.watch().asyncMap((rows) async {
      if (rows.isEmpty) return null;
      final row = rows.first;
      final inc = row.readTable(_db.incidents);
      final bh = row.readTableOrNull(_db.boilerHouses);
      
      final photos = await (_db.select(_db.incidentPhotos)..where((t) => t.incidentId.equals(inc.backendId))).get();
      final affectedHousesRows = await (_db.select(_db.affectedHouses).join([
        innerJoin(_db.savedLocations, _db.savedLocations.backendId.equalsExp(_db.affectedHouses.savedLocationId)),
      ])..where(_db.affectedHouses.incidentId.equals(inc.backendId))).get();
      
      return _mapIncidentToResponse(inc, boilerHouse: bh, affectedHousesRows: affectedHousesRows, photos: photos);
    });
  }

  Future<void> saveIncidentOffline({IncidentCreate? create, IncidentUpdate? update}) async {
    final isCreate = create != null;
    final payload = (isCreate ? create.toJson() : update!.toJson());
    
    final localUUID = isCreate ? const Uuid().v4() : update!.id.toString();
    if (isCreate) payload['local_uuid'] = localUUID;

    final tempId = isCreate ? -(DateTime.now().millisecondsSinceEpoch ~/ 1000) : update!.id!;

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
          localPendingAck: const Value(true),
        ),
        mode: InsertMode.insertOrReplace,
      );

      final affectedHouseIds = isCreate ? create.affectedHouseIds : update!.affectedHouseIds;
      if (affectedHouseIds != null) {
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

    await enqueueChange(
      entityType: 'incident',
      entityId: isCreate ? tempId : update!.id!,
      actionType: isCreate ? 'create' : 'update',
      payload: payload,
    );
  }

  Future<void> resolveTemporaryId(String entityType, int tempId, int realId) async {
    if (tempId > 0) return;

    await _db.transaction(() async {
      if (entityType == 'incident') {
        await (_db.update(_db.incidents)..where((t) => t.backendId.equals(tempId)))
            .write(IncidentsCompanion(
              backendId: Value(realId),
              localPendingAck: const Value(false),
            ));
            
        await (_db.update(_db.affectedHouses)..where((t) => t.incidentId.equals(tempId)))
            .write(AffectedHousesCompanion(
              incidentId: Value(realId),
            ));
            
        await (_db.update(_db.incidentPhotos)..where((t) => t.incidentId.equals(tempId)))
            .write(IncidentPhotosCompanion(
              incidentId: Value(realId),
            ));
            
        await (_db.update(_db.incidentComments)..where((t) => t.incidentId.equals(tempId)))
            .write(IncidentCommentsCompanion(
              incidentId: Value(realId),
            ));
            
        await (_db.update(_db.pendingChanges)
            ..where((t) => t.entityType.equals(entityType) & t.entityId.equals(tempId)))
            .write(PendingChangesCompanion(
              entityId: Value(realId),
            ));
      }
    });
  }

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

  Future<void> upsertSavedLocations(List<SavedLocationResponse> locations) async {
    if (locations.isEmpty) return;
    final backendIds = locations.where((l) => l.id > 0).map((l) => l.id).toList();
    
    await _db.transaction(() async {
      if (backendIds.isNotEmpty) {
        await (_db.delete(_db.savedLocations)
          ..where((t) => t.backendId.isIn(backendIds)))
          .go();
      }

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
              managementCompanyName: Value(loc.managementCompanyName),
              boilerHouseId: Value(loc.boilerHouseId),
              floors: Value(loc.floors),
              residentsCount: Value(loc.residentsCount),
              rooms: Value(loc.rooms),
              totalArea: Value(loc.totalArea),
              yearBuilt: Value(loc.yearBuilt),
              fiasHouseGuid: Value(loc.fiasHouseGuid),
              fiasAOGuid: Value(loc.fiasAOGuid),
              accounts: Value(loc.accountsCount),
              providesHeating: Value(loc.providesHeating ?? false),
              providesHotWater: Value(loc.providesHotWater ?? false),
              updatedAt: Value(loc.updatedAt != null ? DateTime.parse(loc.updatedAt!) : null),
            ),
          );

          if (loc.accounts != null) {
            for (final acc in loc.accounts!) {
              batch.insert(
                _db.myAccounts,
                MyAccountsCompanion.insert(
                  accountNumber: Value(acc.accountNumber),
                  address: Value(acc.address),
                  area: Value(acc.area),
                  closeDate: Value(acc.closeDate != null ? DateTime.parse(acc.closeDate!) : null),
                  email: Value(acc.email),
                  fio: Value(acc.fio),
                  jkuIdentifier: Value(acc.jkuIdentifier),
                  locationUUID: acc.locationUUID ?? loc.locationUUID ?? '',
                  openDate: Value(acc.openDate != null ? DateTime.parse(acc.openDate!) : null),
                  phone: Value(acc.phone),
                  serviceType: Value(acc.serviceType),
                  status: Value(acc.status),
                ),
                mode: InsertMode.insertOrReplace,
              );
            }
          }

          if (loc.photos != null) {
            for (final photo in loc.photos!) {
              batch.insert(
                _db.housePhotos,
                HousePhotosCompanion.insert(
                  backendId: Value(photo.id),
                  url: Value(photo.url),
                  thumbnailUrl: Value(photo.thumbnailUrl),
                  createdAt: DateTime.parse(photo.createdAt ?? DateTime.now().toIso8601String()),
                  fileName: photo.url?.split('/').last ?? 'photo.jpg',
                  id: photo.id.toString(),
                  sha256: '',
                  houseId: Value(loc.id),
                ),
                mode: InsertMode.insertOrReplace,
              );
            }
          }
        }
      });
    });
  }

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
      await (_db.delete(_db.savedLocations)..where((t) => t.id.isIn(toDelete))).go();
    }
  }

  Stream<List<SavedLocationResponse>> watchAllLocations() {
    final query = _db.select(_db.savedLocations).join([
      leftOuterJoin(_db.housePhotos, _db.housePhotos.houseId.equalsExp(_db.savedLocations.backendId)),
    ]);

    return query.watch().map((rows) {
      final Map<int, SavedLocationDb> locsMap = {};
      final Map<int, List<HousePhotoDb>> photosMap = {};

      for (final row in rows) {
        final loc = row.readTable(_db.savedLocations);
        final photo = row.readTableOrNull(_db.housePhotos);

        final bid = loc.backendId ?? 0;
        locsMap[bid] = loc;
        if (photo != null) {
          photosMap.putIfAbsent(bid, () => []).add(photo);
        }
      }

      return locsMap.values.map((loc) {
        return _mapLocationToResponse(loc, photos: photosMap[loc.backendId]);
      }).toList();
    });
  }

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

  Future<int?> getSyncCursor(String key) async {
    final row = await (_db.select(_db.syncMetadata)
          ..where((t) => t.syncKey.equals(key)))
        .getSingleOrNull();
    return row?.lastActionId;
  }

  Future<void> updateSyncCursor(String key, int actionId) async {
    await _db.into(_db.syncMetadata).insertOnConflictUpdate(
      SyncMetadataCompanion.insert(
        syncKey: key,
        lastActionId: Value(actionId),
        lastQueriedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> deleteIncident(int backendId) async {
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
    final photo = await (_db.select(_db.incidentPhotos)
          ..where((t) => t.backendId.equals(backendId)))
        .getSingleOrNull();
    final incidentId = photo?.incidentId;

    await (_db.delete(_db.incidentPhotos)
          ..where((t) => t.backendId.equals(backendId)))
        .go();

    if (incidentId != null) {
      await (_db.update(_db.incidents)..where((t) => t.backendId.equals(incidentId)))
          .write(IncidentsCompanion(lastLocalEditAt: Value(DateTime.now())));
    }
  }

  Future<void> deleteLocationPhoto(int backendId) async {
    await (_db.delete(_db.housePhotos)..where((t) => t.backendId.equals(backendId))).go();
  }

  // ----------------------------------------------------------------------
  // Mapping Helpers
  // ----------------------------------------------------------------------

  IncidentResponse _mapIncidentToResponse(
    IncidentDb incident, {
    BoilerHouseDb? boilerHouse,
    required List<TypedResult> affectedHousesRows,
    required List<IncidentPhotoDb> photos,
  }) {
    final baseUrlPrefix = AppConstants.baseUrl.split('/api/v1')[0];

    return IncidentResponse(
      id: incident.backendId,
      boilerHouseId: incident.boilerHouseId,
      title: incident.type,
      description: incident.details,
      status: IncidentStatus.fromAny(incident.status),
      severity: incident.severity?.toString() ?? '1',
      resourceHotWaterStopped: (incident.resourceHotWaterStopped == true) ? 1 : 0,
      resourceHeatingStopped: (incident.resourceHeatingStopped == true) ? 1 : 0,
      createdAt: incident.startedAt?.toIso8601String(),
      updatedAt: incident.lastServerUpdateAt?.toIso8601String(),
      resolvedAt: incident.finishedAt?.toIso8601String(),
      localUUID: incident.incidentUUID,
      localPendingAck: incident.localPendingAck,
      assignedTo: incident.assignedTo,
      affectedHouseIds: affectedHousesRows.map((r) => r.readTable(_db.affectedHouses).savedLocationId).toList(),
      affectedHouseDetails: affectedHousesRows.map((r) => AffectedHouseDetail(
        savedLocationId: r.readTable(_db.affectedHouses).savedLocationId,
        residentsCount: r.readTable(_db.savedLocations).residentsCount,
        savedLocation: _mapSavedLocationToInfo(r.readTable(_db.savedLocations)),
      )).toList(),
      boilerHouse: boilerHouse != null ? _mapBoilerHouseToSummary(boilerHouse) : null,
      photos: photos.map((p) {
        final url = p.url ?? '';
        final thumb = p.thumbnailUrl;
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
            type: AudienceType.fromAny(incident.notificationConfigType),
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

  BoilerHouseSummary _mapBoilerHouseToSummary(BoilerHouseDb bh) {
    return BoilerHouseSummary(
      id: bh.backendId,
      address: bh.name ?? '',
      latitude: bh.latitude ?? 0.0,
      longitude: bh.longitude ?? 0.0,
      activeIncidentsCount: 0,
      hasActiveIncidents: 0,
      siteNumber: bh.siteNumber,
      siteManager: bh.siteManager,
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

  SavedLocationResponse _mapLocationToResponse(SavedLocationDb loc, {List<HousePhotoDb>? photos}) {
    final baseUrlPrefix = AppConstants.baseUrl.split('/api/v1')[0];
    return SavedLocationResponse(
      id: loc.backendId ?? 0,
      name: loc.name ?? '',
      latitude: loc.latitude ?? 0.0,
      longitude: loc.longitude ?? 0.0,
      managementCompanyId: loc.managementCompany,
      managementCompanyName: loc.managementCompanyName,
      boilerHouseId: loc.boilerHouseId,
      floors: loc.floors,
      residentsCount: loc.residentsCount,
      rooms: loc.rooms,
      totalArea: loc.totalArea,
      yearBuilt: loc.yearBuilt,
      fiasHouseGuid: loc.fiasHouseGuid,
      fiasAOGuid: loc.fiasAOGuid,
      locationUUID: loc.locationUUID,
      accountsCount: loc.accounts,
      providesHeating: loc.providesHeating,
      providesHotWater: loc.providesHotWater,
      createdAt: loc.updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      updatedAt: loc.updatedAt?.toIso8601String(),
      photos: photos?.map((p) {
        final url = p.url ?? '';
        final fullUrl = url.startsWith('http') ? url : '$baseUrlPrefix$url';
        return PhotoInfo(
          id: p.backendId,
          url: fullUrl,
          thumbnailUrl: p.thumbnailUrl != null ? (p.thumbnailUrl!.startsWith('http') ? p.thumbnailUrl : '$baseUrlPrefix${p.thumbnailUrl}') : null,
          createdAt: p.createdAt.toIso8601String(),
        );
      }).toList(),
    );
  }
}

extension IncidentsCompanionExtension on $IncidentsTable {
  IncidentsCompanion insertCompanionFromResponse(IncidentResponse incident) {
    return IncidentsCompanion.insert(
      backendId: Value(incident.id),
      incidentUUID: Value(incident.localUUID),
      boilerHouseId: Value(incident.boilerHouseId),
      type: Value(incident.title),
      details: Value(incident.description),
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

class _DebounceStreamTransformer<T> extends StreamTransformerBase<T, T> {
  final Duration duration;
  final bool leading;
  
  _DebounceStreamTransformer(this.duration, {this.leading = false});

  @override
  Stream<T> bind(Stream<T> stream) {
    Timer? timer;
    StreamController<T>? controller;
    StreamSubscription<T>? subscription;
    bool isFirstEvent = true;

    controller = StreamController<T>(
      onListen: () {
        subscription = stream.listen((event) {
          if (leading && isFirstEvent) {
            isFirstEvent = false;
            if (controller != null && !controller!.isClosed) {
              controller!.add(event);
            }
            return;
          }
          isFirstEvent = false;
          timer?.cancel();
          timer = Timer(duration, () {
            if (controller != null && !controller!.isClosed) {
              controller!.add(event);
            }
          });
        });
      },
      onPause: () => subscription?.pause(),
      onResume: () => subscription?.resume(),
      onCancel: () {
        subscription?.cancel();
        timer?.cancel();
      },
    );

    return controller.stream;
  }
}
