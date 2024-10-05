import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Keys
  static const String userIdKey = 'userId';

  // Store user ID
  Future<void> storeUserId(String userId) async {
    await _storage.write(key: userIdKey, value: userId);
  }

  // Retrieve user ID
  Future<String?> getUserId() async {
    return await _storage.read(key: userIdKey);
  }

  // Delete user ID
  Future<void> deleteUserId() async {
    await _storage.delete(key: userIdKey);
  }

  // Store a value securely
  Future<void> saveToken(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  // Retrieve a securely stored value
  Future<String?> getToken(String key) async {
    return await _storage.read(key: key);
  }

  // Delete a value securely
  Future<void> deleteToken(String key) async {
    await _storage.delete(key: key);
  }

  // Clear all stored values
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
