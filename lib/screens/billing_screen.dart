import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/base_api_service.dart';
import '../utils/app_theme.dart';

/// Экран массового начисления — аналог nachtm.prg / NACHIK.PRG из FoxPro.
/// Позволяет выбрать период, дом и услуги, запустить массовое начисление
/// и просмотреть результат.
class BillingScreen extends ConsumerStatefulWidget {
  const BillingScreen({super.key});

  @override
  ConsumerState<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends ConsumerState<BillingScreen> {
  // Параметры начисления
  DateTime _selectedDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  int? _selectedLocationId;
  String _selectedLocationName = 'Все дома';
  final Set<String> _selectedServices = {};
  bool _selectAll = true;

  // Результат
  bool _isCharging = false;
  bool _isUndoing = false;
  Map<String, dynamic>? _result;
  Map<String, dynamic>? _undoResult;
  String? _error;

  // История начислений (последние)
  List<Map<String, dynamic>> _recentPeriods = [];
  bool _loadingPeriods = true;

  static const Map<String, String> serviceLabels = {
    'heating': 'Отопление',
    'hot_water': 'Горячая вода',
    'maintenance': 'Теплообслуживание',
    'waste': 'ТБО',
    'odn_electricity': 'ОДН Электричество',
    'odn_water': 'ОДН Вода',
  };

  static const Map<String, IconData> serviceIcons = {
    'heating': Icons.whatshot,
    'hot_water': Icons.water_drop,
    'maintenance': Icons.build_circle,
    'waste': Icons.delete_sweep,
    'odn_electricity': Icons.electrical_services,
    'odn_water': Icons.water,
  };

  static const Map<String, Color> serviceColors = {
    'heating': Colors.deepOrange,
    'hot_water': Colors.blue,
    'maintenance': Colors.teal,
    'waste': Colors.brown,
    'odn_electricity': Colors.amber,
    'odn_water': Colors.cyan,
  };

  @override
  void initState() {
    super.initState();
    _loadRecentPeriods();
  }

  Future<void> _loadRecentPeriods() async {
    setState(() => _loadingPeriods = true);
    try {
      final dio = ref.read(dioProvider);
      final resp = await dio.get('/payment-documents/periods');
      if (resp.statusCode == 200) {
        setState(() {
          _recentPeriods = (resp.data as List)
              .map((e) => {'period': e.toString()})
              .toList();
        });
      }
    } catch (_) {}
    setState(() => _loadingPeriods = false);
  }

  Future<void> _runMassCharge() async {
    final services = _selectAll
        ? null
        : _selectedServices.toList();

    if (!_selectAll && _selectedServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Выберите хотя бы одну услугу'), backgroundColor: Colors.red),
      );
      return;
    }

    // Подтверждение
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.calculate, size: 48, color: AppTheme.primaryBlue),
        title: const Text('Запуск начисления'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow(Icons.calendar_today, 'Период', _formatPeriod(_selectedDate)),
            const SizedBox(height: 8),
            _infoRow(Icons.home, 'Дом', _selectedLocationName),
            const SizedBox(height: 8),
            _infoRow(
              Icons.category,
              'Услуги',
              _selectAll
                  ? 'Все (${serviceLabels.length})'
                  : _selectedServices.map((s) => serviceLabels[s] ?? s).join(', '),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withAlpha(30),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.withAlpha(80)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.amber, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Начисление добавит суммы к существующим документам. '
                      'Убедитесь, что тарифы настроены корректно.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          FilledButton.icon(
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.play_arrow, size: 18),
            label: const Text('Начислить'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() { _isCharging = true; _result = null; _error = null; });

    try {
      final dio = ref.read(dioProvider);
      final body = <String, dynamic>{
        'period_date': _selectedDate.toIso8601String().substring(0, 10),
      };
      if (_selectedLocationId != null) body['location_id'] = _selectedLocationId;
      if (services != null) body['services'] = services;

      final resp = await dio.post('/tariffs/mass-charge', data: body);
      if (resp.statusCode == 200) {
        setState(() => _result = resp.data as Map<String, dynamic>);
      }
    } on DioException catch (e) {
      final detail = e.response?.data;
      String msg;
      if (detail is Map && detail.containsKey('detail')) {
        msg = detail['detail'].toString();
      } else if (detail is String && detail.isNotEmpty) {
        msg = detail;
      } else {
        msg = 'Ошибка сервера: ${e.response?.statusCode ?? "нет ответа"}';
      }
      setState(() => _error = msg);
    } catch (e) {
      setState(() => _error = e.toString());
    }
    setState(() => _isCharging = false);
  }

  Future<void> _undoMassCharge() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.undo, size: 48, color: Colors.red),
        title: const Text('Отмена начислений'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _infoRow(Icons.calendar_today, 'Период', _formatPeriod(_selectedDate)),
            const SizedBox(height: 8),
            _infoRow(Icons.home, 'Дом', _selectedLocationName),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withAlpha(30),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withAlpha(80)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Будут отменены все начисления из последнего массового начисления за выбранный период.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Нет')),
          FilledButton.icon(
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.undo, size: 18),
            label: const Text('Отменить начисления'),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() { _isUndoing = true; _undoResult = null; _error = null; });

    try {
      final dio = ref.read(dioProvider);
      final body = <String, dynamic>{
        'period_date': _selectedDate.toIso8601String().substring(0, 10),
      };
      if (_selectedLocationId != null) body['location_id'] = _selectedLocationId;

      final resp = await dio.post('/tariffs/mass-charge/undo', data: body);
      if (resp.statusCode == 200) {
        setState(() => _undoResult = resp.data as Map<String, dynamic>);
      }
    } on DioException catch (e) {
      final detail = e.response?.data;
      String msg;
      if (detail is Map && detail.containsKey('detail')) {
        msg = detail['detail'].toString();
      } else if (detail is String && detail.isNotEmpty) {
        msg = detail;
      } else {
        msg = 'Ошибка сервера: ${e.response?.statusCode ?? "нет ответа"}';
      }
      setState(() => _error = msg);
    } catch (e) {
      setState(() => _error = e.toString());
    }
    setState(() => _isUndoing = false);
  }

  String _formatPeriod(DateTime d) {
    const months = [
      '', 'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
      'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь',
    ];
    return '${months[d.month]} ${d.year}';
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Начисления'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ═══════ Параметры начисления ═══════
            _buildSectionTitle('Параметры начисления', Icons.tune),
            const SizedBox(height: 12),
            _buildParamsCard(theme, isDark),

            const SizedBox(height: 24),

            // ═══════ Услуги ═══════
            _buildSectionTitle('Услуги для начисления', Icons.category),
            const SizedBox(height: 12),
            _buildServicesCard(theme, isDark),

            const SizedBox(height: 24),

            // ═══════ Кнопка запуска ═══════
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: _isCharging ? null : _runMassCharge,
                icon: _isCharging
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.calculate, size: 22),
                label: Text(
                  _isCharging ? 'Начисление...' : 'Запустить начисление',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ═══════ Кнопка отмены ═══════
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: (_isUndoing || _isCharging) ? null : _undoMassCharge,
                icon: _isUndoing
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.undo, size: 20),
                label: Text(
                  _isUndoing ? 'Отмена...' : 'Отменить последнее начисление',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

            // ═══════ Результат ═══════
            if (_result != null) ...[
              const SizedBox(height: 24),
              _buildResultCard(theme, isDark),
            ],
            if (_undoResult != null) ...[
              const SizedBox(height: 24),
              _buildUndoResultCard(theme),
            ],
            if (_error != null) ...[
              const SizedBox(height: 24),
              _buildErrorCard(theme),
            ],

            // ═══════ История периодов ═══════
            const SizedBox(height: 24),
            _buildSectionTitle('Доступные периоды', Icons.history),
            const SizedBox(height: 12),
            _buildPeriodsCard(theme, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryBlue),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(
          fontSize: 16, fontWeight: FontWeight.w700,
        )),
      ],
    );
  }

  Widget _buildParamsCard(ThemeData theme, bool isDark) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Период
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() => _selectedDate = DateTime(picked.year, picked.month, 1));
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Период начисления',
                  border: OutlineInputBorder(),
                  isDense: true,
                  prefixIcon: Icon(Icons.calendar_month, size: 20),
                  suffixIcon: Icon(Icons.arrow_drop_down),
                ),
                child: Text(
                  _formatPeriod(_selectedDate),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Дом
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => _selectLocation(),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Дом',
                  border: OutlineInputBorder(),
                  isDense: true,
                  prefixIcon: Icon(Icons.home_outlined, size: 20),
                  suffixIcon: Icon(Icons.arrow_drop_down),
                ),
                child: Text(
                  _selectedLocationName,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesCard(ThemeData theme, bool isDark) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Все/Выборочно
            SwitchListTile(
              title: const Text('Все услуги', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(
                _selectAll ? 'Начисление по всем ${serviceLabels.length} услугам' : 'Выберите конкретные услуги',
                style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
              ),
              value: _selectAll,
              onChanged: (v) => setState(() {
                _selectAll = v;
                if (v) _selectedServices.clear();
              }),
              activeColor: AppTheme.primaryBlue,
            ),
            if (!_selectAll) ...[
              const Divider(),
              ...serviceLabels.entries.map((entry) {
                final isChecked = _selectedServices.contains(entry.key);
                final color = serviceColors[entry.key] ?? Colors.grey;
                return CheckboxListTile(
                  value: isChecked,
                  onChanged: (v) {
                    setState(() {
                      if (v == true) {
                        _selectedServices.add(entry.key);
                      } else {
                        _selectedServices.remove(entry.key);
                      }
                    });
                  },
                  title: Row(
                    children: [
                      Icon(serviceIcons[entry.key], size: 20, color: color),
                      const SizedBox(width: 10),
                      Text(entry.value),
                    ],
                  ),
                  activeColor: color,
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(ThemeData theme, bool isDark) {
    final result = _result!;
    final details = (result['details'] as Map<String, dynamic>?) ?? {};
    final totalCharged = (result['total_charged'] as num?)?.toDouble() ?? 0;
    final chargesMade = result['charges_made'] as int? ?? 0;
    final docsProcessed = result['docs_processed'] as int? ?? 0;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.green, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withAlpha(30),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle, color: Colors.green, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Начисление завершено', style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700, color: Colors.green,
                      )),
                      Text(
                        '$chargesMade начислений по $docsProcessed документам',
                        style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${totalCharged.toStringAsFixed(2)} ₽',
                  style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w800, color: Colors.green,
                  ),
                ),
              ],
            ),
            if (details.isNotEmpty) ...[
              const Divider(height: 24),
              const Text('Детализация по услугам:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 8),
              ...details.entries.map((entry) {
                final svc = entry.key;
                final data = entry.value as Map<String, dynamic>;
                final color = serviceColors[svc] ?? Colors.grey;
                final icon = serviceIcons[svc] ?? Icons.monetization_on;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Icon(icon, size: 18, color: color),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          data['label'] ?? svc,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      Text(
                        '${data['count']} шт.',
                        style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${(data['total'] as num).toStringAsFixed(2)} ₽',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUndoResultCard(ThemeData theme) {
    final r = _undoResult!;
    final undoneCount = r['undone_count'] as int? ?? 0;
    final totalUndone = (r['total_undone'] as num?)?.toDouble() ?? 0;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.orange, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.undo, color: Colors.orange, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Начисления отменены', style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700, color: Colors.orange,
                  )),
                  Text(
                    '$undoneCount операций отменено',
                    style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Text(
              '-${totalUndone.toStringAsFixed(2)} ₽',
              style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.w800, color: Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(ThemeData theme) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.red, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ошибка начисления', style: TextStyle(
                    fontWeight: FontWeight.w600, color: Colors.red,
                  )),
                  const SizedBox(height: 4),
                  Text(_error!, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodsCard(ThemeData theme, bool isDark) {
    if (_loadingPeriods) {
      return const Card(child: Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      ));
    }
    if (_recentPeriods.isEmpty) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: Text('Нет данных о периодах', style: TextStyle(color: Colors.grey))),
        ),
      );
    }
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: _recentPeriods.take(12).map((p) {
            final periodStr = p['period'].toString();
            final dt = DateTime.tryParse(periodStr);
            final label = dt != null ? _formatPeriod(dt) : periodStr;
            return ListTile(
              leading: const Icon(Icons.date_range, size: 20),
              title: Text(label, style: const TextStyle(fontSize: 14)),
              trailing: const Icon(Icons.chevron_right, size: 20),
              dense: true,
              onTap: () {
                if (dt != null) {
                  setState(() => _selectedDate = DateTime(dt.year, dt.month, 1));
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _selectLocation() async {
    try {
      final dio = ref.read(dioProvider);
      final resp = await dio.get('/locations/', queryParameters: {'limit': 1000, 'assigned_only': true});
      if (resp.statusCode != 200) return;
      final locations = (resp.data as List).cast<Map<String, dynamic>>();

      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (ctx) {
          final searchCtrl = TextEditingController();
          var filtered = locations;
          return StatefulBuilder(
            builder: (ctx, setDialogState) => AlertDialog(
              title: const Text('Выбор дома'),
              content: SizedBox(
                width: 400,
                height: 400,
                child: Column(
                  children: [
                    TextField(
                      controller: searchCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Поиск по адресу...',
                        prefixIcon: Icon(Icons.search),
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (q) {
                        setDialogState(() {
                          filtered = locations.where((l) =>
                            (l['name'] ?? '').toString().toLowerCase().contains(q.toLowerCase())
                          ).toList();
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.public, color: Colors.blue),
                            title: const Text('Все дома', style: TextStyle(fontWeight: FontWeight.w600)),
                            selected: _selectedLocationId == null,
                            onTap: () {
                              setState(() {
                                _selectedLocationId = null;
                                _selectedLocationName = 'Все дома';
                              });
                              Navigator.pop(ctx);
                            },
                          ),
                          const Divider(),
                          ...filtered.map((l) => ListTile(
                            leading: const Icon(Icons.home, size: 20),
                            title: Text(l['name'] ?? 'ID: ${l['id']}', style: const TextStyle(fontSize: 14)),
                            selected: l['id'] == _selectedLocationId,
                            dense: true,
                            onTap: () {
                              setState(() {
                                _selectedLocationId = l['id'] as int;
                                _selectedLocationName = l['name'] ?? 'ID: ${l['id']}';
                              });
                              Navigator.pop(ctx);
                            },
                          )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } catch (e) {
      debugPrint('❌ Ошибка загрузки домов: $e');
    }
  }
}
