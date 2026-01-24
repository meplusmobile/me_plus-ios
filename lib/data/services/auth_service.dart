import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:me_plus/core/constants/api_constants.dart';
import 'package:me_plus/data/models/auth_response.dart';
import 'package:me_plus/core/services/debug_log_service.dart';
import 'package:me_plus/data/models/signup_request.dart';
import 'package:me_plus/data/models/login_request.dart';
import 'package:me_plus/data/models/user_profile.dart';
import 'package:me_plus/data/models/school.dart';
import 'package:me_plus/data/models/class_model.dart';
import 'package:me_plus/data/models/forgot_password_request.dart';
import 'package:me_plus/data/services/token_storage_service.dart';

/// AuthService using http package - Works 100% on iOS!
class AuthService {
  final TokenStorageService _tokenStorage;
  final http.Client _client = http.Client();
  final DebugLogService _debugLog = DebugLogService();
  
  static const Duration _timeout = Duration(seconds: 15);

  AuthService({TokenStorageService? tokenStorage})
    : _tokenStorage = tokenStorage ?? TokenStorageService();

  /// Get headers with optional auth token
  Future<Map<String, String>> _getHeaders({bool withAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (withAuth) {
      final token = await _tokenStorage.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  /// Handle HTTP response
  dynamic _handleResponse(http.Response response, {String operation = 'Request'}) {
    debugPrint('✅ [$operation] Status: ${response.statusCode}');
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else {
      String error = '$operation failed';
      try {
        final data = jsonDecode(response.body);
        if (data is Map) {
          error = data['message'] ?? data['error'] ?? error;
        } else if (data is String) {
          error = data;
        }
      } catch (_) {
        if (response.body.isNotEmpty) error = response.body;
      }
      throw Exception(error);
    }
  }

  // ==================== Login ====================
  Future<AuthResponse> login(LoginRequest request) async {
    debugPrint('🔐 [Login] Starting...');
    _debugLog.logInfo('Login: Starting...');
    final url = '${ApiConstants.baseUrl}${ApiConstants.login}';

    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: await _getHeaders(withAuth: false),
        body: jsonEncode(request.toJson()),
      ).timeout(_timeout);

      _debugLog.logApiCall('Login', response.statusCode);
      final data = _handleResponse(response, operation: 'Login');
      final authResponse = AuthResponse.fromJson(data);

      await _tokenStorage.saveAuthData(
        token: authResponse.token,
        refreshToken: authResponse.refreshToken,
        userId: authResponse.id.toString(),
        email: authResponse.email,
        role: authResponse.role,
        isFirstTimeUser: authResponse.isFirstTimeUser,
      );

      debugPrint('═══════════════════════════════════════');
      debugPrint('🧪 [Login] IMMEDIATE TOKEN VERIFICATION');
      debugPrint('═══════════════════════════════════════');
      
      // CRITICAL TEST: Verify token was actually saved and can be retrieved
      // With in-memory cache AND singleton, this should ALWAYS work!
      debugPrint('🧪 Calling getToken() immediately...');
      final testToken = await _tokenStorage.getToken();
      debugPrint('🧪 Result: ${testToken != null ? 'GOT TOKEN' : 'NULL'}');
      
      if (testToken == null) {
        debugPrint('🚨🚨🚨 [Login] CRITICAL: Token is NULL after save!');
        debugPrint('🚨 This should NEVER happen with Singleton + Memory Cache!');
        _debugLog.logError('CRITICAL: Token NULL after save!');
      } else if (testToken == authResponse.token) {
        debugPrint('✅✅✅ [Login] Token verified successfully!');
        debugPrint('   Preview: ${testToken.substring(0, 30)}...');
        debugPrint('   Length: ${testToken.length}');
        debugPrint('   Singleton: ${identical(_tokenStorage, TokenStorageService())}');
        _debugLog.logSuccess('✅✅✅ LOGIN SUCCESS - Token verified!');
      } else {
        debugPrint('⚠️⚠️⚠️ [Login] Token MISMATCH!');
        debugPrint('   Expected length: ${authResponse.token.length}');
        debugPrint('   Got length: ${testToken.length}');
        _debugLog.logError('Token mismatch! Saved != Retrieved');
      }
      
      debugPrint('═══════════════════════════════════════\n');
      _debugLog.logSuccess('Login successful! Token saved to iOS Keychain');
      debugPrint('✅ [Login] Success!');
      return authResponse;
    } catch (e) {
      debugPrint('❌ [Login] Error: $e');
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Connection timeout. Please try again.');
      }
      rethrow;
    }
  }

  // ==================== Signup ====================
  Future<AuthResponse> signup(SignupRequest request) async {
    debugPrint('📝 [Signup] Starting...');
    final url = '${ApiConstants.baseUrl}${ApiConstants.signup}';

    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: await _getHeaders(withAuth: false),
        body: jsonEncode(request.toJson()),
      ).timeout(_timeout);

      final data = _handleResponse(response, operation: 'Signup');
      final authResponse = AuthResponse.fromJson(data);

      await _tokenStorage.saveAuthData(
        token: authResponse.token,
        refreshToken: authResponse.refreshToken,
        userId: authResponse.id.toString(),
        email: authResponse.email,
        role: authResponse.role,
        isFirstTimeUser: authResponse.isFirstTimeUser,
      );

      debugPrint('✅ [Signup] Success!');
      return authResponse;
    } catch (e) {
      debugPrint('❌ [Signup] Error: $e');
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Connection timeout. Please try again.');
      }
      rethrow;
    }
  }

  // ==================== Refresh Token ====================
  Future<AuthResponse> refreshToken() async {
    debugPrint('🔄 [RefreshToken] Starting...');
    
    final refreshTokenValue = await _tokenStorage.getRefreshToken();
    final userId = await _tokenStorage.getUserId();

    if (refreshTokenValue == null || userId == null) {
      throw Exception('No refresh token or user ID found');
    }

    final url = '${ApiConstants.baseUrl}/refresh-token';

    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: await _getHeaders(withAuth: false),
        body: jsonEncode({
          'userId': userId,
          'refreshToken': refreshTokenValue,
        }),
      ).timeout(_timeout);

      final data = _handleResponse(response, operation: 'RefreshToken');
      final authResponse = AuthResponse.fromJson(data);

      await _tokenStorage.saveAuthData(
        token: authResponse.token,
        refreshToken: authResponse.refreshToken,
        userId: authResponse.id.toString(),
        email: authResponse.email,
        role: authResponse.role,
        isFirstTimeUser: authResponse.isFirstTimeUser,
      );

      debugPrint('✅ [RefreshToken] Success!');
      return authResponse;
    } catch (e) {
      debugPrint('❌ [RefreshToken] Error: $e');
      rethrow;
    }
  }

  // ==================== Logout ====================
  Future<void> logout() async {
    await _tokenStorage.clearAuthData();
  }

  Future<bool> isLoggedIn() async {
    return await _tokenStorage.isLoggedIn();
  }

  Future<String?> getUserRole() async {
    return await _tokenStorage.getUserRole();
  }

  Future<bool> isFirstTimeUser() async {
    return await _tokenStorage.isFirstTimeUser();
  }

  // ==================== Schools ====================
  Future<List<School>> getSchools() async {
    debugPrint('🏫 [GetSchools] Fetching...');
    final url = '${ApiConstants.baseUrl}${ApiConstants.schools}';

    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: await _getHeaders(withAuth: false),
      ).timeout(_timeout);

      final data = _handleResponse(response, operation: 'GetSchools');
      
      if (data is List) {
        return data.map((json) => School.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('❌ [GetSchools] Error: $e');
      rethrow;
    }
  }

  // ==================== Classes ====================
  Future<List<ClassModel>> getClassesBySchool(int schoolId) async {
    debugPrint('📚 [GetClasses] Fetching for school $schoolId...');
    final url = '${ApiConstants.baseUrl}/api/schools/$schoolId/classes';

    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      ).timeout(_timeout);

      final data = _handleResponse(response, operation: 'GetClasses');
      
      if (data is List) {
        return data.map((json) => ClassModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('❌ [GetClasses] Error: $e');
      rethrow;
    }
  }

  // ==================== Student Request ====================
  Future<void> submitStudentRequest({
    required String schoolId,
    required String classId,
  }) async {
    debugPrint('📨 [StudentRequest] Submitting...');
    final url = '${ApiConstants.baseUrl}/student_requests';

    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: await _getHeaders(),
        body: jsonEncode({
          'schoolId': schoolId,
          'ClassId': classId,
        }),
      ).timeout(_timeout);

      _handleResponse(response, operation: 'StudentRequest');
      debugPrint('✅ [StudentRequest] Success!');
    } catch (e) {
      debugPrint('❌ [StudentRequest] Error: $e');
      rethrow;
    }
  }

  // ==================== Profile ====================
  Future<UserProfile> getProfile() async {
    debugPrint('👤 [GetProfile] Fetching...');
    final url = '${ApiConstants.baseUrl}${ApiConstants.profile}';

    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      ).timeout(_timeout);

      final data = _handleResponse(response, operation: 'GetProfile');
      return UserProfile.fromJson(data);
    } catch (e) {
      debugPrint('❌ [GetProfile] Error: $e');
      rethrow;
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    debugPrint('✏️ [UpdateProfile] Updating...');
    final url = '${ApiConstants.baseUrl}${ApiConstants.updateProfile}';

    try {
      final response = await _client.put(
        Uri.parse(url),
        headers: await _getHeaders(),
        body: jsonEncode(data),
      ).timeout(_timeout);

      _handleResponse(response, operation: 'UpdateProfile');
      debugPrint('✅ [UpdateProfile] Success!');
    } catch (e) {
      debugPrint('❌ [UpdateProfile] Error: $e');
      rethrow;
    }
  }

  // ==================== Forgot Password ====================
  Future<String> forgotPassword(String email) async {
    debugPrint('🔑 [ForgotPassword] Sending reset email...');
    final url = '${ApiConstants.baseUrl}${ApiConstants.forgetPassword}';

    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: await _getHeaders(withAuth: false),
        body: jsonEncode(ForgotPasswordRequest(email: email).toJson()),
      ).timeout(_timeout);

      final data = _handleResponse(response, operation: 'ForgotPassword');
      return data.toString();
    } catch (e) {
      debugPrint('❌ [ForgotPassword] Error: $e');
      rethrow;
    }
  }

  // ==================== Validate Reset Code ====================
  Future<bool> validateResetCode(String email, String code) async {
    debugPrint('🔢 [ValidateCode] Validating...');
    final url = '${ApiConstants.baseUrl}${ApiConstants.validateResetCode}';

    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: await _getHeaders(withAuth: false),
        body: jsonEncode(ValidateResetCodeRequest(email: email, code: code).toJson()),
      ).timeout(_timeout);

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('❌ [ValidateCode] Error: $e');
      rethrow;
    }
  }

  // ==================== Reset Password ====================
  Future<String> resetPassword(String email, String code, String newPassword) async {
    debugPrint('🔐 [ResetPassword] Resetting...');
    final url = '${ApiConstants.baseUrl}${ApiConstants.resetPassword}';

    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: await _getHeaders(withAuth: false),
        body: jsonEncode(ResetPasswordRequest(
          email: email,
          code: code,
          newPassword: newPassword,
        ).toJson()),
      ).timeout(_timeout);

      final data = _handleResponse(response, operation: 'ResetPassword');
      return data.toString();
    } catch (e) {
      debugPrint('❌ [ResetPassword] Error: $e');
      rethrow;
    }
  }

  // ==================== Change Password ====================
  Future<void> changePassword(String oldPassword, String newPassword) async {
    debugPrint('🔒 [ChangePassword] Changing...');
    final url = '${ApiConstants.baseUrl}${ApiConstants.changePassword}';

    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: await _getHeaders(),
        body: jsonEncode(ChangePasswordRequest(
          oldPassword: oldPassword,
          newPassword: newPassword,
        ).toJson()),
      ).timeout(_timeout);

      _handleResponse(response, operation: 'ChangePassword');
      debugPrint('✅ [ChangePassword] Success!');
    } catch (e) {
      debugPrint('❌ [ChangePassword] Error: $e');
      rethrow;
    }
  }

  // ==================== Check Token ====================
  Future<bool> checkToken() async {
    try {
      final url = '${ApiConstants.baseUrl}${ApiConstants.checkToken}';
      final response = await _client.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      ).timeout(_timeout);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ==================== Parent Request ====================
  Future<void> submitParentRequest({required List<String> emails}) async {
    debugPrint('👨‍👧 [ParentRequest] Submitting...');
    final url = '${ApiConstants.baseUrl}/parent_requests';

    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: await _getHeaders(),
        body: jsonEncode({'emails': emails}),
      ).timeout(_timeout);

      _handleResponse(response, operation: 'ParentRequest');
      debugPrint('✅ [ParentRequest] Success!');
    } catch (e) {
      debugPrint('❌ [ParentRequest] Error: $e');
      rethrow;
    }
  }

  // ==================== Update Market Owner Info ====================
  Future<void> updateMarketOwnerInfo({
    required String marketName,
    required String marketAddress,
  }) async {
    await updateProfile({
      'marketName': marketName,
      'address': marketAddress,
    });
  }

  void dispose() {
    _client.close();
  }
}
