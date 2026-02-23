import 'package:dio/dio.dart';
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
    return IncidentResponse.fromJson(response.data);
  }

  Future<IncidentResponse> updateIncident(int id, IncidentUpdate update) async {
    final response = await _dio.put(
      '/incidents/$id',
      data: update.toJson(),
    );
    return IncidentResponse.fromJson(response.data);
  }

  Future<void> deleteIncident(int id) async {
    await _dio.delete('/incidents/$id');
  }

  Future<List<IncidentResponse>> batchUpdateIncidents(List<IncidentUpdate> updates) async {
    final response = await _dio.post(
      '/incidents/batch-update',
      data: updates.map((e) => e.toJson()).toList(),
    );
    return (response.data as List)
        .map((e) => IncidentResponse.fromJson(e))
        .toList();
  }

  Future<List<IncidentResponse>> batchCreateIncidents(List<IncidentCreate> incidents) async {
    final response = await _dio.post(
      '/incidents/batch-create',
      data: incidents.map((e) => e.toJson()).toList(),
    );
    return (response.data as List)
        .map((e) => IncidentResponse.fromJson(e))
        .toList();
  }
}
