import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Storage Service using Hive - Pure Dart, no platform channel issues!
/// Works 100% on iOS without native plugin problems
class StorageService {
  static final StorageService _instance = StorageService._internal();
  static bool _initialized = false;
  static Box? _box;

  factory StorageService() => _instance;

  StorageService._internal();

  /// Initialize Hive - call this in main.dart before runApp
  static Future<void> init() async {
    if (_initialized) return;
    try {
      await Hive.initFlutter();
      _box = await Hive.openBox('app_storage');
      _initialized = true;
      debugPrint('✅ Hive storage initialized successfully');
    } catch (e) {
      debugPrint('❌ Hive init error: $e');
      // Try fallback initialization
      try {
        _box = await Hive.openBox('app_storage');
        _initialized = true;
      } catch (e2) {
        debugPrint('❌ Hive fallback also failed: $e2');
        _initialized = true; // Mark as initialized to prevent loops
      }
    }
  }

  /// Check if storage is ready
  static bool get isReady => _initialized && _box != null;

  Box? get box => _box;

  // ==================== String Methods ====================

  Future<void> saveString(String key, String value) async {
    if (box == null) return;
    try {
      await box!.put(key, value);
    } catch (e) {
      debugPrint('Error saving string $key: $e');
    }
  }

  Future<String?> getString(String key) async {
    if (box == null) return null;
    try {
      return box!.get(key) as String?;
    } catch (e) {
      debugPrint('Error getting string $key: $e');
      return null;
    }
  }

  // ==================== Int Methods ====================

  Future<void> saveInt(String key, int value) async {
    if (box == null) return;
    try {
      await box!.put(key, value);
    } catch (e) {
      debugPrint('Error saving int $key: $e');
    }
  }

  Future<int?> getInt(String key) async {
    if (box == null) return null;
    try {
      return box!.get(key) as int?;
    } catch (e) {
      debugPrint('Error getting int $key: $e');
      return null;
    }
  }

  // ==================== Bool Methods ====================

  Future<void> saveBool(String key, bool value) async {
    if (box == null) return;
    try {
      await box!.put(key, value);
    } catch (e) {
      debugPrint('Error saving bool $key: $e');
    }
  }

  Future<bool> getBool(String key) async {
    if (box == null) return false;
    try {
      return box!.get(key, defaultValue: false) as bool;
    } catch (e) {
      debugPrint('Error getting bool $key: $e');
      return false;
    }
  }

  // ==================== Double Methods ====================

  Future<void> saveDouble(String key, double value) async {
    if (box == null) return;
    try {
      await box!.put(key, value);
    } catch (e) {
      debugPrint('Error saving double $key: $e');
    }
  }

  Future<double?> getDouble(String key) async {
    if (box == null) return null;
    try {
      return box!.get(key) as double?;
    } catch (e) {
      debugPrint('Error getting double $key: $e');
      return null;
    }
  }

  // ==================== List<String> Methods ====================

  Future<void> saveStringList(String key, List<String> value) async {
    if (box == null) return;
    try {
      await box!.put(key, value);
    } catch (e) {
      debugPrint('Error saving list $key: $e');
    }
  }

  Future<List<String>> getStringList(String key) async {
    if (box == null) return [];
    try {
      final value = box!.get(key);
      if (value == null) return [];
      return List<String>.from(value);
    } catch (e) {
      debugPrint('Error getting list $key: $e');
      return [];
    }
  }

  // ==================== Delete & Clear Methods ====================

  Future<void> remove(String key) async {
    if (box == null) return;
    try {
      await box!.delete(key);
    } catch (e) {
      debugPrint('Error removing $key: $e');
    }
  }

  Future<void> clear() async {
    if (box == null) return;
    try {
      await box!.clear();
    } catch (e) {
      debugPrint('Error clearing storage: $e');
    }
  }

  // ==================== Utility Methods ====================

  Future<bool> containsKey(String key) async {
    if (box == null) return false;
    try {
      return box!.containsKey(key);
    } catch (e) {
      debugPrint('Error checking key $key: $e');
      return false;
    }
  }

  Map<String, dynamic> readAll() {
    if (box == null) return {};
    try {
      return box!.toMap().cast<String, dynamic>();
    } catch (e) {
      debugPrint('Error reading all: $e');
      return {};
    }
  }
}
