import 'package:flutter/material.dart';
import '../services/incident_schedule_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/incident_providers.dart';
import '../providers/map_providers.dart';
import '../widgets/incident_card.dart';
import '../utils/app_theme.dart';
import '../models/incident_models.dart';
import '../models/boiler_house_models.dart';
import '../models/permission_key.dart';
import '../services/incident_service.dart';
import '../services/user_service.dart';
import '../services/permission_service.dart';
import 'incident_detail_screen.dart';
import 'incident_form_screen.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../widgets/incident_filter_sheet.dart';
import '../providers/offline_edit_permission.dart';
import '../services/chat_read_service.dart';

class IncidentListScreen extends ConsumerStatefulWidget {
  const IncidentListScreen({super.key});

  @override
  ConsumerState<IncidentListScreen> createState() => _IncidentListScreenState();
}

class _IncidentListScreenState extends ConsumerState<IncidentListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Загружаем счётчики непрочитанных при открытии экрана
    Future.microtask(() {
      ref.read(unreadCountsProvider.notifier).fetchAll();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 0. Initialize schedule manager for auto-refresh on start/finish times
    ref.watch(incidentScheduleManagerProvider);

    // 1. Listen for global refresh events from WebSocket (safely now that we're on AsyncValue)
    ref.listen(globalRefreshEventProvider, (_, __) {
      ref.invalidate(allIncidentsProvider);
    });

    // 2. Watch the ViewModels stream with native Riverpod caching and lifecycle handling
    final viewModelsAsync = ref.watch(incidentViewModelsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Журнал инцидентов'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const IncidentFilterSheet(),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            children: [
              _buildSearchBar(),
              _buildQuickFilters(),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(allIncidentsProvider);
        },
        child: viewModelsAsync.when(
          // Key improvement: skipLoadingOnReload ensures UI does not blank out or show a spinner when the stream emits a new value
          skipLoadingOnReload: true,
          data: (viewModels) => _buildList(viewModels),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: AppTheme.errorRed, size: 48),
                const SizedBox(height: 16),
                Text('Ошибка: $err', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(allIncidentsProvider),
                  child: const Text('Повторить'),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: ref.watch(permissionStateProvider).hasPermission(PermissionKey.incidentCreate)
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const IncidentFormScreen(),
                  ),
                ).then((_) => ref.invalidate(allIncidentsProvider));
              },
              backgroundColor: Colors.blue,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => ref.read(incidentFilterProvider.notifier).updateSearchQuery(value),
          decoration: InputDecoration(
            hintText: 'Поиск по типу или деталям...',
            prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurface.withAlpha(140)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: Theme.of(context).colorScheme.onSurface.withAlpha(140)),
                    onPressed: () {
                      _searchController.clear();
                      ref.read(incidentFilterProvider.notifier).updateSearchQuery('');
                    },
                  )
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _FilterChip(
            label: 'Активные',
            isSelected: ref.watch(incidentFilterProvider).quickFilter == IncidentQuickFilter.active,
            onSelected: () => ref.read(incidentFilterProvider.notifier).setQuickFilter(IncidentQuickFilter.active),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Мои',
            isSelected: ref.watch(incidentFilterProvider).quickFilter == IncidentQuickFilter.assignedToMe,
            onSelected: () => ref.read(incidentFilterProvider.notifier).setQuickFilter(IncidentQuickFilter.assignedToMe),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Все',
            isSelected: ref.watch(incidentFilterProvider).quickFilter == IncidentQuickFilter.all,
            onSelected: () => ref.read(incidentFilterProvider.notifier).setQuickFilter(IncidentQuickFilter.all),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<IncidentViewModel> viewModels) {
    if (viewModels.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 100),
          Center(
            child: Column(
              children: [
                Icon(Icons.search_off, size: 64, color: Theme.of(context).colorScheme.onSurface.withAlpha(60)),
                const SizedBox(height: 16),
                Text('Инцидентов не найдено', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(140), fontSize: 16)),
              ],
            ),
          ),
        ],
      );
    }

    final unreadCounts = ref.watch(unreadCountsProvider);
    
    // Сортируем: непрочитанные наверх (stable sort сохраняет порядок внутри групп)
    final sorted = List<IncidentViewModel>.from(viewModels);
    sorted.sort((a, b) {
      final aUnread = (unreadCounts[a.raw.id] ?? 0) > 0 ? 0 : 1;
      final bUnread = (unreadCounts[b.raw.id] ?? 0) > 0 ? 0 : 1;
      return aUnread.compareTo(bUnread);
    });

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final sortedVm = sorted[index];
        final sortedInc = sortedVm.raw;

        return Slidable(
          key: ValueKey(sortedInc.id),
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            extentRatio: 0.65, // Adjust based on 3 buttons width
            children: [
              if (ref.read(permissionStateProvider).hasPermission(PermissionKey.incidentUpdate)) ...[
                if (sortedInc.status == IncidentStatus.resolved || sortedInc.status == IncidentStatus.closed)
                  _buildCustomSlidableAction(
                    label: 'Возобновить',
                    icon: Icons.refresh,
                    color: Colors.orange,
                    onPressed: (_) => _resumeIncident(sortedInc.id),
                  )
                else
                  _buildCustomSlidableAction(
                    label: 'Завершить',
                    icon: Icons.check_circle_outline,
                    color: Colors.green,
                    onPressed: (_) => _completeIncident(sortedInc.id),
                  ),
              ],
              if (ref.read(permissionStateProvider).hasPermission(PermissionKey.incidentDelete))
                _buildCustomSlidableAction(
                  label: 'Удалить',
                  icon: Icons.delete_outline,
                  color: Colors.redAccent,
                  onPressed: (_) => _deleteIncident(sortedInc.id, sortedInc.title),
                ),
              if (ref.read(permissionStateProvider).hasPermission(PermissionKey.incidentUpdate))
                _buildCustomSlidableAction(
                  label: 'Редакт.',
                  icon: Icons.edit,
                  color: Colors.orange,
                  onPressed: (_) => _editIncident(sortedInc),
                ),
            ],
          ),
          child: IncidentCard(
            title: sortedInc.title ?? 'Инцидент №${sortedInc.id}',
            location: sortedInc.boilerHouse?.address != null
                ? '📍 Котельная: ${sortedInc.boilerHouse!.address}'
                : 'Неизвестная локация',
            timestamp: sortedVm.formattedTimestamp,
            statusText: sortedInc.isScheduledLocal
                ? 'ЗАПЛАНИРОВАН'
                : sortedInc.isOverdue
                    ? 'ПРОСРОЧЕН'
                    : (sortedInc.status == IncidentStatus.resolved || sortedInc.status == IncidentStatus.closed)
                        ? 'ЗАВЕРШЁН'
                        : 'АКТИВЕН',
            isStatusActive: !sortedInc.isScheduledLocal && !sortedInc.isOverdue && sortedInc.status != IncidentStatus.resolved && sortedInc.status != IncidentStatus.closed,
            statusColor: sortedInc.isScheduledLocal ? Colors.grey : sortedInc.isOverdue ? Colors.orange : null,
            colorStatus: sortedVm.resolvedColorStatus,
            assigneeName: sortedVm.assigneeName,
            affectedPopulationCount: sortedVm.totalResidents,
            stoppedServicesText: sortedVm.stoppedServicesText,
            broadcastText: sortedVm.broadcastText,
            boilersInfoText: sortedVm.boilersInfoText,
            inactiveBoilerNumbers: sortedVm.inactiveBoilerNumbers,
            totalBoilersCount: sortedVm.totalBoilersCount,
            supplyFullyStopped: sortedVm.supplyFullyStopped,
            isUnsynced: sortedInc.localPendingAck == true,
            isOverdue: sortedInc.isOverdue,
            boilerHouseDetail: sortedVm.boilerHouseDetail,
            unreadChatCount: unreadCounts[sortedInc.id] ?? 0,
            incidentId: sortedInc.id,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => IncidentDetailScreen(incidentId: sortedInc.id),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCustomSlidableAction({
    required String label,
    required IconData icon,
    required Color color,
    required Function(BuildContext) onPressed,
  }) {
    return CustomSlidableAction(
      onPressed: onPressed,
      backgroundColor: Colors.transparent,
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(180), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Future<void> _completeIncident(int id) async {
    if (!ref.read(permissionStateProvider).hasPermission(PermissionKey.incidentUpdate)) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Нет прав на редактирование инцидентов'), backgroundColor: Colors.red));
      return;
    }
    final canWrite = ref.read(writeAccessProvider);
    if (!canWrite) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Нет интернета и нет прав на редактирование без сети'), backgroundColor: Colors.red));
      return;
    }
    try {
      final service = ref.read(incidentServiceProvider);
      await service.updateIncident(id, IncidentUpdate(status: IncidentStatus.resolved));
      ref.invalidate(allIncidentsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Инцидент завершен')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка завершения: $e')));
      }
    }
  }

  Future<void> _resumeIncident(int id) async {
    if (!ref.read(permissionStateProvider).hasPermission(PermissionKey.incidentUpdate)) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Нет прав на редактирование инцидентов'), backgroundColor: Colors.red));
      return;
    }
    final canWrite = ref.read(writeAccessProvider);
    if (!canWrite) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Нет интернета и нет прав на редактирование без сети'), backgroundColor: Colors.red));
      return;
    }
    try {
      final service = ref.read(incidentServiceProvider);
      // КРИТИЧНО: Используем resumeIncident вместо updateIncident,
      // чтобы отправить finishedAt=null и autoResolveOnFinish=false.
      // Иначе сервер сохранит старый finishedAt и инцидент снова закроется.
      await service.resumeIncident(id);
      ref.invalidate(allIncidentsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Инцидент возобновлен')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка возобновления: $e')));
      }
    }
  }

  Future<void> _deleteIncident(int id, String? title) async {
    if (!ref.read(permissionStateProvider).hasPermission(PermissionKey.incidentDelete)) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Нет прав на удаление инцидентов'), backgroundColor: Colors.red));
      return;
    }
    final canWrite = ref.read(writeAccessProvider);
    if (!canWrite) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Нет интернета и нет прав на редактирование без сети'), backgroundColor: Colors.red));
      return;
    }
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text('Удаление инцидента', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          content: Text(
            'Вы уверены, что хотите удалить ${title ?? "№$id"}?',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(180)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Отмена', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(180))),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Удалить', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        final service = ref.read(incidentServiceProvider);
        await service.deleteIncident(id);
        ref.invalidate(allIncidentsProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Инцидент удален')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка удаления: $e')));
        }
      }
    }
  }

  void _editIncident(IncidentResponse incident) {
    if (!ref.read(permissionStateProvider).hasPermission(PermissionKey.incidentUpdate)) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Нет прав на редактирование инцидентов'), backgroundColor: Colors.red));
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IncidentFormScreen(initialIncident: incident),
      ),
    ).then((_) => ref.invalidate(allIncidentsProvider));
  }

}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: AppTheme.primaryBlue.withAlpha(100),
      backgroundColor: Colors.transparent,
      labelStyle: TextStyle(
        color: isSelected ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurface.withAlpha(180),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: StadiumBorder(
        side: BorderSide(color: isSelected ? AppTheme.primaryBlue : Theme.of(context).colorScheme.onSurface.withAlpha(60)),
      ),
      showCheckmark: false,
    );
  }
}
