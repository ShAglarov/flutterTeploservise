import 'dart:async';
import 'dart:developer' as dev;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/api_models.dart';
import '../services/realtime_service.dart';
import '../services/user_service.dart';

/// ─────────────────────────────────────────────────
/// Presence data for a single user
/// ─────────────────────────────────────────────────
class UserPresence {
  final bool isOnline;
  final DateTime? lastSeen;
  final double? lastLatitude;
  final double? lastLongitude;

  const UserPresence({this.isOnline = false, this.lastSeen, this.lastLatitude, this.lastLongitude});

  UserPresence copyWith({bool? isOnline, DateTime? lastSeen, double? lastLatitude, double? lastLongitude}) {
    return UserPresence(
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      lastLatitude: lastLatitude ?? this.lastLatitude,
      lastLongitude: lastLongitude ?? this.lastLongitude,
    );
  }

  bool get hasLocation => (lastLatitude ?? 0) != 0 || (lastLongitude ?? 0) != 0;
}

/// ─────────────────────────────────────────────────
/// State: holds all users + their real-time presence
/// ─────────────────────────────────────────────────
class UsersState {
  final List<APIUserResponse> users;
  final Map<int, UserPresence> presence; // userId → presence
  final bool isLoading;
  final String? error;

  const UsersState({
    this.users = const [],
    this.presence = const {},
    this.isLoading = true,
    this.error,
  });

  UsersState copyWith({
    List<APIUserResponse>? users,
    Map<int, UserPresence>? presence,
    bool? isLoading,
    String? error,
  }) {
    return UsersState(
      users: users ?? this.users,
      presence: presence ?? this.presence,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Get presence for a user (falls back to API data if not tracked)
  bool isUserOnline(int userId) {
    if (presence.containsKey(userId)) {
      return presence[userId]!.isOnline;
    }
    // Fallback to API response data
    final user = users.cast<APIUserResponse?>().firstWhere(
      (u) => u?.id == userId,
      orElse: () => null,
    );
    return user?.isOnline == true;
  }

  /// Get last seen for a user
  DateTime? lastSeenFor(int userId) {
    if (presence.containsKey(userId)) {
      return presence[userId]!.lastSeen;
    }
    // Fallback to API response data
    final user = users.cast<APIUserResponse?>().firstWhere(
      (u) => u?.id == userId,
      orElse: () => null,
    );
    if (user?.lastLoginAt != null) {
      try {
        return DateTime.parse(user!.lastLoginAt!);
      } catch (_) {}
    }
    return null;
  }

  /// Get last latitude for a user
  double? lastLatFor(int userId) {
    if (presence.containsKey(userId) && presence[userId]!.lastLatitude != null) {
      return presence[userId]!.lastLatitude;
    }
    final user = users.cast<APIUserResponse?>().firstWhere(
      (u) => u?.id == userId,
      orElse: () => null,
    );
    return user?.lastLatitude;
  }

  /// Get last longitude for a user
  double? lastLngFor(int userId) {
    if (presence.containsKey(userId) && presence[userId]!.lastLongitude != null) {
      return presence[userId]!.lastLongitude;
    }
    final user = users.cast<APIUserResponse?>().firstWhere(
      (u) => u?.id == userId,
      orElse: () => null,
    );
    return user?.lastLongitude;
  }

  /// Check if user has a known location
  bool hasLocationFor(int userId) {
    final lat = lastLatFor(userId) ?? 0;
    final lng = lastLngFor(userId) ?? 0;
    return lat != 0 || lng != 0;
  }
}

/// ─────────────────────────────────────────────────
/// Provider
/// ─────────────────────────────────────────────────
final usersWithPresenceProvider = NotifierProvider<UsersNotifier, UsersState>(
  UsersNotifier.new,
);

/// ─────────────────────────────────────────────────
/// Notifier: manages user list + WebSocket presence
/// ─────────────────────────────────────────────────
class UsersNotifier extends Notifier<UsersState> {
  StreamSubscription<Map<String, dynamic>>? _wsSubscription;
  StreamSubscription<void>? _reconnectSubscription;

  @override
  UsersState build() {
    // Clean up subscriptions when provider is disposed
    ref.onDispose(() {
      _wsSubscription?.cancel();
      _reconnectSubscription?.cancel();
    });

    // IMPORTANT: Defer async work to after build() completes.
    // Setting state during synchronous build() execution causes silent failures.
    Future.microtask(() => _init());

    return const UsersState(); // isLoading: true by default
  }

  Future<void> _init() async {
    try {
      await loadUsers();
      _subscribeToWebSocket();
    } catch (e, st) {
      dev.log('UsersNotifier: _init() FAILED: $e\n$st', name: 'PRESENCE');
      state = state.copyWith(
        isLoading: false,
        error: 'Ошибка инициализации: $e',
      );
    }
  }

  /// Load all users from API
  Future<void> loadUsers() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final userService = ref.read(userServiceProvider);
      final users = await userService.getAllUsers();

      // Initialize presence from API data
      final presenceMap = <int, UserPresence>{};
      for (final user in users) {
        DateTime? lastSeen;
        if (user.lastLoginAt != null) {
          try {
            lastSeen = DateTime.parse(user.lastLoginAt!);
          } catch (_) {}
        }
        presenceMap[user.id] = UserPresence(
          isOnline: user.isOnline == true,
          lastSeen: lastSeen,
          lastLatitude: user.lastLatitude,
          lastLongitude: user.lastLongitude,
        );
      }

      state = state.copyWith(
        users: users,
        presence: presenceMap,
        isLoading: false,
      );
      dev.log('UsersNotifier: Loaded ${users.length} users', name: 'PRESENCE');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Ошибка загрузки пользователей: $e',
      );
      dev.log('UsersNotifier: Error loading users: $e', name: 'PRESENCE');
    }
  }

  /// Subscribe to WebSocket events
  void _subscribeToWebSocket() {
    final realtimeService = ref.read(realtimeServiceProvider);
    _wsSubscription = realtimeService.messages.listen(_handleWsMessage);
    _reconnectSubscription = realtimeService.onReconnect.listen((_) {
      dev.log('UsersNotifier: WebSocket reconnected, reloading users', name: 'PRESENCE');
      loadUsers();
    });
  }

  void _handleWsMessage(Map<String, dynamic> message) {
    final type = message['type'] as String?;

    // Handle presence events
    if (type == 'presence') {
      _handlePresenceEvent(message);
      return;
    }

    // КРИТИЧНО: Обработка presence_snapshot — бэкенд отправляет при подключении/переподключении
    // полный снимок онлайн-статусов всех пользователей. Без этого Flutter использует
    // устаревшие данные до прихода индивидуальных presence events.
    if (type == 'presence_snapshot') {
      _handlePresenceSnapshot(message);
      return;
    }

    // Handle user entity updates (action_sync with entity_type=user)
    if (type == 'action_sync') {
      final data = message['data'] as Map<String, dynamic>?;
      if (data != null && data['entity_type'] == 'user') {
        _handleUserUpdate(data);
      }
    }
  }

  /// Handle real-time presence event
  void _handlePresenceEvent(Map<String, dynamic> message) {
    final data = message['data'] as Map<String, dynamic>?;
    if (data == null) return;

    final userId = data['user_id'] as int?;
    final isOnline = data['is_online'] as bool?;
    final lastSeenStr = data['last_seen'] as String?;
    final lastLat = (data['last_latitude'] as num?)?.toDouble();
    final lastLng = (data['last_longitude'] as num?)?.toDouble();

    if (userId == null || isOnline == null) return;

    DateTime? lastSeen;
    if (lastSeenStr != null) {
      try {
        lastSeen = DateTime.parse(lastSeenStr);
      } catch (_) {}
    }

    dev.log(
      'UsersNotifier: PRESENCE update: user=$userId, online=$isOnline, lastSeen=$lastSeenStr, lat=$lastLat, lng=$lastLng',
      name: 'PRESENCE',
    );

    // Update presence map
    final existing = state.presence[userId];
    final newPresence = Map<int, UserPresence>.from(state.presence);
    newPresence[userId] = UserPresence(
      isOnline: isOnline,
      lastSeen: lastSeen ?? existing?.lastSeen,
      lastLatitude: lastLat ?? existing?.lastLatitude,
      lastLongitude: lastLng ?? existing?.lastLongitude,
    );

    state = state.copyWith(presence: newPresence);
  }

  /// Handle full presence snapshot (sent by backend on connect/reconnect)
  /// Format: {"type": "presence_snapshot", "data": {"users": [{"user_id": 1, "is_online": true, ...}, ...]}}
  void _handlePresenceSnapshot(Map<String, dynamic> message) {
    final data = message['data'] as Map<String, dynamic>?;
    if (data == null) return;

    final users = data['users'] as List<dynamic>?;
    if (users == null || users.isEmpty) return;

    final newPresence = Map<int, UserPresence>.from(state.presence);
    int onlineCount = 0;

    for (final userEntry in users) {
      if (userEntry is! Map<String, dynamic>) continue;

      final userId = userEntry['user_id'] as int?;
      final isOnline = userEntry['is_online'] as bool?;
      if (userId == null || isOnline == null) continue;

      final lastSeenStr = userEntry['last_seen'] as String?;
      final lastLat = (userEntry['last_latitude'] as num?)?.toDouble();
      final lastLng = (userEntry['last_longitude'] as num?)?.toDouble();

      DateTime? lastSeen;
      if (lastSeenStr != null) {
        try {
          lastSeen = DateTime.parse(lastSeenStr);
        } catch (_) {}
      }

      final existing = newPresence[userId];
      newPresence[userId] = UserPresence(
        isOnline: isOnline,
        lastSeen: lastSeen ?? existing?.lastSeen,
        lastLatitude: lastLat ?? existing?.lastLatitude,
        lastLongitude: lastLng ?? existing?.lastLongitude,
      );

      if (isOnline) onlineCount++;
    }

    state = state.copyWith(presence: newPresence);
    dev.log(
      'UsersNotifier: PRESENCE SNAPSHOT applied: ${users.length} users, $onlineCount online',
      name: 'PRESENCE',
    );
  }

  /// Handle user entity update (is_active, is_blocked changes)
  void _handleUserUpdate(Map<String, dynamic> data) {
    final entityData = data['entity_data'] as Map<String, dynamic>?;
    if (entityData == null) return;

    try {
      final updatedUser = APIUserResponse.fromJson(entityData);
      final userId = updatedUser.id;

      dev.log(
        'UsersNotifier: USER update: id=$userId, active=${updatedUser.isActive}, blocked=${updatedUser.isBlocked}',
        name: 'PRESENCE',
      );

      // Update user in list
      final newUsers = state.users.map((u) {
        if (u.id == userId) return updatedUser;
        return u;
      }).toList();

      // Also update presence from entity_data
      final changes = data['changes'] as Map<String, dynamic>?;
      final newPresence = Map<int, UserPresence>.from(state.presence);

      if (changes != null) {
        final isOnline = changes['is_online'] as bool?;
        final lastLoginAt = changes['last_login_at'] as String?;

        if (isOnline != null || lastLoginAt != null) {
          DateTime? lastSeen;
          if (lastLoginAt != null) {
            try {
              lastSeen = DateTime.parse(lastLoginAt);
            } catch (_) {}
          }

          newPresence[userId] = UserPresence(
            isOnline: isOnline ?? newPresence[userId]?.isOnline ?? false,
            lastSeen: lastSeen ?? newPresence[userId]?.lastSeen,
          );
        }
      }

      state = state.copyWith(users: newUsers, presence: newPresence);
    } catch (e) {
      dev.log('UsersNotifier: Error parsing user update: $e', name: 'PRESENCE');
    }
  }

  /// Force refresh from API
  Future<void> refresh() => loadUsers();

  /// Toggle user active/deactive status via API
  Future<bool> toggleUserActive(int userId, bool activate) async {
    try {
      final userService = ref.read(userServiceProvider);
      if (activate) {
        await userService.activateUser(userId);
      } else {
        await userService.deactivateUser(userId);
      }

      // Optimistic update: update local state immediately
      // (The WebSocket event will also arrive and reinforce this)
      final newUsers = state.users.map((u) {
        if (u.id == userId) {
          // Create a modified copy via JSON round-trip since APIUserResponse is immutable
          final json = u.toJson();
          json['is_active'] = activate;
          return APIUserResponse.fromJson(json);
        }
        return u;
      }).toList();

      final newPresence = Map<int, UserPresence>.from(state.presence);
      if (!activate) {
        // User deactivated → they'll be force-disconnected → mark offline
        newPresence[userId] = UserPresence(
          isOnline: false,
          lastSeen: DateTime.now(),
        );
      }

      state = state.copyWith(users: newUsers, presence: newPresence);

      dev.log('UsersNotifier: toggled user $userId active=$activate', name: 'PRESENCE');
      return true;
    } catch (e) {
      dev.log('UsersNotifier: Failed to toggle user $userId: $e', name: 'PRESENCE');
      return false;
    }
  }
}
