import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/incident_models.dart';
import '../repositories/sync_repository.dart';
import 'base_api_service.dart';

final incidentServiceProvider = Provider<IncidentService>((ref) {
  final dio = ref.watch(dioProvider);
  final syncRepository = ref.watch(syncRepositoryProvider);
  return IncidentService(dio, syncRepository);
});

class IncidentService {
  final Dio _dio;
  final SyncRepository _syncRepository;

  IncidentService(this._dio, this._syncRepository);

  Future<List<IncidentResponse>> getAllIncidents() async {
    final response = await _dio.get('/incidents/');
    final incidents = (response.data as List)
        .map((e) => IncidentResponse.fromJson(e))
        .toList();
    
    // Cache to local DB
    await _syncRepository.upsertIncidents(incidents);
    
    return incidents;
  }

  Future<IncidentResponse> getIncident(int id) async {
    final response = await _dio.get('/incidents/$id');
    final incident = IncidentResponse.fromJson(response.data);
    
    // Cache to local DB
    await _syncRepository.upsertIncidents([incident]);
    
    return incident;
  }

  Future<IncidentResponse> createIncident(IncidentCreate incident) async {
    final response = await _dio.post(
      '/incidents/',
      data: incident.toJson(),
    );
    final res = IncidentResponse.fromJson(response.data);
    await _syncRepository.upsertIncidents([res]);
    return res;
  }

  Future<IncidentResponse> updateIncident(int id, IncidentUpdate update) async {
    final response = await _dio.put(
      '/incidents/$id',
      data: update.toJson(),
    );
    final incident = IncidentResponse.fromJson(response.data);
    await _syncRepository.upsertIncidents([incident]);
    return incident;
  }

  Future<void> deleteIncident(int id) async {
    await _dio.delete('/incidents/$id');
    await _syncRepository.deleteIncident(id);
  }

  Future<List<IncidentResponse>> batchUpdateIncidents(List<IncidentUpdate> updates) async {
    final response = await _dio.post(
      '/incidents/batch-update',
      data: updates.map((e) => e.toJson()).toList(),
    );
    final incidents = (response.data as List)
        .map((e) => IncidentResponse.fromJson(e))
        .toList();
    await _syncRepository.upsertIncidents(incidents);
    return incidents;
  }

  Future<List<IncidentResponse>> batchCreateIncidents(List<IncidentCreate> incidents) async {
    final response = await _dio.post(
      '/incidents/batch-create',
      data: incidents.map((e) => e.toJson()).toList(),
    );
    final resultList = (response.data as List)
        .map((e) => IncidentResponse.fromJson(e))
        .toList();
    await _syncRepository.upsertIncidents(resultList);
    return resultList;
  }

  Future<void> uploadIncidentPhoto(int incidentId, String filePath) async {
    debugPrint('[Service] Uploading photo for incident $incidentId from $filePath');
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });
      
      final response = await _dio.post(
        '/incidents/$incidentId/photos/',
        data: formData,
      );
      debugPrint('[Service] Upload response: ${response.statusCode} - ${response.data}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final photoInfo = PhotoInfo.fromJson(response.data);
        await _syncRepository.upsertIncidentPhotos(incidentId, [photoInfo]);
        debugPrint('[Service] Local DB updated with new photo');
      }
    } catch (e, stack) {
      debugPrint('[Service] Upload error: $e\n$stack');
      rethrow;
    }
  }

  Future<void> deleteIncidentPhoto(int incidentId, int photoId) async {
    try {
      await _dio.delete(
        '/incidents/$incidentId/photos/$photoId',
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // Photo was already deleted on the server (e.g. by another user).
        // We still need to clean up the local DB below.
        debugPrint('[Service] Photo $photoId already deleted on server (404), cleaning local DB');
      } else {
        rethrow;
      }
    }
    await _syncRepository.deleteIncidentPhoto(photoId);
  }
}
