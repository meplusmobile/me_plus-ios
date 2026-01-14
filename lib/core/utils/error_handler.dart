import 'package:flutter/material.dart';

/// Global error handler for the application
class ErrorHandler {
  /// Handle errors and show user-friendly messages
  static void handleError(
    BuildContext context,
    dynamic error, {
    String? customMessage,
    bool showSnackBar = true,
  }) {
    debugPrint('Error occurred: $error');

    if (!showSnackBar) return;

    final message = customMessage ?? _getErrorMessage(error);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Get user-friendly error message based on error type
  static String _getErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('network') ||
        errorString.contains('socket') ||
        errorString.contains('connection')) {
      return 'Network error. Please check your internet connection.';
    } else if (errorString.contains('timeout')) {
      return 'Request timed out. Please try again.';
    } else if (errorString.contains('format')) {
      return 'Invalid data format received.';
    } else if (errorString.contains('permission')) {
      return 'Permission denied. Please check app permissions.';
    } else if (errorString.contains('unauthorized') ||
        errorString.contains('401')) {
      return 'Session expired. Please login again.';
    } else if (errorString.contains('404')) {
      return 'Resource not found.';
    } else if (errorString.contains('500') || errorString.contains('server')) {
      return 'Server error. Please try again later.';
    } else {
      return 'An error occurred. Please try again.';
    }
  }

  /// Wrap async functions with error handling
  static Future<T?> tryCatch<T>(
    Future<T> Function() function, {
    void Function(dynamic error)? onError,
    T? defaultValue,
  }) async {
    try {
      return await function();
    } catch (e) {
      debugPrint('Error in tryCatch: $e');
      if (onError != null) {
        onError(e);
      }
      return defaultValue;
    }
  }

  /// Wrap synchronous functions with error handling
  static T? tryCatchSync<T>(
    T Function() function, {
    void Function(dynamic error)? onError,
    T? defaultValue,
  }) {
    try {
      return function();
    } catch (e) {
      debugPrint('Error in tryCatchSync: $e');
      if (onError != null) {
        onError(e);
      }
      return defaultValue;
    }
  }
}
