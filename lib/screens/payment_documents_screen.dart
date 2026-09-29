import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../services/base_api_service.dart';
import 'cashier_detail_screen.dart';
import 'cashier_help_screen.dart';

/// Экран платежных документов с поиском, фильтрами, сортировкой и экспортом
class PaymentDocumentsScreen extends ConsumerStatefulWidget {
  final int? accountId;
  final String? accountNumber;
  final String? fio;

  const PaymentDocumentsScreen({
    super.key,
    this.accountId,
    this.accountNumber,
    this.fio,
  });

  @override
  ConsumerState<PaymentDocumentsScreen> createState() => _PaymentDocumentsScreenState();
}

class _PaymentDocumentsScreenState extends ConsumerState<PaymentDocumentsScreen> {
  // Данные
  List<Map<String, dynamic>> _documents = [];
  bool _isLoading = true;
  String? _error;
  int _totalCount = 0;

  // Поиск и фильтры
  final _searchController = TextEditingController();
  String? _selectedPeriod;
  int? _selectedLocationId;
  String? _selectedLocationName;
  List<String> _periods = [];
  List<Map<String, dynamic>> _locations = [];

  // Фильтры долгов
  bool _hasDebt = false;
  bool _hasOverpayment = false;
  double? _minDebt;
  double? _maxDebt;

  // Сортировка
  String _sortBy = 'debt_end';
  String _sortOrder = 'desc';

  // Статистика
  Map<String, dynamic> _stats = {};

  // Экспорт
  bool _isExporting = false;

  // Debounce таймер
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _loadPeriods();
    _loadLocations();
    _loadDocuments();
    _loadStatistics();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _buildQueryParams() {
    final params = <String, dynamic>{};
    if (widget.accountId != null) params['account_id'] = widget.accountId;
    if (_selectedPeriod != null) params['period_date'] = _selectedPeriod;
    if (_selectedLocationId != null) params['location_id'] = _selectedLocationId;
    if (_searchController.text.trim().isNotEmpty) {
      params['search'] = _searchController.text.trim();
      // При поиске дом,кв — сортировать по квартире
      if (RegExp(r'^\d+\s*[,.]\s*\d+$').hasMatch(_searchController.text.trim())) {
        params['sort_by'] = 'apartment';
        params['sort_order'] = 'asc';
      }
    } else {
      params['sort_by'] = _sortBy;
      params['sort_order'] = _sortOrder;
    }
    if (_hasDebt) params['has_debt'] = true;
    if (_hasOverpayment) params['has_overpayment'] = true;
    if (_minDebt != null) params['min_debt'] = _minDebt;
    if (_maxDebt != null) params['max_debt'] = _maxDebt;
    return params;
  }

  Future<void> _loadPeriods() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/payment-documents/periods');
      if (response.statusCode == 200) {
        setState(() => _periods = (response.data as List).map((e) => e.toString()).toList());
      }
    } catch (e) {
      debugPrint('Error loading periods: $e');
    }
  }

  Future<void> _loadLocations() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/payment-documents/locations');
      if (response.statusCode == 200) {
        setState(() => _locations = (response.data as List).cast<Map<String, dynamic>>());
      }
    } catch (e) {
      debugPrint('Error loading locations: $e');
    }
  }

  Future<void> _loadStatistics() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/payment-documents/statistics', queryParameters: _buildQueryParams());
      if (response.statusCode == 200) {
        setState(() => _stats = response.data as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('Error loading stats: $e');
    }
  }

  Future<void> _loadDocuments() async {
    setState(() { _isLoading = true; _error = null; });

    try {
      final dio = ref.read(dioProvider);
      final params = _buildQueryParams();
      params['limit'] = 200;
      
      final response = await dio.get('/payment-documents/', queryParameters: params);

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        setState(() {
          _documents = (data['items'] as List).cast<Map<String, dynamic>>();
          _totalCount = data['total'] ?? _documents.length;
          _isLoading = false;
        });
      } else {
        setState(() { _error = 'Ошибка: ${response.statusCode}'; _isLoading = false; });
      }
    } catch (e) {
      setState(() { _error = 'Ошибка: $e'; _isLoading = false; });
    }
    
    _loadStatistics();
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) _loadDocuments();
    });
  }

  Future<void> _exportFile(String format) async {
    // Для досудебных — показываем диалог настроек
    final isDosudebnoye = format == 'dosudebnoye' || format == 'obshee-dosudebnoye';
    final isCourtOrder = format == 'court-order';
    Map<String, String> extraParams = {};

    if (isDosudebnoye) {
      final result = await _showDosudebSettings(format);
      if (result == null) return;
      extraParams = result;
    }

    if (isCourtOrder) {
      final result = await _showCourtOrderSettings();
      if (result == null) return;
      extraParams = result;
    }

    final extMap = {'excel': 'xlsx', 'baosna-xml': 'xml', 'baosna-json': 'json', 'baosna-xls': 'xlsx'};
    final ext = isCourtOrder
        ? (extraParams['output_format'] == 'single' ? 'docx' : 'zip')
        : (extMap[format] ?? 'pdf');
    final namePrefix = {
      'excel': 'payment_docs',
      'baosna-xml': 'baosna',
      'baosna-json': 'baosna',
      'baosna-xls': 'baosna',
      'pdf': 'payment_docs',
      'dosudebnoye': 'dosudebnoye',
      'obshee-dosudebnoye': 'obshee_dosudebnoye',
      'court-order': 'court_orders',
    }[format] ?? 'export';
    final defaultName = '${namePrefix}_${DateTime.now().millisecondsSinceEpoch}.$ext';

    setState(() => _isExporting = true);
    try {
      final dio = ref.read(dioProvider);
      final params = _buildQueryParams();
      params.addAll(extraParams);

      final response = await dio.get(
        '/payment-documents/export/$format',
        queryParameters: params,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode != 200) return;

      final bytes = response.data as List<int>;

      // iOS/Android: сохраняем в temp и шарим через Share Sheet
      if (Platform.isIOS || Platform.isAndroid) {
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/$defaultName');
        await tempFile.writeAsBytes(bytes);

        if (!mounted) return;
        final box = context.findRenderObject() as RenderBox?;
        final shareOrigin = box != null
            ? box.localToGlobal(Offset.zero) & box.size
            : const Rect.fromLTWH(0, 0, 100, 100);
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(tempFile.path, mimeType: ext == 'pdf' ? 'application/pdf' : ext == 'xml' ? 'application/xml' : ext == 'json' ? 'application/json' : 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')],
            subject: defaultName,
            sharePositionOrigin: shareOrigin,
          ),
        );
        return;
      }

      // macOS / Windows / Linux: диалог «Сохранить как»
      String? savePath;
      try {
        savePath = await FilePicker.saveFile(
          dialogTitle: 'Сохранить $namePrefix',
          fileName: defaultName,
        );
      } catch (_) {
        try {
          final dir = await FilePicker.getDirectoryPath(dialogTitle: 'Выберите папку');
          if (dir != null) savePath = '$dir/$defaultName';
        } catch (_) {}
      }

      if (savePath == null) return;

      final filePath = savePath.endsWith('.$ext') ? savePath : '$savePath.$ext';
      await File(filePath).writeAsBytes(bytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Сохранено: $filePath'),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(label: 'OK', onPressed: () {}),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Ошибка экспорта: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<Map<String, String>?> _showDosudebSettings(String format) async {
    // Загружаем ВСЕ реквизиты организаций
    List<Map<String, dynamic>> allRequisites = [];
    Map<String, dynamic> defaults = {};
    final dio = ref.read(dioProvider);
    
    // Пробуем загрузить реквизиты
    try {
      final resp = await dio.get('/org-requisites/');
      if (resp.statusCode == 200 && resp.data is List) {
        allRequisites = (resp.data as List).map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e)).toList();
      }
    } catch (e) {
      debugPrint('⚠️ org-requisites failed: $e');
    }

    // Если нет реквизитов — пробуем management-companies
    if (allRequisites.isEmpty) {
      try {
        final resp = await dio.get('/management-companies/');
        if (resp.statusCode == 200 && resp.data is List) {
          allRequisites = (resp.data as List).map<Map<String, dynamic>>((e) {
            final m = Map<String, dynamic>.from(e);
            // Маппим поля management_company → org_requisites формат
            return {
              'id': m['id'],
              'org_name': m['name'] ?? '',
              'director_name': m['director'] ?? '',
              'director_title': 'Генеральный директор',
              'city': 'г. Махачкала',
              'bik': '',
              'account_number': '',
              'inn': '',
              'bank_name': '',
              'corr_account': '',
              'is_default': 0,
            };
          }).toList();
        }
      } catch (e) {
        debugPrint('⚠️ management-companies failed: $e');
      }
    }
    
    debugPrint('📋 Loaded ${allRequisites.length} requisites');

    // Найдём default
    for (final r in allRequisites) {
      if (r['is_default'] == 1) { defaults = r; break; }
    }
    if (defaults.isEmpty && allRequisites.isNotEmpty) {
      defaults = allRequisites.first;
    }

    final deadlineCtrl = TextEditingController(text: '20.10.2026');
    final orgNameCtrl = TextEditingController(text: (defaults['org_name'] as String?) ?? 'ООО УК "СТАНДАРТ СЕРВИС"');
    final directorTitleCtrl = TextEditingController(text: (defaults['director_title'] as String?) ?? 'Генеральный директор');
    final directorNameCtrl = TextEditingController(text: (defaults['director_name'] as String?) ?? 'Агларов Ш.Р.');
    final cityCtrl = TextEditingController(text: (defaults['city'] as String?) ?? 'г. Махачкала');

    String buildRequisitesText(Map<String, dynamic> r) {
      final parts = <String>[];
      if (r['bik'] != null && (r['bik'] as String).isNotEmpty) parts.add('БИК: ${r['bik']}');
      if (r['account_number'] != null && (r['account_number'] as String).isNotEmpty) parts.add('Р/с: ${r['account_number']}');
      if (r['inn'] != null && (r['inn'] as String).isNotEmpty) parts.add('ИНН: ${r['inn']}');
      if (r['bank_name'] != null && (r['bank_name'] as String).isNotEmpty) parts.add('Банк: ${r['bank_name']}');
      if (r['corr_account'] != null && (r['corr_account'] as String).isNotEmpty) parts.add('Корр/с: ${r['corr_account']}');
      return parts.join('\n');
    }

    final requisitesCtrl = TextEditingController(text: buildRequisitesText(defaults));
    final noticeDateCtrl = TextEditingController(
      text: '${DateTime.now().day.toString().padLeft(2, '0')}.${DateTime.now().month.toString().padLeft(2, '0')}.${DateTime.now().year}',
    );

    String? selectedReqId = defaults['id']?.toString();

    final isPersonal = format == 'dosudebnoye';
    final title = isPersonal ? 'Досудебное (личное)' : 'Досудебное (общее)';

    bool excludePromises = true;
    bool excludePayers = true;
    final excludeFioCtrl = TextEditingController();

    // Выше были запросы реквизитов — экран мог закрыться за это время.
    if (!mounted) return null;

    return showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('⚖️ $title'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Выбор организации — сверху
                if (allRequisites.isNotEmpty) ...[
                  InkWell(
                    onTap: () async {
                      final selected = await showDialog<Map<String, dynamic>>(
                        context: ctx,
                        builder: (dialogCtx) {
                          String searchText = '';
                          return StatefulBuilder(
                            builder: (dialogCtx, setSearchState) {
                              final filtered = allRequisites.where((r) {
                                final name = (r['org_name'] ?? '').toString().toLowerCase();
                                return name.contains(searchText.toLowerCase());
                              }).toList();

                              Future<void> openOrgForm({Map<String, dynamic>? existing}) async {
                                final nc = TextEditingController(text: existing?['org_name'] ?? '');
                                final dtc = TextEditingController(text: existing?['director_title'] ?? 'Генеральный директор');
                                final dnc = TextEditingController(text: existing?['director_name'] ?? '');
                                final cc = TextEditingController(text: existing?['city'] ?? 'г. Махачкала');
                                final bikc = TextEditingController(text: existing?['bik'] ?? '');
                                final acc = TextEditingController(text: existing?['account_number'] ?? '');
                                final innc = TextEditingController(text: existing?['inn'] ?? '');
                                final bnc = TextEditingController(text: existing?['bank_name'] ?? '');
                                final corc = TextEditingController(text: existing?['corr_account'] ?? '');

                                final saved = await showDialog<Map<String, dynamic>>(
                                  context: dialogCtx,
                                  builder: (formCtx) => AlertDialog(
                                    title: Text(existing != null ? '✏️ Редактировать' : '➕ Новая организация'),
                                    content: SingleChildScrollView(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextField(controller: nc, decoration: const InputDecoration(labelText: 'Название *', border: OutlineInputBorder())),
                                          const SizedBox(height: 8),
                                          TextField(controller: dtc, decoration: const InputDecoration(labelText: 'Должность руководителя', border: OutlineInputBorder())),
                                          const SizedBox(height: 8),
                                          TextField(controller: dnc, decoration: const InputDecoration(labelText: 'ФИО руководителя', border: OutlineInputBorder())),
                                          const SizedBox(height: 8),
                                          TextField(controller: cc, decoration: const InputDecoration(labelText: 'Город', border: OutlineInputBorder())),
                                          const SizedBox(height: 12),
                                          const Text('Реквизиты', style: TextStyle(fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 8),
                                          TextField(controller: innc, decoration: const InputDecoration(labelText: 'ИНН', border: OutlineInputBorder())),
                                          const SizedBox(height: 8),
                                          TextField(controller: bikc, decoration: const InputDecoration(labelText: 'БИК', border: OutlineInputBorder())),
                                          const SizedBox(height: 8),
                                          TextField(controller: acc, decoration: const InputDecoration(labelText: 'Расчётный счёт', border: OutlineInputBorder())),
                                          const SizedBox(height: 8),
                                          TextField(controller: bnc, decoration: const InputDecoration(labelText: 'Банк', border: OutlineInputBorder())),
                                          const SizedBox(height: 8),
                                          TextField(controller: corc, decoration: const InputDecoration(labelText: 'Корр. счёт', border: OutlineInputBorder())),
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(formCtx), child: const Text('Отмена')),
                                      FilledButton(
                                        onPressed: () async {
                                          if (nc.text.trim().isEmpty) return;
                                          final body = {
                                            'org_name': nc.text.trim(),
                                            'director_title': dtc.text.trim(),
                                            'director_name': dnc.text.trim(),
                                            'city': cc.text.trim(),
                                            'bik': bikc.text.trim(),
                                            'account_number': acc.text.trim(),
                                            'inn': innc.text.trim(),
                                            'bank_name': bnc.text.trim(),
                                            'corr_account': corc.text.trim(),
                                          };
                                          try {
                                            if (existing != null && existing['id'] != null) {
                                              await dio.put('/org-requisites/${existing['id']}', data: body);
                                            } else {
                                              await dio.post('/org-requisites/', data: body);
                                            }
                                            // Перезагружаем список
                                            final resp = await dio.get('/org-requisites/');
                                            if (resp.statusCode == 200 && resp.data is List) {
                                              allRequisites.clear();
                                              allRequisites.addAll((resp.data as List).map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e)));
                                            }
                                            if (formCtx.mounted) Navigator.pop(formCtx, body);
                                          } catch (e) {
                                            debugPrint('❌ Save org error: $e');
                                          }
                                        },
                                        child: Text(existing != null ? 'Сохранить' : 'Создать'),
                                      ),
                                    ],
                                  ),
                                );
                                if (saved != null) {
                                  setSearchState(() {});
                                }
                              }

                              return AlertDialog(
                                title: Row(
                                  children: [
                                    const Expanded(child: Text('🏢 Организации')),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle, color: Colors.green),
                                      tooltip: 'Добавить организацию',
                                      onPressed: () => openOrgForm(),
                                    ),
                                  ],
                                ),
                                content: SizedBox(
                                  width: double.maxFinite,
                                  height: 400,
                                  child: Column(
                                    children: [
                                      TextField(
                                        autofocus: true,
                                        decoration: const InputDecoration(
                                          hintText: 'Поиск...',
                                          prefixIcon: Icon(Icons.search),
                                          border: OutlineInputBorder(),
                                        ),
                                        onChanged: (v) => setSearchState(() => searchText = v),
                                      ),
                                      const SizedBox(height: 8),
                                      Expanded(
                                        child: ListView.builder(
                                          itemCount: filtered.length,
                                          itemBuilder: (_, i) {
                                            final r = filtered[i];
                                            final isSelected = r['id']?.toString() == selectedReqId;
                                            return ListTile(
                                              dense: true,
                                              selected: isSelected,
                                              leading: Icon(Icons.business, color: isSelected ? Colors.blue : Colors.grey),
                                              title: Text(r['org_name'] ?? '-', style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                                              subtitle: r['director_name'] != null && r['director_name'].toString().isNotEmpty
                                                  ? Text(r['director_name'], style: const TextStyle(fontSize: 12))
                                                  : null,
                                              trailing: IconButton(
                                                icon: const Icon(Icons.edit, size: 18),
                                                onPressed: () => openOrgForm(existing: r),
                                              ),
                                              onTap: () => Navigator.pop(dialogCtx, r),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                      if (selected != null) {
                        setDialogState(() {
                          selectedReqId = selected['id']?.toString();
                          orgNameCtrl.text = selected['org_name'] ?? '';
                          directorTitleCtrl.text = selected['director_title'] ?? 'Генеральный директор';
                          directorNameCtrl.text = selected['director_name'] ?? '';
                          cityCtrl.text = selected['city'] ?? 'г. Махачкала';
                          requisitesCtrl.text = buildRequisitesText(selected);
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: '🏢 Организация',
                        prefixIcon: Icon(Icons.business),
                        suffixIcon: Icon(Icons.arrow_drop_down),
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        orgNameCtrl.text.isNotEmpty ? orgNameCtrl.text : 'Выберите организацию',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          color: orgNameCtrl.text.isNotEmpty ? null : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                TextField(
                  controller: noticeDateCtrl,
                  decoration: const InputDecoration(labelText: 'Дата составления', prefixIcon: Icon(Icons.calendar_today), border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: deadlineCtrl,
                  decoration: const InputDecoration(labelText: 'Срок оплаты (до)', prefixIcon: Icon(Icons.timer), border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: orgNameCtrl,
                  decoration: const InputDecoration(labelText: 'Название организации', prefixIcon: Icon(Icons.business), border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: directorTitleCtrl,
                  decoration: const InputDecoration(labelText: 'Должность', prefixIcon: Icon(Icons.badge), border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: directorNameCtrl,
                  decoration: const InputDecoration(labelText: 'ФИО руководителя', prefixIcon: Icon(Icons.person), border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: cityCtrl,
                  decoration: const InputDecoration(labelText: 'Город', prefixIcon: Icon(Icons.location_city), border: OutlineInputBorder()),
                ),
                if (isPersonal) ...[
                  const SizedBox(height: 10),
                  TextField(
                    controller: requisitesCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Реквизиты для оплаты', prefixIcon: Icon(Icons.account_balance), border: OutlineInputBorder(), alignLabelWithHint: true),
                  ),
                ],
                // Фильтры исключений — внизу
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(ctx).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('🛡️ Защита от ошибок', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 4),
                      CheckboxListTile(
                        value: excludePromises,
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: const Text('Исключить обещавших', style: TextStyle(fontSize: 13)),
                        subtitle: const Text('🤝 Кто обещал оплатить', style: TextStyle(fontSize: 11)),
                        onChanged: (v) => setDialogState(() => excludePromises = v ?? true),
                      ),
                      CheckboxListTile(
                        value: excludePayers,
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: const Text('Исключить плательщиков', style: TextStyle(fontSize: 13)),
                        subtitle: const Text('💰 Кто ежемесячно платит', style: TextStyle(fontSize: 11)),
                        onChanged: (v) => setDialogState(() => excludePayers = v ?? true),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: excludeFioCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Исключить по ФИО',
                          hintText: 'Амирбеков Г Г, Иванов',
                          prefixIcon: Icon(Icons.person_off),
                          border: OutlineInputBorder(),
                          helperText: 'Через запятую. Частичное совпадение.',
                          helperMaxLines: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
            FilledButton.icon(
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Сформировать'),
              onPressed: () {
                Navigator.pop(ctx, {
                  'deadline': deadlineCtrl.text,
                  'org_name': orgNameCtrl.text,
                  'director_title': directorTitleCtrl.text,
                  'director_name': directorNameCtrl.text,
                  'notice_date': noticeDateCtrl.text,
                  'city': cityCtrl.text,
                  if (isPersonal) 'requisites': requisitesCtrl.text,
                  'exclude_promises': excludePromises.toString(),
                  'exclude_payers': excludePayers.toString(),
                  if (excludeFioCtrl.text.trim().isNotEmpty)
                    'exclude_fio': excludeFioCtrl.text.trim(),
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<Map<String, String>?> _showCourtOrderSettings() async {
    // Загружаем реквизиты организации
    List<Map<String, dynamic>> allRequisites = [];
    Map<String, dynamic> defaults = {};
    final dio = ref.read(dioProvider);

    try {
      final resp = await dio.get('/org-requisites/');
      if (resp.statusCode == 200 && resp.data is List) {
        allRequisites = (resp.data as List).map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e)).toList();
      }
    } catch (_) {}

    for (final r in allRequisites) {
      if (r['is_default'] == 1) { defaults = r; break; }
    }
    if (defaults.isEmpty && allRequisites.isNotEmpty) defaults = allRequisites.first;

    final orgNameCtrl = TextEditingController(text: (defaults['org_name'] as String?) ?? 'ООО УК «Стандарт-Сервис»');
    final directorTitleCtrl = TextEditingController(text: (defaults['director_title'] as String?) ?? 'Генеральный директор');
    final directorNameCtrl = TextEditingController(text: (defaults['director_name'] as String?) ?? 'Агларов Ш.Р.');
    final cityCtrl = TextEditingController(text: (defaults['city'] as String?) ?? 'г. Махачкала');
    final orgAddressCtrl = TextEditingController(text: (defaults['address'] as String?) ?? '');
    final orgInnCtrl = TextEditingController(text: (defaults['inn'] as String?) ?? '');
    final orgOgrnCtrl = TextEditingController(text: (defaults['ogrn'] as String?) ?? '');
    final bankNameCtrl = TextEditingController(text: (defaults['bank_name'] as String?) ?? '');
    final bikCtrl = TextEditingController(text: (defaults['bik'] as String?) ?? '');
    final bankAccountCtrl = TextEditingController(text: (defaults['account_number'] as String?) ?? '');
    final corrAccountCtrl = TextEditingController(text: (defaults['corr_account'] as String?) ?? '');
    final courtNameCtrl = TextEditingController(text: 'судебного участка №11');
    final courtAddressCtrl = TextEditingController(text: 'г. Махачкала');
    final contractDateCtrl = TextEditingController(text: '23.07.2022');
    final tariffCtrl = TextEditingController(text: '12.00');
    final periodFromCtrl = TextEditingController(text: '23.07.2022');
    final periodToCtrl = TextEditingController(text: '30.04.2026');
    final representativeCtrl = TextEditingController(text: 'Амирбеков М.Г.');

    int? selectedReqId = defaults.isNotEmpty ? (defaults['id'] as int?) : null;
    String outputFormat = 'zip';
    bool excludePromises = true;
    bool excludePayers = true;
    final excludeFioCtrl = TextEditingController();

    void fillFromRequisites(Map<String, dynamic> r, void Function(void Function()) setState) {
      orgNameCtrl.text = (r['org_name'] as String?) ?? '';
      directorTitleCtrl.text = (r['director_title'] as String?) ?? '';
      directorNameCtrl.text = (r['director_name'] as String?) ?? '';
      cityCtrl.text = (r['city'] as String?) ?? '';
      orgAddressCtrl.text = (r['address'] as String?) ?? '';
      orgInnCtrl.text = (r['inn'] as String?) ?? '';
      orgOgrnCtrl.text = (r['ogrn'] as String?) ?? '';
      bankNameCtrl.text = (r['bank_name'] as String?) ?? '';
      bikCtrl.text = (r['bik'] as String?) ?? '';
      bankAccountCtrl.text = (r['account_number'] as String?) ?? '';
      corrAccountCtrl.text = (r['corr_account'] as String?) ?? '';
      selectedReqId = r['id'] as int?;
      setState(() {});
    }

    // Выше был запрос реквизитов — экран мог закрыться за это время.
    if (!mounted) return null;

    return showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('⚖️ Судебный приказ'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Выбор организации
                  const Text('Взыскатель', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  if (allRequisites.length > 1) ...[
                    DropdownButtonFormField<int>(
                      initialValue: selectedReqId,
                      decoration: const InputDecoration(
                        labelText: 'Выбрать организацию',
                        border: OutlineInputBorder(),
                        isDense: true,
                        prefixIcon: Icon(Icons.business, size: 18),
                      ),
                      items: allRequisites.map((r) => DropdownMenuItem<int>(
                        value: r['id'] as int,
                        child: Text(
                          (r['org_name'] as String?) ?? '—',
                          overflow: TextOverflow.ellipsis,
                        ),
                      )).toList(),
                      onChanged: (id) {
                        if (id == null) return;
                        final r = allRequisites.firstWhere((e) => e['id'] == id, orElse: () => {});
                        if (r.isNotEmpty) fillFromRequisites(r, setDialogState);
                      },
                    ),
                    const SizedBox(height: 8),
                  ],
                  TextField(controller: orgNameCtrl, decoration: const InputDecoration(labelText: 'Название (по ЕГРЮЛ)', border: OutlineInputBorder(), isDense: true)),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: TextField(controller: orgInnCtrl, decoration: const InputDecoration(labelText: 'ИНН', border: OutlineInputBorder(), isDense: true))),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(controller: orgOgrnCtrl, decoration: const InputDecoration(labelText: 'ОГРН', border: OutlineInputBorder(), isDense: true))),
                  ]),
                  const SizedBox(height: 8),
                  TextField(controller: orgAddressCtrl, decoration: const InputDecoration(labelText: 'Юр. адрес', border: OutlineInputBorder(), isDense: true)),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: TextField(controller: bankNameCtrl, decoration: const InputDecoration(labelText: 'Банк', border: OutlineInputBorder(), isDense: true))),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(controller: bikCtrl, decoration: const InputDecoration(labelText: 'БИК', border: OutlineInputBorder(), isDense: true))),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: TextField(controller: bankAccountCtrl, decoration: const InputDecoration(labelText: 'Р/с', border: OutlineInputBorder(), isDense: true))),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(controller: corrAccountCtrl, decoration: const InputDecoration(labelText: 'К/с', border: OutlineInputBorder(), isDense: true))),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: TextField(controller: directorTitleCtrl, decoration: const InputDecoration(labelText: 'Должность', border: OutlineInputBorder(), isDense: true))),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(controller: directorNameCtrl, decoration: const InputDecoration(labelText: 'ФИО руководителя', border: OutlineInputBorder(), isDense: true))),
                  ]),

                  const SizedBox(height: 16),
                  const Text('Суд', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  TextField(controller: courtNameCtrl, decoration: const InputDecoration(labelText: 'Судебный участок', border: OutlineInputBorder(), isDense: true)),
                  const SizedBox(height: 8),
                  TextField(controller: courtAddressCtrl, decoration: const InputDecoration(labelText: 'Адрес суда', border: OutlineInputBorder(), isDense: true)),

                  const SizedBox(height: 16),
                  const Text('Параметры расчёта', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  Row(children: [
                    Expanded(child: TextField(controller: contractDateCtrl, decoration: const InputDecoration(labelText: 'Дата договора', border: OutlineInputBorder(), isDense: true))),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(controller: tariffCtrl, decoration: const InputDecoration(labelText: 'Тариф ₽/м²', border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number)),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: TextField(controller: periodFromCtrl, decoration: const InputDecoration(labelText: 'Период с', border: OutlineInputBorder(), isDense: true))),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(controller: periodToCtrl, decoration: const InputDecoration(labelText: 'Период по', border: OutlineInputBorder(), isDense: true))),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: TextField(controller: representativeCtrl, decoration: const InputDecoration(labelText: 'Представитель', border: OutlineInputBorder(), isDense: true))),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(controller: cityCtrl, decoration: const InputDecoration(labelText: 'Город', border: OutlineInputBorder(), isDense: true))),
                  ]),

                  const SizedBox(height: 16),
                  const Text('Формат выгрузки', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  Row(children: [
                    ChoiceChip(
                      label: const Text('ZIP (отдельные файлы)'),
                      selected: outputFormat == 'zip',
                      onSelected: (_) => setDialogState(() => outputFormat = 'zip'),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Один DOCX'),
                      selected: outputFormat == 'single',
                      onSelected: (_) => setDialogState(() => outputFormat = 'single'),
                    ),
                  ]),

                  const SizedBox(height: 16),
                  const Text('Фильтры', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  CheckboxListTile(
                    dense: true, contentPadding: EdgeInsets.zero,
                    title: const Text('Исключить с обещаниями', style: TextStyle(fontSize: 13)),
                    value: excludePromises,
                    onChanged: (v) => setDialogState(() => excludePromises = v ?? false),
                  ),
                  CheckboxListTile(
                    dense: true, contentPadding: EdgeInsets.zero,
                    title: const Text('Исключить платящих', style: TextStyle(fontSize: 13)),
                    value: excludePayers,
                    onChanged: (v) => setDialogState(() => excludePayers = v ?? false),
                  ),
                  TextField(
                    controller: excludeFioCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Исключить ФИО (через запятую)',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
            FilledButton.icon(
              icon: const Icon(Icons.balance),
              label: const Text('Сформировать'),
              onPressed: () {
                Navigator.pop(ctx, {
                  'org_name': orgNameCtrl.text,
                  'director_title': directorTitleCtrl.text,
                  'director_name': directorNameCtrl.text,
                  'city': cityCtrl.text,
                  'org_address': orgAddressCtrl.text,
                  'org_inn': orgInnCtrl.text,
                  'org_ogrn': orgOgrnCtrl.text,
                  'court_name': courtNameCtrl.text,
                  'court_address': courtAddressCtrl.text,
                  'contract_date': contractDateCtrl.text,
                  'tariff_per_sqm': tariffCtrl.text,
                  'period_from': periodFromCtrl.text,
                  'period_to': periodToCtrl.text,
                  'representative_name': representativeCtrl.text,
                  'bank_name': bankNameCtrl.text,
                  'bik': bikCtrl.text,
                  'bank_account': bankAccountCtrl.text,
                  'corr_account': corrAccountCtrl.text,
                  'output_format': outputFormat,
                  'exclude_promises': excludePromises.toString(),
                  'exclude_payers': excludePayers.toString(),
                  if (excludeFioCtrl.text.trim().isNotEmpty)
                    'exclude_fio': excludeFioCtrl.text.trim(),
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Платежные документы'),
        actions: [
          // Экспорт
          PopupMenuButton<String>(
            icon: _isExporting
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.upload),
            tooltip: 'Экспорт',
            enabled: !_isExporting,
            onSelected: _exportFile,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'excel', child: ListTile(leading: Icon(Icons.table_chart, color: Colors.green), title: Text('Excel (.xlsx)'))),
              const PopupMenuItem(value: 'pdf', child: ListTile(leading: Icon(Icons.picture_as_pdf, color: Colors.red), title: Text('PDF таблица'))),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'dosudebnoye', child: ListTile(leading: Icon(Icons.gavel, color: Colors.orange), title: Text('Досудебное (личное)'))),
              const PopupMenuItem(value: 'obshee-dosudebnoye', child: ListTile(leading: Icon(Icons.list_alt, color: Colors.deepOrange), title: Text('Досудебное (общее)'))),
              const PopupMenuItem(value: 'court-order', child: ListTile(leading: Icon(Icons.balance, color: Colors.indigo), title: Text('Судебный приказ (DOCX)'))),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'baosna-xml', child: ListTile(leading: Icon(Icons.code, color: Colors.teal), title: Text('БАОСНА (XML)'))),
              const PopupMenuItem(value: 'baosna-json', child: ListTile(leading: Icon(Icons.data_object, color: Colors.indigo), title: Text('БАОСНА (JSON)'))),
              const PopupMenuItem(value: 'baosna-xls', child: ListTile(leading: Icon(Icons.grid_on, color: Colors.green), title: Text('БАОСНА (XLS)'))),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Инструкция кассира',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CashierHelpScreen())),
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadDocuments),
        ],
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        final isWide = constraints.maxWidth > 900;
        final horizontalPad = isWide ? 24.0 : 12.0;

        return Column(
          children: [
            // ═══ Поиск ═══
            Padding(
              padding: EdgeInsets.fromLTRB(horizontalPad, 10, horizontalPad, 6),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => _onSearchChanged(),
                decoration: InputDecoration(
                  hintText: 'Поиск по ФИО, лицевому счёту, адресу...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () { _searchController.clear(); _loadDocuments(); },
                        )
                      : null,
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest.withAlpha(50),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: theme.colorScheme.outlineVariant.withAlpha(80)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),

            // ═══ Фильтры ═══
            _buildFilterChips(horizontalPad),

            // ═══ Статистика ═══
            if (_stats.isNotEmpty) _buildStatsBar(isWide, horizontalPad),

            // ═══ Сортировка + количество ═══
            _buildSortBar(horizontalPad),

            // ═══ Список ═══
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
                          const SizedBox(height: 12),
                          Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.refresh),
                            label: const Text('Повторить'),
                            onPressed: _loadDocuments,
                          ),
                        ]))
                      : _documents.isEmpty
                          ? Center(child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                                const SizedBox(height: 12),
                                Text('Документы не найдены', style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                                const SizedBox(height: 4),
                                Text('Попробуйте изменить фильтры', style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                              ],
                            ))
                          : RefreshIndicator(
                              onRefresh: _loadDocuments,
                              child: ListView.builder(
                                padding: EdgeInsets.symmetric(horizontal: isWide ? horizontalPad : 8, vertical: 4),
                                itemCount: _documents.length,
                                itemBuilder: (context, index) => _buildDocumentCard(_documents[index], isWide),
                              ),
                            ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildFilterChips([double horizontalPad = 12]) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: horizontalPad, vertical: 4),
      child: Row(
        children: [
          // Период
          _buildFilterChip(
            label: _selectedPeriod != null ? _formatPeriod(_selectedPeriod!) : 'Период',
            icon: Icons.calendar_month,
            isSelected: _selectedPeriod != null,
            onTap: _showPeriodPicker,
          ),
          const SizedBox(width: 6),
          // Дом
          _buildFilterChip(
            label: _selectedLocationName ?? 'Дом',
            icon: Icons.home,
            isSelected: _selectedLocationId != null,
            onTap: _showLocationPicker,
          ),
          const SizedBox(width: 6),
          // Должники
          FilterChip(
            label: const Text('Должники'),
            avatar: const Icon(Icons.warning_amber, size: 16),
            selected: _hasDebt,
            onSelected: (v) { setState(() { _hasDebt = v; _hasOverpayment = false; }); _loadDocuments(); },
            selectedColor: Colors.red.withAlpha(60),
          ),
          const SizedBox(width: 6),
          // Переплата
          FilterChip(
            label: const Text('Переплата'),
            avatar: const Icon(Icons.check_circle_outline, size: 16),
            selected: _hasOverpayment,
            onSelected: (v) { setState(() { _hasOverpayment = v; _hasDebt = false; }); _loadDocuments(); },
            selectedColor: Colors.green.withAlpha(60),
          ),
          const SizedBox(width: 6),
          // Диапазон долга
          _buildFilterChip(
            label: _minDebt != null || _maxDebt != null
                ? '${_minDebt?.toStringAsFixed(0) ?? '0'} - ${_maxDebt?.toStringAsFixed(0) ?? '∞'} ₽'
                : 'Сумма долга',
            icon: Icons.attach_money,
            isSelected: _minDebt != null || _maxDebt != null,
            onTap: _showDebtRangePicker,
          ),
          // Сброс
          if (_hasActiveFilters()) ...[
            const SizedBox(width: 8),
            ActionChip(
              label: const Text('Сбросить'),
              avatar: const Icon(Icons.clear_all, size: 16),
              onPressed: _clearFilters,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChip({required String label, required IconData icon, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Chip(
        label: Text(label, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : null)),
        avatar: Icon(icon, size: 16, color: isSelected ? Colors.white : null),
        backgroundColor: isSelected ? Colors.blue : null,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Widget _buildStatsBar([bool isWide = false, double horizontalPad = 12]) {
    final debtorsCount = _stats['debtors_count'] ?? 0;
    final totalDebt = (_stats['total_debt'] as num?)?.toDouble() ?? 0;
    final totalCharged = (_stats['total_charged'] as num?)?.toDouble() ?? 0;
    final totalPaid = (_stats['total_paid'] as num?)?.toDouble() ?? 0;

    final theme = Theme.of(context);

    if (isWide) {
      // Desktop — горизонтальные карточки
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPad, vertical: 6),
        child: Row(children: [
          Expanded(child: _statCard('Начислено', totalCharged, Colors.orange, Icons.receipt_long, theme)),
          const SizedBox(width: 10),
          Expanded(child: _statCard('Оплачено', totalPaid, Colors.green, Icons.payments, theme)),
          const SizedBox(width: 10),
          Expanded(child: _statCard('Общий долг', totalDebt, totalDebt > 0 ? Colors.red : Colors.green, Icons.account_balance_wallet, theme)),
          const SizedBox(width: 10),
          Expanded(child: _statCard('Должников', debtorsCount.toDouble(), Colors.red, Icons.people, theme, isCount: true)),
        ]),
      );
    }

    // Mobile — компактная полоска
    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalPad, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(80),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant.withAlpha(60)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Начисл.', totalCharged, Colors.orange, theme: theme),
          _buildStatItem('Оплач.', totalPaid, Colors.green, theme: theme),
          _buildStatItem('Долг', totalDebt, totalDebt > 0 ? Colors.red : Colors.green, theme: theme),
          _buildStatItem('Должн.', debtorsCount.toDouble(), Colors.red, isCount: true, theme: theme),
        ],
      ),
    );
  }

  Widget _statCard(String label, double value, Color color, IconData icon, ThemeData theme, {bool isCount = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withAlpha(15), color.withAlpha(8)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 2),
          Text(
            isCount ? '${value.toInt()}' : '${_formatMoney(value)} ₽',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: color),
            overflow: TextOverflow.ellipsis,
          ),
        ])),
      ]),
    );
  }

  Widget _buildStatItem(String label, double value, Color color, {bool isCount = false, ThemeData? theme}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: theme?.colorScheme.onSurfaceVariant ?? Colors.grey)),
        const SizedBox(height: 2),
        Text(
          isCount ? '${value.toInt()}' : '${_formatMoney(value)} ₽',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildSortBar([double horizontalPad = 12]) {
    final sortLabels = {
      'debt_end': 'Долг',
      'total_charged': 'Начислено',
      'total_paid': 'Оплачено',
      'period': 'Период',
      'fio': 'ФИО',
      'account_number': 'Л/С',
    };

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPad, vertical: 2),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withAlpha(80),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('$_totalCount док.', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600)),
          ),
          const Spacer(),
          Icon(Icons.sort, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          DropdownButton<String>(
            value: _sortBy,
            underline: const SizedBox.shrink(),
            isDense: true,
            style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface),
            items: sortLabels.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
            onChanged: (v) { if (v != null) { setState(() => _sortBy = v); _loadDocuments(); } },
          ),
          IconButton(
            icon: Icon(_sortOrder == 'desc' ? Icons.arrow_downward : Icons.arrow_upward, size: 16),
            onPressed: () { setState(() => _sortOrder = _sortOrder == 'desc' ? 'asc' : 'desc'); _loadDocuments(); },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(Map<String, dynamic> doc, [bool isWide = false]) {
    final totalDebtEnd = (doc['total_debt_end'] as num?)?.toDouble() ?? 0.0;
    final isDebt = totalDebtEnd > 0.01;
    final isOverpaid = totalDebtEnd < -0.01;
    final theme = Theme.of(context);
    final debtColor = isDebt ? Colors.red : isOverpaid ? Colors.green : Colors.grey;

    return Card(
      margin: EdgeInsets.symmetric(vertical: isWide ? 4 : 3),
      elevation: isWide ? 1 : 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: debtColor.withAlpha(isDebt || isOverpaid ? 50 : 0),
          width: isDebt || isOverpaid ? 1 : 0,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () async {
          await Navigator.push(context, MaterialPageRoute(
            builder: (_) => CashierDetailScreen(docId: doc['id']),
          ));
          _loadDocuments();
        },
        child: Padding(
          padding: EdgeInsets.all(isWide ? 16 : 12),
          child: Row(
            children: [
              // Индикатор долга
              Container(
                width: 4, height: isWide ? 56 : 44,
                decoration: BoxDecoration(
                  color: debtColor.withAlpha(isDebt || isOverpaid ? 200 : 80),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: isWide ? 14 : 10),
              // Основная информация
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc['fio'] ?? 'Без имени',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: isWide ? 15 : 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${doc['account_number'] ?? '-'}  •  ${doc['address'] ?? ''}',
                      style: TextStyle(fontSize: isWide ? 12 : 11, color: theme.colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 6),
                    // Мини-баланс
                    Row(
                      children: [
                        _miniTag('Начисл.', doc['total_charged'], Colors.orange),
                        const SizedBox(width: 10),
                        _miniTag('Оплач.', doc['total_paid'], Colors.green),
                        if (isWide) ...[
                          const SizedBox(width: 10),
                          _miniTag('Д.нач', doc['total_debt_start'], Colors.grey),
                          const SizedBox(width: 10),
                          _miniTag('Перер.', doc['total_recalc'], Colors.blue),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: isWide ? 16 : 10),
              // Долг + период
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: debtColor.withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: debtColor.withAlpha(50)),
                    ),
                    child: Text(
                      '${totalDebtEnd.toStringAsFixed(2)} ₽',
                      style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: isWide ? 14 : 13,
                        color: debtColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withAlpha(60),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _formatPeriod(doc['period_date'] ?? ''),
                      style: TextStyle(fontSize: 10, color: theme.colorScheme.primary, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              SizedBox(width: isWide ? 8 : 4),
              Icon(Icons.chevron_right, size: 18, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniTag(String label, dynamic value, Color color) {
    final val = (value as num?)?.toDouble() ?? 0;
    return Row(children: [
      Container(width: 6, height: 6, decoration: BoxDecoration(color: color.withAlpha(150), shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text('$label: ${val.toStringAsFixed(0)}₽', style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500)),
    ]);
  }


  // ═══════ Пикеры для фильтров ═══════

  void _showPeriodPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            title: const Text('Все периоды', style: TextStyle(fontWeight: FontWeight.bold)),
            selected: _selectedPeriod == null,
            onTap: () { setState(() => _selectedPeriod = null); Navigator.pop(ctx); _loadDocuments(); },
          ),
          ..._periods.map((p) => ListTile(
            title: Text(_formatPeriod(p)),
            selected: _selectedPeriod == p,
            onTap: () { setState(() => _selectedPeriod = p); Navigator.pop(ctx); _loadDocuments(); },
          )),
        ],
      ),
    );
  }

  void _showLocationPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            title: const Text('Все дома', style: TextStyle(fontWeight: FontWeight.bold)),
            selected: _selectedLocationId == null,
            onTap: () { setState(() { _selectedLocationId = null; _selectedLocationName = null; }); Navigator.pop(ctx); _loadDocuments(); },
          ),
          ..._locations.map((l) => ListTile(
            title: Text(l['name'] ?? ''),
            subtitle: Text('${l['docs_count'] ?? 0} документов'),
            selected: _selectedLocationId == l['id'],
            onTap: () { setState(() { _selectedLocationId = l['id']; _selectedLocationName = l['name']; }); Navigator.pop(ctx); _loadDocuments(); },
          )),
        ],
      ),
    );
  }

  void _showDebtRangePicker() {
    final minC = TextEditingController(text: _minDebt?.toStringAsFixed(0) ?? '');
    final maxC = TextEditingController(text: _maxDebt?.toStringAsFixed(0) ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Диапазон долга'),
        content: Row(
          children: [
            Expanded(child: TextField(controller: minC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'От (₽)'))),
            const SizedBox(width: 16),
            Expanded(child: TextField(controller: maxC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'До (₽)'))),
          ],
        ),
        actions: [
          TextButton(onPressed: () { setState(() { _minDebt = null; _maxDebt = null; }); Navigator.pop(ctx); _loadDocuments(); }, child: const Text('Сбросить')),
          FilledButton(onPressed: () {
            setState(() {
              _minDebt = double.tryParse(minC.text);
              _maxDebt = double.tryParse(maxC.text);
            });
            Navigator.pop(ctx);
            _loadDocuments();
          }, child: const Text('Применить')),
        ],
      ),
    );
  }

  bool _hasActiveFilters() {
    return _selectedPeriod != null || _selectedLocationId != null || _hasDebt || _hasOverpayment || _minDebt != null || _maxDebt != null || _searchController.text.isNotEmpty;
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedPeriod = null;
      _selectedLocationId = null;
      _selectedLocationName = null;
      _hasDebt = false;
      _hasOverpayment = false;
      _minDebt = null;
      _maxDebt = null;
      _sortBy = 'debt_end';
      _sortOrder = 'desc';
    });
    _loadDocuments();
  }

  // ═══════ Детали документа ═══════






  // ═══════ Утилиты ═══════

  String _formatPeriod(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      const months = ['', 'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь', 'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь'];
      return '${months[date.month]} ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  String _formatMoney(double value) {
    if (value.abs() >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}М';
    if (value.abs() >= 1000) return '${(value / 1000).toStringAsFixed(1)}К';
    return value.toStringAsFixed(0);
  }

  // ═══════ Редактирование документа ═══════


}


