import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_role.dart';
import '../services/user_service.dart';
import 'connectivity_provider.dart';

/// Может ли текущий пользователь редактировать данные без интернета.
/// Админы всегда могут. Остальные — только если `canEditOffline == true`.
///
/// Источник — currentUserProvider (GET /users/me). Раньше читался
/// authProvider из providers/auth_provider.dart: это был второй провайдер с
/// тем же именем, и он инициализировался лишь как побочный эффект импорта из
/// incident_providers. Пока его состояние пустое, `user == null` → offline
/// запись запрещалась даже админу.
final canEditOfflineProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return false;
  if (user.role == UserRole.admin) return true;
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
