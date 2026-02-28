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
  DateTime? _lastPongReceived;

  RealtimeService(this._storage, this._deviceService);

  Future<void> connect() async {
    if (_isConnecting || _channel != null) return;
    _isConnecting = true;

    try {
      final token = await _storage.getAccessToken();
      final deviceId = await _deviceService.getDeviceId();

      if (token == null) {
        dev.log('RealtimeService: No token, cannot connect WebSocket', name: 'WS');
        _isConnecting = false;
        return;
      }

      final url = '${AppConstants.wsBaseUrl}/$deviceId?token=$token';
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

      // MODIFIED: Start server-ping watchdog instead of client heartbeat.
      // No more client-originated pings — server drives keep-alive.
      _startWatchdog();

      // Emit reconnect event if this is a RE-connection (not first connect)
      final wasConnectedBefore = _retryCount > 0;

      // MODIFIED: Do NOT reset _retryCount = 0 instantly.
      // Schedule a deferred reset after 5 seconds of stable connection.
      _isConnected = true;
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
      final decoded = jsonDecode(data as String);
      if (decoded is Map<String, dynamic>) {
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

    // MODIFIED: Cancel watchdog instead of old heartbeat
    _watchdogTimer?.cancel();
    _watchdogTimer = null;

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

    // MODIFIED: Cancel watchdog instead of old heartbeat
    _watchdogTimer?.cancel();
    _watchdogTimer = null;

    _reconnectTimer?.cancel();
    _subscription?.cancel();
    _channel?.sink.close();
    _channel = null;
    _subscription = null;
    _isConnected = false;
    _connectionStateController.add(false);
    dev.log('RealtimeService: Manually disconnected', name: 'WS');
  }

  // ADDED: Server-ping watchdog. Checks every 45s whether the server
  // has sent a {"type": "ping"} within the last 90 seconds.
  // If not, assumes the connection is silently dead and forces reconnect.
  // This replaces the old _startHeartbeat() which spammed the server with text "ping".
  void _startWatchdog() {
    _watchdogTimer?.cancel();
    _lastPongReceived = DateTime.now(); // Initialize baseline

    _watchdogTimer = Timer.periodic(const Duration(seconds: 45), (timer) {
      if (!_isConnected || _channel == null) {
        timer.cancel();
        return;
      }

      final lastPong = _lastPongReceived;
      if (lastPong != null) {
        final elapsed = DateTime.now().difference(lastPong).inSeconds;
        // 90 seconds = 3 missed server pings (every 30s)
        if (elapsed > 90) {
          dev.log(
            'RealtimeService: ⚠️ Server-ping watchdog: no server ping for ${elapsed}s (timeout: 90s), reconnecting',
            name: 'WS',
          );
          _handleDisconnect();
        }
      }
    });
    dev.log('RealtimeService: Server-ping watchdog started (check: 45s, timeout: 90s)', name: 'WS');
  }

  void dispose() {
    disconnect();
    _messageController.close();
    _reconnectController.close();
    _connectionStateController.close();
  }
}
