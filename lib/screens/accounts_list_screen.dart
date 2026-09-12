import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/base_api_service.dart';
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
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              itemCount: _filteredAccounts.length,
                              itemBuilder: (context, index) => _buildAccountCard(_filteredAccounts[index]),
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard(Map<String, dynamic> account) {
    final accountNumber = account['account_number'] ?? '-';
    final fio = account['fio'] ?? 'Без имени';
    final address = account['address'] ?? '';
    final area = (account['area'] as num?)?.toDouble();
    final jku = account['jku_identifier'] ?? '';
    final accountId = account['id'] as int?;

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
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
