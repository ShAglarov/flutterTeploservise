import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math; // ADDED: for jitter
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import '../utils/constants.dart';
import '../utils/secure_http.dart';
import 'secure_storage_service.dart';
import 'device_id_service.dart';
import 'dart:developer' as dev;
import 'package:geolocator/geolocator.dart';
import '../utils/app_logger.dart';

final realtimeServiceProvider = Provider<RealtimeService>((ref) {
  ref.keepAlive();
  final storage = ref.watch(secureStorageServiceProvider);
  final deviceService = ref.watch(deviceIdServiceProvider);
  return RealtimeService(storage, deviceService);
});

class RealtimeService {
  final SecureStorageService _storage;
  final DeviceIdService _deviceService;
  
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get messages => _messageController.stream;

  /// Stream that emits true on reconnect. DataSyncService/SyncService
  /// listens to this to trigger gap detection.
  final _reconnectController = StreamController<void>.broadcast();
  Stream<void> get onReconnect => _reconnectController.stream;

  /// Stream that emits when server sends force_logout (deactivation/block).
  /// Payload is the reason string (e.g. 'deactivated', 'blocked').
  final _forceLogoutController = StreamController<String>.broadcast();
  Stream<String> get onForceLogout => _forceLogoutController.stream;
  bool _forceLoggedOut = false;

  /// Stream that emits when server sends permission_update.
  final _permissionUpdateController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get onPermissionUpdate => _permissionUpdateController.stream;

  /// Connection state (true = connected)
  final _connectionStateController = StreamController<bool>.broadcast();
  Stream<bool> get connectionState => _connectionStateController.stream;
  bool _isConnected = false;
  bool get isConnected => _isConnected;
  
  bool _isConnecting = false;
  int _retryCount = 0;
  Timer? _reconnectTimer;

  // ADDED: Deferred backoff reset — only resets _retryCount after 5s of stable connection.
  // Prevents Thundering Herd when server flaps (accept → drop → accept → drop).
  Timer? _stableConnectionTimer;

  // ADDED: Server-ping watchdog replaces the old client heartbeat.
  // The server sends {"type": "ping"} every 30s. We passively monitor
  // _lastPongReceived and tear down the connection if no ping arrives for 90s.
  Timer? _watchdogTimer;
  Timer? _heartbeatTimer; // ADDED: Client-side active heartbeat
  DateTime? _lastPongReceived;
  DateTime? _lastConnectedAt; // ADDED: track reconnect time to drop instant redeliveries

  // GPS: Защита от параллельных запросов разрешений
  Future<Position?>? _pendingGpsRequest;

  /// Сервис уничтожен — контроллеры закрыты, добавлять в них нельзя.
  /// Без этого флага отложенный reconnect-таймер, сработавший после
  /// dispose(), бросал StateError («Cannot add new events after calling
  /// close») из _connectionStateController.add().
  bool _disposed = false;

  RealtimeService(this._storage, this._deviceService);

  /// Все исходящие события идут через это — чтобы проверка «не закрыт ли
  /// контроллер» была в одном месте, а не в девяти местах вызова.
  void _emit<T>(StreamController<T> controller, T value) {
    if (_disposed || controller.isClosed) return;
    controller.add(value);
  }

  void _emitConnectionState(bool connected) =>
      _emit(_connectionStateController, connected);

  /// Force-disconnect and reconnect immediately.
  /// Called from app lifecycle handler on resume from background/sleep.
  /// Resets retry count to avoid exponential backoff after device sleep.
  Future<void> reconnectNow() async {
    dev.log('RealtimeService: 🔄 reconnectNow() — forcing immediate reconnect', name: 'WS');
    
    // Clean disconnect (cancels timers, nulls out channel)
    _reconnectTimer?.cancel();
    _stableConnectionTimer?.cancel();
    _watchdogTimer?.cancel();
    _heartbeatTimer?.cancel();
    _subscription?.cancel();
    try { _channel?.sink.close(); } catch (_) {}
    _channel = null;
    _subscription = null;
    _isConnected = false;
    _isConnecting = false; // Reset to allow connect()
    _retryCount = 0; // Reset backoff — this is an intentional reconnect
    _emitConnectionState(false);

    // Refresh token before reconnecting — after sleep, JWT is likely expired
    await _refreshTokenIfNeeded();

    // Connect immediately
    await connect();
  }

  /// Одноразовый билет для WS-подключения (POST /auth/ws-ticket).
  ///
  /// SECURITY: билет вместо JWT в URL. Query-строка — худшее место для
  /// токена: она попадает в access-логи nginx и обратных прокси, в
  /// диагностику TLS-терминаторов и в метрики. Билет живёт 60 секунд,
  /// одноразовый (сервер удаляет его при проверке) и не даёт доступа к
  /// HTTP API, поэтому утечка такой строки почти ничего не стоит.
  ///
  /// Возвращает null, если билет получить не удалось (Redis недоступен,
  /// сети нет, сервер старой версии) — тогда [connect] падает обратно на
  /// `?token=`, который сервер всё ещё принимает. Без этого отката
  /// недоступность Redis means полная потеря realtime.
  Future<String?> _fetchWsTicket() async {
    try {
      final token = await _storage.getAccessToken();
      if (token == null || token.isEmpty) return null;

      final dio = Dio(BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        // 401 обрабатываем сами — он означает «обнови токен», а не ошибку сети.
        validateStatus: (code) => code != null && code < 500,
      ));

      Future<Response<dynamic>> post(String bearer) => dio.post(
            AppConstants.wsTicket,
            options: Options(headers: {'Authorization': 'Bearer $bearer'}),
          );

      var response = await post(token);

      if (response.statusCode == 401) {
        // Токен истёк — обновляем и пробуем ещё раз. Этот путь закрывает
        // reconnect-петлю: раньше истёкший токен переподключался вечно,
        // потому что refresh вызывался только в reconnectNow().
        await _refreshTokenIfNeeded();
        final fresh = await _storage.getAccessToken();
        if (fresh == null || fresh.isEmpty) return null;
        response = await post(fresh);
      }

      if (response.statusCode == 200 && response.data is Map) {
        final ticket = (response.data as Map)['ticket'] as String?;
        if (ticket != null && ticket.isNotEmpty) return ticket;
      }
      dev.log('RealtimeService: WS ticket unavailable (HTTP ${response.statusCode}), falling back to token', name: 'WS');
      return null;
    } catch (e) {
      dev.log('RealtimeService: WS ticket request failed, falling back to token: $e', name: 'WS');
      return null;
    }
  }

  /// Attempts to refresh the access token via HTTP refresh endpoint.
  /// Ensures the stored token is fresh before WS connect() reads it.
  Future<void> _refreshTokenIfNeeded() async {
    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        dev.log('RealtimeService: No refresh token available, skipping token refresh', name: 'WS');
        return;
      }

      final dio = Dio(BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ));

      final response = await dio.post(
        AppConstants.refresh,
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200 && response.data != null) {
        final newAccessToken = response.data['access_token'] as String?;
        final newRefreshToken = response.data['refresh_token'] as String?;

        if (newAccessToken != null) {
          await _storage.saveAccessToken(newAccessToken);
        }
        if (newRefreshToken != null) {
          await _storage.saveRefreshToken(newRefreshToken);
        }
        dev.log('RealtimeService: ✅ Token refreshed before WS connect', name: 'WS');
      }
    } catch (e) {
      dev.log('RealtimeService: ⚠️ Token refresh failed (will try connect with existing token): $e', name: 'WS');
      // Non-fatal — we still try to connect with whatever token is stored
    }
  }

  Future<void> connect() async {
    // Отложенный reconnect мог сработать уже после dispose — открывать
    // сокет и заводить таймеры в уничтоженном сервисе нельзя.
    if (_disposed) return;
    if (_isConnecting || _channel != null) return;
    _isConnecting = true;
    _forceLoggedOut = false; // Reset flag on new connection attempt

    try {
      final token = await _storage.getAccessToken();
      final deviceId = await _deviceService.getDeviceId();

      dev.log('RealtimeService: Found token: ${token != null && token.isNotEmpty ? "YES (length: ${token.length})" : "NO"}', name: 'WS');

      if (token == null || token.isEmpty) {
        dev.log('RealtimeService: Token is empty, aborting WS connect to avoid spamming server.', name: 'WS');
        _isConnecting = false;
        return;
      }

      // SECURITY: предпочитаем одноразовый билет. JWT в query-строке остаётся
      // только как откат (Redis недоступен / сервер старой версии).
      final ticket = await _fetchWsTicket();
      final credential = ticket != null
          ? 'ticket=${Uri.encodeQueryComponent(ticket)}'
          : 'token=${Uri.encodeQueryComponent(token)}';
      final String url = '${AppConstants.wsBaseUrl}/$deviceId?$credential';
      dev.log(
        'RealtimeService: WS auth via ${ticket != null ? "one-time ticket" : "token fallback"}',
        name: 'WS',
      );

      // NOTE: wss:// is used for all environments.
      // SECURITY: сертификат проверяется в release-сборках. Обход
      // (для self-signed/корпоративных прокси) доступен только в debug —
      // см. utils/secure_http.dart. Раньше любой сертификат принимался
      // всегда, что позволяло MITM читать WS-трафик и сам JWT из URL.

      // SECURITY: не логируем URL — он содержит access token в query-параметре
      dev.log('RealtimeService: Connecting to WS for device $deviceId', name: 'WS');

      final wsClient = SecureHttp.createClient(
        connectionTimeout: const Duration(seconds: 15),
      );

      _channel = IOWebSocketChannel.connect(
        Uri.parse(url),
        customClient: wsClient,
      );
      
      _subscription = _channel?.stream.listen(
        (data) {
          _handleMessage(data);
        },
        onError: (error) {
          dev.log('RealtimeService: WebSocket error: $error', name: 'WS');
          _handleDisconnect();
        },
        onDone: () {
          dev.log('RealtimeService: WebSocket closed', name: 'WS');
          _handleDisconnect();
        },
      );

      _isConnecting = false;

      // MODIFIED: Start server-ping watchdog and client-side heartbeat.
      _startWatchdog();
      _startHeartbeat();

      // Emit reconnect event if this is a RE-connection (not first connect)
      final wasConnectedBefore = _retryCount > 0;

      // MODIFIED: Do NOT reset _retryCount = 0 instantly.
      // Schedule a deferred reset after 5 seconds of stable connection.
      _isConnected = true;
      _lastConnectedAt = DateTime.now();
      _emitConnectionState(true);

      // КРИТИЧНО: Отправляем device info СРАЗУ при подключении.
      // Не ждём первого ping от сервера — иначе при resume сессии
      // (без вызова login()) device info никогда не попадёт на сервер.
      _sendPongWithLocation();

      // ADDED: ANTI-DDOS — deferred backoff reset.
      // Only reset retry counter after 5s of proven stability.
      // If the server flaps, _retryCount stays elevated → 2s → 4s → 8s instead of 1s → 1s → DDoS.
      _stableConnectionTimer?.cancel();
      _stableConnectionTimer = Timer(const Duration(seconds: 5), () {
        if (_isConnected) {
          dev.log('RealtimeService: ✅ ANTI-DDOS: Connection stable for 5s, resetting retry count (was $_retryCount)', name: 'WS');
          _retryCount = 0;
        }
      });

      if (wasConnectedBefore) {
        dev.log('RealtimeService: Reconnected — firing onReconnect', name: 'WS');
        _emit(_reconnectController, null);
      }
      // device info + GPS уже отправлены выше. Второй вызов здесь был
      // дублем: на каждое подключение уходило два pong и два запроса GPS.
    } catch (e) {
      dev.log('RealtimeService: Failed to connect: $e', name: 'WS');
      _isConnecting = false;
      _handleDisconnect();
    }
  }

  void _handleMessage(dynamic data) {
    try {
      // ADDED: Fast-drop redelivery storms immediately upon reconnect
      final strData = data.toString();
      if (strData.contains('"is_redelivery": true') || strData.contains('"is_redelivery":true')) {
        if (_lastConnectedAt != null && DateTime.now().difference(_lastConnectedAt!).inSeconds < 2) {
          dev.log('RealtimeService: 🛑 Fast-dropped redelivery immediately after reconnect', name: 'WS');
          return;
        }
      }

      final decoded = jsonDecode(data as String);
      
      if (decoded is Map<String, dynamic>) {
        logDebug('🚀 [WS] MESSAGE RECEIVED: $decoded');
        
        // КРИТИЧНО: Обработка принудительного выхода (деактивация/блокировка)
        if (decoded['type'] == 'force_logout') {
          final reason = (decoded['data'] as Map<String, dynamic>?)?['reason'] ?? 'unknown';
          dev.log('RealtimeService: ⛔ FORCE_LOGOUT received: reason=$reason', name: 'WS');
          _forceLoggedOut = true;
          _emit(_forceLogoutController, reason);
          disconnect(); // Чистое закрытие без reconnect
          return;
        }

        // Respond to server pings immediately with JSON pong + GPS coordinates
        if (decoded['type'] == 'ping') {
          dev.log('RealtimeService: Server ping received, sending pong with GPS', name: 'WS');
          _sendPongWithLocation();
          // ADDED: Update watchdog timestamp — server is alive
          _lastPongReceived = DateTime.now();
          return;
        }
        // ADDED: Handle server JSON pong (response to native pings, if any)
        if (decoded['type'] == 'pong') {
          _lastPongReceived = DateTime.now();
          return;
        }
        // ADDED: Handle permission_update from admin
        if (decoded['type'] == 'permission_update') {
          dev.log('RealtimeService: 🔐 permission_update received', name: 'WS');
          final payload = decoded['payload'] as Map<String, dynamic>? ?? decoded['data'] as Map<String, dynamic>? ?? {};
          _emit(_permissionUpdateController, payload);
          return;
        }
        _emit(_messageController, decoded);
      }
    } catch (e) {
      dev.log('RealtimeService: Failed to decode message: $e', name: 'WS');
    }
  }

  void _handleDisconnect() {
    if (_disposed) return;

    // ADDED: Cancel the deferred backoff reset — connection failed before proving stability
    _stableConnectionTimer?.cancel();
    _stableConnectionTimer = null;

    // MODIFIED: Cancel watchdog and heartbeat
    _watchdogTimer?.cancel();
    _watchdogTimer = null;
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;

    _subscription?.cancel();
    _subscription = null;
    _channel = null;
    _isConnected = false;
    _emitConnectionState(false);

    // КРИТИЧНО: Если сервер прислал force_logout — НЕ переподключаемся
    if (_forceLoggedOut) {
      dev.log('RealtimeService: ⛔ Force-logged out, NOT reconnecting', name: 'WS');
      return;
    }

    // MODIFIED: Removed `if (_retryCount < 10)` — client now retries indefinitely.
    // MODIFIED: Max delay raised from 30s to 60s.
    // ADDED: Positive jitter (0.0–1.0s) to prevent synchronized thundering herds.
    final int baseDelay = (1 << _retryCount).clamp(1, 60);
    final double jitter = math.Random().nextDouble(); // 0.0 to 1.0 seconds
    final delay = Duration(milliseconds: (baseDelay * 1000) + (jitter * 1000).toInt());
    
    dev.log(
      'RealtimeService: Reconnecting in ${delay.inMilliseconds}ms '
      '(base: ${baseDelay}s + jitter: ${jitter.toStringAsFixed(2)}s, retry $_retryCount)',
      name: 'WS',
    );

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () async {
      _retryCount++;
      // Частая причина разрыва — истёкший JWT: сервер закрывает соединение
      // с 1008, и подключение тем же токеном обрывается снова, бесконечно.
      // Обновляем токен перед повторной попыткой. Для первой попытки это не
      // нужно — там токен только что использовался успешно.
      if (_retryCount > 1) {
        await _refreshTokenIfNeeded();
      }
      await connect();
    });
  }

  void disconnect() {
    // ADDED: Cancel deferred backoff reset on explicit disconnect
    _stableConnectionTimer?.cancel();
    _stableConnectionTimer = null;

    // MODIFIED: Cancel watchdog and heartbeat
    _watchdogTimer?.cancel();
    _watchdogTimer = null;
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;

    _reconnectTimer?.cancel();
    _subscription?.cancel();
    _channel?.sink.close();
    _channel = null;
    _subscription = null;
    _isConnected = false;
    _emitConnectionState(false);
    dev.log('RealtimeService: Manually disconnected', name: 'WS');
  }

  // MODIFIED: Faster watchdog. Checks every 15s whether the server
  // has sent a {"type": "ping"} within the last 45 seconds.
  void _startWatchdog() {
    _watchdogTimer?.cancel();
    _lastPongReceived = DateTime.now(); // Initialize baseline

    _watchdogTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (!_isConnected || _channel == null) {
        timer.cancel();
        return;
      }

      final lastPong = _lastPongReceived;
      if (lastPong != null) {
        final elapsed = DateTime.now().difference(lastPong).inSeconds;
        // 120 seconds timeout (increased to handle macOS debug pauses)
        if (elapsed > 120) {
          dev.log(
            'RealtimeService: ⚠️ Server-ping watchdog: no server activity for ${elapsed}s (timeout: 120s), reconnecting',
            name: 'WS',
          );
          _handleDisconnect();
        }
      }
    });
    dev.log('RealtimeService: Server-ping watchdog started (check: 15s, timeout: 120s)', name: 'WS');
  }

  // ADDED: Send pong with GPS coordinates and device info
  void _sendPongWithLocation() {
    _sendPongAsync();
  }

  /// Async implementation — async/await вместо .then()/.catchError()
  /// чтобы ошибки не проглатывались молча.
  Future<void> _sendPongAsync() async {
    final Map<String, dynamic> pongData = {'type': 'pong'};

    // 1. Device info — ВСЕГДА пытаемся получить
    try {
      final deviceInfo = await _deviceService.getDeviceInfo();
      pongData['device_type'] = deviceInfo.deviceType;
      pongData['device_os'] = deviceInfo.deviceOs;
      pongData['device_model'] = deviceInfo.deviceModel;
      pongData['device_model_id'] = deviceInfo.deviceModelId;
    } catch (e) {
      logDebug('⚠️ [Pong] getDeviceInfo FAILED: $e');
      // Отправляем pong без device info — но хотя бы не теряем pong
    }

    // 2. GPS — отдельно, не ломает device info при ошибке
    try {
      final position = await _safeGetLastPosition();
      if (position != null) {
        pongData['latitude'] = position.latitude;
        pongData['longitude'] = position.longitude;
      }
    } catch (e) {
      logDebug('⚠️ [Pong] GPS FAILED (non-critical): $e');
    }

    // 3. Отправляем
    try {
      _channel?.sink.add(jsonEncode(pongData));
    } catch (e) {
      logDebug('⚠️ [Pong] WebSocket send FAILED: $e');
    }
  }

  /// Безопасно получает позицию GPS.
  /// Защита от параллельных вызовов — второй вызов ждёт первого.
  Future<Position?> _safeGetLastPosition() async {
    // Если уже идёт запрос GPS — ждём его результат
    if (_pendingGpsRequest != null) {
      return _pendingGpsRequest!;
    }
    _pendingGpsRequest = _doGetPosition();
    try {
      return await _pendingGpsRequest!;
    } finally {
      _pendingGpsRequest = null;
    }
  }

  /// Внутренняя реализация получения GPS-координат.
  Future<Position?> _doGetPosition() async {
    try {
      // Geolocator не поддерживает Windows/Linux
      if (Platform.isWindows || Platform.isLinux) return null;
      // На macOS Desktop (не "Designed for iPad") — пропускаем
      if (Platform.isMacOS) return null;

      // Проверяем разрешения (без requestPermission — не блокируем pong)
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        // Не запрашиваем разрешение в pong — это должно происходить
        // на экране карты, где пользователь видит контекст.
        return null;
      }

      // Сначала кэш — мгновенно
      final cached = await Geolocator.getLastKnownPosition();
      if (cached != null) return cached;

      // Кэша нет — запрашиваем актуальную позицию с таймаутом
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 5),
        ),
      );
    } catch (e) {
      logDebug('⚠️ [GPS] _doGetPosition error: $e');
      return null;
    }
  }

  /// Last Gasp: публичный метод для отправки финального pong с GPS и device info.
  /// Вызывается при logout и при закрытии приложения (AppLifecycleState.detached).
  /// Fire-and-forget — не ждёт ответа.
  void sendLastPong() {
    if (_channel == null || !_isConnected) {
      dev.log('⚠️ [LastGasp] WebSocket не подключён — финальный pong не отправлен', name: 'WS');
      return;
    }
    dev.log('🚨 [LastGasp] Отправляем финальный pong с GPS...', name: 'WS');
    _sendPongWithLocation();
  }

  // ADDED: Active Client Heartbeat. Proactively sends a ping every 20s.
  // This helps keep the TCP connection alive and ensures we get a 'pong' back 
  // to update the watchdog even if the server is quiet.
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (!_isConnected || _channel == null) {
        timer.cancel();
        return;
      }

      try {
        dev.log('RealtimeService: Sending active client ping', name: 'WS');
        _channel?.sink.add(jsonEncode({'type': 'ping'}));
      } catch (e) {
        dev.log('RealtimeService: Heartbeat failed to send: $e', name: 'WS');
        _handleDisconnect();
      }
    });
  }

  void dispose() {
    // Флаг ДО disconnect(): сам disconnect эмитит connectionState, а
    // контроллеры мы сейчас закроем.
    _disposed = true;
    disconnect();
    _messageController.close();
    _reconnectController.close();
    _forceLogoutController.close();
    _permissionUpdateController.close();
    _connectionStateController.close();
  }
}
