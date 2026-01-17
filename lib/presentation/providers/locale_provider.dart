import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider with ChangeNotifier {
  Locale _locale = const Locale('en');
  bool _isInitialized = false;

  Locale get locale => _locale;

  LocaleProvider();

  Future<void> loadSavedLocale() async {
    if (_isInitialized) return; // Prevent multiple calls
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString('language_code') ?? 'en';
      _locale = Locale(languageCode);
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      // If SharedPreferences fails, use default locale
      _locale = const Locale('en');
      _isInitialized = true;
    }
  }

  Future<void> setLocale(String languageCode) async {
    if (_locale.languageCode == languageCode) return;

    _locale = Locale(languageCode);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);
    await prefs.setString(
      'language',
      languageCode == 'ar' ? 'Arabic' : 'English',
    );

    notifyListeners();
  }

  bool get isArabic => _locale.languageCode == 'ar';
  bool get isEnglish => _locale.languageCode == 'en';
}
