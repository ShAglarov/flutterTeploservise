import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'secure_storage_service.dart';
import 'event_service.dart';
import 'device_id_service.dart';
import '../utils/constants.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 120),
      receiveTimeout: const Duration(seconds: 180),
    ),
  );

  final storageService = ref.watch(secureStorageServiceProvider);
  final eventService = ref.watch(eventServiceProvider);
  final deviceIdService = ref.watch(deviceIdServiceProvider);
  
  dio.interceptors.add(AuthInterceptor(storageService, eventService, deviceIdService));

  return dio;
});

class AuthInterceptor extends Interceptor {
  final SecureStorageService _storageService;
  final EventService _eventService;
  final DeviceIdService _deviceIdService;

  AuthInterceptor(this._storageService, this._eventService, this._deviceIdService);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storageService.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    final deviceId = await _deviceIdService.getDeviceId();
    options.headers['X-Device-Id'] = deviceId;
    
    // Many backend endpoints require device_id as a query parameter
    // We add it globally to avoid missing it in specific service methods
    final queryParams = Map<String, dynamic>.from(options.queryParameters);
    queryParams['device_id'] = deviceId;
    options.queryParameters = queryParams;

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      // Only trigger logout logic if we actually sent a token
      // If we didn't send a token, it's a "natural" unauthenticated state
      final sentToken = err.requestOptions.headers['Authorization'];
      if (sentToken != null) {
        await _storageService.clearAll();
        _eventService.fire(AppEvent.logout);
      }
    }
    return handler.next(err);
  }
}
