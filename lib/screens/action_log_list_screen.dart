import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/action_log_models.dart';
import '../providers/action_log_providers.dart';
import '../services/action_log_service.dart';
import '../utils/app_theme.dart';
import 'package:intl/intl.dart';

class ActionLogListScreen extends ConsumerStatefulWidget {
  const ActionLogListScreen({super.key});

  @override
  ConsumerState<ActionLogListScreen> createState() =>
      _ActionLogListScreenState();
}

class _ActionLogListScreenState extends ConsumerState<ActionLogListScreen> {
  int? _selectedUserId;
  String? _selectedEntityType;
  String? _selectedActionType;
  int _offset = 0;
  final int _pageSize = 50;
  List<ActionLogEntry> _allLogs = [];
  bool _hasMore = true;
  bool _isLoadingMore = false;
  bool _flushing = false;
  final ScrollController _scrollController = ScrollController();

  static const List<_EntityOption> _entityOptions = [
    _EntityOption('Все', null),
    _EntityOption('Котельные', 'boiler_house'),
    _EntityOption('Дома', 'saved_location'),
    _EntityOption('Инциденты', 'incident'),
    _EntityOption('Пользователи', 'user'),
    _EntityOption('Лицевые счета', 'account'),
    _EntityOption('УК', 'management_company'),
  ];

  static const List<_EntityOption> _actionOptions = [
    _EntityOption('Все', null),
    _EntityOption('Создание', 'create'),
    _EntityOption('Обновление', 'update'),
    _EntityOption('Удаление', 'delete'),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Fire request-flush when entering the journal
    WidgetsBinding.instance.addPostFrameCallback((_) => _requestFlush());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMore) {
      _loadMore();
    }
  }

  Future<void> _requestFlush() async {
    setState(() => _flushing = true);
    try {
      final service = ref.read(actionLogServiceProvider);
      await service.requestFlush();
    } catch (_) {
      // Ignore flush errors; this is best-effort
    }
    if (mounted) setState(() => _flushing = false);
  }

  void _resetAndLoad() {
    setState(() {
      _offset = 0;
      _allLogs = [];
      _hasMore = true;
    });
    // Invalidate the provider to re-fetch
    ref.invalidate(actionLogListProvider(_currentFilter));
  }

  ActionLogFilter get _currentFilter => ActionLogFilter(
        limit: _pageSize,
        offset: _offset,
        userId: _selectedUserId,
        entityType: _selectedEntityType,
        actionType: _selectedActionType,
      );

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);
    try {
      final service = ref.read(actionLogServiceProvider);
      final newLogs = await service.getActionLogs(
        limit: _pageSize,
        offset: _offset + _pageSize,
        userId: _selectedUserId,
        entityType: _selectedEntityType,
        actionType: _selectedActionType,
      );
      setState(() {
        _offset += _pageSize;
        _allLogs.addAll(newLogs);
        _hasMore = newLogs.length >= _pageSize;
        _isLoadingMore = false;
      });
    } catch (_) {
      setState(() => _isLoadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(actionLogListProvider(_currentFilter));
    final usersAsync = ref.watch(actionLogUsersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Журнал действий'),
        actions: [
          if (_flushing)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _requestFlush();
              _resetAndLoad();
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: _buildFilterBar(usersAsync),
        ),
      ),
      body: logsAsync.when(
        skipLoadingOnReload: true,
        data: (firstPage) {
          // Merge first page into accumulated list (only when offset == 0)
          if (_offset == 0 && _allLogs.isEmpty) {
            _allLogs = List.from(firstPage);
            _hasMore = firstPage.length >= _pageSize;
          }
          return _buildLogList();
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: AppTheme.errorRed),
                const SizedBox(height: 12),
                Text('Ошибка загрузки журнала:\n$err',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _resetAndLoad,
                  child: const Text('Повторить'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBar(AsyncValue<List<ActionLogUser>> usersAsync) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // Entity type filter
          _buildDropdown<String?>(
            value: _selectedEntityType,
            items: _entityOptions.map((o) {
              return DropdownMenuItem<String?>(
                value: o.value,
                child: Text(o.label, style: const TextStyle(fontSize: 13)),
              );
            }).toList(),
            onChanged: (v) {
              _selectedEntityType = v;
              _resetAndLoad();
            },
            hint: 'Тип объекта',
          ),
          const SizedBox(width: 8),
          // Action type filter
          _buildDropdown<String?>(
            value: _selectedActionType,
            items: _actionOptions.map((o) {
              return DropdownMenuItem<String?>(
                value: o.value,
                child: Text(o.label, style: const TextStyle(fontSize: 13)),
              );
            }).toList(),
            onChanged: (v) {
              _selectedActionType = v;
              _resetAndLoad();
            },
            hint: 'Действие',
          ),
          const SizedBox(width: 8),
          // User filter
          usersAsync.whenOrNull(
                data: (users) {
                  final items = <DropdownMenuItem<int?>>[
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('Все', style: TextStyle(fontSize: 13)),
                    ),
                    ...users.map((u) => DropdownMenuItem<int?>(
                          value: u.id,
                          child: Text(u.displayName,
                              style: const TextStyle(fontSize: 13)),
                        )),
                  ];
                  return _buildDropdown<int?>(
                    value: _selectedUserId,
                    items: items,
                    onChanged: (v) {
                      _selectedUserId = v;
                      _resetAndLoad();
                    },
                    hint: 'Пользователь',
                  );
                },
              ) ??
              const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    required String hint,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.tertiaryDarkBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          dropdownColor: AppTheme.tertiaryDarkBackground,
          isDense: true,
          hint: Text(hint,
              style: const TextStyle(fontSize: 13, color: Colors.white54)),
          style: const TextStyle(fontSize: 13, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildLogList() {
    if (_allLogs.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('Журнал действий пуст',
              style: TextStyle(color: Colors.white54, fontSize: 16)),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _requestFlush();
        _resetAndLoad();
      },
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _allLogs.length + (_hasMore ? 1 : 0),
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (context, index) {
          if (index >= _allLogs.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return _buildLogTile(_allLogs[index]);
        },
      ),
    );
  }

  Widget _buildLogTile(ActionLogEntry log) {
    final dateStr = DateFormat('dd.MM.yy HH:mm').format(log.timestamp.toLocal());
    final icon = _iconForAction(log.actionType);
    final iconColor = _colorForAction(log.actionType);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withAlpha(20),
            width: 1,
          ),
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          title: Text(
            log.displayDescription,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Icon(Icons.person_outline,
                    size: 14, color: Colors.white54),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    log.userName ?? 'ID ${log.userId}',
                    style: const TextStyle(
                        fontSize: 12, color: Colors.white54),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.access_time,
                    size: 14, color: Colors.white54),
                const SizedBox(width: 4),
                Text(dateStr,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.white54)),
              ],
            ),
          ),
          onTap: () => _showLogDetails(log),
        ),
      ),
    );
  }

  void _showLogDetails(ActionLogEntry log) {
    final dateStr =
        DateFormat('dd.MM.yyyy HH:mm:ss').format(log.timestamp.toLocal());
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.secondaryDarkBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(log.displayDescription,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
              const SizedBox(height: 12),
              _detailRow('Пользователь',
                  log.userName ?? 'ID ${log.userId}'),
              _detailRow('Дата', dateStr),
              _detailRow('Тип действия', log.actionLabel),
              _detailRow('Тип объекта', log.entityLabel),
              _detailRow('ID объекта', '${log.entityId}'),
              if (log.deviceId != null)
                _detailRow('Устройство', log.deviceId!),
              if (log.changes != null && log.changes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text('Изменения:',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70)),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.tertiaryDarkBackground,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _formatChanges(log.changes!),
                    style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white60,
                        fontFamily: 'monospace'),
                  ),
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13, color: Colors.white54)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatChanges(Map<String, dynamic> changes) {
    final buf = StringBuffer();
    changes.forEach((key, value) {
      buf.writeln('$key: $value');
    });
    return buf.toString().trimRight();
  }

  IconData _iconForAction(String actionType) {
    switch (actionType) {
      case 'create':
        return Icons.add_circle_outline;
      case 'update':
        return Icons.edit_outlined;
      case 'delete':
        return Icons.delete_outline;
      case 'login':
        return Icons.login;
      case 'logout':
        return Icons.logout;
      default:
        return Icons.info_outline;
    }
  }

  Color _colorForAction(String actionType) {
    switch (actionType) {
      case 'create':
        return AppTheme.successGreen;
      case 'update':
        return AppTheme.primaryBlue;
      case 'delete':
        return AppTheme.errorRed;
      case 'login':
        return AppTheme.warningOrange;
      case 'logout':
        return AppTheme.warningOrange;
      default:
        return Colors.white54;
    }
  }
}

class _EntityOption {
  final String label;
  final String? value;
  const _EntityOption(this.label, this.value);
}
