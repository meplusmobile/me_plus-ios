import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Storage Service using flutter_secure_storage for iOS compatibility
/// Replaces SharedPreferences to fix iOS channel errors
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  // Configure for iOS compatibility
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  // ==================== String Methods ====================
  
  Future<void> saveString(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      throw Exception('Failed to save string: $e');
    }
  }

  Future<String?> getString(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      return null;
    }
  }

  // ==================== Int Methods ====================
  
  Future<void> saveInt(String key, int value) async {
    try {
      await _storage.write(key: key, value: value.toString());
    } catch (e) {
      throw Exception('Failed to save int: $e');
    }
  }

  Future<int?> getInt(String key) async {
    try {
      final value = await _storage.read(key: key);
      return value != null ? int.tryParse(value) : null;
    } catch (e) {
      return null;
    }
  }

  // ==================== Bool Methods ====================
  
  Future<void> saveBool(String key, bool value) async {
    try {
      await _storage.write(key: key, value: value.toString());
    } catch (e) {
      throw Exception('Failed to save bool: $e');
    }
  }

  Future<bool> getBool(String key) async {
    try {
      final value = await _storage.read(key: key);
      return value == 'true';
    } catch (e) {
      return false;
    }
  }

  // ==================== Double Methods ====================
  
  Future<void> saveDouble(String key, double value) async {
    try {
      await _storage.write(key: key, value: value.toString());
    } catch (e) {
      throw Exception('Failed to save double: $e');
    }
  }

  Future<double?> getDouble(String key) async {
    try {
      final value = await _storage.read(key: key);
      return value != null ? double.tryParse(value) : null;
    } catch (e) {
      return null;
    }
  }

  // ==================== List<String> Methods ====================
  
  Future<void> saveStringList(String key, List<String> value) async {
    try {
      // Join with a delimiter that's unlikely to be in user data
      final joined = value.join('|||DELIMITER|||');
      await _storage.write(key: key, value: joined);
    } catch (e) {
      throw Exception('Failed to save string list: $e');
    }
  }

  Future<List<String>> getStringList(String key) async {
    try {
      final value = await _storage.read(key: key);
      if (value == null || value.isEmpty) return [];
      return value.split('|||DELIMITER|||');
    } catch (e) {
      return [];
    }
  }

  // ==================== Delete & Clear Methods ====================
  
  Future<void> remove(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      throw Exception('Failed to remove key: $e');
    }
  }

  Future<void> clear() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      throw Exception('Failed to clear storage: $e');
    }
  }

  // ==================== Utility Methods ====================
  
  Future<bool> containsKey(String key) async {
    try {
      final value = await _storage.read(key: key);
      return value != null;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, String>> readAll() async {
    try {
      return await _storage.readAll();
    } catch (e) {
      return {};
    }
  }
}