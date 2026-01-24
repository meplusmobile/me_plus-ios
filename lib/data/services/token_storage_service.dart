import 'package:flutter/material.dart';
import 'package:me_plus/data/services/storage_service.dart';

class TokenStorageService {
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
  
  // ========== IN-MEMORY CACHE FOR INSTANT ACCESS ==========
  // Critical for iOS: Keychain has delay, cache gives instant access
  String? _cachedAccessToken;
  String? _cachedRefreshToken;

  // Save authentication data - tokens use iOS Keychain for security
  Future<void> saveAuthData({
    required String token,
    required String refreshToken,
    required String userId,
    required String email,
    required String role,
    required bool isFirstTimeUser,
  }) async {
    debugPrint('💾 [TokenStorage] Saving auth data...');
    
    // 1. Cache tokens in memory FIRST (instant access)
    _cachedAccessToken = token;
    _cachedRefreshToken = refreshToken;
    debugPrint('✅ [TokenStorage] Tokens cached in memory');
    
    // 2. Save tokens to iOS Keychain (with proper timing)
    await _storage.saveSecureString(_tokenKey, token);
    await _storage.saveSecureString(_refreshTokenKey, refreshToken);
    
    // 3. Save other data to storage
    await _storage.saveString(_userIdKey, userId);
    await _storage.saveString(_userEmailKey, email);
    await _storage.saveString(_userRoleKey, role);
    await _storage.saveBool(_isFirstTimeUserKey, isFirstTimeUser);
    
    debugPrint('✅ [TokenStorage] Auth data saved: userId=$userId');
  }

  Future<String?> getToken() async {
    // Try cache first (instant!)
    if (_cachedAccessToken != null) {
      debugPrint('🎯 [TokenStorage] Token from cache (instant)');
      return _cachedAccessToken;
    }
    
    // Fallback to keychain
    debugPrint('🔍 [TokenStorage] Reading token from keychain...');
    final token = await _storage.getSecureString(_tokenKey);
    if (token != null) {
      _cachedAccessToken = token; // Cache it for next time
      debugPrint('✅ [TokenStorage] Token loaded and cached');
    }
    return token;
  }

  Future<String?> getRefreshToken() async {
    // Try cache first
    if (_cachedRefreshToken != null) {
      return _cachedRefreshToken;
    }
    
    // Fallback to keychain
    final refreshToken = await _storage.getSecureString(_refreshTokenKey);
    if (refreshToken != null) {
      _cachedRefreshToken = refreshToken;
    }
    return refreshToken;
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

  // Clear all authentication data (logout)
  Future<void> clearAuthData() async {
    try {
      debugPrint('🗑️ [TokenStorage] Clearing auth data...');
      
      // Clear cache FIRST
      _cachedAccessToken = null;
      _cachedRefreshToken = null;
      
      // Clear tokens from iOS Keychain
      await _storage.removeSecure(_tokenKey);
      await _storage.removeSecure(_refreshTokenKey);
      
      // Clear other data from regular preferences
      await _storage.remove(_userIdKey);
      await _storage.remove(_userEmailKey);
      await _storage.remove(_userRoleKey);
      await _storage.remove(_isFirstTimeUserKey);
      
      debugPrint('✅ Auth data cleared from iOS Keychain and preferences');
    } catch (e) {
      debugPrint('Error clearing auth data: $e');
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
