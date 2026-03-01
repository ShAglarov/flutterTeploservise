import 'dart:async';
import 'dart:developer' as dev;
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/sync_repository.dart';
import 'base_api_service.dart';
import 'data_sync_service.dart';
import 'device_id_service.dart';
import 'realtime_service.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  final dio = ref.watch(dioProvider);
  final syncRepo = ref.watch(syncRepositoryProvider);
  final dataSyncService = ref.watch(dataSyncServiceProvider);
  final deviceService = ref.watch(deviceIdServiceProvider);
  final realtimeService = ref.watch(realtimeServiceProvider);
  final service = SyncService(dio, syncRepo, dataSyncService, deviceService, realtimeService);
  
  service.start();
  ref.onDispose(() => service.dispose());
  return service;
});

/// HTTP-based incremental sync using the `GET /sync/incremental` endpoint.
/// Fetches action_log entries since the last known cursor and processes them
/// through DataSyncService.
class SyncService {
  final Dio _dio;
  final SyncRepository _syncRepo;
  final DataSyncService _dataSyncService;
  final DeviceIdService _deviceService;
  final RealtimeService _realtimeService;

  bool _isSyncing = false;
  static const String _cursorKey = 'global_sync_cursor';
  
  StreamSubscription<bool>? _connectionSub;
  DateTime? _lastSyncTriggeredAt;
  static const _syncCooldown = Duration(seconds: 5);

  SyncService(this._dio, this._syncRepo, this._dataSyncService, this._deviceService, this._realtimeService);

  void start() {
    _connectionSub = _realtimeService.connectionState.listen((isConnected) {
      if (isConnected) {
        final now = DateTime.now();
        if (_lastSyncTriggeredAt != null && now.difference(_lastSyncTriggeredAt!) < _syncCooldown) {
          dev.log('[SyncService] Skipping sync — cooldown active (${now.difference(_lastSyncTriggeredAt!).inSeconds}s since last)', name: 'SYNC');
          return;
        }
        _lastSyncTriggeredAt = now;
        dev.log('🔄 [SyncService] WebSocket reconnected. Triaging background sync recovery.', name: 'SYNC');
        incrementalSync();
      }
    });
  }

  void dispose() {
    _connectionSub?.cancel();
  }

  /// Run a full incremental sync from the server.
  /// Handles pagination via `has_more`.
  Future<void> incrementalSync() async {
    if (_isSyncing) {
      dev.log('[SyncService] Already syncing, skipping', name: 'SYNC');
      return;
    }
    _isSyncing = true;

    try {
      final deviceId = await _deviceService.getDeviceId();
      var cursor = await _syncRepo.getSyncCursor(_cursorKey);
      dev.log('📥 [SyncService] Starting incremental sync from cursor=$cursor', name: 'SYNC');

      bool hasMore = true;
      int totalProcessed = 0;

      while (hasMore) {
        final queryParams = <String, dynamic>{
          'device_id': deviceId,
        };
        if (cursor != null && cursor > 0) {
          queryParams['last_sync_action_id'] = cursor;
        }

        final response = await _dio.get('/sync/incremental', queryParameters: queryParams);
        final data = response.data as Map<String, dynamic>;

        final actions = data['actions'] as List<dynamic>? ?? [];
        hasMore = data['has_more'] as bool? ?? false;
        final nextSyncId = data['next_sync_id'];

        dev.log('[SyncService] Received ${actions.length} actions, hasMore=$hasMore, nextSyncId=$nextSyncId', name: 'SYNC');

        for (final action in actions) {
          if (action is Map<String, dynamic>) {
            await _dataSyncService.processAction(action);
            totalProcessed++;
          }
        }

        // Update cursor
        final newCursor = _parseInt(nextSyncId);
        if (newCursor != null && newCursor > 0) {
          cursor = newCursor;
          await _syncRepo.updateSyncCursor(_cursorKey, newCursor);
        }
      }

      dev.log('✅ [SyncService] Incremental sync complete: processed $totalProcessed actions, cursor=$cursor', name: 'SYNC');
    } on DioException catch (e) {
      dev.log('❌ [SyncService] Incremental sync HTTP error: ${e.response?.statusCode} ${e.message}', name: 'SYNC');
    } catch (e) {
      dev.log('❌ [SyncService] Incremental sync failed: $e', name: 'SYNC');
    } finally {
      _isSyncing = false;
    }
  }

  /// Check if there's a gap between what WS reported and our local cursor.
  /// If yes, trigger an incremental sync to fill the gap.
  Future<void> checkAndFillGap(int? lastWSActionLogId) async {
    if (lastWSActionLogId == null) return;

    final localCursor = await _syncRepo.getSyncCursor(_cursorKey);
    if (localCursor == null || lastWSActionLogId > localCursor) {
      final gap = (localCursor ?? 0) > 0 ? lastWSActionLogId - localCursor! : lastWSActionLogId;
      dev.log('⚠️ [SyncService] Gap detected! Local cursor=$localCursor, WS last=$lastWSActionLogId (gap=$gap actions)', name: 'SYNC');
      await incrementalSync();
    }
  }

  int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}
