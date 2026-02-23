import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_api_service.dart';
import 'secure_storage_service.dart';
import '../models/api_models.dart';
import '../utils/constants.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  final dio = ref.watch(dioProvider);
  final storage = ref.watch(secureStorageServiceProvider);
  return AuthService(dio, storage);
});

class AuthService {
  final Dio _dio;
  final SecureStorageService _storage;

  AuthService(this._dio, this._storage);

  Future<APILoginResponse> login(String username, String password) async {
    // Clear old tokens before login attempt
    await _storage.deleteAccessToken();
    await _storage.deleteRefreshToken();

    final response = await _dio.post(
      AppConstants.login,
      data: {
        'username': username,
        'password': password,
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );

    final loginResponse = APILoginResponse.fromJson(response.data);
    
    await _storage.saveAccessToken(loginResponse.accessToken);
    if (loginResponse.refreshToken != null) {
      await _storage.saveRefreshToken(loginResponse.refreshToken!);
    }
    
    return loginResponse;
  }

  Future<APIUserResponse> getCurrentUser() async {
    final response = await _dio.get(AppConstants.currentUser);
    return APIUserResponse.fromJson(response.data);
  }

  Future<void> logout() async {
    try {
      await _dio.post(AppConstants.logout);
    } catch (_) {
      // Ignore logout errors, we clear local state anyway
    } finally {
      await _storage.clearAll();
    }
  }
}
