import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/activity_models.dart';
import 'base_api_service.dart';
import 'dart:developer' as dev;

final activityServiceProvider = Provider<ActivityService>((ref) {
  final dio = ref.watch(dioProvider);
  return ActivityService(dio);
});

class ActivityService {
  final Dio _dio;

  ActivityService(this._dio);

  Future<List<IncidentActivity>> getActivities(int incidentId) async {
    try {
      final response = await _dio.get(
        '/action-logs/',
        queryParameters: {
          'entity_type': 'incident',
          'entity_id': incidentId,
          'limit': 100,
        },
      );
      return (response.data as List)
          .map((e) => IncidentActivity.fromJson(e))
          .toList();
    } catch (e, stack) {
      dev.log('Failed to load activity logs: $e\n$stack', name: 'ActivityService');
      return [];
    }
  }
}
