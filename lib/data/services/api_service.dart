import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:me_plus/data/services/token_storage_service.dart';

/// API Service using http package - Works 100% on iOS!
/// Same approach as the working login function
class ApiService {
  static const String baseUrl =
      'https://meplus3-hjfehnfpfyg2gyau.israelcentral-01.azurewebsites.net';

  final TokenStorageService _tokenStorage = TokenStorageService();
  final http.Client _client = http.Client();
  
  static const Duration _timeout = Duration(seconds: 15);

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

  /// Build full URL with query parameters
  Uri _buildUri(String path, {Map<String, dynamic>? queryParameters}) {
    final uri = Uri.parse('$baseUrl$path');
    if (queryParameters != null && queryParameters.isNotEmpty) {
      return uri.replace(
        queryParameters: queryParameters.map(
          (key, value) => MapEntry(key, value?.toString() ?? ''),
        ),
      );
    }
    return uri;
  }

  /// GET request
  Future<ApiResponse> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool withAuth = true,
  }) async {
    try {
      final uri = _buildUri(path, queryParameters: queryParameters);
      final headers = await _getHeaders(withAuth: withAuth);

      debugPrint('🌐 [GET] $uri');

      final response = await _client.get(uri, headers: headers).timeout(_timeout);

      debugPrint('✅ [GET] Status: ${response.statusCode}');

      return _handleResponse(response);
    } catch (e) {
      debugPrint('❌ [GET] Error: $e');
      return ApiResponse(
        success: false,
        statusCode: 0,
        error: _handleError(e),
      );
    }
  }

  /// POST request
  Future<ApiResponse> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool withAuth = true,
  }) async {
    try {
      final uri = _buildUri(path, queryParameters: queryParameters);
      final headers = await _getHeaders(withAuth: withAuth);

      debugPrint('🌐 [POST] $uri');

      final body = data != null ? jsonEncode(data) : null;
      final response = await _client.post(uri, headers: headers, body: body).timeout(_timeout);

      debugPrint('✅ [POST] Status: ${response.statusCode}');

      return _handleResponse(response);
    } catch (e) {
      debugPrint('❌ [POST] Error: $e');
      return ApiResponse(
        success: false,
        statusCode: 0,
        error: _handleError(e),
      );
    }
  }

  /// PUT request
  Future<ApiResponse> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool withAuth = true,
  }) async {
    try {
      final uri = _buildUri(path, queryParameters: queryParameters);
      final headers = await _getHeaders(withAuth: withAuth);

      debugPrint('🌐 [PUT] $uri');

      final body = data != null ? jsonEncode(data) : null;
      final response = await _client.put(uri, headers: headers, body: body).timeout(_timeout);

      debugPrint('✅ [PUT] Status: ${response.statusCode}');

      return _handleResponse(response);
    } catch (e) {
      debugPrint('❌ [PUT] Error: $e');
      return ApiResponse(
        success: false,
        statusCode: 0,
        error: _handleError(e),
      );
    }
  }

  /// PATCH request
  Future<ApiResponse> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool withAuth = true,
  }) async {
    try {
      final uri = _buildUri(path, queryParameters: queryParameters);
      final headers = await _getHeaders(withAuth: withAuth);

      debugPrint('🌐 [PATCH] $uri');

      final body = data != null ? jsonEncode(data) : null;
      final response = await _client.patch(uri, headers: headers, body: body).timeout(_timeout);

      debugPrint('✅ [PATCH] Status: ${response.statusCode}');

      return _handleResponse(response);
    } catch (e) {
      debugPrint('❌ [PATCH] Error: $e');
      return ApiResponse(
        success: false,
        statusCode: 0,
        error: _handleError(e),
      );
    }
  }

  /// DELETE request
  Future<ApiResponse> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool withAuth = true,
  }) async {
    try {
      final uri = _buildUri(path, queryParameters: queryParameters);
      final headers = await _getHeaders(withAuth: withAuth);

      debugPrint('🌐 [DELETE] $uri');

      final response = await _client.delete(uri, headers: headers).timeout(_timeout);

      debugPrint('✅ [DELETE] Status: ${response.statusCode}');

      return _handleResponse(response);
    } catch (e) {
      debugPrint('❌ [DELETE] Error: $e');
      return ApiResponse(
        success: false,
        statusCode: 0,
        error: _handleError(e),
      );
    }
  }

  /// Handle HTTP response
  ApiResponse _handleResponse(http.Response response) {
    dynamic data;
    
    try {
      if (response.body.isNotEmpty) {
        data = jsonDecode(response.body);
      }
    } catch (e) {
      // Body is not JSON, use raw string
      data = response.body;
    }

    final success = response.statusCode >= 200 && response.statusCode < 300;

    if (!success) {
      String error = 'Request failed';
      if (data is Map<String, dynamic>) {
        error = data['message'] ?? data['error'] ?? 'Server error';
      } else if (data is String && data.isNotEmpty) {
        error = data;
      }
      
      return ApiResponse(
        success: false,
        statusCode: response.statusCode,
        data: data,
        error: error,
      );
    }

    return ApiResponse(
      success: true,
      statusCode: response.statusCode,
      data: data,
    );
  }

  /// Handle errors
  String _handleError(dynamic error) {
    if (error.toString().contains('TimeoutException')) {
      return 'Connection timeout. Please check your internet.';
    }
    if (error.toString().contains('SocketException')) {
      return 'No internet connection.';
    }
    if (error.toString().contains('HandshakeException')) {
      return 'SSL certificate error.';
    }
    return 'Network error: ${error.toString()}';
  }

  /// Close the client when done
  void dispose() {
    _client.close();
  }
}

/// API Response wrapper
class ApiResponse {
  final bool success;
  final int statusCode;
  final dynamic data;
  final String? error;

  ApiResponse({
    required this.success,
    required this.statusCode,
    this.data,
    this.error,
  });

  /// Check if response has data
  bool get hasData => data != null;

  /// Get data as Map
  Map<String, dynamic>? get dataAsMap {
    if (data is Map<String, dynamic>) {
      return data as Map<String, dynamic>;
    }
    return null;
  }

  /// Get data as List
  List<dynamic>? get dataAsList {
    if (data is List) {
      return data as List<dynamic>;
    }
    return null;
  }
}
