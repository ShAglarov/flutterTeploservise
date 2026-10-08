import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/api_models.dart';
import '../services/file_export_helper.dart';
import '../services/incident_report_service.dart';
import '../services/user_service.dart';
import '../utils/app_theme.dart';

final shiftsProvider = FutureProvider<List<ShiftInfo>>((ref) async {
  return ref.watch(incidentReportServiceProvider).getShifts();
});

/// Сотрудники — для выбора диспетчера смены и главного инженера.
final reportStaffProvider = FutureProvider<List<APIUserResponse>>((ref) async {
  return ref.watch(userServiceProvider).getAllUsers();
});

/// Отчёты по инцидентам.
///
/// Главный сценарий — сдача дежурства: диспетчер работает с 12:00 до 12:00
/// и должен отчитаться главному инженеру, что происходило за смену. Поэтому
/// кнопка отчёта за текущую смену стоит первой и не требует настроек.
class IncidentReportsScreen extends ConsumerStatefulWidget {
  const IncidentReportsScreen({super.key});

  @override
  ConsumerState<IncidentReportsScreen> createState() =>
      _IncidentReportsScreenState();
}

class _IncidentReportsScreenState extends ConsumerState<IncidentReportsScreen> {
  bool _busy = false;
  DateTimeRange? _range;
  String? _statusFilter;

  /// Кто подписывает отчёт. Выбирается из списка сотрудников: выгрузить
  /// может один человек, а подписывают дежурный и инженер.
  APIUserResponse? _dispatcher;
  APIUserResponse? _engineer;

  static const _pdfMime = 'application/pdf';

  Future<void> _exportShift({
    String? shiftDate,
    required String label,
    bool compact = false,
  }) async {
    setState(() => _busy = true);
    try {
      final service = ref.read(incidentReportServiceProvider);
      final file = await service.downloadShiftPdf(
        shiftDate: shiftDate,
        compact: compact,
        dispatcherId: _dispatcher?.id,
        engineerId: _engineer?.id,
      );
      await _share(file, label);
    } catch (e) {
      _toast(_errorText(e), AppTheme.errorRed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _exportPeriod() async {
    final range = _range;
    if (range == null) {
      _toast('Выберите период', AppTheme.warningOrange);
      return;
    }
    setState(() => _busy = true);
    try {
      final file = await ref.read(incidentReportServiceProvider).downloadPeriodPdf(
            from: range.start,
            to: range.end,
            status: _statusFilter,
          );
      await _share(file, 'Отчёт по инцидентам');
    } catch (e) {
      _toast(_errorText(e), AppTheme.errorRed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _share(File file, String subject) async {
    await FileExportHelper.exportFile(
      sourceFile: file,
      fileName: file.uri.pathSegments.last,
      mimeType: _pdfMime,
      subject: subject,
    );
    _toast('Отчёт готов', AppTheme.successGreen);
  }

  /// Предпросмотр: диспетчер видит цифры до выгрузки и понимает, что
  /// отчёт не пустой и в нём есть незакрытые аварии.
  Future<void> _preview({String? shiftDate}) async {
    setState(() => _busy = true);
    try {
      final service = ref.read(incidentReportServiceProvider);
      final ReportSummary summary;
      if (shiftDate != null || _range == null) {
        summary = await service.shiftSummary(shiftDate: shiftDate);
      } else {
        summary = await service.periodSummary(
          from: _range!.start,
          to: _range!.end,
          status: _statusFilter,
        );
      }
      if (mounted) await _showSummary(summary, shiftDate: shiftDate);
    } catch (e) {
      _toast(_errorText(e), AppTheme.errorRed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _showSummary(ReportSummary s, {String? shiftDate}) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        builder: (ctx, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            Text(s.title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(s.periodLabel,
                style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(ctx).colorScheme.onSurface.withAlpha(150))),
            const SizedBox(height: 14),
            _stat('Всего инцидентов', s.total, AppTheme.primaryBlue),
            if (s.inherited > 0)
              _stat('Принято с прошлой смены', s.inherited, AppTheme.warningOrange),
            _stat('Завершено', s.finished, AppTheme.successGreen),
            _stat('Осталось активными', s.stillActive,
                s.stillActive > 0 ? AppTheme.errorRed : AppTheme.successGreen),
            _stat('Аварий на котельных', s.boilerFailures, AppTheme.errorRed),
            if (s.plannedWorks > 0)
              _stat('Плановых работ', s.plannedWorks, AppTheme.primaryBlue),
            _stat('Домов затронуто', s.housesAffected, AppTheme.primaryBlue),
            if (s.residentsAffected > 0)
              _stat('Жителей затронуто', s.residentsAffected, AppTheme.primaryBlue),
            if (s.incidents.isNotEmpty) ...[
              const SizedBox(height: 14),
              const Text('Инциденты',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 6),
              ...s.incidents.map((i) => _incidentTile(ctx, i)),
            ] else ...[
              const SizedBox(height: 20),
              Center(
                child: Text('За период инцидентов не было',
                    style: TextStyle(
                        color: Theme.of(ctx).colorScheme.onSurface.withAlpha(150))),
              ),
            ],
            const SizedBox(height: 18),
            SizedBox(
              height: 46,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  if (shiftDate != null || _range == null) {
                    _exportShift(shiftDate: shiftDate, label: s.title);
                  } else {
                    _exportPeriod();
                  }
                },
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: const Text('Выгрузить PDF'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _incidentTile(BuildContext ctx, Map<String, dynamic> i) {
    final active = i['still_active'] == true;
    final inherited = i['inherited'] == true;
    final cs = Theme.of(ctx).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 7, height: 7,
            margin: const EdgeInsets.only(top: 5, right: 8),
            decoration: BoxDecoration(
              color: active ? AppTheme.errorRed : AppTheme.successGreen,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${i['title']}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                Text(
                  [
                    '${i['boiler_house']}',
                    '${i['services']}',
                    '${i['duration']}',
                    if (inherited) 'принят с прошлой смены',
                  ].join(' · '),
                  style: TextStyle(fontSize: 11, color: cs.onSurface.withAlpha(150)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, int value, Color color) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            Container(width: 8, height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
            Text('$value',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
      );

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 1, 12, 31),
      initialDateRange: _range ??
          DateTimeRange(start: now.subtract(const Duration(days: 7)), end: now),
      helpText: 'Период отчёта',
      saveText: 'Выбрать',
    );
    if (picked != null) setState(() => _range = picked);
  }

  void _toast(String text, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text),
      backgroundColor: color,
      duration: const Duration(seconds: 4),
    ));
  }

  String _errorText(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      String? detail;
      if (data is Map) detail = data['detail']?.toString();
      if (detail != null && detail.startsWith('permission_denied')) {
        return 'Нет права на просмотр отчётов';
      }
      if (e.response?.statusCode == 503) {
        return detail ?? 'На сервере не настроен шрифт для PDF';
      }
      return detail ?? e.message ?? 'Ошибка сети';
    }
    return e.toString();
  }

  @override
  Widget build(BuildContext context) {
    final shifts = ref.watch(shiftsProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Отчёты по инцидентам'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _busy ? null : () => ref.invalidate(shiftsProvider),
          ),
        ],
      ),
      body: shifts.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 42, color: AppTheme.errorRed),
                const SizedBox(height: 12),
                Text(_errorText(e), textAlign: TextAlign.center),
                const SizedBox(height: 14),
                OutlinedButton(
                  onPressed: () => ref.invalidate(shiftsProvider),
                  child: const Text('Повторить'),
                ),
              ],
            ),
          ),
        ),
        data: (list) {
          final current = list.isNotEmpty ? list.first : null;
          final past = list.length > 1 ? list.sublist(1) : const <ShiftInfo>[];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (current != null) _currentShiftCard(current, cs),
              const SizedBox(height: 22),
              _sectionTitle('Прошлые смены'),
              if (past.isEmpty)
                Text('Пока нет данных',
                    style: TextStyle(fontSize: 12, color: cs.onSurface.withAlpha(150)))
              else
                ...past.map((s) => _shiftTile(s, cs)),
              const SizedBox(height: 22),
              _sectionTitle('Отчёт за период'),
              _periodCard(cs),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: Theme.of(context).colorScheme.onSurface.withAlpha(140),
          ),
        ),
      );

  Widget _currentShiftCard(ShiftInfo s, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryBlue.withAlpha(30), cs.surfaceContainerHighest],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.primaryBlue.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.badge_outlined, size: 18, color: AppTheme.primaryBlue),
              const SizedBox(width: 8),
              Text('Текущее дежурство',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600, color: cs.onSurface)),
            ],
          ),
          const SizedBox(height: 6),
          Text(s.label,
              style: TextStyle(fontSize: 12, color: cs.onSurface.withAlpha(175))),
          const SizedBox(height: 12),
          Wrap(
            spacing: 14,
            runSpacing: 6,
            children: [
              _chip('инцидентов', s.total, AppTheme.primaryBlue),
              _chip('аварий', s.boilerFailures, AppTheme.errorRed),
              _chip('домов', s.housesAffected, AppTheme.warningOrange),
              _chip('не закрыто', s.stillActive,
                  s.stillActive > 0 ? AppTheme.errorRed : AppTheme.successGreen),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: FilledButton.icon(
                    onPressed: _busy ? null : () => _preview(),
                    icon: _busy
                        ? const SizedBox(
                            width: 14, height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.description_outlined, size: 18),
                    label: const Text('Отчёт за дежурство'),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 44,
                child: OutlinedButton(
                  onPressed: _busy
                      ? null
                      : () => _exportShift(label: 'Отчёт о дежурстве'),
                  child: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Краткая форма: один лист, по котельным. Отдельной кнопкой —
          // полный отчёт остаётся как был.
          SizedBox(
            height: 40,
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _busy
                  ? null
                  : () => _exportShift(
                        label: 'Краткий отчёт о дежурстве',
                        compact: true,
                      ),
              icon: const Icon(Icons.table_rows_outlined, size: 17),
              label: const Text('Краткий отчёт (на один лист)'),
            ),
          ),
          const SizedBox(height: 10),
          _staffPickers(cs),
        ],
      ),
    );
  }

  /// Выбор диспетчера смены и главного инженера для подписей в отчёте.
  Widget _staffPickers(ColorScheme cs) {
    final staff = ref.watch(reportStaffProvider);
    return staff.when(
      loading: () => const SizedBox(
        height: 18,
        child: Center(
          child: SizedBox(
              width: 14, height: 14,
              child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      ),
      error: (e, _) => Text('Не удалось загрузить сотрудников',
          style: TextStyle(fontSize: 11, color: cs.onSurface.withAlpha(140))),
      data: (users) {
        final sorted = [...users]..sort(
            (a, b) => a.formattedDisplayName.compareTo(b.formattedDisplayName));
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Подписи в отчёте',
                style: TextStyle(
                    fontSize: 11, color: cs.onSurface.withAlpha(150))),
            const SizedBox(height: 6),
            _staffDropdown(
              label: 'Диспетчер смены',
              value: _dispatcher,
              users: sorted,
              onChanged: (u) => setState(() => _dispatcher = u),
            ),
            const SizedBox(height: 6),
            _staffDropdown(
              label: 'Главный инженер',
              value: _engineer,
              users: sorted,
              onChanged: (u) => setState(() => _engineer = u),
            ),
          ],
        );
      },
    );
  }

  Widget _staffDropdown({
    required String label,
    required APIUserResponse? value,
    required List<APIUserResponse> users,
    required ValueChanged<APIUserResponse?> onChanged,
  }) {
    return DropdownButtonFormField<int?>(
      // Храним id, а не объект: после обновления списка приходят новые
      // экземпляры, и сравнение по ссылке сбрасывало бы выбор.
      initialValue: value?.id,
      isDense: true,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        border: const OutlineInputBorder(),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      ),
      style: const TextStyle(fontSize: 12.5),
      items: [
        const DropdownMenuItem<int?>(
            value: null,
            child: Text('не выбран', style: TextStyle(fontSize: 12.5))),
        ...users.map((u) => DropdownMenuItem<int?>(
              value: u.id,
              child: Text(u.formattedDisplayName,
                  style: const TextStyle(fontSize: 12.5),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            )),
      ],
      onChanged: _busy
          ? null
          : (id) => onChanged(
              id == null ? null : users.firstWhere((u) => u.id == id)),
    );
  }

  Widget _chip(String label, int value, Color color) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$value',
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(150))),
        ],
      );

  Widget _shiftTile(ShiftInfo s, ColorScheme cs) {
    final empty = s.total == 0;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        dense: true,
        onTap: _busy ? null : () => _preview(shiftDate: s.shiftDate),
        leading: Icon(
          empty ? Icons.check_circle_outline : Icons.warning_amber_rounded,
          color: empty ? cs.onSurface.withAlpha(90) : AppTheme.warningOrange,
          size: 20,
        ),
        title: Text(s.label, style: const TextStyle(fontSize: 12.5)),
        subtitle: Text(
          empty
              ? 'инцидентов не было'
              : 'инцидентов ${s.total} · аварий ${s.boilerFailures} · '
                  'домов ${s.housesAffected}'
                  '${s.stillActive > 0 ? " · не закрыто ${s.stillActive}" : ""}',
          style: TextStyle(fontSize: 11, color: cs.onSurface.withAlpha(150)),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Краткая форма доступна и для прошлых смен: отчёт за
            // вчерашнее дежурство нужен так же часто.
            IconButton(
              icon: const Icon(Icons.table_rows_outlined, size: 17),
              tooltip: 'Краткий отчёт',
              onPressed: _busy
                  ? null
                  : () => _exportShift(
                        shiftDate: s.shiftDate,
                        label: 'Краткий отчёт о дежурстве',
                        compact: true,
                      ),
            ),
            IconButton(
              icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
              tooltip: 'Полный отчёт PDF',
              onPressed: _busy
                  ? null
                  : () => _exportShift(
                      shiftDate: s.shiftDate, label: 'Отчёт о дежурстве'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _periodCard(ColorScheme cs) {
    final range = _range;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: _busy ? null : _pickRange,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Icon(Icons.date_range, size: 18, color: cs.onSurface.withAlpha(150)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        range == null
                            ? 'Выбрать период'
                            : '${_fmt(range.start)} — ${_fmt(range.end)}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    Icon(Icons.chevron_right, color: cs.onSurface.withAlpha(90)),
                  ],
                ),
              ),
            ),
            const Divider(height: 14),
            Text('Какие инциденты включить',
                style: TextStyle(fontSize: 11.5, color: cs.onSurface.withAlpha(150))),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _filterChip('Все', null),
                _filterChip('Активные', 'active'),
                _filterChip('Завершённые', 'finished'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: (_busy || range == null) ? null : () => _preview(),
                    icon: const Icon(Icons.visibility_outlined, size: 18),
                    label: const Text('Посмотреть'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: (_busy || range == null) ? null : _exportPeriod,
                    icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                    label: const Text('PDF'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, String? value) => ChoiceChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        selected: _statusFilter == value,
        onSelected: _busy ? null : (_) => setState(() => _statusFilter = value),
      );

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.'
      '${d.month.toString().padLeft(2, '0')}.${d.year}';
}
