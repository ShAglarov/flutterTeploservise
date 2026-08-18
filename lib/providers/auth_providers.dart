import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/auth_service.dart';
import '../services/secure_storage_service.dart';
import '../services/realtime_service.dart';
import '../services/event_service.dart';
import '../utils/constants.dart';

part 'auth_providers.g.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
}

class AuthState {
  final AuthStatus status;
  final String? errorMessage;
  final bool isLoading;

  AuthState({
    required this.status,
    this.errorMessage,
    this.isLoading = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    bool? isLoading,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

@riverpod
class Auth extends _$Auth {
  StreamSubscription? _eventSubscription;

  @override
  AuthState build() {
    // Слушаем logout events от AuthInterceptor (при 401 + failed refresh)
    final eventService = ref.watch(eventServiceProvider);
    _eventSubscription?.cancel();
    _eventSubscription = eventService.events.listen((event) {
      if (event == AppEvent.logout) {
        print('🔑 [Auth] Received logout event — redirecting to login');
        state = AuthState(status: AuthStatus.unauthenticated);
      }
    });
    ref.onDispose(() => _eventSubscription?.cancel());

    _checkAuth();
    return AuthState(status: AuthStatus.initial, isLoading: true);
  }

  Future<void> _checkAuth() async {
    final storage = ref.watch(secureStorageServiceProvider);
    final token = await storage.getAccessToken();
    if (token == null) {
      state = state.copyWith(status: AuthStatus.unauthenticated, isLoading: false);
      return;
    }

    // Проверяем exp claim — не истёк ли access token
    bool tokenExpired = false;
    try {
      final parts = token.split('.');
      if (parts.length == 3) {
        String payload = parts[1];
        switch (payload.length % 4) {
          case 2: payload += '=='; break;
          case 3: payload += '='; break;
        }
        final decoded = utf8.decode(base64Url.decode(payload));
        final json = jsonDecode(decoded) as Map<String, dynamic>;
        final exp = json['exp'] as int?;
        if (exp != null) {
          final expiresAt = DateTime.fromMillisecondsSinceEpoch(exp * 1000, isUtc: true);
          tokenExpired = DateTime.now().toUtc().isAfter(expiresAt);
          print('🔑 [Auth] Token exp: $expiresAt, expired: $tokenExpired');
        }
      }
    } catch (_) {}

    if (tokenExpired) {
      print('⚠️ [Auth] Access token expired — trying refresh...');
      final refreshToken = await storage.getRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          final dio = Dio(BaseOptions(
            baseUrl: AppConstants.baseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
          ));
          final response = await dio.post(
            AppConstants.refresh,
            data: {'refresh_token': refreshToken},
          );
          if (response.statusCode == 200 && response.data != null) {
            final newAccess = response.data['access_token'] as String?;
            final newRefresh = response.data['refresh_token'] as String?;
            if (newAccess != null) await storage.saveAccessToken(newAccess);
            if (newRefresh != null) await storage.saveRefreshToken(newRefresh);
            print('✅ [Auth] Token refreshed at startup');
            state = state.copyWith(status: AuthStatus.authenticated, isLoading: false);
            return;
          }
        } catch (e) {
          print('❌ [Auth] Refresh failed: $e');
        }
      }
      // Refresh не помог — очищаем и на логин
      print('❌ [Auth] Forcing re-login');
      await storage.clearAuthData();
      state = state.copyWith(status: AuthStatus.unauthenticated, isLoading: false);
      return;
    }

    // Токен валиден
    state = state.copyWith(status: AuthStatus.authenticated, isLoading: false);
  }

  Future<void> login(String username, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final authService = ref.read(authServiceProvider);
      await authService.login(username, password);
      state = state.copyWith(status: AuthStatus.authenticated, isLoading: false);
    } catch (e) {
      print('🔥 [AuthProvider] Caught error: $e, type: ${e.runtimeType}');
      String errorMessage = 'Произошла непредвиденная ошибка: $e';
      
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout || 
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.connectionError) {
          errorMessage = 'Ошибка сети. Проверьте подключение к интернету.';
        } else if (e.response != null) {
          final statusCode = e.response!.statusCode;
          if (statusCode == 401) {
            errorMessage = 'Неверный логин или пароль.';
          } else if (statusCode == 400) {
            errorMessage = e.response?.data['detail'] ?? 'Неверный запрос.';
          } else if (statusCode != null && statusCode >= 500) {
            errorMessage = 'Ошибка сервера. Пожалуйста, попробуйте позже.';
          } else {
             errorMessage = 'Ошибка: ${e.response?.statusMessage}';
          }
        }
      }

      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        isLoading: false,
        errorMessage: errorMessage,
      );
    }
  }

  Future<void> logout() async {
    // >>> LAST GASP: Отправляем финальный pong с GPS ДО очистки токенов
    try {
      final realtimeService = ref.read(realtimeServiceProvider);
      realtimeService.sendLastPong();
      // Даём WebSocket 500мс на фактическую отправку фрейма
      await Future.delayed(const Duration(milliseconds: 500));
      realtimeService.disconnect();
    } catch (_) {
      // RealtimeService может быть не инициализирован — не критично
    }
    
    final authService = ref.read(authServiceProvider);
    await authService.logout();
    state = AuthState(status: AuthStatus.unauthenticated);
  }
}
