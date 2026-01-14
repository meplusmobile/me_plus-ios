import 'package:flutter_test/flutter_test.dart';
import 'package:me_plus/presentation/providers/locale_provider.dart';

void main() {
  group('LocaleProvider Tests', () {
    late LocaleProvider localeProvider;

    setUp(() {
      localeProvider = LocaleProvider();
    });

    test('Initial locale should be English', () {
      expect(localeProvider.locale.languageCode, equals('en'));
      expect(localeProvider.isArabic, isFalse);
    });

    test('Should change locale to Arabic', () async {
      await localeProvider.setLocale('ar');

      expect(localeProvider.locale.languageCode, equals('ar'));
      expect(localeProvider.isArabic, isTrue);
    });

    test('Should change locale to English', () async {
      // First set to Arabic
      await localeProvider.setLocale('ar');
      expect(localeProvider.isArabic, isTrue);

      // Then change back to English
      await localeProvider.setLocale('en');
      expect(localeProvider.isArabic, isFalse);
      expect(localeProvider.isEnglish, isTrue);
    });
  });
}
