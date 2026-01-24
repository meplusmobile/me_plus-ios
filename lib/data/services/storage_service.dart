import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Storage Service using SharedPreferences + Secure Storage for iOS
/// Uses iOS Keychain for sensitive data like tokens
class StorageService {
  static final StorageService _instance = StorageService._internal();
  static SharedPreferences? _prefs;
  static FlutterSecureStorage? _secureStorage;
  static bool _initialized = false;

  factory StorageService() => _instance;

  StorageService._internal();

  /// Initialize SharedPreferences + Secure Storage - call this in main.dart before runApp
  static Future<void> init() async {
    if (_initialized && _prefs != null && _secureStorage != null) {
      debugPrint('✅ Storage already initialized');
      return;
    }
    
    try {
      debugPrint('🔄 Initializing SharedPreferences...');
      _prefs = await SharedPreferences.getInstance();
      debugPrint('✅ SharedPreferences initialized: ${_prefs != null}');
      
      // Initialize secure storage with iOS Keychain configuration
      debugPrint('🔄 Initializing FlutterSecureStorage...');
      const secureOptions = IOSOptions(
        accessibility: KeychainAccessibility.first_unlock,
      );
      _secureStorage = const FlutterSecureStorage(
        iOptions: secureOptions,
      );
      debugPrint('✅ FlutterSecureStorage initialized: ${_secureStorage != null}');
      
      _initialized = true;
      debugPrint('✅ Storage initialized: SharedPreferences + iOS Keychain');
      debugPrint('✅ Storage isReady: $isReady');
    } catch (e, stackTrace) {
      debugPrint('❌ Storage init error: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      // Don't mark as initialized if it failed
      _initialized = false;
      rethrow; // Re-throw so main.dart knows it failed
    }
  }

  /// Check if storage is ready
  static bool get isReady => _initialized && _prefs != null;

  SharedPreferences? get prefs => _prefs;
  FlutterSecureStorage? get secureStorage => _secureStorage;

  // ==================== Secure Storage Methods (for tokens/sensitive data) ====================

  Future<void> saveSecureString(String key, String value) async {
    if (secureStorage == null) return;
    try {
      await secureStorage!.write(key: key, value: value);
      debugPrint('✅ Saved to iOS Keychain: $key');
    } catch (e) {
      debugPrint('❌ Error saving to Keychain $key: $e');
    }
  }

  Future<String?> getSecureString(String key) async {
    if (secureStorage == null) return null;
    try {
      final value = await secureStorage!.read(key: key);
      debugPrint('📖 Read from iOS Keychain: $key = ${value != null ? "exists" : "null"}');
      return value;
    } catch (e) {
      debugPrint('❌ Error reading from Keychain $key: $e');
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
    if (prefs == null) return;
    try {
      await prefs!.setString(key, value);
    } catch (e) {
      debugPrint('Error saving string $key: $e');
    }
  }

  Future<String?> getString(String key) async {
    if (prefs == null) return null;
    try {
      return prefs!.getString(key);
    } catch (e) {
      debugPrint('Error getting string $key: $e');
      return null;
    }
  }

  // ==================== Int Methods ====================

  Future<void> saveInt(String key, int value) async {
    if (prefs == null) return;
    try {
      await prefs!.setInt(key, value);
    } catch (e) {
      debugPrint('Error saving int $key: $e');
    }
  }

  Future<int?> getInt(String key) async {
    if (prefs == null) return null;
    try {
      return prefs!.getInt(key);
    } catch (e) {
      debugPrint('Error getting int $key: $e');
      return null;
    }
  }

  // ==================== Bool Methods ====================

  Future<void> saveBool(String key, bool value) async {
    if (prefs == null) return;
    try {
      await prefs!.setBool(key, value);
    } catch (e) {
      debugPrint('Error saving bool $key: $e');
    }
  }

  Future<bool> getBool(String key) async {
    if (prefs == null) return false;
    try {
      return prefs!.getBool(key) ?? false;
    } catch (e) {
      debugPrint('Error getting bool $key: $e');
      return false;
    }
  }

  // ==================== Double Methods ====================

  Future<void> saveDouble(String key, double value) async {
    if (prefs == null) return;
    try {
      await prefs!.setDouble(key, value);
    } catch (e) {
      debugPrint('Error saving double $key: $e');
    }
  }

  Future<double?> getDouble(String key) async {
    if (prefs == null) return null;
    try {
      return prefs!.getDouble(key);
    } catch (e) {
      debugPrint('Error getting double $key: $e');
      return null;
    }
  }

  // ==================== List<String> Methods ====================

  Future<void> saveStringList(String key, List<String> value) async {
    if (prefs == null) return;
    try {
      await prefs!.setStringList(key, value);
    } catch (e) {
      debugPrint('Error saving string list $key: $e');
    }
  }

  Future<List<String>?> getStringList(String key) async {
    if (prefs == null) return null;
    try {
      return prefs!.getStringList(key);
    } catch (e) {
      debugPrint('Error getting string list $key: $e');
      return null;
    }
  }

  // ==================== Delete & Clear Methods ====================

  Future<void> remove(String key) async {
    if (prefs == null) return;
    try {
      await prefs!.remove(key);
    } catch (e) {
      debugPrint('Error removing $key: $e');
    }
  }

  Future<void> clear() async {
    if (prefs == null) return;
    try {
      await prefs!.clear();
    } catch (e) {
      debugPrint('Error clearing storage: $e');
    }
  }

  // ==================== Utility Methods ====================

  Future<bool> containsKey(String key) async {
    if (prefs == null) return false;
    try {
      return prefs!.containsKey(key);
    } catch (e) {
      debugPrint('Error checking key $key: $e');
      return false;
    }
  }

  Future<Set<String>> getAllKeys() async {
    if (prefs == null) return {};
    try {
      return prefs!.getKeys();
    } catch (e) {
      debugPrint('Error getting keys: $e');
      return {};
    }
  }
}
