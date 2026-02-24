import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/location_models.dart';
import '../models/incident_models.dart';
import '../repositories/sync_repository.dart';
import 'base_api_service.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  final dio = ref.watch(dioProvider);
  final syncRepository = ref.watch(syncRepositoryProvider);
  return LocationService(dio, syncRepository);
});

class LocationService {
  final Dio _dio;
  final SyncRepository _syncRepository;

  LocationService(this._dio, this._syncRepository);

  // MARK: - Saved Location Methods

  Future<int> countSavedLocations({bool useCache = true}) async {
    final response = await _dio.get('/locations/count', queryParameters: {'use_cache': useCache});
    return response.data as int;
  }

  Future<List<SavedLocationResponse>> getAllSavedLocations({bool forceRefresh = false}) async {
    final response = await _dio.get('/locations/', queryParameters: {'force_refresh': forceRefresh});
    final locations = (response.data as List)
        .map((e) => SavedLocationResponse.fromJson(e))
        .toList();
    
    // Cache to local DB
    await _syncRepository.upsertSavedLocations(locations);
    
    return locations;
  }

  Future<SavedLocationResponse> getSavedLocation(int id) async {
    final response = await _dio.get('/locations/$id');
    final location = SavedLocationResponse.fromJson(response.data);
    
    // Cache to local DB
    await _syncRepository.upsertSavedLocations([location]);
    
    return location;
  }

  Future<SavedLocationResponse> getSavedLocationByUUID(String uuid) async {
    final response = await _dio.get('/locations/uuid/$uuid');
    return SavedLocationResponse.fromJson(response.data);
  }

  Future<SavedLocationResponse> createSavedLocation(SavedLocationCreate location) async {
    final response = await _dio.post('/locations/', data: location.toJson());
    return SavedLocationResponse.fromJson(response.data);
  }

  Future<SavedLocationResponse> updateSavedLocation(int id, SavedLocationUpdate update) async {
    final response = await _dio.put('/locations/$id', data: update.toJson());
    return SavedLocationResponse.fromJson(response.data);
  }

  Future<void> deleteSavedLocation(int id) async {
    await _dio.delete('/locations/$id');
  }

  Future<PhotoInfo> uploadLocationPhoto(int locationId, String filePath) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });

    final response = await _dio.post(
      '/locations/$locationId/photos/',
      data: formData,
    );
    final photo = PhotoInfo.fromJson(response.data);
    
    // Refresh the location in local DB to include new photo
    await getSavedLocation(locationId);
    
    return photo;
  }

  Future<void> deleteLocationPhoto(int locationId, int photoId) async {
    await _dio.delete(
      '/locations/$locationId/photos/$photoId',
    );
    
    // Update local DB
    await _syncRepository.deleteLocationPhoto(photoId);
  }

  // MARK: - Account Methods

  Future<int> countAccounts({int? locationId, bool useCache = true}) async {
    final response = await _dio.get('/accounts/count', queryParameters: {
      'location_id': locationId,
      'use_cache': useCache,
    });
    return response.data as int;
  }

  Future<AccountResponse?> lookupAccount(int locationId, String accountNumber) async {
    try {
      final response = await _dio.get('/accounts/lookup', queryParameters: {
        'location_id': locationId,
        'account_number': accountNumber,
      });
      return AccountResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  Future<List<AccountResponse>> getAccounts({int? locationId}) async {
    final response = await _dio.get('/accounts/', queryParameters: {
      'location_id': locationId,
    });
    return (response.data as List)
        .map((e) => AccountResponse.fromJson(e))
        .toList();
  }

  Future<AccountResponse> getAccount(int id) async {
    final response = await _dio.get('/accounts/$id');
    return AccountResponse.fromJson(response.data);
  }

  Future<AccountResponse> createAccount(AccountCreate account) async {
    final response = await _dio.post('/accounts/', data: account.toJson());
    return AccountResponse.fromJson(response.data);
  }

  Future<AccountResponse> updateAccount(int id, AccountUpdate update) async {
    final response = await _dio.put('/accounts/$id', data: update.toJson());
    return AccountResponse.fromJson(response.data);
  }

  Future<void> deleteAccount(int id) async {
    await _dio.delete('/accounts/$id');
  }

  // MARK: - Batch Methods

  Future<List<SavedLocationResponse>> batchUpdateSavedLocations(List<SavedLocationUpdate> updates) async {
    final response = await _dio.post(
      '/locations/batch-update',
      data: updates.map((e) => e.toJson()).toList(),
    );
    return (response.data as List)
        .map((e) => SavedLocationResponse.fromJson(e))
        .toList();
  }

  Future<List<SavedLocationResponse>> batchCreateSavedLocations(List<SavedLocationCreate> locations) async {
    final response = await _dio.post(
      '/locations/batch-create',
      data: locations.map((e) => e.toJson()).toList(),
    );
    return (response.data as List)
        .map((e) => SavedLocationResponse.fromJson(e))
        .toList();
  }
}
