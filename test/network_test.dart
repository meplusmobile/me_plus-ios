import 'dart:io';
import 'package:dio/dio.dart';

/// Simple network test for iOS debugging
Future<void> testIOSConnection() async {
  print('🧪 Testing iOS Network Connection...\n');
  
  final dio = Dio();
  dio.options.connectTimeout = const Duration(seconds: 10);
  dio.options.receiveTimeout = const Duration(seconds: 10);
  
  const testUrl = 'https://meplus3-hjfehnfpfyg2gyau.israelcentral-01.azurewebsites.net';
  
  try {
    print('📡 Attempting to connect to: $testUrl');
    print('Platform: ${Platform.operatingSystem}');
    print('iOS Version: ${Platform.operatingSystemVersion}\n');
    
    // Test 1: HEAD request
    print('Test 1: HEAD request...');
    final headResponse = await dio.head(testUrl);
    print('✅ HEAD Success: ${headResponse.statusCode}\n');
    
    // Test 2: GET request
    print('Test 2: GET request...');
    final getResponse = await dio.get(testUrl);
    print('✅ GET Success: ${getResponse.statusCode}\n');
    
    // Test 3: POST to login
    print('Test 3: POST to /login...');
    try {
      final loginResponse = await dio.post(
        '$testUrl/login',
        data: {'email': 'test', 'password': 'test'},
      );
      print('✅ POST Success: ${loginResponse.statusCode}');
      print('Response: ${loginResponse.data}\n');
    } catch (e) {
      if (e is DioException && e.response != null) {
        print('✅ POST reached server (${e.response!.statusCode})');
        print('This is expected - invalid credentials\n');
      } else {
        rethrow;
      }
    }
    
    print('✅ All tests passed! Network is working correctly.');
    
  } on DioException catch (e) {
    print('❌ Network Error:');
    print('   Type: ${e.type}');
    print('   Message: ${e.message}');
    print('   Error: ${e.error}');
    if (e.response != null) {
      print('   Status: ${e.response!.statusCode}');
      print('   Data: ${e.response!.data}');
    }
    
    print('\n💡 Troubleshooting:');
    if (e.type == DioExceptionType.connectionTimeout) {
      print('   - Check internet connection');
      print('   - Server might be slow');
    } else if (e.type == DioExceptionType.connectionError) {
      print('   - Check ATS settings in Info.plist');
      print('   - Verify SSL certificate');
    } else if (e.type == DioExceptionType.badCertificate) {
      print('   - SSL certificate issue');
      print('   - May need to add exception in Info.plist');
    }
  } catch (e) {
    print('❌ Unexpected Error: $e');
  }
}

void main() async {
  await testIOSConnection();
}
