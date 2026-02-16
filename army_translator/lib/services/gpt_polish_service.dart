import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/constants.dart';

class GptPolishService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Get API key
  Future<String?> getApiKey() async {
    return await _secureStorage.read(key: AppConstants.keyOpenAIKey);
  }

  // Polish translation to sound more natural
  Future<String> polishTranslation({
    required String originalKorean,
    required String roughTranslation,
    String? speakerName,
  }) async {
    final apiKey = await getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      return roughTranslation;
    }

    try {
      final systemPrompt = _buildSystemPrompt();
      final userPrompt = _buildUserPrompt(
        originalKorean,
        roughTranslation,
        speakerName,
      );

      final response = await http.post(
        Uri.parse(AppConstants.gptApiUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userPrompt},
          ],
          'max_tokens': 200,
          'temperature': 0.3,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final polished = data['choices'][0]['message']['content'];
        return polished.trim();
      } else {
        debugPrint('GPT polish failed: ${response.statusCode}');
        return roughTranslation;
      }
    } catch (e) {
      debugPrint('GPT polish error: $e');
      return roughTranslation;
    }
  }

  String _buildSystemPrompt() {
    return '''You are a BTS translation specialist helping ARMY understand Korean dialogue.

Your role:
- Polish rough translations to sound natural in English
- Keep BTS/K-pop terms (hyung, maknae, ARMY, etc.) as-is
- Preserve the speaker's personality and tone
- Keep it conversational and friendly
- Keep "borahae" as "I purple you 💜"
- Keep member names as stage names (RM, Jin, SUGA, J-Hope, Jimin, V, Jungkook)

IMPORTANT: Only output the polished translation, nothing else.''';
  }

  String _buildUserPrompt(
    String original,
    String rough,
    String? speaker,
  ) {
    final speakerContext = speaker != null 
        ? '\nSpeaker: $speaker (BTS member)' 
        : '';
    
    return '''Polish this translation to sound natural:

Original Korean: $original
Rough Translation: $rough$speakerContext

Polished:''';
  }

  // Batch polish multiple translations
  Future<List<String>> polishBatch(
    List<Map<String, String>> translations,
  ) async {
    final results = <String>[];
    
    for (final t in translations) {
      final polished = await polishTranslation(
        originalKorean: t['original'] ?? '',
        roughTranslation: t['translation'] ?? '',
        speakerName: t['speaker'],
      );
      results.add(polished);
    }
    
    return results;
  }

  // Quick context fix for common issues
  String quickFix(String translation) {
    var fixed = translation;
    
    // Common fixes
    fixed = fixed.replaceAll('purple you', 'purple you 💜');
    fixed = fixed.replaceAll('fighting!', 'fighting! 💪');
    fixed = fixed.replaceAll('army', 'ARMY');
    fixed = fixed.replaceAll('bts', 'BTS');
    
    return fixed;
  }
}
