import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/incident_models.dart';
import '../services/comment_service.dart';
import '../services/realtime_service.dart';
import 'dart:developer' as dev;

part 'chat_providers.g.dart';

@riverpod
class IncidentChat extends _$IncidentChat {
  @override
  Future<List<IncidentComment>> build(int incidentId) async {
    // 1. Fetch initial comments
    final commentService = ref.watch(commentServiceProvider);
    final initialComments = await commentService.getComments(incidentId);

    // 2. Listen to real-time updates
    final realtimeService = ref.watch(realtimeServiceProvider);
    
    // Auto-connect when this provider is active
    realtimeService.connect();

    final subscription = realtimeService.messages.listen((message) {
      _handleRealtimeMessage(message);
    });

    ref.onDispose(() {
      subscription.cancel();
    });

    return initialComments;
  }

  void _handleRealtimeMessage(Map<String, dynamic> message) {
    var data = message;
    if (message['type'] == 'action_sync' && message['data'] is Map<String, dynamic>) {
      data = message['data'] as Map<String, dynamic>;
    }

    // Check if message is for this incident and is a comment
    final entityType = data['entity_type'];
    final actionType = data['action_type'];
    
    if (entityType == 'incident_comment' || entityType == 'comment') {
      final entityData = data['entity_data'];
      if (entityData != null) {
        try {
          final comment = IncidentComment.fromJson(entityData);
          if (comment.incidentId == incidentId) {
            _addComment(comment);
          }
        } catch (e) {
          dev.log('ChatProvider: Failed to parse comment from WS: $e', name: 'WS');
        }
      }
    } else if (entityType == 'action_log' || entityType == 'incident') {
      // Potentially handle system messages or incident updates
      // The backend might send action logs that we want to show in chat
    }
  }

  void _addComment(IncidentComment comment) {
    state.whenData((comments) {
      // Deduplicate
      if (comments.any((c) => c.id == comment.id)) return;
      
      state = AsyncData([...comments, comment]);
    });
  }

  Future<void> sendComment(String text) async {
    final commentService = ref.read(commentServiceProvider);
    
    // Note: In a full implementation, we'd add an optimistic comment here.
    // For now, let's just send and wait for the response or WS update.
    try {
      final newComment = await commentService.postComment(incidentId, text);
      _addComment(newComment);
    } catch (e) {
      dev.log('ChatProvider: Failed to send comment: $e', name: 'Chat');
      rethrow;
    }
  }
}
