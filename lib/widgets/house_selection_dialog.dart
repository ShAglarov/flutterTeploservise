import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/location_models.dart';
import '../services/location_service.dart';
import '../utils/app_theme.dart';

class HouseSelectionDialog extends ConsumerStatefulWidget {
  const HouseSelectionDialog({super.key});

  @override
  ConsumerState<HouseSelectionDialog> createState() => _HouseSelectionDialogState();
}

class _HouseSelectionDialogState extends ConsumerState<HouseSelectionDialog> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<SavedLocationResponse> _houses = [];
  bool _isLoading = false;
  bool _isMoreLoading = false;
  bool _hasMore = true;
  int _skip = 0;
  final int _limit = 20;
  String _query = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadHouses();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
      if (!_isMoreLoading && _hasMore) {
        _loadMore();
      }
    }
  }

  Future<void> _loadHouses({bool isInitial = true}) async {
    if (isInitial) {
      setState(() {
        _isLoading = true;
        _skip = 0;
        _hasMore = true;
        _houses = [];
      });
    } else {
      setState(() => _isMoreLoading = true);
    }

    try {
      final service = ref.read(locationServiceProvider);
      final results = await service.searchHouses(
        skip: _skip,
        limit: _limit,
        q: _query,
        unassignedOnly: true,
      );

      setState(() {
        if (isInitial) {
          _houses = results;
          _isLoading = false;
        } else {
          _houses.addAll(results);
          _isMoreLoading = false;
        }
        _hasMore = results.length == _limit;
        _skip += results.length;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isMoreLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка загрузки: $e')),
        );
      }
    }
  }

  Future<void> _loadMore() async {
    await _loadHouses(isInitial: false);
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_query != value) {
        setState(() {
          _query = value;
        });
        _loadHouses();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      child: Container(
        width: 500,
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: Colors.blue))
                : _houses.isEmpty
                  ? const Center(child: Text('Дома не найдены', style: TextStyle(color: Colors.white54)))
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: _houses.length + (_hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _houses.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator(color: Colors.blue, strokeWidth: 2)),
                          );
                        }
                        return _buildHouseCard(_houses[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _CircleButton(
            icon: Icons.chevron_left,
            onTap: () => Navigator.pop(context),
          ),
          const Text(
            'Выбрать дом',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 36), // Spacer for balance
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            hintText: 'Поиск по дому / УК / ЛС...',
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
            prefixIcon: Icon(Icons.search, color: Colors.white.withValues(alpha: 0.3), size: 20),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
          ),
          onChanged: _onSearchChanged,
        ),
      ),
    );
  }

  Widget _buildHouseCard(SavedLocationResponse house) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => Navigator.pop(context, house),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      house.name,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Год: ${house.yearBuilt ?? "Н/Д"} • Этажей: ${house.floors ?? "Н/Д"} • Помещений: ${house.rooms ?? "Н/Д"} • Площадь: ${house.totalArea ?? "Н/Д"}',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.white.withValues(alpha: 0.3), size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: Colors.white),
      ),
    );
  }
}
