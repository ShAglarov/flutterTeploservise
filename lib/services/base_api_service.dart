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

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      // Handle Unauthorized error (logout)
      await _storageService.clearAll();
      _eventService.fire(AppEvent.logout);
    }
    return handler.next(err);
  }
}
