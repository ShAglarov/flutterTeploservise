import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'utils/app_theme.dart';
import 'screens/map_screen.dart';
import 'screens/login_screen.dart';
import 'providers/auth_providers.dart';

import 'services/sync_worker.dart';
import 'services/realtime_service.dart';
import 'services/data_sync_service.dart';
import 'services/sync_service.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  bool _syncInitialized = false;

  @override
  void initState() {
    super.initState();
    // Start the background sync worker (outgoing pending changes)
    Future.microtask(() => ref.read(syncWorkerProvider).start());
  }

  /// Called once when the user is authenticated.
  /// Connects WebSocket, starts DataSyncService, runs initial incremental sync.
  void _initializeSyncPipeline() {
    if (_syncInitialized) return;
    _syncInitialized = true;

    Future.microtask(() async {
      // 1. Connect WebSocket
      final realtimeService = ref.read(realtimeServiceProvider);
      await realtimeService.connect();

      // 2. Start DataSyncService (listens to WS messages)
      final dataSyncService = ref.read(dataSyncServiceProvider);
      await dataSyncService.start();

      // 3. Run initial incremental sync (catch-up via HTTP)
      final syncService = ref.read(syncServiceProvider);
      await syncService.incrementalSync();

      // 4. Listen for WS reconnects → gap detection
      realtimeService.onReconnect.listen((_) async {
        print('🔄 [Main] WS reconnected — checking for gap');
        await syncService.checkAndFillGap(dataSyncService.lastWSActionLogId);
      });

      print('✅ [Main] Sync pipeline initialized');
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // When authenticated, initialize the sync pipeline
    if (authState.status == AuthStatus.authenticated && !_syncInitialized) {
      _initializeSyncPipeline();
    }

    return MaterialApp(
      title: 'Teplo Service',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      scaffoldMessengerKey: scaffoldMessengerKey,
      home: _getHome(authState),
    );
  }

  Widget _getHome(AuthState authState) {
    if (authState.isLoading && authState.status == AuthStatus.initial) {
      return const Scaffold(
        backgroundColor: AppTheme.darkBackground,
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryBlue),
        ),
      );
    }

    if (authState.status == AuthStatus.authenticated) {
      return MapScreen();
    }

    return const LoginScreen();
  }
}
