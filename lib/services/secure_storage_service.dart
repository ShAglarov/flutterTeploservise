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

  Future<void> _safeWrite(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } on PlatformException catch (e) {
      print('⚠️ [SecureStorageService] Write failed ($key): ${e.message}.');
    }
  }

  Future<String?> _safeRead(String key) async {
    try {
      return await _storage.read(key: key);
    } on PlatformException catch (e) {
      print('⚠️ [SecureStorageService] Read failed ($key): ${e.message}.');
      return null;
    }
  }

  Future<void> _safeDelete(String key) async {
    try {
      await _storage.delete(key: key);
    } on PlatformException catch (e) {
      print('⚠️ [SecureStorageService] Delete failed ($key): ${e.message}.');
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
