import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:me_plus/data/services/storage_service.dart';

class LocaleProvider with ChangeNotifier {
  Locale _locale = const Locale('en');
  bool _isInitialized = false;
  final _storage = StorageService();

  Locale get locale => _locale;

  LocaleProvider();

  Future<void> loadSavedLocale() async {
    if (_isInitialized) return; // Prevent multiple calls
    
    try {
      final languageCode = await _storage.getString('language_code') ?? 'en';
      _locale = Locale(languageCode);
      _isInitialized = true;
      
      debugPrint('✅ [LocaleProvider] Loaded locale: $languageCode');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ [LocaleProvider] Failed to load locale: $e');
      // If storage fails, use default locale
      _locale = const Locale('en');
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> setLocale(String languageCode) async {
    debugPrint('🌐 [LocaleProvider] Setting locale to: $languageCode');
    
    if (_locale.languageCode == languageCode) {
      debugPrint('⚠️ [LocaleProvider] Locale already set to: $languageCode');
      return;
    }

    try {
      // Update locale immediately for UI
      _locale = Locale(languageCode);
      notifyListeners();

      // Save to secure storage
      await _storage.saveString('language_code', languageCode);
      await _storage.saveString(
        'language',
        languageCode == 'ar' ? 'Arabic' : 'English',
      );
      
      debugPrint('✅ [LocaleProvider] Locale changed to: $languageCode');
      
      // Notify listeners again to ensure UI updates
      notifyListeners();
    } catch (e) {
      debugPrint('❌ [LocaleProvider] Failed to save locale: $e');
      // Revert locale change if save failed
      _locale = Locale(languageCode == 'ar' ? 'en' : 'ar');
      notifyListeners();
    }
  }

  bool get isArabic => _locale.languageCode == 'ar';
  bool get isEnglish => _locale.languageCode == 'en';
}
