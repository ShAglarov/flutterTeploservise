import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/gis_details_models.dart';
import '../services/gis_details_service.dart';
import '../utils/app_theme.dart';

/// Расширенные сведения ГИС ЖКХ для одного объекта.
///
/// Форма строится ПО КАТАЛОГУ с сервера, а не по захардкоженному
/// списку: параметров 123, и их состав меняется вместе с версией
/// шаблона ГИС. Так обновление шаблона на сервере не требует новой
/// версии приложения.
///
/// Соответствует листам «Информация о МКД», «Конструктивные элементы»,
/// «Внутридомовые сети», «Информация о лифтах», «Информация о жилых
/// (нежилых) помещениях», «Информация о комнатах».
class GisParamsScreen extends ConsumerStatefulWidget {
  /// Группа параметров = лист шаблона (house_info, house_structure, …).
  final String groupKey;

  /// house / lift / premises / room.
  final String ownerType;
  final int ownerId;

  /// Что правим — показывается в подзаголовке.
  final String ownerTitle;

  const GisParamsScreen({
    super.key,
    required this.groupKey,
    required this.ownerType,
    required this.ownerId,
    required this.ownerTitle,
  });

  @override
  ConsumerState<GisParamsScreen> createState() => _GisParamsScreenState();
}

class _GisParamsScreenState extends ConsumerState<GisParamsScreen> {
  /// Текущее значение каждого параметра по его названию.
  final Map<String, String> _values = {};
  bool _loading = true;
  bool _saving = false;
  String? _error;
  String _search = '';

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
      final saved = await service.getParams(
        ownerType: widget.ownerType,
        ownerId: widget.ownerId,
        groupKey: widget.groupKey,
      );
      _values
        ..clear()
        ..addEntries(saved
            .where((e) => (e.value ?? '').isNotEmpty)
            .map((e) => MapEntry(e.paramName, e.value!)));
    } on DioException catch (e) {
      _error = e.response?.data is Map
          ? '${(e.response!.data as Map)['detail'] ?? e.message}'
          : e.message;
    } catch (e) {
      _error = '$e';
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref.read(gisDetailsServiceProvider).saveParams(
            groupKey: widget.groupKey,
            ownerType: widget.ownerType,
            ownerId: widget.ownerId,
            // Передаём ВСЕ заполненные параметры: сервер заменяет
            // группу целиком, поэтому снятое значение исчезнет и из
            // выгрузки.
            params: _values.entries
                .map((e) => GisParamValue(paramName: e.key, value: e.value))
                .toList(),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Сведения сохранены'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(true);
    } on DioException catch (e) {
      final detail = e.response?.data is Map
          ? '${(e.response!.data as Map)['detail'] ?? e.message}'
          : e.message;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$detail'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(gisCatalogProvider);

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        title: catalog.maybeWhen(
          data: (groups) {
            final group =
                groups.where((g) => g.key == widget.groupKey).firstOrNull;
            return Text(group?.title ?? 'Сведения ГИС');
          },
          orElse: () => const Text('Сведения ГИС'),
        ),
        actions: [
          if (_saving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              tooltip: 'Сохранить',
              onPressed: _save,
            ),
        ],
      ),
      body: catalog.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _buildError('Не удалось получить каталог: $e'),
        data: (groups) {
          final group =
              groups.where((g) => g.key == widget.groupKey).firstOrNull;
          if (group == null) {
            return _buildError(
                'Группа «${widget.groupKey}» отсутствует в шаблоне на сервере');
          }
          if (_loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_error != null) return _buildError(_error!);
          return _buildForm(group);
        },
      ),
    );
  }

  Widget _buildError(String message) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.orange),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              OutlinedButton(onPressed: _load, child: const Text('Повторить')),
            ],
          ),
        ),
      );

  Widget _buildForm(GisParamGroup group) {
    final query = _search.trim().toLowerCase();
    final params = query.isEmpty
        ? group.params
        : group.params
            .where((p) => p.name.toLowerCase().contains(query))
            .toList();
    final filled = _values.values.where((v) => v.isNotEmpty).length;

    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.ownerTitle,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    'заполнено $filled из ${group.params.length}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Поиск: у внутридомовых сетей 55 параметров, листать их
              // ради одного — неудобно.
              TextField(
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'Поиск параметра',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (v) => setState(() => _search = v),
              ),
            ],
          ),
        ),
        Expanded(
          child: params.isEmpty
              ? const Center(child: Text('Ничего не найдено'))
              : ListView.separated(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: params.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (_, i) => _buildParamTile(params[i]),
                ),
        ),
      ],
    );
  }

  Widget _buildParamTile(GisParamDef param) {
    final value = _values[param.name] ?? '';
    final hasValue = value.isNotEmpty;

    // Перечислимые — только выбором из справочника: портал сверяет
    // значение дословно, и опечатка приводит к отказу файла.
    if (param.values.isNotEmpty) {
      return ListTile(
        title: Text(param.label),
        subtitle: Text(
          hasValue ? value : 'не заполнено',
          style: TextStyle(
            color: hasValue ? AppTheme.primaryBlue : Colors.grey,
            fontWeight: hasValue ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _pickEnum(param),
      );
    }

    if (param.valueType == 'bool') {
      // Три состояния: «Да», «Нет» и «не заполнено» — пустое поле
      // портал трактует как отсутствие сведений, это не то же, что «Нет».
      return ListTile(
        title: Text(param.label),
        subtitle: Text(hasValue ? value : 'не заполнено',
            style: TextStyle(color: hasValue ? null : Colors.grey)),
        trailing: Wrap(
          spacing: 4,
          children: [
            for (final option in ['Да', 'Нет'])
              ChoiceChip(
                label: Text(option),
                selected: value == option,
                onSelected: (sel) => setState(() {
                  if (sel) {
                    _values[param.name] = option;
                  } else {
                    _values.remove(param.name);
                  }
                }),
              ),
          ],
        ),
      );
    }

    final isNumber = param.valueType == 'number' ||
        param.valueType == 'integer' ||
        param.valueType == 'year';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextFormField(
        initialValue: value,
        keyboardType: isNumber
            ? (param.valueType == 'number'
                ? const TextInputType.numberWithOptions(decimal: true)
                : TextInputType.number)
            : TextInputType.text,
        inputFormatters: param.valueType == 'integer' ||
                param.valueType == 'year'
            ? [FilteringTextInputFormatter.digitsOnly]
            : null,
        decoration: InputDecoration(
          labelText: param.label,
          isDense: true,
          hintText: param.valueType == 'date' ? 'ДД.ММ.ГГГГ' : null,
          border: const OutlineInputBorder(),
        ),
        onChanged: (v) {
          final text = v.trim();
          if (text.isEmpty) {
            _values.remove(param.name);
          } else {
            _values[param.name] = text;
          }
        },
      ),
    );
  }

  Future<void> _pickEnum(GisParamDef param) async {
    final current = (_values[param.name] ?? '')
        .split(';')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet();

    final picked = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final selected = {...current};
        return StatefulBuilder(
          builder: (ctx, setSheet) => DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.7,
            builder: (_, controller) => Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          param.label,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(selected),
                        child: const Text('Готово'),
                      ),
                    ],
                  ),
                ),
                if (param.multiple)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Можно выбрать несколько значений',
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),
                  ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    controller: controller,
                    itemCount: param.values.length,
                    itemBuilder: (_, i) {
                      final option = param.values[i];
                      final isOn = selected.contains(option);
                      return param.multiple
                          ? CheckboxListTile(
                              value: isOn,
                              title: Text(option),
                              onChanged: (v) => setSheet(() {
                                if (v == true) {
                                  selected.add(option);
                                } else {
                                  selected.remove(option);
                                }
                              }),
                            )
                          // Не RadioListTile: его groupValue/onChanged
                          // объявлены deprecated (нужен RadioGroup), а
                          // выбор здесь всё равно закрывает лист.
                          : ListTile(
                              leading: Icon(
                                isOn
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_unchecked,
                                color: isOn ? AppTheme.primaryBlue : null,
                              ),
                              title: Text(option),
                              onTap: () {
                                selected
                                  ..clear()
                                  ..add(option);
                                Navigator.of(ctx).pop(selected);
                              },
                            );
                    },
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(<String>{}),
                      child: const Text('Очистить'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (picked == null) return;
    setState(() {
      if (picked.isEmpty) {
        _values.remove(param.name);
      } else {
        // Несколько значений портал принимает через «;» — так же, как
        // отдаёт их в своём экспорте.
        _values[param.name] = picked.join('; ');
      }
    });
  }
}
