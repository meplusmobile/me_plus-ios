import 'dart:async';
import 'package:dio/dio.dart';

class NetworkHelper {
  static Future<bool> checkConnectivity(String url) async {
    try {
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 5);
      dio.options.receiveTimeout = const Duration(seconds: 5);
      
      final response = await dio.head(url);
      return response.statusCode != null && response.statusCode! < 500;
    } catch (e) {
      print('❌ [NetworkHelper] Connectivity check failed: $e');
      return false;
    }
  }

  static Future<T> retryRequest<T>({
    required Future<T> Function() request,
    int maxRetries = 3,
    Duration delayBetweenRetries = const Duration(seconds: 2),
  }) async {
    int attempts = 0;
    
    while (attempts < maxRetries) {
      try {
        return await request();
      } catch (e) {
        attempts++;
        
        if (attempts >= maxRetries) {
          rethrow;
        }
        
        print('🔄 [NetworkHelper] Retry attempt $attempts/$maxRetries after error: $e');
        await Future.delayed(delayBetweenRetries);
      }
    }
    
    throw Exception('Max retries reached');
  }

  static String getReadableError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return 'Connection timed out. Please check your internet connection.';
        case DioExceptionType.receiveTimeout:
          return 'Server is taking too long to respond. Please try again.';
        case DioExceptionType.sendTimeout:
          return 'Request timed out. Please check your connection.';
        case DioExceptionType.connectionError:
          return 'Unable to connect to server. Please check your internet connection.';
        case DioExceptionType.badCertificate:
          return 'Security certificate error. Please contact support.';
        case DioExceptionType.unknown:
          return 'Unable to connect to server. Please check your internet connection and try again.';
        default:
          if (error.response != null) {
            final responseData = error.response?.data;
            if (responseData is String) {
              return responseData;
            } else if (responseData is Map) {
              return responseData['message'] ?? 
                     responseData['error'] ?? 
                     'Request failed';
            }
          }
          return 'Network error occurred. Please try again.';
      }
    }
    
    return error.toString();
  }
}
