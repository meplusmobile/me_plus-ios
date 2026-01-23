import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Storage Service using SharedPreferences - Works 100% on iOS!
class StorageService {
  static final StorageService _instance = StorageService._internal();
  static SharedPreferences? _prefs;
  static bool _initialized = false;

  factory StorageService() => _instance;

  StorageService._internal();

  /// Initialize SharedPreferences - call this in main.dart before runApp
  static Future<void> init() async {
    if (_initialized) return;
    try {
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
      debugPrint('✅ SharedPreferences storage initialized successfully');
    } catch (e) {
      debugPrint('❌ SharedPreferences init error: $e');
      _initialized = true; // Mark as initialized to prevent loops
    }
  }

  /// Check if storage is ready
  static bool get isReady => _initialized && _prefs != null;

  SharedPreferences? get prefs => _prefs;

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
