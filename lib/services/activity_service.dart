import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/activity_models.dart';
import 'base_api_service.dart';

final activityServiceProvider = Provider<ActivityService>((ref) {
  final dio = ref.watch(dioProvider);
  return ActivityService(dio);
});

class ActivityService {
  final Dio _dio;

  ActivityService(this._dio);

  Future<List<IncidentActivity>> getActivities(int incidentId) async {
    try {
      final response = await _dio.get('/incidents/$incidentId/history/');
      return (response.data as List)
          .map((e) => IncidentActivity.fromJson(e))
          .toList();
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        try {
          // Fallback to /activity/
          final response2 = await _dio.get('/incidents/$incidentId/activity/');
          return (response2.data as List)
              .map((e) => IncidentActivity.fromJson(e))
              .toList();
        } catch (e2) {
          try {
            // Fallback to /logs/
            final response3 = await _dio.get('/incidents/$incidentId/logs/');
            return (response3.data as List)
                .map((e) => IncidentActivity.fromJson(e))
                .toList();
          } catch (e3) {
            // Give up and return empty list or rethrow
            return [];
          }
        }
      }
      return [];
    }
  }
}
