import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// iOS-specific network utilities for handling ATS and connectivity issues
class IOSNetworkHelper {
  /// Check if error is retryable on iOS
  static bool isRetryableError(DioException error) {
    // DON'T retry connection errors - they won't resolve by retrying
    // This prevents long hangs on iOS
    if (error.type == DioExceptionType.connectionTimeout) return false;
    if (error.type == DioExceptionType.connectionError) return false;
    
    // DON'T retry socket exceptions - network issue won't resolve
    if (error.error is SocketException) {
      return false;
    }
    
    // Only retry on receive timeout (server slowness, not connection issue)
    if (error.type == DioExceptionType.receiveTimeout) return true;
    
    // Check HTTP error codes that warrant retry
    if (error.response?.statusCode != null) {
      final statusCode = error.response!.statusCode!;
      // Retry on 5xx errors (server issues)
      if (statusCode >= 500 && statusCode < 600) return true;
      // Retry on 408 (Request Timeout)
      if (statusCode == 408) return true;
      // Retry on 429 (Too Many Requests) - with backoff
      if (statusCode == 429) return true;
    }
    
    return false;
  }

  /// Calculate exponential backoff delay
  static Duration getRetryDelay(int attempt) {
    // Exponential backoff: min(2^attempt, 16) seconds
    final seconds = (2 << (attempt - 1)).toDouble();
    final cappedSeconds = seconds > 16 ? 16.0 : seconds;
    return Duration(milliseconds: (cappedSeconds * 1000).toInt());
  }

  /// Get user-friendly error message for iOS network errors
  static String getIOSErrorMessage(dynamic error) {
    if (error is! DioException) {
      return 'An unexpected error occurred';
    }

    // Check for iOS-specific NSURLError codes
    if (error.error is SocketException) {
      final socketError = error.error as SocketException;
      if (socketError.osError != null) {
        switch (socketError.osError!.errorCode) {
          case -1200: // NSURLErrorSecureConnectionFailed
            return 'Secure connection failed. The server may have an invalid SSL certificate.';
          case -1009: // NSURLErrorNotConnectedToInternet
            return 'No internet connection. Please check your network settings.';
          case -1001: // NSURLErrorTimedOut
            return 'Connection timed out. Please try again.';
          case -1004: // NSURLErrorCannotConnectToHost
            return 'Cannot connect to server. Please check your internet connection.';
          case -1005: // NSURLErrorNetworkConnectionLost
            return 'Network connection lost. Please try again.';
        }
      }
    }

    // Standard Dio error handling
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timed out. Please check your internet connection and try again.';
      case DioExceptionType.sendTimeout:
        return 'Request timed out while sending data. Please try again.';
      case DioExceptionType.receiveTimeout:
        return 'Server is taking too long to respond. Please try again.';
      case DioExceptionType.badCertificate:
        return 'SSL certificate error. Please contact support.';
      case DioExceptionType.connectionError:
        return 'Unable to connect to server. Please check your internet connection.';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      default:
        if (error.response != null) {
          final responseData = error.response?.data;
          if (responseData is String && responseData.isNotEmpty) {
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

  /// Enhanced retry logic for iOS
  static Future<T> retryRequest<T>({
    required Future<T> Function() request,
    int maxRetries = 3,
    bool Function(dynamic error)? shouldRetry,
  }) async {
    int attempt = 0;
    dynamic lastError;

    while (attempt < maxRetries) {
      try {
        return await request();
      } catch (e) {
        lastError = e;
        attempt++;

        // Check if we should retry
        bool retry = false;
        if (shouldRetry != null) {
          retry = shouldRetry(e);
        } else if (e is DioException) {
          retry = isRetryableError(e);
        }

        if (!retry || attempt >= maxRetries) {
          rethrow;
        }

        // Calculate delay before retry
        final delay = getRetryDelay(attempt);
        debugPrint('🔄 [IOSNetworkHelper] Retry attempt $attempt/$maxRetries after ${delay.inSeconds}s');
        await Future.delayed(delay);
      }
    }

    throw lastError;
  }

  /// Debug network configuration
  static void logNetworkConfig() {
    debugPrint('📱 [IOSNetworkHelper] iOS Network Configuration:');
    debugPrint('   Platform: ${Platform.operatingSystem}');
    debugPrint('   Version: ${Platform.operatingSystemVersion}');
    debugPrint('   Locale: ${Platform.localeName}');
  }
}
