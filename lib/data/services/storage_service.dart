import 'package:flutter/foundation.dart';
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
      debugPrint('✅ Storage already initialized');
      return;
    }
    
    try {
      // Initialize secure storage with iOS Keychain configuration
      debugPrint('🔄 Initializing FlutterSecureStorage (iOS Keychain)...');
      final secureOptions = IOSOptions(
        accessibility: KeychainAccessibility.first_unlock,
      );
      _secureStorage = FlutterSecureStorage(
        iOptions: secureOptions,
      );
      debugPrint('✅ FlutterSecureStorage initialized: ${_secureStorage != null}');
      
      _initialized = true;
      debugPrint('✅ Storage initialized: iOS Keychain ONLY');
      debugPrint('✅ Storage isReady: $isReady');
    } catch (e, stackTrace) {
      debugPrint('❌ Storage init error: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      _initialized = false;
      rethrow;
    }
  }

  /// Check if storage is ready
  static bool get isReady => _initialized && _secureStorage != null;

  FlutterSecureStorage? get secureStorage => _secureStorage;

  // ==================== Secure Storage Methods (for tokens/sensitive data) ====================

  Future<void> saveSecureString(String key, String value) async {
    if (secureStorage == null) {
      debugPrint('❌ [saveSecureString] secureStorage is NULL!');
      return;
    }
    try {
      debugPrint('🔐 [saveSecureString] Saving $key to iOS Keychain...');
      await secureStorage!.write(key: key, value: value);
      debugPrint('✅ [saveSecureString] Saved to iOS Keychain: $key (length: ${value.length})');
      
      // Immediate verification
      final verify = await secureStorage!.read(key: key);
      debugPrint('🧪 [saveSecureString] Verification read: ${verify != null ? "SUCCESS" : "FAILED"}');
    } catch (e) {
      debugPrint('❌ [saveSecureString] Error saving to Keychain $key: $e');
    }
  }

  Future<String?> getSecureString(String key) async {
    if (secureStorage == null) {
      debugPrint('❌ [getSecureString] secureStorage is NULL!');
      return null;
    }
    try {
      debugPrint('🔍 [getSecureString] Reading $key from iOS Keychain...');
      final value = await secureStorage!.read(key: key);
      debugPrint('📖 [getSecureString] Read from iOS Keychain: $key = ${value != null ? "exists (length: ${value.length})" : "NULL"}');
      return value;
    } catch (e) {
      debugPrint('❌ [getSecureString] Error reading from Keychain $key: $e');
      return null;
    }
  }

  Future<void> removeSecure(String key) async {
    if (secureStorage == null) return;
    try {
      await secureStorage!.delete(key: key);
      debugPrint('🗑️ Removed from iOS Keychain: $key');
    } catch (e) {
      debugPrint('❌ Error removing from Keychain $key: $e');
    }
  }

  Future<void> clearSecure() async {
    if (secureStorage == null) return;
    try {
      await secureStorage!.deleteAll();
      debugPrint('🗑️ Cleared all iOS Keychain data');
    } catch (e) {
      debugPrint('❌ Error clearing Keychain: $e');
    }
  }

  // ==================== String Methods ====================

  Future<void> saveString(String key, String value) async {
    if (secureStorage == null) return;
    try {
      await secureStorage!.write(key: key, value: value);
    } catch (e) {
      debugPrint('Error saving string $key: $e');
    }
  }

  Future<String?> getString(String key) async {
    if (secureStorage == null) return null;
    try {
      return await secureStorage!.read(key: key);
    } catch (e) {
      debugPrint('Error getting string $key: $e');
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
      debugPrint('Error getting all keys: $e');
      return {};
    }
  }
}
