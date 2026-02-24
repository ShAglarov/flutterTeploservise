import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/activity_models.dart';
import '../services/activity_service.dart';
import '../services/realtime_service.dart';
import 'dart:developer' as dev;

part 'activity_providers.g.dart';

@riverpod
class IncidentActivityFeed extends _$IncidentActivityFeed {
  @override
  Future<List<IncidentActivity>> build(int incidentId) async {
    final activityService = ref.watch(activityServiceProvider);
    final initialActivities = await activityService.getActivities(incidentId);

    final realtimeService = ref.watch(realtimeServiceProvider);
    
    // Auto-connect when this provider is active
    realtimeService.connect();

    final subscription = realtimeService.messages.listen((message) {
      _handleRealtimeMessage(message);
    });

    ref.onDispose(() {
      subscription.cancel();
    });

    // Sort by timestamp descending (newest first)
    initialActivities.sort((a, b) {
      final aDate = DateTime.tryParse(a.timestamp) ?? DateTime.now();
      final bDate = DateTime.tryParse(b.timestamp) ?? DateTime.now();
      return bDate.compareTo(aDate);
    });

    return initialActivities;
  }

  void _handleRealtimeMessage(Map<String, dynamic> message) {
    var data = message;
    if (message['type'] == 'action_sync' && message['data'] is Map<String, dynamic>) {
      data = message['data'] as Map<String, dynamic>;
    }

    final entityType = data['entity_type'];
    final actionType = data['action_type'];
    
    // Check if this action log belongs to our incident
    bool isRelevantLog = false;
    if (entityType == 'incident') {
      isRelevantLog = true;
    } else if (data['entity_id'] == incidentId || data['entity_id'] == incidentId.toString()) {
      isRelevantLog = true;
    }

    if (isRelevantLog) {
      try {
        final activity = IncidentActivity.fromJson(data);
        if (activity.entityId == incidentId || activity.entityId == incidentId.toString() || activity.entityType == 'incident') {
           _addActivity(activity);
        }
      } catch (e) {
        // If it's partial data or not matching ActionLogResponse perfectly
        dev.log('ActivityProvider: Failed to parse activity from WS: $e', name: 'WS');
      }
    }
  }

  void _addActivity(IncidentActivity activity) {
    state.whenData((activities) {
      // Deduplicate
      if (activities.any((a) => a.id == activity.id)) return;
      
      final updatedList = [activity, ...activities];
      updatedList.sort((a, b) {
        final aDate = DateTime.tryParse(a.timestamp) ?? DateTime.now();
        final bDate = DateTime.tryParse(b.timestamp) ?? DateTime.now();
        return bDate.compareTo(aDate);
      });
      state = AsyncData(updatedList);
    });
  }
}
