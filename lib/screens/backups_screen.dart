import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/organization_models.dart';
import '../services/backup_service.dart';
import '../utils/app_theme.dart';

final backupsProvider =
    FutureProvider.family<BackupList, int>((ref, orgId) async {
  return ref.watch(backupServiceProvider).list(orgId);
});

/// Резервные копии одной организации.
///
/// Откат затрагивает ТОЛЬКО эту организацию — остальные компании не
/// меняются. Перед каждым откатом сервер сам снимает копию «как было»,
/// поэтому случайное восстановление можно отменить.
class BackupsScreen extends ConsumerStatefulWidget {
  final OrganizationResponse organization;

  const BackupsScreen({super.key, required this.organization});

  @override
  ConsumerState<BackupsScreen> createState() => _BackupsScreenState();
}

class _BackupsScreenState extends ConsumerState<BackupsScreen> {
  bool _busy = false;
  String? _lastSafetyId;

  int get _orgId => widget.organization.id;

  Future<void> _create() async {
    final note = await _askNote();
    if (note == null) return;

    setState(() => _busy = true);
    try {
      final info = await ref.read(backupServiceProvider).create(
            _orgId,
            note: note.isEmpty ? null : note,
          );
      ref.invalidate(backupsProvider(_orgId));
      _toast('Копия создана: ${info.totalRows} записей, ${info.sizeLabel}',
          AppTheme.successGreen);
    } catch (e) {
      _toast(_errorText(e), AppTheme.errorRed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<String?> _askNote() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Создать копию'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Организация: ${widget.organization.name}',
                style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLength: 300,
              decoration: const InputDecoration(
                labelText: 'Примечание (необязательно)',
                hintText: 'например: перед импортом данных',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: const Text('Создать')),
        ],
      ),
    );
    controller.dispose();
    return result;
  }

  Future<void> _restore(BackupInfo backup) async {
    // Откат перезаписывает все данные организации — подтверждение
    // обязательно, и в нём сразу видно, к какому состоянию вернёмся.
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Откатить данные?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Организация «${widget.organization.name}» вернётся к '
                'состоянию на:'),
            const SizedBox(height: 6),
            Text(backup.dateLabel,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            if (backup.note != null) ...[
              const SizedBox(height: 4),
              Text(backup.note!,
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
            const SizedBox(height: 12),
            Text('Будет заменено ${backup.totalRows} записей: дома, '
                'котельные, лицевые счета, начисления, оплаты.',
                style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.successGreen.withAlpha(28),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Перед откатом автоматически сохранится текущее состояние — '
                'если откат окажется лишним, к нему можно вернуться.',
                style: TextStyle(fontSize: 11.5),
              ),
            ),
            const SizedBox(height: 8),
            const Text('Другие организации не затрагиваются.',
                style: TextStyle(fontSize: 11.5, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Отмена')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.errorRed),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Откатить'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _busy = true);
    try {
      final result =
          await ref.read(backupServiceProvider).restore(_orgId, backup.backupId);
      ref.invalidate(backupsProvider(_orgId));
      setState(() => _lastSafetyId = result.safetyBackupId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Откат выполнен: восстановлено '
              '${result.totalInserted} записей'),
          backgroundColor: AppTheme.successGreen,
          duration: const Duration(seconds: 6),
          action: result.safetyBackupId == null
              ? null
              : SnackBarAction(
                  label: 'Вернуть как было',
                  textColor: Colors.white,
                  onPressed: () => _undoRestore(result.safetyBackupId!),
                ),
        ));
      }
    } catch (e) {
      _toast(_errorText(e), AppTheme.errorRed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Возврат к состоянию до откката — на случай, если откатились зря.
  Future<void> _undoRestore(String safetyId) async {
    setState(() => _busy = true);
    try {
      final result =
          await ref.read(backupServiceProvider).restore(_orgId, safetyId);
      ref.invalidate(backupsProvider(_orgId));
      setState(() => _lastSafetyId = result.safetyBackupId);
      _toast('Возвращено состояние до откката: '
          '${result.totalInserted} записей', AppTheme.successGreen);
    } catch (e) {
      _toast(_errorText(e), AppTheme.errorRed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete(BackupInfo backup) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить копию?'),
        content: Text('Копия от ${backup.dateLabel} будет удалена навсегда.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Отмена')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Удалить',
                style: TextStyle(color: AppTheme.errorRed)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _busy = true);
    try {
      await ref.read(backupServiceProvider).delete(_orgId, backup.backupId);
      ref.invalidate(backupsProvider(_orgId));
      _toast('Копия удалена', AppTheme.successGreen);
    } catch (e) {
      _toast(_errorText(e), AppTheme.errorRed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _toast(String text, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text),
      backgroundColor: color,
      duration: const Duration(seconds: 5),
    ));
  }

  String _errorText(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      String? detail;
      if (data is Map) detail = data['detail']?.toString();
      if (detail == 'superadmin_required') {
        return 'Нужны права суперадмина';
      }
      if (e.type == DioExceptionType.receiveTimeout) {
        return 'Сервер долго отвечает. Операция могла продолжиться — '
            'обновите список.';
      }
      return detail ?? e.message ?? 'Ошибка сети';
    }
    return e.toString();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final data = ref.watch(backupsProvider(_orgId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Резервные копии'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _busy ? null : () => ref.invalidate(backupsProvider(_orgId)),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _busy ? null : _create,
        icon: _busy
            ? const SizedBox(
                width: 16, height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.backup_outlined),
        label: const Text('Создать копию'),
      ),
      body: data.when(
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
                  onPressed: () => ref.invalidate(backupsProvider(_orgId)),
                  child: const Text('Повторить'),
                ),
              ],
            ),
          ),
        ),
        data: (list) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
          children: [
            _intro(list, cs),
            const SizedBox(height: 18),
            _sectionTitle('Копии (${list.manual.length} из ${list.limitPerKind})'),
            if (list.manual.isEmpty)
              Text('Копий пока нет. Нажмите «Создать копию».',
                  style: TextStyle(fontSize: 12.5, color: cs.onSurface.withAlpha(150)))
            else
              ...list.manual.asMap().entries.map(
                  (e) => _tile(e.value, cs, isLatest: e.key == 0)),
            if (list.preRestore.isNotEmpty) ...[
              const SizedBox(height: 18),
              _sectionTitle('Состояния до откатов'),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Снимаются автоматически перед каждым откатом. '
                  'Выберите, чтобы отменить откат.',
                  style: TextStyle(fontSize: 11.5, color: cs.onSurface.withAlpha(150)),
                ),
              ),
              ...list.preRestore.map((b) => _tile(b, cs)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _intro(BackupList list, ColorScheme cs) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.apartment, size: 18, color: AppTheme.primaryBlue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(list.organization,
                      style: TextStyle(
                          fontWeight: FontWeight.w600, color: cs.onSurface)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Копия охватывает только эту организацию: дома, котельные, '
              'лицевые счета, начисления, оплаты, инциденты.\n\n'
              'Хранится до ${list.limitPerKind} копий — старые удаляются сами. '
              'Перед откатом текущее состояние сохраняется автоматически.',
              style: TextStyle(fontSize: 12, color: cs.onSurface.withAlpha(165)),
            ),
          ],
        ),
      );

  Widget _sectionTitle(String text) => Padding(
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

  Widget _tile(BackupInfo b, ColorScheme cs, {bool isLatest = false}) {
    if (b.broken) {
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          dense: true,
          leading: const Icon(Icons.broken_image_outlined,
              color: AppTheme.errorRed, size: 20),
          title: Text(b.backupId, style: const TextStyle(fontSize: 12)),
          subtitle: const Text('Файл повреждён — восстановление невозможно',
              style: TextStyle(fontSize: 11, color: AppTheme.errorRed)),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline, size: 18),
            onPressed: _busy ? null : () => _delete(b),
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
        child: Row(
          children: [
            Icon(
              b.isPreRestore ? Icons.history : Icons.inventory_2_outlined,
              size: 20,
              color: b.isPreRestore ? AppTheme.warningOrange : AppTheme.primaryBlue,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(b.dateLabel,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w500)),
                      if (isLatest) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppTheme.successGreen.withAlpha(40),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('последняя',
                              style: TextStyle(
                                  fontSize: 10, color: AppTheme.successGreen)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    [
                      '${b.totalRows} записей',
                      b.sizeLabel,
                      if (b.author != null) b.author!,
                    ].join(' · '),
                    style: TextStyle(
                        fontSize: 11, color: cs.onSurface.withAlpha(150)),
                  ),
                  if (b.note != null && b.note!.isNotEmpty)
                    Text(b.note!,
                        style: TextStyle(
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            color: cs.onSurface.withAlpha(130))),
                  if (b.backupId == _lastSafetyId)
                    const Text('снято перед последним откатом',
                        style: TextStyle(
                            fontSize: 10.5, color: AppTheme.warningOrange)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.restore, size: 20),
              tooltip: b.isPreRestore ? 'Отменить откат' : 'Откатиться сюда',
              color: AppTheme.errorRed,
              onPressed: _busy ? null : () => _restore(b),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18),
              tooltip: 'Удалить копию',
              onPressed: _busy ? null : () => _delete(b),
            ),
          ],
        ),
      ),
    );
  }
}
