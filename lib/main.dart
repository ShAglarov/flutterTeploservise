import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:window_manager/window_manager.dart';
import 'utils/app_theme.dart';
import 'utils/constants.dart';
import 'screens/map_screen.dart';
import 'screens/login_screen.dart';
import 'providers/auth_providers.dart';
import 'services/server_manager.dart';

import 'services/sync_worker.dart';
import 'services/realtime_service.dart';
import 'services/data_sync_service.dart';
import 'services/sync_service.dart';
import 'services/wns_push_service.dart';
import 'services/incident_service.dart';
import 'services/secure_storage_service.dart';
import 'providers/incident_providers.dart';
import 'providers/map_providers.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  
  if (Platform.isMacOS) {
    await windowManager.ensureInitialized();
    windowManager.waitUntilReadyToShow(const WindowOptions(), () async {
      await windowManager.show();
      await windowManager.setHasShadow(true);
      await windowManager.focus();
    });
  }

  // ============================================================
  // Инициализация ServerManager
  // ============================================================
  const storage = FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    mOptions: MacOsOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  final serverManager = ServerManagerNotifier(
    read: (key) => storage.read(key: 'sm_$key'),
    write: (key, value) => storage.write(key: 'sm_$key', value: value),
    onServerSwitch: () async {
      // Очищаем токены при смене сервера
      await storage.delete(key: AppConstants.accessTokenKey);
      await storage.delete(key: AppConstants.refreshTokenKey);
      debugPrint('🖥️ [Main] Токены очищены при смене сервера');
    },
  );
  await serverManager.init();

  // Устанавливаем текущие URL в AppConstants
  _syncConstants(serverManager.state);

  // Слушаем изменения сервера для обновления AppConstants
  serverManager.addListener(() {
    _syncConstants(serverManager.state);
  });

  runApp(
    ProviderScope(
      overrides: [
        serverManagerProvider.overrideWith((_) => serverManager),
      ],
      child: const MyApp(),
    ),
  );
}

/// Синхронизация AppConstants с текущим активным сервером
void _syncConstants(ServerManagerState state) {
  AppConstants.baseUrl = state.currentBaseUrl;
  AppConstants.wsBaseUrl = state.currentWsBaseUrl;
  debugPrint('🖥️ [Main] baseUrl = ${AppConstants.baseUrl}');
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
      // 0. Force fresh re-read from local DB
      ref.invalidate(allIncidentsProvider);

      // 1. Connect WebSocket
      final realtimeService = ref.read(realtimeServiceProvider);
      await realtimeService.connect();

      // 1.5 КРИТИЧНО: Слушаем force_logout (деактивация/блокировка админом)
      realtimeService.onForceLogout.listen((reason) async {
        print('⛔ [Main] Force logout received: $reason');
        
        // Очищаем сохраненные токены
        final storage = ref.read(secureStorageServiceProvider);
        await storage.clearAll();
        
        // Отключаем WebSocket (уже сделано в RealtimeService, но для надёжности)
        realtimeService.disconnect();
        
        // Обновляем состояние авторизации → выкидываем на экран логина
        ref.read(authProvider.notifier).logout();
        
        // Показываем уведомление пользователю
        final message = reason == 'deactivated'
            ? 'Ваш аккаунт был деактивирован администратором'
            : reason == 'blocked'
                ? 'Ваш аккаунт был заблокирован администратором'
                : 'Вы были отключены: $reason';
        
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 5),
            backgroundColor: Colors.red,
          ),
        );
      });

      // 2. Start DataSyncService (listens to WS messages)
      final dataSyncService = ref.read(dataSyncServiceProvider);
      await dataSyncService.start();

      // 3. Run initial incremental sync (catch-up via HTTP)
      final syncService = ref.read(syncServiceProvider);
      await syncService.incrementalSync();

      // 3.5 Full incident refresh: reconcile local DB against server
      try {
        final incidentService = ref.read(incidentServiceProvider);
        await incidentService.getAllIncidents();
        print('✅ [Main] Full incident refresh completed');
      } catch (e) {
        print('⚠️ [Main] Full incident refresh failed: $e');
      }

      // 4. Listen for WS reconnects → gap detection (debounced)
      DateTime? lastReconnectHandled;
      realtimeService.onReconnect.listen((_) async {
        final now = DateTime.now();
        if (lastReconnectHandled != null &&
            now.difference(lastReconnectHandled!).inSeconds < 10) {
          print('🔄 [Main] WS reconnected — skipping gap check (cooldown)');
          return;
        }
        lastReconnectHandled = now;
        print('🔄 [Main] WS reconnected — checking for gap');
        await syncService.checkAndFillGap(dataSyncService.lastWSActionLogId);
        
        // Invalidate map data AND incidents to force a full UI refresh after reconnect
        ref.invalidate(allIncidentsProvider);
        ref.invalidate(mapDataProvider);
        ref.read(globalRefreshEventControllerProvider).add(null);
      });

      print('✅ [Main] Sync pipeline initialized');

      // 5. Register WNS channel for Windows push notifications
      if (Platform.isWindows) {
        final wnsPushService = ref.read(wnsPushServiceProvider);
        await wnsPushService.registerIfWindows();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Reset sync flag when user logs out so the pipeline re-initializes on next login
    if (authState.status != AuthStatus.authenticated) {
      _syncInitialized = false;
    }

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
