import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/location_models.dart';
import '../models/permission_key.dart';
import '../services/location_service.dart';
import '../services/permission_service.dart';
import '../utils/app_theme.dart';
import '../utils/gis_dictionaries.dart';
import 'account_details_screen.dart';
import 'account_gis_screen.dart';

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
      _premisesNumber,
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
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: [
            if (widget.locationName != null) _buildHouseBadge(cs),

            // ─── Основное ───
            _header('Основное'),
            _card([
              _field(_number, 'Номер лицевого счёта',
                  icon: Icons.pin, iconColor: Colors.blue,
                  hint: '00102900170',
                  required: true,
                  help: 'Уникален внутри организации',
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Укажите номер счёта'
                      : null),
              _divider(),
              _field(_fio, 'ФИО владельца',
                  icon: Icons.person_outline, iconColor: Colors.indigo,
                  hint: 'Иванова Мария Петровна'),
              _divider(),
              _field(_address, 'Адрес помещения',
                  icon: Icons.place_outlined, iconColor: Colors.red,
                  hint: 'ул. Ленина, д. 27, кв. 1', maxLines: 2,
                  help: 'Если указать «кв. N», номер помещения '
                      'подставится в выгрузку ГИС автоматически'),
              _divider(),
              _buildStatusRow(cs),
              _divider(),
              _buildServiceRow(cs),
            ]),

            // ─── Контакты ───
            _header('Контакты'),
            _card([
              _field(_phone, 'Телефон',
                  icon: Icons.phone_outlined, iconColor: Colors.green,
                  hint: '+7 999 123-45-67', keyboard: TextInputType.phone),
              _divider(),
              _field(_email, 'Email',
                  icon: Icons.alternate_email, iconColor: Colors.teal,
                  hint: 'mail@example.ru',
                  keyboard: TextInputType.emailAddress,
                  validator: (v) {
                    final s = v?.trim() ?? '';
                    if (s.isEmpty) return null;
                    return (s.contains('@') && s.contains('.'))
                        ? null
                        : 'Некорректный email';
                  }),
            ]),

            // ─── Площади ───
            _header('Площади и проживающие'),
            _card([
              _field(_area, 'Общая площадь',
                  icon: Icons.square_foot, iconColor: Colors.blue,
                  suffix: 'м²', number: true),
              _divider(),
              _field(_rooms, 'Комнат',
                  icon: Icons.meeting_room_outlined, iconColor: Colors.orange,
                  number: true),
              // Жилая и отапливаемая площадь, проживающие есть только в
              // AccountUpdate: при создании сервер их не принимает.
              if (_isEditing) ...[
                _divider(),
                _field(_livingArea, 'Жилая площадь',
                    icon: Icons.bed_outlined, iconColor: Colors.purple,
                    suffix: 'м²', number: true),
                _divider(),
                _field(_heatedArea, 'Отапливаемая площадь',
                    icon: Icons.thermostat, iconColor: Colors.deepOrange,
                    suffix: 'м²', number: true),
                _divider(),
                _field(_residents, 'Проживающих',
                    icon: Icons.people_outline, iconColor: Colors.brown,
                    number: true),
              ],
            ]),
            if (!_isEditing)
              _hint('Жилую и отапливаемую площадь, количество проживающих '
                  'можно будет заполнить сразу после создания счёта.'),

            // ─── ГИС ЖКХ ───
            _header('Данные для ГИС ЖКХ',
                filled: _gisFilledCount, total: _gisTotalCount),
            _card([
              _buildPickerRow(
                Icons.badge_outlined, Colors.deepPurple,
                'Тип лицевого счёта', _accountType, gisAccountTypes,
                (v) => setState(() => _accountType = v),
                help: 'Для управляющей организации — «ЛС УО»',
              ),
              _divider(),
              _buildPickerRow(
                Icons.door_front_door_outlined, Colors.brown,
                'Тип помещения', _premisesType, gisPremisesTypes,
                (v) => setState(() => _premisesType = v),
              ),
              _divider(),
              _field(_premisesNumber, 'Номер помещения',
                  icon: Icons.tag, iconColor: Colors.cyan, hint: '12',
                  help: 'По нему портал связывает счёт с квартирой'),
              if (_isEditing) ...[
                _divider(),
                _buildPickerRow(
                  Icons.description_outlined, Colors.blueGrey,
                  'Вид документа', _docType, gisDocumentTypes,
                  (v) => setState(() => _docType = v),
                ),
              ],
            ]),

            // ─── Идентификаторы ───
            _header('Идентификаторы'),
            _card([
              _field(_jku, 'Идентификатор ЖКУ',
                  icon: Icons.qr_code_2, iconColor: Colors.purple,
                  hint: '80РС558347-01',
                  help: 'Присваивает портал ГИС. Можно оставить пустым'),
              if (_isEditing) ...[
                _divider(),
                _field(_els, 'Единый лицевой счёт (ЕЛС)',
                    icon: Icons.account_balance_outlined,
                    iconColor: Colors.indigo),
              ],
              _divider(),
              _field(_cadastral, 'Кадастровый номер',
                  icon: Icons.map_outlined, iconColor: Colors.green,
                  hint: '05:40:000123:456',
                  help: 'Помещения, а не дома'),
            ]),

            // ─── Переходы на отдельные экраны ───
            if (_isEditing) ...[
              _header('Ещё сведения'),
              _card([
                _buildLinkRow(
                  Icons.account_balance,
                  Colors.deepPurple,
                  'Все поля ГИС ЖКХ',
                  'СНИЛС, документ, доля, привязка к ЕГРП',
                  _openGis,
                ),
                _divider(),
                _buildLinkRow(
                  Icons.meeting_room,
                  Colors.teal,
                  'Комнаты и основания',
                  'комнаты коммуналки, договоры найма и ТКО',
                  _openDetails,
                ),
              ]),
            ] else
              _hint('Комнаты, основания договоров и остальные поля ГИС ЖКХ '
                  'станут доступны после создания счёта.'),

            const SizedBox(height: 22),
            if (canSave)
              SizedBox(
                height: 50,
                child: FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: Icon(_isEditing ? Icons.check : Icons.add),
                  label: Text(_isEditing ? 'Сохранить' : 'Создать счёт'),
                ),
              )
            else
              _hint(_isEditing
                  ? 'Нет права на изменение лицевых счетов'
                  : 'Нет права на создание лицевых счетов'),
          ],
        ),
      ),
    );
  }

  /// Плашка с домом: оператор должен видеть, куда попадёт счёт.
  Widget _buildHouseBadge(ColorScheme cs) => Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: cs.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.home_outlined, size: 18, color: cs.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Дом',
                      style: TextStyle(
                          fontSize: 11, color: cs.onSurface.withAlpha(150))),
                  Text(widget.locationName!,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      );

  /// Статус счёта.
  ///
  /// Списком, а не сегментами: «Приостановлен» в три сегмента по
  /// ширине телефона не влезает, а обрезать название статуса нельзя.
  /// Текущее значение подсвечено цветом — видно без чтения.
  Widget _buildStatusRow(ColorScheme cs) {
    final color = switch (_status) {
      'Активный' => Colors.green,
      'Закрыт' => Colors.red,
      'Приостановлен' => Colors.orange,
      _ => Colors.grey,
    };
    return InkWell(
      onTap: () async {
        final picked = await _pickOne(
          title: 'Статус счёта',
          current: _status ?? '',
          emptyLabel: 'Не указан',
          options: [for (final s in _statuses) _Option(s, s)],
        );
        if (picked != null) {
          setState(() => _status = picked.isEmpty ? null : picked);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(
          children: [
            _iconChip(Icons.toggle_on_outlined, Colors.amber),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Статус',
                  style: TextStyle(fontSize: 15, color: cs.onSurface)),
            ),
            if (_status != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(_status!,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: color)),
              )
            else
              Text('Не указан',
                  style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: cs.onSurface.withAlpha(105))),
            const SizedBox(width: 4),
            Icon(Icons.unfold_more,
                size: 17, color: cs.onSurface.withAlpha(100)),
          ],
        ),
      ),
    );
  }

  /// Тип услуги — выбором из списка услуг приложения.
  ///
  /// Было свободное поле: оператор писал «отопление», «Отопл.», и
  /// значения не сходились между счетами.
  Widget _buildServiceRow(ColorScheme cs) {
    final current = _serviceType.text.trim();
    return _buildValueRow(
      Icons.local_fire_department_outlined,
      Colors.deepOrange,
      'Тип услуги',
      current.isEmpty ? 'Не указан' : current,
      isEmpty: current.isEmpty,
      onTap: () async {
        final picked = await _pickOne(
          title: 'Тип услуги',
          current: current,
          emptyLabel: 'Не указан',
          options: _serviceOptions,
        );
        if (picked != null) {
          setState(() => _serviceType.text = picked);
        }
      },
    );
  }

  void _openGis() {
    final model = widget.account;
    if (model == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AccountGisScreen(account: model)),
    );
  }

  void _openDetails() {
    final model = widget.account;
    if (model == null) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => AccountDetailsScreen(
        accountId: model.id,
        accountTitle: 'ЛС ${model.accountNumber}',
        premisesType: _premisesType,
      ),
    ));
  }

  /// Услуги приложения. Коды те же, что в начислениях и отчётах.
  static const _serviceOptions = <_Option>[
    _Option('Отопление', 'Отопление'),
    _Option('Горячая вода', 'Горячая вода'),
    _Option('Техобслуживание', 'Техобслуживание'),
    _Option('ТБО', 'ТБО'),
    _Option('ОДН Электричество', 'ОДН Электричество'),
    _Option('ОДН Вода', 'ОДН Вода'),
  ];

  int get _gisTotalCount => _isEditing ? 4 : 3;

  /// Сколько полей секции ГИС заполнено — для счётчика в заголовке.
  int get _gisFilledCount {
    var filled = 0;
    if (_accountType != null) filled++;
    if (_premisesType != null) filled++;
    if (_premisesNumber.text.trim().isNotEmpty) filled++;
    if (_isEditing && _docType != null) filled++;
    return filled;
  }

  Widget _header(String text, {int? filled, int? total}) {
    final cs = Theme.of(context).colorScheme;
    final showCounter = filled != null && total != null && total > 0;
    final complete = showCounter && filled == total;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 18, 4, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text.toUpperCase(),
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
                color: cs.onSurface.withAlpha(140),
              ),
            ),
          ),
          if (showCounter)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: complete
                    ? Colors.green.withValues(alpha: 0.15)
                    : cs.onSurface.withAlpha(18),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                complete ? '✓ заполнено' : 'заполнено $filled из $total',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: complete
                      ? Colors.green.shade700
                      : cs.onSurface.withAlpha(150),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Секция-карточка: группирует поля, как в карточке дома.
  Widget _card(List<Widget> children) => Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurface.withAlpha(10),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(children: children),
      );

  Widget _divider() => Divider(
        height: 1,
        thickness: 1,
        indent: 52,
        color: Theme.of(context).colorScheme.onSurface.withAlpha(15),
      );

  Widget _hint(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(6, 8, 6, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline,
                size: 14,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(130)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 11.5,
                  height: 1.35,
                  color:
                      Theme.of(context).colorScheme.onSurface.withAlpha(150),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _iconChip(IconData icon, Color color) => Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 17, color: color),
      );

  /// Строка «название — значение», которое выбирают нажатием.
  ///
  /// Цвет значения — из темы. В карточке дома такой же код был прибит
  /// к `Colors.white`, и на светлой теме значения были не видны;
  /// повторять эту ошибку здесь нельзя.
  Widget _buildValueRow(
    IconData icon,
    Color iconColor,
    String label,
    String value, {
    required VoidCallback onTap,
    bool isEmpty = false,
    String? help,
  }) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(
          children: [
            _iconChip(icon, iconColor),
            const SizedBox(width: 12),
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label,
                      style: TextStyle(fontSize: 15, color: cs.onSurface)),
                  if (help != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(help,
                          style: TextStyle(
                              fontSize: 10.5,
                              color: cs.onSurface.withAlpha(130))),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: Text(
                value,
                textAlign: TextAlign.right,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: isEmpty ? cs.onSurface.withAlpha(105) : cs.onSurface,
                  fontWeight: isEmpty ? FontWeight.normal : FontWeight.w500,
                  fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ),
            Icon(Icons.unfold_more,
                size: 17, color: cs.onSurface.withAlpha(100)),
          ],
        ),
      ),
    );
  }

  /// Выбор значения ГИС из справочника.
  Widget _buildPickerRow(
    IconData icon,
    Color iconColor,
    String label,
    String? value,
    List<String> options,
    ValueChanged<String?> onChanged, {
    String? help,
  }) =>
      _buildValueRow(
        icon,
        iconColor,
        label,
        value ?? 'Не указан',
        isEmpty: value == null,
        help: help,
        onTap: () async {
          final picked = await _pickOne(
            title: label,
            current: value ?? '',
            emptyLabel: 'Не указан',
            options: [for (final o in options) _Option(o, o)],
          );
          if (picked != null) onChanged(picked.isEmpty ? null : picked);
        },
      );

  /// Переход на отдельный экран.
  Widget _buildLinkRow(
    IconData icon,
    Color iconColor,
    String label,
    String description,
    VoidCallback onTap,
  ) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            _iconChip(icon, iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label,
                      style: TextStyle(fontSize: 15, color: cs.onSurface)),
                  const SizedBox(height: 2),
                  Text(description,
                      style: TextStyle(
                          fontSize: 11.5,
                          color: cs.onSurface.withAlpha(130))),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                size: 13, color: cs.onSurface.withAlpha(100)),
          ],
        ),
      ),
    );
  }

  /// Выбор одного значения листом снизу, с отметкой текущего.
  ///
  /// Вместо DropdownButtonFormField: у «Вида документа» 21 значение,
  /// и в выпадающем списке они не читались — текст был 12.5 пункта и
  /// обрезался по ширине строки.
  Future<String?> _pickOne({
    required String title,
    required String current,
    required List<_Option> options,
    String emptyLabel = 'Не указано',
  }) {
    final cs = Theme.of(context).colorScheme;
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: options.length > 6 ? 0.7 : 0.45,
        maxChildSize: 0.9,
        builder: (_, controller) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w600)),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                controller: controller,
                children: [
                  ListTile(
                    leading: Icon(
                      current.isEmpty
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: current.isEmpty ? cs.primary : null,
                    ),
                    title: Text(emptyLabel,
                        style: const TextStyle(fontStyle: FontStyle.italic)),
                    onTap: () => Navigator.pop(ctx, ''),
                  ),
                  const Divider(height: 1),
                  for (final option in options)
                    ListTile(
                      leading: Icon(
                        option.value == current
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: option.value == current ? cs.primary : null,
                      ),
                      title: Text(option.label),
                      onTap: () => Navigator.pop(ctx, option.value),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  /// Поле ввода строкой: иконка, название, значение справа.
  ///
  /// Единый вид с полями выбора. Раньше часть полей была рамками
  /// `OutlineInputBorder`, часть — выпадающими списками с текстом 12.5
  /// пункта, и экран выглядел набором разнородных элементов.
  Widget _field(
    TextEditingController controller,
    String label, {
    required IconData icon,
    required Color iconColor,
    String? hint,
    String? help,
    String? suffix,
    int maxLines = 1,
    bool number = false,
    bool required = false,
    TextInputType? keyboard,
    String? Function(String?)? validator,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: _iconChip(icon, iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(label,
                            style:
                                TextStyle(fontSize: 15, color: cs.onSurface)),
                      ),
                      // Обязательное поле — звёздочкой цветом ошибки:
                      // так заметнее, чем «*» внутри названия.
                      if (required)
                        Text(' *',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: cs.error)),
                    ],
                  ),
                  if (help != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2, bottom: 2),
                      child: Text(help,
                          style: TextStyle(
                              fontSize: 10.5,
                              height: 1.3,
                              color: cs.onSurface.withAlpha(130))),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: TextFormField(
              controller: controller,
              maxLines: maxLines,
              textAlign: TextAlign.right,
              keyboardType: number
                  ? const TextInputType.numberWithOptions(decimal: true)
                  : keyboard,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: cs.onSurface),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                    fontSize: 13, color: cs.onSurface.withAlpha(90)),
                suffixText: suffix,
                suffixStyle: TextStyle(
                    fontSize: 13, color: cs.onSurface.withAlpha(140)),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: InputBorder.none,
                errorStyle: const TextStyle(fontSize: 10.5, height: 1.1),
              ),
              onChanged: (_) {
                // Счётчик «заполнено N из M» должен меняться сразу.
                if (controller == _premisesNumber) setState(() {});
              },
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
          ),
        ],
      ),
    );
  }
}

/// Вариант выбора: что уйдёт в базу и что видит оператор.
class _Option {
  final String value;
  final String label;

  const _Option(this.value, this.label);
}
