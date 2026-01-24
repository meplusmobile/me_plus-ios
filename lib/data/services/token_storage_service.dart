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
    
    debugPrint('\n🧪 ═══════════════════════════════════════');
    debugPrint('🧪 TESTING iOS KEYCHAIN FUNCTIONALITY');
    debugPrint('🧪 ═══════════════════════════════════════');
    
    try {
      const testKey = '__keychain_test_key__';
      const testValue = 'test_value_12345_iOS_Keychain_Test';
      
      // Test 1: Write
      debugPrint('📝 Test 1: Writing test value to Keychain...');
      await _storage.saveSecureString(testKey, testValue);
      await Future.delayed(const Duration(milliseconds: 300));
      debugPrint('  ✅ Write completed');
      
      // Test 2: Read
      debugPrint('📖 Test 2: Reading test value from Keychain...');
      final readValue = await _storage.getSecureString(testKey);
      debugPrint('  📦 Read value: ${readValue != null ? 'EXISTS' : 'NULL'}');
      
      // Test 3: Verify
      debugPrint('🔍 Test 3: Verifying match...');
      final matches = readValue == testValue;
      debugPrint('  ${matches ? '✅' : '❌'} Match: $matches');
      
      // Cleanup
      await _storage.removeSecure(testKey);
      
      _keychainTested = true;
      _keychainWorking = matches;
      
      debugPrint('═══════════════════════════════════════');
      debugPrint('🧪 Keychain Test Result: ${_keychainWorking ? '✅ WORKING' : '❌ BROKEN'}');
      debugPrint('═══════════════════════════════════════\n');
      
      return _keychainWorking;
    } catch (e) {
      debugPrint('❌ Keychain test error: $e');
      _keychainTested = true;
      _keychainWorking = false;
      debugPrint('═══════════════════════════════════════');
      debugPrint('🧪 Keychain Test Result: ❌ BROKEN (Exception)');
      debugPrint('═══════════════════════════════════════\n');
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
    debugPrint('\n═══════════════════════════════════════');
    debugPrint('💾 SAVING ACCESS TOKEN');
    debugPrint('═══════════════════════════════════════');
    debugPrint('Token length: ${token.length}');
    debugPrint('Token preview: ${token.substring(0, token.length > 30 ? 30 : token.length)}...');
    
    // ═══════════════════════════════════════
    // STEP 1: Memory Cache (Instant)
    // ═══════════════════════════════════════
    debugPrint('\n📍 STEP 1: Saving to Memory Cache...');
    debugPrint('  🔍 Before: _cachedAccessToken = ${_cachedAccessToken != null ? 'EXISTS' : 'NULL'}');
    _cachedAccessToken = token;
    _cachedRefreshToken = refreshToken;
    debugPrint('  ✅ Memory cache updated');
    debugPrint('  🔍 After: _cachedAccessToken = ${_cachedAccessToken != null ? 'EXISTS' : 'NULL'}');
    debugPrint('  ✅ Can read from cache: ${_cachedAccessToken != null}');
    debugPrint('  ✅ Singleton instance: ${identical(this, TokenStorageService())}');
    debugPrint('  ✅ Cache value matches: ${_cachedAccessToken == token}');
    
    // ═══════════════════════════════════════
    // STEP 2: SharedPreferences (Backup)
    // ═══════════════════════════════════════
    debugPrint('\n📍 STEP 2: Saving to SharedPreferences...');
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('backup_$_tokenKey', token);
      await prefs.setString('backup_$_refreshTokenKey', refreshToken);
      
      // Verify SharedPreferences
      final verified = prefs.getString('backup_$_tokenKey');
      if (verified == token) {
        debugPrint('  ✅ SharedPreferences saved & verified');
      } else {
        debugPrint('  ⚠️ SharedPreferences verification failed');
      }
    } catch (e) {
      debugPrint('  ❌ SharedPreferences error: $e');
    }
    
    // ═══════════════════════════════════════
    // STEP 3: iOS Keychain (Primary Secure)
    // ═══════════════════════════════════════
    debugPrint('\n📍 STEP 3: Saving to iOS Keychain...');
    
    // Test keychain first
    await _testKeychainFunctionality();
    
    if (_keychainWorking) {
      debugPrint('  🔐 Keychain is working, proceeding...');
      await _storage.saveSecureString(_tokenKey, token);
      await _storage.saveSecureString(_refreshTokenKey, refreshToken);
      
      // Verify keychain save
      await Future.delayed(const Duration(milliseconds: 300));
      final keychainVerify = await _storage.getSecureString(_tokenKey);
      if (keychainVerify == token) {
        debugPrint('  ✅ iOS Keychain saved & verified');
      } else {
        debugPrint('  ⚠️ iOS Keychain verification failed');
        debugPrint('  📦 Stored: ${keychainVerify != null ? 'EXISTS but MISMATCH' : 'NULL'}');
      }
    } else {
      debugPrint('  ⚠️ Keychain not working, using Memory + SharedPreferences only');
    }
    
    // ═══════════════════════════════════════
    // STEP 4: Other User Data
    // ═══════════════════════════════════════
    debugPrint('\n📍 STEP 4: Saving other user data...');
    await _storage.saveString(_userIdKey, userId);
    await _storage.saveString(_userEmailKey, email);
    await _storage.saveString(_userRoleKey, role);
    await _storage.saveBool(_isFirstTimeUserKey, isFirstTimeUser);
    debugPrint('  ✅ User data saved');
    
    debugPrint('\n═══════════════════════════════════════');
    debugPrint('✅ SAVE COMPLETE - Summary:');
    debugPrint('  • Memory Cache: ✅');
    debugPrint('  • SharedPreferences: ✅');
    debugPrint('  • iOS Keychain: ${_keychainWorking ? '✅' : '⚠️ (fallback mode)'}');
    debugPrint('═══════════════════════════════════════\n');
  }

  // ═══════════════════════════════════════════════════════════════
  // GET TOKEN - TRIPLE RETRIEVAL STRATEGY
  // ═══════════════════════════════════════════════════════════════
  Future<String?> getToken() async {
    debugPrint('\n🔍 ═══════════════════════════════════════');
    debugPrint('🔍 RETRIEVING ACCESS TOKEN');
    debugPrint('🔍 ═══════════════════════════════════════');
    debugPrint('🔍 Singleton instance: ${identical(this, TokenStorageService())}');
    debugPrint('🔍 Cache state: ${_cachedAccessToken != null ? 'HAS DATA' : 'EMPTY'}');
    
    // Try Level 1: Memory Cache (Instant)
    if (_cachedAccessToken != null) {
      debugPrint('✅ LEVEL 1: Found in Memory Cache (instant)');
      debugPrint('   Token preview: ${_cachedAccessToken!.substring(0, 30)}...');
      debugPrint('   Token length: ${_cachedAccessToken!.length}');
      debugPrint('═══════════════════════════════════════\n');
      return _cachedAccessToken;
    }
    debugPrint('❌ LEVEL 1: Not in Memory Cache (_cachedAccessToken is NULL)');
    
    // Try Level 2: SharedPreferences (Backup)
    try {
      final prefs = await SharedPreferences.getInstance();
      final backupToken = prefs.getString('backup_$_tokenKey');
      if (backupToken != null) {
        debugPrint('✅ LEVEL 2: Found in SharedPreferences');
        _cachedAccessToken = backupToken; // Cache it
        debugPrint('   Token preview: ${backupToken.substring(0, 30)}...');
        debugPrint('   ↻ Cached for next access');
        debugPrint('═══════════════════════════════════════\n');
        return backupToken;
      }
      debugPrint('❌ LEVEL 2: Not in SharedPreferences');
    } catch (e) {
      debugPrint('❌ LEVEL 2: SharedPreferences error: $e');
    }
    
    // Try Level 3: iOS Keychain (Primary)
    debugPrint('🔍 LEVEL 3: Checking iOS Keychain...');
    final keychainToken = await _storage.getSecureString(_tokenKey);
    if (keychainToken != null) {
      debugPrint('✅ LEVEL 3: Found in iOS Keychain');
      _cachedAccessToken = keychainToken; // Cache it
      debugPrint('   Token preview: ${keychainToken.substring(0, 30)}...');
      debugPrint('   ↻ Cached for next access');
      
      // Backup to SharedPreferences if not there
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('backup_$_tokenKey', keychainToken);
        debugPrint('   ✅ Backed up to SharedPreferences');
      } catch (e) {
        debugPrint('   ⚠️ Backup failed: $e');
      }
      
      debugPrint('═══════════════════════════════════════\n');
      return keychainToken;
    }
    debugPrint('❌ LEVEL 3: Not in iOS Keychain');
    
    debugPrint('═══════════════════════════════════════');
    debugPrint('❌ TOKEN NOT FOUND IN ANY STORAGE!');
    debugPrint('═══════════════════════════════════════\n');
    return null;
  }

  Future<String?> getRefreshToken() async {
    // Try cache first
    if (_cachedRefreshToken != null) return _cachedRefreshToken;
    
    // Try SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final backup = prefs.getString('backup_$_refreshTokenKey');
      if (backup != null) {
        _cachedRefreshToken = backup;
        return backup;
      }
    } catch (e) {
      debugPrint('SharedPreferences error: $e');
    }
    
    // Try Keychain
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

  // Clear all authentication data (logout)
  Future<void> clearAuthData() async {
    try {
      debugPrint('\n🗑️ ═══════════════════════════════════════');
      debugPrint('🗑️ CLEARING AUTH DATA');
      debugPrint('🗑️ ═══════════════════════════════════════');
      
      // Clear Level 1: Memory Cache
      debugPrint('📍 STEP 1: Clearing Memory Cache...');
      _cachedAccessToken = null;
      _cachedRefreshToken = null;
      debugPrint('  ✅ Memory cache cleared');
      
      // Clear Level 2: SharedPreferences
      debugPrint('📍 STEP 2: Clearing SharedPreferences...');
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('backup_$_tokenKey');
        await prefs.remove('backup_$_refreshTokenKey');
        debugPrint('  ✅ SharedPreferences cleared');
      } catch (e) {
        debugPrint('  ❌ SharedPreferences error: $e');
      }
      
      // Clear Level 3: iOS Keychain
      debugPrint('📍 STEP 3: Clearing iOS Keychain...');
      await _storage.removeSecure(_tokenKey);
      await _storage.removeSecure(_refreshTokenKey);
      debugPrint('  ✅ iOS Keychain cleared');
      
      // Clear other data
      debugPrint('📍 STEP 4: Clearing other user data...');
      await _storage.remove(_userIdKey);
      await _storage.remove(_userEmailKey);
      await _storage.remove(_userRoleKey);
      await _storage.remove(_isFirstTimeUserKey);
      debugPrint('  ✅ User data cleared');
      
      debugPrint('═══════════════════════════════════════');
      debugPrint('✅ ALL AUTH DATA CLEARED');
      debugPrint('═══════════════════════════════════════\n');
    } catch (e) {
      debugPrint('❌ Error clearing auth data: $e');
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
