import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

/// Translation Service using http package - Works 100% on iOS!
class TranslationService {
  static final TranslationService _instance = TranslationService._internal();
  factory TranslationService() => _instance;
  TranslationService._internal();

  final http.Client _client = http.Client();
  static const Duration _timeout = Duration(seconds: 10);

  // Cache to avoid translating the same text multiple times
  final Map<String, String> _translationCache = {};

  Future<String> translate(
    String text, {
    required String from,
    required String to,
  }) async {
    if (text.isEmpty) return text;

    final cacheKey = '$from-$to:$text';
    if (_translationCache.containsKey(cacheKey)) {
      return _translationCache[cacheKey]!;
    }

    try {
      // Use Google Translate unofficial API
      final encodedText = Uri.encodeComponent(text);
      final url =
          'https://translate.googleapis.com/translate_a/single?client=gtx&sl=$from&tl=$to&dt=t&q=$encodedText';

      final response = await _client.get(Uri.parse(url)).timeout(_timeout);

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        // Google Translate returns: [[["translated text","original text",null,null,3]],null,"en"]
        final data = jsonDecode(response.body);
        if (data is List && data.isNotEmpty) {
          final translations = data[0] as List;
          if (translations.isNotEmpty && translations[0] is List) {
            final translatedText = translations[0][0] as String?;
            if (translatedText != null && translatedText.isNotEmpty) {
              // Cache the translation
              _translationCache[cacheKey] = translatedText;
              return translatedText;
            }
          }
        }
      }
    } catch (e) {
      developer.log('Translation error: $e', name: 'TranslationService');
    }

    // Return original text if translation fails
    return text;
  }

  Future<String> translateToArabic(String text) async {
    if (text.isEmpty) return text;
    return await translate(text, from: 'en', to: 'ar');
  }

  Future<String> translateToEnglish(String text) async {
    if (text.isEmpty) return text;
    return await translate(text, from: 'ar', to: 'en');
  }

  bool _isArabic(String text) {
    if (text.isEmpty) return false;
    final arabicRegex = RegExp(r'[\u0600-\u06FF]');
    return arabicRegex.hasMatch(text);
  }

  String detectLanguage(String text) {
    return _isArabic(text) ? 'ar' : 'en';
  }

  void clearCache() {
    _translationCache.clear();
  }

  void dispose() {
    _client.close();
  }
}
