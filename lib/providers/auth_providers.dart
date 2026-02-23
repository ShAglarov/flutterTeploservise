import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/auth_service.dart';
import '../services/secure_storage_service.dart';

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
  @override
  AuthState build() {
    _checkAuth();
    return AuthState(status: AuthStatus.initial, isLoading: true);
  }

  Future<void> _checkAuth() async {
    final storage = ref.watch(secureStorageServiceProvider);
    final token = await storage.getAccessToken();
    if (token != null) {
      state = state.copyWith(status: AuthStatus.authenticated, isLoading: false);
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated, isLoading: false);
    }
  }

  Future<void> login(String username, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final authService = ref.read(authServiceProvider);
      await authService.login(username, password);
      state = state.copyWith(status: AuthStatus.authenticated, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        isLoading: false,
        errorMessage: 'Ошибка входа. Проверьте логин и пароль.',
      );
    }
  }

  Future<void> logout() async {
    final authService = ref.read(authServiceProvider);
    await authService.logout();
    state = AuthState(status: AuthStatus.unauthenticated);
  }
}
