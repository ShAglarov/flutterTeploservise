import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../providers/map_providers.dart';
import '../utils/app_theme.dart';
import '../widgets/base_card.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();

  @override
  void dispose() {
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _onItemTap(double lat, double lng) {
    _mapController.move(LatLng(lat, lng), 15);
  }

  @override
  Widget build(BuildContext context) {
    final mapData = ref.watch(filteredMapDataProvider);
    final sections = ref.watch(mapSectionsProvider);

    return Scaffold(
      body: Stack(
        children: [
          // 1. FlutterMap Layer (OpenStreetMap)
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(59.9343, 30.3351), // St. Petersburg
              initialZoom: 11,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.teploservice',
                tileBuilder: _darkModeTileBuilder,
              ),
              MarkerLayer(
                markers: _buildMarkers(mapData),
              ),
            ],
          ),

          // 2. Search Top Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                children: [
                  _buildSearchBar(sections),
                ],
              ),
            ),
          ),

          // 3. Draggable Bottom Sheet
          _buildDraggableSheet(mapData),
          
          // 4. Map Action Buttons
          Positioned(
            right: 16,
            bottom: 160,
            child: _buildMapActions(),
          ),

          if (mapData.isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  // Dark mode tile overlay
  Widget _darkModeTileBuilder(BuildContext context, Widget tileWidget, TileImage tile) {
    return ColorFiltered(
      colorFilter: const ColorFilter.matrix(<double>[
        -0.2126, -0.7152, -0.0722, 0, 255,
        -0.2126, -0.7152, -0.0722, 0, 255,
        -0.2126, -0.7152, -0.0722, 0, 255,
         0,       0,       0,      1,   0,
      ]),
      child: tileWidget,
    );
  }

  List<Marker> _buildMarkers(MapDataState data) {
    final markers = <Marker>[];

    for (final bh in data.boilerHouses) {
      if (bh.latitude == 0 && bh.longitude == 0) continue;
      final hasIncident = bh.incidentCount != null && bh.incidentCount! > 0;
      markers.add(Marker(
        point: LatLng(bh.latitude, bh.longitude),
        width: 36,
        height: 36,
        child: GestureDetector(
          onTap: () => _onItemTap(bh.latitude, bh.longitude),
          child: Container(
            decoration: BoxDecoration(
              color: hasIncident ? AppTheme.errorRed : AppTheme.primaryBlue,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 4),
              ],
            ),
            child: const Icon(Icons.factory, color: Colors.white, size: 18),
          ),
        ),
      ));
    }

    for (final loc in data.locations) {
      if (loc.latitude == 0 && loc.longitude == 0) continue;
      markers.add(Marker(
        point: LatLng(loc.latitude, loc.longitude),
        width: 28,
        height: 28,
        child: GestureDetector(
          onTap: () => _onItemTap(loc.latitude, loc.longitude),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.successGreen,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 4),
              ],
            ),
            child: const Icon(Icons.home, color: Colors.white, size: 14),
          ),
        ),
      ));
    }

    return markers;
  }

  Widget _buildSearchBar(List<String> sections) {
    final searchQuery = ref.watch(mapSearchQueryProvider);
    final filter = ref.watch(mapFilterProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground.withAlpha(230),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => ref.read(mapSearchQueryProvider.notifier).update(value),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Поиск...',
                    hintStyle: TextStyle(color: Colors.white.withAlpha(128)),
                    prefixIcon: const Icon(Icons.search, color: AppTheme.primaryBlue),
                    border: InputBorder.none,
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.white60),
                            onPressed: () {
                              _searchController.clear();
                              ref.read(mapSearchQueryProvider.notifier).update('');
                            },
                          )
                        : null,
                  ),
                ),
              ),
              const VerticalDivider(width: 1, color: Colors.white24),
              IconButton(
                icon: Icon(
                  filter.showOnlyIncidents ? Icons.warning : Icons.warning_amber_outlined,
                  color: filter.showOnlyIncidents ? AppTheme.errorRed : Colors.white60,
                ),
                onPressed: () => ref.read(mapFilterProvider.notifier).toggleOnlyIncidents(),
                tooltip: 'Только с инцидентами',
              ),
            ],
          ),
          if (sections.isNotEmpty) ...[
            const Divider(height: 1, color: Colors.white12),
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildFilterChip(
                    label: 'Все участки',
                    isSelected: filter.selectedSection == null,
                    onSelected: () => ref.read(mapFilterProvider.notifier).setSection(null),
                  ),
                  ...sections.map((section) => _buildFilterChip(
                        label: 'Участок $section',
                        isSelected: filter.selectedSection == section,
                        onSelected: () => ref.read(mapFilterProvider.notifier).setSection(section),
                      )),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label, style: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
          fontSize: 12,
        )),
        selected: isSelected,
        onSelected: (_) => onSelected(),
        selectedColor: AppTheme.primaryBlue.withAlpha(100),
        backgroundColor: Colors.transparent,
        shape: StadiumBorder(side: BorderSide(
          color: isSelected ? AppTheme.primaryBlue : Colors.white24,
        )),
        showCheckmark: false,
      ),
    );
  }

  Widget _buildMapActions() {
    return Column(
      children: [
        _mapActionButton(
          icon: Icons.my_location,
          onPressed: () {
            // TODO: Use geolocator to get current pos
          },
        ),
        const SizedBox(height: 12),
        _mapActionButton(
          icon: Icons.layers,
          onPressed: () {
            // Show map type dialog
          },
        ),
      ],
    );
  }

  Widget _mapActionButton({required IconData icon, required VoidCallback onPressed}) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppTheme.secondaryDarkBackground.withAlpha(230),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withAlpha(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(80),
            blurRadius: 10,
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: AppTheme.primaryBlue, size: 24),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildDraggableSheet(MapDataState data) {
    return DraggableScrollableSheet(
      initialChildSize: 0.35,
      minChildSize: 0.15,
      maxChildSize: 0.9,
      snap: true,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.darkBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border.all(color: Colors.white.withAlpha(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(150),
                blurRadius: 30,
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(50),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // List Content
              Expanded(
                child: data.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildList(data, scrollController),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildList(MapDataState data, ScrollController scrollController) {
    final totalItems = data.boilerHouses.length + data.locations.length;
    
    if (totalItems == 0) {
      return const Center(child: Text('Нет результатов', style: TextStyle(color: Colors.white54)));
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(6, 0, 6, 40),
      itemCount: totalItems,
      itemBuilder: (context, index) {
        if (index < data.boilerHouses.length) {
          final bh = data.boilerHouses[index];
          return _buildBoilerHouseItem(bh);
        } else {
          final loc = data.locations[index - data.boilerHouses.length];
          return _buildLocationItem(loc);
        }
      },
    );
  }

  Widget _buildBoilerHouseItem(dynamic bh) {
    final hasIncident = bh.incidentCount != null && bh.incidentCount! > 0;
    
    return BaseCard(
      onTap: () => _onItemTap(bh.latitude, bh.longitude),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (hasIncident ? AppTheme.errorRed : AppTheme.primaryBlue).withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.factory, 
              color: hasIncident ? AppTheme.errorRed : AppTheme.primaryBlue, 
              size: 24
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bh.address ?? 'No Address', 
                  style: Theme.of(context).textTheme.headlineMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('Уч. ${bh.siteNumber ?? '?'}', style: Theme.of(context).textTheme.labelSmall),
                    if (hasIncident) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.errorRed,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${bh.incidentCount} ИНЦИД.',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.white24),
        ],
      ),
    );
  }

  Widget _buildLocationItem(dynamic loc) {
    return BaseCard(
      onTap: () => _onItemTap(loc.latitude, loc.longitude),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.successGreen.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.home, color: AppTheme.successGreen, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.name ?? 'Без названия', 
                  style: Theme.of(context).textTheme.headlineMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  loc.managementCompanyId ?? '', 
                  style: Theme.of(context).textTheme.labelSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.white24),
        ],
      ),
    );
  }
}
