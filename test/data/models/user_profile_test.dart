import 'package:flutter_test/flutter_test.dart';
import 'package:me_plus/data/models/user_profile.dart';

void main() {
  group('UserProfile Tests', () {
    test('UserProfile should create from JSON', () {
      final json = {
        'id': '1',
        'firstName': 'Test',
        'lastName': 'User',
        'email': 'test@example.com',
        'phoneNumber': '+1234567890',
        'role': 'Student',
        'birthDate': '1990-01-01',
      };

      final profile = UserProfile.fromJson(json);

      expect(profile.id, equals('1'));
      expect(profile.firstName, equals('Test'));
      expect(profile.lastName, equals('User'));
      expect(profile.email, equals('test@example.com'));
      expect(profile.role, equals('Student'));
    });

    test('UserProfile should convert to JSON', () {
      final profile = UserProfile(
        id: '1',
        firstName: 'Test',
        lastName: 'User',
        email: 'test@example.com',
        phoneNumber: '+1234567890',
        role: 'Student',
        birthdate: '1990-01-01',
      );

      final json = profile.toJson();

      expect(json['id'], equals('1'));
      expect(json['firstName'], equals('Test'));
      expect(json['lastName'], equals('User'));
      expect(json['email'], equals('test@example.com'));
    });
  });
}
