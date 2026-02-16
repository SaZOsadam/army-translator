import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';
import '../config/bts_dictionary.dart';

enum TranslationProvider {
  papago,
  deepl,
  google,
}

class TranslationResult {
  final String originalText;
  final String translatedText;
  final String sourceLanguage;
  final String targetLanguage;
  final TranslationProvider provider;

  TranslationResult({
    required this.originalText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.provider,
  });
}

class TranslationService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  // Get preferred translation provider
  Future<TranslationProvider> getPreferredProvider() async {
    final prefs = await SharedPreferences.getInstance();
    final provider = prefs.getString(AppConstants.keyPreferredTranslator);
    
    switch (provider) {
      case 'deepl':
        return TranslationProvider.deepl;
      case 'google':
        return TranslationProvider.google;
      default:
        return TranslationProvider.papago;
    }
  }

  // Set preferred translation provider
  Future<void> setPreferredProvider(TranslationProvider provider) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyPreferredTranslator, provider.name);
  }

  // Main translate method - uses preferred provider
  Future<TranslationResult> translate(
    String text, {
    String from = 'ko',
    String to = 'en',
  }) async {
    // Pre-process with BTS dictionary
    final processedText = BTSDictionary.applyDictionary(text);
    
    final provider = await getPreferredProvider();
    
    try {
      switch (provider) {
        case TranslationProvider.papago:
          return await _translateWithPapago(processedText, from, to);
        case TranslationProvider.deepl:
          return await _translateWithDeepL(processedText, from, to);
        case TranslationProvider.google:
          return await _translateWithGoogle(processedText, from, to);
      }
    } catch (e) {
      debugPrint('Translation error with $provider: $e');
      // Fallback to another provider if available
      return await _fallbackTranslate(processedText, from, to, provider);
    }
  }

  // Papago Translation (Best for Korean)
  Future<TranslationResult> _translateWithPapago(
    String text,
    String from,
    String to,
  ) async {
    final clientId = await _secureStorage.read(key: AppConstants.keyPapagoClientId);
    final clientSecret = await _secureStorage.read(key: AppConstants.keyPapagoSecret);
    
    if (clientId == null || clientSecret == null) {
      throw Exception('Papago API credentials not configured');
    }

    final response = await http.post(
      Uri.parse(AppConstants.papagoApiUrl),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
        'X-Naver-Client-Id': clientId,
        'X-Naver-Client-Secret': clientSecret,
      },
      body: {
        'source': from,
        'target': to,
        'text': text,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return TranslationResult(
        originalText: text,
        translatedText: data['message']['result']['translatedText'],
        sourceLanguage: from,
        targetLanguage: to,
        provider: TranslationProvider.papago,
      );
    } else {
      throw Exception('Papago translation failed: ${response.statusCode}');
    }
  }

  // DeepL Translation
  Future<TranslationResult> _translateWithDeepL(
    String text,
    String from,
    String to,
  ) async {
    final apiKey = await _secureStorage.read(key: AppConstants.keyDeepLKey);
    
    if (apiKey == null) {
      throw Exception('DeepL API key not configured');
    }

    // DeepL uses different language codes
    final sourceLang = from.toUpperCase();
    final targetLang = to.toUpperCase();

    final response = await http.post(
      Uri.parse(AppConstants.deeplApiUrl),
      headers: {
        'Authorization': 'DeepL-Auth-Key $apiKey',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'text': text,
        'source_lang': sourceLang,
        'target_lang': targetLang,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final translations = data['translations'] as List;
      
      return TranslationResult(
        originalText: text,
        translatedText: translations.isNotEmpty 
            ? translations[0]['text'] 
            : text,
        sourceLanguage: from,
        targetLanguage: to,
        provider: TranslationProvider.deepl,
      );
    } else {
      throw Exception('DeepL translation failed: ${response.statusCode}');
    }
  }

  // Google Translate (fallback)
  Future<TranslationResult> _translateWithGoogle(
    String text,
    String from,
    String to,
  ) async {
    // Using free Google Translate API endpoint
    final url = Uri.parse(
      'https://translate.googleapis.com/translate_a/single'
      '?client=gtx&sl=$from&tl=$to&dt=t&q=${Uri.encodeComponent(text)}',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final translations = data[0] as List;
      final translatedText = translations.map((t) => t[0]).join('');
      
      return TranslationResult(
        originalText: text,
        translatedText: translatedText,
        sourceLanguage: from,
        targetLanguage: to,
        provider: TranslationProvider.google,
      );
    } else {
      throw Exception('Google translation failed: ${response.statusCode}');
    }
  }

  // Fallback translation
  Future<TranslationResult> _fallbackTranslate(
    String text,
    String from,
    String to,
    TranslationProvider failedProvider,
  ) async {
    // Try providers in order, skipping the one that failed
    final providers = [
      TranslationProvider.papago,
      TranslationProvider.google,
      TranslationProvider.deepl,
    ].where((p) => p != failedProvider);

    for (final provider in providers) {
      try {
        switch (provider) {
          case TranslationProvider.papago:
            return await _translateWithPapago(text, from, to);
          case TranslationProvider.deepl:
            return await _translateWithDeepL(text, from, to);
          case TranslationProvider.google:
            return await _translateWithGoogle(text, from, to);
        }
      } catch (e) {
        debugPrint('Fallback translation with $provider failed: $e');
        continue;
      }
    }

    // Return original text if all providers fail
    return TranslationResult(
      originalText: text,
      translatedText: text,
      sourceLanguage: from,
      targetLanguage: to,
      provider: failedProvider,
    );
  }

  // Store Papago credentials
  Future<void> setPapagoCredentials(String clientId, String secret) async {
    await _secureStorage.write(key: AppConstants.keyPapagoClientId, value: clientId);
    await _secureStorage.write(key: AppConstants.keyPapagoSecret, value: secret);
  }

  // Store DeepL API key
  Future<void> setDeepLKey(String apiKey) async {
    await _secureStorage.write(key: AppConstants.keyDeepLKey, value: apiKey);
  }

  // Check if credentials are configured
  Future<bool> hasCredentials(TranslationProvider provider) async {
    switch (provider) {
      case TranslationProvider.papago:
        final clientId = await _secureStorage.read(key: AppConstants.keyPapagoClientId);
        final secret = await _secureStorage.read(key: AppConstants.keyPapagoSecret);
        return clientId != null && secret != null;
      case TranslationProvider.deepl:
        final key = await _secureStorage.read(key: AppConstants.keyDeepLKey);
        return key != null;
      case TranslationProvider.google:
        return true; // Google free API doesn't need credentials
    }
  }
}
