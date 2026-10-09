import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/gis_details_models.dart';
import '../services/gis_details_service.dart';
import 'gis_params_screen.dart';

/// Подъезды и лифты дома — листы «Подъезды», «Лифты» и «Информация о
/// лифтах» шаблона ГИС ЖКХ.
///
/// До этого экрана подъезды существовали только числом в карточке дома,
/// а лифтов не было вовсе, поэтому соответствующие листы шаблона
/// выгружались пустыми.
class HouseStructureScreen extends ConsumerStatefulWidget {
  final int locationId;
  final String houseName;

  const HouseStructureScreen({
    super.key,
    required this.locationId,
    required this.houseName,
  });

  @override
  ConsumerState<HouseStructureScreen> createState() =>
      _HouseStructureScreenState();
}

class _HouseStructureScreenState extends ConsumerState<HouseStructureScreen> {
  List<Entrance> _entrances = [];
  List<Lift> _lifts = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final service = ref.read(gisDetailsServiceProvider);
      final results = await Future.wait([
        service.getEntrances(widget.locationId),
        service.getLifts(widget.locationId),
      ]);
      _entrances = results[0] as List<Entrance>;
      _lifts = results[1] as List<Lift>;
    } catch (e) {
      _error = _message(e);
    }
    if (mounted) setState(() => _loading = false);
  }

  String _message(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['detail'] != null) return '${data['detail']}';
      return error.message ?? 'Ошибка сети';
    }
    return '$error';
  }

  void _toast(String text, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text),
      backgroundColor: error ? Colors.red : Colors.green,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Подъезды и лифты'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              widget.houseName,
              style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context)
                      .appBarTheme
                      .foregroundColor
                      ?.withAlpha(180),
                ),
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      OutlinedButton(
                          onPressed: _load, child: const Text('Повторить')),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 80),
                    children: [
                      _header('Подъезды', _entrances.length),
                      if (_entrances.isEmpty)
                        _empty('Подъезды не заведены. В выгрузку попадёт '
                            'нумерация 1..N по количеству из карточки дома.'),
                      ..._entrances.map(_entranceTile),
                      _addButton('Добавить подъезд', _editEntrance),
                      const SizedBox(height: 16),
                      _header('Лифты', _lifts.length),
                      if (_lifts.isEmpty)
                        _empty('Лифтов нет — лист «Лифты» останется пустым.'),
                      ..._lifts.map(_liftTile),
                      _addButton('Добавить лифт', _editLift),
                    ],
                  ),
                ),
    );
  }

  Widget _header(String title, int count) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Row(
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            Text('$count', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );

  Widget _empty(String text) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Text(text,
            style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      );

  Widget _addButton(String label, VoidCallback onTap) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: OutlinedButton.icon(
          icon: const Icon(Icons.add),
          label: Text(label),
          onPressed: onTap,
        ),
      );

  Widget _entranceTile(Entrance item) {
    final details = [
      if (item.floors != null) 'этажей ${item.floors}',
      if (item.yearBuilt != null) '${item.yearBuilt} г.',
      if (!item.confirmed) 'не подтверждено',
    ].join(' · ');
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: const Icon(Icons.door_front_door, color: Colors.brown),
        title: Text('Подъезд №${item.number}'),
        subtitle: details.isEmpty ? null : Text(details),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') _editEntrance(item);
            if (value == 'delete') _deleteEntrance(item);
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Изменить')),
            PopupMenuItem(value: 'delete', child: Text('Удалить')),
          ],
        ),
        onTap: () => _editEntrance(item),
      ),
    );
  }

  Widget _liftTile(Lift item) {
    final entrance =
        _entrances.where((e) => e.id == item.entranceId).firstOrNull;
    final details = [
      if (item.liftType != null && item.liftType!.isNotEmpty) item.liftType!,
      if (entrance != null) 'подъезд ${entrance.number}',
      if (item.serviceLifeUntil != null) 'до ${item.serviceLifeUntil} г.',
    ].join(' · ');
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: const Icon(Icons.elevator, color: Colors.indigo),
        title: Text(item.factoryNumber),
        subtitle: details.isEmpty ? null : Text(details),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') _editLift(item);
            if (value == 'params') _openLiftParams(item);
            if (value == 'delete') _deleteLift(item);
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Изменить')),
            PopupMenuItem(
                value: 'params', child: Text('Расширенные сведения')),
            PopupMenuItem(value: 'delete', child: Text('Удалить')),
          ],
        ),
        onTap: () => _editLift(item),
      ),
    );
  }

  void _openLiftParams(Lift item) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => GisParamsScreen(
        groupKey: 'lift_info',
        ownerType: 'lift',
        ownerId: item.id!,
        ownerTitle: 'Лифт ${item.factoryNumber}',
      ),
    ));
  }

  // ─────────────────────────── подъезды ───────────────────────────

  Future<void> _editEntrance([Entrance? item]) async {
    final number = TextEditingController(text: item?.number ?? '');
    final floors =
        TextEditingController(text: item?.floors?.toString() ?? '');
    final year =
        TextEditingController(text: item?.yearBuilt?.toString() ?? '');
    var confirmed = item?.confirmed ?? true;

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          title: Text(item == null ? 'Новый подъезд' : 'Подъезд'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: number,
                  decoration: const InputDecoration(
                    labelText: 'Номер подъезда *',
                    helperText: 'Обязательное поле портала',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: floors,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(labelText: 'Этажность'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: year,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(labelText: 'Год постройки'),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Информация подтверждена'),
                  value: confirmed,
                  onChanged: (v) => setDialog(() => confirmed = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Отмена')),
            FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Сохранить')),
          ],
        ),
      ),
    );
    if (saved != true) return;

    if (number.text.trim().isEmpty) {
      _toast('Укажите номер подъезда', error: true);
      return;
    }
    final payload = Entrance(
      locationId: widget.locationId,
      number: number.text.trim(),
      floors: int.tryParse(floors.text),
      yearBuilt: int.tryParse(year.text),
      confirmed: confirmed,
    );
    try {
      final service = ref.read(gisDetailsServiceProvider);
      if (item?.id == null) {
        await service.createEntrance(payload);
      } else {
        await service.updateEntrance(item!.id!, payload);
      }
      await _load();
      _toast('Сохранено');
    } catch (e) {
      _toast(_message(e), error: true);
    }
  }

  Future<void> _deleteEntrance(Entrance item) async {
    final lifts = _lifts.where((l) => l.entranceId == item.id).length;
    final ok = await _confirm(
      'Удалить подъезд №${item.number}?',
      lifts > 0
          ? 'Вместе с ним удалятся лифты этого подъезда ($lifts).'
          : null,
    );
    if (!ok) return;
    try {
      await ref.read(gisDetailsServiceProvider).deleteEntrance(item.id!);
      await _load();
      _toast('Подъезд удалён');
    } catch (e) {
      _toast(_message(e), error: true);
    }
  }

  // ─────────────────────────── лифты ───────────────────────────

  Future<void> _editLift([Lift? item]) async {
    final factory = TextEditingController(text: item?.factoryNumber ?? '');
    final life =
        TextEditingController(text: item?.serviceLifeUntil?.toString() ?? '');
    var liftType = item?.liftType;
    var entranceId = item?.entranceId;

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          title: Text(item == null ? 'Новый лифт' : 'Лифт'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: factory,
                  decoration: const InputDecoration(
                    labelText: 'Заводской номер *',
                    helperText: 'Обязательное поле портала',
                  ),
                ),
                const SizedBox(height: 8),
                // Тип лифта — строго из списка портала (лист «Тип лифта»
                // шаблона), иначе строка не принимается.
                DropdownButtonFormField<String>(
                  initialValue: liftType,
                  decoration: const InputDecoration(labelText: 'Тип лифта'),
                  items: const [
                    DropdownMenuItem(
                        value: 'Пассажирский', child: Text('Пассажирский')),
                    DropdownMenuItem(
                        value: 'Грузовой', child: Text('Грузовой')),
                    DropdownMenuItem(
                        value: 'Грузопассажирский',
                        child: Text('Грузопассажирский')),
                  ],
                  onChanged: (v) => setDialog(() => liftType = v),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int?>(
                  initialValue: entranceId,
                  decoration: const InputDecoration(
                    labelText: 'Подъезд',
                    helperText: 'Портал требует номер подъезда',
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('не указан')),
                    for (final e in _entrances)
                      DropdownMenuItem(
                          value: e.id, child: Text('Подъезд №${e.number}')),
                  ],
                  onChanged: (v) => setDialog(() => entranceId = v),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: life,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                      labelText: 'Предельный срок эксплуатации (год)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Отмена')),
            FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Сохранить')),
          ],
        ),
      ),
    );
    if (saved != true) return;

    if (factory.text.trim().isEmpty) {
      _toast('Укажите заводской номер', error: true);
      return;
    }
    final payload = Lift(
      locationId: widget.locationId,
      entranceId: entranceId,
      factoryNumber: factory.text.trim(),
      liftType: liftType,
      serviceLifeUntil: int.tryParse(life.text),
    );
    try {
      final service = ref.read(gisDetailsServiceProvider);
      if (item?.id == null) {
        await service.createLift(payload);
      } else {
        await service.updateLift(item!.id!, payload);
      }
      await _load();
      _toast('Сохранено');
    } catch (e) {
      _toast(_message(e), error: true);
    }
  }

  Future<void> _deleteLift(Lift item) async {
    if (!await _confirm('Удалить лифт ${item.factoryNumber}?', null)) return;
    try {
      await ref.read(gisDetailsServiceProvider).deleteLift(item.id!);
      await _load();
      _toast('Лифт удалён');
    } catch (e) {
      _toast(_message(e), error: true);
    }
  }

  Future<bool> _confirm(String title, String? detail) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: detail == null ? null : Text(detail),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Отмена')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    return result == true;
  }
}
