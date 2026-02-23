import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'secure_storage_service.dart';

final deviceIdServiceProvider = Provider<DeviceIdService>((ref) {
  final storage = ref.watch(secureStorageServiceProvider);
  return DeviceIdService(storage);
});

class DeviceIdService {
  final SecureStorageService _storage;
  String? _cachedId;

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
}
