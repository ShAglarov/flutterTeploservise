import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';
import 'connectivity_provider.dart';

/// Может ли текущий пользователь редактировать данные без интернета.
/// Админы всегда могут. Остальные — только если `canEditOffline == true`.
final canEditOfflineProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  final user = authState.user;
  if (user == null) return false;
  if (user.isAdmin) return true;
  return user.canEditOffline;
});

/// Итоговый флаг: может ли пользователь вносить изменения прямо сейчас.
/// - Online → всегда true (сервер доступен)
/// - Offline + canEditOffline → true (offline-режим разрешён)
/// - Offline + !canEditOffline → false (заблокировано)
final writeAccessProvider = Provider<bool>((ref) {
  final isOffline = ref.watch(isOfflineProvider);
  if (!isOffline) return true;
  return ref.watch(canEditOfflineProvider);
});
