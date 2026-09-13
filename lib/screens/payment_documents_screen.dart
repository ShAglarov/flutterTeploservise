import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../services/base_api_service.dart';

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

    final ext = format == 'excel' ? 'xlsx' : 'pdf';
    final namePrefix = {
      'excel': 'payment_docs',
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
          [XFile(tempFile.path, mimeType: ext == 'pdf' ? 'application/pdf' : 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')],
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
    // Загружаем реквизиты по умолчанию с сервера
    Map<String, dynamic> defaults = {};
    try {
      final dio = ref.read(dioProvider);
      final resp = await dio.get('/org-requisites/default');
      if (resp.statusCode == 200) defaults = resp.data as Map<String, dynamic>;
    } catch (_) {}

    final deadlineCtrl = TextEditingController(text: '20.10.2026');
    final orgNameCtrl = TextEditingController(text: (defaults['org_name'] as String?) ?? 'ООО УК "СТАНДАРТ СЕРВИС"');
    final directorTitleCtrl = TextEditingController(text: (defaults['director_title'] as String?) ?? 'Генеральный директор');
    final directorNameCtrl = TextEditingController(text: (defaults['director_name'] as String?) ?? 'Агларов Ш.Р.');
    // Формируем строку реквизитов
    final reqParts = <String>[];
    if (defaults['bik'] != null && (defaults['bik'] as String).isNotEmpty) reqParts.add('БИК: ${defaults['bik']}');
    if (defaults['account_number'] != null && (defaults['account_number'] as String).isNotEmpty) reqParts.add('Р/с: ${defaults['account_number']}');
    if (defaults['inn'] != null && (defaults['inn'] as String).isNotEmpty) reqParts.add('ИНН: ${defaults['inn']}');
    if (defaults['bank_name'] != null && (defaults['bank_name'] as String).isNotEmpty) reqParts.add('Банк: ${defaults['bank_name']}');
    if (defaults['corr_account'] != null && (defaults['corr_account'] as String).isNotEmpty) reqParts.add('Корр/с: ${defaults['corr_account']}');
    final requisitesCtrl = TextEditingController(text: reqParts.join('\n'));
    final noticeDateCtrl = TextEditingController(
      text: '${DateTime.now().day.toString().padLeft(2, '0')}.${DateTime.now().month.toString().padLeft(2, '0')}.${DateTime.now().year}',
    );
    final cityCtrl = TextEditingController(text: 'г. Махачкала');

    final isPersonal = format == 'dosudebnoye';
    final title = isPersonal ? 'Досудебное (личное)' : 'Досудебное (общее)';

    return showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('⚖️ $title'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
              });
            },
          ),
        ],
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
            ],
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadDocuments),
        ],
      ),
      body: Column(
        children: [
          // ═══ Строка поиска ═══
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _onSearchChanged(),
              decoration: InputDecoration(
                hintText: 'Поиск по ФИО, Л/С, адресу...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () { _searchController.clear(); _loadDocuments(); },
                      )
                    : null,
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // ═══ Фильтры ═══
          _buildFilterChips(),

          // ═══ Статистика ═══
          if (_stats.isNotEmpty) _buildStatsBar(),

          // ═══ Сортировка + количество ═══
          _buildSortBar(),

          // ═══ Список ═══
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text(_error!, style: TextStyle(color: theme.colorScheme.error)))
                    : _documents.isEmpty
                        ? const Center(child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.search_off, size: 64, color: Colors.grey),
                              SizedBox(height: 12),
                              Text('Документы не найдены', style: TextStyle(fontSize: 16, color: Colors.grey)),
                              Text('Попробуйте изменить фильтры', style: TextStyle(fontSize: 13, color: Colors.grey)),
                            ],
                          ))
                        : RefreshIndicator(
                            onRefresh: _loadDocuments,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              itemCount: _documents.length,
                              itemBuilder: (context, index) => _buildDocumentCard(_documents[index]),
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
            selectedColor: Colors.red.withValues(alpha: 0.3),
          ),
          const SizedBox(width: 6),
          // Переплата
          FilterChip(
            label: const Text('Переплата'),
            avatar: const Icon(Icons.check_circle_outline, size: 16),
            selected: _hasOverpayment,
            onSelected: (v) { setState(() { _hasOverpayment = v; _hasDebt = false; }); _loadDocuments(); },
            selectedColor: Colors.green.withValues(alpha: 0.3),
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

  Widget _buildStatsBar() {
    final debtorsCount = _stats['debtors_count'] ?? 0;
    final totalDebt = (_stats['total_debt'] as num?)?.toDouble() ?? 0;
    final totalCharged = (_stats['total_charged'] as num?)?.toDouble() ?? 0;
    final totalPaid = (_stats['total_paid'] as num?)?.toDouble() ?? 0;

    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
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

  Widget _buildSortBar() {
    final sortLabels = {
      'debt_end': 'Долг',
      'total_charged': 'Начислено',
      'total_paid': 'Оплачено',
      'period': 'Период',
      'fio': 'ФИО',
      'account_number': 'Л/С',
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Row(
        children: [
          Text('$_totalCount док.', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500)),
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

  Widget _buildDocumentCard(Map<String, dynamic> doc) {
    final totalDebtEnd = (doc['total_debt_end'] as num?)?.toDouble() ?? 0.0;
    final isDebt = totalDebtEnd > 0.01;
    final isOverpaid = totalDebtEnd < -0.01;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 3),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDebt ? Colors.red.shade200 : isOverpaid ? Colors.green.shade200 : Colors.transparent,
          width: isDebt || isOverpaid ? 1 : 0,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showDocumentDetails(doc),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Индикатор долга
                  Container(
                    width: 4, height: 40,
                    decoration: BoxDecoration(
                      color: isDebt ? Colors.red : isOverpaid ? Colors.green : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doc['fio'] ?? 'Без имени',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${doc['account_number'] ?? '-'}  •  ${doc['address'] ?? ''}',
                          style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isDebt
                              ? Colors.red.withValues(alpha: 0.15)
                              : isOverpaid
                                  ? Colors.green.withValues(alpha: 0.15)
                                  : Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${totalDebtEnd.toStringAsFixed(2)} ₽',
                          style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13,
                            color: isDebt ? Colors.red : isOverpaid ? Colors.green : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatPeriod(doc['period_date'] ?? ''),
                        style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.primary),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Мини-баланс
              Row(
                children: [
                  const SizedBox(width: 14),
                  _buildMiniStat('Начисл.', doc['total_charged'], Colors.orange),
                  const SizedBox(width: 16),
                  _buildMiniStat('Оплач.', doc['total_paid'], Colors.green),
                  const SizedBox(width: 16),
                  _buildMiniStat('Долг нач.', doc['total_debt_start'], Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
              // Кнопка редактирования
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text('Редактировать'),
                  onPressed: () {
                    Navigator.pop(context); // close detail sheet
                    _editDocument(doc);
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
