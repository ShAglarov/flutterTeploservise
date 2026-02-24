import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../providers/map_providers.dart';
import '../models/boiler_house_models.dart';
import '../models/location_models.dart';
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

  /// Currently selected boiler house for filtering the bottom list
  BoilerHouseResponse? _selectedBoilerHouse;

  /// Currently tapped item for the info popup
  dynamic _tappedItem; // BoilerHouseResponse or SavedLocationResponse
  LatLng? _tappedPosition;

  @override
  void dispose() {
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _onBoilerHouseMarkerTap(BoilerHouseResponse bh) {
    setState(() {
      _tappedItem = bh;
      _tappedPosition = LatLng(bh.latitude, bh.longitude);
    });
    _mapController.move(LatLng(bh.latitude, bh.longitude), _mapController.camera.zoom);
  }

  void _onLocationMarkerTap(SavedLocationResponse loc) {
    setState(() {
      _tappedItem = loc;
      _tappedPosition = LatLng(loc.latitude, loc.longitude);
    });
    _mapController.move(LatLng(loc.latitude, loc.longitude), _mapController.camera.zoom);
  }

  void _onPopupTap() {
    if (_tappedItem is BoilerHouseResponse) {
      // Filter the bottom list to show only houses of this boiler house
      setState(() {
        _selectedBoilerHouse = _tappedItem as BoilerHouseResponse;
        _tappedItem = null;
        _tappedPosition = null;
      });
    } else if (_tappedItem is SavedLocationResponse) {
      // Show house detail card
      final loc = _tappedItem as SavedLocationResponse;
      setState(() {
        _tappedItem = null;
        _tappedPosition = null;
      });
      _showHouseDetailSheet(loc);
    }
  }

  void _dismissPopup() {
    setState(() {
      _tappedItem = null;
      _tappedPosition = null;
    });
  }

  void _clearBoilerHouseFilter() {
    setState(() {
      _selectedBoilerHouse = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mapData = ref.watch(filteredMapDataProvider);
    final sections = ref.watch(mapSectionsProvider);

    return Scaffold(
      body: Stack(
        children: [
          // 1. FlutterMap Layer
          GestureDetector(
            onTap: _dismissPopup,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: const LatLng(42.9849, 47.5047), // Makhachkala
                initialZoom: 13,
                onTap: (_, __) => _dismissPopup(),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.teploservice',
                  tileBuilder: _darkModeTileBuilder,
                ),
                // Green polylines from boiler houses to their houses
                PolylineLayer(
                  polylines: _buildPolylines(mapData),
                ),
                MarkerLayer(
                  markers: _buildMarkers(mapData),
                ),
              ],
            ),
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

          // 3. Info Popup (shows on pin tap)
          if (_tappedItem != null && _tappedPosition != null)
            _buildInfoPopup(),

          // 4. Draggable Bottom Sheet
          _buildDraggableSheet(mapData),
          
          // 5. Map Action Buttons
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

  // --------------------------------------------------------------------------
  // Dark mode tile overlay
  // --------------------------------------------------------------------------
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

  // --------------------------------------------------------------------------
  // Green polylines: boiler house → linked houses
  // --------------------------------------------------------------------------
  List<Polyline> _buildPolylines(MapDataState data) {
    final polylines = <Polyline>[];

    for (final bh in data.boilerHouses) {
      if (_selectedBoilerHouse != null && bh.id != _selectedBoilerHouse!.id) continue;

      if (bh.latitude == 0 && bh.longitude == 0) continue;
      final bhPoint = LatLng(bh.latitude, bh.longitude);

      // Find all locations linked to this boiler house
      for (final loc in data.locations) {
        if (loc.boilerHouseId == bh.id && loc.latitude != 0 && loc.longitude != 0) {
          polylines.add(Polyline(
            points: [bhPoint, LatLng(loc.latitude, loc.longitude)],
            color: Colors.green.withOpacity(0.6),
            strokeWidth: 2.0,
          ));
        }
      }
    }

    return polylines;
  }

  // --------------------------------------------------------------------------
  // Markers
  // --------------------------------------------------------------------------
  List<Marker> _buildMarkers(MapDataState data) {
    final markers = <Marker>[];

    for (final bh in data.boilerHouses) {
      if (_selectedBoilerHouse != null && bh.id != _selectedBoilerHouse!.id) continue;
      
      if (bh.latitude == 0 && bh.longitude == 0) continue;
      final hasIncident = bh.incidentCount != null && bh.incidentCount! > 0;
      final isSelected = _tappedItem is BoilerHouseResponse && (_tappedItem as BoilerHouseResponse).id == bh.id;
      markers.add(Marker(
        point: LatLng(bh.latitude, bh.longitude),
        width: isSelected ? 44 : 36,
        height: isSelected ? 44 : 36,
        child: GestureDetector(
          onTap: () => _onBoilerHouseMarkerTap(bh),
          child: Container(
            decoration: BoxDecoration(
              color: hasIncident ? AppTheme.errorRed : AppTheme.primaryBlue,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.yellow : Colors.white,
                width: isSelected ? 3 : 2,
              ),
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
      if (_selectedBoilerHouse != null && loc.boilerHouseId != _selectedBoilerHouse!.id) continue;

      if (loc.latitude == 0 && loc.longitude == 0) continue;
      final isSelected = _tappedItem is SavedLocationResponse && (_tappedItem as SavedLocationResponse).id == loc.id;
      markers.add(Marker(
        point: LatLng(loc.latitude, loc.longitude),
        width: isSelected ? 34 : 28,
        height: isSelected ? 34 : 28,
        child: GestureDetector(
          onTap: () => _onLocationMarkerTap(loc),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.successGreen,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.yellow : Colors.white,
                width: isSelected ? 2.5 : 1.5,
              ),
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

  // --------------------------------------------------------------------------
  // Info Popup (floating callout on pin tap)
  // --------------------------------------------------------------------------
  Widget _buildInfoPopup() {
    final isBoilerHouse = _tappedItem is BoilerHouseResponse;
    String title;
    String subtitle;
    Color accentColor;
    IconData icon;

    if (isBoilerHouse) {
      final bh = _tappedItem as BoilerHouseResponse;
      title = bh.address;
      subtitle = 'Котельная • Уч. ${bh.siteNumber ?? '?'}';
      if (bh.incidentCount != null && bh.incidentCount! > 0) {
        subtitle += ' • ${bh.incidentCount} инцид.';
      }
      accentColor = (bh.incidentCount ?? 0) > 0 ? AppTheme.errorRed : AppTheme.primaryBlue;
      icon = Icons.factory;
    } else {
      final loc = _tappedItem as SavedLocationResponse;
      title = loc.name;
      subtitle = 'Дом';
      if (loc.floors != null) subtitle += ' • ${loc.floors} эт.';
      if (loc.residentsCount != null) subtitle += ' • ${loc.residentsCount} жил.';
      accentColor = AppTheme.successGreen;
      icon = Icons.home;
    }

    return Positioned(
      top: MediaQuery.of(context).padding.top + 100,
      left: 20,
      right: 20,
      child: GestureDetector(
        onTap: _onPopupTap,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: accentColor.withOpacity(0.5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: accentColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.4)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Search Bar
  // --------------------------------------------------------------------------
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
                    hintText: 'Название, начальник, участок, УК/ВО...',
                    hintStyle: TextStyle(color: Colors.white.withAlpha(128), fontSize: 13),
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

  // --------------------------------------------------------------------------
  // Map Action Buttons
  // --------------------------------------------------------------------------
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

  // --------------------------------------------------------------------------
  // Draggable Bottom Sheet
  // --------------------------------------------------------------------------
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

              // Header with back button when filtering by boiler house
              if (_selectedBoilerHouse != null)
                _buildFilterHeader(),
              
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

  Widget _buildFilterHeader() {
    final bh = _selectedBoilerHouse!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppTheme.primaryBlue, size: 20),
            onPressed: _clearBoilerHouseFilter,
            tooltip: 'Показать все',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bh.address,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Дома котельной',
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(MapDataState data, ScrollController scrollController) {
    // If a boiler house is selected, show only its linked houses
    if (_selectedBoilerHouse != null) {
      final filteredLocations = data.locations
          .where((loc) => loc.boilerHouseId == _selectedBoilerHouse!.id)
          .toList();

      if (filteredLocations.isEmpty) {
        return const Center(
          child: Text('Нет привязанных домов', style: TextStyle(color: Colors.white54)),
        );
      }

      return ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(6, 0, 6, 40),
        itemCount: filteredLocations.length,
        itemBuilder: (context, index) => _buildLocationItem(filteredLocations[index]),
      );
    }

    // Default: show ONLY boiler houses in the list (no locations)
    final totalItems = data.boilerHouses.length;
    
    if (totalItems == 0) {
      return const Center(child: Text('Нет результатов', style: TextStyle(color: Colors.white54)));
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(6, 0, 6, 40),
      itemCount: totalItems,
      itemBuilder: (context, index) {
        return _buildBoilerHouseItem(data.boilerHouses[index]);
      },
    );
  }

  // --------------------------------------------------------------------------
  // List Items
  // --------------------------------------------------------------------------
  Widget _buildBoilerHouseItem(BoilerHouseResponse bh) {
    final hasIncident = bh.incidentCount != null && bh.incidentCount! > 0;
    
    return BaseCard(
      onTap: () {
        setState(() {
          _selectedBoilerHouse = bh;
          _tappedItem = null;
          _tappedPosition = null;
        });
        _mapController.move(LatLng(bh.latitude, bh.longitude), 14);
      },
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
                  bh.address, 
                  style: Theme.of(context).textTheme.headlineMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('Нач: ${bh.siteManager ?? '?'} | Участок: ${bh.siteNumber ?? '?'}', 
                         style: Theme.of(context).textTheme.labelSmall),
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

  Widget _buildLocationItem(SavedLocationResponse loc) {
    return BaseCard(
      onTap: () {
        if (loc.latitude != 0 && loc.longitude != 0) {
          _mapController.move(LatLng(loc.latitude, loc.longitude), 16);
        }
        _showHouseDetailSheet(loc);
      },
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
                  loc.name, 
                  style: Theme.of(context).textTheme.headlineMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _buildLocationSubtitle(loc), 
                  style: Theme.of(context).textTheme.labelSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Show number of accounts if available
          if (loc.accounts != null && loc.accounts!.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${loc.accounts!.length}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: Colors.white24),
        ],
      ),
    );
  }

  String _buildLocationSubtitle(SavedLocationResponse loc) {
    final parts = <String>[];
    if (loc.floors != null && loc.floors! > 0) parts.add('${loc.floors} эт.');
    if (loc.residentsCount != null && loc.residentsCount! > 0) parts.add('${loc.residentsCount} жил.');
    if (loc.managementCompanyName != null) parts.add(loc.managementCompanyName!);
    return parts.isEmpty ? '' : parts.join(' • ');
  }

  // --------------------------------------------------------------------------
  // House Detail Bottom Sheet
  // --------------------------------------------------------------------------
  void _showHouseDetailSheet(SavedLocationResponse loc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          builder: (ctx, controller) {
            return Container(
              decoration: BoxDecoration(
                color: AppTheme.darkBackground,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(color: Colors.white.withAlpha(20)),
              ),
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.all(20),
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(50),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Title
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.successGreen.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.home, color: AppTheme.successGreen, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          loc.name,
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Info Card
                  _buildDetailCard('Информация о доме', [
                    _detailRow('Этажи', loc.floors?.toString()),
                    _detailRow('Кол-во жителей', loc.residentsCount?.toString()),
                    _detailRow('Комнаты', loc.rooms?.toString()),
                    _detailRow('Площадь', loc.totalArea != null ? '${loc.totalArea} м²' : null),
                    _detailRow('Год постройки', loc.yearBuilt?.toString()),
                    _detailRow('Отопление', loc.providesHeating == true ? 'Да' : (loc.providesHeating == false ? 'Нет' : null)),
                    _detailRow('ГВС', loc.providesHotWater == true ? 'Да' : (loc.providesHotWater == false ? 'Нет' : null)),
                    _detailRow('УК', loc.managementCompanyName),
                  ]),

                  if (loc.latitude != 0 && loc.longitude != 0) ...[
                    const SizedBox(height: 12),
                    _buildDetailCard('Координаты', [
                      _detailRow('Широта', loc.latitude.toStringAsFixed(6)),
                      _detailRow('Долгота', loc.longitude.toStringAsFixed(6)),
                    ]),
                  ],

                  if (loc.accounts != null && loc.accounts!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildDetailCard('Лицевые счета (${loc.accounts!.length})', [
                      for (final acc in loc.accounts!)
                        _detailRow(acc.accountNumber, acc.fio ?? acc.address ?? ''),
                    ]),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailCard(String title, List<Widget> rows) {
    // Filter out null-valued rows
    final validRows = rows.whereType<Widget>().toList();
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text(
              title,
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          ...validRows,
        ],
      ),
    );
  }

  Widget _detailRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14)),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
