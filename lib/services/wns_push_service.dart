import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_api_service.dart';
import 'device_id_service.dart';
import 'tenant_service.dart';
import '../utils/app_logger.dart';

final wnsPushServiceProvider = Provider<WnsPushService>((ref) {
  final dio = ref.watch(dioProvider);
  final deviceIdService = ref.watch(deviceIdServiceProvider);
  return WnsPushService(dio, deviceIdService);
});

/// Service that obtains a WNS channel URI from Windows
/// and registers it with the backend for push notifications.
class WnsPushService {
  static const _channel = MethodChannel('com.teploservice/wns');
  final Dio _dio;
  final DeviceIdService _deviceIdService;

  WnsPushService(this._dio, this._deviceIdService);

  /// Относится ли полученный push к текущей организации.
  ///
  /// MULTI-TENANCY: сервер отправляет уведомления только на устройства своей
  /// организации, но доставка асинхронна. APNs/WNS могут принести сообщение
  /// через минуты — уже после того, как на устройстве вышли и вошли под
  /// другой компанией. Такое уведомление нужно игнорировать, иначе сотрудник
  /// увидит инцидент чужого клиента.
  ///
  /// Вызывать из обработчика нажатия на уведомление перед открытием
  /// карточки: `organization_id` сервер кладёт в скрытый payload.
  static bool shouldHandlePush(Map<String, dynamic>? payload) {
    if (payload == null) return true;
    return TenantService.belongsToCurrentOrg(payload['organization_id']);
  }

  /// Call this once after user login on Windows.
  /// On non-Windows platforms this is a no-op.
  Future<void> registerIfWindows() async {
    if (!Platform.isWindows) return;

    try {
      logDebug('🪟 [WnsPush] Requesting WNS channel URI...');
      final String? channelUri =
          await _channel.invokeMethod<String>('getWnsChannelUri');

      if (channelUri == null || channelUri.isEmpty) {
        logDebug('⚠️ [WnsPush] Channel URI is empty, skipping registration');
        return;
      }

      logDebug('✅ [WnsPush] Got channel URI (${channelUri.length} chars)');

      final deviceId = await _deviceIdService.getDeviceId();

      // Register with backend
      await _dio.post(
        '/push/register',
        data: {
          'device_id': deviceId,
          'platform': 'windows',
          'wns_channel_uri': channelUri,
          'device_name': Platform.localHostname,
        },
      );

      logDebug('✅ [WnsPush] Channel URI registered with backend');
    } on PlatformException catch (e) {
      logDebug('❌ [WnsPush] Platform error: ${e.code} - ${e.message}');
    } on DioException catch (e) {
      logDebug('❌ [WnsPush] API error: ${e.response?.statusCode} - ${e.message}');
    } catch (e) {
      logDebug('❌ [WnsPush] Unexpected error: $e');
    }
  }
}
