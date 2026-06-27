import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/api_models.dart';
import '../providers/auth_providers.dart';
import '../providers/user_presence_provider.dart';
import '../providers/theme_provider.dart';
import '../services/auth_service.dart';
import '../utils/app_theme.dart';
import '../utils/time_formatter.dart';
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
        backgroundColor: AppTheme.secondaryDarkBackground,
        title: const Text('Выход', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Вы уверены, что хотите выйти из аккаунта?',
          style: TextStyle(color: Colors.white70),
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
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBackground,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Настройки',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
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
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                user.role.title,
                style: const TextStyle(
                  color: Colors.white54,
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
              style: const TextStyle(
                color: Colors.white,
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
        style: const TextStyle(
          color: Colors.white54,
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
        style: const TextStyle(
          color: Colors.white38,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.secondaryDarkBackground,
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
      color: Colors.white.withAlpha(15),
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
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
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
    final currentTheme = ref.watch(themeProvider);
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
        onTap: () => ref.read(themeProvider.notifier).setTheme(pref),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? Colors.white.withAlpha(30) : Colors.black.withAlpha(20))
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
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white38, size: 20),
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
                color: titleColor ?? Colors.white,
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
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBackground,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Закрыть',
              style: TextStyle(color: AppTheme.primaryBlue, fontSize: 15)),
        ),
        leadingWidth: 80,
        title: const Text('Управление пользователями',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 17)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppTheme.primaryBlue, size: 28),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Создание пользователя скоро появится')),
              );
            },
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
                      Text(usersState.error!, style: const TextStyle(color: Colors.white70, fontSize: 16)),
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
              color: AppTheme.secondaryDarkBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Поиск пользователей...',
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: Colors.white38, size: 20),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white38, size: 18),
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
              color: AppTheme.secondaryDarkBackground,
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                const Expanded(
                  child: Text('Показывать пользователей на карте',
                      style: TextStyle(color: Colors.white, fontSize: 15)),
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
                color: AppTheme.secondaryDarkBackground,
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
                        color: Colors.white.withAlpha(15),
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
                color: AppTheme.secondaryDarkBackground,
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
                        color: Colors.white.withAlpha(15),
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
                color: AppTheme.secondaryDarkBackground,
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
                        color: Colors.white.withAlpha(15),
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
        style: const TextStyle(
          color: Colors.white54,
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
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _getAvatarColor(user),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _getInitials(user),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
                        border: Border.all(color: AppTheme.secondaryDarkBackground, width: 2),
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
                          style: const TextStyle(
                            color: Colors.white,
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
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (lastSeen.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      lastSeen,
                      style: TextStyle(
                        color: isOnline ? AppTheme.successGreen : Colors.white38,
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
                      backgroundColor: AppTheme.secondaryDarkBackground,
                      title: const Text('Деактивация', style: TextStyle(color: Colors.white)),
                      content: Text(
                        'Деактивировать пользователя ${_getFullName(user)}?\n\nПользователь будет отключён от системы и не сможет войти.',
                        style: const TextStyle(color: Colors.white70),
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
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBackground,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Профиль',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.white54, size: 24),
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
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _getAvatarColor(),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                _getInitials(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Name
            Text(
              _getFullName(),
              style: const TextStyle(
                color: Colors.white,
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
                style: const TextStyle(color: Colors.white54, fontSize: 15),
              ),
            const SizedBox(height: 8),

            // Online status indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: isOnline
                    ? AppTheme.successGreen.withAlpha(30)
                    : user.isActive
                        ? Colors.white.withAlpha(15)
                        : AppTheme.errorRed.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isOnline ? '● Онлайн' : (user.isActive ? 'Оффлайн' : 'Заблокирован'),
                style: TextStyle(
                  color: isOnline ? AppTheme.successGreen : (user.isActive ? Colors.white54 : AppTheme.errorRed),
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Редактирование скоро появится')),
                  );
                }),
                _buildActionButton(
                  context,
                  Icons.map_outlined,
                  'На карте',
                  hasLocation ? AppTheme.primaryBlue : Colors.white24,
                  hasLocation
                      ? () => _open2GIS(context, lat, lng)
                      : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Местоположение пока неизвестно')),
                          );
                        },
                ),
                _buildActionButton(context, Icons.vpn_key, 'Пароль', AppTheme.warningOrange, () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Сброс пароля скоро появится')),
                  );
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

            const SizedBox(height: 24),

            // Data section
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Row(
                  children: [
                    const Icon(Icons.list_alt, color: Colors.white54, size: 16),
                    const SizedBox(width: 6),
                    const Text('Данные',
                        style: TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            Container(
              decoration: BoxDecoration(
                color: AppTheme.secondaryDarkBackground,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  _buildDataRow('ФИО', _getFullName()),
                  _buildRowDivider(),
                  _buildDataRow('Должность', user.position ?? '—'),
                  _buildRowDivider(),
                  _buildDataRow('Роль', user.role.title),
                  _buildRowDivider(),
                  _buildDataRow('Создан', _formatDate(user.createdAt)),
                  _buildRowDivider(),
                  _buildDataRow(
                    'Последний\nвход',
                    lastSeenText,
                    valueColor: isOnline ? AppTheme.successGreen : null,
                  ),
                  // Кнопка «Последнее местоположение» — если есть координаты
                  if (hasLocation) ...[
                    _buildRowDivider(),
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
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildDataRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 15)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(color: valueColor ?? Colors.white, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRowDivider() {
    return Divider(
      height: 1,
      color: Colors.white.withAlpha(15),
      indent: 16,
      endIndent: 16,
    );
  }
}

