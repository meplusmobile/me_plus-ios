import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:me_plus/core/constants/api_constants.dart';
import 'package:me_plus/data/models/auth_response.dart';
import 'package:me_plus/data/models/signup_request.dart';
import 'package:me_plus/data/models/login_request.dart';
import 'package:me_plus/data/models/user_profile.dart';
import 'package:me_plus/data/models/school.dart';
import 'package:me_plus/data/models/class_model.dart';
import 'package:me_plus/data/models/forgot_password_request.dart';
import 'package:me_plus/data/services/token_storage_service.dart';

class AuthService {
  final Dio _dio;
  final TokenStorageService _tokenStorage;

  AuthService({Dio? dio, TokenStorageService? tokenStorage})
    : _dio = dio ?? Dio(),
      _tokenStorage = tokenStorage ?? TokenStorageService() {
    _setupDio();
  }

  void _setupDio() {
    _dio.options.baseUrl = ApiConstants.baseUrl;
    
    // Fast timeouts - fail quickly to show errors
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    _dio.options.sendTimeout = const Duration(seconds: 10);
    
    // Simple headers
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Accept all HTTP status codes
    _dio.options.validateStatus = (status) => true;

    debugPrint('✅ [Auth] Dio configured - BaseURL: ${_dio.options.baseUrl}');

    // Add interceptor for token and logging
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Skip token only for public endpoints like schools list
          if (!options.path.contains('/api/schools') ||
              options.path.contains('/classes')) {
            // Add token to headers if available
            final token = await _tokenStorage.getToken();
            if (token != null) {
              options.headers[ApiConstants.authorization] = 'Bearer $token';
            }
          }

          // Debug logging for iOS network issues
          debugPrint('🌐 [Network] ${options.method} ${options.uri}');

          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('✅ [Network] Status ${response.statusCode}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          debugPrint('❌ [Network Error] ${e.type}: ${e.message}');
          debugPrint('📍 Response: ${e.response?.statusCode} - ${e.response?.data}');
          return handler.next(e);
        },
      ),
    );
  }

  // Signup
  Future<AuthResponse> signup(SignupRequest request) async {
    try {
      final response = await _dio.post(
        ApiConstants.signup,
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final authResponse = AuthResponse.fromJson(response.data);

        // Save authentication data
        await _tokenStorage.saveAuthData(
          token: authResponse.token,
          refreshToken: authResponse.refreshToken,
          userId: authResponse.id.toString(),
          email: authResponse.email,
          role: authResponse.role,
          isFirstTimeUser: authResponse.isFirstTimeUser,
        );

        return authResponse;
      } else {
        throw Exception('Signup failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        // Server returned an error response
        final responseData = e.response?.data;
        String errorMessage = 'Signup failed';

        if (responseData is String) {
          // API returned error as string (e.g., "DUPLICATED_USERNAME")
          errorMessage = responseData;
        } else if (responseData is Map) {
          // API returned error as object
          errorMessage =
              responseData['message'] ??
              responseData['error'] ??
              'Signup failed';
        }

        throw Exception(errorMessage);
      } else {
        // Network error or timeout
        throw Exception('Network error. Please check your connection.');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Refresh token
  Future<AuthResponse> refreshToken() async {
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      final userId = await _tokenStorage.getUserId();

      if (refreshToken == null || userId == null) {
        throw Exception('No refresh token or user ID found');
      }

      final response = await _dio.post(
        '/refresh-token',
        data: {'userId': userId, 'refreshToken': refreshToken},
      );

      final authResponse = AuthResponse.fromJson(response.data);

      // Save new tokens
      await _tokenStorage.saveAuthData(
        token: authResponse.token,
        refreshToken: authResponse.refreshToken,
        userId: authResponse.id.toString(),
        email: authResponse.email,
        role: authResponse.role,
        isFirstTimeUser: authResponse.isFirstTimeUser,
      );

      return authResponse;
    } catch (e) {
      throw Exception('Failed to refresh token: $e');
    }
  }

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

  // Login - using http package (simpler, more iOS compatible)
  Future<AuthResponse> login(LoginRequest request) async {
    debugPrint('🔐 [Login] Starting with http package...');
    final url = '${ApiConstants.baseUrl}${ApiConstants.login}';
    debugPrint('🔐 [Login] URL: $url');
    debugPrint('🔐 [Login] Email: ${request.email}');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(request.toJson()),
      ).timeout(const Duration(seconds: 15));

      debugPrint('✅ [Login] Got response: ${response.statusCode}');
      debugPrint('✅ [Login] Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        final authResponse = AuthResponse.fromJson(data);
        await _tokenStorage.saveAuthData(
          token: authResponse.token,
          refreshToken: authResponse.refreshToken,
          userId: authResponse.id.toString(),
          email: authResponse.email,
          role: authResponse.role,
          isFirstTimeUser: authResponse.isFirstTimeUser,
        );
        debugPrint('✅ [Login] Success!');
        return authResponse;
      } else {
        debugPrint('❌ [Login] Bad status: ${response.statusCode}');
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Login failed');
      }
    } catch (e) {
      debugPrint('❌ [Login] Error: $e');
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Connection timeout. Please try again.');
      }
      rethrow;
    }
  }

  Future<List<School>> getSchools() async {
    try {
      final response = await _dio.get(ApiConstants.schools);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => School.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch schools');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage =
            e.response?.data['message'] ??
            e.response?.data['error'] ??
            'Failed to fetch schools';
        throw Exception(errorMessage);
      } else {
        // Network error
        if (e.type == DioExceptionType.connectionTimeout) {
          throw Exception(
            'Connection timeout. Please check your internet connection.',
          );
        } else if (e.type == DioExceptionType.receiveTimeout) {
          throw Exception('Server response timeout. Please try again.');
        } else {
          throw Exception('Network error: ${e.message}');
        }
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<List<ClassModel>> getClassesBySchool(int schoolId) async {
    try {
      // Try to get token, but don't fail if not available
      final token = await _tokenStorage.getToken();
      final headers = <String, dynamic>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      if (token != null) {
        headers[ApiConstants.authorization] = 'Bearer $token';
      }

      final response = await _dio.get(
        '/api/schools/$schoolId/classes',
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ClassModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch classes');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage =
            e.response?.data['message'] ??
            e.response?.data['error'] ??
            'Failed to fetch classes';
        throw Exception(errorMessage);
      } else {
        if (e.type == DioExceptionType.connectionTimeout) {
          throw Exception(
            'Connection timeout. Please check your internet connection.',
          );
        } else if (e.type == DioExceptionType.receiveTimeout) {
          throw Exception('Server response timeout. Please try again.');
        } else {
          throw Exception('Network error: ${e.message}');
        }
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Submit Student Request to join School/Class (requires token)
  Future<void> submitStudentRequest({
    required String schoolId,
    required String classId,
  }) async {
    try {
      final response = await _dio.post(
        '/student_requests',
        data: {'schoolId': schoolId, 'ClassId': classId},
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to submit request');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final responseData = e.response?.data;
        String errorMessage = 'Failed to submit request';

        if (responseData is String) {
          // API returned error as string
          errorMessage = responseData;
        } else if (responseData is Map) {
          // API returned error as object
          errorMessage =
              responseData['message'] ??
              responseData['error'] ??
              'Failed to submit request';
        }

        throw Exception(errorMessage);
      } else {
        if (e.type == DioExceptionType.connectionTimeout) {
          throw Exception(
            'Connection timeout. Please check your internet connection.',
          );
        } else if (e.type == DioExceptionType.receiveTimeout) {
          throw Exception('Server response timeout. Please try again.');
        } else {
          throw Exception('Network error: ${e.message}');
        }
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<UserProfile> getProfile() async {
    try {
      final response = await _dio.get(ApiConstants.profile);

      if (response.statusCode == 200) {
        return UserProfile.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch profile');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage =
            e.response?.data['message'] ??
            e.response?.data['error'] ??
            'Failed to fetch profile';
        throw Exception(errorMessage);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Update Profile (sends data as form-data)
  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      // Create FormData
      final formData = FormData.fromMap(data);

      final response = await _dio.put(
        ApiConstants.updateProfile,
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to update profile');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage =
            e.response?.data['message'] ??
            e.response?.data['error'] ??
            'Failed to update profile';
        throw Exception(errorMessage);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Forgot Password
  Future<String> forgotPassword(String email) async {
    try {
      final response = await _dio.post(
        ApiConstants.forgetPassword,
        data: ForgotPasswordRequest(email: email).toJson(),
      );

      if (response.statusCode == 200) {
        return response.data.toString();
      } else {
        throw Exception('Failed to send reset email');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage =
            e.response?.data['message'] ??
            e.response?.data['error'] ??
            'Failed to send reset email';
        throw Exception(errorMessage);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Validate Reset Code
  Future<bool> validateResetCode(String email, String code) async {
    try {
      final response = await _dio.post(
        ApiConstants.validateResetCode,
        data: ValidateResetCodeRequest(email: email, code: code).toJson(),
      );

      return response.statusCode == 200;
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage =
            e.response?.data['message'] ??
            e.response?.data['error'] ??
            'Invalid code';
        throw Exception(errorMessage);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Reset Password
  Future<String> resetPassword(
    String email,
    String code,
    String newPassword,
  ) async {
    try {
      final response = await _dio.post(
        ApiConstants.resetPassword,
        data: ResetPasswordRequest(
          email: email,
          code: code,
          newPassword: newPassword,
        ).toJson(),
      );

      if (response.statusCode == 200) {
        return response.data.toString();
      } else {
        throw Exception('Failed to reset password');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage =
            e.response?.data['message'] ??
            e.response?.data['error'] ??
            'Failed to reset password';
        throw Exception(errorMessage);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Change Password
  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      final response = await _dio.post(
        ApiConstants.changePassword,
        data: ChangePasswordRequest(
          oldPassword: oldPassword,
          newPassword: newPassword,
        ).toJson(),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to change password');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage =
            e.response?.data['message'] ??
            e.response?.data['error'] ??
            'Failed to change password';
        throw Exception(errorMessage);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<bool> checkToken() async {
    try {
      final response = await _dio.get(ApiConstants.checkToken);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Submit Parent Request (add children)
  Future<void> submitParentRequest({required List<String> emails}) async {
    try {
      final response = await _dio.post(
        '/parent_requests',
        data: {'emails': emails},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success
      } else {
        throw Exception('Failed to submit parent request');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final responseData = e.response?.data;
        String errorMessage = 'Failed to submit parent request';

        if (responseData is String) {
          // API returned error as string
          errorMessage = responseData;
        } else if (responseData is Map) {
          // API returned error as object
          errorMessage =
              responseData['message'] ??
              responseData['error'] ??
              'Failed to submit parent request';
        }

        throw Exception(errorMessage);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Update Market Owner Info (for Google signup flow)
  Future<void> updateMarketOwnerInfo({
    required String marketName,
    required String marketAddress,
  }) async {
    try {
      await updateProfile({'marketName': marketName, 'address': marketAddress});
    } catch (e) {
      throw Exception('Failed to update market owner info: $e');
    }
  }
}
