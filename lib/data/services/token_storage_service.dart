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

  // Save authentication data - tokens use iOS Keychain for security
  Future<void> saveAuthData({
    required String token,
    required String refreshToken,
    required String userId,
    required String email,
    required String role,
    required bool isFirstTimeUser,
  }) async {
    // Save tokens to secure storage (iOS Keychain)
    await _storage.saveSecureString(_tokenKey, token);
    await _storage.saveSecureString(_refreshTokenKey, refreshToken);
    
    // Save other data to regular preferences
    await _storage.saveString(_userIdKey, userId);
    await _storage.saveString(_userEmailKey, email);
    await _storage.saveString(_userRoleKey, role);
    await _storage.saveBool(_isFirstTimeUserKey, isFirstTimeUser);
    
    debugPrint('✅ Auth data saved: token & refreshToken in iOS Keychain, userId=$userId');
  }

  Future<String?> getToken() async {
    return await _storage.getSecureString(_tokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.getSecureString(_refreshTokenKey);
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
