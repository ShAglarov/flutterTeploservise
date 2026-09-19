import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/base_api_service.dart';
import '../utils/app_theme.dart';

/// Экран управления тарифами — аналог cengz, cento, centbo, cenLIF и др. форм FoxPro.
/// Позволяет просматривать, создавать, редактировать и удалять тарифы по услугам.
class TariffsScreen extends ConsumerStatefulWidget {
  const TariffsScreen({super.key});

  @override
  ConsumerState<TariffsScreen> createState() => _TariffsScreenState();
}

class _TariffsScreenState extends ConsumerState<TariffsScreen> {
  List<Map<String, dynamic>> _tariffs = [];
  bool _isLoading = true;
  String? _error;
  String? _selectedService;
  bool _showInactive = false;

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

  static const Map<String, String> unitLabels = {
    'per_sqm': 'за м²',
    'per_person': 'за чел.',
    'fixed': 'фикс.',
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final dio = ref.read(dioProvider);
      final params = <String, dynamic>{
        'active_only': !_showInactive,
      };
      if (_selectedService != null) params['service'] = _selectedService;

      final resp = await dio.get('/tariffs/', queryParameters: params);
      if (resp.statusCode == 200) {
        setState(() => _tariffs = (resp.data as List).cast<Map<String, dynamic>>());
      }
    } catch (e) {
      setState(() => _error = '$e');
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Тарифы'),
        actions: [
          // Фильтр неактивных
          IconButton(
            icon: Icon(_showInactive ? Icons.visibility : Icons.visibility_off, size: 22),
            tooltip: _showInactive ? 'Скрыть неактивные' : 'Показать неактивные',
            onPressed: () {
              setState(() => _showInactive = !_showInactive);
              _load();
            },
          ),
          // Добавление
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Новый тариф',
            onPressed: () => _editTariff(null),
          ),
        ],
      ),
      body: Column(
        children: [
          // Чипы фильтра по услугам
          _buildServiceFilter(isDark),
          // Список тарифов
          Expanded(child: _buildBody(theme, isDark)),
        ],
      ),
    );
  }

  Widget _buildServiceFilter(bool isDark) {
    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          _buildFilterChip(null, 'Все', Icons.grid_view, isDark),
          const SizedBox(width: 6),
          ...serviceLabels.entries.map((e) => Padding(
            padding: const EdgeInsets.only(right: 6),
            child: _buildFilterChip(e.key, e.value, serviceIcons[e.key]!, isDark),
          )),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String? service, String label, IconData icon, bool isDark) {
    final isSelected = _selectedService == service;
    final color = service != null ? (serviceColors[service] ?? Colors.grey) : AppTheme.primaryBlue;

    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isSelected ? Colors.white : color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
          )),
        ],
      ),
      selectedColor: color,
      checkmarkColor: Colors.white,
      backgroundColor: isDark ? Colors.white10 : Colors.grey.shade100,
      side: BorderSide(color: isSelected ? color : Colors.transparent),
      onSelected: (_) {
        setState(() => _selectedService = isSelected ? null : service);
        _load();
      },
    );
  }

  Widget _buildBody(ThemeData theme, bool isDark) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
            const SizedBox(height: 12),
            Text('Ошибка загрузки', style: TextStyle(color: theme.colorScheme.onSurface)),
            const SizedBox(height: 4),
            Text(_error!, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Повторить'),
            ),
          ],
        ),
      );
    }
    if (_tariffs.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.price_change_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              _selectedService != null
                  ? 'Нет тарифов для ${serviceLabels[_selectedService]}'
                  : 'Нет тарифов',
              style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => _editTariff(null),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Добавить тариф'),
            ),
          ],
        ),
      );
    }

    // Группируем по услугам
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final t in _tariffs) {
      final svc = t['service'] as String? ?? 'unknown';
      grouped.putIfAbsent(svc, () => []).add(t);
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: grouped.entries.map((entry) {
          final svc = entry.key;
          final items = entry.value;
          final color = serviceColors[svc] ?? Colors.grey;
          final icon = serviceIcons[svc] ?? Icons.monetization_on;
          final label = serviceLabels[svc] ?? svc;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, top: 8, bottom: 6),
                child: Row(
                  children: [
                    Icon(icon, size: 20, color: color),
                    const SizedBox(width: 8),
                    Text(label, style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: color,
                    )),
                    const Spacer(),
                    Text('${items.length} шт.', style: TextStyle(
                      fontSize: 12, color: theme.colorScheme.onSurfaceVariant,
                    )),
                  ],
                ),
              ),
              ...items.map((t) => _buildTariffCard(t, color, isDark, theme)),
              const SizedBox(height: 8),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTariffCard(Map<String, dynamic> t, Color color, bool isDark, ThemeData theme) {
    final isActive = t['is_active'] == true;
    final rate = (t['rate'] as num?)?.toDouble() ?? 0;
    final unitLabel = unitLabels[t['unit']] ?? t['unit'] ?? '';
    final locationName = t['location_name'] ?? 'Все дома';
    final effectiveFrom = t['effective_from'] ?? '';
    final effectiveTo = t['effective_to'];
    final note = t['note'];

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      elevation: isActive ? 1 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isActive
            ? BorderSide(color: color.withAlpha(80), width: 1)
            : BorderSide(color: Colors.grey.withAlpha(60)),
      ),
      color: isActive ? null : (isDark ? Colors.white.withAlpha(10) : Colors.grey.shade50),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _editTariff(t),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Индикатор активности
              Container(
                width: 4,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: isActive ? color : Colors.grey.shade400,
                ),
              ),
              const SizedBox(width: 12),
              // Основная информация
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${rate.toStringAsFixed(2)} ₽',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: isActive ? theme.colorScheme.onSurface : Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withAlpha(30),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(unitLabel, style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: color,
                          )),
                        ),
                        if (!isActive) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red.withAlpha(30),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('Неактивен', style: TextStyle(
                              fontSize: 10, fontWeight: FontWeight.w600, color: Colors.red,
                            )),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.home_outlined, size: 14, color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(locationName, style: TextStyle(
                            fontSize: 12, color: theme.colorScheme.onSurfaceVariant,
                          ), overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 14, color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          effectiveTo != null ? 'c $effectiveFrom по $effectiveTo' : 'с $effectiveFrom',
                          style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                    if (note != null && note.toString().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(note.toString(), style: TextStyle(
                          fontSize: 11, fontStyle: FontStyle.italic,
                          color: theme.colorScheme.onSurfaceVariant,
                        )),
                      ),
                  ],
                ),
              ),
              // Действия
              PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'edit') _editTariff(t);
                  if (v == 'toggle') _toggleActive(t);
                  if (v == 'delete') _delete(t['id'] as int);
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit', child: ListTile(
                    leading: Icon(Icons.edit, size: 20), title: Text('Редактировать'),
                  )),
                  PopupMenuItem(value: 'toggle', child: ListTile(
                    leading: Icon(
                      isActive ? Icons.pause_circle : Icons.play_circle,
                      size: 20,
                      color: isActive ? Colors.orange : Colors.green,
                    ),
                    title: Text(isActive ? 'Деактивировать' : 'Активировать'),
                  )),
                  const PopupMenuItem(value: 'delete', child: ListTile(
                    leading: Icon(Icons.delete, size: 20, color: Colors.red),
                    title: Text('Удалить', style: TextStyle(color: Colors.red)),
                  )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editTariff(Map<String, dynamic>? existing) async {
    final isNew = existing == null;
    String selectedService = (existing?['service'] as String?) ?? 'heating';
    String selectedUnit = (existing?['unit'] as String?) ?? 'per_sqm';
    final rateCtrl = TextEditingController(
      text: existing != null ? (existing['rate'] as num?)?.toStringAsFixed(2) ?? '' : '',
    );
    final noteCtrl = TextEditingController(text: existing?['note'] ?? '');
    final fromCtrl = TextEditingController(
      text: existing?['effective_from'] ?? DateTime.now().toIso8601String().substring(0, 10),
    );
    final toCtrl = TextEditingController(text: existing?['effective_to'] ?? '');

    // Для выбора дома (null = для всех)
    int? selectedLocationId = existing?['location_id'] as int?;
    String selectedLocationName = existing?['location_name'] ?? 'Все дома';

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(isNew ? '➕ Новый тариф' : '✏️ Редактирование тарифа'),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Услуга
                  if (isNew) ...[
                    const Text('Услуга', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: selectedService,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                        prefixIcon: Icon(Icons.category, size: 20),
                      ),
                      items: serviceLabels.entries.map((e) => DropdownMenuItem(
                        value: e.key,
                        child: Row(
                          children: [
                            Icon(serviceIcons[e.key], size: 18, color: serviceColors[e.key]),
                            const SizedBox(width: 8),
                            Text(e.value),
                          ],
                        ),
                      )).toList(),
                      onChanged: (v) => setDialogState(() => selectedService = v!),
                    ),
                    const SizedBox(height: 16),
                  ] else ...[
                    Row(
                      children: [
                        Icon(serviceIcons[selectedService], size: 20,
                            color: serviceColors[selectedService]),
                        const SizedBox(width: 8),
                        Text(
                          serviceLabels[selectedService] ?? selectedService,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Ставка
                  const Text('Ставка (₽)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: rateCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                      prefixIcon: Icon(Icons.payments, size: 20),
                      hintText: '0.00',
                      suffixText: '₽',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Единица
                  const Text('Единица', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: selectedUnit,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                      prefixIcon: Icon(Icons.straighten, size: 20),
                    ),
                    items: unitLabels.entries.map((e) => DropdownMenuItem(
                      value: e.key,
                      child: Text(e.value),
                    )).toList(),
                    onChanged: (v) => setDialogState(() => selectedUnit = v!),
                  ),
                  const SizedBox(height: 16),

                  // Дом
                  const Text('Дом', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () => _selectLocation(ctx, selectedLocationId, (id, name) {
                      setDialogState(() {
                        selectedLocationId = id;
                        selectedLocationName = name;
                      });
                    }),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                        prefixIcon: Icon(Icons.home, size: 20),
                        suffixIcon: Icon(Icons.arrow_drop_down),
                      ),
                      child: Text(selectedLocationName, style: const TextStyle(fontSize: 14)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Даты
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Действует с', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: fromCtrl,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                isDense: true,
                                prefixIcon: Icon(Icons.event, size: 20),
                                hintText: 'ГГГГ-ММ-ДД',
                              ),
                              onTap: () => _pickDate(ctx, fromCtrl),
                              readOnly: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Действует до', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: toCtrl,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                isDense: true,
                                prefixIcon: const Icon(Icons.event_busy, size: 20),
                                hintText: 'Бессрочно',
                                suffixIcon: toCtrl.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear, size: 18),
                                        onPressed: () => setDialogState(() => toCtrl.clear()),
                                      )
                                    : null,
                              ),
                              onTap: () => _pickDate(ctx, toCtrl),
                              readOnly: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Примечание
                  TextField(
                    controller: noteCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                      labelText: 'Примечание',
                      prefixIcon: Icon(Icons.note, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(isNew ? 'Создать' : 'Сохранить'),
            ),
          ],
        ),
      ),
    );

    if (result != true) return;

    final rate = double.tryParse(rateCtrl.text);
    if (rate == null || rate <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Укажите корректную ставку'), backgroundColor: Colors.red),
        );
      }
      return;
    }

    final body = <String, dynamic>{
      'rate': rate,
      'unit': selectedUnit,
      'effective_from': fromCtrl.text,
      'note': noteCtrl.text.isEmpty ? null : noteCtrl.text,
    };
    if (toCtrl.text.isNotEmpty) body['effective_to'] = toCtrl.text;
    if (isNew) {
      body['service'] = selectedService;
      body['location_id'] = selectedLocationId;
    }

    try {
      final dio = ref.read(dioProvider);
      if (isNew) {
        await dio.post('/tariffs/', data: body);
      } else {
        await dio.put('/tariffs/${existing['id']}', data: body);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isNew ? '✅ Тариф создан' : '✅ Тариф обновлён'),
            backgroundColor: Colors.green,
          ),
        );
      }
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Ошибка: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _pickDate(BuildContext ctx, TextEditingController ctrl) async {
    final initial = DateTime.tryParse(ctrl.text) ?? DateTime.now();
    final picked = await showDatePicker(
      context: ctx,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      ctrl.text = picked.toIso8601String().substring(0, 10);
    }
  }

  Future<void> _selectLocation(BuildContext ctx, int? currentId, void Function(int?, String) onSelect) async {
    // Загружаем список домов
    try {
      final dio = ref.read(dioProvider);
      final resp = await dio.get('/locations/', queryParameters: {'limit': 1000, 'assigned_only': true});
      if (resp.statusCode != 200) return;

      final locations = (resp.data as List).cast<Map<String, dynamic>>();

      if (!ctx.mounted) return;

      await showDialog(
        context: ctx,
        builder: (dlgCtx) {
          final searchCtrl = TextEditingController();
          var filtered = locations;
          return StatefulBuilder(
            builder: (dlgCtx, setState) => AlertDialog(
              title: const Text('Выбор дома'),
              content: SizedBox(
                width: 400,
                height: 400,
                child: Column(
                  children: [
                    TextField(
                      controller: searchCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Поиск...',
                        prefixIcon: Icon(Icons.search),
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (q) {
                        setState(() {
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
                            selected: currentId == null,
                            onTap: () {
                              onSelect(null, 'Все дома');
                              Navigator.pop(dlgCtx);
                            },
                          ),
                          const Divider(),
                          ...filtered.map((l) => ListTile(
                            leading: const Icon(Icons.home, size: 20),
                            title: Text(l['name'] ?? 'ID: ${l['id']}', style: const TextStyle(fontSize: 14)),
                            selected: l['id'] == currentId,
                            dense: true,
                            onTap: () {
                              onSelect(l['id'] as int, l['name'] ?? 'ID: ${l['id']}');
                              Navigator.pop(dlgCtx);
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

  Future<void> _toggleActive(Map<String, dynamic> t) async {
    final isActive = t['is_active'] == true;
    try {
      final dio = ref.read(dioProvider);
      await dio.put('/tariffs/${t['id']}', data: {'is_active': !isActive});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isActive ? '⏸ Тариф деактивирован' : '▶️ Тариф активирован'),
            backgroundColor: isActive ? Colors.orange : Colors.green,
          ),
        );
      }
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _delete(int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить тариф?'),
        content: const Text('Тариф будет удалён безвозвратно. Это не повлияет на уже сделанные начисления.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      final dio = ref.read(dioProvider);
      await dio.delete('/tariffs/$id');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🗑 Тариф удалён')),
        );
      }
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
