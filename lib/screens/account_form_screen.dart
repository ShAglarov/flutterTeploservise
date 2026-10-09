import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/location_models.dart';
import '../models/permission_key.dart';
import '../services/location_service.dart';
import '../services/permission_service.dart';
import '../utils/app_theme.dart';
import '../utils/gis_dictionaries.dart';

/// Создание и правка лицевого счёта вручную.
///
/// До этого счета можно было только импортировать шаблоном. Поля ГИС
/// живут на отдельном экране (`account_gis_screen.dart`) — здесь то, что
/// нужно для обычной работы: кто, где, какая площадь.
class AccountFormScreen extends ConsumerStatefulWidget {
  /// null — создание нового счёта.
  final AccountResponse? account;

  /// Дом, к которому привязывается новый счёт.
  final int locationId;
  final String? locationName;

  const AccountFormScreen({
    super.key,
    this.account,
    required this.locationId,
    this.locationName,
  });

  @override
  ConsumerState<AccountFormScreen> createState() => _AccountFormScreenState();
}

class _AccountFormScreenState extends ConsumerState<AccountFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _number;
  late final TextEditingController _fio;
  late final TextEditingController _address;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  late final TextEditingController _area;
  late final TextEditingController _livingArea;
  late final TextEditingController _heatedArea;
  late final TextEditingController _residents;
  late final TextEditingController _rooms;
  late final TextEditingController _jku;
  late final TextEditingController _els;
  late final TextEditingController _cadastral;
  late final TextEditingController _serviceType;
  late final TextEditingController _premisesNumber;

  String? _status;
  // Справочные поля ГИС — выбором, а не вводом: портал сверяет текст
  // дословно, и опечатка в «ЛС УО» приводит к отказу файла.
  String? _accountType;
  String? _premisesType;
  String? _docType;
  bool _saving = false;

  bool get _isEditing => widget.account != null;

  static const _statuses = ['Активный', 'Закрыт', 'Приостановлен'];

  @override
  void initState() {
    super.initState();
    final a = widget.account;
    _number = TextEditingController(text: a?.accountNumber ?? '');
    _fio = TextEditingController(text: a?.fio ?? '');
    _address = TextEditingController(text: a?.address ?? '');
    _phone = TextEditingController(text: a?.phone ?? '');
    _email = TextEditingController(text: a?.email ?? '');
    _area = TextEditingController(text: _num(a?.area));
    _livingArea = TextEditingController(text: _num(a?.livingArea));
    _heatedArea = TextEditingController(text: _num(a?.heatedArea));
    _residents = TextEditingController(text: a?.residentsCount?.toString() ?? '');
    _rooms = TextEditingController(text: a?.roomsCount?.toString() ?? '');
    _jku = TextEditingController(text: a?.jkuIdentifier ?? '');
    _els = TextEditingController(text: a?.gisEls ?? '');
    _cadastral = TextEditingController(text: a?.cadastralNumber ?? '');
    _serviceType = TextEditingController(text: a?.serviceType ?? '');
    _premisesNumber = TextEditingController(text: a?.gisPremisesNumber ?? '');
    final status = a?.status;
    _status = (status != null && _statuses.contains(status)) ? status : null;
    _accountType = gisAccountTypes.contains(a?.gisAccountType)
        ? a!.gisAccountType
        : null;
    _premisesType = gisPremisesTypes.contains(a?.gisPremisesType)
        ? a!.gisPremisesType
        : null;
    _docType = gisDocumentTypes.contains(a?.gisDocType) ? a!.gisDocType : null;
  }

  /// Площадь без хвоста «.0»: в поле ввода он только мешает.
  String _num(double? v) {
    if (v == null) return '';
    return v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();
  }

  @override
  void dispose() {
    for (final c in [
      _number, _fio, _address, _phone, _email, _area, _livingArea,
      _heatedArea, _residents, _rooms, _jku, _els, _cadastral, _serviceType,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _t(TextEditingController c) =>
      c.text.trim().isEmpty ? null : c.text.trim();

  double? _d(TextEditingController c) {
    final s = c.text.trim();
    if (s.isEmpty) return null;
    return double.tryParse(s.replaceAll(',', '.'));
  }

  int? _i(TextEditingController c) {
    final s = c.text.trim();
    return s.isEmpty ? null : int.tryParse(s);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final service = ref.read(locationServiceProvider);

      if (_isEditing) {
        // AccountUpdate сериализуется с includeIfNull: false — поля ГИС,
        // которых нет на этом экране, не затираются.
        await service.updateAccount(
          widget.account!.id,
          AccountUpdate(
            accountNumber: _t(_number),
            fio: _t(_fio),
            address: _t(_address),
            phone: _t(_phone),
            email: _t(_email),
            area: _d(_area),
            livingArea: _d(_livingArea),
            heatedArea: _d(_heatedArea),
            residentsCount: _i(_residents),
            roomsCount: _i(_rooms),
            jkuIdentifier: _t(_jku),
            gisEls: _t(_els),
            cadastralNumber: _t(_cadastral),
            serviceType: _t(_serviceType),
            status: _status,
            gisAccountType: _accountType,
            gisPremisesType: _premisesType,
            gisDocType: _docType,
            gisPremisesNumber: _t(_premisesNumber),
          ),
        );
      } else {
        await service.createAccount(AccountCreate(
          locationId: widget.locationId,
          accountNumber: _number.text.trim(),
          fio: _t(_fio),
          address: _t(_address),
          phone: _t(_phone),
          email: _t(_email),
          area: _d(_area),
          jkuIdentifier: _t(_jku),
          serviceType: _t(_serviceType),
          status: _status,
          cadastralNumber: _t(_cadastral),
          roomsCount: _i(_rooms),
        ));
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_isEditing ? 'Лицевой счёт обновлён' : 'Лицевой счёт создан'),
          backgroundColor: AppTheme.successGreen,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_errorText(e)),
          backgroundColor: AppTheme.errorRed,
          duration: const Duration(seconds: 5),
        ));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _errorText(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      String? detail;
      if (data is Map) detail = data['detail']?.toString();
      if (detail != null && detail.startsWith('permission_denied')) {
        return _isEditing
            ? 'Нет права на изменение лицевых счетов'
            : 'Нет права на создание лицевых счетов';
      }
      if (e.response?.statusCode == 409 ||
          (detail != null && detail.toLowerCase().contains('unique'))) {
        return 'Лицевой счёт с таким номером уже есть в этой организации';
      }
      return detail ?? e.message ?? 'Ошибка сети';
    }
    return e.toString();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final perms = ref.watch(permissionStateProvider);
    final canSave = _isEditing
        ? perms.hasPermission(PermissionKey.accountUpdate)
        : perms.hasPermission(PermissionKey.accountCreate);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Лицевой счёт' : 'Новый лицевой счёт'),
        actions: [
          if (_saving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Center(
                child: SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            )
          else if (canSave)
            TextButton(onPressed: _save, child: const Text('Сохранить')),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (widget.locationName != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: [
                    Icon(Icons.home_outlined, size: 16,
                        color: cs.onSurface.withAlpha(150)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(widget.locationName!,
                          style: TextStyle(
                              fontSize: 12.5, color: cs.onSurface.withAlpha(165))),
                    ),
                  ],
                ),
              ),

            _header('Основное'),
            _field(_number, 'Номер лицевого счёта *',
                hint: '00102900170',
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Укажите номер счёта'
                    : null),
            _field(_fio, 'ФИО владельца', hint: 'Иванова Мария Петровна'),
            _field(_address, 'Адрес помещения',
                hint: 'ул. Ленина, д. 27, кв. 1', maxLines: 2),
            _dropdownStatus(cs),
            _field(_serviceType, 'Тип услуги', hint: 'Отопление'),

            const SizedBox(height: 8),
            _header('Контакты'),
            _field(_phone, 'Телефон', hint: '+7 999 123-45-67',
                keyboard: TextInputType.phone),
            _field(_email, 'Email',
                keyboard: TextInputType.emailAddress,
                validator: (v) {
                  final s = v?.trim() ?? '';
                  if (s.isEmpty) return null;
                  return (s.contains('@') && s.contains('.'))
                      ? null
                      : 'Некорректный email';
                }),

            const SizedBox(height: 8),
            _header('Площади и проживающие'),
            _field(_area, 'Общая площадь, кв. м', number: true),
            _field(_rooms, 'Количество комнат', number: true),
            // Эти поля есть только в AccountUpdate: при создании сервер их
            // не принимает, поэтому показываем их лишь при правке.
            if (_isEditing) ...[
              _field(_livingArea, 'Жилая площадь, кв. м', number: true),
              _field(_heatedArea, 'Отапливаемая площадь, кв. м', number: true),
              _field(_residents, 'Количество проживающих', number: true),
            ],

            const SizedBox(height: 8),
            _header('Данные для ГИС ЖКХ'),
            _gisDropdown('Тип лицевого счёта', _accountType, gisAccountTypes,
                (v) => setState(() => _accountType = v)),
            _gisDropdown('Тип помещения', _premisesType, gisPremisesTypes,
                (v) => setState(() => _premisesType = v)),
            _field(_premisesNumber, 'Номер помещения (квартиры)', hint: '12'),
            if (_isEditing)
              _gisDropdown('Вид документа', _docType, gisDocumentTypes,
                  (v) => setState(() => _docType = v)),

            const SizedBox(height: 8),
            _header('Идентификаторы'),
            _field(_jku, 'Идентификатор ЖКУ', hint: '80РС558347-01'),
            if (_isEditing) _field(_els, 'Единый лицевой счёт (ЕЛС)'),
            _field(_cadastral, 'Кадастровый номер помещения',
                hint: '05:40:000123:456'),

            if (_isEditing)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Остальные поля ГИС ЖКХ — кнопка 🏛 в списке счетов.',
                  style: TextStyle(fontSize: 11.5, color: cs.onSurface.withAlpha(140)),
                ),
              ),

            const SizedBox(height: 22),
            if (canSave)
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: Text(_isEditing ? 'Сохранить' : 'Создать счёт'),
                ),
              )
            else
              Text(
                _isEditing
                    ? 'Нет права на изменение лицевых счетов'
                    : 'Нет права на создание лицевых счетов',
                style: TextStyle(fontSize: 12, color: cs.onSurface.withAlpha(150)),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _header(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
            color: Theme.of(context).colorScheme.onSurface.withAlpha(140),
          ),
        ),
      );

  /// Выпадающий список значений ГИС.
  ///
  /// Длинные варианты (виды документов) в строке не поместились бы,
  /// поэтому список прокручиваемый и значение переносится.
  Widget _gisDropdown(
    String label,
    String? value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: DropdownButtonFormField<String?>(
          initialValue: value,
          isExpanded: true,
          isDense: true,
          decoration: InputDecoration(
            labelText: label,
            isDense: true,
            border: const OutlineInputBorder(),
          ),
          style: const TextStyle(fontSize: 12.5),
          items: [
            const DropdownMenuItem<String?>(
                value: null,
                child: Text('не указан', style: TextStyle(fontSize: 12.5))),
            ...options.map((o) => DropdownMenuItem<String?>(
                  value: o,
                  child: Text(o,
                      style: const TextStyle(fontSize: 12.5),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                )),
          ],
          onChanged: onChanged,
        ),
      );

  Widget _dropdownStatus(ColorScheme cs) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: DropdownButtonFormField<String>(
          initialValue: _status,
          isDense: true,
          decoration: const InputDecoration(
            labelText: 'Статус',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          items: [
            const DropdownMenuItem<String>(
                value: null, child: Text('не указан')),
            ..._statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))),
          ],
          onChanged: (v) => setState(() => _status = v),
        ),
      );

  Widget _field(
    TextEditingController controller,
    String label, {
    String? hint,
    int maxLines = 1,
    bool number = false,
    TextInputType? keyboard,
    String? Function(String?)? validator,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: number
              ? const TextInputType.numberWithOptions(decimal: true)
              : keyboard,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            isDense: true,
            border: const OutlineInputBorder(),
          ),
          validator: validator ??
              (number
                  ? (v) {
                      final s = v?.trim() ?? '';
                      if (s.isEmpty) return null;
                      return double.tryParse(s.replaceAll(',', '.')) == null
                          ? 'Нужно число'
                          : null;
                    }
                  : null),
        ),
      );
}
