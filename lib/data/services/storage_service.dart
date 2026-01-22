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
    await Hive.initFlutter();
    _box = await Hive.openBox('app_storage');
    _initialized = true;
  }

  Box get box {
    if (_box == null) {
      throw Exception('StorageService not initialized. Call StorageService.init() first.');
    }
    return _box!;
  }

  // ==================== String Methods ====================

  Future<void> saveString(String key, String value) async {
    await box.put(key, value);
  }

  Future<String?> getString(String key) async {
    return box.get(key) as String?;
  }

  // ==================== Int Methods ====================

  Future<void> saveInt(String key, int value) async {
    await box.put(key, value);
  }

  Future<int?> getInt(String key) async {
    return box.get(key) as int?;
  }

  // ==================== Bool Methods ====================

  Future<void> saveBool(String key, bool value) async {
    await box.put(key, value);
  }

  Future<bool> getBool(String key) async {
    return box.get(key, defaultValue: false) as bool;
  }

  // ==================== Double Methods ====================

  Future<void> saveDouble(String key, double value) async {
    await box.put(key, value);
  }

  Future<double?> getDouble(String key) async {
    return box.get(key) as double?;
  }

  // ==================== List<String> Methods ====================

  Future<void> saveStringList(String key, List<String> value) async {
    await box.put(key, value);
  }

  Future<List<String>> getStringList(String key) async {
    final value = box.get(key);
    if (value == null) return [];
    return List<String>.from(value);
  }

  // ==================== Delete & Clear Methods ====================

  Future<void> remove(String key) async {
    await box.delete(key);
  }

  Future<void> clear() async {
    await box.clear();
  }

  // ==================== Utility Methods ====================

  Future<bool> containsKey(String key) async {
    return box.containsKey(key);
  }

  Map<String, dynamic> readAll() {
    return box.toMap().cast<String, dynamic>();
  }
}
