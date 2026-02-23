import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/boiler_house_models.dart';
import '../repositories/sync_repository.dart';
import 'base_api_service.dart';

final boilerHouseServiceProvider = Provider<BoilerHouseService>((ref) {
  final dio = ref.watch(dioProvider);
  final syncRepository = ref.watch(syncRepositoryProvider);
  return BoilerHouseService(dio, syncRepository);
});

class BoilerHouseService {
  final Dio _dio;
  final SyncRepository _syncRepository;

  BoilerHouseService(this._dio, this._syncRepository);

  Future<int> countBoilerHouses({bool useCache = true}) async {
    final response = await _dio.get('/boiler-houses/count', queryParameters: {'use_cache': useCache});
    return response.data as int;
  }

  Future<List<BoilerHouseResponse>> getAllBoilerHouses() async {
    final response = await _dio.get('/boiler-houses/');
    final boilerHouses = (response.data as List)
        .map((e) => BoilerHouseResponse.fromJson(e))
        .toList();
    
    // Cache to local DB
    await _syncRepository.upsertBoilerHouses(boilerHouses);
    
    return boilerHouses;
  }

  Future<BoilerHouseResponse> getBoilerHouse(int id) async {
    final response = await _dio.get('/boiler-houses/$id');
    final boilerHouse = BoilerHouseResponse.fromJson(response.data);
    
    // Cache to local DB
    await _syncRepository.upsertBoilerHouses([boilerHouse]);
    
    return boilerHouse;
  }

  Future<BoilerHouseResponse> createBoilerHouse(BoilerHouseCreate boilerHouse) async {
    final response = await _dio.post('/boiler-houses/', data: boilerHouse.toJson());
    return BoilerHouseResponse.fromJson(response.data);
  }

  Future<BoilerHouseResponse> updateBoilerHouse(int id, BoilerHouseUpdate update) async {
    final response = await _dio.put('/boiler-houses/$id', data: update.toJson());
    return BoilerHouseResponse.fromJson(response.data);
  }

  Future<void> deleteBoilerHouse(int id) async {
    await _dio.delete('/boiler-houses/$id');
  }
}
