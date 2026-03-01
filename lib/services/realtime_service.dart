import 'dart:async';
import 'dart:convert';
import 'dart:math' as math; // ADDED: for jitter
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../utils/constants.dart';
import 'secure_storage_service.dart';
import 'device_id_service.dart';
import 'dart:developer' as dev;

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

  RealtimeService(this._storage, this._deviceService);

  Future<void> connect() async {
    if (_isConnecting || _channel != null) return;
    _isConnecting = true;

    try {
      final token = await _storage.getAccessToken();
      final deviceId = await _deviceService.getDeviceId();

      dev.log('RealtimeService: Found token: ${token != null && token.isNotEmpty ? "YES (length: ${token.length})" : "NO"}', name: 'WS');

      if (token == null || token.isEmpty) {
        dev.log('RealtimeService: Token is empty, aborting WS connect to avoid spamming server.', name: 'WS');
        _isConnecting = false;
        return;
      }

      String url = '${AppConstants.wsBaseUrl}/$deviceId?token=$token';
      
      // NOTE: wss:// is used for all environments. MyHttpOverrides in main.dart
      // handles self-signed certs for debug builds. The previous ws:// override
      // for macOS debug was causing constant reconnections (every 3-60s) because
      // plain WebSocket through nginx SSL proxy is inherently unstable.

      dev.log('RealtimeService: Connecting to $url', name: 'WS');

      _channel = WebSocketChannel.connect(Uri.parse(url));
      
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
      _connectionStateController.add(true);

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
        _reconnectController.add(null);
      }
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
        print('🚀 [WS] MESSAGE RECEIVED: $decoded');
        
        // Respond to server pings immediately with JSON pong
        if (decoded['type'] == 'ping') {
          dev.log('RealtimeService: Server ping received, sending pong', name: 'WS');
          _channel?.sink.add(jsonEncode({'type': 'pong'}));
          // ADDED: Update watchdog timestamp — server is alive
          _lastPongReceived = DateTime.now();
          return;
        }
        // ADDED: Handle server JSON pong (response to native pings, if any)
        if (decoded['type'] == 'pong') {
          _lastPongReceived = DateTime.now();
          return;
        }
        _messageController.add(decoded);
      }
    } catch (e) {
      dev.log('RealtimeService: Failed to decode message: $e', name: 'WS');
    }
  }

  void _handleDisconnect() {
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
    _connectionStateController.add(false);

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
    _reconnectTimer = Timer(delay, () {
      _retryCount++;
      connect();
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
    _connectionStateController.add(false);
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
    disconnect();
    _messageController.close();
    _reconnectController.close();
    _connectionStateController.close();
  }
}
