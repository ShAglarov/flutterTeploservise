import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/constants.dart';

/// Сервис кеширования аватарок.
/// Делегирует кеширование в cached_network_image (через DefaultCacheManager).
/// Предоставляет хелперы для построения URL и инвалидации.
final avatarCacheServiceProvider = Provider<AvatarCacheService>((ref) {
  return AvatarCacheService();
});

class AvatarCacheService {
  /// Построить полный URL аватарки из относительного пути (/uploads/avatars/xxx.jpg).
  /// Убираем /api/v1 из baseUrl, т.к. uploads обслуживается от корня сервера.
  static String buildAvatarUrl(String relativePath) {
    // AppConstants.baseUrl = 'https://api.teploservis05.ru/api/v1'
    // Нужен: 'https://api.teploservis05.ru/uploads/avatars/xxx.jpg'
    final base = AppConstants.baseUrl.replaceAll('/api/v1', '');
    // relativePath starts with /uploads/...
    return '$base$relativePath';
  }

  /// Инвалидировать кеш аватарки после загрузки нового фото
  Future<void> invalidateAvatar(String avatarUrl) async {
    final fullUrl = buildAvatarUrl(avatarUrl);
    await DefaultCacheManager().removeFile(fullUrl);
  }

  /// Очистить весь кеш аватарок
  Future<void> clearAll() async {
    await DefaultCacheManager().emptyCache();
  }
}
