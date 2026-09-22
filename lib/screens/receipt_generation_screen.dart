import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../services/base_api_service.dart';

/// Экран генерации квитанций — аналог kvitadr, kvitban, pr_kvit из FoxPro.
/// Массовая генерация PDF квитанций по дому, по ЛС, с QR-кодами.
class ReceiptGenerationScreen extends ConsumerStatefulWidget {
  const ReceiptGenerationScreen({super.key});

  @override
  ConsumerState<ReceiptGenerationScreen> createState() => _ReceiptGenerationScreenState();
}

class _ReceiptGenerationScreenState extends ConsumerState<ReceiptGenerationScreen> {
  List<Map<String, dynamic>> _locations = [];
  List<Map<String, dynamic>> _allLocations = [];
  Map<String, dynamic>? _selectedLocation;
  String? _selectedPeriod;
  List<String> _periods = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = false;
  bool _isGenerating = false;
  String _generationType = 'by_house'; // by_house, by_account

  final _accountIdCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLocations();
    _loadPeriods();
  }

  @override
  void dispose() {
    _accountIdCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadLocations() async {
    try {
      final dio = ref.read(dioProvider);
      final resp = await dio.get('/locations/', queryParameters: {'limit': 1000, 'assigned_only': true});
      if (mounted) {
        final data = resp.data;
        List<Map<String, dynamic>> locs;
        if (data is List) {
          locs = List<Map<String, dynamic>>.from(data);
        } else if (data is Map && data.containsKey('items')) {
          locs = List<Map<String, dynamic>>.from(data['items']);
        } else {
          locs = [];
        }
        // Ensure address field
        for (var loc in locs) {
          loc['address'] ??= loc['name'] ?? 'Дом #${loc['id']}';
        }
        locs.sort((a, b) => (a['address'] as String).compareTo(b['address'] as String));
        setState(() {
          _allLocations = locs;
          _locations = locs;
        });
      }
    } catch (e) {
      debugPrint('Error loading locations: $e');
    }
  }

  void _showHouseSearch() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        String query = '';
        List<Map<String, dynamic>> filtered = List.from(_allLocations);
        return StatefulBuilder(
          builder: (ctx, ss) {
            return Container(
              height: MediaQuery.of(ctx).size.height * 0.7,
              decoration: BoxDecoration(
                color: Theme.of(ctx).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Container(margin: const EdgeInsets.only(top: 10), width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(2))),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextField(
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Поиск дома...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        isDense: true,
                      ),
                      onChanged: (v) {
                        ss(() {
                          query = v.toLowerCase();
                          filtered = _allLocations.where((loc) {
                            final addr = (loc['address'] as String? ?? '').toLowerCase();
                            final name = (loc['name'] as String? ?? '').toLowerCase();
                            return addr.contains(query) || name.contains(query);
                          }).toList();
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('${filtered.length} домов (подключены к котельным)', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final loc = filtered[i];
                        final isSelected = _selectedLocation != null && _selectedLocation!['id'] == loc['id'];
                        return ListTile(
                          dense: true,
                          leading: Icon(Icons.apartment, color: isSelected ? Colors.indigo : Colors.grey),
                          title: Text(loc['address'] ?? '', style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                          subtitle: loc['accounts_count'] != null ? Text('${loc['accounts_count']} Л/С', style: const TextStyle(fontSize: 11)) : null,
                          trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.indigo) : null,
                          onTap: () {
                            setState(() => _selectedLocation = loc);
                            _loadStats();
                            Navigator.pop(ctx);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _loadPeriods() async {
    try {
      final dio = ref.read(dioProvider);
      final resp = await dio.get('/payment-documents/periods');
      if (mounted) {
        setState(() {
          _periods = List<String>.from(resp.data);
          if (_periods.isNotEmpty) _selectedPeriod = _periods.first;
        });
        _loadStats();
      }
    } catch (_) {}
  }

  Future<void> _loadStats() async {
    try {
      final dio = ref.read(dioProvider);
      final params = <String, dynamic>{};
      if (_selectedLocation != null) params['location_id'] = _selectedLocation!['id'];
      if (_selectedPeriod != null) params['period'] = _selectedPeriod;
      final resp = await dio.get('/receipts/stats', queryParameters: params);
      if (mounted) setState(() => _stats = Map<String, dynamic>.from(resp.data));
    } catch (_) {}
  }

  Future<void> _generateReceipts() async {
    setState(() => _isGenerating = true);

    try {
      final dio = ref.read(dioProvider);
      late Response resp;

      if (_generationType == 'by_account') {
        final accountId = _accountIdCtrl.text.trim();
        if (accountId.isEmpty) {
          _showError('Укажите номер лицевого счёта');
          return;
        }
        resp = await dio.get(
          '/receipts/by-account/$accountId',
          queryParameters: _selectedPeriod != null ? {'period': _selectedPeriod} : null,
          options: Options(responseType: ResponseType.bytes),
        );
      } else {
        if (_selectedLocation == null) {
          _showError('Выберите дом');
          return;
        }
        resp = await dio.get(
          '/receipts/by-location/${_selectedLocation!['id']}',
          queryParameters: _selectedPeriod != null ? {'period': _selectedPeriod} : null,
          options: Options(responseType: ResponseType.bytes),
        );
      }

      // Save and share PDF
      final dir = await getTemporaryDirectory();
      final filename = _generationType == 'by_account'
          ? 'receipt_${_accountIdCtrl.text}.pdf'
          : 'receipts_${_selectedLocation?['address'] ?? 'house'}.pdf';
      final file = File('${dir.path}/$filename');
      await file.writeAsBytes(resp.data);

      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)], subject: 'Квитанции ЖКУ'),
      );
    } catch (e) {
      _showError('$e');
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  void _showError(String msg) {
    if (mounted) {
      setState(() => _isGenerating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ $msg'), backgroundColor: Colors.red),
      );
    }
  }

  static const _monthNames = [
    '', 'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
    'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь',
  ];

  String _formatPeriod(String period) {
    try {
      final parts = period.split('-');
      final year = parts[0];
      final month = int.parse(parts[1]);
      return '${_monthNames[month]} $year';
    } catch (_) {
      return period;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Квитанции')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Статистика
          if (_stats.isNotEmpty) _buildStatsCard(theme),
          const SizedBox(height: 16),

          // Тип генерации
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Тип формирования', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'by_house', icon: Icon(Icons.apartment), label: Text('По дому')),
                      ButtonSegment(value: 'by_account', icon: Icon(Icons.person), label: Text('По Л/С')),
                    ],
                    selected: {_generationType},
                    onSelectionChanged: (v) => setState(() => _generationType = v.first),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Параметры
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Параметры', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),

                  // Период
                  DropdownButtonFormField<String>(
                    value: _selectedPeriod,
                    decoration: InputDecoration(
                      labelText: 'Период',
                      prefixIcon: const Icon(Icons.calendar_month),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: _periods.map((p) => DropdownMenuItem(value: p, child: Text(_formatPeriod(p)))).toList(),
                    onChanged: (v) {
                      setState(() => _selectedPeriod = v);
                      _loadStats();
                    },
                  ),
                  const SizedBox(height: 12),

                  if (_generationType == 'by_house') ...[
                    // Дом — с поиском
                    InkWell(
                      onTap: _showHouseSearch,
                      borderRadius: BorderRadius.circular(12),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Дом',
                          prefixIcon: const Icon(Icons.apartment),
                          suffixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          _selectedLocation != null
                              ? '${_selectedLocation!['address']}'
                              : 'Выберите дом (${_allLocations.length})',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _selectedLocation != null ? null : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    // ID лицевого счёта
                    TextField(
                      controller: _accountIdCtrl,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: 'Номер лицевого счёта',
                        prefixIcon: const Icon(Icons.credit_card),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Кнопка генерации
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _isGenerating ? null : _generateReceipts,
              icon: _isGenerating
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.picture_as_pdf, size: 22),
              label: Text(
                _isGenerating ? 'Формирование...' : 'Сформировать PDF',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(ThemeData theme) {
    final total = _stats['total_accounts'] ?? 0;
    final withDebt = _stats['with_debt'] ?? 0;
    final totalDebt = (_stats['total_debt'] as num?)?.toDouble() ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.indigo.shade700, Colors.blue.shade500]),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text('$total', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const Text('Всего Л/С', style: TextStyle(color: Colors.white70, fontSize: 11)),
              ],
            ),
          ),
          Container(width: 1, height: 40, color: Colors.white30),
          Expanded(
            child: Column(
              children: [
                Text('$withDebt', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const Text('С задолж.', style: TextStyle(color: Colors.white70, fontSize: 11)),
              ],
            ),
          ),
          Container(width: 1, height: 40, color: Colors.white30),
          Expanded(
            child: Column(
              children: [
                Text('${totalDebt.toStringAsFixed(0)}₽', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const Text('Общий долг', style: TextStyle(color: Colors.white70, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
