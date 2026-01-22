import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Configure Dio with iOS-specific HTTP client settings
class DioIOSAdapter {
  static void configureDio(Dio dio) {
    if (!Platform.isIOS) return;

    debugPrint('✅ [DioIOSAdapter] Using default Dio configuration for iOS');
    // Let Dio use default settings - Info.plist NSAllowsArbitraryLoads handles everything
  }
}
