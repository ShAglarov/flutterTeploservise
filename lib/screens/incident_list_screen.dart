import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/incident_providers.dart';
import '../providers/map_providers.dart';
import '../widgets/incident_card.dart';
import '../utils/app_theme.dart';
import '../models/incident_models.dart';
import '../models/boiler_house_models.dart';
import '../services/incident_service.dart';
import '../services/user_service.dart';
import 'incident_detail_screen.dart';
import 'incident_form_screen.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class IncidentListScreen extends ConsumerStatefulWidget {
  const IncidentListScreen({super.key});

  @override
  ConsumerState<IncidentListScreen> createState() => _IncidentListScreenState();
}

class _IncidentListScreenState extends ConsumerState<IncidentListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredIncidentsAsync = ref.watch(filteredIncidentsProvider);
    final mapData = ref.watch(mapDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Журнал инцидентов'),
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
          return ref.read(allIncidentsProvider.future);
        },
        child: filteredIncidentsAsync.when(
          data: (incidents) => _buildList(incidents, mapData),
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
      floatingActionButton: FloatingActionButton(
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
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.secondaryDarkBackground,
          borderRadius: BorderRadius.circular(10),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => ref.read(incidentFilterProvider.notifier).updateSearchQuery(value),
          decoration: InputDecoration(
            hintText: 'Поиск по типу или деталям...',
            prefixIcon: const Icon(Icons.search, color: Colors.white54),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white54),
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
            label: 'Все',
            isSelected: ref.watch(incidentFilterProvider).quickFilter == IncidentQuickFilter.all,
            onSelected: () => ref.read(incidentFilterProvider.notifier).setQuickFilter(IncidentQuickFilter.all),
          ),
          const SizedBox(width: 8),
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
        ],
      ),
    );
  }

  Widget _buildList(List<IncidentResponse> incidents, MapDataState mapData) {
    if (incidents.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 100),
          Center(
            child: Column(
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.white24),
                SizedBox(height: 16),
                Text('Инцидентов не найдено', style: TextStyle(color: Colors.white54, fontSize: 16)),
              ],
            ),
          ),
        ],
      );
    }

    final usersAsync = ref.watch(usersProvider);
    final users = usersAsync.value ?? [];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: incidents.length,
      itemBuilder: (context, index) {
        final inc = incidents[index];
        
        String? boilerHouseDetail;
        if (inc.boilerHouseId != null) {
          final bhId = inc.boilerHouseId!;
          // Find the boiler house in mapData to get manager and site info
          final bh = mapData.boilerHouses.firstWhere((b) => b.id == bhId, orElse: () => BoilerHouseResponse(id: bhId, address: '?', latitude: 0, longitude: 0, createdAt: ''));
          
          // Calculate active incident count for this boiler house
          final incidentCount = mapData.incidents.where((i) => 
            i.boilerHouseId == bhId && 
            i.status != IncidentStatus.resolved && 
            i.status != IncidentStatus.closed
          ).length;
          
          // Calculate house count
          final houseCount = mapData.locations.where((l) => l.boilerHouseId == bhId).length;
          
          boilerHouseDetail = '⚠️ Инциденты: $incidentCount | Нач: ${bh.siteManager ?? "?"} | Участок: ${bh.siteNumber ?? "?"} | 🏠 домов: $houseCount';
        }

        // Calculate affected population
        int totalResidents = 0;
        if (inc.affectedHouseDetails != null) {
          for (final hd in inc.affectedHouseDetails!) {
            totalResidents += (hd.residentsCount ?? 0);
          }
        }

        // Map assignedTo to actual user name
        String? assigneeName;
        if (inc.assignedTo != null) {
          try {
            final user = users.firstWhere((u) => u.id == inc.assignedTo);
            assigneeName = user.fullName ?? user.username;
          } catch (_) {
            assigneeName = 'Неизвестный (${inc.assignedTo})';
          }
        }

        return Slidable(
          key: ValueKey(inc.id),
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            extentRatio: 0.65, // Adjust based on 3 buttons width
            children: [
              if (inc.status == IncidentStatus.resolved || inc.status == IncidentStatus.closed)
                _buildCustomSlidableAction(
                  label: 'Возобновить',
                  icon: Icons.refresh,
                  color: Colors.orange,
                  onPressed: (_) => _resumeIncident(inc.id),
                )
              else
                _buildCustomSlidableAction(
                  label: 'Завершить',
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
                  onPressed: (_) => _completeIncident(inc.id),
                ),
              _buildCustomSlidableAction(
                label: 'Удалить',
                icon: Icons.delete_outline,
                color: Colors.redAccent,
                onPressed: (_) => _deleteIncident(inc.id, inc.title),
              ),
              _buildCustomSlidableAction(
                label: 'Редакт.',
                icon: Icons.edit,
                color: Colors.orange,
                onPressed: (_) => _editIncident(inc.id),
              ),
            ],
          ),
          child: IncidentCard(
            title: inc.title ?? 'Инцидент #${inc.id}',
            location: inc.boilerHouse?.address ?? 'Неизвестная локация',
            timestamp: _formatFullTimestamp(inc),
            statusText: inc.status == IncidentStatus.resolved ? 'ЗАВЕРШЁН' : 'АКТИВЕН',
            isStatusActive: inc.status != IncidentStatus.resolved && inc.status != IncidentStatus.closed,
            assigneeName: assigneeName,
            affectedPopulationCount: totalResidents,
            stoppedServicesText: _getStoppedServices(inc),
            broadcastText: _getBroadcastText(inc),
            isUnsynced: inc.localPendingAck == true,
            boilerHouseDetail: boilerHouseDetail,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => IncidentDetailScreen(incidentId: inc.id),
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _formatFullTimestamp(IncidentResponse inc) {
    final start = _formatDateTime(inc.createdAt);
    if (inc.status == IncidentStatus.resolved || inc.status == IncidentStatus.closed) {
      final end = _formatDateTime(inc.resolvedAt ?? inc.updatedAt);
      return 'с $start до $end';
    } else {
      return 'с $start до по наст. время';
    }
  }

  String _formatDateTime(String? dtString) {
    if (dtString == null || dtString.isEmpty) return '';
    final dt = DateTime.tryParse(dtString)?.toLocal();
    if (dt == null) return dtString;
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String? _getStoppedServices(IncidentResponse inc) {
    List<String> stopped = [];
    if (inc.resourceHotWaterStopped == 1) stopped.add('ГВС');
    if (inc.resourceHeatingStopped == 1) stopped.add('Отопление');
    return stopped.isEmpty ? null : stopped.join(', ');
  }

  String? _getBroadcastText(IncidentResponse inc) {
    if (inc.notificationConfig != null) {
      if (inc.notificationConfig!.type == AudienceType.broadcast) {
        return 'Все (Broadcast)';
      }
      return 'Роли/Пользователи (${inc.notificationConfig!.type.name})';
    }
    return null;
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
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Future<void> _completeIncident(int id) async {
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
    try {
      final service = ref.read(incidentServiceProvider);
      await service.updateIncident(id, IncidentUpdate(status: IncidentStatus.open));
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
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.secondaryDarkBackground,
          title: const Text('Удаление инцидента', style: TextStyle(color: Colors.white)),
          content: Text(
            'Вы уверены, что хотите удалить ${title ?? "#$id"}?',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Отмена', style: TextStyle(color: Colors.white70)),
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

  void _editIncident(int id) async {
    try {
      final service = ref.read(incidentServiceProvider);
      final incident = await service.getIncident(id);
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => IncidentFormScreen(initialIncident: incident),
          ),
        ).then((_) => ref.invalidate(allIncidentsProvider));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка загрузки инцидента: $e')));
      }
    }
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
        color: isSelected ? Colors.white : Colors.white70,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: StadiumBorder(
        side: BorderSide(color: isSelected ? AppTheme.primaryBlue : Colors.white24),
      ),
      showCheckmark: false,
    );
  }
}
