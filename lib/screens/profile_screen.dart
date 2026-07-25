import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/api_models.dart';
import '../models/permission_key.dart';
import '../providers/auth_providers.dart';
import '../services/auth_service.dart';
import '../services/device_id_service.dart';
import '../services/user_service.dart';
import '../services/avatar_cache_service.dart';
import '../services/permission_service.dart';
import '../utils/app_theme.dart';
import '../widgets/user_avatar_widget.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  APIUserResponse? _user;
  String? _deviceId;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final authService = ref.read(authServiceProvider);
      final deviceIdService = ref.read(deviceIdServiceProvider);

      final results = await Future.wait([
        authService.getCurrentUser(),
        deviceIdService.getDeviceId(),
      ]);

      if (mounted) {
        setState(() {
          _user = results[0] as APIUserResponse;
          _deviceId = results[1] as String;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Ошибка загрузки профиля';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text('Выход', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        content: Text(
          'Вы уверены, что хотите выйти из аккаунта?',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(180)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Выйти',
                style: TextStyle(color: AppTheme.errorRed)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(authProvider.notifier).logout();
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _showFullscreenAvatar(APIUserResponse user) async {
    if (user.avatarUrl == null || user.avatarUrl!.isEmpty) {
      // Нет аватарки — сразу открываем пикер
      _pickAndUploadAvatar(user);
      return;
    }
    
    final fullUrl = AvatarCacheService.buildAvatarUrl(user.avatarUrl!);
    
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black87,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Center(
                  child: Hero(
                    tag: 'avatar_${user.id}',
                    child: CachedNetworkImage(
                      imageUrl: fullUrl,
                      fit: BoxFit.contain,
                      placeholder: (ctx, url) => const CircularProgressIndicator(color: Colors.white),
                      errorWidget: (ctx, url, err) => const Icon(Icons.error, color: Colors.white, size: 48),
                    ),
                  ),
                ),
              ),
              floatingActionButton: FloatingActionButton(
                mini: true,
                backgroundColor: Colors.white24,
                onPressed: () => Navigator.pop(context),
                child: const Icon(Icons.close, color: Colors.white),
              ),
              floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
            ),
          );
        },
      ),
    );
  }

  Future<void> _pickAndUploadAvatar(APIUserResponse user) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    if (picked == null) return;

    try {
      final userService = ref.read(userServiceProvider);
      final avatarService = ref.read(avatarCacheServiceProvider);

      // Инвалидируем старый кеш
      if (user.avatarUrl != null) {
        await avatarService.invalidateAvatar(user.avatarUrl!);
      }

      final updatedUser = await userService.uploadAvatar(
        user.id,
        File(picked.path),
      );

      // Инвалидируем новый URL тоже (чтобы перезагрузить)
      if (updatedUser.avatarUrl != null) {
        await avatarService.invalidateAvatar(updatedUser.avatarUrl!);
      }

      if (mounted) {
        setState(() {
          _user = updatedUser;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Аватар обновлён'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка загрузки аватара: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  String get _deviceName {
    if (Platform.isIOS) return 'iPhone';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isLinux) return 'Linux';
    return 'Устройство';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).colorScheme.onSurface, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Профиль',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _handleLogout,
            child: const Text(
              'Выйти',
              style: TextStyle(
                color: AppTheme.errorRed,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryBlue))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          color: AppTheme.errorRed, size: 48),
                      const SizedBox(height: 16),
                      Text(_error!,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withAlpha(180), fontSize: 16)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isLoading = true;
                            _error = null;
                          });
                          _loadData();
                        },
                        child: const Text('Повторить'),
                      ),
                    ],
                  ),
                )
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final user = _user!;
    final role = user.role;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // ======== Аватар ========
          Center(
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () => _showFullscreenAvatar(user),
                  child: Hero(
                    tag: 'avatar_${user.id}',
                    child: UserAvatarWidget(
                      avatarUrl: user.avatarUrl,
                      displayName: _buildFIO(user).isNotEmpty ? _buildFIO(user) : user.username,
                      userId: user.id,
                      radius: 40,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => _pickAndUploadAvatar(user),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ======== Учетная запись ========
          _buildSectionHeader('Учетная запись'),
          const SizedBox(height: 8),
          _buildCard([
            _buildRow('Логин', user.username),
            if (_buildFIO(user).isNotEmpty) _buildRow('ФИО', _buildFIO(user)),
            if (user.position != null && user.position!.isNotEmpty)
              _buildRow('Должность', user.position!),
            _buildRow('Роль', role.title, valueColor: AppTheme.primaryBlue),
          ]),

          const SizedBox(height: 24),

          // ======== Устройство ========
          _buildSectionHeader('Устройство'),
          const SizedBox(height: 8),
          _buildCard([
            _buildRow('Имя устройства', _deviceName),
            _buildDeviceIdRow(),
          ]),

          const SizedBox(height: 24),

          // ======== Ваши права и доступ ========
          _buildSectionHeader('Ваши права и доступ'),
          const SizedBox(height: 8),
          Builder(builder: (context) {
            final perms = ref.watch(permissionStateProvider);
            return _buildCard([
              _buildPermissionRow('Просмотр инцидентов', perms.hasPermission(PermissionKey.incidentRead)),
              _buildPermissionRow('Создание инцидентов', perms.hasPermission(PermissionKey.incidentCreate)),
              _buildPermissionRow('Редактирование инцидентов', perms.hasPermission(PermissionKey.incidentUpdate)),
              _buildPermissionRow('Удаление инцидентов', perms.hasPermission(PermissionKey.incidentDelete)),
              _buildPermissionRow('Создание котельных', perms.hasPermission(PermissionKey.boilerHouseCreate)),
              _buildPermissionRow('Управление пользователями', perms.hasPermission(PermissionKey.userManagePermissions)),
            ]);
          }),

          const SizedBox(height: 40),

          // ======== Кнопка Выйти (нижняя) ========
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: _handleLogout,
              icon: const Icon(Icons.logout, size: 20),
              label: const Text('Выйти из аккаунта',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.errorRed,
                side: BorderSide(color: AppTheme.errorRed.withAlpha(80)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  String _buildFIO(APIUserResponse user) {
    final parts = [
      user.lastName,
      user.firstName,
      user.middleName,
    ].where((s) => s != null && s.trim().isNotEmpty).map((s) => s!.trim());
    if (parts.isNotEmpty) return parts.join(' ');
    if (user.fullName != null && user.fullName!.trim().isNotEmpty) {
      return user.fullName!.trim();
    }
    return '';
  }

  // ============================================================
  // UI Building Blocks
  // ============================================================

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withAlpha(140),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              Divider(
                height: 1,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(15),
                indent: 16,
                endIndent: 16,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: valueColor ?? Theme.of(context).colorScheme.onSurface.withAlpha(140),
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceIdRow() {
    final displayId = _deviceId ?? '—';
    // Truncate in middle like iOS: "4E347CCD-A178-…C-59B123C92749"
    String shortId = displayId;
    if (displayId.length > 24) {
      shortId =
          '${displayId.substring(0, 12)}…${displayId.substring(displayId.length - 12)}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Text(
            'Device ID',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              shortId,
              textAlign: TextAlign.right,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(140), fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: displayId));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Device ID скопирован'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            child: Icon(
              Icons.info_outline,
              color: AppTheme.primaryBlue,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionRow(String label, bool allowed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16),
            ),
          ),
          Text(
            allowed ? 'Разрешено' : 'Запрещено',
            style: TextStyle(
              color: allowed ? AppTheme.successGreen : AppTheme.errorRed,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
