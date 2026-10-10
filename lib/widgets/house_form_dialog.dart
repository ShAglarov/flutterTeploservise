import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import '../models/location_models.dart';
import '../models/user_role.dart';
import '../services/location_service.dart';
import '../services/user_service.dart';
import '../services/base_api_service.dart';
import '../utils/app_theme.dart';
import '../utils/gis_dictionaries.dart';
import '../providers/offline_edit_permission.dart';
import '../screens/gis_params_screen.dart';
import '../screens/house_structure_screen.dart';
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
  late final TextEditingController _cadastralController;
  late final TextEditingController _commissioningDateController;
  late final TextEditingController _entrancesController;
  // Нежилые помещения: в поле «Квартир» они не входят.
  late final TextEditingController _nonlivingCountController;
  late final TextEditingController _nonlivingAreaController;
  String? _stoveType;
  String? _housingType;

  // ─── ГИС ЖКХ: лист «Характеристики МКД» шаблона импорта сведений о МКД ───
  late final TextEditingController _gisOktmoController;
  late final TextEditingController _gisStateController;
  late final TextEditingController _gisLifecycleController;
  late final TextEditingController _gisUndergroundController;
  late final TextEditingController _gisTimezoneController;
  late final TextEditingController _gisHostelTypeController;
  // Трёхзначные: null — «не указано», портал отличает это от «Нет».
  bool? _gisCulturalHeritage;
  bool? _gisFederalProperty;
  bool? _gisMunicipalProperty;
  String? _gisStatus;
  
  bool _providesHeating = false;
  bool _providesHotWater = false;
  bool _isSaving = false;
  String? _selectedSiteManager;
  String? _selectedManagementCompanyId;
  String? _selectedManagementCompanyName;
  List<Map<String, dynamic>> _documents = [];
  bool _isUploadingDoc = false;

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
    _cadastralController = TextEditingController(text: initial?.cadastralNumber ?? '');
    _commissioningDateController = TextEditingController(text: initial?.commissioningDate ?? '');
    _entrancesController = TextEditingController(text: initial?.entrancesCount?.toString() ?? '');
    _nonlivingCountController =
        TextEditingController(text: initial?.nonlivingCount?.toString() ?? '');
    _nonlivingAreaController =
        TextEditingController(text: initial?.nonlivingArea?.toString() ?? '');
    _gisOktmoController = TextEditingController(text: initial?.gisOktmo ?? '');
    _gisStateController = TextEditingController(text: initial?.gisState ?? '');
    _gisLifecycleController = TextEditingController(text: initial?.gisLifecycleStage ?? '');
    _gisUndergroundController =
        TextEditingController(text: initial?.undergroundFloors?.toString() ?? '');
    _gisTimezoneController = TextEditingController(text: initial?.gisTimezone ?? '');
    _gisHostelTypeController = TextEditingController(text: initial?.gisHostelType ?? '');
    _gisCulturalHeritage = initial?.gisCulturalHeritage;
    _gisFederalProperty = initial?.gisFederalProperty;
    _gisMunicipalProperty = initial?.gisMunicipalProperty;
    _gisStatus = initial?.gisStatus;
    _stoveType = initial?.stoveType;
    _housingType = initial?.housingType;
    // Счётчик «заполнено N из M» в заголовке секции ГИС должен
    // меняться сразу при вводе. Пикеры вызывают setState сами, а поля
    // с клавиатуры — нет, поэтому слушаем их контроллеры.
    for (final controller in [_gisOktmoController, _gisUndergroundController]) {
      controller.addListener(_onGisFieldChanged);
    }
    _providesHeating = initial?.providesHeating ?? false;
    _providesHotWater = initial?.providesHotWater ?? false;
    _selectedManagementCompanyId = initial?.managementCompanyId;
    _selectedManagementCompanyName = initial?.managementCompanyName;
    if (initial != null) {
      _loadDocuments(initial.id);
    }
  }

  Future<void> _pickCommissioningDate() async {
    DateTime initialDate = DateTime.now();
    if (_commissioningDateController.text.isNotEmpty) {
      try {
        initialDate = DateTime.parse(_commissioningDateController.text);
      } catch (_) {}
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      locale: const Locale('ru'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Colors.blue,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _commissioningDateController.text = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _loadDocuments(int locationId) async {
    try {
      final dio = ref.read(dioProvider);
      final resp = await dio.get('/house-documents/by-location/$locationId');
      if (mounted) {
        setState(() {
          _documents = List<Map<String, dynamic>>.from(resp.data);
        });
      }
    } catch (_) {}
  }

  Future<void> _uploadDocument() async {
    final locationId = widget.initialLocation?.id;
    if (locationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Сначала сохраните дом, затем загрузите документ')),
      );
      return;
    }

    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png', 'xls', 'xlsx'],
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    if (file.path == null) return;

    setState(() => _isUploadingDoc = true);

    try {
      final dio = ref.read(dioProvider);
      final formData = FormData.fromMap({
        'location_id': locationId,
        'document_type': 'commissioning',
        'title': file.name,
        'file': await MultipartFile.fromFile(file.path!, filename: file.name),
      });
      await dio.post('/house-documents/upload', data: formData);
      await _loadDocuments(locationId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Документ загружен'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Ошибка загрузки: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingDoc = false);
    }
  }

  Future<void> _deleteDocument(int docId) async {
    try {
      final dio = ref.read(dioProvider);
      await dio.delete('/house-documents/$docId');
      final locId = widget.initialLocation?.id;
      if (locId != null) await _loadDocuments(locId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка удаления: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    for (final controller in [_gisOktmoController, _gisUndergroundController]) {
      controller.removeListener(_onGisFieldChanged);
    }
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
    _cadastralController.dispose();
    _gisOktmoController.dispose();
    _gisStateController.dispose();
    _gisLifecycleController.dispose();
    _gisUndergroundController.dispose();
    _gisTimezoneController.dispose();
    _gisHostelTypeController.dispose();
    _commissioningDateController.dispose();
    // _entrancesController не освобождался — утечка, видная только при
    // многократном открытии карточки. Заодно и новые поля.
    _entrancesController.dispose();
    _nonlivingCountController.dispose();
    _nonlivingAreaController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final canWrite = ref.read(writeAccessProvider);
    if (!canWrite) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Нет интернета и у вас нет прав на редактирование без сети'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

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
          cadastralNumber: _cadastralController.text.isNotEmpty ? _cadastralController.text : null,
          commissioningDate: _commissioningDateController.text.isNotEmpty ? _commissioningDateController.text : null,
          stoveType: _stoveType,
          housingType: _housingType,
          entrancesCount: int.tryParse(_entrancesController.text),
          nonlivingCount: int.tryParse(_nonlivingCountController.text),
          nonlivingArea: double.tryParse(
              _nonlivingAreaController.text.replaceAll(',', '.')),
          // ГИС ЖКХ: пустое поле отправляем как null — «не заполнено».
          gisOktmo: _textOrNull(_gisOktmoController),
          gisState: _textOrNull(_gisStateController),
          gisLifecycleStage: _textOrNull(_gisLifecycleController),
          undergroundFloors: int.tryParse(_gisUndergroundController.text),
          gisTimezone: _textOrNull(_gisTimezoneController),
          gisCulturalHeritage: _gisCulturalHeritage,
          gisFederalProperty: _gisFederalProperty,
          gisMunicipalProperty: _gisMunicipalProperty,
          gisHostelType: _textOrNull(_gisHostelTypeController),
          gisStatus: _gisStatus,
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
          cadastralNumber: _cadastralController.text.isNotEmpty ? _cadastralController.text : null,
          commissioningDate: _commissioningDateController.text.isNotEmpty ? _commissioningDateController.text : null,
          stoveType: _stoveType,
          housingType: _housingType,
          entrancesCount: int.tryParse(_entrancesController.text),
          nonlivingCount: int.tryParse(_nonlivingCountController.text),
          nonlivingArea: double.tryParse(
              _nonlivingAreaController.text.replaceAll(',', '.')),
          // ГИС ЖКХ: пустое поле отправляем как null — «не заполнено».
          gisOktmo: _textOrNull(_gisOktmoController),
          gisState: _textOrNull(_gisStateController),
          gisLifecycleStage: _textOrNull(_gisLifecycleController),
          undergroundFloors: int.tryParse(_gisUndergroundController.text),
          gisTimezone: _textOrNull(_gisTimezoneController),
          gisCulturalHeritage: _gisCulturalHeritage,
          gisFederalProperty: _gisFederalProperty,
          gisMunicipalProperty: _gisMunicipalProperty,
          gisHostelType: _textOrNull(_gisHostelTypeController),
          gisStatus: _gisStatus,
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

    if (result == null) return;

    // Диалог показывает дома, УЖЕ заведённые в организации. Если
    // скопировать всё, включая ФИАС и кадастровый номер, и сменить
    // только название, в базе окажутся ДВА дома с одним ФИАС. Для
    // портала ГИС это не два дома, а одна запись дважды.
    //
    // Выгрузка такие дубли теперь отсекает, но лучше не создавать их
    // вовсе: спрашиваем, нужна правка того же дома или новый дом с
    // похожими характеристиками.
    if (!mounted) return;
    final mode = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Что сделать с выбранным домом?'),
        content: Text(
          '«${result.name}» уже есть в базе.\n\n'
          'Если это тот же дом — откройте его карточку и измените там: '
          'иначе появится второй дом с теми же ФИАС и кадастровым '
          'номером.',
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop('cancel'),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop('copy'),
            child: const Text('Только характеристики'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop('edit'),
            child: const Text('Открыть этот дом'),
          ),
        ],
      ),
    );
    if (mode == null || mode == 'cancel') return;

    if (mode == 'edit') {
      // Закрываем форму создания и отдаём выбранный дом наружу —
      // вызывающий экран откроет его карточку на правку.
      if (mounted) Navigator.of(context).pop(result);
      return;
    }

    setState(() {
      // Характеристики, общие для похожих домов, копируем.
      _areaController.text = result.totalArea?.toString() ?? '';
      _floorsController.text = result.floors?.toString() ?? '';
      _yearController.text = result.yearBuilt?.toString() ?? '';
      _roomsController.text = result.rooms?.toString() ?? '';
      _residentsController.text = result.residentsCount?.toString() ?? '';
      _providesHeating = result.providesHeating ?? false;
      _providesHotWater = result.providesHotWater ?? false;
      _selectedManagementCompanyId = result.managementCompanyId;
      _selectedManagementCompanyName = result.managementCompanyName;
      _entrancesController.text = result.entrancesCount?.toString() ?? '';
      _nonlivingCountController.text = result.nonlivingCount?.toString() ?? '';
      _nonlivingAreaController.text = result.nonlivingArea?.toString() ?? '';
      _stoveType = result.stoveType;
      _housingType = result.housingType;
      _commissioningDateController.text = result.commissioningDate ?? '';
      // ОКТМО и часовая зона относятся к населённому пункту, а не к
      // зданию — их копировать можно.
      _gisOktmoController.text = result.gisOktmo ?? '';
      _gisTimezoneController.text = result.gisTimezone ?? '';

      // НЕ копируем: название, координаты, ФИАС, кадастровый номер.
      // Это удостоверение конкретного здания, у нового дома оно своё.
      _nameController.clear();
      _latController.clear();
      _lngController.clear();
      _fiasHouseController.clear();
      _fiasAOController.clear();
      _cadastralController.clear();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Характеристики скопированы. Укажите адрес, координаты, '
            'ФИАС и кадастровый номер нового дома.',
          ),
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: screenHeight - 48,
          maxWidth: 500,
        ),
        child: Container(
          width: 500,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Theme.of(context).colorScheme.onSurface.withAlpha(25)),
          ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 60),
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

                      _SectionHeader('Документы'),
                      _buildSection([
                        _buildActionRow(
                          Icons.upload_file,
                          Colors.indigo,
                          'Загрузить документ',
                          _isUploadingDoc ? 'Загрузка...' : 'Выбрать файл',
                          onTap: _isUploadingDoc ? null : _uploadDocument,
                        ),
                        if (_documents.isNotEmpty) ...[
                          _buildDivider(),
                          ..._documents.map((doc) => Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Row(
                                  children: [
                                    Icon(
                                      _getDocIcon(doc['content_type'] ?? ''),
                                      size: 20,
                                      color: Colors.blue,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            doc['title'] ?? doc['filename'] ?? 'Документ',
                                            style: TextStyle(
                                              color: Theme.of(context).colorScheme.onSurface,
                                              fontSize: 14,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            '${doc['document_type_label'] ?? ''} • ${_formatFileSize(doc['file_size'])}',
                                            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                      onPressed: () => _deleteDocument(doc['id']),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                              ),
                              if (doc != _documents.last) _buildDivider(),
                            ],
                          )),
                        ],
                        if (widget.initialLocation == null) ...[
                          _buildDivider(),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Text(
                              'Документы можно загрузить после сохранения дома',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontStyle: FontStyle.italic),
                            ),
                          ),
                        ],
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
                        // «Квартир», а не «Помещений»: в портал это поле
                        // уходит параметром «Количество жилых помещений
                        // (квартир)», и нежилые в него не входят — для
                        // них отдельные поля ниже.
                        _buildInputRow(Icons.door_front_door, Colors.orange, 'Квартир', _roomsController, hint: '10', keyboardType: TextInputType.number),
                        _buildDivider(),
                        _buildInputRow(Icons.storefront, Colors.brown, 'Нежилых помещений', _nonlivingCountController, hint: '3', keyboardType: TextInputType.number),
                        _buildDivider(),
                        _buildInputRow(Icons.square_foot, Colors.brown, 'Площадь нежилых, м²', _nonlivingAreaController, hint: '240.5', keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                        _buildDivider(),
                        _buildInputRow(Icons.people, Colors.orange, 'Жильцов', _residentsController, hint: '4', keyboardType: TextInputType.number),
                      ]),
                      
                      // Эти поля раньше лежали в секции «ФИАС и кадастр»,
                      // хотя к идентификаторам не относятся.
                      _SectionHeader('Дом'),
                      _buildSection([
                        _buildActionRow(
                          Icons.event_available,
                          Colors.green,
                          'Ввод в эксплуатацию',
                          _commissioningDateController.text.isNotEmpty
                              ? _formatIsoDate(_commissioningDateController.text)
                              : 'Не указан',
                          isEmpty: _commissioningDateController.text.isEmpty,
                          onTap: _pickCommissioningDate,
                        ),
                        _buildDivider(),
                        _buildInputRow(Icons.door_front_door, Colors.indigo,
                            'Подъездов', _entrancesController,
                            hint: '4', keyboardType: TextInputType.number),
                        _buildDivider(),
                        _buildActionRow(
                          Icons.local_fire_department,
                          Colors.orange,
                          'Тип плит',
                          _stoveLabel(_stoveType) ?? 'Не указан',
                          isEmpty: _stoveLabel(_stoveType) == null,
                          onTap: () async {
                            final result = await _pickOne(
                              title: 'Тип плит',
                              current: _stoveType ?? '',
                              emptyLabel: 'Не указан',
                              options: const [
                                _Option('gas', 'Газовые'),
                                _Option('electric', 'Электрические'),
                                _Option('mixed', 'Смешанные'),
                              ],
                            );
                            if (result != null) {
                              setState(() =>
                                  _stoveType = result.isEmpty ? null : result);
                            }
                          },
                        ),
                        _buildDivider(),
                        _buildActionRow(
                          Icons.home,
                          Colors.deepPurple,
                          'Тип жилья',
                          _housingLabel(_housingType) ?? 'Не указан',
                          isEmpty: _housingLabel(_housingType) == null,
                          onTap: () async {
                            final result = await _pickOne(
                              title: 'Тип жилья',
                              current: _housingType ?? '',
                              emptyLabel: 'Не указан',
                              options: const [
                                _Option('privatized', 'Приватизированное'),
                                _Option('municipal', 'Муниципальное'),
                                _Option('departmental', 'Ведомственное'),
                              ],
                            );
                            if (result != null) {
                              setState(() =>
                                  _housingType = result.isEmpty ? null : result);
                            }
                          },
                        ),
                      ]),

                      _SectionHeader('Координаты'),
                      _buildSection([
                        _buildInputRow(Icons.navigation, Colors.red, 'Широта', _latController, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                        _buildDivider(),
                        _buildInputRow(Icons.navigation, Colors.red, 'Долгота', _lngController, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                      ]),
                      
                      _SectionHeader('ФИАС и кадастр'),
                      _buildSection([
                        _buildInputRow(Icons.description, Colors.purple, 'ФИАС дом', _fiasHouseController, hint: 'a0b1c2d3...'),
                        _buildDivider(),
                        _buildInputRow(Icons.description, Colors.blue, 'ФИАС адр. объект', _fiasAOController, hint: 'e4f5g6h7...'),
                        _buildDivider(),
                        _buildInputRow(Icons.pin, Colors.teal, 'Кадастровый номер', _cadastralController, hint: '05:40:000038:3079'),
                        _buildDivider(),
                      ]),

                      // Поля шаблона ГИС, которых нет в обычной карточке дома.
                      // ФИАС и кадастровый номер — выше, в своей секции.
                      _SectionHeader('ГИС ЖКХ',
                          filled: _gisFilledCount, total: _gisTotalCount),
                      _buildSection([
                        _buildInputRow(Icons.tag, Colors.teal, 'ОКТМО',
                            _gisOktmoController, hint: '82701000'),
                        _buildDivider(),
                        // Справочные поля — выпадающими списками: портал
                        // сверяет текст дословно, и опечатка в «Исправный»
                        // приводит к отказу при загрузке файла.
                        _buildGisPicker(
                          Icons.health_and_safety, Colors.green, 'Состояние',
                          _gisStateController.text,
                          gisStates,
                          (v) => setState(() => _gisStateController.text = v ?? ''),
                        ),
                        _buildDivider(),
                        _buildGisPicker(
                          Icons.timeline, Colors.blue, 'Стадия жизненного цикла',
                          _gisLifecycleController.text,
                          gisLifecycleStages,
                          (v) => setState(() => _gisLifecycleController.text = v ?? ''),
                        ),
                        _buildDivider(),
                        _buildInputRow(Icons.stairs, Colors.brown,
                            'Подземных этажей', _gisUndergroundController,
                            hint: '0', keyboardType: TextInputType.number),
                        _buildDivider(),
                        _buildTimezonePicker(),
                        _buildDivider(),
                        _buildTristateRow(Icons.account_balance, Colors.amber,
                            'Культурное наследие', _gisCulturalHeritage,
                            (v) => setState(() => _gisCulturalHeritage = v)),
                        _buildDivider(),
                        _buildTristateRow(Icons.flag, Colors.indigo,
                            'Собственность субъекта РФ', _gisFederalProperty,
                            (v) => setState(() => _gisFederalProperty = v)),
                        _buildDivider(),
                        _buildTristateRow(Icons.location_city, Colors.cyan,
                            'Муниципальная собственность', _gisMunicipalProperty,
                            (v) => setState(() => _gisMunicipalProperty = v)),
                        _buildDivider(),
                        _buildGisPicker(
                          Icons.apartment, Colors.orange, 'Тип общежития',
                          _gisHostelTypeController.text,
                          gisHostelTypes,
                          (v) => setState(() => _gisHostelTypeController.text = v ?? ''),
                          emptyLabel: 'не общежитие',
                        ),
                        if (_gisStatus != null && _gisStatus!.isNotEmpty) ...[
                          _buildDivider(),
                          // Статус приходит от портала после загрузки файла,
                          // поэтому только для чтения (onTap не задан).
                          _buildActionRow(Icons.cloud_done, Colors.blueGrey,
                              'Статус в ГИС', _gisStatus!),
                        ],
                      ]),

                      // Отдельные листы шаблона — на своих экранах:
                      // расширенных параметров 112, в карточку они не
                      // поместились бы. Своей секцией, а не вперемешку с
                      // полями: это переходы, а не ввод значений.
                      _SectionHeader('Сведения для ГИС ЖКХ'),
                      if (widget.initialLocation?.id == null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline,
                                  size: 15,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withAlpha(130)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Доступно после сохранения дома',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withAlpha(130),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      _buildSection([
                        _buildLinkRow(
                          Icons.door_front_door,
                          Colors.brown,
                          'Подъезды и лифты',
                          'номера, этажность, заводские номера',
                          _openStructure,
                        ),
                        _buildDivider(),
                        _buildLinkRow(
                          Icons.info_outline,
                          Colors.blue,
                          'Информация о доме',
                          'износ, площади, паркинг',
                          () => _openParams('house_info', 'Информация о доме'),
                        ),
                        _buildDivider(),
                        _buildLinkRow(
                          Icons.foundation,
                          Colors.deepOrange,
                          'Конструктивные элементы',
                          'фундамент, стены, крыша, окна',
                          () => _openParams(
                              'house_structure', 'Конструктивные элементы'),
                        ),
                        _buildDivider(),
                        _buildLinkRow(
                          Icons.plumbing,
                          Colors.cyan,
                          'Внутридомовые сети',
                          'отопление, ГВС, ХВС, газ, электричество',
                          () => _openParams(
                              'house_networks', 'Внутридомовые сети'),
                        ),
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
            child: Text('Отмена', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 17)),
          ),
          Text(
            widget.initialLocation != null ? 'Редактировать дом' : 'Новый дом',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
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

  /// Пустое поле → null: для ГИС «не заполнено» и «пустая строка» разные
  /// вещи, портал на пустой строке в коде ОКТМО ругается.
  String? _textOrNull(TextEditingController c) =>
      c.text.trim().isEmpty ? null : c.text.trim();

  /// Выбор значения из справочника ГИС.
  ///
  /// Показываем диалогом, а не DropdownButton: некоторые значения длинные
  /// («Капитальный ремонт без отселения»), и в узкой строке формы они
  /// обрезались бы до неузнаваемости.
  /// Перерисовать счётчик в заголовке секции ГИС.
  void _onGisFieldChanged() {
    if (mounted) setState(() {});
  }

  /// Сколько полей секции ГИС заполнено. По нему заголовок показывает
  /// «заполнено N из M»: полей много, и без счётчика непонятно, что
  /// осталось дозаполнить перед выгрузкой в портал.
  int get _gisTotalCount => 9;

  int get _gisFilledCount {
    var filled = 0;
    if (_gisOktmoController.text.trim().isNotEmpty) filled++;
    if (_gisStateController.text.trim().isNotEmpty) filled++;
    if (_gisLifecycleController.text.trim().isNotEmpty) filled++;
    if (_gisUndergroundController.text.trim().isNotEmpty) filled++;
    if (_gisTimezoneController.text.trim().isNotEmpty) filled++;
    if (_gisCulturalHeritage != null) filled++;
    if (_gisFederalProperty != null) filled++;
    if (_gisMunicipalProperty != null) filled++;
    if (_gisHostelTypeController.text.trim().isNotEmpty) filled++;
    return filled;
  }

  /// Переход на отдельный экран: название, пояснение и стрелка.
  ///
  /// Отдельно от `_buildActionRow`, потому что здесь нет «значения» —
  /// раньше пояснение писалось в колонку значения, где его обрезало и
  /// красило бледным, как незаполненное поле.
  ///
  /// У нового дома переход недоступен: экранам нужен его id. Строка при
  /// этом остаётся видимой (приглушённой), чтобы было понятно, что
  /// раздел существует.
  Widget _buildLinkRow(
    IconData icon,
    Color iconColor,
    String label,
    String description,
    VoidCallback onTap,
  ) {
    final enabled = widget.initialLocation?.id != null;
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.45,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(label,
                        style: TextStyle(
                            color: scheme.onSurface, fontSize: 16)),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: TextStyle(
                        color: scheme.onSurface.withAlpha(130),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios,
                  size: 14, color: scheme.onSurface.withAlpha(100)),
            ],
          ),
        ),
      ),
    );
  }

  /// Название типа плит или null, если не задан.
  String? _stoveLabel(String? code) => const {
        'gas': 'Газовые',
        'electric': 'Электрические',
        'mixed': 'Смешанные',
      }[code];

  String? _housingLabel(String? code) => const {
        'privatized': 'Приватизированное',
        'municipal': 'Муниципальное',
        'departmental': 'Ведомственное',
      }[code];

  /// «2020-05-14» → «14.05.2020»: ISO-дата в поле ввода неудобна.
  String _formatIsoDate(String iso) {
    final parts = iso.split('T').first.split('-');
    if (parts.length != 3) return iso;
    return '${parts[2]}.${parts[1]}.${parts[0]}';
  }

  /// Выбор одного значения из списка с отметкой текущего.
  ///
  /// Вместо SimpleDialog — лист снизу: в справочниках ГИС до 22
  /// значений («Состояние», «Часовая зона»), в диалоге они не
  /// помещались на экран телефона и список нельзя было прокрутить.
  Future<String?> _pickOne({
    required String title,
    required String current,
    required List<_Option> options,
    String emptyLabel = 'Не указано',
  }) {
    final scheme = Theme.of(context).colorScheme;
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
                child: Text(
                  title,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w600),
                ),
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
                      color: current.isEmpty ? scheme.primary : null,
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
                        color: option.value == current ? scheme.primary : null,
                      ),
                      title: Text(option.label),
                      subtitle: option.hint == null ? null : Text(option.hint!),
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

  Widget _buildGisPicker(
    IconData icon,
    Color iconColor,
    String label,
    String current,
    List<String> options,
    ValueChanged<String?> onChanged, {
    String emptyLabel = 'Не указано',
  }) {
    return _buildActionRow(
      icon,
      iconColor,
      label,
      current.isEmpty ? emptyLabel : current,
      isEmpty: current.isEmpty,
      onTap: () async {
        final result = await _pickOne(
          title: label,
          current: current,
          emptyLabel: emptyLabel,
          options: [for (final o in options) _Option(o, o)],
        );
        if (result != null) onChanged(result);
      },
    );
  }

  /// Часовая зона: выбираем по городу, храним идентификатор Olson.
  ///
  /// В файл для портала сервер пишет ГОРОД: колонка J «Часовая зона по
  /// Olson» ограничена списком `Olson!$C$1:$C$21` — это города, и
  /// «Europe/Moscow» портал отвергает. Храним всё равно идентификатор:
  /// он однозначен, а города в справочнике портала могут переименовать.
  Widget _buildTimezonePicker() {
    final current = _gisTimezoneController.text;
    final match = gisTimezones.where((z) => z.id == current).firstOrNull;
    return _buildActionRow(
      Icons.schedule,
      Colors.deepPurple,
      'Часовая зона',
      match?.city ?? (current.isEmpty ? 'Не указано' : current),
      // Идентификатор Olson показываем подписью: в значение он не
      // влезал, а оператору полезно видеть, что уйдёт в портал.
      subtitle: match?.id,
      isEmpty: current.isEmpty,
      onTap: () async {
        final result = await _pickOne(
          title: 'Часовая зона по Olson',
          current: current,
          options: [
            for (final z in gisTimezones) _Option(z.id, z.city, hint: z.id),
          ],
        );
        if (result != null) {
          setState(() => _gisTimezoneController.text = result);
        }
      },
    );
  }

  /// Переключатель на три состояния: не указано / Да / Нет.
  ///
  /// Сегментами, а не диалогом: это самый частый ввод в секции ГИС
  /// (культурное наследие, собственность субъекта, муниципальная), и
  /// лишнее окно на каждое поле только мешало.
  Widget _buildTristateRow(
    IconData icon,
    Color iconColor,
    String label,
    bool? value,
    ValueChanged<bool?> onChanged,
  ) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: TextStyle(color: scheme.onSurface, fontSize: 15)),
          ),
          const SizedBox(width: 8),
          SegmentedButton<String>(
            style: const ButtonStyle(
              visualDensity: VisualDensity(horizontal: -3, vertical: -3),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: 'null', label: Text('—')),
              ButtonSegment(value: 'yes', label: Text('Да')),
              ButtonSegment(value: 'no', label: Text('Нет')),
            ],
            selected: {
              value == null ? 'null' : (value ? 'yes' : 'no'),
            },
            onSelectionChanged: (selected) {
              final picked = selected.first;
              onChanged(picked == 'null' ? null : picked == 'yes');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSection(List<Widget> children) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withAlpha(13),
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
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16),
            ),
          ),
          Expanded(
            flex: 3,
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              textAlign: TextAlign.right,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(77)),
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

  /// Подъезды и лифты дома — отдельный экран.
  void _openStructure() {
    final id = widget.initialLocation?.id;
    if (id == null) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => HouseStructureScreen(
        locationId: id,
        houseName: widget.initialLocation?.name ?? 'Дом',
      ),
    ));
  }

  /// Расширенные сведения ГИС: форма строится по каталогу с сервера.
  void _openParams(String groupKey, String title) {
    final id = widget.initialLocation?.id;
    if (id == null) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => GisParamsScreen(
        groupKey: groupKey,
        ownerType: 'house',
        ownerId: id,
        ownerTitle: widget.initialLocation?.name ?? title,
      ),
    ));
  }

  /// Строка со значением, которое выбирают (не вводят с клавиатуры).
  ///
  /// ВАЖНО ПРО ЦВЕТ: раньше значение рисовалось
  /// `Colors.white.withValues(alpha: 0.5)`. На светлой теме это белый
  /// текст на белой карточке — выбранные «Состояние», «Тип плит»,
  /// «Часовая зона» и ещё десяток полей были не видны вообще. Цвет
  /// обязан идти от темы, поэтому здесь `colorScheme`.
  ///
  /// [isEmpty] — значение не заполнено: показываем его бледным и
  /// курсивом, чтобы «Не указано» нельзя было спутать с настоящим
  /// значением. [isLink] — строка открывает отдельный экран.
  Widget _buildActionRow(
    IconData icon,
    Color iconColor,
    String label,
    String value, {
    VoidCallback? onTap,
    bool isEmpty = false,
    bool isLink = false,
    String? subtitle,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final enabled = onTap != null;

    return InkWell(
      onTap: onTap,
      child: Opacity(
        // Недоступная строка (например, до сохранения дома) видна, но
        // явно показывает, что нажать нельзя.
        opacity: enabled ? 1 : 0.45,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: TextStyle(color: scheme.onSurface, fontSize: 16),
                    ),
                    if (subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          subtitle,
                          style: TextStyle(
                            color: scheme.onSurface.withAlpha(130),
                            fontSize: 11,
                          ),
                        ),
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
                  // Длинные значения («Капитальный ремонт без отселения»,
                  // названия часовых зон) раньше ломали строку по ширине.
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isEmpty
                        ? scheme.onSurface.withAlpha(105)
                        : scheme.onSurface,
                    fontSize: 15,
                    fontWeight: isEmpty ? FontWeight.normal : FontWeight.w500,
                    fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
              ),
              // Стрелка у ВСЕХ нажимаемых строк: раньше она появлялась
              // только у значений «Выбрать»/«Не выбрано», и по
              // заполненной строке не было видно, что её можно открыть.
              if (enabled)
                Padding(
                  padding: const EdgeInsets.only(left: 2),
                  child: Icon(
                    isLink ? Icons.arrow_forward_ios : Icons.unfold_more,
                    size: isLink ? 14 : 18,
                    color: scheme.onSurface.withAlpha(100),
                  ),
                ),
            ],
          ),
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
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16),
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
                  Expanded(
                    child: Text(
                      'Начальник участка',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16),
                    ),
                  ),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedSiteManager,
                      dropdownColor: Theme.of(context).colorScheme.surface,
                      icon: const SizedBox.shrink(),
                      hint: Text(
                        'Выберите',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(77), fontSize: 16),
                      ),
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16),
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
    return Divider(color: Theme.of(context).colorScheme.onSurface.withAlpha(25), height: 1, indent: 46);
  }

  IconData _getDocIcon(String contentType) {
    if (contentType.contains('pdf')) return Icons.picture_as_pdf;
    if (contentType.contains('image')) return Icons.image;
    if (contentType.contains('word') || contentType.contains('doc')) return Icons.description;
    if (contentType.contains('excel') || contentType.contains('sheet')) return Icons.table_chart;
    return Icons.insert_drive_file;
  }

  String _formatFileSize(dynamic bytes) {
    if (bytes == null) return '';
    final b = bytes is int ? bytes : int.tryParse(bytes.toString()) ?? 0;
    if (b < 1024) return '$b Б';
    if (b < 1024 * 1024) return '${(b / 1024).toStringAsFixed(1)} КБ';
    return '${(b / (1024 * 1024)).toStringAsFixed(1)} МБ';
  }
}

/// Вариант выбора: что уйдёт в базу (`value`) и что видит оператор.
class _Option {
  final String value;
  final String label;

  /// Пояснение под названием — например идентификатор Olson.
  final String? hint;

  const _Option(this.value, this.label, {this.hint});
}

class _SectionHeader extends StatelessWidget {
  final String title;

  /// Сколько полей секции заполнено — показывается справа.
  /// Нужно для секции ГИС: полей там много, и без счётчика непонятно,
  /// что ещё не заполнено перед выгрузкой в портал.
  final int? filled;
  final int? total;

  const _SectionHeader(this.title, {this.filled, this.total});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final showCounter = filled != null && total != null && total! > 0;
    final complete = showCounter && filled == total;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title.toUpperCase(),
              style: TextStyle(
                color: scheme.onSurface.withAlpha(140),
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          if (showCounter)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: complete
                    ? Colors.green.withValues(alpha: 0.15)
                    : scheme.onSurface.withAlpha(18),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  if (complete)
                    const Padding(
                      padding: EdgeInsets.only(right: 3),
                      child: Icon(Icons.check, size: 11, color: Colors.green),
                    ),
                  Text(
                    'заполнено $filled из $total',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: complete
                          ? Colors.green.shade700
                          : scheme.onSurface.withAlpha(150),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
