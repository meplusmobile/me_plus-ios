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
      // Add delay for iOS to ensure SharedPreferences is ready
      await Future.delayed(const Duration(milliseconds: 100));
      
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString('language_code') ?? 'en';
      _locale = Locale(languageCode);
      _isInitialized = true;
      
      print('✅ [LocaleProvider] Loaded locale: $languageCode');
      notifyListeners();
    } catch (e) {
      print('❌ [LocaleProvider] Failed to load locale: $e');
      // If SharedPreferences fails, use default locale
      _locale = const Locale('en');
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> setLocale(String languageCode) async {
    print('🌐 [LocaleProvider] Setting locale to: $languageCode');
    
    if (_locale.languageCode == languageCode) {
      print('⚠️ [LocaleProvider] Locale already set to: $languageCode');
      return;
    }

    try {
      // Update locale immediately for UI
      _locale = Locale(languageCode);
      notifyListeners();

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language_code', languageCode);
      await prefs.setString(
        'language',
        languageCode == 'ar' ? 'Arabic' : 'English',
      );
      
      // Force commit on iOS
      await prefs.reload();
      
      print('✅ [LocaleProvider] Locale changed to: $languageCode');
      
      // Notify listeners again to ensure UI updates
      notifyListeners();
    } catch (e) {
      print('❌ [LocaleProvider] Failed to save locale: $e');
      // Revert locale change if save failed
      _locale = Locale(languageCode == 'ar' ? 'en' : 'ar');
      notifyListeners();
    }
  }

  bool get isArabic => _locale.languageCode == 'ar';
  bool get isEnglish => _locale.languageCode == 'en';
}
