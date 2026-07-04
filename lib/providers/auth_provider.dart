import 'dart:async';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/api_models.dart';
import '../models/auth_user.dart';
import '../models/user_role.dart';
import '../services/auth_service.dart';
import '../services/secure_storage_service.dart';
import '../services/event_service.dart';
import '../database/database.dart';

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
  late final AppDatabase _db;
  StreamSubscription? _eventSubscription;

  @override
  AuthState build() {
    _authService = ref.watch(authServiceProvider);
    _storageService = ref.watch(secureStorageServiceProvider);
    _eventService = ref.watch(eventServiceProvider);
    _db = ref.watch(databaseProvider);

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
      // КРИТИЧНО: Кэшируем пользователя в локальную БД для offline-режима
      await _cacheUserLocally(authUser);
      state = AuthState.authenticated(authUser);
    } catch (e) {
      // ИСПРАВЛЕНИЕ: При сетевой ошибке восстанавливаем пользователя из локальной БД
      // Это позволяет показывать оранжевый баннер "сохраняются локально" вместо красного
      if (_isNetworkError(e)) {
        final cachedUser = await _loadCachedUser();
        if (cachedUser != null) {
          state = AuthState.authenticated(cachedUser);
          return;
        }
      }
      state = AuthState.unauthenticated();
    }
  }

  Future<void> login(String username, String password) async {
    state = AuthState.loading();
    try {
      await _authService.login(username, password);
      final apiUser = await _authService.getCurrentUser();
      final authUser = _mapToAuthUser(apiUser);
      // Кэшируем пользователя в локальную БД для offline-режима
      await _cacheUserLocally(authUser);
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

  /// Проверяет, является ли ошибка сетевой (DioException)
  bool _isNetworkError(Object e) {
    if (e is DioException) {
      return e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.unknown;
    }
    return false;
  }

  /// Сохраняет/обновляет пользователя в локальной Drift таблице AppUsers
  Future<void> _cacheUserLocally(AuthUser user) async {
    try {
      final existing = await (_db.select(_db.appUsers)
            ..where((t) => t.username.equals(user.username)))
          .getSingleOrNull();

      if (existing != null) {
        await (_db.update(_db.appUsers)
              ..where((t) => t.username.equals(user.username)))
            .write(AppUsersCompanion(
          userId: Value(user.id),
          fullName: Value(user.displayName),
          userEmail: Value(user.email),
          role: Value(user.role.name),
          canEditOffline: Value(user.canEditOffline),
          isAdmin: Value(user.isAdmin),
          lastLoginAt: Value(user.lastLoginAt),
          updatedAt: Value(DateTime.now()),
        ));
      } else {
        await _db.into(_db.appUsers).insert(AppUsersCompanion.insert(
          username: Value(user.username),
          userId: Value(user.id),
          fullName: Value(user.displayName),
          userEmail: Value(user.email),
          role: Value(user.role.name),
          canEditOffline: Value(user.canEditOffline),
          isAdmin: Value(user.isAdmin),
          lastLoginAt: Value(user.lastLoginAt),
          passwordHash: '',
          createdAt: Value(DateTime.now()),
        ));
      }
    } catch (e) {
      // Не блокируем авторизацию из-за ошибки кэширования
      print('⚠️ [Auth] Failed to cache user locally: $e');
    }
  }

  /// Восстанавливает пользователя из локальной Drift таблицы AppUsers
  Future<AuthUser?> _loadCachedUser() async {
    try {
      final cachedUser = await (_db.select(_db.appUsers)
            ..orderBy([(t) => OrderingTerm.desc(t.lastLoginAt)])
            ..limit(1))
          .getSingleOrNull();

      if (cachedUser == null) return null;

      return AuthUser(
        id: cachedUser.userId ?? cachedUser.id.toString(),
        username: cachedUser.username ?? '',
        displayName: cachedUser.fullName ?? cachedUser.username ?? '',
        email: cachedUser.userEmail,
        role: UserRole.fromAnyString(cachedUser.role),
        canEditOffline: cachedUser.canEditOffline,
        createdAt: cachedUser.createdAt,
        lastLoginAt: cachedUser.lastLoginAt,
      );
    } catch (e) {
      print('⚠️ [Auth] Failed to load cached user: $e');
      return null;
    }
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
      canEditOffline: apiUser.canEditOffline,
    );
  }
}
