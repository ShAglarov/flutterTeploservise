import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/connectivity_banner.dart';
import 'map_screen.dart';
import 'incident_list_screen.dart';
import '../utils/app_theme.dart';
import '../services/chat_read_service.dart';

class MainTabsScreen extends ConsumerStatefulWidget {
  const MainTabsScreen({super.key});

  @override
  ConsumerState<MainTabsScreen> createState() => _MainTabsScreenState();
}

class _MainTabsScreenState extends ConsumerState<MainTabsScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const MapScreen(),
    const IncidentListScreen(),
    const PlaceholderScreen(title: 'Настройки'),
  ];

  @override
  void initState() {
    super.initState();
    // Загружаем счётчики непрочитанных при старте приложения
    Future.microtask(() {
      ref.read(unreadCountsProvider.notifier).fetchAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final unreadCounts = ref.watch(unreadCountsProvider);
    final hasUnread = unreadCounts.values.any((c) => c > 0);

    return Scaffold(
      body: Column(
        children: [
          const ConnectivityBanner(includeTopPadding: true),
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.onSurface.withAlpha(20),
              width: 0.5,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Theme.of(context).colorScheme.onSurface.withAlpha(140),
          type: BottomNavigationBarType.fixed,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              activeIcon: Icon(Icons.map),
              label: 'Карта',
            ),
            BottomNavigationBarItem(
              icon: Badge(
                isLabelVisible: hasUnread,
                backgroundColor: Colors.blue,
                smallSize: 8,
                child: const Icon(Icons.article_outlined),
              ),
              activeIcon: Badge(
                isLabelVisible: hasUnread,
                backgroundColor: Colors.blue,
                smallSize: 8,
                child: const Icon(Icons.article),
              ),
              label: 'Журнал',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Профиль',
            ),
          ],
        ),
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          '$title - В разработке',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(140)),
        ),
      ),
    );
  }
}
