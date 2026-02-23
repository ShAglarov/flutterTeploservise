import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/management_company_models.dart';
import 'base_api_service.dart';

final managementCompanyServiceProvider = Provider<ManagementCompanyService>((ref) {
  final dio = ref.watch(dioProvider);
  return ManagementCompanyService(dio);
});

class ManagementCompanyService {
  final Dio _dio;

  ManagementCompanyService(this._dio);

  Future<int> countManagementCompanies({bool useCache = true}) async {
    final response = await _dio.get('/management-companies/count', queryParameters: {'use_cache': useCache});
    return response.data as int;
  }

  Future<List<ManagementCompanyResponse>> getAllManagementCompanies() async {
    final response = await _dio.get('/management-companies/');
    return (response.data as List)
        .map((e) => ManagementCompanyResponse.fromJson(e))
        .toList();
  }

  Future<ManagementCompanyResponse> getManagementCompany(String id) async {
    final response = await _dio.get('/management-companies/$id');
    return ManagementCompanyResponse.fromJson(response.data);
  }

  Future<ManagementCompanyResponse> createManagementCompany(ManagementCompanyCreate company) async {
    final response = await _dio.post('/management-companies/', data: company.toJson());
    return ManagementCompanyResponse.fromJson(response.data);
  }

  Future<ManagementCompanyResponse> updateManagementCompany(String id, ManagementCompanyUpdate update) async {
    final response = await _dio.put('/management-companies/$id', data: update.toJson());
    return ManagementCompanyResponse.fromJson(response.data);
  }

  Future<void> deleteManagementCompany(String id) async {
    await _dio.delete('/management-companies/$id');
  }
}
