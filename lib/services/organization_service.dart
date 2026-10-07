import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/organization_models.dart';
import 'base_api_service.dart';

final organizationServiceProvider = Provider<OrganizationService>((ref) {
  final dio = ref.watch(dioProvider);
  return OrganizationService(dio);
});

/// Управление организациями. Все эндпоинты требуют is_superadmin на сервере.
class OrganizationService {
  final Dio _dio;

  OrganizationService(this._dio);

  Future<List<OrganizationResponse>> getAll({bool includeInactive = true}) async {
    final response = await _dio.get(
      '/organizations/',
      queryParameters: {'include_inactive': includeInactive},
    );
    return (response.data as List)
        .map((e) => OrganizationResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<OrganizationResponse> getOne(int id) async {
    final response = await _dio.get('/organizations/$id');
    return OrganizationResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<OrganizationResponse> create(OrganizationCreate data) async {
    final response = await _dio.post('/organizations/', data: data.toJson());
    return OrganizationResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<OrganizationResponse> update(int id, OrganizationUpdate data) async {
    final response = await _dio.patch('/organizations/$id', data: data.toJson());
    return OrganizationResponse.fromJson(response.data as Map<String, dynamic>);
  }
}
