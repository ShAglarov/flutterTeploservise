import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/avatar_cache_service.dart';
import '../services/secure_storage_service.dart';

/// Универсальный виджет аватарки пользователя.
/// Показывает фото из кеша (memory → disk → server) или инициалы/иконку.
///
/// Аналог iOS AvatarCacheManager + UIImageView.
class UserAvatarWidget extends ConsumerWidget {
  /// Относительный путь к аватарке (/uploads/avatars/xxx.jpg) или null
  final String? avatarUrl;

  /// Имя пользователя для инициалов (fallback)
  final String? displayName;

  /// ID пользователя для детерминированного цвета фона
  final int? userId;

  /// Радиус круга (половина размера)
  final double radius;

  /// Callback при нажатии
  final VoidCallback? onTap;

  const UserAvatarWidget({
    super.key,
    this.avatarUrl,
    this.displayName,
    this.userId,
    this.radius = 20,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final widget = _buildAvatar(context, ref);
    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: widget);
    }
    return widget;
  }

  Widget _buildAvatar(BuildContext context, WidgetRef ref) {
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      final fullUrl = AvatarCacheService.buildAvatarUrl(avatarUrl!);

      return ClipOval(
        child: SizedBox(
          width: radius * 2,
          height: radius * 2,
          child: CachedNetworkImage(
            imageUrl: fullUrl,
            httpHeaders: _buildHeaders(ref),
            fit: BoxFit.cover,
            placeholder: (context, url) => _buildInitialsAvatar(context),
            errorWidget: (context, url, error) => _buildInitialsAvatar(context),
          ),
        ),
      );
    }
    return _buildInitialsAvatar(context);
  }

  Map<String, String> _buildHeaders(WidgetRef ref) {
    // Синхронно получить токен из Riverpod невозможно, поэтому
    // CachedNetworkImage передаёт заголовки через httpHeaders.
    // Токен берём из секьюрного хранилища при первом рендере.
    // Для API-запросов Dio interceptor добавит авторизацию сам.
    // Здесь передаём пустые заголовки — uploads обычно доступны без авторизации.
    return {};
  }

  Widget _buildInitialsAvatar(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        color: _getAvatarColor(),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        _getInitials(),
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 0.7,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getInitials() {
    if (displayName == null || displayName!.trim().isEmpty) return '?';
    final parts = displayName!.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  Color _getAvatarColor() {
    final colors = [
      Colors.blue,
      Colors.purple,
      Colors.teal,
      Colors.orange,
      Colors.pink,
      Colors.indigo,
      Colors.green,
      Colors.red,
    ];
    final index = (userId ?? displayName?.hashCode ?? 0) % colors.length;
    return colors[index.abs()];
  }
}
