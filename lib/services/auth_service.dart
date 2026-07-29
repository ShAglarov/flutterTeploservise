import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_api_service.dart';
import 'secure_storage_service.dart';
import 'device_id_service.dart';
import '../models/api_models.dart';
import '../utils/constants.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  final dio = ref.watch(dioProvider);
  final storage = ref.watch(secureStorageServiceProvider);
  final deviceIdService = ref.watch(deviceIdServiceProvider);
  return AuthService(dio, storage, deviceIdService);
});

class AuthService {
  final Dio _dio;
  final SecureStorageService _storage;
  final DeviceIdService _deviceIdService;

  AuthService(this._dio, this._storage, this._deviceIdService);

  Future<APILoginResponse> login(String username, String password) async {
    // Clear old tokens before login attempt
    await _storage.deleteAccessToken();
    await _storage.deleteRefreshToken();

    try {
      print('🚀 [AuthService] Attempting login to: ${AppConstants.baseUrl}${AppConstants.login}');
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

      print('✅ [AuthService] Login successful for: $username');
      final loginResponse = APILoginResponse.fromJson(response.data);
      
      await _storage.saveAccessToken(loginResponse.accessToken);
      if (loginResponse.refreshToken != null) {
        await _storage.saveRefreshToken(loginResponse.refreshToken!);
      }
      
      // Отправка session event "login" с геолокацией (best-effort, не блокирует вход)
      _sendSessionEventAsync('login');
      
      return loginResponse;
    } on DioException catch (e) {
      print('❌ [AuthService] Login failed: ${e.message}');
      if (e.response != null) {
        print('    Status: ${e.response?.statusCode}');
        print('    Data: ${e.response?.data}');
      }
      rethrow;
    } catch (e) {
      print('❌ [AuthService] Unexpected login error: $e');
      rethrow;
    }
  }

  Future<APIUserResponse> getCurrentUser() async {
    final response = await _dio.get(AppConstants.currentUser);
    return APIUserResponse.fromJson(response.data);
  }

  Future<void> logout() async {
    // Отправка session event "logout" ДО удаления токена (синхронно — ждём)
    await _sendSessionEventSync('logout');
    
    try {
      await _dio.post(AppConstants.logout);
    } catch (_) {
      // Ignore logout errors, we clear local state anyway
    } finally {
      // КРИТИЧНО: clearAuthData() вместо clearAll() — НЕ удаляет device_id
      await _storage.clearAuthData();
    }
  }

  // MARK: - Session Events (Login/Logout)

  /// Fire-and-forget session event (для login — не блокирует UI)
  void _sendSessionEventAsync(String event) {
    Future(() async {
      await _doSendSessionEvent(event);
    });
  }

  /// Синхронный session event (для logout — ждём завершения перед очисткой токена)
  Future<void> _sendSessionEventSync(String event) async {
    await _doSendSessionEvent(event);
  }

  /// Общая логика отправки session event
  Future<void> _doSendSessionEvent(String event) async {
    try {
      final deviceInfo = await _deviceIdService.getDeviceInfo();
      final deviceId = await _deviceIdService.getDeviceId();
      final position = await _deviceIdService.quickLocationFix();
      
      await _dio.post('/auth/session-event', data: {
        'event': event,
        'latitude': position?.latitude,
        'longitude': position?.longitude,
        'device_id': deviceId,
        ...deviceInfo.toJson(),
      });
      
      print('📋 [AuthService] Session event "$event" sent '
          '(lat: ${position?.latitude ?? "null"}, '
          'lon: ${position?.longitude ?? "null"})');
    } catch (e) {
      print('⚠️ [AuthService] Session event "$event" failed: $e');
      // Best-effort: не прокидываем ошибку — login/logout не должен блокироваться
    }
  }
}
