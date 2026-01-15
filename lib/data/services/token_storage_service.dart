import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // Save authentication data
  Future<void> saveAuthData({
    required String token,
    required String refreshToken,
    required String userId,
    required String email,
    required String role,
    required bool isFirstTimeUser,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      await prefs.setString(_refreshTokenKey, refreshToken);
      await prefs.setString(_userIdKey, userId);
      await prefs.setString(_userEmailKey, email);
      await prefs.setString(_userRoleKey, role);
      await prefs.setBool(_isFirstTimeUserKey, isFirstTimeUser);
    } catch (e) {
      debugPrint('Error saving auth data: $e');
      rethrow;
    }
  }

  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      debugPrint('Error getting token: $e');
      return null;
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_refreshTokenKey);
    } catch (e) {
      debugPrint('Error getting refresh token: $e');
      return null;
    }
  }

  Future<String?> getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userIdKey);
    } catch (e) {
      debugPrint('Error getting user ID: $e');
      return null;
    }
  }

  Future<String?> getUserEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userEmailKey);
    } catch (e) {
      debugPrint('Error getting user email: $e');
      return null;
    }
  }

  Future<String?> getUserRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userRoleKey);
    } catch (e) {
      debugPrint('Error getting user role: $e');
      return null;
    }
  }

  Future<bool> isFirstTimeUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isFirstTimeUserKey) ?? true;
    } catch (e) {
      debugPrint('Error checking first time user: $e');
      return true;
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      final token = await getToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking logged in status: $e');
      return false;
    }
  }

  // Clear all authentication data (logout)
  Future<void> clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_refreshTokenKey);
      await prefs.remove(_userIdKey);
      await prefs.remove(_userEmailKey);
      await prefs.remove(_userRoleKey);
      await prefs.remove(_isFirstTimeUserKey);
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
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_rememberMeKey, rememberMe);
      
      if (rememberMe && email != null && password != null) {
        await prefs.setString(_savedEmailKey, email);
        await prefs.setString(_savedPasswordKey, password);
      } else {
        await prefs.remove(_savedEmailKey);
        await prefs.remove(_savedPasswordKey);
      }
    } catch (e) {
      debugPrint('Error saving remember me: $e');
    }
  }

  Future<bool> getRememberMe() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_rememberMeKey) ?? false;
    } catch (e) {
      debugPrint('Error getting remember me: $e');
      return false;
    }
  }

  Future<String?> getSavedEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_savedEmailKey);
    } catch (e) {
      debugPrint('Error getting saved email: $e');
      return null;
    }
  }

  Future<String?> getSavedPassword() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_savedPasswordKey);
    } catch (e) {
      debugPrint('Error getting saved password: $e');
      return null;
    }
  }
}
