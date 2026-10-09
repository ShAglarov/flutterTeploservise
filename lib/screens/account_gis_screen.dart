import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/location_models.dart';
import '../models/permission_key.dart';
import '../services/location_service.dart';
import 'account_details_screen.dart';
import '../services/permission_service.dart';
import '../utils/app_theme.dart';

/// Правка полей ГИС ЖКХ у лицевого счёта.
///
/// Отдельный экран, а не часть общей карточки: поля нужны только перед
/// выгрузкой в портал, а лицевые счета в приложении приходят из импорта
/// XLS и обычно не редактируются вручную.
class AccountGisScreen extends ConsumerStatefulWidget {
  final AccountResponse account;

  const AccountGisScreen({super.key, required this.account});

  @override
  ConsumerState<AccountGisScreen> createState() => _AccountGisScreenState();
}

class _AccountGisScreenState extends ConsumerState<AccountGisScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _jku;
  late final TextEditingController _els;
  late final TextEditingController _accountType;
  late final TextEditingController _lastName;
  late final TextEditingController _firstName;
  late final TextEditingController _middleName;
  late final TextEditingController _snils;
  late final TextEditingController _docType;
  late final TextEditingController _docNumber;
  late final TextEditingController _docSeries;
  late final TextEditingController _docDate;
  late final TextEditingController _ogrn;
  late final TextEditingController _nza;
  late final TextEditingController _kpp;
  late final TextEditingController _area;
  late final TextEditingController _livingArea;
  late final TextEditingController _heatedArea;
  late final TextEditingController _residents;
  late final TextEditingController _premisesType;
  late final TextEditingController _premisesNumber;
  late final TextEditingController _roomNumber;
  late final TextEditingController _paymentShare;
  // Лист «Доп критерии поиска в ЕГРП» шаблона МКД.
  late final TextEditingController _egrpConditional;
  late final TextEditingController _egrpRegNumber;
  late final TextEditingController _egrpRegDate;

  bool? _isTenant;
  bool? _isSplit;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final a = widget.account;
    _jku = TextEditingController(text: a.jkuIdentifier ?? '');
    _els = TextEditingController(text: a.gisEls ?? '');
    _accountType = TextEditingController(text: a.gisAccountType ?? '');
    // ФИО: если разобранных полей ГИС нет, предзаполняем из общего fio —
    // оператору останется проверить разбивку, а не вводить заново.
    final parts = (a.fio ?? '').trim().split(RegExp(r'\s+'));
    _lastName = TextEditingController(
        text: a.gisLastName ?? (parts.isNotEmpty ? parts[0] : ''));
    _firstName = TextEditingController(
        text: a.gisFirstName ?? (parts.length > 1 ? parts[1] : ''));
    _middleName = TextEditingController(
        text: a.gisMiddleName ?? (parts.length > 2 ? parts.sublist(2).join(' ') : ''));
    _snils = TextEditingController(text: a.gisSnils ?? '');
    _docType = TextEditingController(text: a.gisDocType ?? '');
    _docNumber = TextEditingController(text: a.gisDocNumber ?? '');
    _docSeries = TextEditingController(text: a.gisDocSeries ?? '');
    _docDate = TextEditingController(text: a.gisDocDate ?? '');
    _ogrn = TextEditingController(text: a.gisOgrn ?? '');
    _nza = TextEditingController(text: a.gisNza ?? '');
    _kpp = TextEditingController(text: a.gisKpp ?? '');
    _area = TextEditingController(text: a.area?.toString() ?? '');
    _livingArea = TextEditingController(text: a.livingArea?.toString() ?? '');
    _heatedArea = TextEditingController(text: a.heatedArea?.toString() ?? '');
    _residents = TextEditingController(text: a.residentsCount?.toString() ?? '');
    _premisesType = TextEditingController(text: a.gisPremisesType ?? '');
    _premisesNumber = TextEditingController(text: a.gisPremisesNumber ?? '');
    _roomNumber = TextEditingController(text: a.gisRoomNumber ?? '');
    _paymentShare = TextEditingController(text: a.gisPaymentShare?.toString() ?? '');
    _egrpConditional =
        TextEditingController(text: a.gisEgrpConditionalNumber ?? '');
    _egrpRegNumber =
        TextEditingController(text: a.gisEgrpRegistrationNumber ?? '');
    _egrpRegDate =
        TextEditingController(text: a.gisEgrpRegistrationDate ?? '');
    _isTenant = a.gisIsTenant;
    _isSplit = a.gisIsSplit;
  }

  @override
  void dispose() {
    for (final c in [
      _jku, _els, _accountType, _lastName, _firstName, _middleName, _snils,
      _docType, _docNumber, _docSeries, _docDate, _ogrn, _nza, _kpp,
      _area, _livingArea, _heatedArea, _residents,
      _premisesType, _premisesNumber, _roomNumber, _paymentShare,
      _egrpConditional, _egrpRegNumber, _egrpRegDate,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _t(TextEditingController c) =>
      c.text.trim().isEmpty ? null : c.text.trim();

  double? _d(TextEditingController c) =>
      c.text.trim().isEmpty ? null : double.tryParse(c.text.trim().replaceAll(',', '.'));

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      // AccountUpdate сериализуется с includeIfNull: false, поэтому
      // незаполненные поля вообще не уедут и ничего не затрут.
      final update = AccountUpdate(
        jkuIdentifier: _t(_jku),
        gisEls: _t(_els),
        gisAccountType: _t(_accountType),
        gisIsTenant: _isTenant,
        gisIsSplit: _isSplit,
        gisLastName: _t(_lastName),
        gisFirstName: _t(_firstName),
        gisMiddleName: _t(_middleName),
        gisSnils: _t(_snils),
        gisDocType: _t(_docType),
        gisDocNumber: _t(_docNumber),
        gisDocSeries: _t(_docSeries),
        gisDocDate: _t(_docDate),
        gisOgrn: _t(_ogrn),
        gisNza: _t(_nza),
        gisKpp: _t(_kpp),
        area: _d(_area),
        livingArea: _d(_livingArea),
        heatedArea: _d(_heatedArea),
        residentsCount: _residents.text.trim().isEmpty
            ? null
            : int.tryParse(_residents.text.trim()),
        gisPremisesType: _t(_premisesType),
        gisPremisesNumber: _t(_premisesNumber),
        gisRoomNumber: _t(_roomNumber),
        gisPaymentShare: _d(_paymentShare),
        gisEgrpConditionalNumber: _t(_egrpConditional),
        gisEgrpRegistrationNumber: _t(_egrpRegNumber),
        gisEgrpRegistrationDate: _t(_egrpRegDate),
      );

      await ref.read(locationServiceProvider).updateAccount(widget.account.id, update);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Данные ГИС сохранены'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_errorText(e)), backgroundColor: AppTheme.errorRed),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _errorText(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      final detail = data is Map ? data['detail']?.toString() : null;
      if (detail != null && detail.startsWith('permission_denied')) {
        return 'Нет прав на изменение лицевых счетов';
      }
      return detail ?? e.message ?? 'Ошибка сети';
    }
    return e.toString();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final canEdit =
        ref.watch(permissionStateProvider).hasPermission(PermissionKey.accountUpdate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Данные ГИС ЖКХ'),
        actions: [
          if (_saving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Center(
                child: SizedBox(
                    width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            )
          else if (canEdit)
            TextButton(onPressed: _save, child: const Text('Сохранить')),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ЛС ${widget.account.accountNumber}',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  if (widget.account.fio != null)
                    Text(widget.account.fio!,
                        style: TextStyle(
                            fontSize: 12, color: cs.onSurface.withAlpha(165))),
                  if (widget.account.address != null)
                    Text(widget.account.address!,
                        style: TextStyle(
                            fontSize: 12, color: cs.onSurface.withAlpha(140))),
                  if (widget.account.gisStatus != null) ...[
                    const SizedBox(height: 6),
                    Text('Статус в ГИС: ${widget.account.gisStatus}',
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.primaryBlue)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            _header('Идентификаторы'),
            _field(_jku, 'Идентификатор ЖКУ', hint: '80РС558347-01'),
            _field(_els, 'Единый лицевой счет (ЕЛС)', hint: '1234567890'),
            _field(_accountType, 'Тип лицевого счета', hint: 'Лицевой счет'),
            _tristate('Является нанимателем', _isTenant,
                (v) => setState(() => _isTenant = v)),
            _tristate('ЛС на помещение разделены', _isSplit,
                (v) => setState(() => _isSplit = v)),

            const SizedBox(height: 12),
            _header('Потребитель'),
            _field(_lastName, 'Фамилия'),
            _field(_firstName, 'Имя'),
            _field(_middleName, 'Отчество'),
            _field(_snils, 'СНИЛС', hint: '123-456-789 00'),

            const SizedBox(height: 12),
            _header('Документ, удостоверяющий личность'),
            _field(_docType, 'Вид документа', hint: 'Паспорт гражданина РФ'),
            _field(_docSeries, 'Серия'),
            _field(_docNumber, 'Номер'),
            _field(_docDate, 'Дата выдачи', hint: '31.12.2020'),

            const SizedBox(height: 12),
            _header('Для юридических лиц'),
            _field(_ogrn, 'ОГРН/ОГРНИП'),
            _field(_nza, 'НЗА (для ФПИЮЛ)'),
            _field(_kpp, 'КПП (для ОП)'),

            const SizedBox(height: 12),
            _header('Площади и проживающие'),
            _field(_area, 'Общая площадь, кв. м', number: true),
            _field(_livingArea, 'Жилая площадь, кв. м', number: true),
            _field(_heatedArea, 'Отапливаемая площадь, кв. м', number: true),
            _field(_residents, 'Количество проживающих', number: true),

            const SizedBox(height: 12),
            _header('Помещение'),
            _field(_premisesType, 'Тип помещения/блок', hint: 'Жилое'),
            _field(_premisesNumber, 'Номер помещения/блока', hint: '1'),
            _field(_roomNumber, 'Номер комнаты'),
            _field(_paymentShare, 'Доля внесения платы, %',
                hint: '100', number: true),

            const SizedBox(height: 12),
            _header('Привязка к ЕГРП'),
            // Заполняется, когда привязать помещение по кадастровому
            // номеру не удалось — лист «Доп критерии поиска в ЕГРП».
            _field(_egrpConditional, 'Условный номер ЕГРП'),
            _field(_egrpRegNumber, 'Номер гос. регистрации права'),
            _field(_egrpRegDate, 'Дата гос. регистрации права',
                hint: 'ГГГГ-ММ-ДД'),

            const SizedBox(height: 12),
            _header('Комнаты и основания'),
            // Отдельный экран: комнат и договоров у счёта может быть
            // несколько, в поля карточки они не укладываются.
            Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(Icons.meeting_room, color: Colors.teal),
                title: const Text('Комнаты, основания, параметры'),
                subtitle: const Text(
                    'листы «Комнаты», «Основания», «Информация о помещениях»'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => AccountDetailsScreen(
                    accountId: widget.account.id,
                    accountTitle: 'ЛС ${widget.account.accountNumber}',
                    premisesType: _premisesType.text.trim().isEmpty
                        ? null
                        : _premisesType.text.trim(),
                  ),
                )),
              ),
            ),

            const SizedBox(height: 24),
            if (canEdit)
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: const Text('Сохранить'),
                ),
              )
            else
              Text('Нет прав на изменение лицевых счетов',
                  style: TextStyle(fontSize: 12, color: cs.onSurface.withAlpha(150))),
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
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: Theme.of(context).colorScheme.onSurface.withAlpha(140),
          ),
        ),
      );

  Widget _field(
    TextEditingController controller,
    String label, {
    String? hint,
    bool number = false,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          controller: controller,
          keyboardType: number
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            isDense: true,
            border: const OutlineInputBorder(),
          ),
          validator: number
              ? (v) {
                  final s = v?.trim() ?? '';
                  if (s.isEmpty) return null;
                  return double.tryParse(s.replaceAll(',', '.')) == null
                      ? 'Нужно число'
                      : null;
                }
              : null,
        ),
      );

  Widget _tristate(String label, bool? value, ValueChanged<bool?> onChanged) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
            SegmentedButton<String>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: 'null', label: Text('—')),
                ButtonSegment(value: 'yes', label: Text('Да')),
                ButtonSegment(value: 'no', label: Text('Нет')),
              ],
              selected: {value == null ? 'null' : (value ? 'yes' : 'no')},
              onSelectionChanged: (s) {
                final v = s.first;
                onChanged(v == 'null' ? null : v == 'yes');
              },
            ),
          ],
        ),
      );
}
