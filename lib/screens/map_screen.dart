import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:image_picker/image_picker.dart';
import 'incident_list_screen.dart';
import 'action_log_list_screen.dart';
import '../providers/connectivity_provider.dart';
import '../providers/map_providers.dart';
import '../providers/incident_providers.dart';
import '../models/boiler_house_models.dart';
import '../models/location_models.dart';
import '../models/incident_models.dart';
import '../services/location_service.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../widgets/base_card.dart';
import '../widgets/fullscreen_image_viewer.dart';
import '../widgets/boiler_house_form_dialog.dart';
import '../widgets/house_form_dialog.dart';
import '../widgets/house_incident_form_dialog.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../services/boiler_house_service.dart';

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
  bool _showSuccessAnimation = false;
  bool _isMenuOpen = false;

  /// Cached markers to avoid rebuilding the entire list on unrelated state changes
  List<Marker> _cachedMarkers = [];
  List<Polyline> _cachedPolylines = [];
  /// Tracks which boiler house is selected for marker filtering (to invalidate cache)
  int? _cachedSelectedBhId;
  /// Tracks which item is tapped (to invalidate cache for selection highlight)
  dynamic _cachedTappedItem;
  /// Tracks marker-relevant data to avoid rebuilding on unrelated state changes
  int _cachedBhCount = -1;
  int _cachedLocCount = -1;
  Set<int> _cachedBhIncidentIds = {};
  Set<int> _cachedLocIncidentIds = {};

  /// Value-based set equality check
  bool _setsEqual(Set<int> a, Set<int> b) {
    if (a.length != b.length) return false;
    return a.containsAll(b);
  }

  void _onBoilerHouseMarkerTap(BoilerHouseResponse bh) {
    setState(() {
      _tappedItem = bh;
      _tappedPosition = LatLng(bh.latitude, bh.longitude);
    });
    _mapController.move(LatLng(bh.latitude, bh.longitude), _mapController.camera.zoom);
  }

  StreamSubscription<void>? _refreshSubscription;

  @override
  void initState() {
    super.initState();
    // Force a complete rebuild of the map data if a global refresh is triggered
    _refreshSubscription = ref.read(globalRefreshEventControllerProvider).stream.listen((_) {
      if (mounted) {
        ref.invalidate(mapDataProvider);
      }
    });
  }

  @override
  void dispose() {
    _refreshSubscription?.cancel();
    _searchController.dispose();
    _mapController.dispose();
    _sheetController.dispose();
    super.dispose();
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

  void _onMapTap() {
    setState(() {
      _isMenuOpen = false;
    });

    if (_tappedItem != null) {
      _dismissPopup();
    } else {
      _toggleSheet();
    }
  }

  Future<void> _onMapLongPress(TapPosition tapPosition, LatLng point) async {
    if (_selectedBoilerHouse == null) {
      // Create Boiler House
      final result = await showDialog<BoilerHouseResponse>(
        context: context,
        builder: (context) => BoilerHouseFormDialog(position: point),
      );
      
      if (result != null) {
        ref.invalidate(mapDataProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Котельная успешно добавлена')),
          );
        }
      }
    } else {
      // Create House linked to selected Boiler House
      final result = await showDialog<SavedLocationResponse>(
        context: context,
        builder: (context) => HouseFormDialog(
          position: point,
          boilerHouseId: _selectedBoilerHouse!.id,
        ),
      );
      
      if (result != null) {
        ref.invalidate(mapDataProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Дом успешно добавлен')),
          );
          _showHouseDetailSheet(result);
        }
      }
    }
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
    final isOffline = ref.watch(isOfflineProvider);

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Stack(
        children: [
          // 1. FlutterMap Layer
          Positioned.fill(
            child: GestureDetector(
              onTap: _onMapTap,
              child: Builder(builder: (context) {
                // Rebuild markers only when marker-RELEVANT data actually changed,
                // not on every MapDataState reference change. This prevents
                // rapid rebuilds from multiple WebSocket updates.
                final selectedBhId = _selectedBoilerHouse?.id;
                final needsRebuild = _cachedMarkers.isEmpty ||
                    _cachedSelectedBhId != selectedBhId ||
                    !identical(_cachedTappedItem, _tappedItem) ||
                    _cachedBhCount != mapData.boilerHouses.length ||
                    _cachedLocCount != mapData.locations.length ||
                    !_setsEqual(_cachedBhIncidentIds, mapData.boilerHouseIdsWithIncidents) ||
                    !_setsEqual(_cachedLocIncidentIds, mapData.locationIdsWithIncidents);
                if (needsRebuild) {
                  _cachedMarkers = _buildMarkers(mapData);
                  _cachedPolylines = _buildPolylines(mapData);
                  _cachedSelectedBhId = selectedBhId;
                  _cachedTappedItem = _tappedItem;
                  _cachedBhCount = mapData.boilerHouses.length;
                  _cachedLocCount = mapData.locations.length;
                  _cachedBhIncidentIds = Set.of(mapData.boilerHouseIdsWithIncidents);
                  _cachedLocIncidentIds = Set.of(mapData.locationIdsWithIncidents);
                }
                return FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: const LatLng(42.9849, 47.5047),
                    initialZoom: 13,
                    onTap: (_, __) => _onMapTap(),
                    onLongPress: _onMapLongPress,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.teploservice',
                      tileBuilder: _darkModeTileBuilder,
                    ),
                    PolylineLayer(polylines: _cachedPolylines),
                    MarkerLayer(markers: _cachedMarkers),
                  ],
                );
              }),
            ),
          ),

          // Offline Banner
          if (isOffline)
            Positioned(
              top: MediaQuery.of(context).padding.top,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.red.withOpacity(0.9),
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: const Text(
                  'Нет подключения к сети',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ActionLogListScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Builder(
                    builder: (context) {
                      // Live count of active incidents
                      final activeCount = ref.watch(allIncidentsProvider).whenOrNull(
                        data: (incidents) => incidents.where((i) {
                          final s = i.status;
                          return s != IncidentStatus.resolved && s != IncidentStatus.closed;
                        }).length,
                      ) ?? 0;
                      return _buildTopButton(
                        label: 'Инциденты',
                        icon: Icons.chat_outlined,
                        color: activeCount > 0 ? AppTheme.errorRed : AppTheme.successGreen,
                        badgeCount: activeCount,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const IncidentListScreen()),
                          );
                        },
                      );
                    },
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
    int badgeCount = 0,
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
            if (badgeCount > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
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
            setState(() {
              _isMenuOpen = !_isMenuOpen;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8)],
            ),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: _isMenuOpen ? 1.0 : 0.0),
              duration: const Duration(milliseconds: 200),
              builder: (context, value, child) {
                return Transform.rotate(
                  angle: value * 3.14159 / 4, // rotate 45 degrees
                  child: Icon(
                    _isMenuOpen ? Icons.close : Icons.tune,
                    color: Colors.white,
                    size: 24,
                  ),
                );
              },
            ),
          ),
        ),
        
        // Menu Items (shown stacked like in high-end apps)
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          height: _isMenuOpen ? 140 : 0, // Match the height roughly to fit the 3 buttons
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 150),
              opacity: _isMenuOpen ? 1.0 : 0.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const SizedBox(height: 12),
                  _buildMenuItem(Icons.business, 'Упр. компания', () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Раздел Управляющие компании скоро появится')),
                    );
                  }),
                  const SizedBox(height: 8),
                  _buildMenuItem(Icons.search, 'Найти', () {
                    if (_isSheetHidden) {
                      _toggleSheet(); // Just expand the sheet so search is visible
                    }
                  }),
                  const SizedBox(height: 8),
                  _buildMenuItem(Icons.settings, 'Настройки', () {
                     ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Настройки скоро появятся')),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isMenuOpen = false;
        });
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground.withOpacity(0.95),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(width: 10),
            Icon(icon, color: Colors.white70, size: 18),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Draggable Bottom Sheet
  // --------------------------------------------------------------------------
  Widget _buildDraggableSheet(MapDataState mapData, List<String> sections) {
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
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                mapData.isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(child: CircularProgressIndicator()))
                    : _buildList(mapData),
              ],
            ),
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
      final hasIncident = data.boilerHouseIdsWithIncidents.contains(bh.id);
      final isSelected = _tappedItem is BoilerHouseResponse && (_tappedItem as BoilerHouseResponse).id == bh.id;
      markers.add(Marker(
        key: ValueKey('bh_${bh.id}'),
        point: LatLng(bh.latitude, bh.longitude),
        width: isSelected ? 44 : 36,
        height: isSelected ? 44 : 36,
        child: RepaintBoundary(
          child: GestureDetector(
            onTap: () => _onBoilerHouseMarkerTap(bh),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
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
        key: ValueKey('loc_${loc.id}'),
        point: LatLng(loc.latitude, loc.longitude),
        width: isSelected ? 34 : 28,
        height: isSelected ? 34 : 28,
        child: RepaintBoundary(
          child: GestureDetector(
            onTap: () => _onLocationMarkerTap(loc),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color: data.locationIdsWithIncidents.contains(loc.id)
                    ? AppTheme.errorRed
                    : AppTheme.successGreen,
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
      
      // Calculate local active incident count
      final data = ref.read(filteredMapDataProvider);
      final activeIncidents = data.incidents.where((inc) => 
        inc.boilerHouseId == bh.id && 
        inc.status != IncidentStatus.resolved && 
        inc.status != IncidentStatus.closed
      ).toList();
      final incidentCount = activeIncidents.length;

      subtitle = 'Котельная • Уч. ${bh.siteNumber ?? '?'}';
      if (incidentCount > 0) {
        subtitle += ' • $incidentCount инцид.';
      }
      accentColor = incidentCount > 0 ? AppTheme.errorRed : AppTheme.primaryBlue;
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

  Widget _buildList(MapDataState data) {
    if (_selectedBoilerHouse != null) {
      final filteredLocations = data.locations
          .where((loc) => loc.boilerHouseId == _selectedBoilerHouse!.id)
          .toList();

      if (filteredLocations.isEmpty) {
        return const Padding(
          padding: EdgeInsets.only(top: 40),
          child: Center(child: Text('Нет привязанных домов', style: TextStyle(color: Colors.white54))),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(6, 0, 6, 40),
        itemCount: filteredLocations.length,
        itemBuilder: (context, index) => _buildLocationItem(context, filteredLocations[index]),
      );
    }

    final totalItems = data.boilerHouses.length;
    
    if (totalItems == 0) {
      return const Padding(
        padding: EdgeInsets.only(top: 40),
        child: Center(child: Text('Нет результатов', style: TextStyle(color: Colors.white54))),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(6, 0, 6, 40),
      itemCount: totalItems,
      itemBuilder: (context, index) {
        return _buildBoilerHouseItem(context, data, data.boilerHouses[index]);
      },
    );
  }

  Widget _buildBoilerHouseItem(BuildContext context, MapDataState data, BoilerHouseResponse bh) {
    // Calculate local active incident count
    final activeIncidents = data.incidents.where((inc) => 
      inc.boilerHouseId == bh.id && 
      inc.status != IncidentStatus.resolved && 
      inc.status != IncidentStatus.closed
    ).toList();
    
    final incidentCount = activeIncidents.length;
    final hasIncident = incidentCount > 0;
    
    // Find house count for this boiler house
    final houseCount = data.locations.where((loc) => loc.boilerHouseId == bh.id).length;
    
    return Slidable(
      key: ValueKey('bh_${bh.id}'),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.65,
        children: [
          CustomSlidableAction(
            onPressed: (_) => _deleteBoilerHouse(bh),
            backgroundColor: Colors.transparent,
            padding: EdgeInsets.zero,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(24)),
                  child: const Icon(Icons.delete_outline, color: Colors.white, size: 24),
                ),
                const SizedBox(height: 8),
                const Text('Удалить', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          CustomSlidableAction(
            onPressed: (_) => _editBoilerHouse(bh),
            backgroundColor: Colors.transparent,
            padding: EdgeInsets.zero,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(24)),
                  child: const Icon(Icons.edit, color: Colors.white, size: 24),
                ),
                const SizedBox(height: 8),
                const Text('Редакт.', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          CustomSlidableAction(
            onPressed: (_) => _showBoilerHouseIncidents(bh),
            backgroundColor: Colors.transparent,
            padding: EdgeInsets.zero,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(24)),
                  child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(height: 8),
                const Text('Инциденты', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
      child: BaseCard(
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
            const SizedBox(width: 4), // Small padding to compensate for removed icon
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${bh.address} Котельная', 
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  if (hasIncident) ...[
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '⚠️ Инциденты: $incidentCount | Нач: ${bh.siteManager ?? "?"} | Участок: ${bh.siteNumber ?? "?"} | 🏠 домов: $houseCount',
                            style: const TextStyle(
                              color: Color(0xFFFFA726), // OrangeAccent-like color from screenshot
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Text(
                      'Нач: ${bh.siteManager ?? "?"} | Участок: ${bh.siteNumber ?? "?"} | 🏠 домов: $houseCount',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white24),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationItem(BuildContext context, SavedLocationResponse loc) {
    return Slidable(
      key: ValueKey('loc_${loc.id}'),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.65,
        children: [
          CustomSlidableAction(
            onPressed: (_) => _deleteLocation(loc),
            backgroundColor: Colors.transparent,
            padding: EdgeInsets.zero,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(24)),
                  child: const Icon(Icons.delete_outline, color: Colors.white, size: 24),
                ),
                const SizedBox(height: 8),
                const Text('Удалить', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          CustomSlidableAction(
            onPressed: (_) => _editLocation(loc),
            backgroundColor: Colors.transparent,
            padding: EdgeInsets.zero,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(24)),
                  child: const Icon(Icons.edit, color: Colors.white, size: 24),
                ),
                const SizedBox(height: 8),
                const Text('Редакт.', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          CustomSlidableAction(
            onPressed: (_) => _showLocationIncidents(loc),
            backgroundColor: Colors.transparent,
            padding: EdgeInsets.zero,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(24)),
                  child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(height: 8),
                const Text('Инциденты', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
      child: BaseCard(
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
                  color: Colors.white.withValues(alpha: 0.1),
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
    final data = ref.read(filteredMapDataProvider);
    
    // Calculate local active incident count
    final activeIncidents = data.incidents.where((inc) => 
      inc.boilerHouseId == bh.id && 
      inc.status != IncidentStatus.resolved && 
      inc.status != IncidentStatus.closed
    ).toList();
    final incidentCount = activeIncidents.length;
    final houseCount = data.locations.where((loc) => loc.boilerHouseId == bh.id).length;
    final hasIncident = incidentCount > 0;

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
                if (hasIncident)
                  Text(
                    '⚠️ Инциденты: $incidentCount | Нач: ${bh.siteManager ?? "?"} | Участок: ${bh.siteNumber ?? "?"} | 🏠 домов: $houseCount',
                    style: const TextStyle(color: Color(0xFFFFA726), fontSize: 11, fontWeight: FontWeight.w500),
                  )
                else
                  Text(
                    'Нач: ${bh.siteManager ?? "?"} | Участок: ${bh.siteNumber ?? "?"} | 🏠 домов: $houseCount',
                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11),
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
  void _showHouseDetailSheet(SavedLocationResponse initialLoc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            // Watch for updates to this specific location (e.g. photos)
            final data = ref.watch(filteredMapDataProvider);
            final loc = data.locations.firstWhere(
              (l) => l.id == initialLoc.id,
              orElse: () => initialLoc,
            );
            
            final linkedBH = loc.boilerHouseId != null 
                ? data.boilerHouses.firstWhere((bh) => bh.id == loc.boilerHouseId, orElse: () => BoilerHouseResponse(id: 0, address: 'Неизвестная котельная', latitude: 0, longitude: 0, createdAt: ''))
                : null;

            return DraggableScrollableSheet(
              initialChildSize: 0.85,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              builder: (ctx, controller) {
                return Container(
                  decoration: BoxDecoration(
                    color: AppTheme.darkBackground,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                  ),
                  child: Column(
                    children: [
                      // Header with back button and title
                      _buildBottomSheetHeader(loc),
                      
                      Expanded(
                        child: ListView(
                          controller: controller,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          children: [
                            // 1. House Info Section
                            _buildHouseInfoSection(loc),
                            
                            const SizedBox(height: 16),
                            
                            // 2. Boiler House Info Section
                            if (linkedBH != null && linkedBH.id != 0)
                              _buildBoilerHouseSection(linkedBH, data),
                            
                            const SizedBox(height: 16),
                            
                            // 3. Accounts Section
                            _buildAccountsSection(loc.accountsCount ?? loc.accounts?.length ?? 0),
                            
                            const SizedBox(height: 24),
                            
                            // 4. Photos Section
                            _buildHousePhotosSection(loc),
                            
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildBottomSheetHeader(SavedLocationResponse loc) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.more_horiz, color: Colors.white, size: 24),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 24),
                    onPressed: () async {
                      final result = await showDialog<bool>(
                        context: context,
                        builder: (context) => HouseIncidentFormDialog(house: loc),
                      );
                      if (result == true && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Инцидент создан')),
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 100),
            child: Text(
              loc.name,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHouseInfoSection(SavedLocationResponse loc) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.secondaryDarkBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.apartment, color: AppTheme.primaryBlue, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Информация о доме',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          _buildInfoLabel('Название'),
          Text(loc.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
          
          const SizedBox(height: 16),
          const Divider(color: Colors.white10),
          const SizedBox(height: 16),
          
          // Grid of characteristics
          LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = (constraints.maxWidth - 16) / 2; // 2 columns with 16px gap
              return Wrap(
                spacing: 16,
                runSpacing: 20,
                children: [
                  _buildGridItem(
                    itemWidth: itemWidth,
                    icon: Icons.grid_view_rounded,
                    label: 'Услуги',
                    content: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (loc.providesHotWater == true) ...[
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.water_drop, color: Colors.blue, size: 16),
                              const SizedBox(width: 4),
                              const Text('ГВС', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                        if (loc.providesHeating == true) ...[
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.local_fire_department, color: Colors.orange, size: 16),
                              const SizedBox(width: 4),
                              const Text('Отопление', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  _buildGridItem(
                    itemWidth: itemWidth,
                    icon: Icons.people_outline,
                    label: 'Жильцов',
                    value: loc.residentsCount?.toString() ?? '—',
                  ),
                  _buildGridItem(
                    itemWidth: itemWidth,
                    icon: Icons.square_foot,
                    label: 'Площадь',
                    value: loc.totalArea != null ? '${loc.totalArea} м²' : '—',
                  ),
                  _buildGridItem(
                    itemWidth: itemWidth,
                    icon: Icons.stairs,
                    label: 'Этажей',
                    value: loc.floors?.toString() ?? '—',
                  ),
                  _buildGridItem(
                    itemWidth: itemWidth,
                    icon: Icons.door_front_door_outlined,
                    label: 'Помещений',
                    value: loc.rooms?.toString() ?? '—',
                  ),
                  _buildGridItem(
                    itemWidth: itemWidth,
                    icon: Icons.calendar_month,
                    label: 'Год постройки',
                    value: loc.yearBuilt?.toString() ?? '—',
                  ),
                ],
              );
            },
          ),
          
          const SizedBox(height: 16),
          const Divider(color: Colors.white10),
          const SizedBox(height: 16),
          
          _buildInfoLabel('УК/УО'),
          Row(
            children: [
              const Icon(Icons.work, color: AppTheme.successGreen, size: 20),
              const SizedBox(width: 8),
              Text(
                loc.managementCompanyName ?? 'Не указана',
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          const Divider(color: Colors.white10),
          const SizedBox(height: 16),
          
          // Technical info block (FIAS, Coords)
          _buildTechnicalInfo(loc),
          
          const SizedBox(height: 20),
          
          // Edit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2C2C2E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Редактировать дом', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicalInfo(SavedLocationResponse loc) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.navigation_rounded, color: Colors.red, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Ш: ${loc.latitude.toStringAsFixed(7)} Д: ${loc.longitude.toStringAsFixed(7)}',
                style: const TextStyle(color: Colors.white70, fontSize: 14, fontFamily: 'monospace'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.file_copy, color: Colors.purple, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'ФИАС Дом: ${loc.fiasHouseGuid ?? "—"}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.file_copy, color: Colors.blue, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'ФИАС АО: ${loc.fiasAOGuid ?? "—"}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBoilerHouseSection(BoilerHouseResponse bh, MapDataState data) {
    // Check for active incidents
    final activeIncidents = data.incidents.where((inc) => 
      inc.boilerHouseId == bh.id && 
      inc.status != IncidentStatus.resolved && 
      inc.status != IncidentStatus.closed
    ).toList();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.secondaryDarkBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.local_fire_department, color: Colors.orange, size: 24),
              SizedBox(width: 8),
              Text(
                'Информация о котельной',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildInfoLabel('Котельная'),
          Text(bh.address, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildIconLabel(Icons.tag, 'Номер участка'),
                    Text(bh.siteNumber ?? '—', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildIconLabel(Icons.account_circle_outlined, 'Начальник участка'),
                    Text(bh.siteManager ?? '—', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          const Divider(color: Colors.white10),
          const SizedBox(height: 16),
          
          _buildInfoLabel('Ресурсы сейчас'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildResourceChip('ГВС', Icons.water_drop, Colors.blue)),
              const SizedBox(width: 8),
              Expanded(child: _buildResourceChip('Отопление', Icons.thermostat, Colors.blue)),
            ],
          ),
          
          const SizedBox(height: 16),
          const Divider(color: Colors.white10),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Icon(
                activeIncidents.isEmpty ? Icons.check_circle : Icons.warning_amber_rounded, 
                color: activeIncidents.isEmpty ? AppTheme.successGreen : AppTheme.errorRed, 
                size: 20
              ),
              const SizedBox(width: 8),
              Text(
                activeIncidents.isEmpty ? 'Нет активных инцидентов' : 'Активных инцидентов: ${activeIncidents.length}',
                style: TextStyle(
                  color: activeIncidents.isEmpty ? Colors.white70 : AppTheme.errorRed,
                  fontSize: 14,
                  fontWeight: activeIncidents.isEmpty ? FontWeight.normal : FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccountsSection(int count) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF14223A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Center(
        child: Text(
          'Лицевые счета: $count',
          style: const TextStyle(color: AppTheme.primaryBlue, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildHousePhotosSection(SavedLocationResponse loc) {
    final photos = loc.photos ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.image_outlined, color: AppTheme.primaryBlue, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Фотографии дома',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            TextButton(
              onPressed: () => _uploadPhotoForLocation(loc.id),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF14223A),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Добавить', style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        if (photos.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Column(
                children: [
                  const Text('Нет фотографий', style: TextStyle(color: Colors.white54, fontSize: 14)),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => _uploadPhotoForLocation(loc.id),
                    child: const Text(
                      'Добавить первую фотографию',
                      style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: photos.length,
              itemBuilder: (context, index) {
                final photo = photos[index];
                return _buildPhotoThumbnail(loc.id, photos, index);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildPhotoThumbnail(int locationId, List<PhotoInfo> allPhotos, int index) {
    final photo = allPhotos[index];
    return Container(
      margin: const EdgeInsets.only(right: 12),
      width: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: NetworkImage(photo.thumbnailUrl ?? photo.url ?? ''),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 4, right: 4,
            child: GestureDetector(
              onTap: () => _deletePhotoForLocation(locationId, photo.id),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _openFullscreenPhoto(allPhotos, index),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widgets
  Widget _buildInfoLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        label,
        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
      ),
    );
  }

  Widget _buildIconLabel(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.3), size: 16),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildGridItem({required IconData icon, required String label, String? value, Widget? content, double? itemWidth}) {
    final body = content ?? Text(
      value ?? '—', 
      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
    
    return SizedBox(
      width: itemWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIconLabel(icon, label),
          const SizedBox(height: 4),
          body,
        ],
      ),
    );
  }

  Widget _buildResourceChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF14223A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500))),
          const Icon(Icons.check_circle, color: Color(0xFF30D158), size: 16),
        ],
      ),
    );
  }

  // Action methods for photo management
  Future<void> _uploadPhotoForLocation(int locationId) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    
    if (image != null) {
      try {
        await ref.read(locationServiceProvider).uploadLocationPhoto(locationId, image.path);
        // UI should auto-refresh because we use Consumer/ref.watch
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка загрузки: $e')));
        }
      }
    }
  }

  Future<void> _deletePhotoForLocation(int locationId, int photoId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить фото?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Удалить')),
        ],
      ),
    );
    
    if (confirm == true) {
      try {
        await ref.read(locationServiceProvider).deleteLocationPhoto(locationId, photoId);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка удаления: $e')));
        }
      }
    }
  }

  void _openFullscreenPhoto(List<PhotoInfo> photos, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullscreenImageViewer(
          photos: photos,
          initialIndex: index,
        ),
      ),
    );
  }

  Future<void> _deleteBoilerHouse(BoilerHouseResponse bh) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить котельную?'),
        content: Text('Вы уверены, что хотите удалить котельную ${bh.address}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Удалить', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      try {
        await ref.read(boilerHouseServiceProvider).deleteBoilerHouse(bh.id);
        ref.invalidate(mapDataProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Котельная удалена')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка удаления: $e')));
        }
      }
    }
  }

  Future<void> _editBoilerHouse(BoilerHouseResponse bh) async {
    final result = await showDialog<BoilerHouseResponse>(
      context: context,
      builder: (context) => BoilerHouseFormDialog(
        position: LatLng(bh.latitude, bh.longitude),
        initialBoilerHouse: bh,
      ),
    );
    
    if (result != null && mounted) {
      ref.invalidate(mapDataProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Котельная успешно обновлена')),
      );
    }
  }

  void _showBoilerHouseIncidents(BoilerHouseResponse bh) {
    ref.read(incidentFilterProvider.notifier).updateSearchQuery(bh.address);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const IncidentListScreen()),
    );
  }

  Future<void> _deleteLocation(SavedLocationResponse loc) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить дом?'),
        content: Text('Вы уверены, что хотите удалить дом ${loc.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Удалить', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      try {
        await ref.read(locationServiceProvider).deleteSavedLocation(loc.id);
        ref.invalidate(mapDataProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Дом удален')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка удаления: $e')));
        }
      }
    }
  }

  Future<void> _editLocation(SavedLocationResponse loc) async {
    final result = await showDialog<SavedLocationResponse>(
      context: context,
      builder: (context) => HouseFormDialog(
        position: LatLng(loc.latitude, loc.longitude),
        boilerHouseId: loc.boilerHouseId ?? 0,
        initialLocation: loc,
      ),
    );
    
    if (result != null && mounted) {
      ref.invalidate(mapDataProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Дом успешно обновлен')),
      );
    }
  }

  void _showLocationIncidents(SavedLocationResponse loc) {
    ref.read(incidentFilterProvider.notifier).updateSearchQuery(loc.name);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const IncidentListScreen()),
    );
  }

}
