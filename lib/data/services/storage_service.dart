import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  
  factory StorageService() => _instance;
  
  StorageService._internal();

  final _storage = const FlutterSecureStorage();

  // String methods
  Future<void> saveString(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> getString(String key) async {
    return await _storage.read(key: key);
  }

  // Int methods
  Future<void> saveInt(String key, int value) async {
    await _storage.write(key: key, value: value.toString());
  }

  Future<int?> getInt(String key) async {
    final value = await _storage.read(key: key);
    return value != null ? int.tryParse(value) : null;
  }

  // Bool methods
  Future<void> saveBool(String key, bool value) async {
    await _storage.write(key: key, value: value.toString());
  }

  Future<bool> getBool(String key) async {
    final value = await _storage.read(key: key);
    return value == 'true';
  }

  // Delete
  Future<void> remove(String key) async {
    await _storage.delete(key: key);
  }

  // Clear all
  Future<void> clear() async {
    await _storage.deleteAll();
  }
}
