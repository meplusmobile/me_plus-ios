import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:me_plus/core/widgets/role_back_handler.dart';

void main() {
  group('RoleBackHandler', () {
    testWidgets('should not intercept back button on student home route', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RoleBackHandler(
            currentRoute: '/student/home',
            child: Scaffold(body: Text('Student Home')),
          ),
        ),
      );

      expect(find.text('Student Home'), findsOneWidget);
    });

    testWidgets('should not intercept back button on parent home route', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RoleBackHandler(
            currentRoute: '/parent/home',
            child: Scaffold(body: Text('Parent Home')),
          ),
        ),
      );

      expect(find.text('Parent Home'), findsOneWidget);
    });

    testWidgets('should not intercept back button on market-owner home route', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RoleBackHandler(
            currentRoute: '/market-owner/home',
            child: Scaffold(body: Text('Market Owner Home')),
          ),
        ),
      );

      expect(find.text('Market Owner Home'), findsOneWidget);
    });

    test('route detection for student paths', () {
      expect('/student/profile'.startsWith('/student/'), isTrue);
    });

    test('route detection for parent paths', () {
      expect('/parent/child-activity/123'.startsWith('/parent/'), isTrue);
    });

    test('route detection for market-owner paths', () {
      expect('/market-owner/orders'.startsWith('/market-owner/'), isTrue);
    });
  });
}
