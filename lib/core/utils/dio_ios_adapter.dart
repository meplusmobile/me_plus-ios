import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

/// Configure Dio with iOS-specific HTTP client settings
class DioIOSAdapter {
  static void configureDio(Dio dio) {
    if (!Platform.isIOS) return;

    // Create custom HTTP client for iOS with relaxed settings
    final httpClient = HttpClient()
      ..connectionTimeout = const Duration(seconds: 30)
      ..idleTimeout = const Duration(seconds: 60);

    // Configure SSL/TLS handling for iOS
    httpClient.badCertificateCallback = 
        (X509Certificate cert, String host, int port) {
      // In production, verify the certificate properly
      // For now, accept Azure certificates
      return host.contains('azurewebsites.net');
    };

    // Apply custom adapter to Dio
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        return httpClient;
      },
      validateCertificate: (cert, host, port) {
        // Accept Azure certificates
        if (host.contains('azurewebsites.net')) {
          return true;
        }
        return false;
      },
    );
  }
}
