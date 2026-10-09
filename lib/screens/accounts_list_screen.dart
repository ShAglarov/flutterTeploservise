import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/location_models.dart';
import '../models/permission_key.dart';
import '../services/location_service.dart';
import '../services/permission_service.dart';
import '../services/base_api_service.dart';
import 'account_form_screen.dart';
import 'accounts_bulk_screen.dart';
import 'account_gis_screen.dart';
import 'payment_documents_screen.dart';

/// Экран лицевых счетов дома с поиском и навигацией к платежным документам
class AccountsListScreen extends ConsumerStatefulWidget {
  final int locationId;

  const AccountsListScreen({super.key, required this.locationId});

  @override
  ConsumerState<AccountsListScreen> createState() => _AccountsListScreenState();
}

class _AccountsListScreenState extends ConsumerState<AccountsListScreen> {
  List<Map<String, dynamic>> _accounts = [];
  List<Map<String, dynamic>> _filteredAccounts = [];
  bool _isLoading = true;
  String? _error;
  final _searchController = TextEditingController();
  String _locationName = '';

  @override
  void initState() {
    super.initState();
    _loadAccounts();
    _searchController.addListener(_filterAccounts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAccounts() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/accounts/', queryParameters: {
        'location_id': widget.locationId,
        'limit': 10000,
      });

      if (response.statusCode == 200) {
        final data = (response.data as List).cast<Map<String, dynamic>>();
        // Debug: check resident field
        for (final a in data) {
          if ((a['address'] ?? '').toString().contains('25')) {
            debugPrint('🔍 ACC ${a['account_number']}: resident=${a['resident']}');
          }
        }
        // Get location name from first account
        if (data.isNotEmpty) {
          _locationName = data.first['location_name'] ?? data.first['address'] ?? '';
        }
        setState(() {
          _accounts = data;
          _filteredAccounts = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() { _error = 'Ошибка: $e'; _isLoading = false; });
    }
  }

  void _filterAccounts() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() => _filteredAccounts = _accounts);
      return;
    }
    setState(() {
      _filteredAccounts = _accounts.where((a) {
        final accountNum = (a['account_number'] ?? '').toString().toLowerCase();
        final fio = (a['fio'] ?? '').toString().toLowerCase();
        final address = (a['address'] ?? '').toString().toLowerCase();
        final jku = (a['jku_identifier'] ?? '').toString().toLowerCase();
        return accountNum.contains(query) || fio.contains(query) || 
               address.contains(query) || jku.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_locationName.isNotEmpty ? _locationName : 'Лицевые счета'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadAccounts),
        ],
      ),
      floatingActionButton:
          ref.watch(permissionStateProvider).hasPermission(PermissionKey.accountCreate)
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Массовое создание по номерам квартир: придумывать
                    // номер для каждой квартиры вручную не нужно.
                    FloatingActionButton.small(
                      heroTag: 'bulk',
                      tooltip: 'Создать счета по квартирам',
                      onPressed: _bulkCreate,
                      child: const Icon(Icons.playlist_add),
                    ),
                    const SizedBox(height: 10),
                    FloatingActionButton.extended(
                      heroTag: 'single',
                      onPressed: _createAccount,
                      icon: const Icon(Icons.add),
                      label: const Text('Лицевой счёт'),
                    ),
                  ],
                )
              : null,
      body: Column(
        children: [
          // Поиск
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Поиск по ФИО, Л/С, адресу...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
          ),
          
          // Счётчик
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Найдено: ${_filteredAccounts.length} из ${_accounts.length}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ),
          ),

          // Список
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)))
                    : _filteredAccounts.isEmpty
                        ? const Center(child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.search_off, size: 64, color: Colors.grey),
                              SizedBox(height: 12),
                              Text('Лицевые счета не найдены', style: TextStyle(fontSize: 16, color: Colors.grey)),
                            ],
                          ))
                        : RefreshIndicator(
                            onRefresh: _loadAccounts,
                            child: ListView.builder(
                              // Снизу запас под кнопку «Лицевой счёт»:
                              // иначе она накрывает последнюю карточку.
                              padding: const EdgeInsets.fromLTRB(8, 0, 8, 80),
                              itemCount: _filteredAccounts.length + 1,
                              itemBuilder: (context, index) {
                                if (index == 0) return _swipeHint();
                                return _buildAccountCard(
                                    _filteredAccounts[index - 1]);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  /// Карточка со свайпом: влево — удалить, вправо — редактировать.
  ///
  /// Действия показываются только при наличии права: без `account.update`
  /// свайп вправо не сработает, без `account.delete` — влево. Сервер
  /// проверяет права повторно, это лишь чтобы не предлагать недоступное.
  Widget _buildAccountCard(Map<String, dynamic> account) {
    final perms = ref.watch(permissionStateProvider);
    final canEdit = perms.hasPermission(PermissionKey.accountUpdate);
    final canDelete = perms.hasPermission(PermissionKey.accountDelete);
    final accId = account['id'] as int?;

    final card = _buildAccountCardBody(account);
    if (accId == null || (!canEdit && !canDelete)) return card;

    return Dismissible(
      key: ValueKey('acc_$accId'),
      direction: canEdit && canDelete
          ? DismissDirection.horizontal
          : (canEdit ? DismissDirection.startToEnd : DismissDirection.endToStart),
      background: _swipeBg(
        color: Colors.blue,
        icon: Icons.edit,
        label: 'Редактировать',
        alignment: Alignment.centerLeft,
      ),
      secondaryBackground: _swipeBg(
        color: Colors.red,
        icon: Icons.delete,
        label: 'Удалить',
        alignment: Alignment.centerRight,
      ),
      // confirmDismiss, а не onDismissed: карточка не должна исчезать до
      // подтверждения — правка её вообще не удаляет из списка.
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          await _editAccount(account);
          return false;
        }
        return _confirmDelete(account);
      },
      child: card,
    );
  }

  /// Подсказка про свайп: без неё о жесте никто не узнает.
  /// Показывается только если действия реально доступны по правам.
  Widget _swipeHint() {
    final perms = ref.watch(permissionStateProvider);
    final canEdit = perms.hasPermission(PermissionKey.accountUpdate);
    final canDelete = perms.hasPermission(PermissionKey.accountDelete);
    if (!canEdit && !canDelete) return const SizedBox.shrink();

    final parts = [
      if (canEdit) 'вправо — редактировать',
      if (canDelete) 'влево — удалить',
    ];
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 2, 6, 8),
      child: Row(
        children: [
          Icon(Icons.swipe, size: 14, color: cs.onSurface.withAlpha(120)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Свайп по карточке: ${parts.join(', ')}',
              style: TextStyle(fontSize: 11, color: cs.onSurface.withAlpha(140)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _swipeBg({
    required Color color,
    required IconData icon,
    required String label,
    required Alignment alignment,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      alignment: alignment,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(
                  color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildAccountCardBody(Map<String, dynamic> account) {
    final accountNumber = account['account_number'] ?? '-';
    final fio = account['fio'] ?? 'Без имени';
    final address = account['address'] ?? '';
    final area = (account['area'] as num?)?.toDouble();
    final jku = account['jku_identifier'] ?? '';
    final cadastral = account['cadastral_number'] ?? '';
    final accountId = account['id'] as int?;
    final resident = account['resident'] as Map<String, dynamic>?;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 3),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (accountId != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PaymentDocumentsScreen(
                  accountId: accountId,
                  accountNumber: accountNumber,
                  fio: fio,
                ),
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Иконка
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.receipt_long, color: Colors.blue.shade700, size: 22),
              ),
              const SizedBox(width: 12),
              // Инфо
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(fio, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14), overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(
                      'Л/С: $accountNumber${jku.isNotEmpty ? '  •  ЖКУ: $jku' : ''}',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (address.isNotEmpty || area != null)
                      Text(
                        '${address.isNotEmpty ? address : ''}${area != null ? '  •  ${area.toStringAsFixed(1)} м²' : ''}',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (cadastral.isNotEmpty)
                      Text(
                        'Кадастр: $cadastral',
                        style: TextStyle(fontSize: 11, color: Colors.teal.shade600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 4),
                    // Жилец
                    if (resident != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: (resident['is_blocked'] == true) ? Colors.red.shade50 : Colors.green.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              resident['is_blocked'] == true ? Icons.person_off : Icons.person,
                              size: 12,
                              color: resident['is_blocked'] == true ? Colors.red : Colors.green.shade700,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                '${resident['full_name'] ?? resident['username'] ?? 'Жилец'}${resident['phone_number'] != null && resident['phone_number'].toString().isNotEmpty ? '  📱${resident['phone_number']}' : ''}',
                                style: TextStyle(fontSize: 10, color: resident['is_blocked'] == true ? Colors.red : Colors.green.shade700),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.person_outline, size: 12, color: Colors.orange.shade700),
                            const SizedBox(width: 4),
                            Text('Нет жильца', style: TextStyle(fontSize: 10, color: Colors.orange.shade700)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              // Правка данных ГИС ЖКХ по этому лицевому счёту: ЕЛС, СНИЛС,
              // площади и прочее из шаблона импорта ЛС.
              IconButton(
                icon: const Icon(Icons.account_balance_outlined,
                    size: 18, color: Colors.teal),
                tooltip: 'Данные ГИС ЖКХ',
                onPressed: () => _openGis(account),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editAccount(Map<String, dynamic> account) async {
    try {
      final model = AccountResponse.fromJson(account);
      final changed = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => AccountFormScreen(
            account: model,
            locationId: widget.locationId,
            locationName: _locationName,
          ),
        ),
      );
      if (changed == true) await _loadAccounts();
    } catch (e) {
      _toast('Не удалось открыть счёт: $e', Colors.red);
    }
  }

  Future<void> _bulkCreate() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AccountsBulkScreen(
          locationId: widget.locationId,
          locationName: _locationName,
        ),
      ),
    );
    // Экран генерации не возвращает true, но счета могли появиться —
    // перечитываем список всегда.
    if (mounted) await _loadAccounts();
    if (changed == true && mounted) await _loadAccounts();
  }

  Future<void> _createAccount() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AccountFormScreen(
          locationId: widget.locationId,
          locationName: _locationName,
        ),
      ),
    );
    if (changed == true) await _loadAccounts();
  }

  /// Удаление с подтверждением: вместе со счётом уходят его платёжные
  /// документы и история операций, восстановить это из интерфейса нельзя.
  Future<bool> _confirmDelete(Map<String, dynamic> account) async {
    final number = account['account_number'] ?? '—';
    final fio = account['fio'] ?? 'без имени';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить лицевой счёт?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$number · $fio'),
            const SizedBox(height: 10),
            const Text(
              'Вместе со счётом удалятся его начисления и история операций '
              'кассира. Отменить это из приложения нельзя.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Отмена')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return false;

    final id = account['id'] as int?;
    if (id == null) return false;

    try {
      await ref.read(locationServiceProvider).deleteAccount(id);
      _toast('Лицевой счёт удалён', Colors.green);
      await _loadAccounts();
      // false: список уже перезагружен, Dismissible не должен сам убирать
      // карточку — иначе индексы разъедутся с новыми данными.
      return false;
    } catch (e) {
      _toast(_deleteErrorText(e), Colors.red);
      return false;
    }
  }

  String _deleteErrorText(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      String? detail;
      if (data is Map) detail = data['detail']?.toString();
      if (detail != null && detail.startsWith('permission_denied')) {
        return 'Нет права на удаление лицевых счетов';
      }
      return detail ?? e.message ?? 'Ошибка сети';
    }
    return 'Не удалось удалить: $e';
  }

  void _toast(String text, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), backgroundColor: color),
    );
  }

  /// Экран правит поля ГИС, поэтому ему нужна типизированная модель.
  /// Список приходит сырыми Map, собираем AccountResponse из той же JSON.
  Future<void> _openGis(Map<String, dynamic> account) async {
    try {
      final model = AccountResponse.fromJson(account);
      final changed = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => AccountGisScreen(account: model)),
      );
      if (changed == true) await _loadAccounts();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Не удалось открыть данные ГИС: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
