import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../models/api_models.dart';
import '../models/user_role.dart';
import '../providers/auth_providers.dart';
import '../providers/user_presence_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/map_tile_provider.dart';
import '../services/auth_service.dart';
import '../services/boiler_house_service.dart';
import '../services/location_service.dart';
import '../services/incident_service.dart';
import '../services/user_service.dart';
import '../services/avatar_cache_service.dart';
import '../repositories/sync_repository.dart';
import '../utils/app_theme.dart';
import '../utils/time_formatter.dart';
import '../widgets/user_avatar_widget.dart';
import 'action_log_list_screen.dart';
import 'profile_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  APIUserResponse? _currentUser;
  bool _isLoading = true;
  bool _showPipes = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final authService = ref.read(authServiceProvider);
      final user = await authService.getCurrentUser();
      if (mounted) {
        setState(() {
          _currentUser = user;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
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

  Future<void> _handleFullSync() async {
    // Показать диалог загрузки
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        content: Row(
          children: [
            const CircularProgressIndicator(color: AppTheme.primaryBlue),
            const SizedBox(width: 24),
            Expanded(
              child: Text(
                'Загрузка данных с сервера...',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              ),
            ),
          ],
        ),
      ),
    );

    try {
      final syncRepo = ref.read(syncRepositoryProvider);
      final bhService = ref.read(boilerHouseServiceProvider);
      final locService = ref.read(locationServiceProvider);
      final incService = ref.read(incidentServiceProvider);

      // 1. Очищаем кэш
      await syncRepo.clearAllCachedData();

      // 2. Загружаем все данные заново
      await Future.wait([
        bhService.getAllBoilerHouses(),
        locService.getAllSavedLocations(),
        incService.getAllIncidents(),
      ]);

      if (mounted) {
        Navigator.pop(context); // закрыть диалог загрузки
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Все данные загружены с сервера'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // закрыть диалог загрузки
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Ошибка: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  String _getInitials(APIUserResponse user) {
    final first = user.firstName?.trim() ?? '';
    final last = user.lastName?.trim() ?? '';
    if (first.isNotEmpty && last.isNotEmpty) {
      return '${first[0]}${last[0]}'.toUpperCase();
    }
    if (user.username.isNotEmpty) {
      return user.username.substring(0, user.username.length >= 2 ? 2 : 1).toUpperCase();
    }
    return '?';
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Настройки',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          if (_currentUser != null) _buildUserBadge(),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue))
          : _buildContent(),
    );
  }

  Widget _buildUserBadge() {
    final user = _currentUser!;
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                user.username,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                user.role.title,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(140),
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppTheme.primaryBlue,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              _getInitials(user),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        // ═══════ Отображение ═══════
        _buildSectionHeader('Отображение'),
        const SizedBox(height: 8),
        _buildCard([
          // Показать трубы
          _buildToggleRow(
            icon: Icons.route,
            iconColor: Colors.tealAccent,
            title: 'Показать трубы',
            subtitle: 'Отображение теплотрасс на карте',
            value: _showPipes,
            onChanged: (v) => setState(() => _showPipes = v),
          ),
          _buildDivider(),
          // Тема приложения
          _buildThemeSelector(),
          _buildDivider(),
          // Подложка карты
          _buildMapTileSelector(),
          _buildDivider(),
          // Настройка кнопок и меню
          _buildNavRow(
            icon: Icons.tune,
            iconColor: Colors.purpleAccent,
            title: 'Настройка кнопок и меню',
            subtitle: 'Выберите быстрые действия и порядок элементов',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Настройка кнопок скоро появится')),
              );
            },
          ),
          _buildDivider(),
          // Настройка отслеживаний действий
          _buildNavRow(
            icon: Icons.power_settings_new,
            iconColor: AppTheme.primaryBlue,
            title: 'Настройка отслеживаний действий',
            subtitle: 'Управляйте типами событий журнала',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Настройка отслеживаний скоро появится')),
              );
            },
          ),
        ]),
        _buildSectionFooter('Управление отображением элементов на карте'),

        const SizedBox(height: 24),

        // ═══════ Пользователи ═══════
        if (_currentUser?.role.canManageUsers == true) ...[
          _buildSectionHeader('Пользователи'),
          const SizedBox(height: 8),
          _buildCard([
            _buildNavRow(
              icon: Icons.people_outline,
              iconColor: AppTheme.primaryBlue,
              title: 'Управление пользователями',
              subtitle: 'Создание, блокировка и выдача ролей',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UserManagementScreen()),
                );
              },
            ),
          ]),
          const SizedBox(height: 24),
        ],

        // ═══════ Данные ═══════
        _buildSectionHeader('Данные'),
        const SizedBox(height: 8),
        _buildCard([
          _buildActionRow(
            icon: Icons.cloud_download_outlined,
            iconColor: Colors.orangeAccent,
            title: 'Загрузить все данные с сервера',
            onTap: _handleFullSync,
          ),
        ]),
        _buildSectionFooter('Полная пересинхронизация котельных и домов с сервера'),

        const SizedBox(height: 24),

        // ═══════ Аккаунт ═══════
        _buildSectionHeader('Аккаунт'),
        const SizedBox(height: 8),
        _buildCard([
          _buildNavRow(
            icon: Icons.person_outline,
            iconColor: AppTheme.successGreen,
            title: 'Профиль',
            subtitle: 'Просмотр и редактирование профиля',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          _buildDivider(),
          _buildActionRow(
            icon: Icons.logout,
            iconColor: AppTheme.errorRed,
            title: 'Выйти из аккаунта',
            titleColor: AppTheme.errorRed,
            onTap: _handleLogout,
          ),
        ]),

        const SizedBox(height: 40),
      ],
    );
  }

  // ─────────────────────────────────────────────────
  // UI Building Blocks
  // ─────────────────────────────────────────────────

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withAlpha(140),
          fontSize: 13,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildSectionFooter(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 8),
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withAlpha(97),
          fontSize: 12,
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
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: Theme.of(context).colorScheme.onSurface.withAlpha(15),
      indent: 52,
      endIndent: 16,
    );
  }

  Widget _buildToggleRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(140), fontSize: 12)),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppTheme.successGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSelector() {
    final currentTheme = ref.watch(themeControllerProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Тема приложения',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16)),
          const SizedBox(height: 2),
          Text('Системная, светлая или тёмная тема',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(140), fontSize: 12)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                _buildThemeButton('Система', ThemePreference.system, currentTheme),
                _buildThemeButton('Светлая', ThemePreference.light, currentTheme),
                _buildThemeButton('Тёмная', ThemePreference.dark, currentTheme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeButton(String label, ThemePreference pref, ThemePreference currentTheme) {
    final isSelected = currentTheme == pref;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: GestureDetector(
        onTap: () => ref.read(themeControllerProvider.notifier).setTheme(pref),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? Theme.of(context).colorScheme.onSurface.withAlpha(30) : Colors.black.withAlpha(20))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(context).colorScheme.onSurface.withAlpha(140),
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMapTileSelector() {
    final currentSource = ref.watch(mapTileSourceProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Подложка карты',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16)),
          const SizedBox(height: 2),
          Text('Выберите стиль карты',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(140), fontSize: 12)),
          const SizedBox(height: 12),
          SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: mapTileDisplayOptions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final option = mapTileDisplayOptions[index];
                return _buildTileOption(option, currentSource);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTileOption(MapTileDisplayInfo option, MapTileSource currentSource) {
    final isSelected = currentSource == option.source;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => ref.read(mapTileSourceProvider.notifier).setSource(option.source),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? Theme.of(context).colorScheme.onSurface.withAlpha(30) : Colors.black.withAlpha(20))
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(color: AppTheme.primaryBlue, width: 2)
              : Border.all(color: Colors.transparent, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(option.icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 4),
            Text(
              option.displayName,
              style: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.onSurface
                    : Theme.of(context).colorScheme.onSurface.withAlpha(140),
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(140), fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurface.withAlpha(97), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildActionRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: titleColor ?? Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
// User Management Screen
// ═══════════════════════════════════════════════════

class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen>
    with WidgetsBindingObserver {
  bool _showUsersOnMap = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  /// При возвращении из фона — обновляем список пользователей,
  /// чтобы получить актуальные онлайн-статусы из API
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(usersWithPresenceProvider.notifier).refresh();
    }
  }

  List<APIUserResponse> _applySearch(List<APIUserResponse> users) {
    if (_searchQuery.isEmpty) return users;
    return users.where((u) {
      final name = _getFullName(u).toLowerCase();
      final username = u.username.toLowerCase();
      final email = u.email.toLowerCase();
      final phone = u.phoneNumber?.toLowerCase() ?? '';
      return name.contains(_searchQuery) ||
          username.contains(_searchQuery) ||
          email.contains(_searchQuery) ||
          phone.contains(_searchQuery);
    }).toList();
  }

  String _getFullName(APIUserResponse user) {
    final parts = [user.lastName, user.firstName, user.middleName]
        .where((s) => s != null && s.trim().isNotEmpty)
        .map((s) => s!.trim())
        .toList();
    if (parts.isNotEmpty) return parts.join(' ');
    if (user.fullName?.trim().isNotEmpty == true) return user.fullName!.trim();
    return user.username;
  }

  String _getInitials(APIUserResponse user) {
    final first = user.firstName?.trim() ?? '';
    final last = user.lastName?.trim() ?? '';
    if (first.isNotEmpty && last.isNotEmpty) {
      return '${first[0]}${last[0]}'.toUpperCase();
    }
    if (user.username.isNotEmpty) {
      return user.username.substring(0, user.username.length >= 2 ? 2 : 1).toUpperCase();
    }
    return '?';
  }

  String _getLastSeenText(int userId, UsersState usersState) {
    final isOnline = usersState.isUserOnline(userId);
    final lastSeen = usersState.lastSeenFor(userId);
    return TimeFormatter.formatActivitySummary(
      isOnline: isOnline,
      lastLoginAt: lastSeen,
    );
  }

  Color _getAvatarColor(APIUserResponse user) {
    final colors = [
      Colors.blue, Colors.purple, Colors.teal, Colors.orange,
      Colors.pink, Colors.indigo, Colors.green, Colors.red,
    ];
    return colors[user.id % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    // Watch the provider — rebuilds on any presence/user change
    final usersState = ref.watch(usersWithPresenceProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Закрыть',
              style: TextStyle(color: AppTheme.primaryBlue, fontSize: 15)),
        ),
        leadingWidth: 80,
        title: Text('Управление пользователями',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600, fontSize: 17)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppTheme.primaryBlue, size: 28),
            onPressed: () => _showCreateUserDialog(context),
          ),
        ],
      ),
      body: usersState.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue))
          : usersState.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: AppTheme.errorRed, size: 48),
                      const SizedBox(height: 16),
                      Text(usersState.error!, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(180), fontSize: 16)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(usersWithPresenceProvider.notifier).refresh();
                        },
                        child: const Text('Повторить'),
                      ),
                    ],
                  ),
                )
              : _buildUserList(usersState),
    );
  }

  Widget _buildUserList(UsersState usersState) {
    final filtered = _applySearch(usersState.users);
    final activeUsers = filtered.where((u) => u.isActive && u.isBlocked != true).toList();
    final deactivatedUsers = filtered.where((u) => !u.isActive && u.isBlocked != true).toList();
    final blockedUsers = filtered.where((u) => u.isBlocked == true).toList();

    // Сортировка: онлайн-пользователи поднимаются вверх, затем по имени
    int compareByOnlineThenName(APIUserResponse a, APIUserResponse b) {
      final aOnline = usersState.isUserOnline(a.id);
      final bOnline = usersState.isUserOnline(b.id);
      if (aOnline != bOnline) return aOnline ? -1 : 1;
      return _getFullName(a).toLowerCase().compareTo(_getFullName(b).toLowerCase());
    }

    activeUsers.sort(compareByOnlineThenName);
    deactivatedUsers.sort(compareByOnlineThenName);
    blockedUsers.sort(compareByOnlineThenName);

    return RefreshIndicator(
      onRefresh: () => ref.read(usersWithPresenceProvider.notifier).refresh(),
      color: AppTheme.primaryBlue,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SizedBox(height: 8),
          // Search bar
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Поиск пользователей...',
                hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(97)),
                prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurface.withAlpha(97), size: 20),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Theme.of(context).colorScheme.onSurface.withAlpha(97), size: 18),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Show on map toggle
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text('Показывать пользователей на карте',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 15)),
                ),
                Switch.adaptive(
                  value: _showUsersOnMap,
                  onChanged: (v) => setState(() => _showUsersOnMap = v),
                  activeThumbColor: AppTheme.successGreen,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Active users
          if (activeUsers.isNotEmpty) ...[
            _buildUserSectionHeader('Активные'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  for (int i = 0; i < activeUsers.length; i++) ...[
                    _buildUserTile(activeUsers[i], usersState),
                    if (i < activeUsers.length - 1)
                      Divider(
                        height: 1,
                        color: Theme.of(context).colorScheme.onSurface.withAlpha(15),
                        indent: 72,
                        endIndent: 16,
                      ),
                  ],
                ],
              ),
            ),
          ],

          // Deactivated users (can be re-activated via toggle)
          if (deactivatedUsers.isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildUserSectionHeader('Деактивированные'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  for (int i = 0; i < deactivatedUsers.length; i++) ...[
                    _buildUserTile(deactivatedUsers[i], usersState, isDeactivated: true),
                    if (i < deactivatedUsers.length - 1)
                      Divider(
                        height: 1,
                        color: Theme.of(context).colorScheme.onSurface.withAlpha(15),
                        indent: 72,
                        endIndent: 16,
                      ),
                  ],
                ],
              ),
            ),
          ],

          // Blocked users (toggle disabled — must unblock first)
          if (blockedUsers.isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildUserSectionHeader('Заблокированные'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  for (int i = 0; i < blockedUsers.length; i++) ...[
                    _buildUserTile(blockedUsers[i], usersState, isBlocked: true),
                    if (i < blockedUsers.length - 1)
                      Divider(
                        height: 1,
                        color: Theme.of(context).colorScheme.onSurface.withAlpha(15),
                        indent: 72,
                        endIndent: 16,
                      ),
                  ],
                ],
              ),
            ),
          ],

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildUserSectionHeader(String title) {
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

  Widget _buildUserTile(APIUserResponse user, UsersState usersState, {bool isBlocked = false, bool isDeactivated = false}) {
    final fullName = _getFullName(user);
    final position = user.position?.trim() ?? '';
    final role = user.role.title;
    final phone = user.phoneNumber ?? '';
    final email = user.email;
    final lastSeen = _getLastSeenText(user.id, usersState);
    final isOnline = usersState.isUserOnline(user.id);

    // Build subtitle parts
    final subtitleParts = <String>[];
    subtitleParts.add(user.username); // Добавляем логин (username) всегда
    if (position.isNotEmpty) subtitleParts.add(position);
    if (email.isNotEmpty) subtitleParts.add(email);
    if (phone.isNotEmpty) subtitleParts.add(phone);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => UserProfileScreen(user: user)),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar with online indicator
            Stack(
              children: [
                UserAvatarWidget(
                  avatarUrl: user.avatarUrl,
                  displayName: _getFullName(user),
                  userId: user.id,
                  radius: 22,
                ),
                // Online indicator dot
                if (isOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppTheme.successGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: Theme.of(context).colorScheme.surface, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          fullName,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isBlocked
                              ? AppTheme.errorRed.withAlpha(30)
                              : isDeactivated
                                  ? AppTheme.warningOrange.withAlpha(30)
                                  : AppTheme.successGreen.withAlpha(30),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isBlocked ? 'Заблокирован' : isDeactivated ? 'Деактивирован' : 'Активен',
                          style: TextStyle(
                            color: isBlocked ? AppTheme.errorRed : isDeactivated ? AppTheme.warningOrange : AppTheme.successGreen,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (subtitleParts.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      '$role • ${subtitleParts.join(' • ')}',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(140), fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (lastSeen.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      lastSeen,
                      style: TextStyle(
                        color: isOnline ? AppTheme.successGreen : Theme.of(context).colorScheme.onSurface.withAlpha(97),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Toggle active/deactive
            Switch.adaptive(
              value: user.isActive && !isBlocked,
              onChanged: isBlocked ? null : (newValue) async {
                // Allow re-activation of deactivated users
                // Prevent self-deactivation
                final authService = ref.read(authServiceProvider);
                try {
                  final me = await authService.getCurrentUser();
                  if (me.id == user.id) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Невозможно деактивировать самого себя'),
                          backgroundColor: AppTheme.errorRed,
                        ),
                      );
                    }
                    return;
                  }
                } catch (_) {}

                if (!newValue) {
                  // Confirm deactivation
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      title: Text('Деактивация', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                      content: Text(
                        'Деактивировать пользователя ${_getFullName(user)}?\n\nПользователь будет отключён от системы и не сможет войти.',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(180)),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Отмена'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Деактивировать',
                              style: TextStyle(color: AppTheme.errorRed)),
                        ),
                      ],
                    ),
                  );
                  if (confirmed != true) return;
                }

                final success = await ref
                    .read(usersWithPresenceProvider.notifier)
                    .toggleUserActive(user.id, newValue);

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? (newValue ? '${_getFullName(user)} активирован' : '${_getFullName(user)} деактивирован')
                            : 'Ошибка. Проверьте права доступа.',
                      ),
                      backgroundColor: success ? AppTheme.successGreen : AppTheme.errorRed,
                    ),
                  );
                }
              },
              activeThumbColor: AppTheme.primaryBlue,
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // Create User Dialog
  // ═══════════════════════════════════════════════════

  void _showCreateUserDialog(BuildContext context) {
    final usernameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    final lastNameCtrl = TextEditingController();
    final firstNameCtrl = TextEditingController();
    final middleNameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final positionCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    UserRole selectedRole = UserRole.viewer;
    bool isLoading = false;
    String? errorMessage;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: Text('Новый пользователь', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (errorMessage != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.errorRed.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(errorMessage!, style: const TextStyle(color: AppTheme.errorRed, fontSize: 13)),
                    ),
                  _buildDialogField(usernameCtrl, 'Логин *', TextInputType.text, autocapitalize: false),
                  _buildDialogField(emailCtrl, 'Email *', TextInputType.emailAddress, autocapitalize: false),
                  _buildDialogField(passwordCtrl, 'Пароль *', TextInputType.visiblePassword, obscure: true),
                  const SizedBox(height: 8),
                  _buildDialogField(lastNameCtrl, 'Фамилия', TextInputType.name),
                  _buildDialogField(firstNameCtrl, 'Имя', TextInputType.name),
                  _buildDialogField(middleNameCtrl, 'Отчество', TextInputType.name),
                  _buildDialogField(phoneCtrl, 'Телефон', TextInputType.phone),
                  _buildDialogField(positionCtrl, 'Должность', TextInputType.text),
                  _buildDialogField(notesCtrl, 'Заметки', TextInputType.multiline, maxLines: 2),
                  const SizedBox(height: 8),
                  // Role selector
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).colorScheme.onSurface.withAlpha(40)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<UserRole>(
                        value: selectedRole,
                        isExpanded: true,
                        dropdownColor: Theme.of(context).colorScheme.surface,
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 15),
                        items: UserRole.values.map((r) => DropdownMenuItem(
                          value: r,
                          child: Text(r.title),
                        )).toList(),
                        onChanged: (r) {
                          if (r != null) setDialogState(() => selectedRole = r);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(ctx),
                child: const Text('Отмена'),
              ),
              ElevatedButton(
                onPressed: isLoading ? null : () async {
                  final username = usernameCtrl.text.trim();
                  final email = emailCtrl.text.trim();
                  final password = passwordCtrl.text;

                  if (username.isEmpty || email.isEmpty || password.isEmpty) {
                    setDialogState(() => errorMessage = 'Логин, Email и Пароль обязательны');
                    return;
                  }
                  if (password.length < 8) {
                    setDialogState(() => errorMessage = 'Пароль должен содержать минимум 8 символов');
                    return;
                  }

                  setDialogState(() { isLoading = true; errorMessage = null; });

                  try {
                    final userService = ref.read(userServiceProvider);
                    await userService.registerUser(
                      username: username,
                      email: email,
                      password: password,
                      lastName: lastNameCtrl.text.trim(),
                      firstName: firstNameCtrl.text.trim(),
                      middleName: middleNameCtrl.text.trim(),
                      phoneNumber: phoneCtrl.text.trim(),
                      position: positionCtrl.text.trim(),
                      notes: notesCtrl.text.trim(),
                      role: selectedRole.serverValue,
                    );

                    if (ctx.mounted) Navigator.pop(ctx);
                    // Refresh the user list
                    ref.read(usersWithPresenceProvider.notifier).refresh();

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Пользователь $username создан'),
                          backgroundColor: AppTheme.successGreen,
                        ),
                      );
                    }
                  } on DioException catch (e) {
                    final detail = e.response?.data is Map ? (e.response?.data['detail'] ?? e.message) : e.message;
                    setDialogState(() {
                      isLoading = false;
                      errorMessage = detail?.toString() ?? 'Ошибка сервера';
                    });
                  } catch (e) {
                    setDialogState(() {
                      isLoading = false;
                      errorMessage = e.toString();
                    });
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
                child: isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Создать', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDialogField(
    TextEditingController controller,
    String label,
    TextInputType keyboardType, {
    bool obscure = false,
    bool autocapitalize = true,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscure,
        maxLines: maxLines,
        textCapitalization: autocapitalize ? TextCapitalization.words : TextCapitalization.none,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 15),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(130), fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface.withAlpha(40)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppTheme.primaryBlue),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
// User Profile Screen (detailed profile view)
// ═══════════════════════════════════════════════════

class UserProfileScreen extends ConsumerWidget {
  final APIUserResponse user;

  const UserProfileScreen({super.key, required this.user});

  String _getFullName() {
    final parts = [user.lastName, user.firstName, user.middleName]
        .where((s) => s != null && s.trim().isNotEmpty)
        .map((s) => s!.trim())
        .toList();
    if (parts.isNotEmpty) return parts.join(' ');
    if (user.fullName?.trim().isNotEmpty == true) return user.fullName!.trim();
    return user.username;
  }

  String _getInitials() {
    final first = user.firstName?.trim() ?? '';
    final last = user.lastName?.trim() ?? '';
    if (first.isNotEmpty && last.isNotEmpty) {
      return '${first[0]}${last[0]}'.toUpperCase();
    }
    if (user.username.isNotEmpty) {
      return user.username.substring(0, user.username.length >= 2 ? 2 : 1).toUpperCase();
    }
    return '?';
  }

  Color _getAvatarColor() {
    final colors = [
      Colors.blue, Colors.purple, Colors.teal, Colors.orange,
      Colors.pink, Colors.indigo, Colors.green, Colors.red,
    ];
    return colors[user.id % colors.length];
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '—';
    try {
      final dt = DateTime.parse(dateStr);
      return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
    } catch (_) {
      return dateStr;
    }
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return '—';
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = dt.year;
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day.$month.$year $hour:$minute';
  }

  void _open2GIS(BuildContext context, double lat, double lng) {
    if (lat == 0 && lng == 0) return;
    final uri = Uri.parse('https://2gis.ru/search/$lat,$lng');
    launchUrl(uri, mode: LaunchMode.externalApplication).catchError((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось открыть 2GIS')),
      );
      return false;
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Подписываемся на presence — UI перестраивается при смене онлайн/оффлайн
    final usersState = ref.watch(usersWithPresenceProvider);
    final isOnline = usersState.isUserOnline(user.id);
    final lastSeen = usersState.lastSeenFor(user.id);
    final hasLocation = usersState.hasLocationFor(user.id);
    final lat = usersState.lastLatFor(user.id) ?? 0;
    final lng = usersState.lastLngFor(user.id) ?? 0;

    // Определяем текст «Последний вход»
    final lastSeenText = TimeFormatter.formatActivitySummary(
      isOnline: isOnline,
      lastLoginAt: lastSeen,
    );

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
          IconButton(
            icon: Icon(Icons.more_horiz, color: Theme.of(context).colorScheme.onSurface.withAlpha(140), size: 24),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Avatar
            UserAvatarWidget(
              avatarUrl: user.avatarUrl,
              displayName: _getFullName(),
              userId: user.id,
              radius: 40,
            ),
            const SizedBox(height: 16),

            // Name
            Text(
              _getFullName(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),

            // Position
            if (user.position?.isNotEmpty == true)
              Text(
                user.position!,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(140), fontSize: 15),
              ),
            const SizedBox(height: 8),

            // Online status indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: isOnline
                    ? AppTheme.successGreen.withAlpha(30)
                    : user.isActive
                        ? Theme.of(context).colorScheme.onSurface.withAlpha(15)
                        : AppTheme.errorRed.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isOnline ? '● Онлайн' : (user.isActive ? 'Оффлайн' : 'Заблокирован'),
                style: TextStyle(
                  color: isOnline ? AppTheme.successGreen : (user.isActive ? Theme.of(context).colorScheme.onSurface.withAlpha(140) : AppTheme.errorRed),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(context, Icons.edit, 'Редакт.', AppTheme.successGreen, () {
                  _showEditUserDialog(context, ref, user);
                }),
                _buildActionButton(
                  context,
                  Icons.map_outlined,
                  'На карте',
                  hasLocation ? AppTheme.primaryBlue : Theme.of(context).colorScheme.onSurface.withAlpha(60),
                  hasLocation
                      ? () => _open2GIS(context, lat, lng)
                      : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Местоположение пока неизвестно')),
                          );
                        },
                ),
                _buildActionButton(context, Icons.vpn_key, 'Пароль', AppTheme.warningOrange, () {
                  _showChangePasswordDialog(context, ref, user);
                }),
                _buildActionButton(context, Icons.article_outlined, 'Журнал', Colors.purpleAccent, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ActionLogListScreen(initialUserId: user.id),
                    ),
                  );
                }),
              ],
            ),

            const SizedBox(height: 12),

            // Reassign sites button (second row)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(context, Icons.swap_horiz, 'Передать\nучастки', Colors.deepOrangeAccent, () {
                  _showReassignDialog(context, ref);
                }),
              ],
            ),

            const SizedBox(height: 24),

            // Data section
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Row(
                  children: [
                    Icon(Icons.list_alt, color: Theme.of(context).colorScheme.onSurface.withAlpha(140), size: 16),
                    const SizedBox(width: 6),
                    Text('Данные',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(140), fontSize: 13, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  _buildDataRow(context, 'ФИО', _getFullName()),
                  _buildRowDivider(context),
                  _buildDataRow(context, 'Должность', user.position ?? '—'),
                  _buildRowDivider(context),
                  _buildDataRow(context, 'Роль', user.role.title),
                  _buildRowDivider(context),
                  _buildDataRow(
                    context,
                    'Offline-доступ',
                    user.canEditOffline ? 'Включён' : 'Отключён',
                    valueColor: user.canEditOffline ? AppTheme.successGreen : AppTheme.errorRed,
                  ),
                  _buildRowDivider(context),
                  _buildDataRow(context, 'Создан', _formatDate(user.createdAt)),
                  _buildRowDivider(context),
                  _buildDataRow(
                    context,
                    'Последний\nвход',
                    lastSeenText,
                    valueColor: isOnline ? AppTheme.successGreen : null,
                  ),
                  // Кнопка «Последнее местоположение» — если есть координаты
                  if (hasLocation) ...[
                    _buildRowDivider(context),
                    _buildLocationRow(context, lat, lng),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationRow(BuildContext context, double lat, double lng) {
    return InkWell(
      onTap: () => _open2GIS(context, lat, lng),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            const Icon(Icons.location_on, color: Colors.blue, size: 18),
            const SizedBox(width: 8),
            const Expanded(
              child: Text('Последнее\nместоположение', style: TextStyle(color: Colors.blue, fontSize: 15)),
            ),
            const Icon(Icons.open_in_new, color: Colors.blue, size: 16),
            const SizedBox(width: 4),
            const Text('Найти на 2GIS', style: TextStyle(color: Colors.blue, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(140), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildDataRow(BuildContext context, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(140), fontSize: 15)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(color: valueColor ?? Theme.of(context).colorScheme.onSurface, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRowDivider(BuildContext context) {
    return Divider(
      height: 1,
      color: Theme.of(context).colorScheme.onSurface.withAlpha(15),
      indent: 16,
      endIndent: 16,
    );
  }

  // ═══════════════════════════════════════════════════
  // Edit User Dialog
  // ═══════════════════════════════════════════════════

  static void _showEditUserDialog(BuildContext context, WidgetRef ref, APIUserResponse user) {
    final usernameCtrl = TextEditingController(text: user.username);
    final emailCtrl = TextEditingController(text: user.email);
    final lastNameCtrl = TextEditingController(text: user.lastName ?? '');
    final firstNameCtrl = TextEditingController(text: user.firstName ?? '');
    final middleNameCtrl = TextEditingController(text: user.middleName ?? '');
    final phoneCtrl = TextEditingController(text: user.phoneNumber ?? '');
    final positionCtrl = TextEditingController(text: user.position ?? '');
    final notesCtrl = TextEditingController(text: '');
    UserRole selectedRole = user.role;
    bool canEditOffline = user.canEditOffline;
    bool isLoading = false;
    String? errorMessage;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          Widget buildField(
            TextEditingController controller,
            String label,
            TextInputType keyboardType, {
            bool autocapitalize = true,
            int maxLines = 1,
          }) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TextField(
                controller: controller,
                keyboardType: keyboardType,
                maxLines: maxLines,
                textCapitalization: autocapitalize ? TextCapitalization.words : TextCapitalization.none,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 15),
                decoration: InputDecoration(
                  labelText: label,
                  labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(130), fontSize: 14),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface.withAlpha(40)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppTheme.primaryBlue),
                  ),
                ),
              ),
            );
          }

          return AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: Text('Редактирование: ${user.username}', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600, fontSize: 16)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (errorMessage != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.errorRed.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(errorMessage!, style: const TextStyle(color: AppTheme.errorRed, fontSize: 13)),
                    ),
                  buildField(usernameCtrl, 'Логин', TextInputType.text, autocapitalize: false),
                  buildField(emailCtrl, 'Email', TextInputType.emailAddress, autocapitalize: false),
                  buildField(lastNameCtrl, 'Фамилия', TextInputType.name),
                  buildField(firstNameCtrl, 'Имя', TextInputType.name),
                  buildField(middleNameCtrl, 'Отчество', TextInputType.name),
                  buildField(phoneCtrl, 'Телефон', TextInputType.phone),
                  buildField(positionCtrl, 'Должность', TextInputType.text),
                  buildField(notesCtrl, 'Заметки', TextInputType.multiline, maxLines: 2),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).colorScheme.onSurface.withAlpha(40)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<UserRole>(
                        value: selectedRole,
                        isExpanded: true,
                        dropdownColor: Theme.of(context).colorScheme.surface,
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 15),
                        items: UserRole.values.map((r) => DropdownMenuItem(
                          value: r,
                          child: Text(r.title),
                        )).toList(),
                        onChanged: (r) {
                          if (r != null) setDialogState(() => selectedRole = r);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Offline-доступ Switch
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).colorScheme.onSurface.withAlpha(40)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Offline-доступ',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                'Редактирование без интернета',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface.withAlpha(130),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: canEditOffline,
                          activeColor: AppTheme.primaryBlue,
                          onChanged: (v) => setDialogState(() => canEditOffline = v),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(ctx),
                child: const Text('Отмена'),
              ),
              ElevatedButton(
                onPressed: isLoading ? null : () async {
                  setDialogState(() { isLoading = true; errorMessage = null; });

                  try {
                    final userService = ref.read(userServiceProvider);
                    await userService.updateUserByAdmin(
                      userId: user.id,
                      username: usernameCtrl.text.trim() != user.username ? usernameCtrl.text.trim() : null,
                      email: emailCtrl.text.trim() != user.email ? emailCtrl.text.trim() : null,
                      lastName: lastNameCtrl.text.trim(),
                      firstName: firstNameCtrl.text.trim(),
                      middleName: middleNameCtrl.text.trim(),
                      phoneNumber: phoneCtrl.text.trim(),
                      position: positionCtrl.text.trim(),
                      notes: notesCtrl.text.trim().isNotEmpty ? notesCtrl.text.trim() : null,
                      role: selectedRole != user.role ? selectedRole.serverValue : null,
                      canEditOffline: canEditOffline != user.canEditOffline ? canEditOffline : null,
                    );

                    if (ctx.mounted) Navigator.pop(ctx);
                    ref.read(usersWithPresenceProvider.notifier).refresh();

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Пользователь ${usernameCtrl.text.trim()} обновлён'),
                          backgroundColor: AppTheme.successGreen,
                        ),
                      );
                    }
                  } on DioException catch (e) {
                    final detail = e.response?.data is Map ? (e.response?.data['detail'] ?? e.message) : e.message;
                    setDialogState(() {
                      isLoading = false;
                      errorMessage = detail?.toString() ?? 'Ошибка сервера';
                    });
                  } catch (e) {
                    setDialogState(() {
                      isLoading = false;
                      errorMessage = e.toString();
                    });
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
                child: isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Сохранить', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // Change Password Dialog
  // ═══════════════════════════════════════════════════

  static void _showChangePasswordDialog(BuildContext context, WidgetRef ref, APIUserResponse user) {
    final passwordCtrl = TextEditingController();
    bool isLoading = false;
    String? errorMessage;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: Text('Сменить пароль: ${user.username}', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600, fontSize: 16)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (errorMessage != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.errorRed.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(errorMessage!, style: const TextStyle(color: AppTheme.errorRed, fontSize: 13)),
                  ),
                TextField(
                  controller: passwordCtrl,
                  obscureText: true,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 15),
                  decoration: InputDecoration(
                    labelText: 'Новый пароль',
                    labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(130), fontSize: 14),
                    helperText: 'Минимум 8 символов, заглавная, строчная, цифра',
                    helperStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(97), fontSize: 12),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface.withAlpha(40)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppTheme.primaryBlue),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(ctx),
                child: const Text('Отмена'),
              ),
              ElevatedButton(
                onPressed: isLoading ? null : () async {
                  final password = passwordCtrl.text;
                  if (password.length < 8) {
                    setDialogState(() => errorMessage = 'Пароль должен содержать минимум 8 символов');
                    return;
                  }

                  setDialogState(() { isLoading = true; errorMessage = null; });

                  try {
                    final userService = ref.read(userServiceProvider);
                    await userService.changeUserPasswordByAdmin(
                      userId: user.id,
                      newPassword: password,
                    );

                    if (ctx.mounted) Navigator.pop(ctx);

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Пароль ${user.username} изменён'),
                          backgroundColor: AppTheme.successGreen,
                        ),
                      );
                    }
                  } on DioException catch (e) {
                    final detail = e.response?.data is Map ? (e.response?.data['detail'] ?? e.message) : e.message;
                    setDialogState(() {
                      isLoading = false;
                      errorMessage = detail?.toString() ?? 'Ошибка сервера';
                    });
                  } catch (e) {
                    setDialogState(() {
                      isLoading = false;
                      errorMessage = e.toString();
                    });
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.warningOrange),
                child: isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Сменить', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // Reassign Sites Dialog
  // ═══════════════════════════════════════════════════

  void _showReassignDialog(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.read(usersProvider);
    
    usersAsync.when(
      data: (users) {
        // Filter managers (exclude current user)
        final managers = users
            .where((u) => u.role == UserRole.manager && u.id != user.id)
            .toList();
        
        if (managers.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Нет доступных начальников участка для передачи')),
          );
          return;
        }

        APIUserResponse? selectedManager;
        bool isLoading = false;

        showDialog(
          context: context,
          builder: (ctx) => StatefulBuilder(
            builder: (ctx, setDialogState) {
              return AlertDialog(
                backgroundColor: Theme.of(context).colorScheme.surface,
                title: Text(
                  'Передать участки от\n${_getFullName()}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Все котельные этого начальника будут переданы выбранному сотруднику. Номер участка также изменится.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withAlpha(140),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<APIUserResponse>(
                      value: selectedManager,
                      dropdownColor: Theme.of(context).colorScheme.surface,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: 'Новый начальник',
                        labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(140)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: managers.map((m) {
                        final name = [m.lastName, m.firstName, m.middleName]
                            .where((s) => s != null && s.trim().isNotEmpty)
                            .map((s) => s!.trim())
                            .join(' ');
                        final label = name.isNotEmpty ? name : m.username;
                        return DropdownMenuItem<APIUserResponse>(
                          value: m,
                          child: Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                        );
                      }).toList(),
                      onChanged: (v) => setDialogState(() => selectedManager = v),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text('Отмена', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(140))),
                  ),
                  ElevatedButton(
                    onPressed: selectedManager == null || isLoading
                        ? null
                        : () async {
                            setDialogState(() => isLoading = true);
                            try {
                              final result = await ref.read(boilerHouseServiceProvider).reassignManager(
                                    oldManagerId: user.id,
                                    newManagerId: selectedManager!.id,
                                  );
                              if (ctx.mounted) {
                                Navigator.pop(ctx);
                              }
                              if (context.mounted) {
                                final newName = [selectedManager!.lastName, selectedManager!.firstName]
                                    .where((s) => s != null && s.trim().isNotEmpty)
                                    .map((s) => s!.trim())
                                    .join(' ');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('✅ Передано ${result.updatedCount} котельных → $newName'),
                                    backgroundColor: AppTheme.successGreen,
                                  ),
                                );
                              }
                            } on DioException catch (e) {
                              final detail = e.response?.data is Map
                                  ? (e.response?.data['detail'] ?? e.message)
                                  : e.message;
                              setDialogState(() => isLoading = false);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Ошибка: $detail'),
                                    backgroundColor: AppTheme.errorRed,
                                  ),
                                );
                              }
                            } catch (e) {
                              setDialogState(() => isLoading = false);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Ошибка: $e'), backgroundColor: AppTheme.errorRed),
                                );
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrangeAccent),
                    child: isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Передать', style: TextStyle(color: Colors.white)),
                  ),
                ],
              );
            },
          ),
        );
      },
      loading: () => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Загрузка пользователей...')),
      ),
      error: (err, _) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $err')),
      ),
    );
  }
}
