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

final dataSyncServiceProvider = Provider<DataSyncService>((ref) {
  final syncRepo = ref.watch(syncRepositoryProvider);
  final realtimeService = ref.watch(realtimeServiceProvider);
  final deviceService = ref.watch(deviceIdServiceProvider);
  return DataSyncService(syncRepo, realtimeService, deviceService);
});

/// Processes incoming WebSocket `action_sync` messages and applies them to the
/// local Drift database. This is the "incoming mail" handler described in the
/// documentation (DataSyncService / SyncCoordinator).
class DataSyncService {
  final SyncRepository _syncRepo;
  final RealtimeService _realtimeService;
  final DeviceIdService _deviceService;

  StreamSubscription? _messageSubscription;
  String? _myDeviceId;

  /// Tracks the highest action_log ID received via WebSocket.
  /// Used for gap detection on reconnect.
  int? lastWSActionLogId;

  DataSyncService(this._syncRepo, this._realtimeService, this._deviceService);

  Future<void> start() async {
    _myDeviceId = await _deviceService.getDeviceId();
    dev.log('[DataSync] Starting, deviceId=$_myDeviceId', name: 'SYNC');

    _messageSubscription?.cancel();
    _messageSubscription = _realtimeService.messages.listen(
      _handleMessage,
      onError: (e) => dev.log('[DataSync] Stream error: $e', name: 'SYNC'),
    );
  }

  void stop() {
    _messageSubscription?.cancel();
    _messageSubscription = null;
  }

  /// Process a single action (from WS or from incremental sync).
  /// Returns true if the action was applied successfully.
  Future<bool> processAction(Map<String, dynamic> action) async {
    final actionType = (action['action_type'] as String?)?.toLowerCase();
    final entityType = (action['entity_type'] as String?)?.toLowerCase();
    final entityIdRaw = action['entity_id'];
    final actionId = action['id'];
    final deviceId = action['device_id'] as String?;
    final entityData = action['entity_data'] as Map<String, dynamic>?;

    if (actionType == null || entityType == null) {
      dev.log('[DataSync] Skipping malformed action: missing type fields', name: 'SYNC');
      return false;
    }

    // Echo suppression: skip actions originating from this device
    if (deviceId != null && deviceId == _myDeviceId) {
      dev.log('[DataSync] Echo suppressed: action from own device', name: 'SYNC');
      // Still track the actionId for cursor
      _trackActionId(actionId);
      return true;
    }

    try {
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

      _trackActionId(actionId);
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
    // The server sends: {"type": "action_sync", "data": {...action fields...}, "timestamp": "..."}
    final type = message['type'] as String?;

    if (type == 'action_sync') {
      // Extract the nested action data
      final data = message['data'];
      if (data is Map<String, dynamic>) {
        processAction(data);
      } else {
        dev.log('[DataSync] action_sync message has no valid data field', name: 'SYNC');
      }
    } else if (message.containsKey('action_type')) {
      // Direct action format (no wrapper)
      processAction(message);
    } else if (type == 'ping' || type == 'connection_established') {
      // Heartbeat / connection confirmation - ignore
    } else {
      dev.log('[DataSync] Unhandled WS message type: $type', name: 'SYNC');
    }
  }

  // ---------------------------------------------------------------------------
  // Entity handlers
  // ---------------------------------------------------------------------------

  Future<void> _handleIncident(String actionType, dynamic entityId, Map<String, dynamic>? entityData) async {
    if (actionType == 'delete') {
      final id = _parseInt(entityId);
      if (id != null) await _syncRepo.deleteIncident(id);
      return;
    }

    // create / update — upsert if we have entity_data
    if (entityData != null) {
      try {
        final incident = IncidentResponse.fromJson(entityData);
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

  Future<void> _handlePhoto(String actionType, String entityType, dynamic entityId, Map<String, dynamic>? entityData) async {
    // For now, photos are handled when parent entities refresh.
    // A more complete implementation would upsert/delete individual photos.
    dev.log('[DataSync] Photo action: $actionType $entityType id=$entityId', name: 'SYNC');
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  void _trackActionId(dynamic actionId) {
    final id = _parseInt(actionId);
    if (id != null) {
      if (lastWSActionLogId == null || id > lastWSActionLogId!) {
        lastWSActionLogId = id;
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
