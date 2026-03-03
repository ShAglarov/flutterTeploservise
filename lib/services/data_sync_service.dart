import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/sync_repository.dart';
import '../models/incident_models.dart';
import '../models/boiler_house_models.dart';
import '../models/location_models.dart';
import 'realtime_service.dart';
import 'device_id_service.dart';

import '../providers/incident_providers.dart';

final dataSyncServiceProvider = Provider<DataSyncService>((ref) {
  ref.keepAlive();
  final syncRepo = ref.watch(syncRepositoryProvider);
  final realtimeService = ref.watch(realtimeServiceProvider);
  final deviceService = ref.watch(deviceIdServiceProvider);
  final service = DataSyncService(ref, syncRepo, realtimeService, deviceService);
  
  // Auto-start listening
  service.start();
  
  ref.onDispose(() => service.dispose());
  return service;
});

class _EntityCacheEntry {
  final String dataHash;
  final DateTime timestamp;
  _EntityCacheEntry(this.dataHash, this.timestamp);
}

/// Processes incoming WebSocket `action_sync` messages and applies them to the
/// local Drift database. This is the "incoming mail" handler described in the
/// documentation (DataSyncService / SyncCoordinator).
class DataSyncService {
  final Ref _ref;
  final SyncRepository _syncRepo;
  final RealtimeService _realtimeService;
  final DeviceIdService _deviceService;

  StreamSubscription? _messageSubscription;
  String? _myDeviceId;

  /// Tracks the highest action_log ID received via WebSocket.
  /// Used for gap detection on reconnect.
  final Set<String> _processedActionHashes = {};
  int _lastWSActionLogId = 0;
  int get lastWSActionLogId => _lastWSActionLogId;

  /// Tracks recently processed msg_id to prevent redelivery storms
  final Set<String> _processedMsgIds = {};

  // ADDED: Deduplication cache for identical updates
  final Map<String, _EntityCacheEntry> _recentUpdatesData = {};

  // SERIAL QUEUE for processing incoming events
  // This ensures that if we get 5 fast WebSocket events, they are processed 
  // strictly in order, preventing database race conditions.
  Future<void> _processingQueue = Future.value();

  DataSyncService(this._ref, this._syncRepo, this._realtimeService, this._deviceService);

  Future<void> start() async {
    if (_messageSubscription != null) return; // Already started

    _myDeviceId = await _deviceService.getDeviceId();
    
    // Load last sync cursor from DB
    _lastWSActionLogId = await _syncRepo.getSyncCursor('ws_sync_cursor') ?? 0;
    dev.log('[DataSync] Starting listener, deviceId=$_myDeviceId, lastCursor=$_lastWSActionLogId', name: 'SYNC');

    _messageSubscription = _realtimeService.messages.listen(
      (message) => _handleMessage(message),
      onError: (e) => dev.log('[DataSync] Stream error: $e', name: 'SYNC'),
      onDone: () => dev.log('[DataSync] Stream closed', name: 'SYNC'),
    );
  }

  void stop() {
    _messageSubscription?.cancel();
    _messageSubscription = null;
  }

  /// Process a single action (from WS or from incremental sync).
  /// Returns true if the action was applied successfully.
  Future<bool> processAction(Map<String, dynamic> actionData) async {
    // Generate a quick hash of the action data to prevent duplicate processing 
    // when WebSocket and REST fetch the same action concurrently
    final hashStr = actionData.toString();
    if (_processedActionHashes.contains(hashStr)) {
      final actionId = actionData['id'];
      dev.log('📥 [DataSync] IGNORING DUPLICATE ACTION (already processed): id=$actionId, type=${actionData['entity_type']}', name: 'SYNC');
      return true; // Already processed
    }
    
    if (_processedActionHashes.length >= 1000) {
      _processedActionHashes.remove(_processedActionHashes.first);
    }
    _processedActionHashes.add(hashStr);

    final actionType = (actionData['action_type'] as String?)?.toLowerCase();
    final entityType = (actionData['entity_type'] as String?)?.toLowerCase();
    final entityIdRaw = actionData['entity_id'];
    final actionId = actionData['id'];
    final deviceId = actionData['device_id'] as String?;
    final entityData = actionData['entity_data'] as Map<String, dynamic>?;

    if (actionType == null || entityType == null) {
      dev.log('[DataSync] Skipping malformed action: missing type fields', name: 'SYNC');
      return false;
    }

    // Echo suppression: skip actions originating from this device UNLESS it contains full entity data.
    // We want to apply the server's committed state even if it was our action,
    // as it might contain server-side generated fields (like photo IDs, URLs, etc) 
    // that we haven't integrated locally yet.
    if (deviceId != null && deviceId == _myDeviceId && entityData == null) {
      dev.log('[DataSync] Echo suppressed: action from own device (no data)', name: 'SYNC');
      // Still track the actionId for cursor
      await _trackActionId(actionId);
      return true;
    }

    // ADDED: Hard deduplication for identical updates within 5s
    if (actionType == 'update' && entityData != null) {
      final cacheKey = '${entityType}_${entityIdRaw}';
      final dataHash = jsonEncode(entityData);
      final now = DateTime.now();
      
      final existing = _recentUpdatesData[cacheKey];
      if (existing != null && existing.dataHash == dataHash && now.difference(existing.timestamp).inSeconds < 5) {
        dev.log('📥 [DataSync] HARD DEDUPLICATION: Identical update for $cacheKey within 5s, skipping DB write.', name: 'SYNC');
        await _trackActionId(actionId); // still track cursor!
        return true;
      }
      
      _recentUpdatesData[cacheKey] = _EntityCacheEntry(dataHash, now);
      
      // Cleanup old entries (keep memory small)
      if (_recentUpdatesData.length > 100) {
        _recentUpdatesData.removeWhere((key, value) => now.difference(value.timestamp).inSeconds > 60);
      }
    }

    try {
      print('💾 [DataSyncService] Начинаю запись в БД для: $actionType $entityType (id: $entityIdRaw)');
      switch (entityType) {
        case 'incident':
          await _handleIncident(actionType, entityIdRaw, entityData);
          break;
        case 'boiler_house':
          await _handleBoilerHouse(actionType, entityIdRaw, entityData);
          break;
        case 'saved_location':
          await _handleSavedLocation(actionType, entityIdRaw, entityData);
          break;
        case 'incident_photo':
        case 'saved_location_photo':
        case 'boiler_house_photo':
          await _handlePhoto(actionType, entityType, entityIdRaw, entityData);
          break;
        case 'incident_comment':
        case 'comment':
          await _handleComment(actionType, entityIdRaw, entityData);
          break;
        case 'management_company':
          // TODO: implement if/when MC models are added
          dev.log('[DataSync] management_company action - skipping (not implemented)', name: 'SYNC');
          break;
        case 'account':
          // TODO: implement if/when Account sync is needed
          dev.log('[DataSync] account action - skipping (not implemented)', name: 'SYNC');
          break;
        default:
          dev.log('[DataSync] Unknown entity type: $entityType', name: 'SYNC');
      }

      await _trackActionId(actionId);
      dev.log('✅ [DataSync] Processed $actionType $entityType id=$entityIdRaw', name: 'SYNC');
      return true;
    } catch (e) {
      dev.log('❌ [DataSync] Failed to process $actionType $entityType: $e', name: 'SYNC');
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // WS message handler
  // ---------------------------------------------------------------------------

  void _handleMessage(Map<String, dynamic> message) {
    final msgId = message['msg_id'] as String?;
    
    // HARD DROP BEFORE QUEUEING
    if (msgId != null) {
      if (_processedMsgIds.contains(msgId)) {
        dev.log('📥 [DataSync] HARD DROP: Duplicate or redelivery msg_id=$msgId', name: 'SYNC');
        return; // Return immediately, DO NOT ENTER QUEUE
      }
      // Prevent memory leak
      if (_processedMsgIds.length >= 500) {
        _processedMsgIds.remove(_processedMsgIds.first);
      }
      _processedMsgIds.add(msgId);
    }

    // MODIFIED: Push every WebSocket message into a serial queue.
    _processingQueue = _processingQueue.then((_) async {
      try {
        final type = message['type'];
        final timestamp = DateTime.now().toIso8601String();


        if (type == 'action_sync') {
          // The server sends: {"type": "action_sync", "data": {...action fields...}, "timestamp": "..."}
          final actionData = message['data'] as Map<String, dynamic>?;
          if (actionData != null) {
            final actionId = actionData['id'];
            dev.log('📥 [DataSync] QUEUED PROCESSING: Action $actionId ($timestamp)', name: 'SYNC');
            await processAction(actionData);
          } else {
            dev.log('[DataSync] action_sync message has no valid data field', name: 'SYNC');
          }
        } else if (message.containsKey('action_type')) {
          // Direct action format (no wrapper)
          dev.log('📥 [DataSync] QUEUED PROCESSING: Direct Action ($timestamp)', name: 'SYNC');
          await processAction(message);
        } else if (type == 'ping' || type == 'pong' || type == 'connection_established' || type == 'presence') {
          // Heartbeat / connection confirmation / presence - ignore in DataSync
        } else {
          dev.log('[DataSync] Unhandled WS message type: $type', name: 'SYNC');
        }
      } catch (e, stack) {
        dev.log('❌ [DataSync] Error in serial queue processing: $e', name: 'SYNC', error: e, stackTrace: stack);
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Entity handlers
  // ---------------------------------------------------------------------------

  Future<void> _handleIncident(String actionType, dynamic entityId, Map<String, dynamic>? entityData) async {
    if (actionType == 'delete') {
      final id = _parseInt(entityId);
      if (id != null) {
        await _syncRepo.deleteIncident(id);
        // Force the UI list to invalidate because pure Drift row-deletions 
        // sometimes don't propagate flawlessly through the Riverpod debouncer cascade.
        _ref.read(globalRefreshEventControllerProvider).add(null);
      }
      return;
    }

    if (entityData != null) {
      try {
        // CRITICAL FIX: To prevent UI overload and DB cascade storms, if this is an 'update'
        // action specifically for an incident, ONLY save the incident itself, but 
        // DO NOT save the nested boilerplate boiler_house or saved_locations.
        // We do this by stripping them out from the raw JSON before parsing.
        
        final cleanData = Map<String, dynamic>.from(entityData);
        cleanData.remove('boiler_house');
        cleanData.remove('affected_house_details');
        
        final incident = IncidentResponse.fromJson(cleanData);
        await _syncRepo.upsertIncidents([incident]);
      } catch (e) {
        dev.log('[DataSync] Failed to parse incident entity_data: $e', name: 'SYNC');
      }
    }
  }

  Future<void> _handleBoilerHouse(String actionType, dynamic entityId, Map<String, dynamic>? entityData) async {
    if (actionType == 'delete') {
      final id = _parseInt(entityId);
      if (id != null) await _syncRepo.deleteBoilerHouse(id);
      return;
    }

    if (entityData != null) {
      try {
        final bh = BoilerHouseResponse.fromJson(entityData);
        await _syncRepo.upsertBoilerHouses([bh]);
      } catch (e) {
        dev.log('[DataSync] Failed to parse boiler_house entity_data: $e', name: 'SYNC');
      }
    }
  }

  Future<void> _handleSavedLocation(String actionType, dynamic entityId, Map<String, dynamic>? entityData) async {
    if (actionType == 'delete') {
      final id = _parseInt(entityId);
      if (id != null) await _syncRepo.deleteSavedLocation(id);
      return;
    }

    if (entityData != null) {
      try {
        final loc = SavedLocationResponse.fromJson(entityData);
        await _syncRepo.upsertSavedLocations([loc]);
      } catch (e) {
        dev.log('[DataSync] Failed to parse saved_location entity_data: $e', name: 'SYNC');
      }
    }
  }

  Future<void> _handleComment(String actionType, dynamic entityId, Map<String, dynamic>? entityData) async {
    // We only care about creates/updates for now
    if (actionType == 'delete') return;

    if (entityData != null) {
      try {
        final comment = IncidentComment.fromJson(entityData);
        await _syncRepo.upsertComments(comment.incidentId, [comment]);
      } catch (e) {
        dev.log('[DataSync] Failed to parse comment entity_data: $e', name: 'SYNC');
      }
    }
  }

  Future<void> _handlePhoto(String actionType, String entityType, dynamic entityId, Map<String, dynamic>? entityData) async {
    dev.log('📸 [DataSync] _handlePhoto called: actionType=$actionType, entityType=$entityType, entityId=$entityId (${entityId.runtimeType}), hasData=${entityData != null}', name: 'SYNC');
    if (actionType == 'delete') {
      final id = _parseInt(entityId);
      dev.log('📸 [DataSync] Photo delete: parsed id=$id from raw=$entityId', name: 'SYNC');
      if (id != null) {
        switch (entityType) {
          case 'incident_photo':
            dev.log('📸 [DataSync] Deleting incident_photo backendId=$id', name: 'SYNC');
            await _syncRepo.deleteIncidentPhoto(id);
            // Force UI refresh so the photo disappears immediately
            _ref.read(globalRefreshEventControllerProvider).add(null);
            dev.log('📸 [DataSync] globalRefreshEvent fired after photo delete', name: 'SYNC');
            break;
          case 'saved_location_photo':
            dev.log('[DataSync] Deleting saved_location_photo id=$id', name: 'SYNC');
            await _syncRepo.deleteLocationPhoto(id);
            break;
          case 'boiler_house_photo':
            dev.log('[DataSync] Deleting boiler_house_photo id=$id', name: 'SYNC');
            await _syncRepo.deleteBoilerPhoto(id);
            break;
          default:
            dev.log('[DataSync] Unknown photo entity_type for delete: $entityType', name: 'SYNC');
        }
      } else {
        dev.log('⚠️ [DataSync] Could not parse photo entityId: $entityId', name: 'SYNC');
      }
    } else if (entityData != null) {
      // Handle create/update for photos
      try {
        final photoId = _parseInt(entityData['id']) ?? _parseInt(entityId) ?? 0;
        final parentId = _parseInt(entityData['entity_id']) ?? 0;
        final url = entityData['url'] as String? ?? '';
        final thumbnailUrl = entityData['thumbnail_url'] as String?;
        final createdAt = entityData['created_at'] as String?;

        if (entityType == 'incident_photo' && parentId > 0) {
          final photo = PhotoInfo(
            id: photoId,
            url: url,
            thumbnailUrl: thumbnailUrl,
            createdAt: createdAt,
          );
          await _syncRepo.upsertIncidentPhotos(parentId, [photo]);
          dev.log('[DataSync] Upserted incident_photo id=$photoId for incident=$parentId', name: 'SYNC');
        } else if (entityType == 'saved_location_photo') {
          dev.log('[DataSync] saved_location_photo create/update - handled via location sync', name: 'SYNC');
        } else if (entityType == 'boiler_house_photo') {
          dev.log('[DataSync] boiler_house_photo create/update - handled via boiler_house sync', name: 'SYNC');
        }
      } catch (e) {
        dev.log('[DataSync] Failed to upsert photo: $e', name: 'SYNC');
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Future<void> _trackActionId(dynamic actionId) async {
    final id = _parseInt(actionId);
    if (id != null) {
      if (id > _lastWSActionLogId) {
        _lastWSActionLogId = id;
        // Persist to DB
        await _syncRepo.updateSyncCursor('ws_sync_cursor', id);
      }
    }
  }

  int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  void dispose() {
    stop();
  }
}
