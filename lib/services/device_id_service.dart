import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';
import 'secure_storage_service.dart';

final deviceIdServiceProvider = Provider<DeviceIdService>((ref) {
  final storage = ref.watch(secureStorageServiceProvider);
  return DeviceIdService(storage);
});

/// Информация об устройстве для отправки на сервер.
/// Значения собираются один раз при первом обращении и кэшируются.
///
/// ОБНОВЛЕНО:
/// - Добавлено поле deviceModelId (сырой идентификатор для диагностики)
/// - Android: brand + model вместо просто model ("Samsung SM-G998B" вместо "SM-G998B")
/// - Windows: computerName вместо productName ("DESKTOP-PTO-01" вместо "Windows 10 Pro")
/// - Единообразие с iOS/Swift DeviceInfo
class DeviceInfoData {
  /// Тип устройства: "Phone", "Tablet" или "Desktop"
  final String deviceType;

  /// ОС с версией, например "Android 14" или "Windows 22H2 (19045)"
  final String deviceOs;

  /// Маркетинговое / человекочитаемое название устройства.
  /// Android: "Samsung SM-G998B"
  /// Windows: "DESKTOP-PTO-01" (имя компьютера)
  final String deviceModel;

  /// Сырой идентификатор модели для диагностики.
  /// Android: "SM-G998B" (info.model)
  /// Windows: "Windows 10 Pro" (info.productName)
  final String deviceModelId;

  const DeviceInfoData({
    required this.deviceType,
    required this.deviceOs,
    required this.deviceModel,
    required this.deviceModelId,
  });

  Map<String, String> toJson() => {
    'device_type': deviceType,
    'device_os': deviceOs,
    'device_model': deviceModel,
    'device_model_id': deviceModelId,
  };
}

class DeviceIdService {
  final SecureStorageService _storage;
  String? _cachedId;
  DeviceInfoData? _cachedDeviceInfo;

  DeviceIdService(this._storage);

  Future<String> getDeviceId() async {
    if (_cachedId != null) return _cachedId!;

    // Try to get from secure storage
    final id = await _storage.getDeviceId();
    if (id != null) {
      _cachedId = id;
      return id;
    }

    // Generate new ID
    final newId = const Uuid().v4();
    await _storage.saveDeviceId(newId);
    _cachedId = newId;
    return newId;
  }

  /// Собирает и кэширует информацию об устройстве.
  /// Вызывается один раз, повторные вызовы возвращают кэш.
  ///
  /// ОБНОВЛЕНО:
  /// - Android: brand + model (маркетинговое) + model (сырой ID)
  /// - Windows: computerName (маркетинговое) + productName (сырой ID)
  /// - macOS: computerName + model
  /// - iOS: utsname.machine (в Flutter iOS клиент не используется — iOS = нативный Swift)
  Future<DeviceInfoData> getDeviceInfo() async {
    if (_cachedDeviceInfo != null) return _cachedDeviceInfo!;

    final plugin = DeviceInfoPlugin();

    String deviceType;
    String deviceOs;
    String deviceModel;
    String deviceModelId;

    if (Platform.isAndroid) {
      final info = await plugin.androidInfo;
      deviceOs = 'Android ${info.version.release}';
      // Маркетинговое название: Brand + Model (например "Samsung SM-G998B")
      final brand = info.brand;
      final capBrand = brand.isNotEmpty
          ? brand[0].toUpperCase() + brand.substring(1)
          : brand;
      deviceModel = '$capBrand ${info.model}';
      // Сырой идентификатор: только model (например "SM-G998B")
      deviceModelId = info.model;
      // Определяем тип по shortestSide экрана (>= 600dp = планшет)
      deviceType = _detectDeviceType();

    } else if (Platform.isIOS) {
      final info = await plugin.iosInfo;

      // Детектируем "Designed for iPad" на Mac (isiOSAppOnMac аналог).
      // На реальном iOS: HOME = /var/mobile/Containers/...
      // На Mac через "Designed for iPad": HOME = /Users/...
      final isOnMac = _isIOSAppRunningOnMac();

      if (isOnMac) {
        // Mac mini / MacBook / iMac запускающий iOS-приложение
        deviceType = 'Desktop';
        deviceModel = 'Mac (${Platform.localHostname})';
        deviceModelId = info.utsname.machine;
        deviceOs = 'macOS (via ${info.systemName} ${info.systemVersion})';
      } else {
        // Настоящий iPhone/iPad
        deviceOs = '${info.systemName} ${info.systemVersion}';
        deviceModelId = info.utsname.machine;
        deviceModel = _iOSMarketingName(info.utsname.machine);
        deviceType = _detectDeviceType();
      }



    } else if (Platform.isWindows) {
      // Windows Desktop: имя компьютера для административного контроля
      deviceType = 'Desktop';
      try {
        final info = await plugin.windowsInfo;
        // computerName — сетевое имя машины (DESKTOP-PTO-01)
        deviceModel = info.computerName;
        // productName — системная информация (Windows 10 Pro)
        deviceModelId = info.productName;
        // Подробная версия ОС
        deviceOs = 'Windows ${info.displayVersion} (${info.buildNumber})';
      } catch (_) {
        // Fallback если device_info_plus не может получить данные
        deviceModel = Platform.localHostname;
        deviceModelId = Platform.operatingSystem;
        deviceOs = Platform.operatingSystemVersion;
      }

    } else if (Platform.isMacOS) {
      // macOS Desktop (Flutter macOS — если когда-то будет использоваться)
      deviceType = 'Desktop';
      try {
        final info = await plugin.macOsInfo;
        deviceModel = info.computerName;
        deviceModelId = info.model;
        deviceOs = 'macOS ${info.majorVersion}.${info.minorVersion}';
      } catch (_) {
        deviceModel = Platform.localHostname;
        deviceModelId = Platform.operatingSystem;
        deviceOs = Platform.operatingSystemVersion;
      }

    } else {
      // Linux / другие
      deviceType = 'Desktop';
      deviceModel = Platform.localHostname;
      deviceModelId = Platform.operatingSystem;
      deviceOs = '${Platform.operatingSystem} ${Platform.operatingSystemVersion}';
    }

    _cachedDeviceInfo = DeviceInfoData(
      deviceType: deviceType,
      deviceOs: deviceOs,
      deviceModel: deviceModel,
      deviceModelId: deviceModelId,
    );

    return _cachedDeviceInfo!;
  }

  /// Быстрый запрос координат для session events (login/logout).
  /// Возвращает Position или null за ≤5 секунд.
  /// НИКОГДА не блокирует вход/выход.
  ///
  /// На Windows/Linux GPS недоступен — всегда возвращает null.
  Future<Position?> quickLocationFix() async {
    // GPS недоступен на десктопных платформах
    if (Platform.isWindows || Platform.isLinux) {
      return null;
    }

    try {
      // 1. Проверка разрешения (не запрашиваем — это login/logout flow)
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      // 2. Проверка сервиса
      if (!await Geolocator.isLocationServiceEnabled()) {
        return null;
      }

      // 3. Попытка кэша (если < 5 минут и accuracy < 500м)
      final cached = await Geolocator.getLastKnownPosition();
      if (cached != null) {
        final age = DateTime.now().difference(cached.timestamp);
        if (age.inMinutes < 5 && cached.accuracy < 500) {
          return cached;
        }
      }

      // 4. Разовый запрос с таймаутом 5 секунд
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 5),
        ),
      );
    } catch (_) {
      // Любая ошибка → null, не блокируем login/logout
      return null;
    }
  }

  /// Определяет тип мобильного устройства: Phone или Tablet.
  /// Использует shortestSide экрана: >= 600dp считается планшетом.
  /// Определяет, запущено ли iOS-приложение на Mac через "Designed for iPad".
  /// Dart-аналог Swift ProcessInfo.processInfo.isiOSAppOnMac.
  ///
  /// Проверяет наличие директории /Users — она существует ТОЛЬКО на macOS.
  /// На реальном iOS-устройстве /Users не существует.
  /// Platform.environment не работает — iOS sandbox блокирует доступ.
  bool _isIOSAppRunningOnMac() {
    if (!Platform.isIOS) return false;
    try {
      return Directory('/Users').existsSync();
    } catch (_) {
      return false;
    }
  }

  String _detectDeviceType() {
    try {
      final window = WidgetsBinding.instance.platformDispatcher.views.first;
      final shortestSide = window.physicalSize.shortestSide / window.devicePixelRatio;
      return shortestSide >= 600 ? 'Tablet' : 'Phone';
    } catch (_) {
      // Fallback если binding ещё не инициализирован
      return 'Phone';
    }
  }

  /// Возвращает маркетинговое название iOS/iPadOS устройства по hardware ID.
  /// Например: "iPad8,6" → "iPad Pro 11-inch (3rd generation)"
  /// Fallback: возвращает сам identifier если модель не найдена.
  static String _iOSMarketingName(String identifier) {
    const map = <String, String>{
      // iPhone
      'iPhone6,1': 'iPhone 5s', 'iPhone6,2': 'iPhone 5s',
      'iPhone7,1': 'iPhone 6 Plus', 'iPhone7,2': 'iPhone 6',
      'iPhone8,1': 'iPhone 6s', 'iPhone8,2': 'iPhone 6s Plus', 'iPhone8,4': 'iPhone SE',
      'iPhone9,1': 'iPhone 7', 'iPhone9,2': 'iPhone 7 Plus', 'iPhone9,3': 'iPhone 7', 'iPhone9,4': 'iPhone 7 Plus',
      'iPhone10,1': 'iPhone 8', 'iPhone10,2': 'iPhone 8 Plus', 'iPhone10,3': 'iPhone X',
      'iPhone10,4': 'iPhone 8', 'iPhone10,5': 'iPhone 8 Plus', 'iPhone10,6': 'iPhone X',
      'iPhone11,2': 'iPhone XS', 'iPhone11,4': 'iPhone XS Max', 'iPhone11,6': 'iPhone XS Max', 'iPhone11,8': 'iPhone XR',
      'iPhone12,1': 'iPhone 11', 'iPhone12,3': 'iPhone 11 Pro', 'iPhone12,5': 'iPhone 11 Pro Max', 'iPhone12,8': 'iPhone SE (2nd gen)',
      'iPhone13,1': 'iPhone 12 mini', 'iPhone13,2': 'iPhone 12', 'iPhone13,3': 'iPhone 12 Pro', 'iPhone13,4': 'iPhone 12 Pro Max',
      'iPhone14,2': 'iPhone 13 Pro', 'iPhone14,3': 'iPhone 13 Pro Max', 'iPhone14,4': 'iPhone 13 mini', 'iPhone14,5': 'iPhone 13',
      'iPhone14,6': 'iPhone SE (3rd gen)',
      'iPhone14,7': 'iPhone 14', 'iPhone14,8': 'iPhone 14 Plus',
      'iPhone15,2': 'iPhone 14 Pro', 'iPhone15,3': 'iPhone 14 Pro Max',
      'iPhone15,4': 'iPhone 15', 'iPhone15,5': 'iPhone 15 Plus',
      'iPhone16,1': 'iPhone 15 Pro', 'iPhone16,2': 'iPhone 15 Pro Max',
      'iPhone16,3': 'iPhone SE (4th gen)',
      'iPhone17,1': 'iPhone 16 Pro', 'iPhone17,2': 'iPhone 16 Pro Max',
      'iPhone17,3': 'iPhone 16', 'iPhone17,4': 'iPhone 16 Plus',
      // iPad
      'iPad4,1': 'iPad Air', 'iPad4,2': 'iPad Air', 'iPad4,3': 'iPad Air',
      'iPad5,3': 'iPad Air 2', 'iPad5,4': 'iPad Air 2',
      'iPad11,3': 'iPad Air (3rd gen)', 'iPad11,4': 'iPad Air (3rd gen)',
      'iPad13,1': 'iPad Air (4th gen)', 'iPad13,2': 'iPad Air (4th gen)',
      'iPad13,16': 'iPad Air (5th gen)', 'iPad13,17': 'iPad Air (5th gen)',
      'iPad14,8': 'iPad Air 11-inch (M2)', 'iPad14,9': 'iPad Air 11-inch (M2)',
      'iPad14,10': 'iPad Air 13-inch (M2)', 'iPad14,11': 'iPad Air 13-inch (M2)',
      'iPad6,11': 'iPad (5th gen)', 'iPad6,12': 'iPad (5th gen)',
      'iPad7,5': 'iPad (6th gen)', 'iPad7,6': 'iPad (6th gen)',
      'iPad7,11': 'iPad (7th gen)', 'iPad7,12': 'iPad (7th gen)',
      'iPad11,6': 'iPad (8th gen)', 'iPad11,7': 'iPad (8th gen)',
      'iPad12,1': 'iPad (9th gen)', 'iPad12,2': 'iPad (9th gen)',
      'iPad13,18': 'iPad (10th gen)', 'iPad13,19': 'iPad (10th gen)',
      'iPad4,4': 'iPad mini 2', 'iPad4,5': 'iPad mini 2', 'iPad4,6': 'iPad mini 2',
      'iPad4,7': 'iPad mini 3', 'iPad4,8': 'iPad mini 3', 'iPad4,9': 'iPad mini 3',
      'iPad5,1': 'iPad mini 4', 'iPad5,2': 'iPad mini 4',
      'iPad11,1': 'iPad mini (5th gen)', 'iPad11,2': 'iPad mini (5th gen)',
      'iPad14,1': 'iPad mini (6th gen)', 'iPad14,2': 'iPad mini (6th gen)',
      'iPad16,1': 'iPad mini (7th gen)', 'iPad16,2': 'iPad mini (7th gen)',
      'iPad6,3': 'iPad Pro 9.7-inch', 'iPad6,4': 'iPad Pro 9.7-inch',
      'iPad6,7': 'iPad Pro 12.9-inch', 'iPad6,8': 'iPad Pro 12.9-inch',
      'iPad7,1': 'iPad Pro 12.9-inch (2nd gen)', 'iPad7,2': 'iPad Pro 12.9-inch (2nd gen)',
      'iPad7,3': 'iPad Pro 10.5-inch', 'iPad7,4': 'iPad Pro 10.5-inch',
      'iPad8,1': 'iPad Pro 11-inch', 'iPad8,2': 'iPad Pro 11-inch',
      'iPad8,3': 'iPad Pro 11-inch', 'iPad8,4': 'iPad Pro 11-inch',
      'iPad8,5': 'iPad Pro 12.9-inch (3rd gen)', 'iPad8,6': 'iPad Pro 12.9-inch (3rd gen)',
      'iPad8,7': 'iPad Pro 12.9-inch (3rd gen)', 'iPad8,8': 'iPad Pro 12.9-inch (3rd gen)',
      'iPad8,9': 'iPad Pro 11-inch (2nd gen)', 'iPad8,10': 'iPad Pro 11-inch (2nd gen)',
      'iPad8,11': 'iPad Pro 12.9-inch (4th gen)', 'iPad8,12': 'iPad Pro 12.9-inch (4th gen)',
      'iPad13,4': 'iPad Pro 11-inch (3rd gen)', 'iPad13,5': 'iPad Pro 11-inch (3rd gen)',
      'iPad13,6': 'iPad Pro 11-inch (3rd gen)', 'iPad13,7': 'iPad Pro 11-inch (3rd gen)',
      'iPad13,8': 'iPad Pro 12.9-inch (5th gen)', 'iPad13,9': 'iPad Pro 12.9-inch (5th gen)',
      'iPad13,10': 'iPad Pro 12.9-inch (5th gen)', 'iPad13,11': 'iPad Pro 12.9-inch (5th gen)',
      'iPad14,3': 'iPad Pro 11-inch (4th gen)', 'iPad14,4': 'iPad Pro 11-inch (4th gen)',
      'iPad14,5': 'iPad Pro 12.9-inch (6th gen)', 'iPad14,6': 'iPad Pro 12.9-inch (6th gen)',
      'iPad16,3': 'iPad Pro 11-inch (M4)', 'iPad16,4': 'iPad Pro 11-inch (M4)',
      'iPad16,5': 'iPad Pro 13-inch (M4)', 'iPad16,6': 'iPad Pro 13-inch (M4)',
    };
    return map[identifier] ?? identifier;
  }
}
