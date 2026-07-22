import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/permission_service.dart';

/// Виджет, который делает дочерний элемент неактивным (серым),
/// если у пользователя нет указанного разрешения.
///
/// Элемент **не скрывается** — он остаётся видимым, но в disabled-состоянии.
///
/// ```dart
/// PermissionGate(
///   permissionKey: PermissionKey.incidentCreate,
///   child: ElevatedButton(
///     onPressed: () => createIncident(),
///     child: Text('Создать инцидент'),
///   ),
/// )
/// ```
class PermissionGate extends ConsumerWidget {
  /// Ключ разрешения (из [PermissionKey]).
  final String permissionKey;

  /// Дочерний виджет, который будет обёрнут.
  final Widget child;

  /// Если `true`, полностью скрывает элемент вместо dimming.
  /// По умолчанию `false` — элемент остаётся видимым, но серым.
  final bool hideInsteadOfDim;

  /// Кастомный виджет для отображения вместо child, когда нет прав.
  /// Если не указан — используется стандартный dimming.
  final Widget? deniedChild;

  /// Opacity для disabled-состояния (0.0 – 1.0).
  final double disabledOpacity;

  const PermissionGate({
    super.key,
    required this.permissionKey,
    required this.child,
    this.hideInsteadOfDim = false,
    this.deniedChild,
    this.disabledOpacity = 0.4,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(permissionStateProvider);

    // Пока не загружены — показываем child как есть (optimistic)
    if (!snapshot.isLoaded) return child;

    final allowed = snapshot.hasPermission(permissionKey);

    if (allowed) return child;

    // Запрещено
    if (hideInsteadOfDim) return const SizedBox.shrink();

    if (deniedChild != null) return deniedChild!;

    // Стандартный dimming: серый, не кликабельный
    return IgnorePointer(
      child: Opacity(
        opacity: disabledOpacity,
        child: child,
      ),
    );
  }
}

/// Extension на [Widget] для удобного оборачивания.
///
/// ```dart
/// ElevatedButton(...).requiresPermission(PermissionKey.incidentCreate)
/// ```
extension PermissionGateExtension on Widget {
  Widget requiresPermission(
    String permissionKey, {
    bool hideInsteadOfDim = false,
    double disabledOpacity = 0.4,
  }) {
    return PermissionGate(
      permissionKey: permissionKey,
      hideInsteadOfDim: hideInsteadOfDim,
      disabledOpacity: disabledOpacity,
      child: this,
    );
  }
}

/// Хелпер-метод для проверки прав внутри обработчиков (не виджетов).
///
/// ```dart
/// final canCreate = ref.read(permissionStateProvider).hasPermission(PermissionKey.incidentCreate);
/// if (!canCreate) {
///   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Нет прав')));
///   return;
/// }
/// ```
