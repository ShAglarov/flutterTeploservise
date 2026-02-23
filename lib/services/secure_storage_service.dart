import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/constants.dart';

const String _deviceIdKey = 'device_unique_id';

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    mOptions: MacOsOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // Fallback for macOS local development when Keychain signing isn't available
  final Map<String, String> _memoryFallback = {};

  Future<void> _safeWrite(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } on PlatformException catch (e) {
      print('⚠️ [SecureStorageService] Write failed ($key): ${e.message}. Using fallback.');
      _memoryFallback[key] = value;
    }
  }

  Future<String?> _safeRead(String key) async {
    try {
      if (_memoryFallback.containsKey(key)) return _memoryFallback[key];
      return await _storage.read(key: key);
    } on PlatformException catch (e) {
      print('⚠️ [SecureStorageService] Read failed ($key): ${e.message}. Using fallback.');
      return _memoryFallback[key];
    }
  }

  Future<void> _safeDelete(String key) async {
    try {
      _memoryFallback.remove(key);
      await _storage.delete(key: key);
    } on PlatformException catch (e) {
      print('⚠️ [SecureStorageService] Delete failed ($key): ${e.message}. Using fallback.');
    }
  }

  Future<void> saveAccessToken(String token) async {
    await _safeWrite(AppConstants.accessTokenKey, token);
  }

  Future<String?> getAccessToken() async {
    return await _safeRead(AppConstants.accessTokenKey);
  }

  Future<void> saveRefreshToken(String token) async {
    await _safeWrite(AppConstants.refreshTokenKey, token);
  }

  Future<String?> getRefreshToken() async {
    return await _safeRead(AppConstants.refreshTokenKey);
  }

  Future<void> clearAll() async {
    try {
      _memoryFallback.clear();
      await _storage.deleteAll();
    } on PlatformException catch (_) {
      // Ignored
    }
  }

  Future<void> deleteAccessToken() async {
    await _safeDelete(AppConstants.accessTokenKey);
  }

  Future<void> deleteRefreshToken() async {
    await _safeDelete(AppConstants.refreshTokenKey);
  }

  Future<void> saveDeviceId(String id) async {
    await _safeWrite(_deviceIdKey, id);
  }

  Future<String?> getDeviceId() async {
    return await _safeRead(_deviceIdKey);
  }
}
