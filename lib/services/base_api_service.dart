import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'secure_storage_service.dart';
import 'event_service.dart';
import 'device_id_service.dart';
import 'server_manager.dart';
import '../utils/constants.dart';
import '../utils/app_logger.dart';

final dioProvider = Provider<Dio>((ref) {
  // КРИТИЧНО: Наблюдаем за serverStateProvider, чтобы Dio пересоздавался при смене сервера
  final serverState = ref.watch(serverStateProvider).value ?? ref.read(serverManagerProvider).state;
  final currentBaseUrl = serverState.currentBaseUrl;
  
  final dio = Dio(
    BaseOptions(
      baseUrl: currentBaseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
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

  /// Mutex: if a refresh is already in progress, other 401 handlers wait for it.
  Completer<bool>? _refreshCompleter;

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
    // 403 permission_denied — сервер отказал по правам. Это значит, что
    // локальный снэпшот прав устарел: клиент показал кнопку, которой уже
    // нет. Перечитываем права, чтобы UI пришёл в соответствие с сервером.
    //
    // Нужно потому, что единственным механизмом обновления был WebSocket
    // permission_update: если он не дошёл (сеть, спящий сокет, выход из
    // фона), клиент жил со старыми правами до перелогина.
    if (err.response?.statusCode == 403) {
      final detail = err.response?.data;
      final isPermissionDenied = detail is Map &&
          detail['detail'] is String &&
          (detail['detail'] as String).startsWith('permission_denied');
      if (isPermissionDenied) {
        logDebug('🔐 [AuthInterceptor] 403 ${detail['detail']} — refreshing permissions');
        _eventService.fire(AppEvent.permissionsStale);
      }
      return handler.next(err);
    }

    if (err.response?.statusCode == 401) {
      // Don't try to refresh if we didn't send a token (unauthenticated request)
      final sentToken = err.requestOptions.headers['Authorization'];
      if (sentToken == null) {
        return handler.next(err);
      }

      // Don't refresh for the refresh endpoint itself (avoid infinite loop)
      if (err.requestOptions.path == AppConstants.refresh) {
        await _storageService.clearAuthData();
        _eventService.fire(AppEvent.logout);
        return handler.next(err);
      }

      // Try silent refresh
      final refreshed = await _tryRefreshToken();
      if (refreshed) {
        // Retry the original request with the NEW token
        try {
          final newToken = await _storageService.getAccessToken();
          final deviceId = await _deviceIdService.getDeviceId();
          final opts = err.requestOptions;
          
          // SECURITY: не логируем содержимое токена
          logDebug('🔄 [AuthInterceptor] Retrying ${opts.method} ${opts.path} with new token');

          final retryDio = Dio(BaseOptions(
            baseUrl: AppConstants.baseUrl,
            connectTimeout: opts.connectTimeout,
            receiveTimeout: opts.receiveTimeout,
          ));
          
          // Собираем query parameters
          final queryParams = Map<String, dynamic>.from(opts.queryParameters);
          queryParams['device_id'] = deviceId;

          final response = await retryDio.request(
            opts.path,
            data: opts.data,
            queryParameters: queryParams,
            options: Options(
              method: opts.method,
              headers: {
                'Authorization': 'Bearer $newToken',
                'X-Device-Id': deviceId,
                'Content-Type': opts.contentType,
              },
            ),
          );
          return handler.resolve(response);
        } catch (retryError) {
          // Retry also failed — log detail for debugging
          if (retryError is DioException) {
            final path = err.requestOptions.path;
            final detail = retryError.response?.data;
            logDebug('❌ [AuthInterceptor] Retry STILL ${retryError.response?.statusCode} on $path — server says: $detail');
            return handler.next(retryError);
          }
          return handler.next(err);
        }
      } else {
        // Refresh failed — session is truly expired, log out
        await _storageService.clearAuthData();
        _eventService.fire(AppEvent.logout);
        return handler.next(err);
      }
    }
    return handler.next(err);
  }

  /// Attempts to refresh the access token using the stored refresh token.
  /// Returns true on success (new tokens saved), false on failure.
  /// Uses a Completer mutex so concurrent 401s trigger only one refresh call.
  Future<bool> _tryRefreshToken() async {
    // If another request is already refreshing, wait for it
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    _refreshCompleter = Completer<bool>();

    try {
      final refreshToken = await _storageService.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        _refreshCompleter!.complete(false);
        return false;
      }

      final refreshUrl = AppConstants.baseUrl;
      logDebug('🔄 [AuthInterceptor] Refreshing at: $refreshUrl${AppConstants.refresh}');
      
      final dio = Dio(BaseOptions(
        baseUrl: refreshUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ));

      final response = await dio.post(
        AppConstants.refresh,
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200 && response.data != null) {
        final newAccessToken = response.data['access_token'] as String?;
        final newRefreshToken = response.data['refresh_token'] as String?;

        if (newAccessToken != null) {
          await _storageService.saveAccessToken(newAccessToken);
          // SECURITY: payload токена больше не логируется — содержит
          // session id и claims, по которым можно восстановить сессию.
        }
        if (newRefreshToken != null) {
          await _storageService.saveRefreshToken(newRefreshToken);
        }

        logDebug('🔄 [AuthInterceptor] Token refreshed successfully');
        _refreshCompleter!.complete(true);
        return true;
      }

      _refreshCompleter!.complete(false);
      return false;
    } catch (e) {
      logDebug('❌ [AuthInterceptor] Token refresh failed: $e');
      _refreshCompleter!.complete(false);
      return false;
    } finally {
      _refreshCompleter = null;
    }
  }
}
