import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart';
import '../repositories/sync_repository.dart';
import 'incident_service.dart';
import 'location_service.dart';
import '../models/incident_models.dart';

final syncWorkerProvider = Provider<SyncWorker>((ref) {
  final repository = ref.watch(syncRepositoryProvider);
  final incidentService = ref.watch(incidentServiceProvider);
  // final locationService = ref.watch(locationServiceProvider);
  return SyncWorker(repository, incidentService, null);
});

class SyncWorker {
  final SyncRepository _repository;
  final IncidentService _incidentService;
  final dynamic _locationService;
  
  bool _isSyncing = false;
  Timer? _timer;

  SyncWorker(this._repository, this._incidentService, this._locationService);

  void start() {
    print('🚀 [SyncWorker] Starting...');
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => syncPending());
    syncPending(); // Initial sync
  }

  void stop() {
    print('🛑 [SyncWorker] Stopping...');
    _timer?.cancel();
    _timer = null;
  }

  Future<void> syncPending() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final pendingChanges = await _repository.getPendingChanges();
      if (pendingChanges.isEmpty) {
        // print('💤 [SyncWorker] No pending changes');
        return;
      }

      print('🔄 [SyncWorker] Processing ${pendingChanges.length} pending changes');

      for (final change in pendingChanges) {
        await _processChange(change);
      }
    } catch (e) {
      print('❌ [SyncWorker] Sync loop failed: $e');
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _processChange(PendingChangeDb change) async {
    try {
      await _repository.updatePendingStatus(change.id, 'syncing');

      final payload = change.payload != null 
          ? jsonDecode(change.payload!) as Map<String, dynamic>
          : <String, dynamic>{};

      switch (change.entityType) {
        case 'incident':
          await _processIncidentChange(change, payload);
          break;
        case 'saved_location':
          // await _processLocationChange(change, payload);
          break;
        default:
          throw Exception('Unsupported entity type: ${change.entityType}');
      }

      await _repository.updatePendingStatus(change.id, 'synced');
      print('✅ [SyncWorker] Successfully synced ${change.entityType} ${change.actionType} (ID: ${change.id})');
    } catch (e) {
      print('⚠️ [SyncWorker] Failed to sync ${change.entityType} ${change.actionType} (ID: ${change.id}): $e');
      final newRetryCount = change.retryCount + 1;
      final newStatus = newRetryCount >= 5 ? 'failed' : 'pending';
      await _repository.updatePendingStatus(change.id, newStatus, retryCount: newRetryCount);
    }
  }

  Future<void> _processIncidentChange(PendingChangeDb change, Map<String, dynamic> payload) async {
    switch (change.actionType) {
      case 'create':
        final incidentCreate = IncidentCreate.fromJson(payload);
        final result = await _incidentService.createIncident(incidentCreate);
        // After successful create, we should ideally update the local DB with the new backend ID
        // and delete any "stub" or local version of this incident.
        // For simplicity, we just mark the change as synced for now.
        break;
      case 'update':
        if (change.entityId != null) {
          final incidentUpdate = IncidentUpdate.fromJson(payload);
          await _incidentService.updateIncident(change.entityId!, incidentUpdate);
        }
        break;
      case 'comment':
        if (change.entityId != null) {
          // Assuming payload has 'text'
          // await _incidentService.addComment(change.entityId!, payload['text']);
        }
        break;
    }
  }
}
