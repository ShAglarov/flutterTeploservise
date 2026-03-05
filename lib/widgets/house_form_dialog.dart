import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../models/location_models.dart';
import '../models/user_role.dart';
import '../services/location_service.dart';
import '../services/user_service.dart';
import '../utils/app_theme.dart';
import 'house_selection_dialog.dart';
import 'management_company_selection_dialog.dart';

class HouseFormDialog extends ConsumerStatefulWidget {
  final LatLng position;
  final int boilerHouseId;
  final SavedLocationResponse? initialLocation;

  const HouseFormDialog({
    super.key,
    required this.position,
    required this.boilerHouseId,
    this.initialLocation,
  });

  @override
  ConsumerState<HouseFormDialog> createState() => _HouseFormDialogState();
}

class _HouseFormDialogState extends ConsumerState<HouseFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _floorsController;
  late final TextEditingController _residentsController;
  late final TextEditingController _areaController;
  late final TextEditingController _yearController;
  late final TextEditingController _roomsController;
  late final TextEditingController _latController;
  late final TextEditingController _lngController;
  late final TextEditingController _fiasHouseController;
  late final TextEditingController _fiasAOController;
  
  bool _providesHeating = false;
  bool _providesHotWater = false;
  bool _isSaving = false;
  String? _selectedSiteManager;
  String? _selectedManagementCompanyId;
  String? _selectedManagementCompanyName;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialLocation;
    _nameController = TextEditingController(text: initial?.name ?? '');
    _floorsController = TextEditingController(text: initial?.floors?.toString() ?? '');
    _residentsController = TextEditingController(text: initial?.residentsCount?.toString() ?? '');
    _areaController = TextEditingController(text: initial?.totalArea?.toString() ?? '');
    _yearController = TextEditingController(text: initial?.yearBuilt?.toString() ?? '');
    _roomsController = TextEditingController(text: initial?.rooms?.toString() ?? '');
    _latController = TextEditingController(text: initial != null ? initial.latitude.toStringAsFixed(12) : widget.position.latitude.toStringAsFixed(12));
    _lngController = TextEditingController(text: initial != null ? initial.longitude.toStringAsFixed(12) : widget.position.longitude.toStringAsFixed(12));
    _fiasHouseController = TextEditingController(text: initial?.fiasHouseGuid ?? '');
    _fiasAOController = TextEditingController(text: initial?.fiasAOGuid ?? '');
    _providesHeating = initial?.providesHeating ?? false;
    _providesHotWater = initial?.providesHotWater ?? false;
    _selectedManagementCompanyId = initial?.managementCompanyId;
    _selectedManagementCompanyName = initial?.managementCompanyName;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _floorsController.dispose();
    _residentsController.dispose();
    _areaController.dispose();
    _yearController.dispose();
    _roomsController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _fiasHouseController.dispose();
    _fiasAOController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final isEditing = widget.initialLocation != null;
      dynamic result;

      if (isEditing) {
        final update = SavedLocationUpdate(
          name: _nameController.text,
          latitude: double.parse(_latController.text),
          longitude: double.parse(_lngController.text),
          boilerHouseId: widget.boilerHouseId,
          floors: int.tryParse(_floorsController.text),
          residentsCount: int.tryParse(_residentsController.text),
          totalArea: double.tryParse(_areaController.text),
          yearBuilt: int.tryParse(_yearController.text),
          rooms: int.tryParse(_roomsController.text),
          providesHeating: _providesHeating,
          providesHotWater: _providesHotWater,
          fiasHouseGuid: _fiasHouseController.text.isNotEmpty ? _fiasHouseController.text : null,
          fiasAOGuid: _fiasAOController.text.isNotEmpty ? _fiasAOController.text : null,
          managementCompanyId: _selectedManagementCompanyId,
        );
        result = await ref.read(locationServiceProvider).updateSavedLocation(widget.initialLocation!.id, update);
      } else {
        final location = SavedLocationCreate(
          name: _nameController.text,
          latitude: double.parse(_latController.text),
          longitude: double.parse(_lngController.text),
          boilerHouseId: widget.boilerHouseId,
          floors: int.tryParse(_floorsController.text),
          residentsCount: int.tryParse(_residentsController.text),
          totalArea: double.tryParse(_areaController.text),
          yearBuilt: int.tryParse(_yearController.text),
          rooms: int.tryParse(_roomsController.text),
          providesHeating: _providesHeating,
          providesHotWater: _providesHotWater,
          fiasHouseGuid: _fiasHouseController.text.isNotEmpty ? _fiasHouseController.text : null,
          fiasAOGuid: _fiasAOController.text.isNotEmpty ? _fiasAOController.text : null,
          managementCompanyId: _selectedManagementCompanyId,
        );
        result = await ref.read(locationServiceProvider).createSavedLocation(location);
      }
      
      if (mounted) {
        Navigator.of(context).pop(result);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка сохранения: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _selectManagementCompany() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const ManagementCompanySelectionDialog(),
    );

    if (result != null) {
      setState(() {
        _selectedManagementCompanyId = result['id'];
        _selectedManagementCompanyName = result['name'];
      });
    }
  }

  Future<void> _selectFromDatabase() async {
    final result = await showDialog<SavedLocationResponse>(
      context: context,
      builder: (context) => const HouseSelectionDialog(),
    );

    if (result != null) {
      setState(() {
        _nameController.text = result.name;
        _areaController.text = result.totalArea?.toString() ?? '';
        _floorsController.text = result.floors?.toString() ?? '';
        _yearController.text = result.yearBuilt?.toString() ?? '';
        _roomsController.text = result.rooms?.toString() ?? '';
        _residentsController.text = result.residentsCount?.toString() ?? '';
        _latController.text = result.latitude.toString();
        _lngController.text = result.longitude.toString();
        _fiasHouseController.text = result.fiasHouseGuid ?? '';
        _fiasAOController.text = result.fiasAOGuid ?? '';
        _providesHeating = result.providesHeating ?? false;
        _providesHotWater = result.providesHotWater ?? false;
        _selectedManagementCompanyId = result.managementCompanyId;
        _selectedManagementCompanyName = result.managementCompanyName;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        width: 500,
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeader('Источник'),
                      _buildSection([
                        _buildActionRow(
                          Icons.copy, 
                          Colors.blue, 
                          'Копировать из...', 
                          'Выбрать',
                          onTap: _selectFromDatabase,
                        ),
                      ]),
                      
                      _SectionHeader('Основная информация'),
                      _buildSection([
                        _buildInputRow(Icons.apartment, Colors.blue, 'Название', _nameController, hint: 'Дом №1'),
                      ]),
                      
                      _SectionHeader('Характеристики'),
                      _buildSection([
                        _buildInputRow(Icons.square_foot, Colors.blue, 'Площадь, м²', _areaController, hint: '150.0', keyboardType: TextInputType.number),
                        _buildDivider(),
                        _buildInputRow(Icons.layers, Colors.grey, 'Этажей', _floorsController, hint: '5', keyboardType: TextInputType.number),
                        _buildDivider(),
                        _buildInputRow(Icons.calendar_month, Colors.teal, 'Год постройки', _yearController, hint: '2020', keyboardType: TextInputType.number),
                        _buildDivider(),
                        _buildInputRow(Icons.door_front_door, Colors.orange, 'Помещений', _roomsController, hint: '10', keyboardType: TextInputType.number),
                        _buildDivider(),
                        _buildInputRow(Icons.people, Colors.orange, 'Жильцов', _residentsController, hint: '4', keyboardType: TextInputType.number),
                      ]),
                      
                      _SectionHeader('Координаты'),
                      _buildSection([
                        _buildInputRow(Icons.navigation, Colors.red, 'Широта', _latController, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                        _buildDivider(),
                        _buildInputRow(Icons.navigation, Colors.red, 'Долгота', _lngController, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                      ]),
                      
                      _SectionHeader('ФИАС'),
                      _buildSection([
                        _buildInputRow(Icons.description, Colors.purple, 'Дом', _fiasHouseController, hint: 'a0b1c2d3...'),
                        _buildDivider(),
                        _buildInputRow(Icons.description, Colors.blue, 'Адресообразующий объект', _fiasAOController, hint: 'e4f5g6h7...'),
                      ]),
                      
                       _SectionHeader('Управление и связи'),
                      _buildSection([
                        _buildActionRow(
                          Icons.business_center, 
                          Colors.green, 
                          'УК / УО', 
                          _selectedManagementCompanyName ?? 'Не выбрано',
                          onTap: _selectManagementCompany,
                        ),
                        _buildDivider(),
                        _buildActionRow(Icons.numbers, Colors.grey, 'Номер участка', ''),
                        _buildDivider(),
                        _buildManagerDropdown(),
                        _buildDivider(),
                        _buildActionRow(Icons.group_work, Colors.blue, 'Лицевые счета', ''),
                      ]),
                      
                      _SectionHeader('Услуги'),
                      _buildSection([
                        _buildSwitchRow(Icons.water_drop, Colors.red, 'Поставляется ГВС', _providesHotWater, (v) => setState(() => _providesHotWater = v)),
                        _buildDivider(),
                        _buildSwitchRow(Icons.thermostat, Colors.orange, 'Поставляется отопление', _providesHeating, (v) => setState(() => _providesHeating = v)),
                      ]),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена', style: TextStyle(color: Colors.white, fontSize: 17)),
          ),
          Text(
            widget.initialLocation != null ? 'Редактировать дом' : 'Новый дом',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          _isSaving 
            ? const SizedBox(width: 80, height: 36, child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
            : ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(80, 42),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(21)),
                  elevation: 0,
                ),
                child: const Text('Сохранить', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
        ],
      ),
    );
  }

  Widget _buildSection(List<Widget> children) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInputRow(IconData icon, Color iconColor, String label, TextEditingController controller, {String? hint, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          Expanded(
            flex: 3,
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              textAlign: TextAlign.right,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(IconData icon, Color iconColor, String label, String value, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            Text(
              value,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 16),
            ),
            if (value == 'Выбрать' || value == 'Не выбрано')
              Icon(Icons.chevron_right, size: 20, color: Colors.white.withValues(alpha: 0.3)),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchRow(IconData icon, Color iconColor, String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: iconColor.withValues(alpha: 0.5),
            activeThumbColor: iconColor,
          ),
        ],
      ),
    );
  }

  Widget _buildManagerDropdown() {
    return Consumer(
      builder: (context, ref, child) {
        final usersAsync = ref.watch(usersProvider);
        return usersAsync.when(
          data: (users) {
            final managers = users.where((u) => u.role == UserRole.manager).toList();
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.person, size: 18, color: Colors.grey),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Начальник участка',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedSiteManager,
                      dropdownColor: const Color(0xFF2C2C2E),
                      icon: const SizedBox.shrink(),
                      hint: Text(
                        'Выберите',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 16),
                      ),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      onChanged: (v) => setState(() => _selectedSiteManager = v),
                      items: managers.map((u) {
                        final label = u.formattedDisplayName.split(' • ').first;
                        return DropdownMenuItem(
                          value: label,
                          child: Text(label),
                        );
                      }).toList()
                        ..addAll(
                          _selectedSiteManager != null && 
                          !managers.any((m) => m.formattedDisplayName.split(' • ').first == _selectedSiteManager)
                              ? [
                                  DropdownMenuItem<String>(
                                    value: _selectedSiteManager,
                                    child: Text(_selectedSiteManager!),
                                  )
                                ]
                              : []
                        ),
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (e, s) => const SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildDivider() {
    return Divider(color: Colors.white.withValues(alpha: 0.1), height: 1, indent: 46);
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
