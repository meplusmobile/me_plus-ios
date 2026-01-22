import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';

/// Configure Dio with iOS-specific HTTP client settings
class DioIOSAdapter {
  static void configureDio(Dio dio) {
    if (!Platform.isIOS) return;

    // Create custom HTTP client for iOS with proper settings
    final httpClient = HttpClient()
      ..connectionTimeout = const Duration(seconds: 30)
      ..idleTimeout = const Duration(seconds: 90)
      ..maxConnectionsPerHost = 10;

    // IMPORTANT: Let iOS handle SSL/TLS validation properly
    // Don't override badCertificateCallback - use system validation
    debugPrint('✅ [DioIOSAdapter] Configured with system SSL validation');

    // Apply custom adapter to Dio
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        return httpClient;
      },
    );
  }
}
