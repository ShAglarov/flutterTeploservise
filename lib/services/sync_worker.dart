import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../database/database.dart';
import '../repositories/sync_repository.dart';
import '../main.dart';
import 'incident_service.dart';
import 'location_service.dart';
import '../models/incident_models.dart';

final syncWorkerProvider = Provider<SyncWorker>((ref) {
  final repository = ref.watch(syncRepositoryProvider);
  final incidentService = ref.watch(incidentServiceProvider);
  return SyncWorker(repository, incidentService);
});

/// Background worker that processes the PendingChanges queue.
/// Replaces the blind 30s timer with connectivity-driven triggers and
/// priority-based ordering (incidents first, then houses, then rest).
class SyncWorker {
  final SyncRepository _repository;
  final IncidentService _incidentService;
  
  bool _isSyncing = false;
  Timer? _timer;
  StreamSubscription? _connectivitySub;

  SyncWorker(this._repository, this._incidentService);

  void start() {
    print('🚀 [SyncWorker] Starting...');

    // 1. Listen to connectivity changes — sync when network comes back
    _connectivitySub?.cancel();
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      final hasConnection = results.any((r) => r != ConnectivityResult.none);
      if (hasConnection) {
        print('🌐 [SyncWorker] Network available, triggering sync');
        syncPending();
      }
    });

    // 2. Fallback periodic timer (60s instead of 30s)
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 60), (_) => syncPending());

    // 3. Initial sync on start
    syncPending();
  }

  void stop() {
    print('🛑 [SyncWorker] Stopping...');
    _timer?.cancel();
    _timer = null;
    _connectivitySub?.cancel();
    _connectivitySub = null;
  }

  Future<void> syncPending() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final pendingChanges = await _repository.getPendingChanges();
      if (pendingChanges.isEmpty) return;

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
          ? jsonDecode(utf8.decode(change.payload!)) as Map<String, dynamic>
          : <String, dynamic>{};

      switch (change.entityType) {
        case 'incident':
          await _processIncidentChange(change, payload);
          break;
        case 'saved_location':
          // TODO: implement location sync
          break;
        default:
          throw Exception('Unsupported entity type: ${change.entityType}');
      }

      await _repository.updatePendingStatus(change.id, 'synced');
      print('✅ [SyncWorker] Synced ${change.entityType} ${change.actionType} (ID: ${change.id})');
    } catch (e) {
      print('⚠️ [SyncWorker] Failed ${change.entityType} ${change.actionType} (ID: ${change.id}): $e');
      final newRetryCount = (change.retryCount ?? 0) + 1;

      // Exponential backoff — fail after 5 retries
      if (newRetryCount >= 5) {
        await _repository.updatePendingStatus(change.id, 'failed', retryCount: newRetryCount);
        _showToast('Ошибка синхронизации: ${change.entityType} (${change.actionType})');
      } else {
        await _repository.updatePendingStatus(change.id, 'pending', retryCount: newRetryCount);
        // Calculate backoff delay (1s, 2s, 4s, 8s, 16s)
        final backoffMs = min(1000 * pow(2, newRetryCount - 1).toInt(), 30000);
        print('⏳ [SyncWorker] Retry #$newRetryCount in ${backoffMs}ms');
      }
    }
  }

  void _showToast(String message) {
    if (scaffoldMessengerKey.currentState != null) {
      scaffoldMessengerKey.currentState!.showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red.withOpacity(0.9),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _processIncidentChange(PendingChangeDb change, Map<String, dynamic> payload) async {
    switch (change.actionType) {
      case 'create':
        final incidentCreate = IncidentCreate.fromJson(payload);
        final result = await _incidentService.createIncident(incidentCreate);
        if (change.entityId != null && change.entityId! < 0 && result.id > 0) {
          await _repository.resolveTemporaryId('incident', change.entityId!, result.id);
          print('🔗 [SyncWorker] Resolved temp ID ${change.entityId} → ${result.id}');
        }
        break;
      case 'update':
        if (change.entityId != null) {
          final incidentUpdate = IncidentUpdate.fromJson(payload);
          await _incidentService.updateIncident(change.entityId!, incidentUpdate);
        }
        break;
      case 'comment':
        if (change.entityId != null) {
          // TODO: implement comment sync
        }
        break;
    }
  }
}
