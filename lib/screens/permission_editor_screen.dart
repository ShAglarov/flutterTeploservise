import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/base_api_service.dart';

/// Экран редактирования прав доступа пользователя (только admin).
///
/// Путь: Список пользователей → Карточка пользователя → «Управление правами»
///
/// API:
///   GET  /permissions/registry     — каталог ключей
///   GET  /permissions/{user_id}    — текущие права
///   PUT  /permissions/{user_id}    — дельта-обновление
///   POST /permissions/{user_id}/reset — сброс к пресету роли
class PermissionEditorScreen extends ConsumerStatefulWidget {
  final int userId;
  final String userName;

  const PermissionEditorScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  ConsumerState<PermissionEditorScreen> createState() => _PermissionEditorScreenState();
}

class _PermissionEditorScreenState extends ConsumerState<PermissionEditorScreen> {
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;
  String? _roleName;

  /// Все ключи из registry, группированные по категории.
  List<_PermissionSection> _sections = [];

  /// Текущие значения тумблеров.
  Map<String, bool> _values = {};

  /// Оригинальные значения (для определения дельты).
  Map<String, bool> _originalValues = {};

  bool get _hasChanges => _values.toString() != _originalValues.toString();

  @override
  void initState() {
    super.initState();
    _load();
  }

  // ─── Load ───

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });

    try {
      final dio = ref.read(dioProvider);

      // 1. Registry
      final registryResp = await dio.get('/permissions/registry');
      final registryItems = (registryResp.data['items'] as List? ?? [])
          .map((e) => _RegistryItem(
                key: e['key'] as String,
                description: e['description'] as String,
                category: e['category'] as String,
              ))
          .toList();

      // 2. User permissions
      final permResp = await dio.get('/permissions/${widget.userId}');
      final permData = permResp.data as Map<String, dynamic>;
      final rawPerms = (permData['permissions'] as Map<String, dynamic>? ?? {})
          .map((k, v) => MapEntry(k, v == true));
      final roleName = permData['role_display_name'] as String?;

      // Build sections
      final grouped = <String, List<_RegistryItem>>{};
      for (final item in registryItems) {
        grouped.putIfAbsent(item.category, () => []).add(item);
      }

      final sections = grouped.entries.map((e) {
        final items = e.value
            .map((r) => _PermissionItem(
                  key: r.key,
                  title: _localizedAction(r.key),
                  description: r.description,
                ))
            .toList()
          ..sort((a, b) => a.title.compareTo(b.title));

        return _PermissionSection(
          category: e.key,
          title: _localizedCategory(e.key),
          icon: _categoryIcon(e.key),
          items: items,
        );
      }).toList()
        ..sort((a, b) => a.title.compareTo(b.title));

      setState(() {
        _sections = sections;
        _values = Map.from(rawPerms);
        _originalValues = Map.from(rawPerms);
        _roleName = roleName;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Не удалось загрузить: ${e is DioException ? e.message : e}';
        _isLoading = false;
      });
    }
  }

  // ─── Save ───

  Future<void> _save() async {
    final delta = <String, bool>{};
    for (final entry in _values.entries) {
      if (_originalValues[entry.key] != entry.value) {
        delta[entry.key] = entry.value;
      }
    }
    if (delta.isEmpty) return;

    setState(() => _isSaving = true);

    try {
      final dio = ref.read(dioProvider);
      final resp = await dio.put(
        '/permissions/${widget.userId}',
        data: {'permissions': delta},
      );

      final newPerms = (resp.data['permissions'] as Map<String, dynamic>? ?? {})
          .map((k, v) => MapEntry(k, v == true));

      setState(() {
        _values = Map.from(newPerms);
        _originalValues = Map.from(newPerms);
        _isSaving = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Права обновлены'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Ошибка: ${e is DioException ? e.message : e}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ─── Reset ───

  Future<void> _resetToPreset() async {
    setState(() => _isSaving = true);
    try {
      final dio = ref.read(dioProvider);
      await dio.post('/permissions/${widget.userId}/reset');
      await _load();
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка сброса: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ─── Build ───

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Права: ${widget.userName}'),
        actions: [
          if (_hasChanges)
            _isSaving
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                : TextButton(
                    onPressed: _save,
                    child: const Text('Сохранить', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : _buildContent(theme),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning_amber_rounded, size: 48, color: Colors.orange),
          const SizedBox(height: 16),
          Text(_error!, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _load, child: const Text('Повторить')),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    return ListView(
      children: [
        // Preset header
        if (_roleName != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(Icons.shield_outlined, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Базовый пресет', style: theme.textTheme.labelSmall),
                          Text(_roleName!, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      onPressed: _isSaving ? null : _resetToPreset,
                      child: const Text('Сбросить', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Permission sections
        for (final section in _sections) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
            child: Row(
              children: [
                Icon(section.icon, size: 18, color: theme.colorScheme.secondary),
                const SizedBox(width: 8),
                Text(
                  section.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                for (int i = 0; i < section.items.length; i++) ...[
                  SwitchListTile(
                    title: Text(section.items[i].title, style: const TextStyle(fontSize: 14)),
                    subtitle: Text(section.items[i].description, style: const TextStyle(fontSize: 11)),
                    value: _values[section.items[i].key] ?? false,
                    activeColor: Colors.green,
                    onChanged: (val) {
                      setState(() => _values[section.items[i].key] = val);
                    },
                  ),
                  if (i < section.items.length - 1)
                    const Divider(height: 1, indent: 16, endIndent: 16),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: 32),
      ],
    );
  }

  // ─── Localization ───

  static String _localizedCategory(String category) {
    return switch (category) {
      'boiler_house' => 'Котельные',
      'saved_location' => 'Адреса',
      'account' => 'Лицевые счета',
      'incident' => 'Инциденты',
      'incident_comment' => 'Комментарии',
      'photo' => 'Фотографии',
      'management_company' => 'Управляющие компании',
      'report' => 'Отчёты',
      'operation_log' => 'Журнал работы',
      'user' => 'Пользователи',
      'action_log' => 'Журнал действий',
      'analytics' => 'Аналитика',
      'data' => 'Данные',
      'sync' => 'Синхронизация',
      'scope' => 'Видимость',
      _ => category.replaceAll('_', ' '),
    };
  }

  static IconData _categoryIcon(String category) {
    return switch (category) {
      'boiler_house' => Icons.local_fire_department,
      'saved_location' => Icons.location_on,
      'account' => Icons.account_balance_wallet,
      'incident' => Icons.warning_amber,
      'incident_comment' => Icons.chat_bubble_outline,
      'photo' => Icons.photo_camera,
      'management_company' => Icons.business,
      'report' => Icons.description,
      'operation_log' => Icons.list_alt,
      'user' => Icons.people,
      'action_log' => Icons.history,
      'analytics' => Icons.bar_chart,
      'data' => Icons.swap_vert,
      'sync' => Icons.sync,
      'scope' => Icons.visibility,
      _ => Icons.settings,
    };
  }

  static String _localizedAction(String key) {
    final action = key.split('.').last;
    return switch (action) {
      'read' => 'Просмотр',
      'create' => 'Создание',
      'update' => 'Редактирование',
      'delete' => 'Удаление',
      'export' => 'Экспорт',
      'import' => 'Импорт',
      'approve' => 'Утверждение',
      'assign' => 'Назначение',
      'manage_permissions' => 'Управление правами',
      'all_objects' => 'Все объекты',
      'all_incidents' => 'Все инциденты',
      'manage' => 'Управление',
      _ => action.replaceAll('_', ' '),
    };
  }
}

// ─── Data models ───

class _RegistryItem {
  final String key, description, category;
  _RegistryItem({required this.key, required this.description, required this.category});
}

class _PermissionSection {
  final String category, title;
  final IconData icon;
  final List<_PermissionItem> items;
  _PermissionSection({required this.category, required this.title, required this.icon, required this.items});
}

class _PermissionItem {
  final String key, title, description;
  _PermissionItem({required this.key, required this.title, required this.description});
}
