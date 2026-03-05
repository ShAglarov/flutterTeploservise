import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/action_log_models.dart';
import '../services/action_log_service.dart';

/// Provider that fetches action logs from the server.
/// Supports optional filters — pass them via the family key.
final actionLogListProvider = FutureProvider.autoDispose
    .family<List<ActionLogEntry>, ActionLogFilter>((ref, filter) async {
  final service = ref.watch(actionLogServiceProvider);
  return service.getActionLogs(
    limit: filter.limit,
    offset: filter.offset,
    userId: filter.userId,
    entityType: filter.entityType,
    actionType: filter.actionType,
  );
});

/// Provider that fetches the list of users who have action log entries.
final actionLogUsersProvider =
    FutureProvider.autoDispose<List<ActionLogUser>>((ref) async {
  final service = ref.watch(actionLogServiceProvider);
  return service.getActionLogUsers();
});

/// Immutable filter key for [actionLogListProvider].
class ActionLogFilter {
  final int limit;
  final int offset;
  final int? userId;
  final String? entityType;
  final String? actionType;

  const ActionLogFilter({
    this.limit = 50,
    this.offset = 0,
    this.userId,
    this.entityType,
    this.actionType,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActionLogFilter &&
          runtimeType == other.runtimeType &&
          limit == other.limit &&
          offset == other.offset &&
          userId == other.userId &&
          entityType == other.entityType &&
          actionType == other.actionType;

  @override
  int get hashCode =>
      limit.hashCode ^
      offset.hashCode ^
      userId.hashCode ^
      entityType.hashCode ^
      actionType.hashCode;
}
