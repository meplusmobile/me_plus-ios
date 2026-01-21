import 'package:dio/dio.dart';
import 'package:me_plus/data/services/token_storage_service.dart';

class ApiService {
  static const String baseUrl =
      'https://meplus3-hjfehnfpfyg2gyau.israelcentral-01.azurewebsites.net';

  late final Dio _dio;
  late final TokenStorageService _tokenStorage;

  ApiService() {
    _tokenStorage = TokenStorageService();
    
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 90), // Increased for iOS
        receiveTimeout: const Duration(seconds: 90),
        sendTimeout: const Duration(seconds: 90),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': 'MePlus/1.0.0',
        },
        validateStatus: (status) {
          // Accept all status codes to handle them manually
          return status != null && status < 500;
        },
      ),
    );

    // Add logging interceptor for debugging
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        requestHeader: true,
        responseHeader: false,
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add token to requests
          final token = await _tokenStorage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          // Handle connection errors
          if (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.receiveTimeout ||
              error.type == DioExceptionType.sendTimeout) {
            return handler.next(
              DioException(
                requestOptions: error.requestOptions,
                error: 'Connection timeout. Please check your internet connection.',
                type: error.type,
              ),
            );
          }

          if (error.type == DioExceptionType.connectionError) {
            return handler.next(
              DioException(
                requestOptions: error.requestOptions,
                error: 'No internet connection. Please check your network settings.',
                type: error.type,
              ),
            );
          }

          if (error.response?.statusCode == 401) {
            // Token expired, try to refresh
            final refreshToken = await _tokenStorage.getRefreshToken();
            final userId = await _tokenStorage.getUserId();

            if (refreshToken != null && userId != null) {
              try {
                // Try to refresh the token
                final response = await _dio.post(
                  '/refresh-token',
                  data: {'userId': userId, 'refreshToken': refreshToken},
                  options: Options(
                    headers: {'Content-Type': 'application/json'},
                  ),
                );

                if (response.statusCode == 200) {
                  // Save new tokens
                  await _tokenStorage.saveAuthData(
                    token: response.data['token'],
                    refreshToken: response.data['refreshToken'],
                    userId: response.data['id'].toString(),
                    email: response.data['email'],
                    role: response.data['role'],
                    isFirstTimeUser: response.data['isFirstTimeUser'] ?? false,
                  );

                  // Retry the original request with new token
                  error.requestOptions.headers['Authorization'] =
                      'Bearer ${response.data['token']}';
                  final retryResponse = await _dio.fetch(error.requestOptions);
                  return handler.resolve(retryResponse);
                }
              } catch (e) {
                // Refresh failed, clear auth data
                await _tokenStorage.clearAuthData();
              }
            } else {
              // No refresh token, clear auth data
              await _tokenStorage.clearAuthData();
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;

  // GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool isFormData = false,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: isFormData
            ? Options(headers: {'Content-Type': 'multipart/form-data'})
            : null,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PATCH request
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE request
  Future<Response> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.delete(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException error) {
    String errorMsg = '';
    
    // Log detailed error info for iOS debugging
    print('🔴 DioException Type: ${error.type}');
    print('🔴 Message: ${error.message}');
    print('🔴 Status Code: ${error.response?.statusCode}');
    print('🔴 Response Data: ${error.response?.data}');
    
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        errorMsg = 'Connection timeout - server not responding. Check your network.';
        break;
      case DioExceptionType.sendTimeout:
        errorMsg = 'Request timeout - taking too long to send.';
        break;
      case DioExceptionType.receiveTimeout:
        errorMsg = 'Server timeout - not responding in time.';
        break;
      case DioExceptionType.badResponse:
        final data = error.response?.data;
        if (data is Map<String, dynamic>) {
          errorMsg = data['message'] ?? data['error'] ?? 'Server error occurred';
        } else if (data is String) {
          errorMsg = data;
        } else {
          errorMsg = 'Server error (${error.response?.statusCode})';
        }
        break;
      case DioExceptionType.cancel:
        errorMsg = 'Request cancelled';
        break;
      case DioExceptionType.connectionError:
        errorMsg = 'Connection failed - check internet and SSL certificates';
        break;
      case DioExceptionType.unknown:
        errorMsg = 'Unknown network error: ${error.message}';
        break;
      default:
        errorMsg = 'Network error. Please check your connection.';
    }
    
    return errorMsg;
  }
}
