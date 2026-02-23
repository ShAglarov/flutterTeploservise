import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/api_models.dart';
import '../models/auth_user.dart';
import '../services/auth_service.dart';
import '../services/secure_storage_service.dart';
import '../services/event_service.dart';

part 'auth_provider.g.dart';

enum AuthStatus { authenticated, unauthenticated, loading }

class AuthState {
  final AuthStatus status;
  final AuthUser? user;
  final String? error;

  AuthState({
    required this.status,
    this.user,
    this.error,
  });

  factory AuthState.unauthenticated({String? error}) =>
      AuthState(status: AuthStatus.unauthenticated, error: error);

  factory AuthState.authenticated(AuthUser user) =>
      AuthState(status: AuthStatus.authenticated, user: user);

  factory AuthState.loading() => AuthState(status: AuthStatus.loading);
}

@riverpod
class Auth extends _$Auth {
  late final AuthService _authService;
  late final SecureStorageService _storageService;
  late final EventService _eventService;
  StreamSubscription? _eventSubscription;

  @override
  AuthState build() {
    _authService = ref.watch(authServiceProvider);
    _storageService = ref.watch(secureStorageServiceProvider);
    _eventService = ref.watch(eventServiceProvider);

    _subscribeToEvents();
    
    // Use a microtask to initialize to avoid updating state during build
    Future.microtask(() => _initialize());

    ref.onDispose(() {
      _eventSubscription?.cancel();
    });

    return AuthState.loading();
  }

  void _subscribeToEvents() {
    _eventSubscription?.cancel();
    _eventSubscription = _eventService.events.listen((event) {
      if (event == AppEvent.logout) {
        forceLogout();
      }
    });
  }

  Future<void> _initialize() async {
    final token = await _storageService.getAccessToken();
    if (token == null) {
      state = AuthState.unauthenticated();
      return;
    }

    try {
      final apiUser = await _authService.getCurrentUser();
      final authUser = _mapToAuthUser(apiUser);
      state = AuthState.authenticated(authUser);
    } catch (e) {
      state = AuthState.unauthenticated();
    }
  }

  Future<void> login(String username, String password) async {
    state = AuthState.loading();
    try {
      await _authService.login(username, password);
      final apiUser = await _authService.getCurrentUser();
      final authUser = _mapToAuthUser(apiUser);
      state = AuthState.authenticated(authUser);
    } catch (e) {
      state = AuthState.unauthenticated(error: e.toString());
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = AuthState.unauthenticated();
  }

  void forceLogout() {
    state = AuthState.unauthenticated();
  }

  AuthUser _mapToAuthUser(APIUserResponse apiUser) {
    return AuthUser(
      id: apiUser.id.toString(),
      username: apiUser.username,
      displayName: apiUser.fullName ?? apiUser.username,
      email: apiUser.email,
      role: apiUser.role,
      createdAt: DateTime.tryParse(apiUser.createdAt),
      lastLoginAt: apiUser.lastLoginAt != null ? DateTime.tryParse(apiUser.lastLoginAt!) : null,
    );
  }
}
