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
    final result = BoilerHouseResponse.fromJson(response.data);
    
    // Cache to local DB so map UI updates immediately on this device
    await _syncRepository.upsertBoilerHouses([result]);
    
    return result;
  }

  Future<BoilerHouseResponse> updateBoilerHouse(int id, BoilerHouseUpdate update) async {
    final response = await _dio.put('/boiler-houses/$id', data: update.toJson());
    final result = BoilerHouseResponse.fromJson(response.data);
    
    // Cache to local DB so map UI updates immediately on this device
    await _syncRepository.upsertBoilerHouses([result]);
    
    return result;
  }

  Future<void> deleteBoilerHouse(int id) async {
    try {
      await _dio.delete('/boiler-houses/$id');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // Котельная уже удалена на сервере (например, с другого устройства)
        // Удаляем из локального кеша
        await _syncRepository.deleteBoilerHouse(id);
        return;
      }
      rethrow;
    }
    // Успешное удаление — очищаем локальный кеш
    await _syncRepository.deleteBoilerHouse(id);
  }

  /// Массовая смена начальника участка во всех котельных
  Future<ReassignManagerResult> reassignManager({
    required int oldManagerId,
    required int newManagerId,
    String? newSiteNumber,
  }) async {
    final response = await _dio.post('/boiler-houses/reassign-manager', data: {
      'old_manager_id': oldManagerId,
      'new_manager_id': newManagerId,
      if (newSiteNumber != null) 'new_site_number': newSiteNumber,
    });
    return ReassignManagerResult.fromJson(response.data);
  }
}

class ReassignManagerResult {
  final int updatedCount;
  final List<int>? updatedBoilerHouseIds;
  final String oldManager;
  final String newManager;
  final String? newSiteNumber;
  final String message;

  ReassignManagerResult({
    required this.updatedCount,
    this.updatedBoilerHouseIds,
    required this.oldManager,
    required this.newManager,
    this.newSiteNumber,
    required this.message,
  });

  factory ReassignManagerResult.fromJson(Map<String, dynamic> json) {
    return ReassignManagerResult(
      updatedCount: json['updated_count'] ?? 0,
      updatedBoilerHouseIds: (json['updated_boiler_house_ids'] as List?)?.cast<int>(),
      oldManager: json['old_manager'] ?? '',
      newManager: json['new_manager'] ?? '',
      newSiteNumber: json['new_site_number'],
      message: json['message'] ?? '',
    );
  }
}
