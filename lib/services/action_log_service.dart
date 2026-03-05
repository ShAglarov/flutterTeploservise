import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/action_log_models.dart';
import 'base_api_service.dart';

final actionLogServiceProvider = Provider<ActionLogService>((ref) {
  final dio = ref.watch(dioProvider);
  return ActionLogService(dio);
});

class ActionLogService {
  final Dio _dio;

  ActionLogService(this._dio);

  /// Fetch paginated action logs from the server.
  Future<List<ActionLogEntry>> getActionLogs({
    int limit = 50,
    int offset = 0,
    int? userId,
    String? entityType,
    String? actionType,
  }) async {
    final queryParams = <String, dynamic>{
      'limit': limit,
      'offset': offset,
    };
    if (userId != null) queryParams['user_id'] = userId;
    if (entityType != null) queryParams['entity_type'] = entityType;
    if (actionType != null) queryParams['action_type'] = actionType;

    final response = await _dio.get(
      '/action-logs/',
      queryParameters: queryParams,
    );
    return (response.data as List)
        .map((e) => ActionLogEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Fetch list of unique users that have action log entries.
  Future<List<ActionLogUser>> getActionLogUsers() async {
    final response = await _dio.get('/action-logs/users');
    return (response.data as List)
        .map((e) => ActionLogUser.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Ask the server to broadcast flush_audit_logs to all devices,
  /// so they upload their local logs.
  Future<void> requestFlush() async {
    await _dio.post('/action-logs/request-flush');
  }
}
