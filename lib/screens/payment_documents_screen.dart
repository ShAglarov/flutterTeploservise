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
    if (_searchController.text.trim().isNotEmpty) params['search'] = _searchController.text.trim();
    if (_hasDebt) params['has_debt'] = true;
    if (_hasOverpayment) params['has_overpayment'] = true;
    if (_minDebt != null) params['min_debt'] = _minDebt;
    if (_maxDebt != null) params['max_debt'] = _maxDebt;
    params['sort_by'] = _sortBy;
    params['sort_order'] = _sortOrder;
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
    Map<String, String> extraParams = {};

    if (isDosudebnoye) {
      final result = await _showDosudebSettings(format);
      if (result == null) return;
      extraParams = result;
    }

    final extMap = {'excel': 'xlsx', 'baosna-xml': 'xml', 'baosna-json': 'json', 'baosna-xls': 'xlsx'};
    final ext = extMap[format] ?? 'pdf';
    final namePrefix = {
      'excel': 'payment_docs',
      'baosna-xml': 'baosna',
      'baosna-json': 'baosna',
      'baosna-xls': 'baosna',
      'pdf': 'payment_docs',
      'dosudebnoye': 'dosudebnoye',
      'obshee-dosudebnoye': 'obshee_dosudebnoye',
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
        await Share.shareXFiles(
          [XFile(tempFile.path, mimeType: ext == 'pdf' ? 'application/pdf' : ext == 'xml' ? 'application/xml' : ext == 'json' ? 'application/json' : 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')],
          subject: defaultName,
        );
        return;
      }

      // macOS / Windows / Linux: диалог «Сохранить как»
      String? savePath;
      try {
        savePath = await FilePicker.platform.saveFile(
          dialogTitle: 'Сохранить $namePrefix',
          fileName: defaultName,
        );
      } catch (_) {
        try {
          final dir = await FilePicker.platform.getDirectoryPath(dialogTitle: 'Выберите папку');
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

    String _buildRequisitesText(Map<String, dynamic> r) {
      final parts = <String>[];
      if (r['bik'] != null && (r['bik'] as String).isNotEmpty) parts.add('БИК: ${r['bik']}');
      if (r['account_number'] != null && (r['account_number'] as String).isNotEmpty) parts.add('Р/с: ${r['account_number']}');
      if (r['inn'] != null && (r['inn'] as String).isNotEmpty) parts.add('ИНН: ${r['inn']}');
      if (r['bank_name'] != null && (r['bank_name'] as String).isNotEmpty) parts.add('Банк: ${r['bank_name']}');
      if (r['corr_account'] != null && (r['corr_account'] as String).isNotEmpty) parts.add('Корр/с: ${r['corr_account']}');
      return parts.join('\n');
    }

    final requisitesCtrl = TextEditingController(text: _buildRequisitesText(defaults));
    final noticeDateCtrl = TextEditingController(
      text: '${DateTime.now().day.toString().padLeft(2, '0')}.${DateTime.now().month.toString().padLeft(2, '0')}.${DateTime.now().year}',
    );

    String? selectedReqId = defaults['id']?.toString();

    final isPersonal = format == 'dosudebnoye';
    final title = isPersonal ? 'Досудебное (личное)' : 'Досудебное (общее)';

    bool excludePromises = true;
    bool excludePayers = true;

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
                          requisitesCtrl.text = _buildRequisitesText(selected);
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
                      overflow: TextOverflow.ellipsis,
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

  Widget _buildMiniStat(String label, dynamic value, Color color) {
    final val = (value as num?)?.toDouble() ?? 0;
    return Text(
      '$label: ${val.toStringAsFixed(0)} ₽',
      style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500),
    );
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

  void _showDocumentDetails(Map<String, dynamic> doc) {
    debugPrint('🔍 DOC RESIDENT: ${doc['resident']}');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85, minChildSize: 0.5, maxChildSize: 0.95, expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              Text(doc['fio'] ?? 'Платежный документ', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text('Период: ${_formatPeriod(doc['period_date'] ?? '')}', style: TextStyle(fontSize: 14, color: Colors.blue[700])),
              if (doc['address'] != null) Text(doc['address'], style: TextStyle(fontSize: 13, color: Colors.grey[600])),
              Text('Л/С: ${doc['account_number'] ?? '-'}', style: TextStyle(fontSize: 13, color: Colors.grey[600])),

              // Информация о жильце
              if (doc['resident'] != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person, size: 18, color: Colors.green[700]),
                          const SizedBox(width: 6),
                          Text('Зарегистрированный жилец', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green[700])),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        doc['resident']['full_name'] ?? doc['resident']['username'] ?? 'Без имени',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                      if (doc['resident']['phone_number'] != null && doc['resident']['phone_number'].toString().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.phone, size: 14, color: Colors.blue),
                            const SizedBox(width: 6),
                            Text(doc['resident']['phone_number'].toString(), style: const TextStyle(fontSize: 14, color: Colors.blue)),
                          ],
                        ),
                      ],
                      if (doc['resident']['email'] != null && doc['resident']['email'].toString().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.email, size: 14, color: Colors.grey),
                            const SizedBox(width: 6),
                            Text(doc['resident']['email'].toString(), style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                          ],
                        ),
                      ],
                      const SizedBox(height: 8),
                      if (doc['resident']['is_blocked'] == true) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(6)),
                          child: const Text('⛔ Жилец заблокирован', style: TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ],
                  ),
                ),
              ] else ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person_outline, size: 16, color: Colors.orange[700]),
                      const SizedBox(width: 6),
                      Text('Нет зарегистрированного жильца', style: TextStyle(fontSize: 13, color: Colors.orange[700])),
                    ],
                  ),
                ),
              ],

              // Обещания из payment_promises
              if (doc['promises'] != null && (doc['promises'] as List).isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.handshake, size: 18, color: Colors.orange[700]),
                          const SizedBox(width: 6),
                          Text('Обещания оплаты', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.orange[700])),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...(doc['promises'] as List).map<Widget>((p) {
                        String dateStr = p['promised_date'] ?? '-';
                        final parsed = DateTime.tryParse(dateStr);
                        if (parsed != null) {
                          dateStr = '${parsed.day.toString().padLeft(2, '0')}.${parsed.month.toString().padLeft(2, '0')}.${parsed.year}';
                        }
                        final statusIcon = p['status'] == 'fulfilled' ? '✅' : p['status'] == 'broken' ? '❌' : '⏳';
                        final statusColor = p['status'] == 'fulfilled' ? Colors.green : p['status'] == 'broken' ? Colors.red : Colors.orange;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text('$statusIcon До $dateStr', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: statusColor)),
                                  if (p['promised_amount'] != null) Text(' — ${p['promised_amount']} ₽', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                ],
                              ),
                              if (p['note'] != null && p['note'].toString().isNotEmpty)
                                Text(p['note'].toString(), style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ] else if (doc['resident'] != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning_amber, size: 16, color: Colors.red[700]),
                      const SizedBox(width: 6),
                      Text('Нет обещания оплатить', style: TextStyle(fontSize: 13, color: Colors.red[700])),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),

              _buildServiceSection('🔥 Отопление', {'Долг на начало': doc['debt_heating_start'], 'Начислено': doc['charged_heating'], 'Оплачено': doc['paid_heating'], 'Перерасчёт': doc['recalc_heating'], 'Долг на конец': doc['debt_heating_end']}),
              _buildServiceSection('💧 ГВС', {'Долг на начало': doc['debt_hot_water_start'], 'Начислено': doc['charged_hot_water'], 'Оплачено': doc['paid_hot_water'], 'Перерасчёт': doc['recalc_hot_water'], 'Долг на конец': doc['debt_hot_water_end']}),
              _buildServiceSection('🏠 Теплообслуживание', {'Долг на начало': doc['debt_maintenance_start'], 'Начислено': doc['charged_maintenance'], 'Оплачено': doc['paid_maintenance'], 'Перерасчёт': doc['recalc_maintenance'], 'Долг на конец': doc['debt_maintenance_end']}),
              _buildServiceSection('🗑 ТБО', {'Долг на начало': doc['debt_waste_start'], 'Начислено': doc['charged_waste'], 'Оплачено': doc['paid_waste'], 'Перерасчёт': doc['recalc_waste'], 'Долг на конец': doc['debt_waste_end']}),
              _buildServiceSection('⚡ ОДН Электричество', {'Долг на начало': doc['debt_odn_electricity_start'], 'Начислено': doc['charged_odn_electricity'], 'Оплачено': doc['paid_odn_electricity'], 'Перерасчёт': doc['recalc_odn_electricity'], 'Долг на конец': doc['debt_odn_electricity_end']}),
              _buildServiceSection('💧 ОДН Вода', {'Долг на начало': doc['debt_odn_water_start'], 'Начислено': doc['charged_odn_water'], 'Оплачено': doc['paid_odn_water'], 'Перерасчёт': doc['recalc_odn_water'], 'Долг на конец': doc['debt_odn_water_end']}),

              const Divider(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('📊 Итого', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    _buildDetailRow('Общий долг на начало', doc['total_debt_start']),
                    _buildDetailRow('Общее начисление', doc['total_charged']),
                    _buildDetailRow('Общая оплата', doc['total_paid']),
                    _buildDetailRow('Общий долг на конец', doc['total_debt_end'], isBold: true),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Кнопки действий
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      icon: const Icon(Icons.payments),
                      label: const Text('Внести оплату'),
                      style: FilledButton.styleFrom(backgroundColor: Colors.green),
                      onPressed: () {
                        Navigator.pop(context);
                        _showPaymentDialog(doc);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text('Редактировать'),
                      onPressed: () {
                        Navigator.pop(context);
                        _editDocument(doc);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Кнопка обещания
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.handshake),
                  label: Text(doc['resident']?['promise_to_pay'] == true ? 'Редактировать обещание' : 'Добавить обещание оплатить'),
                  style: FilledButton.styleFrom(backgroundColor: Colors.orange),
                  onPressed: () {
                    Navigator.pop(context);
                    _showPromiseDialog(doc);
                  },
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showPromiseDialog(Map<String, dynamic> doc) async {
    final resident = doc['resident'] as Map<String, dynamic>?;
    final promises = (doc['promises'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final latestPromise = promises.isNotEmpty ? promises.first : null;
    final hasPromise = latestPromise != null && latestPromise['status'] == 'pending';
    
    DateTime selectedDate = DateTime.now();
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    
    if (hasPromise) {
      final parsed = DateTime.tryParse(latestPromise['promised_date']?.toString() ?? '');
      if (parsed != null) selectedDate = parsed;
      if (latestPromise['promised_amount'] != null) amountCtrl.text = latestPromise['promised_amount'].toString();
      if (latestPromise['note'] != null) noteCtrl.text = latestPromise['note'].toString();
    }

    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setDialogState) {
          return AlertDialog(
            title: Text(hasPromise ? '✏️ Редактировать обещание' : '🤝 Обещание оплаты'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (resident != null)
                    Text('Жилец: ${resident['full_name'] ?? resident['username'] ?? '-'}', style: const TextStyle(fontWeight: FontWeight.w600)),
                  if (doc['account_number'] != null)
                    Text('Л/С: ${doc['account_number']}', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: selectedDate,
                        firstDate: DateTime.now().subtract(const Duration(days: 30)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setDialogState(() => selectedDate = picked);
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: '📅 До какого числа обещает оплатить',
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        '${selectedDate.day.toString().padLeft(2, '0')}.${selectedDate.month.toString().padLeft(2, '0')}.${selectedDate.year}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: amountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Сумма (необязательно)', border: OutlineInputBorder(), suffixText: '₽'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: noteCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Заметка / Комментарий', border: OutlineInputBorder()),
                  ),
                ],
              ),
            ),
            actions: [
              if (hasPromise)
                TextButton(
                  onPressed: () => Navigator.pop(ctx, {'remove': true}),
                  child: const Text('Удалить', style: TextStyle(color: Colors.red)),
                ),
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, {
                  'date': selectedDate,
                  'amount': amountCtrl.text,
                  'note': noteCtrl.text,
                }),
                child: const Text('Сохранить'),
              ),
            ],
          );
        });
      },
    );

    if (result == null) return;

    try {
      final dio = ref.read(dioProvider);
      final accountId = doc['account_id'];
      
      if (result['remove'] == true) {
        if (hasPromise && latestPromise['id'] != null) {
          await dio.delete('/activity-monitor/promises/${latestPromise['id']}');
        }
        if (resident != null) {
          await dio.put('/residents/${resident['id']}', data: {
            'promise_to_pay': false,
            'promise_date': null,
          });
        }
      } else {
        final date = result['date'] as DateTime;
        final isoDate = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        
        if (hasPromise && latestPromise['id'] != null) {
          await dio.put('/activity-monitor/promises/${latestPromise['id']}', data: {
            'promised_date': isoDate,
            if (result['amount'].toString().isNotEmpty) 'promised_amount': double.tryParse(result['amount']),
            'note': result['note'],
          });
        } else {
          await dio.post('/activity-monitor/promises', data: {
            'account_id': accountId,
            'promised_date': isoDate,
            if (result['amount'].toString().isNotEmpty) 'promised_amount': double.tryParse(result['amount']),
            if (result['note'].toString().isNotEmpty) 'note': result['note'],
          });
        }
        
        if (resident != null) {
          await dio.put('/residents/${resident['id']}', data: {
            'promise_to_pay': true,
            'promise_date': isoDate,
          });
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Обещание обновлено'), backgroundColor: Colors.green));
      }
      _loadDocuments();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ Ошибка: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _showPaymentDialog(Map<String, dynamic> doc) async {
    final docId = doc['id'];
    if (docId == null) return;

    final services = <String, _PaySvc>{
      'heating': _PaySvc('🔥 Отопление', doc['debt_heating_end']),
      'hot_water': _PaySvc('💧 ГВС', doc['debt_hot_water_end']),
      'maintenance': _PaySvc('🏠 Теплообсл.', doc['debt_maintenance_end']),
      'waste': _PaySvc('🗑 ТБО', doc['debt_waste_end']),
      'odn_electricity': _PaySvc('⚡ ОДН Эл.', doc['debt_odn_electricity_end']),
      'odn_water': _PaySvc('💧 ОДН Вода', doc['debt_odn_water_end']),
    };

    final controllers = <String, TextEditingController>{};
    for (final key in services.keys) {
      controllers[key] = TextEditingController();
    }
    final noteCtrl = TextEditingController();

    // «Оплатить всё» — заполняет поля суммами долгов
    void fillAll() {
      for (final entry in services.entries) {
        final debt = (entry.value.debt as num?)?.toDouble() ?? 0;
        if (debt > 0) {
          controllers[entry.key]!.text = debt.toStringAsFixed(2);
        }
      }
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.payments, color: Colors.green),
            const SizedBox(width: 8),
            const Expanded(child: Text('Внести оплату')),
            TextButton(onPressed: fillAll, child: const Text('Оплатить всё')),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${doc['fio'] ?? ''} | Л/С: ${doc['account_number'] ?? ''}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 12),
                for (final entry in services.entries)
                  if (((entry.value.debt as num?)?.toDouble() ?? 0) > 0.01 ||
                      ((entry.value.debt as num?)?.toDouble() ?? 0) < -0.01)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: TextField(
                        controller: controllers[entry.key],
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: entry.value.label,
                          hintText: 'Долг: ${((entry.value.debt as num?)?.toDouble() ?? 0).toStringAsFixed(2)} ₽',
                          prefixIcon: const Icon(Icons.attach_money, size: 18),
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                const Divider(),
                TextField(
                  controller: noteCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Комментарий (необязательно)',
                    prefixIcon: Icon(Icons.note, size: 18),
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
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('💰 Оплатить'),
          ),
        ],
      ),
    );

    if (result != true) return;

    // Собираем суммы
    final body = <String, dynamic>{};
    double total = 0;
    for (final entry in controllers.entries) {
      final val = double.tryParse(entry.value.text.replaceAll(',', '.')) ?? 0;
      if (val > 0) {
        body['paid_${entry.key}'] = val;
        total += val;
      }
    }
    if (noteCtrl.text.isNotEmpty) body['note'] = noteCtrl.text;

    if (total <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Введите хотя бы одну сумму'), backgroundColor: Colors.orange),
        );
      }
      return;
    }

    try {
      final dio = ref.read(dioProvider);
      final resp = await dio.post('/payment-documents/$docId/pay', data: body);
      if (resp.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('✅ Оплата ${total.toStringAsFixed(2)} ₽ внесена'), backgroundColor: Colors.green),
          );
        }
        _loadDocuments(); // обновляем список
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Ошибка: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildServiceSection(String title, Map<String, dynamic> values) {
    final hasNonZero = values.values.any((v) => (v as num?)?.toDouble() != 0.0);
    if (!hasNonZero) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 4),
        ...values.entries.map((e) => _buildDetailRow(e.key, e.value)),
        const Divider(height: 8),
      ],
    );
  }

  Widget _buildDetailRow(String label, dynamic value, {bool isBold = false}) {
    final numValue = (value as num?)?.toDouble() ?? 0.0;
    final isNegative = numValue < 0;
    final isPositive = numValue > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(
            '${numValue.toStringAsFixed(2)} ₽',
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: (label.contains('Долг на конец') || label.contains('Общий долг на конец'))
                  ? (isPositive ? Colors.red : isNegative ? Colors.green : Colors.grey)
                  : null,
            ),
          ),
        ],
      ),
    );
  }

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

  void _editDocument(Map<String, dynamic> doc) {
    final docId = doc['id'];
    if (docId == null) return;

    // Определяем все редактируемые поля
    final editableFields = <String, List<_EditField>>{
      '🔥 Отопление': [
        _EditField('debt_heating_start', 'Долг на начало', doc['debt_heating_start']),
        _EditField('charged_heating', 'Начислено', doc['charged_heating']),
        _EditField('paid_heating', 'Оплачено', doc['paid_heating']),
        _EditField('recalc_heating', 'Перерасчёт', doc['recalc_heating']),
        _EditField('debt_heating_end', 'Долг на конец', doc['debt_heating_end']),
      ],
      '💧 ГВС': [
        _EditField('debt_hot_water_start', 'Долг на начало', doc['debt_hot_water_start']),
        _EditField('charged_hot_water', 'Начислено', doc['charged_hot_water']),
        _EditField('paid_hot_water', 'Оплачено', doc['paid_hot_water']),
        _EditField('recalc_hot_water', 'Перерасчёт', doc['recalc_hot_water']),
        _EditField('debt_hot_water_end', 'Долг на конец', doc['debt_hot_water_end']),
      ],
      '🏠 Теплообслуживание': [
        _EditField('debt_maintenance_start', 'Долг на начало', doc['debt_maintenance_start']),
        _EditField('charged_maintenance', 'Начислено', doc['charged_maintenance']),
        _EditField('paid_maintenance', 'Оплачено', doc['paid_maintenance']),
        _EditField('recalc_maintenance', 'Перерасчёт', doc['recalc_maintenance']),
        _EditField('debt_maintenance_end', 'Долг на конец', doc['debt_maintenance_end']),
      ],
      '🗑 ТБО': [
        _EditField('debt_waste_start', 'Долг на начало', doc['debt_waste_start']),
        _EditField('charged_waste', 'Начислено', doc['charged_waste']),
        _EditField('paid_waste', 'Оплачено', doc['paid_waste']),
        _EditField('recalc_waste', 'Перерасчёт', doc['recalc_waste']),
        _EditField('debt_waste_end', 'Долг на конец', doc['debt_waste_end']),
      ],
      '⚡ ОДН Электричество': [
        _EditField('debt_odn_electricity_start', 'Долг на начало', doc['debt_odn_electricity_start']),
        _EditField('charged_odn_electricity', 'Начислено', doc['charged_odn_electricity']),
        _EditField('paid_odn_electricity', 'Оплачено', doc['paid_odn_electricity']),
        _EditField('recalc_odn_electricity', 'Перерасчёт', doc['recalc_odn_electricity']),
        _EditField('debt_odn_electricity_end', 'Долг на конец', doc['debt_odn_electricity_end']),
      ],
      '💧 ОДН Вода': [
        _EditField('debt_odn_water_start', 'Долг на начало', doc['debt_odn_water_start']),
        _EditField('charged_odn_water', 'Начислено', doc['charged_odn_water']),
        _EditField('paid_odn_water', 'Оплачено', doc['paid_odn_water']),
        _EditField('recalc_odn_water', 'Перерасчёт', doc['recalc_odn_water']),
        _EditField('debt_odn_water_end', 'Долг на конец', doc['debt_odn_water_end']),
      ],
    };

    // Создаём контроллеры для всех полей
    final controllers = <String, TextEditingController>{};
    for (final section in editableFields.values) {
      for (final field in section) {
        controllers[field.key] = TextEditingController(
          text: ((field.value as num?)?.toDouble() ?? 0.0).toStringAsFixed(2),
        );
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => Scaffold(
          appBar: AppBar(
            title: Text('Редактирование — ${doc['fio'] ?? ''}'),
            actions: [
              TextButton.icon(
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text('Сохранить', style: TextStyle(color: Colors.white)),
                onPressed: () async {
                  final updates = <String, dynamic>{};
                  for (final entry in controllers.entries) {
                    updates[entry.key] = double.tryParse(entry.value.text) ?? 0.0;
                  }
                  final success = await _updateDocument(docId, updates);
                  if (success && ctx.mounted) {
                    Navigator.pop(ctx);
                    _loadDocuments();
                  }
                },
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Инфо
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(doc['fio'] ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('Л/С: ${doc['account_number'] ?? '-'}', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                      Text('Период: ${_formatPeriod(doc['period_date'] ?? '')}', style: TextStyle(fontSize: 13, color: Colors.blue.shade700)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Секции полей
              ...editableFields.entries.map((section) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(section.key, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    ...section.value.map((field) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: TextField(
                          controller: controllers[field.key],
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: field.label,
                            suffixText: '₽',
                            border: const OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      );
                    }),
                    const Divider(),
                  ],
                );
              }),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );

    // Cleanup
    // Controllers will be disposed when the route is popped
  }

  Future<bool> _updateDocument(int docId, Map<String, dynamic> updates) async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.put('/payment-documents/$docId', data: updates);
      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Документ обновлён'), backgroundColor: Colors.green),
          );
        }
        return true;
      }
      return false;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Ошибка: $e'), backgroundColor: Colors.red),
        );
      }
      return false;
    }
  }
}

class _EditField {
  final String key;
  final String label;
  final dynamic value;
  _EditField(this.key, this.label, this.value);
}

class _PaySvc {
  final String label;
  final dynamic debt;
  _PaySvc(this.label, this.debt);
}
