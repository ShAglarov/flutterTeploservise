import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/base_api_service.dart';

/// Экран уведомлений о задолженности — переработанный.
/// Разные шаблоны карточек по типам, массовые операции, PDF, WhatsApp.
class DebtNoticesScreen extends ConsumerStatefulWidget {
  const DebtNoticesScreen({super.key});

  @override
  ConsumerState<DebtNoticesScreen> createState() => _DebtNoticesScreenState();
}

class _DebtNoticesScreenState extends ConsumerState<DebtNoticesScreen> {
  List<Map<String, dynamic>> _notices = [];
  bool _isLoading = true;
  String? _error;
  String? _filterType;
  String? _filterStatus;

  // ── Кэш аккаунтов (загружается 1 раз) ──
  List<Map<String, dynamic>>? _cachedAccounts;
  bool _isPickerOpen = false;

  // ── Режим множественного выбора ──
  bool _selectionMode = false;
  final Set<int> _selectedIds = {};

  static const Map<String, String> typeLabels = {
    'warning': 'Предупреждение',
    'pretrial': 'Досудебная',
    'court': 'Судебное',
  };
  static const Map<String, IconData> typeIcons = {
    'warning': Icons.warning_amber,
    'pretrial': Icons.gavel,
    'court': Icons.balance,
  };
  static const Map<String, Color> typeColors = {
    'warning': Colors.orange,
    'pretrial': Colors.red,
    'court': Colors.deepPurple,
  };
  static const Map<String, String> statusLabels = {
    'draft': 'Черновик',
    'sent': 'Отправлено',
    'delivered': 'Доставлено',
    'returned': 'Возвращено',
  };
  static const Map<String, Color> statusColors = {
    'draft': Colors.grey,
    'sent': Colors.blue,
    'delivered': Colors.green,
    'returned': Colors.red,
  };

  // Метки услуг для разбивки
  static const Map<String, String> _serviceLabels = {
    'heating': 'Отопление',
    'hot_water': 'Горячая вода',
    'maintenance': 'Теплообслуживание',
    'waste': 'ТБО',
    'odn_electricity': 'ОДН электр.',
    'odn_water': 'ОДН вода',
  };

  @override
  void initState() {
    super.initState();
    _load();
    _preloadAccounts();
  }

  /// Предзагрузка аккаунтов в фоне — чтобы пикер открывался мгновенно
  Future<void> _preloadAccounts() async {
    try {
      final dio = ref.read(dioProvider);
      final resp = await dio.get('/accounts/', queryParameters: {'limit': 10000});
      if (resp.statusCode == 200) {
        _cachedAccounts = (resp.data as List).cast<Map<String, dynamic>>();
      }
    } catch (_) {}
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final dio = ref.read(dioProvider);
      final params = <String, dynamic>{'limit': 500};
      if (_filterType != null) params['notice_type'] = _filterType;
      if (_filterStatus != null) params['status'] = _filterStatus;
      final resp = await dio.get('/debt-notices/', queryParameters: params);
      if (resp.statusCode == 200) {
        setState(() => _notices = (resp.data as List).cast<Map<String, dynamic>>());
      }
    } catch (e) {
      setState(() => _error = '$e');
    }
    setState(() => _isLoading = false);
  }

  void _exitSelectionMode() {
    setState(() {
      _selectionMode = false;
      _selectedIds.clear();
    });
  }

  void _toggleSelection(int id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        if (_selectedIds.isEmpty) _selectionMode = false;
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _selectAll() {
    setState(() {
      if (_selectedIds.length == _notices.length) {
        _selectedIds.clear();
        _selectionMode = false;
      } else {
        _selectedIds.addAll(_notices.map((n) => n['id'] as int));
      }
    });
  }

  List<Map<String, dynamic>> get _selectedNotices =>
      _notices.where((n) => _selectedIds.contains(n['id'])).toList();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: _selectionMode ? _buildSelectionAppBar(theme) : _buildNormalAppBar(theme),
      body: Column(
        children: [
          // Фильтры
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              children: [
                _typeChip(null, 'Все', Icons.grid_view),
                ...typeLabels.entries.map((e) => _typeChip(e.key, e.value, typeIcons[e.key]!)),
                const SizedBox(width: 12),
                ...statusLabels.entries.map((e) => _statusChip(e.key, e.value)),
              ],
            ),
          ),
          // Сводка по выбранным
          if (_selectionMode && _selectedIds.isNotEmpty) _buildSelectionSummary(theme),
          Expanded(child: _buildBody(theme)),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildNormalAppBar(ThemeData theme) {
    return AppBar(
      title: const Text('Уведомления о задолженности'),
      actions: [
        IconButton(icon: const Icon(Icons.flash_on), tooltip: 'Массовое формирование', onPressed: _massCreate),
        IconButton(icon: const Icon(Icons.add_circle_outline), tooltip: 'Создать', onPressed: () => _edit(null)),
      ],
    );
  }

  PreferredSizeWidget _buildSelectionAppBar(ThemeData theme) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: _exitSelectionMode,
      ),
      title: Text('${_selectedIds.length} выбрано'),
      actions: [
        IconButton(
          icon: Icon(_selectedIds.length == _notices.length ? Icons.deselect : Icons.select_all),
          tooltip: _selectedIds.length == _notices.length ? 'Снять все' : 'Выбрать все',
          onPressed: _selectAll,
        ),
        IconButton(
          icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
          tooltip: 'Экспорт PDF',
          onPressed: _selectedIds.isEmpty ? null : () => _exportSelectedPdf(),
        ),
        PopupMenuButton<String>(
          onSelected: (v) {
            if (v == 'whatsapp') _shareSelectedWhatsApp();
            if (v == 'share') _shareSelectedPdf();
            if (v == 'delete') _massDelete();
          },
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: 'whatsapp',
              child: ListTile(
                leading: Icon(Icons.chat, color: Colors.green, size: 20),
                title: Text('Отправить в WhatsApp'),
              ),
            ),
            const PopupMenuItem(
              value: 'share',
              child: ListTile(
                leading: Icon(Icons.share, color: Colors.blue, size: 20),
                title: Text('Поделиться'),
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete_sweep, color: Colors.red, size: 20),
                title: Text('Удалить выбранные'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSelectionSummary(ThemeData theme) {
    final selected = _selectedNotices;
    final totalDebt = selected.fold<double>(0, (s, n) => s + ((n['debt_amount'] as num?)?.toDouble() ?? 0));
    final types = <String, int>{};
    for (final n in selected) {
      final t = n['notice_type'] as String? ?? 'warning';
      types[t] = (types[t] ?? 0) + 1;
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: theme.colorScheme.primaryContainer.withAlpha(60),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Общий долг: ${totalDebt.toStringAsFixed(2)} ₽  •  ${types.entries.map((e) => '${typeLabels[e.key] ?? e.key}: ${e.value}').join(', ')}',
              style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _typeChip(String? type, String label, IconData icon) {
    final selected = _filterType == type;
    final color = type != null ? (typeColors[type] ?? Colors.grey) : Colors.blue;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        selected: selected,
        label: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: selected ? Colors.white : color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, color: selected ? Colors.white : null)),
        ]),
        selectedColor: color,
        onSelected: (_) { setState(() => _filterType = selected ? null : type); _load(); },
      ),
    );
  }

  Widget _statusChip(String status, String label) {
    final selected = _filterStatus == status;
    final color = statusColors[status] ?? Colors.grey;
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: FilterChip(
        selected: selected,
        label: Text(label, style: TextStyle(fontSize: 10, color: selected ? Colors.white : color)),
        selectedColor: color,
        onSelected: (_) { setState(() => _filterStatus = selected ? null : status); _load(); },
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.error_outline, size: 48, color: Colors.red),
      const SizedBox(height: 8), Text(_error!, style: const TextStyle(fontSize: 13)),
      const SizedBox(height: 12), FilledButton(onPressed: _load, child: const Text('Повторить')),
    ]));
    if (_notices.isEmpty) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.mark_email_read, size: 64, color: Colors.grey.shade400),
      const SizedBox(height: 12),
      const Text('Нет уведомлений', style: TextStyle(fontSize: 16, color: Colors.grey)),
      const SizedBox(height: 12),
      FilledButton.icon(onPressed: _massCreate, icon: const Icon(Icons.flash_on), label: const Text('Массовое формирование')),
    ]));

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _notices.length,
        itemBuilder: (_, i) => _buildNoticeCard(_notices[i], theme),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  КАРТОЧКИ УВЕДОМЛЕНИЙ — разные по типу
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildNoticeCard(Map<String, dynamic> n, ThemeData theme) {
    final type = n['notice_type'] as String? ?? 'warning';
    final isSelected = _selectedIds.contains(n['id']);

    return GestureDetector(
      onLongPress: () {
        if (!_selectionMode) {
          setState(() {
            _selectionMode = true;
            _selectedIds.add(n['id'] as int);
          });
        }
      },
      onTap: () {
        if (_selectionMode) {
          _toggleSelection(n['id'] as int);
        } else {
          _showDetailSheet(n);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer.withAlpha(80)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : (typeColors[type] ?? Colors.grey).withAlpha(50),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок карточки
            _buildCardHeader(n, theme, isSelected),
            // Контент зависит от типа
            if (type == 'warning') _buildWarningContent(n, theme),
            if (type == 'pretrial') _buildPretrialContent(n, theme),
            if (type == 'court') _buildCourtContent(n, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildCardHeader(Map<String, dynamic> n, ThemeData theme, bool isSelected) {
    final type = n['notice_type'] as String? ?? 'warning';
    final status = n['status'] as String? ?? 'draft';
    final color = typeColors[type] ?? Colors.grey;
    final stColor = statusColors[status] ?? Colors.grey;
    final icon = typeIcons[type] ?? Icons.mail;
    final debt = (n['debt_amount'] as num?)?.toDouble() ?? 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 0),
      child: Row(
        children: [
          if (_selectionMode)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(
                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isSelected ? theme.colorScheme.primary : Colors.grey,
                size: 22,
              ),
            ),
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withAlpha(30),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  n['fio'] ?? 'Без ФИО',
                  style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'ЛС: ${n['account_number'] ?? ''} • ${n['address'] ?? ''}',
                  style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${debt.toStringAsFixed(2)} ₽',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Colors.red.shade700),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _badge(n['notice_type_label'] ?? type, color),
                  const SizedBox(width: 4),
                  _badge(n['status_label'] ?? status, stColor),
                ],
              ),
            ],
          ),
          if (!_selectionMode)
            PopupMenuButton<String>(
              padding: EdgeInsets.zero,
              iconSize: 20,
              onSelected: (v) {
                if (v == 'edit') _edit(n);
                if (v == 'send') _updateStatus(n['id'] as int, 'sent');
                if (v == 'pdf') _exportSinglePdf(n);
                if (v == 'whatsapp') _shareSingleWhatsApp(n);
                if (v == 'delete') _delete(n['id'] as int);
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: ListTile(dense: true, leading: Icon(Icons.edit, size: 18), title: Text('Редактировать', style: TextStyle(fontSize: 13)))),
                if (status == 'draft')
                  const PopupMenuItem(value: 'send', child: ListTile(dense: true, leading: Icon(Icons.send, size: 18, color: Colors.blue), title: Text('Отметить отправленным', style: TextStyle(fontSize: 13)))),
                const PopupMenuItem(value: 'pdf', child: ListTile(dense: true, leading: Icon(Icons.picture_as_pdf, size: 18, color: Colors.red), title: Text('Экспорт PDF', style: TextStyle(fontSize: 13)))),
                const PopupMenuItem(value: 'whatsapp', child: ListTile(dense: true, leading: Icon(Icons.chat, size: 18, color: Colors.green), title: Text('WhatsApp', style: TextStyle(fontSize: 13)))),
                const PopupMenuItem(value: 'delete', child: ListTile(dense: true, leading: Icon(Icons.delete, size: 18, color: Colors.red), title: Text('Удалить', style: TextStyle(fontSize: 13)))),
              ],
            ),
        ],
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(color: color.withAlpha(25), borderRadius: BorderRadius.circular(4)),
      child: Text(text, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: color)),
    );
  }

  // ── Предупреждение: мягкий тон, простая информация ──
  Widget _buildWarningContent(Map<String, dynamic> n, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.withAlpha(15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withAlpha(40)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Просим погасить задолженность',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.orange.shade800),
                ),
                const SizedBox(height: 4),
                Text(
                  'Период: ${_periodText(n)}  •  Дата: ${n['issued_date'] ?? ''}',
                  style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Досудебная: разбивка по услугам ──
  Widget _buildPretrialContent(Map<String, dynamic> n, ThemeData theme) {
    final breakdown = n['debt_breakdown'] as Map<String, dynamic>? ?? {};
    final services = breakdown.entries.where((e) => (e.value as num?)?.toDouble() != null && (e.value as num).toDouble() > 0).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.red.withAlpha(12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withAlpha(40)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.gavel, size: 14, color: Colors.red.shade700),
                    const SizedBox(width: 4),
                    Text(
                      'Досудебная претензия — разбивка по услугам',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.red.shade700),
                    ),
                  ],
                ),
                if (services.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  ...services.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Row(
                      children: [
                        const SizedBox(width: 18),
                        Expanded(
                          child: Text(
                            _serviceLabels[e.key] ?? e.key,
                            style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ),
                        Text(
                          '${(e.value as num).toDouble().toStringAsFixed(2)} ₽',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.red.shade600),
                        ),
                      ],
                    ),
                  )),
                ],
                const SizedBox(height: 4),
                Text(
                  'Период: ${_periodText(n)}  •  Срок оплаты: 15 дней',
                  style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Судебное: ссылки на законы ──
  Widget _buildCourtContent(Map<String, dynamic> n, ThemeData theme) {
    final breakdown = n['debt_breakdown'] as Map<String, dynamic>? ?? {};
    final totalFromBreakdown = breakdown.values
        .whereType<num>()
        .fold<double>(0, (s, v) => s + v.toDouble());

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withAlpha(12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.deepPurple.withAlpha(50)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.balance, size: 14, color: Colors.deepPurple.shade700),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Подготовка искового заявления',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.deepPurple.shade700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                _legalRef('Ст. 153, 155 ЖК РФ', 'обязанность оплаты', theme),
                _legalRef('П. 14 ст. 155 ЖК РФ', 'начисление пени', theme),
                _legalRef('Ст. 122 ГПК РФ', 'судебный приказ', theme),
                const SizedBox(height: 6),
                if (totalFromBreakdown > 0)
                  Text(
                    'Сумма долга по услугам: ${totalFromBreakdown.toStringAsFixed(2)} ₽ + возможны пени и госпошлина',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.deepPurple.shade600),
                  ),
                const SizedBox(height: 2),
                Text(
                  'Период: ${_periodText(n)}  •  Дата: ${n['issued_date'] ?? ''}',
                  style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _legalRef(String article, String desc, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 18, bottom: 2),
      child: Row(
        children: [
          Text('• ', style: TextStyle(fontSize: 10, color: Colors.deepPurple.shade400)),
          Text(article, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.deepPurple.shade600)),
          Text(' — $desc', style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  String _periodText(Map<String, dynamic> n) {
    final from = n['period_from'] as String?;
    final to = n['period_to'] as String?;
    if (from != null && to != null) return '$from — $to';
    if (to != null) return to;
    if (from != null) return from;
    return '—';
  }

  // ═══════════════════════════════════════════════════════════════════
  //  ДЕТАЛЬНЫЙ ПРОСМОТР (bottom sheet)
  // ═══════════════════════════════════════════════════════════════════

  void _showDetailSheet(Map<String, dynamic> n) {
    final theme = Theme.of(context);
    final type = n['notice_type'] as String? ?? 'warning';
    final status = n['status'] as String? ?? 'draft';
    final color = typeColors[type] ?? Colors.grey;
    final debt = (n['debt_amount'] as num?)?.toDouble() ?? 0;
    final breakdown = n['debt_breakdown'] as Map<String, dynamic>? ?? {};
    final textContent = n['text_content'] as String?;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        expand: false,
        builder: (_, scrollCtrl) => ListView(
          controller: scrollCtrl,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            // Ручка
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            // Заголовок
            Row(
              children: [
                CircleAvatar(radius: 22, backgroundColor: color.withAlpha(30), child: Icon(typeIcons[type], color: color, size: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(typeLabels[type] ?? type, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
                      Text(n['fio'] ?? '', style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface)),
                    ],
                  ),
                ),
                Text('${debt.toStringAsFixed(2)} ₽', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.red.shade700)),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: theme.colorScheme.onSurface.withAlpha(20)),
            const SizedBox(height: 12),

            // Информация
            _detailRow('Лицевой счёт', n['account_number'] ?? '—', theme),
            _detailRow('Адрес', n['address'] ?? '—', theme),
            _detailRow('Телефон', n['phone'] ?? '—', theme),
            _detailRow('Период', _periodText(n), theme),
            _detailRow('Дата формирования', n['issued_date'] ?? '—', theme),
            if (n['sent_date'] != null) _detailRow('Дата отправки', n['sent_date'], theme),
            _detailRow('Статус', statusLabels[status] ?? status, theme),
            const SizedBox(height: 16),

            // Разбивка долга
            if (breakdown.isNotEmpty) ...[
              Text('Разбивка по услугам', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
              const SizedBox(height: 8),
              ...breakdown.entries.where((e) => (e.value as num?)?.toDouble() != null && (e.value as num).toDouble() > 0).map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Container(width: 4, height: 16, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_serviceLabels[e.key] ?? e.key, style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface))),
                    Text('${(e.value as num).toDouble().toStringAsFixed(2)} ₽', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.red.shade600)),
                  ],
                ),
              )),
              const SizedBox(height: 16),
            ],

            // Текст уведомления
            if (textContent != null && textContent.isNotEmpty) ...[
              Text('Текст уведомления', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withAlpha(8),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: theme.colorScheme.onSurface.withAlpha(15)),
                ),
                child: Text(textContent, style: TextStyle(fontSize: 12, height: 1.5, color: theme.colorScheme.onSurface)),
              ),
              const SizedBox(height: 16),
            ],

            // Примечание
            if (n['note'] != null && (n['note'] as String).isNotEmpty) ...[
              Text('Примечание', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
              const SizedBox(height: 4),
              Text(n['note'], style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(height: 16),
            ],

            // Действия
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () { Navigator.pop(ctx); _exportSinglePdf(n); },
                    icon: const Icon(Icons.picture_as_pdf, size: 18),
                    label: const Text('PDF'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () { Navigator.pop(ctx); _shareSingleWhatsApp(n); },
                    icon: const Icon(Icons.chat, size: 18, color: Colors.green),
                    label: const Text('WhatsApp'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () { Navigator.pop(ctx); _edit(n); },
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Изм.'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
          ),
          Expanded(child: Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface))),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  PDF ГЕНЕРАЦИЯ
  // ═══════════════════════════════════════════════════════════════════

  Future<File> _generatePdfForNotices(List<Map<String, dynamic>> notices) async {
    // Загружаем кириллический шрифт
    final fontData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
    final ttf = pw.Font.ttf(fontData);

    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(base: ttf, bold: ttf),
    );

    for (final n in notices) {
      final type = n['notice_type'] as String? ?? 'warning';
      final debt = (n['debt_amount'] as num?)?.toDouble() ?? 0;
      final breakdown = n['debt_breakdown'] as Map<String, dynamic>? ?? {};
      final textContent = n['text_content'] as String?;

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Заголовок
                pw.Center(
                  child: pw.Text(
                    type == 'warning' ? 'УВЕДОМЛЕНИЕ О ЗАДОЛЖЕННОСТИ'
                      : type == 'pretrial' ? 'ДОСУДЕБНАЯ ПРЕТЕНЗИЯ'
                      : 'СУДЕБНОЕ УВЕДОМЛЕНИЕ',
                    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Center(
                  child: pw.Text(
                    'от ${n['issued_date'] ?? '—'}',
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Divider(thickness: 1.5),
                pw.SizedBox(height: 14),

                // Данные
                _pdfInfoRow('Кому:', n['fio'] ?? '—'),
                _pdfInfoRow('Лицевой счёт:', n['account_number'] ?? '—'),
                _pdfInfoRow('Адрес:', n['address'] ?? '—'),
                _pdfInfoRow('Период:', _periodText(n)),
                pw.SizedBox(height: 14),

                // Сумма
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('ОБЩАЯ ЗАДОЛЖЕННОСТЬ:', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    pw.Text('${debt.toStringAsFixed(2)} руб.', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 12),

                // Разбивка для pretrial и court
                if ((type == 'pretrial' || type == 'court') && breakdown.isNotEmpty) ...[
                  pw.Text('Разбивка по услугам:', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 6),
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
                    columnWidths: {
                      0: const pw.FlexColumnWidth(3),
                      1: const pw.FlexColumnWidth(1),
                    },
                    children: [
                      pw.TableRow(
                        decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                        children: [
                          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Услуга', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
                          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Долг', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10), textAlign: pw.TextAlign.right)),
                        ],
                      ),
                      ...breakdown.entries.where((e) => (e.value as num?)?.toDouble() != null && (e.value as num).toDouble() > 0).map((e) => pw.TableRow(
                        children: [
                          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(_serviceLabels[e.key] ?? e.key, style: const pw.TextStyle(fontSize: 10))),
                          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('${(e.value as num).toDouble().toStringAsFixed(2)} р.', style: const pw.TextStyle(fontSize: 10), textAlign: pw.TextAlign.right)),
                        ],
                      )),
                    ],
                  ),
                  pw.SizedBox(height: 14),
                ],

                // Текст
                if (textContent != null && textContent.isNotEmpty) ...[
                  pw.Divider(),
                  pw.SizedBox(height: 8),
                  pw.Text(textContent, style: const pw.TextStyle(fontSize: 10, lineSpacing: 4)),
                ],
              ],
            );
          },
        ),
      );
    }

    final dir = await getTemporaryDirectory();
    final fileName = notices.length == 1
        ? 'notice_${notices[0]['account_number'] ?? 'debt'}_${DateTime.now().millisecondsSinceEpoch}.pdf'
        : 'notices_${notices.length}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  pw.Widget _pdfInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(width: 120, child: pw.Text(label, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700))),
          pw.Expanded(child: pw.Text(value, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold))),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  МАССОВЫЕ ДЕЙСТВИЯ
  // ═══════════════════════════════════════════════════════════════════

  Future<void> _exportSinglePdf(Map<String, dynamic> n) async {
    try {
      final file = await _generatePdfForNotices([n]);
      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)], subject: 'Уведомление — ${n['fio'] ?? ''}'),
      );
    } catch (e) {
      if (mounted) _showSnack('❌ Ошибка PDF: $e', Colors.red);
    }
  }

  Future<void> _exportSelectedPdf() async {
    if (_selectedIds.isEmpty) return;
    try {
      final file = await _generatePdfForNotices(_selectedNotices);
      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)], subject: 'Уведомления о задолженности (${_selectedIds.length})'),
      );
    } catch (e) {
      if (mounted) _showSnack('❌ Ошибка PDF: $e', Colors.red);
    }
  }

  Future<void> _shareSelectedPdf() async {
    if (_selectedIds.isEmpty) return;
    try {
      final file = await _generatePdfForNotices(_selectedNotices);
      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)], subject: 'Уведомления (${_selectedIds.length})'),
      );
    } catch (e) {
      if (mounted) _showSnack('❌ Ошибка: $e', Colors.red);
    }
  }

  Future<void> _shareSingleWhatsApp(Map<String, dynamic> n) async {
    try {
      final file = await _generatePdfForNotices([n]);
      final phone = (n['phone'] as String?)?.replaceAll(RegExp(r'[^0-9]'), '') ?? '';
      
      // Пробуем через share_plus с файлом — WhatsApp подхватит
      if (phone.isNotEmpty) {
        // Сначала шарим файл, потом предлагаем текст для WhatsApp
        final debt = (n['debt_amount'] as num?)?.toDouble() ?? 0;
        final text = 'Уведомление о задолженности: ${n['fio'] ?? ''}, долг ${debt.toStringAsFixed(2)} ₽';
        final waUrl = Uri.parse('https://wa.me/$phone?text=${Uri.encodeComponent(text)}');
        
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(file.path)],
            subject: 'Уведомление о задолженности',
            text: text,
          ),
        );
        
        // Также пробуем открыть WhatsApp с текстом
        if (await canLaunchUrl(waUrl)) {
          await launchUrl(waUrl, mode: LaunchMode.externalApplication);
        }
      } else {
        // Без номера — просто шарим PDF через системный диалог
        await SharePlus.instance.share(
          ShareParams(files: [XFile(file.path)], subject: 'Уведомление — ${n['fio'] ?? ''}'),
        );
      }
    } catch (e) {
      if (mounted) _showSnack('❌ Ошибка WhatsApp: $e', Colors.red);
    }
  }

  Future<void> _shareSelectedWhatsApp() async {
    if (_selectedIds.isEmpty) return;
    try {
      final file = await _generatePdfForNotices(_selectedNotices);
      final totalDebt = _selectedNotices.fold<double>(0, (s, n) => s + ((n['debt_amount'] as num?)?.toDouble() ?? 0));
      final text = 'Уведомления о задолженности (${_selectedIds.length} шт.), общий долг: ${totalDebt.toStringAsFixed(2)} ₽';
      
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          subject: 'Уведомления о задолженности',
          text: text,
        ),
      );
    } catch (e) {
      if (mounted) _showSnack('❌ Ошибка: $e', Colors.red);
    }
  }

  Future<void> _massDelete() async {
    if (_selectedIds.isEmpty) return;
    final count = _selectedIds.length;
    final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      icon: const Icon(Icons.delete_sweep, size: 48, color: Colors.red),
      title: Text('Удалить $count уведомлений?'),
      content: Text('Это действие нельзя отменить. Будет удалено $count уведомлений.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Удалить'),
        ),
      ],
    ));
    if (ok != true) return;

    try {
      final dio = ref.read(dioProvider);
      final resp = await dio.delete('/debt-notices/mass-delete', data: {
        'ids': _selectedIds.toList(),
      });
      final deleted = resp.data?['deleted'] ?? 0;
      if (mounted) _showSnack('🗑 Удалено $deleted уведомлений', Colors.green);
      _exitSelectionMode();
      _load();
    } catch (e) {
      if (mounted) _showSnack('❌ $e', Colors.red);
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  //  СУЩЕСТВУЮЩИЕ МЕТОДЫ (обновлённые)
  // ═══════════════════════════════════════════════════════════════════

  Future<void> _massCreate() async {
    DateTime period = DateTime(DateTime.now().year, DateTime.now().month, 1);
    String noticeType = 'warning';
    final minDebtCtrl = TextEditingController(text: '100');

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, ss) => AlertDialog(
          icon: const Icon(Icons.flash_on, size: 48, color: Colors.orange),
          title: const Text('Массовое формирование'),
          content: SizedBox(
            width: 380,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('Будут созданы уведомления для всех должников за выбранный период.', style: TextStyle(fontSize: 13)),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final d = await showDatePicker(context: ctx, initialDate: period, firstDate: DateTime(2020), lastDate: DateTime(2100));
                  if (d != null) ss(() => period = DateTime(d.year, d.month, 1));
                },
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Период', border: OutlineInputBorder(), isDense: true, prefixIcon: Icon(Icons.calendar_month, size: 20)),
                  child: Text(_formatPeriod(period)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(controller: minDebtCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Мин. долг (₽)', border: OutlineInputBorder(), isDense: true, prefixIcon: Icon(Icons.money_off, size: 20))),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: noticeType,
                decoration: const InputDecoration(labelText: 'Тип уведомления', border: OutlineInputBorder(), isDense: true, prefixIcon: Icon(Icons.mail, size: 20)),
                items: typeLabels.entries.map((e) => DropdownMenuItem(value: e.key, child: Row(children: [
                  Icon(typeIcons[e.key], size: 18, color: typeColors[e.key]),
                  const SizedBox(width: 8), Text(e.value),
                ]))).toList(),
                onChanged: (v) => ss(() => noticeType = v!),
              ),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
            FilledButton.icon(
              onPressed: () => Navigator.pop(ctx, true),
              icon: const Icon(Icons.flash_on),
              label: const Text('Сформировать'),
            ),
          ],
        ),
      ),
    );
    if (result != true) return;

    try {
      final dio = ref.read(dioProvider);
      final resp = await dio.post('/debt-notices/mass-create', data: {
        'period_date': period.toIso8601String().substring(0, 10),
        'min_debt': double.tryParse(minDebtCtrl.text) ?? 100,
        'notice_type': noticeType,
      });
      if (mounted) {
        final created = resp.data?['created'] ?? 0;
        final total = resp.data?['total_debt'] ?? 0;
        _showSnack('✅ Создано $created уведомлений на сумму ${total.toStringAsFixed(2)} ₽', Colors.green);
      }
      _load();
    } catch (e) {
      if (mounted) _showSnack('❌ $e', Colors.red);
    }
  }

  String _formatPeriod(DateTime d) {
    const months = ['', 'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь', 'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь'];
    return '${months[d.month]} ${d.year}';
  }

  Future<void> _edit(Map<String, dynamic>? existing) async {
    final isNew = existing == null;
    String noticeType = (existing?['notice_type'] as String?) ?? 'warning';
    final debtCtrl = TextEditingController(text: existing?['debt_amount']?.toString() ?? '');
    final noteCtrl = TextEditingController(text: existing?['note'] ?? '');
    int? accountId = existing?['account_id'] as int?;
    String accountLabel = existing != null ? '${existing['fio'] ?? ''} (ЛС: ${existing['account_number'] ?? ''})' : 'Выберите ЛС';

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, ss) => AlertDialog(
          title: Text(isNew ? '📬 Новое уведомление' : '✏️ Редактирование'),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
              if (isNew) ...[
                InkWell(
                  onTap: () => _pickAccount(ctx, (id, label, debt) => ss(() {
                    accountId = id;
                    accountLabel = label;
                    if (debt > 0 && debtCtrl.text.isEmpty) {
                      debtCtrl.text = debt.toStringAsFixed(2);
                    }
                  })),
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Лицевой счёт *', border: OutlineInputBorder(), isDense: true, prefixIcon: Icon(Icons.person, size: 20)),
                    child: Text(accountLabel, style: const TextStyle(fontSize: 14), overflow: TextOverflow.ellipsis),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              TextField(controller: debtCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Сумма задолженности *', border: OutlineInputBorder(), isDense: true, prefixIcon: Icon(Icons.money_off, size: 20), suffixText: '₽')),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: noticeType,
                decoration: const InputDecoration(labelText: 'Тип', border: OutlineInputBorder(), isDense: true),
                items: typeLabels.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
                onChanged: (v) => ss(() => noticeType = v!),
              ),
              const SizedBox(height: 12),
              TextField(controller: noteCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Примечание', border: OutlineInputBorder(), isDense: true)),
            ])),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(isNew ? 'Создать' : 'Сохранить')),
          ],
        ),
      ),
    );
    if (result != true) return;
    if (isNew && accountId == null) {
      if (mounted) _showSnack('❌ Выберите ЛС', Colors.red);
      return;
    }
    final debtValue = double.tryParse(debtCtrl.text) ?? 0;
    if (isNew && debtValue <= 0) {
      if (mounted) _showSnack('❌ Укажите сумму задолженности больше 0', Colors.red);
      return;
    }

    try {
      final dio = ref.read(dioProvider);
      if (isNew) {
        await dio.post('/debt-notices/', data: {
          'account_id': accountId,
          'debt_amount': debtValue,
          'notice_type': noticeType,
          'issued_date': DateTime.now().toIso8601String().substring(0, 10),
          'note': noteCtrl.text.isEmpty ? null : noteCtrl.text,
        });
      } else {
        await dio.put('/debt-notices/${existing['id']}', data: {
          'notice_type': noticeType,
          'note': noteCtrl.text.isEmpty ? null : noteCtrl.text,
        });
      }
      if (mounted) _showSnack(isNew ? '✅ Уведомление создано' : '✅ Обновлено', Colors.green);
      _load();
    } catch (e) {
      if (mounted) _showSnack('❌ $e', Colors.red);
    }
  }

  Future<void> _updateStatus(int id, String status) async {
    try {
      final dio = ref.read(dioProvider);
      await dio.put('/debt-notices/$id', data: {
        'status': status,
        if (status == 'sent') 'sent_date': DateTime.now().toIso8601String().substring(0, 10),
      });
      if (mounted) _showSnack('✅ Статус: ${statusLabels[status] ?? status}', Colors.green);
      _load();
    } catch (e) {
      if (mounted) _showSnack('❌ $e', Colors.red);
    }
  }

  Future<void> _pickAccount(BuildContext ctx, void Function(int, String, double) onPick) async {
    if (_isPickerOpen) return;
    _isPickerOpen = true;

    await showDialog(context: ctx, builder: (dlg) {
      return _AccountPickerDialog(
        cachedAccounts: _cachedAccounts,
        dio: ref.read(dioProvider),
        onPick: onPick,
        onAccountsLoaded: (accounts) {
          _cachedAccounts = accounts;
        },
      );
    });

    _isPickerOpen = false;
  }

  Future<void> _delete(int id) async {
    final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Удалить уведомление?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), style: FilledButton.styleFrom(backgroundColor: Colors.red), child: const Text('Удалить')),
      ],
    ));
    if (ok != true) return;
    try {
      final dio = ref.read(dioProvider);
      await dio.delete('/debt-notices/$id');
      if (mounted) _showSnack('🗑 Удалено', Colors.green);
      _load();
    } catch (e) {
      if (mounted) _showSnack('❌ $e', Colors.red);
    }
  }

  void _showSnack(String text, Color bg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), backgroundColor: bg));
  }
}

// ═══════════════════════════════════════════════════════════════════
//  ДИАЛОГ ВЫБОРА ЛС — открывается мгновенно, загрузка внутри
// ═══════════════════════════════════════════════════════════════════

class _AccountPickerDialog extends StatefulWidget {
  final List<Map<String, dynamic>>? cachedAccounts;
  final dynamic dio;
  final void Function(int, String, double) onPick;
  final void Function(List<Map<String, dynamic>>) onAccountsLoaded;

  const _AccountPickerDialog({
    required this.cachedAccounts,
    required this.dio,
    required this.onPick,
    required this.onAccountsLoaded,
  });

  @override
  State<_AccountPickerDialog> createState() => _AccountPickerDialogState();
}

class _AccountPickerDialogState extends State<_AccountPickerDialog> {
  List<Map<String, dynamic>>? _accounts;
  List<Map<String, dynamic>> _filtered = [];
  bool _isLoading = true;
  String? _error;
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.cachedAccounts != null) {
      _accounts = widget.cachedAccounts;
      _filtered = _accounts!;
      _isLoading = false;
      // Фокус на поиске после build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchFocus.requestFocus();
      });
    } else {
      _loadAccounts();
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _loadAccounts() async {
    try {
      final resp = await widget.dio.get('/accounts/', queryParameters: {'limit': 10000});
      if (resp.statusCode == 200 && mounted) {
        final accounts = (resp.data as List).cast<Map<String, dynamic>>();
        widget.onAccountsLoaded(accounts);
        setState(() {
          _accounts = accounts;
          _filtered = accounts;
          _isLoading = false;
        });
        // Фокус на поиске
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _searchFocus.requestFocus();
        });
      }
    } catch (e) {
      if (mounted) setState(() { _error = '$e'; _isLoading = false; });
    }
  }

  void _onSearch(String q) {
    final accounts = _accounts;
    if (accounts == null) return;

    final terms = q.toLowerCase().split(RegExp(r'[\s,;.]+'))
        .where((t) => t.isNotEmpty).toList();

    setState(() => _filtered = accounts.where((a) {
      final addr = (a['address'] as String? ?? '').toLowerCase();
      final haystack = '${a['fio']} ${a['account_number']} $addr'.toLowerCase();

      final houseMatch = RegExp(r'д\.\s*(\S+)').firstMatch(addr);
      final aptMatch = RegExp(r'кв\.\s*(\S+)').firstMatch(addr);
      final houseNum = houseMatch?.group(1)?.replaceAll(',', '') ?? '';
      final aptNum = aptMatch?.group(1)?.replaceAll(',', '') ?? '';

      final numTerms = <String>[];
      final textTerms = <String>[];
      for (final t in terms) {
        if (RegExp(r'^\d+$').hasMatch(t)) {
          numTerms.add(t);
        } else {
          textTerms.add(t);
        }
      }

      for (final t in textTerms) {
        if (!haystack.contains(t)) return false;
      }

      if (numTerms.length == 1) {
        final n = numTerms[0];
        if (houseNum != n && aptNum != n && !(a['account_number']?.toString().contains(n) ?? false)) {
          return false;
        }
      } else if (numTerms.length >= 2) {
        if (houseNum != numTerms[0]) return false;
        if (aptNum != numTerms[1]) return false;
      }

      return true;
    }).toList());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Выбор ЛС'),
      content: SizedBox(
        width: 400,
        height: 400,
        child: _isLoading
            ? const Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Загрузка списка ЛС...', style: TextStyle(fontSize: 13)),
                ]),
              )
            : _error != null
                ? Center(child: Text('Ошибка: $_error', style: const TextStyle(color: Colors.red)))
                : Column(children: [
                    TextField(
                      controller: _searchCtrl,
                      focusNode: _searchFocus,
                      decoration: const InputDecoration(
                        hintText: 'Поиск (ФИО, адрес, дом, кв)...',
                        prefixIcon: Icon(Icons.search),
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                      onChanged: _onSearch,
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        '${_filtered.length} из ${_accounts?.length ?? 0}',
                        style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Expanded(child: ListView.builder(
                      itemCount: _filtered.length,
                      itemBuilder: (_, i) {
                        final a = _filtered[i];
                        return ListTile(
                          dense: true,
                          title: Text('${a['fio'] ?? ''} (ЛС: ${a['account_number'] ?? ''})', style: const TextStyle(fontSize: 13)),
                          subtitle: Text(a['address'] ?? '', style: const TextStyle(fontSize: 11)),
                          onTap: () async {
                            Navigator.pop(context);
                            double debt = 0;
                            try {
                              final pdResp = await widget.dio.get('/payment-documents/', queryParameters: {
                                'account_id': a['id'],
                                'limit': 1,
                              });
                              if (pdResp.statusCode == 200) {
                                final docs = pdResp.data is List ? pdResp.data as List : (pdResp.data['items'] ?? []) as List;
                                if (docs.isNotEmpty) {
                                  final doc = docs.last as Map<String, dynamic>;
                                  debt = [
                                    'debt_heating_end', 'debt_hot_water_end', 'debt_maintenance_end',
                                    'debt_waste_end', 'debt_odn_electricity_end', 'debt_odn_water_end',
                                  ].fold<double>(0, (sum, key) => sum + ((doc[key] as num?)?.toDouble() ?? 0));
                                }
                              }
                            } catch (_) {}
                            widget.onPick(a['id'] as int, '${a['fio']} (ЛС: ${a['account_number']})', debt);
                          },
                        );
                      },
                    )),
                  ]),
      ),
    );
  }
}
