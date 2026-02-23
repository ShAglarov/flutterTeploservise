import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/incident_models.dart';
import 'base_api_service.dart';

final commentServiceProvider = Provider<CommentService>((ref) {
  final dio = ref.watch(dioProvider);
  return CommentService(dio);
});

class CommentService {
  final Dio _dio;

  CommentService(this._dio);

  Future<List<IncidentComment>> getComments(int incidentId) async {
    final response = await _dio.get('/incidents/$incidentId/comments/');
    return (response.data as List)
        .map((e) => IncidentComment.fromJson(e))
        .toList();
  }

  Future<IncidentComment> postComment(int incidentId, String text) async {
    final response = await _dio.post(
      '/incidents/$incidentId/comments/',
      data: {'text': text},
    );
    return IncidentComment.fromJson(response.data);
  }
}
