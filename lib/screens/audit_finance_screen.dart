import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/action_log_models.dart';
import '../providers/action_log_providers.dart';
import '../services/action_log_service.dart';
import '../utils/app_theme.dart';
import 'package:intl/intl.dart';

/// Экран аудита операций с лицевыми счетами и платёжными документами.
/// Доступен из Настройки → Платёжные документы → Аудит операций.
class AuditFinanceScreen extends ConsumerStatefulWidget {
  final int? initialUserId;

  const AuditFinanceScreen({super.key, this.initialUserId});

  @override
  ConsumerState<AuditFinanceScreen> createState() => _AuditFinanceScreenState();
}

class _AuditFinanceScreenState extends ConsumerState<AuditFinanceScreen> {
  int? _selectedUserId;
  String? _selectedCategory; // null = все, 'account', 'payment_document'
  String? _selectedActionType;
  int _offset = 0;
  final int _pageSize = 50;
  List<ActionLogEntry> _allLogs = [];
  bool _hasMore = true;
  bool _isLoadingMore = false;
  bool _flushing = false;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
  String _searchQuery = '';

  static const List<_FilterOption> _categoryOptions = [
    _FilterOption('Все', null),
    _FilterOption('Лицевые счета', 'account'),
    _FilterOption('Платёжные документы', 'payment_document'),
  ];

  static const List<_FilterOption> _actionOptions = [
    _FilterOption('Все', null),
    _FilterOption('Создание', 'create'),
    _FilterOption('Обновление', 'update'),
    _FilterOption('Удаление', 'delete'),
  ];

  @override
  void initState() {
    super.initState();
    _selectedUserId = widget.initialUserId;
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _requestFlush());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchDebounce?.cancel();
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
    } catch (_) {}
    if (mounted) setState(() => _flushing = false);
  }

  void _resetAndLoad() {
    setState(() {
      _offset = 0;
      _allLogs = [];
      _hasMore = true;
    });
    ref.invalidate(actionLogListProvider(_currentFilter));
  }

  ActionLogFilter get _currentFilter => ActionLogFilter(
        limit: _pageSize,
        offset: _offset,
        userId: _selectedUserId,
        entityType: _selectedCategory,
        actionType: _selectedActionType,
        search: _searchQuery.isEmpty ? null : _searchQuery,
      );

  /// Фильтрует записи, оставляя только account и payment_document
  List<ActionLogEntry> _filterFinanceOnly(List<ActionLogEntry> logs) {
    if (_selectedCategory != null) return logs;
    return logs
        .where((l) =>
            l.entityType == 'account' || l.entityType == 'payment_document')
        .toList();
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);
    try {
      final service = ref.read(actionLogServiceProvider);
      final newLogs = await service.getActionLogs(
        limit: _pageSize,
        offset: _offset + _pageSize,
        userId: _selectedUserId,
        entityType: _selectedCategory,
        actionType: _selectedActionType,
        search: _searchQuery.isEmpty ? null : _searchQuery,
      );
      final filtered = _filterFinanceOnly(newLogs);
      setState(() {
        _offset += _pageSize;
        _allLogs.addAll(filtered);
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
        title: const Text('Аудит операций'),
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
          preferredSize: const Size.fromHeight(108),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Поиск по номеру счёта, ФИО, адресу...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              _searchDebounce?.cancel();
                              setState(() => _searchQuery = '');
                              _resetAndLoad();
                            },
                          )
                        : null,
                    isDense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color: Theme.of(context).dividerColor),
                    ),
                  ),
                  onChanged: (text) {
                    _searchDebounce?.cancel();
                    _searchDebounce =
                        Timer(const Duration(milliseconds: 400), () {
                      final trimmed = text.trim();
                      if (trimmed != _searchQuery) {
                        setState(() => _searchQuery = trimmed);
                        _resetAndLoad();
                      }
                    });
                  },
                  onSubmitted: (text) {
                    _searchDebounce?.cancel();
                    final trimmed = text.trim();
                    if (trimmed != _searchQuery) {
                      setState(() => _searchQuery = trimmed);
                      _resetAndLoad();
                    }
                  },
                ),
              ),
              _buildFilterBar(usersAsync),
            ],
          ),
        ),
      ),
      body: logsAsync.when(
        skipLoadingOnReload: true,
        data: (firstPage) {
          if (_offset == 0 && _allLogs.isEmpty) {
            _allLogs = List.from(_filterFinanceOnly(firstPage));
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
                const Icon(Icons.error_outline,
                    size: 48, color: AppTheme.errorRed),
                const SizedBox(height: 12),
                Text('Ошибка загрузки:\n$err',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withAlpha(180))),
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
          _buildDropdown<String?>(
            value: _selectedCategory,
            items: _categoryOptions.map((o) {
              return DropdownMenuItem<String?>(
                value: o.value,
                child: Text(o.label, style: const TextStyle(fontSize: 13)),
              );
            }).toList(),
            onChanged: (v) {
              _selectedCategory = v;
              _resetAndLoad();
            },
            hint: 'Категория',
          ),
          const SizedBox(width: 8),
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
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          dropdownColor: Theme.of(context).colorScheme.surface,
          isDense: true,
          hint: Text(hint,
              style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withAlpha(140))),
          style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurface),
        ),
      ),
    );
  }

  Widget _buildLogList() {
    if (_allLogs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history_edu,
                  size: 64,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withAlpha(60)),
              const SizedBox(height: 16),
              Text('Нет записей аудита',
                  style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withAlpha(140),
                      fontSize: 16)),
              const SizedBox(height: 8),
              Text(
                  'Операции с лицевыми счетами и\nплатёжными документами будут отображаться здесь',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withAlpha(100),
                      fontSize: 13)),
            ],
          ),
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
    final dateStr =
        DateFormat('dd.MM.yy HH:mm').format(log.timestamp.toLocal());
    final icon = _iconForAction(log.actionType);
    final iconColor = _colorForAction(log.actionType);
    final categoryIcon = log.entityType == 'payment_document'
        ? Icons.receipt_long_outlined
        : Icons.account_balance_wallet_outlined;
    final categoryColor = log.entityType == 'payment_document'
        ? Colors.deepPurple
        : Colors.teal;

    final accountNumber = log.changes?['account_number']?.toString() ?? '';
    final periodDate = log.changes?['period_date']?.toString() ?? '';

    String subtitle = '';
    if (accountNumber.isNotEmpty) subtitle += 'ЛС: $accountNumber';
    if (periodDate.isNotEmpty) {
      if (subtitle.isNotEmpty) subtitle += ' • ';
      subtitle += 'Период: $periodDate';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Theme.of(context).colorScheme.onSurface.withAlpha(20),
            width: 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _showLogDetails(log),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(categoryIcon, size: 14, color: categoryColor),
                          const SizedBox(width: 4),
                          Text(
                            log.entityType == 'payment_document'
                                ? 'Платёжный документ'
                                : 'Лицевой счёт',
                            style: TextStyle(
                                fontSize: 11,
                                color: categoryColor,
                                fontWeight: FontWeight.w600),
                          ),
                          const Spacer(),
                          Text(dateStr,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withAlpha(120))),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        log.displayDescription,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onSurface),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(subtitle,
                            style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withAlpha(140))),
                      ],
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.person_outline,
                              size: 14,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withAlpha(140)),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              log.userName ?? 'ID ${log.userId}',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withAlpha(140)),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right,
                    size: 20,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withAlpha(60)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogDetails(ActionLogEntry log) {
    final dateStr =
        DateFormat('dd.MM.yyyy HH:mm:ss').format(log.timestamp.toLocal());
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.85,
          expand: false,
          builder: (_, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
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
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withAlpha(60),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _colorForAction(log.actionType)
                              .withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _iconForAction(log.actionType),
                          color: _colorForAction(log.actionType),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(log.displayDescription,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _detailRow('Пользователь',
                      log.userName ?? 'ID ${log.userId}'),
                  _detailRow('Дата', dateStr),
                  _detailRow('Действие', log.actionLabel),
                  _detailRow('Категория', log.entityLabel),
                  _detailRow('ID объекта', '${log.entityId}'),
                  if (log.deviceId != null)
                    _detailRow('Устройство', log.deviceId!),
                  if (log.changes != null &&
                      log.changes!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text('Изменения:',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface)),
                    const SizedBox(height: 8),
                    ..._buildChangesList(log.changes!),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<Widget> _buildChangesList(Map<String, dynamic> changes) {
    final widgets = <Widget>[];
    final metaKeys = {'account_number', 'period_date', 'account_id', 'scope', 'type', 'screen'};

    final metaEntries = changes.entries
        .where((e) => metaKeys.contains(e.key) && e.value is! Map)
        .toList();
    if (metaEntries.isNotEmpty) {
      for (final entry in metaEntries) {
        widgets.add(_buildMetaChip(
            _humanFieldName(entry.key), '${entry.value}'));
      }
      widgets.add(const SizedBox(height: 8));
    }

    final changeEntries = changes.entries
        .where((e) => !metaKeys.contains(e.key))
        .toList();
    for (final entry in changeEntries) {
      final key = entry.key;
      final value = entry.value;
      if (value is Map) {
        final oldVal = value['old'] ?? value['old_value'] ?? '—';
        final newVal = value['new'] ?? value['new_value'] ?? '—';
        widgets.add(_buildChangeRow(
            _humanFieldName(key), '$oldVal', '$newVal'));
      } else {
        widgets.add(_buildSimpleChangeRow(
            _humanFieldName(key), '$value'));
      }
    }
    return widgets;
  }

  Widget _buildMetaChip(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withAlpha(15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text('$label: $value',
                style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withAlpha(160))),
          ),
        ],
      ),
    );
  }

  Widget _buildChangeRow(String field, String oldVal, String newVal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withAlpha(8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(field,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.errorRed.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Было',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.errorRed.withOpacity(0.7))),
                      const SizedBox(height: 2),
                      Text(oldVal,
                          style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withAlpha(180))),
                    ],
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Icon(Icons.arrow_forward,
                    size: 16,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withAlpha(80)),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.successGreen.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Стало',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.successGreen.withOpacity(0.7))),
                      const SizedBox(height: 2),
                      Text(newVal,
                          style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withAlpha(180))),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleChangeRow(String field, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withAlpha(8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text('$field: ',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withAlpha(140))),
          Expanded(
            child: Text(value,
                style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface)),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withAlpha(140))),
          ),
          Expanded(
            child: Text(value,
                style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface)),
          ),
        ],
      ),
    );
  }

  String _humanFieldName(String field) {
    const names = {
      'account_number': 'Номер ЛС',
      'period_date': 'Период',
      'account_id': 'ID счёта',
      'fio': 'ФИО',
      'phone': 'Телефон',
      'email': 'Email',
      'area': 'Площадь',
      'service_type': 'Тип услуги',
      'status': 'Статус',
      'location_id': 'ID дома',
      'debt_heating_start': 'Долг отопление (начало)',
      'charged_heating': 'Начислено отопление',
      'paid_heating': 'Оплачено отопление',
      'recalc_heating': 'Перерасчёт отопление',
      'debt_heating_end': 'Долг отопление (конец)',
      'debt_hot_water_start': 'Долг ГВС (начало)',
      'charged_hot_water': 'Начислено ГВС',
      'paid_hot_water': 'Оплачено ГВС',
      'recalc_hot_water': 'Перерасчёт ГВС',
      'debt_hot_water_end': 'Долг ГВС (конец)',
      'debt_maintenance_start': 'Долг ТО (начало)',
      'charged_maintenance': 'Начислено ТО',
      'paid_maintenance': 'Оплачено ТО',
      'recalc_maintenance': 'Перерасчёт ТО',
      'debt_maintenance_end': 'Долг ТО (конец)',
      'debt_waste_start': 'Долг ТБО (начало)',
      'charged_waste': 'Начислено ТБО',
      'paid_waste': 'Оплачено ТБО',
      'recalc_waste': 'Перерасчёт ТБО',
      'debt_waste_end': 'Долг ТБО (конец)',
      'debt_odn_electricity_start': 'Долг ОДН Э (начало)',
      'charged_odn_electricity': 'Начислено ОДН Э',
      'paid_odn_electricity': 'Оплачено ОДН Э',
      'recalc_odn_electricity': 'Перерасчёт ОДН Э',
      'debt_odn_electricity_end': 'Долг ОДН Э (конец)',
      'debt_odn_water_start': 'Долг ОДН Вода (начало)',
      'charged_odn_water': 'Начислено ОДН Вода',
      'paid_odn_water': 'Оплачено ОДН Вода',
      'recalc_odn_water': 'Перерасчёт ОДН Вода',
      'debt_odn_water_end': 'Долг ОДН Вода (конец)',
      'name': 'Название',
      'address': 'Адрес',
      'site_number': 'Номер участка',
      'site_manager': 'Участковый',
      'jku_identifier': 'Идентификатор ЖКУ',
      'open_date': 'Дата открытия',
      'close_date': 'Дата закрытия',
    };
    return names[field] ?? field;
  }

  IconData _iconForAction(String actionType) {
    switch (actionType) {
      case 'create':
        return Icons.add_circle_outline;
      case 'update':
        return Icons.edit_outlined;
      case 'delete':
        return Icons.delete_outline;
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
      default:
        return Theme.of(context).colorScheme.onSurface.withAlpha(140);
    }
  }
}

class _FilterOption {
  final String label;
  final String? value;
  const _FilterOption(this.label, this.value);
}
