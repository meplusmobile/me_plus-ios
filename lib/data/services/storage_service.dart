import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Storage Service using ONLY FlutterSecureStorage (iOS Keychain)
/// SharedPreferences was failing on iOS with channel errors
/// iOS Keychain works perfectly for ALL data (not just tokens)
class StorageService {
  static final StorageService _instance = StorageService._internal();
  static FlutterSecureStorage? _secureStorage;
  static bool _initialized = false;

  factory StorageService() => _instance;

  StorageService._internal();

  /// Initialize Secure Storage only - call this in main.dart before runApp
  static Future<void> init() async {
    if (_initialized && _secureStorage != null) {
      return;
    }
    
    try {
      _secureStorage = FlutterSecureStorage(
        iOptions: IOSOptions(
          accessibility: KeychainAccessibility.unlocked_this_device,
          synchronizable: false,
        ),
        aOptions: AndroidOptions(
          encryptedSharedPreferences: true,
        ),
      );
      
      // Test write/read to verify it works
      try {
        const testKey = '__storage_init_test__';
        const testValue = 'test_value_12345';
        
        await _secureStorage!.write(key: testKey, value: testValue);
        await Future.delayed(const Duration(milliseconds: 200));
        
        await _secureStorage!.read(key: testKey);
        await _secureStorage!.delete(key: testKey);
      } catch (e) {
        // Ignore test errors
      }
      
      _initialized = true;
    } catch (e) {
      _initialized = false;
      rethrow;
    }
  }

  /// Check if storage is ready
  static bool get isReady => _initialized && _secureStorage != null;

  FlutterSecureStorage? get secureStorage => _secureStorage;

  // ==================== Secure Storage Methods (for tokens/sensitive data) ====================

  Future<void> saveSecureString(String key, String value) async {
    if (!_initialized || secureStorage == null) {
      return;
    }
    try {
      await secureStorage!.write(key: key, value: value);
      await Future.delayed(const Duration(milliseconds: 250));
      
      // Verify the write
      final verify = await secureStorage!.read(key: key);
      if (verify == null) {
        // Retry once after longer delay
        await Future.delayed(const Duration(milliseconds: 500));
        await secureStorage!.read(key: key);
      }
    } catch (e) {
      // Ignore
    }
  }

  Future<String?> getSecureString(String key) async {
    if (!_initialized || secureStorage == null) {
      return null;
    }
    try {
      final value = await secureStorage!.read(key: key);
      return value;
    } catch (e) {
      return null;
    }
  }

  Future<void> removeSecure(String key) async {
    if (secureStorage == null) return;
    try {
      await secureStorage!.delete(key: key);
    } catch (e) {
      // Ignore
    }
  }

  Future<void> clearSecure() async {
    if (secureStorage == null) return;
    try {
      await secureStorage!.deleteAll();
    } catch (e) {
      // Ignore
    }
  }

  // ==================== String Methods ====================

  Future<void> saveString(String key, String value) async {
    if (secureStorage == null) return;
    try {
      await secureStorage!.write(key: key, value: value);
    } catch (e) {
      // Ignore
    }
  }

  Future<String?> getString(String key) async {
    if (secureStorage == null) return null;
    try {
      return await secureStorage!.read(key: key);
    } catch (e) {
      return null;
    }
  }

  // ==================== Int Methods ====================

  Future<void> saveInt(String key, int value) async {
    await saveString(key, value.toString());
  }

  Future<int?> getInt(String key) async {
    final str = await getString(key);
    if (str == null) return null;
    return int.tryParse(str);
  }

  // ==================== Bool Methods ====================

  Future<void> saveBool(String key, bool value) async {
    await saveString(key, value.toString());
  }

  Future<bool> getBool(String key) async {
    final str = await getString(key);
    return str == 'true';
  }

  // ==================== Double Methods ====================

  Future<void> saveDouble(String key, double value) async {
    await saveString(key, value.toString());
  }

  Future<double?> getDouble(String key) async {
    final str = await getString(key);
    if (str == null) return null;
    return double.tryParse(str);
  }

  // ==================== List<String> Methods ====================

  Future<void> saveStringList(String key, List<String> value) async {
    await saveString(key, value.join('|||')); // Use delimiter
  }

  Future<List<String>?> getStringList(String key) async {
    final str = await getString(key);
    if (str == null || str.isEmpty) return null;
    return str.split('|||');
  }

  // ==================== Delete & Clear Methods ====================

  Future<void> remove(String key) async {
    await removeSecure(key);
  }

  Future<void> clear() async {
    await clearSecure();
  }

  // ==================== Utility Methods ====================

  Future<bool> containsKey(String key) async {
    final value = await getString(key);
    return value != null;
  }

  Future<Set<String>> getAllKeys() async {
    if (secureStorage == null) return {};
    try {
      final all = await secureStorage!.readAll();
      return all.keys.toSet();
    } catch (e) {
      return {};
    }
  }
}
