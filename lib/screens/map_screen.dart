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

  final DraggableScrollableController _sheetController = DraggableScrollableController();
  bool _isSheetHidden = false;

  @override
  void dispose() {
    _searchController.dispose();
    _mapController.dispose();
    _sheetController.dispose();
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
      setState(() {
        _selectedBoilerHouse = _tappedItem as BoilerHouseResponse;
        _tappedItem = null;
        _tappedPosition = null;
      });
      _expandSheet();
    } else if (_tappedItem is SavedLocationResponse) {
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

  void _toggleSheet() {
    if (_sheetController.size > 0.1) {
      _sheetController.animateTo(0.05, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _isSheetHidden = true);
    } else {
      _sheetController.animateTo(0.5, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _isSheetHidden = false);
    }
  }

  void _expandSheet() {
    _sheetController.animateTo(0.5, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    setState(() => _isSheetHidden = false);
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
      backgroundColor: AppTheme.darkBackground,
      body: Stack(
        children: [
          // 1. FlutterMap Layer
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggleSheet,
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: const LatLng(42.9849, 47.5047),
                  initialZoom: 13,
                  onTap: (_, __) => _toggleSheet(),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.teploservice',
                    tileBuilder: _darkModeTileBuilder,
                  ),
                  PolylineLayer(polylines: _buildPolylines(mapData)),
                  MarkerLayer(markers: _buildMarkers(mapData)),
                ],
              ),
            ),
          ),

          // 2. Info Popup (shows on pin tap)
          if (_tappedItem != null && _tappedPosition != null)
            _buildInfoPopup(),

          // 3. Top-Left Control Buttons (Journal & Incidents)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 12.0, top: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopButton(
                    label: 'Журнал',
                    icon: Icons.assignment_outlined,
                    color: AppTheme.successGreen,
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  _buildTopButton(
                    label: 'Инциденты',
                    icon: Icons.warning_amber_rounded,
                    color: AppTheme.errorRed,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),

          // 4. Top-Right Floating Menu Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 12,
            child: _buildFloatingMenu(),
          ),

          // 5. Draggable Bottom Sheet with Search Bar Inside
          _buildDraggableSheet(mapData, sections),

          if (mapData.isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _buildTopButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isCircle = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: label.isNotEmpty ? const EdgeInsets.symmetric(horizontal: 10, vertical: 4) : const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(isCircle ? 24 : 8),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(label, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingMenu() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // The main trigger button (blue circular)
        GestureDetector(
          onTap: () {
            // Toggle menu expansion state if needed, or show a simple overlay/dialog
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8)],
            ),
            child: const Icon(Icons.tune, color: Colors.white, size: 24),
          ),
        ),
        const SizedBox(height: 8),
        // Menu Items (shown stacked like in high-end apps)
        _buildMenuItem(Icons.business, 'Упр. компания'),
        const SizedBox(height: 6),
        _buildMenuItem(Icons.search, 'Найти'),
        const SizedBox(height: 6),
        _buildMenuItem(Icons.settings, 'Настройки'),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground.withOpacity(0.9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
          const SizedBox(width: 8),
          Icon(icon, color: Colors.white60, size: 16),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Draggable Bottom Sheet
  // --------------------------------------------------------------------------
  Widget _buildDraggableSheet(MapDataState data, List<String> sections) {
    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: 0.5,
      minChildSize: 0.05,
      maxChildSize: 0.5,
      snap: true,
      snapSizes: const [0.05, 0.5],
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.darkBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20),
            ],
          ),
          child: Column(
            children: [
              // 1. Draggable Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // 2. Search Bar ATTACHED to the sheet
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: _buildSearchBar(sections),
              ),

              // 3. Header with back button when filtering
              if (_selectedBoilerHouse != null)
                _buildFilterHeader(),
              
              // 4. List Content
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

  // --------------------------------------------------------------------------
  // Search Bar (Updated style to match screenshot)
  // --------------------------------------------------------------------------
  Widget _buildSearchBar(List<String> sections) {
    final searchQuery = ref.watch(mapSearchQueryProvider);
    final filter = ref.watch(mapFilterProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: Colors.white.withOpacity(0.5), size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => ref.read(mapSearchQueryProvider.notifier).update(value),
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Поиск...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 13),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              if (searchQuery.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white30, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(mapSearchQueryProvider.notifier).update('');
                  },
                ),
              const VerticalDivider(width: 16, indent: 8, endIndent: 8, color: Colors.white12),
              IconButton(
                icon: Icon(
                  filter.showOnlyIncidents ? Icons.warning : Icons.warning_amber_outlined,
                  color: filter.showOnlyIncidents ? AppTheme.errorRed : Colors.white60,
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => ref.read(mapFilterProvider.notifier).toggleOnlyIncidents(),
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
        if (sections.isNotEmpty)
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(top: 8),
              children: [
                _buildFilterChip(
                  label: 'Все',
                  isSelected: filter.selectedSection == null,
                  onSelected: () => ref.read(mapFilterProvider.notifier).setSection(null),
                ),
                ...sections.map((section) => _buildFilterChip(
                      label: 'Уч. $section',
                      isSelected: filter.selectedSection == section,
                      onSelected: () => ref.read(mapFilterProvider.notifier).setSection(section),
                    )),
              ],
            ),
          ),
      ],
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
      // ONLY SHOW HOUSES LINKED TO BOILER HOUSES
      if (loc.boilerHouseId == null || loc.boilerHouseId == 0) continue;

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

  Widget _buildList(MapDataState data, ScrollController scrollController) {
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
        itemBuilder: (context, index) => _buildLocationItem(context, filteredLocations[index]),
      );
    }

    final totalItems = data.boilerHouses.length;
    
    if (totalItems == 0) {
      return const Center(child: Text('Нет результатов', style: TextStyle(color: Colors.white54)));
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(6, 0, 6, 40),
      itemCount: totalItems,
      itemBuilder: (context, index) {
        return _buildBoilerHouseItem(context, data.boilerHouses[index]);
      },
    );
  }

  Widget _buildBoilerHouseItem(BuildContext context, BoilerHouseResponse bh) {
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

  Widget _buildLocationItem(BuildContext context, SavedLocationResponse loc) {
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

  // --------------------------------------------------------------------------
  // Search Bar
  // --------------------------------------------------------------------------


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
