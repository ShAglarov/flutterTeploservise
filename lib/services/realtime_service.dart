import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../utils/constants.dart';
import 'secure_storage_service.dart';
import 'device_id_service.dart';
import 'dart:developer' as dev;

final realtimeServiceProvider = Provider<RealtimeService>((ref) {
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
  
  bool _isConnecting = false;
  int _retryCount = 0;
  Timer? _reconnectTimer;

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
      _retryCount = 0;
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
        _messageController.add(decoded);
      }
    } catch (e) {
      dev.log('RealtimeService: Failed to decode message: $e', name: 'WS');
    }
  }

  void _handleDisconnect() {
    _subscription?.cancel();
    _subscription = null;
    _channel = null;

    if (_retryCount < 10) {
      final delay = Duration(seconds: (1 << _retryCount).clamp(1, 30));
      dev.log('RealtimeService: Reconnecting in ${delay.inSeconds}s (retry $_retryCount)', name: 'WS');
      
      _reconnectTimer?.cancel();
      _reconnectTimer = Timer(delay, () {
        _retryCount++;
        connect();
      });
    }
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    _subscription?.cancel();
    _channel?.sink.close();
    _channel = null;
    _subscription = null;
    dev.log('RealtimeService: Manually disconnected', name: 'WS');
  }

  void dispose() {
    disconnect();
    _messageController.close();
  }
}
