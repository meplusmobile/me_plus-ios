import 'package:flutter_test/flutter_test.dart';
import 'package:me_plus/data/services/auth_service.dart';
import 'package:me_plus/data/models/login_request.dart';
import 'package:me_plus/data/models/signup_request.dart';

void main() {
  group('AuthService Tests', () {
    late AuthService authService;

    setUp(() {
      authService = AuthService();
    });

    test('AuthService instance should be created', () {
      expect(authService, isNotNull);
    });

    test('LoginRequest should create valid object', () {
      final request = LoginRequest(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(request.email, equals('test@example.com'));
      expect(request.password, equals('password123'));
    });

    test('SignupRequest should create valid object', () {
      final request = SignupRequest(
        firstName: 'Test',
        lastName: 'User',
        email: 'test@example.com',
        phoneNumber: '+1234567890',
        birthdate: '1990-01-01',
        password: 'password123',
        role: 'Student',
      );

      expect(request.firstName, equals('Test'));
      expect(request.lastName, equals('User'));
      expect(request.email, equals('test@example.com'));
      expect(request.role, equals('Student'));
    });
  });
}
