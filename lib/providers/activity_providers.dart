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

    // Sort by createdAt descending (newest first)
    initialActivities.sort((a, b) {
      final aDate = DateTime.tryParse(a.createdAt) ?? DateTime.now();
      final bDate = DateTime.tryParse(b.createdAt) ?? DateTime.now();
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
    
    // We want to capture changes to the incident itself and its comments/status
    if (entityType == 'action_log' || entityType == 'incident' || entityType == 'status') {
      final entityData = data['entity_data'];
      if (entityData != null) {
        try {
          final activity = IncidentActivity.fromJson(entityData);
          if (activity.incidentId == incidentId) {
            _addActivity(activity);
          }
        } catch (e) {
          // If parsing fails as IncidentActivity, we might need a custom mapping
          dev.log('ActivityProvider: Failed to parse activity from WS: $e', name: 'WS');
        }
      }
    }
  }

  void _addActivity(IncidentActivity activity) {
    state.whenData((activities) {
      // Deduplicate
      if (activities.any((a) => a.id == activity.id)) return;
      
      final updatedList = [activity, ...activities];
      updatedList.sort((a, b) {
        final aDate = DateTime.tryParse(a.createdAt) ?? DateTime.now();
        final bDate = DateTime.tryParse(b.createdAt) ?? DateTime.now();
        return bDate.compareTo(aDate);
      });
      state = AsyncData(updatedList);
    });
  }
}
