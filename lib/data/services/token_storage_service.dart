import 'package:flutter/material.dart';
import 'package:me_plus/data/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ═══════════════════════════════════════════════════════════════
/// TRIPLE STORAGE SYSTEM FOR iOS TOKEN PERSISTENCE
/// ═══════════════════════════════════════════════════════════════
/// 1. Memory Cache (Instant access, lost on app restart)
/// 2. SharedPreferences (Backup, survives restart)
/// 3. iOS Keychain (Primary secure storage)
/// ═══════════════════════════════════════════════════════════════
class TokenStorageService {
  // ═══════════════════════════════════════════════════════════════
  // SINGLETON PATTERN - CRITICAL FOR MEMORY CACHE PERSISTENCE!
  // ═══════════════════════════════════════════════════════════════
  static final TokenStorageService _instance = TokenStorageService._internal();
  factory TokenStorageService() => _instance;
  TokenStorageService._internal();
  
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _userRoleKey = 'user_role';
  static const String _isFirstTimeUserKey = 'is_first_time_user';
  static const String _rememberMeKey = 'remember_me';
  static const String _savedEmailKey = 'saved_email';
  static const String _savedPasswordKey = 'saved_password';

  final _storage = StorageService();
  
  // ═══════════════════════════════════════════════════════════════
  // LEVEL 1: MEMORY CACHE (Fastest - Instant Access)
  // ═══════════════════════════════════════════════════════════════
  String? _cachedAccessToken;
  String? _cachedRefreshToken;
  bool _keychainTested = false;
  bool _keychainWorking = false;

  // ═══════════════════════════════════════════════════════════════
  // KEYCHAIN FUNCTIONALITY TEST
  // ═══════════════════════════════════════════════════════════════
  Future<bool> _testKeychainFunctionality() async {
    if (_keychainTested) return _keychainWorking;
    
    try {
      const testKey = '__keychain_test_key__';
      const testValue = 'test_value_12345_iOS_Keychain_Test';
      
      await _storage.saveSecureString(testKey, testValue);
      await Future.delayed(const Duration(milliseconds: 300));
      
      final readValue = await _storage.getSecureString(testKey);
      final matches = readValue == testValue;
      
      await _storage.removeSecure(testKey);
      
      _keychainTested = true;
      _keychainWorking = matches;
      
      return _keychainWorking;
    } catch (e) {
      _keychainTested = true;
      _keychainWorking = false;
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // SAVE TOKEN - TRIPLE STORAGE STRATEGY
  // ═══════════════════════════════════════════════════════════════
  Future<void> saveAuthData({
    required String token,
    required String refreshToken,
    required String userId,
    required String email,
    required String role,
    required bool isFirstTimeUser,
  }) async {
    // Save to Memory Cache
    _cachedAccessToken = token;
    _cachedRefreshToken = refreshToken;
    
    // Save to SharedPreferences (Backup)
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('backup_$_tokenKey', token);
      await prefs.setString('backup_$_refreshTokenKey', refreshToken);
    } catch (e) {
      // Ignore SharedPreferences errors
    }
    
    // Save to iOS Keychain (if working)
    await _testKeychainFunctionality();
    
    if (_keychainWorking) {
      await _storage.saveSecureString(_tokenKey, token);
      await _storage.saveSecureString(_refreshTokenKey, refreshToken);
    }
    
    // Save other user data
    await _storage.saveString(_userIdKey, userId);
    await _storage.saveString(_userEmailKey, email);
    await _storage.saveString(_userRoleKey, role);
    await _storage.saveBool(_isFirstTimeUserKey, isFirstTimeUser);
  }

  Future<String?> getToken() async {
    // Try Memory Cache first
    if (_cachedAccessToken != null) {
      return _cachedAccessToken;
    }
    
    // Try SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final backupToken = prefs.getString('backup_$_tokenKey');
      if (backupToken != null) {
        _cachedAccessToken = backupToken;
        return backupToken;
      }
    } catch (e) {
      // Ignore
    }
    
    // Try iOS Keychain
    final keychainToken = await _storage.getSecureString(_tokenKey);
    if (keychainToken != null) {
      _cachedAccessToken = keychainToken;
      
      // Backup to SharedPreferences
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('backup_$_tokenKey', keychainToken);
      } catch (e) {
        // Ignore
      }
      
      return keychainToken;
    }
    
    return null;
  }

  Future<String?> getRefreshToken() async {
    if (_cachedRefreshToken != null) return _cachedRefreshToken;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final backup = prefs.getString('backup_$_refreshTokenKey');
      if (backup != null) {
        _cachedRefreshToken = backup;
        return backup;
      }
    } catch (e) {
      // Ignore
    }
    
    final token = await _storage.getSecureString(_refreshTokenKey);
    if (token != null) _cachedRefreshToken = token;
    return token;
  }

  Future<String?> getUserId() async {
    return await _storage.getString(_userIdKey);
  }

  Future<String?> getUserEmail() async {
    return await _storage.getString(_userEmailKey);
  }

  Future<String?> getUserRole() async {
    return await _storage.getString(_userRoleKey);
  }

  Future<bool> isFirstTimeUser() async {
    return await _storage.getBool(_isFirstTimeUserKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> clearAuthData() async {
    try {
      _cachedAccessToken = null;
      _cachedRefreshToken = null;
      
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('backup_$_tokenKey');
        await prefs.remove('backup_$_refreshTokenKey');
      } catch (e) {
        // Ignore
      }
      
      await _storage.removeSecure(_tokenKey);
      await _storage.removeSecure(_refreshTokenKey);
      
      await _storage.remove(_userIdKey);
      await _storage.remove(_userEmailKey);
      await _storage.remove(_userRoleKey);
      await _storage.remove(_isFirstTimeUserKey);
    } catch (e) {
      // Ignore
    }
  }

  // Save Remember Me credentials
  Future<void> saveRememberMe({
    required bool rememberMe,
    String? email,
    String? password,
  }) async {
    try {
      await _storage.saveBool(_rememberMeKey, rememberMe);
      
      if (rememberMe && email != null && password != null) {
        await _storage.saveString(_savedEmailKey, email);
        await _storage.saveString(_savedPasswordKey, password);
      } else {
        await _storage.remove(_savedEmailKey);
        await _storage.remove(_savedPasswordKey);
      }
    } catch (e) {
      debugPrint('Error saving remember me: $e');
    }
  }

  Future<bool> getRememberMe() async {
    return await _storage.getBool(_rememberMeKey);
  }

  // Debug method to check token storage status
  Future<void> debugTokenStorage() async {
    final hasToken = await isLoggedIn();
    final token = await getToken();
    final refreshToken = await getRefreshToken();
    final userId = await getUserId();
    
    debugPrint('=== iOS Keychain Token Debug ===');
    debugPrint('✅ Has Token: $hasToken');
    debugPrint('✅ Token exists: ${token != null}');
    if (token != null && token.length > 20) {
      debugPrint('✅ Token preview: ${token.substring(0, 20)}...');
      debugPrint('✅ Token length: ${token.length}');
    }
    debugPrint('✅ Refresh token exists: ${refreshToken != null}');
    debugPrint('✅ User ID: $userId');
    debugPrint('================================');
  }

  Future<String?> getSavedEmail() async {
    return await _storage.getString(_savedEmailKey);
  }

  Future<String?> getSavedPassword() async {
    return await _storage.getString(_savedPasswordKey);
  }
}
