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

  // Save authentication data
  Future<void> saveAuthData({
    required String token,
    required String refreshToken,
    required String userId,
    required String email,
    required String role,
    required bool isFirstTimeUser,
  }) async {
    await _storage.saveString(_tokenKey, token);
    await _storage.saveString(_refreshTokenKey, refreshToken);
    await _storage.saveString(_userIdKey, userId);
    await _storage.saveString(_userEmailKey, email);
    await _storage.saveString(_userRoleKey, role);
    await _storage.saveBool(_isFirstTimeUserKey, isFirstTimeUser);
  }

  Future<String?> getToken() async {
    return await _storage.getString(_tokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.getString(_refreshTokenKey);
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
      await _storage.remove(_tokenKey);
      await _storage.remove(_refreshTokenKey);
      await _storage.remove(_userIdKey);
      await _storage.remove(_userEmailKey);
      await _storage.remove(_userRoleKey);
      await _storage.remove(_isFirstTimeUserKey);
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

  Future<String?> getSavedEmail() async {
    return await _storage.getString(_savedEmailKey);
  }

  Future<String?> getSavedPassword() async {
    return await _storage.getString(_savedPasswordKey);
  }
}
