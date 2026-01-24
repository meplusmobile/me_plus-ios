import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:me_plus/core/localization/app_localizations.dart';

void main() {
  group('AppLocalizations Tests', () {
    test('English translations should load', () {
      final localizations = AppLocalizations(const Locale('en'));

      expect(localizations.t('welcome'), isNotEmpty);
      expect(localizations.t('login'), isNotEmpty);
      expect(localizations.t('signup'), isNotEmpty);
    });

    test('Arabic translations should load', () {
      final localizations = AppLocalizations(const Locale('ar'));

      expect(localizations.t('welcome'), isNotEmpty);
      expect(localizations.t('login'), isNotEmpty);
      expect(localizations.t('signup'), isNotEmpty);
    });

    test('Unknown keys should return the key itself', () {
      final localizations = AppLocalizations(const Locale('en'));

      expect(localizations.t('unknown_key'), equals('unknown_key'));
    });

    test('Locale should be set correctly', () {
      final enLocalization = AppLocalizations(const Locale('en'));
      final arLocalization = AppLocalizations(const Locale('ar'));

      expect(enLocalization.locale.languageCode, equals('en'));
      expect(arLocalization.locale.languageCode, equals('ar'));
    });
  });
}
