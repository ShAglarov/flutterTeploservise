import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/base_api_service.dart';

/// Экран архива начислений — аналог arh*.DBF / zaparh из FoxPro.
/// Помесячные архивы, просмотр, экспорт (JSON/CSV).
class ArchivesScreen extends ConsumerStatefulWidget {
  const ArchivesScreen({super.key});

  @override
  ConsumerState<ArchivesScreen> createState() => _ArchivesScreenState();
}

class _ArchivesScreenState extends ConsumerState<ArchivesScreen> {
  List<Map<String, dynamic>> _periods = [];
  Map<String, dynamic> _summary = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final dio = ref.read(dioProvider);
      final periodsResp = await dio.get('/archives/periods');
      final summaryResp = await dio.get('/archives/summary');
      if (mounted) {
        setState(() {
          _periods = List<Map<String, dynamic>>.from(periodsResp.data);
          _summary = Map<String, dynamic>.from(summaryResp.data);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Архив начислений'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Сводка
                if (_summary.isNotEmpty) _buildSummary(theme),

                // Периоды
                Expanded(
                  child: _periods.isEmpty
                      ? const Center(child: Text('Нет архивных данных', style: TextStyle(color: Colors.grey)))
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: _periods.length,
                            itemBuilder: (_, i) => _buildPeriodCard(_periods[i], theme),
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildSummary(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blueGrey.shade700, Colors.blueGrey.shade500]),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.archive, color: Colors.white, size: 32),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${_summary['total_documents'] ?? 0} документов', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              Text('${_summary['total_periods'] ?? 0} периодов', style: const TextStyle(color: Colors.white70, fontSize: 12)),
              if (_summary['earliest_period'] != null)
                Text('С ${_summary['earliest_period']} по ${_summary['latest_period']}', style: const TextStyle(color: Colors.white60, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodCard(Map<String, dynamic> period, ThemeData theme) {
    final count = period['count'] ?? 0;
    final debt = (period['total_debt'] as num?)?.toDouble() ?? 0;
    final charged = (period['total_charged'] as num?)?.toDouble() ?? 0;
    final paid = (period['total_paid'] as num?)?.toDouble() ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showPeriodDetails(period['period'], period['period_label']),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.blueGrey.shade600, size: 18),
                  const SizedBox(width: 8),
                  Text(period['period_label'] ?? period['period'] ?? '', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: Colors.blueGrey.shade100, borderRadius: BorderRadius.circular(8)),
                    child: Text('$count Л/С', style: TextStyle(color: Colors.blueGrey.shade700, fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _miniStat('Начислено', charged, Colors.blue),
                  _miniStat('Оплачено', paid, Colors.green),
                  _miniStat('Долг', debt, debt > 0 ? Colors.red : Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniStat(String label, double value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text('${value.toStringAsFixed(0)} ₽', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  void _showPeriodDetails(String? period, String? label) {
    if (period == null) return;
    // Extract YYYY-MM from YYYY-MM-DD
    final periodKey = period.length >= 7 ? period.substring(0, 7) : period;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PeriodDetailSheet(periodKey: periodKey, label: label ?? periodKey, dio: ref.read(dioProvider)),
    );
  }
}

class _PeriodDetailSheet extends StatefulWidget {
  final String periodKey;
  final String label;
  final Dio dio;

  const _PeriodDetailSheet({required this.periodKey, required this.label, required this.dio});

  @override
  State<_PeriodDetailSheet> createState() => _PeriodDetailSheetState();
}

class _PeriodDetailSheetState extends State<_PeriodDetailSheet> {
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = true;
  int _total = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final resp = await widget.dio.get('/archives/by-period', queryParameters: {'period': widget.periodKey, 'limit': 200});
      if (mounted) {
        setState(() {
          _items = List<Map<String, dynamic>>.from(resp.data['items']);
          _total = resp.data['total'];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(margin: const EdgeInsets.only(top: 10), width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.archive, color: Colors.blueGrey),
                const SizedBox(width: 8),
                Expanded(child: Text('${widget.label} ($_total)', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                IconButton(
                  icon: const Icon(Icons.download, color: Colors.indigo),
                  tooltip: 'Экспорт CSV',
                  onPressed: () => _export('csv'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _items.length,
                    itemBuilder: (_, i) {
                      final d = _items[i];
                      final debt = (d['debt_end'] as num?)?.toDouble() ?? 0;
                      return ListTile(
                        dense: true,
                        leading: CircleAvatar(
                          radius: 16,
                          backgroundColor: debt > 0 ? Colors.red.shade50 : Colors.green.shade50,
                          child: Icon(debt > 0 ? Icons.warning : Icons.check, size: 16, color: debt > 0 ? Colors.red : Colors.green),
                        ),
                        title: Text(d['resident'] ?? d['account_number'] ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                        subtitle: Text('Л/С: ${d['account_number']} | Начисл: ${(d['charged_total'] as num?)?.toStringAsFixed(0) ?? 0}₽', style: const TextStyle(fontSize: 11)),
                        trailing: Text('${debt.toStringAsFixed(0)} ₽', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: debt > 0 ? Colors.red : Colors.green)),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _export(String format) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('📥 Экспорт...')));
      // Export happens on backend, just open URL
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ $e')));
    }
  }
}
