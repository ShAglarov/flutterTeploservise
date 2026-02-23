import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/incident_providers.dart';
import '../widgets/incident_card.dart';
import '../utils/app_theme.dart';
import '../models/incident_models.dart';
import 'incident_detail_screen.dart';
import 'incident_form_screen.dart';

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
          data: (incidents) => _buildList(incidents),
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

  Widget _buildList(List<IncidentResponse> incidents) {
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

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: incidents.length,
      itemBuilder: (context, index) {
        final inc = incidents[index];
        return IncidentCard(
          title: inc.title ?? 'Инцидент #${inc.id}',
          location: inc.boilerHouse?.address ?? 'Неизвестная локация',
          timestamp: _formatTimestamp(inc.createdAt),
          statusText: inc.status == IncidentStatus.resolved ? 'ЗАВЕРШЁН' : 'АКТИВЕН',
          isStatusActive: inc.status != IncidentStatus.resolved,
          affectedPopulationCount: 0, // Should be calculated if data is available
          stoppedServicesText: _getStoppedServices(inc),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => IncidentDetailScreen(incidentId: inc.id),
              ),
            );
          },
        );
      },
    );
  }

  String _formatTimestamp(String? createdAt) {
    if (createdAt == null) return '';
    // Placeholder for real formatting
    final date = DateTime.tryParse(createdAt);
    if (date == null) return createdAt;
    return '${date.day}.${date.month} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String? _getStoppedServices(IncidentResponse inc) {
    List<String> stopped = [];
    if (inc.resourceHotWaterStopped == 1) stopped.add('ГВС');
    if (inc.resourceHeatingStopped == 1) stopped.add('Отопление');
    return stopped.isEmpty ? null : stopped.join(', ');
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
