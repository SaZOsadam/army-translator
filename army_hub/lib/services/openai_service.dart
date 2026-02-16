import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/constants.dart';

class OpenAIService {
  static const String _apiUrl = '${AppConstants.openAIBaseUrl}${AppConstants.openAIChatEndpoint}';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  Future<String?> _getApiKey() async {
    return await _secureStorage.read(key: AppConstants.keyOpenAIKey);
  }
  
  Future<void> setApiKey(String apiKey) async {
    await _secureStorage.write(key: AppConstants.keyOpenAIKey, value: apiKey);
  }
  
  Future<bool> hasApiKey() async {
    final key = await _getApiKey();
    return key != null && key.isNotEmpty;
  }

  String _buildSystemPrompt(String bias) {
    return '''
You are an enthusiastic BTS ARMY theorist helping fans decode teasers and predict details about the ARIRANG comeback (March 20, 2026).

Guidelines:
- Use ARMY slang naturally (bias, maknae, hyung line, vocal line, rap line, stan, etc.)
- Reference BTS history, past albums, MVs, and member dynamics
- Keep tone excited, supportive, and fun - like a passionate fan on Twitter
- Include relevant emojis throughout your response 💜🔮✨🎵
- ${bias != 'OT7' ? 'Focus predictions on $bias while still acknowledging group dynamics' : 'Include all members equally in your predictions'}
- Be creative but grounded in actual BTS patterns and lore
- Reference the BTS Universe (BU) when relevant
- Make bold but fun predictions
- Use phrases like "OMG ARMY", "I'm not crying you're crying", "the way this makes sense", etc.
- Keep responses engaging and shareable

Your response should include:
1. Main theory (2-3 exciting paragraphs)
2. Supporting evidence from past BTS content
3. A bold prediction for the album
4. A fun "conspiracy bonus" theory
''';
  }

  Future<String> generateTheory({
    required String userInput,
    required String bias,
  }) async {
    final apiKey = await _getApiKey();
    
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('OpenAI API key not configured. Please add your API key in Settings.');
    }

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o',
          'messages': [
            {
              'role': 'system',
              'content': _buildSystemPrompt(bias),
            },
            {
              'role': 'user',
              'content': '''
Based on this teaser/symbol/lyric description, generate an exciting ARMY-style theory:

"$userInput"

Bias focus: $bias

Remember to be enthusiastic, reference BTS history, and make it shareable! 💜
''',
            },
          ],
          'max_tokens': 1000,
          'temperature': 0.8,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;
        return content.trim();
      } else if (response.statusCode == 401) {
        throw Exception('Invalid API key. Please check your OpenAI API key in Settings.');
      } else if (response.statusCode == 429) {
        throw Exception('Rate limit exceeded. Please try again in a moment.');
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error']['message'] ?? 'Failed to generate theory');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error. Please check your connection and try again.');
    }
  }

  Future<String> generateDailyMessage({
    required String bias,
    required int daysUntilRelease,
  }) async {
    final apiKey = await _getApiKey();
    
    if (apiKey == null || apiKey.isEmpty) {
      return _getDefaultDailyMessage(bias, daysUntilRelease);
    }

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o',
          'messages': [
            {
              'role': 'system',
              'content': '''
You are a friendly BTS ARMY companion app. Generate a short, encouraging daily message for an ARMY fan waiting for the ARIRANG comeback.

Guidelines:
- Keep it brief (2-3 sentences max)
- Be warm and supportive
- Include 1-2 emojis
- Reference the countdown or comeback excitement
- If bias is specified, include a small mention of them
- Vary your greetings and messages
''',
            },
            {
              'role': 'user',
              'content': 'Generate a daily message. Bias: $bias. Days until ARIRANG: $daysUntilRelease',
            },
          ],
          'max_tokens': 150,
          'temperature': 0.9,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'].toString().trim();
      } else {
        return _getDefaultDailyMessage(bias, daysUntilRelease);
      }
    } catch (e) {
      return _getDefaultDailyMessage(bias, daysUntilRelease);
    }
  }

  String _getDefaultDailyMessage(String bias, int daysUntilRelease) {
    final messages = [
      'Hey ARMY! 💜 Only $daysUntilRelease days until ARIRANG drops! Keep streaming and stay strong!',
      'Good morning, ARMY! ✨ The countdown continues - $daysUntilRelease days to go! Who else can\'t wait?',
      'ARMY, we\'re getting closer! 🎵 $daysUntilRelease days until we feast on new music!',
      'Rise and shine! 💜 $daysUntilRelease days until BTS serves us ARIRANG excellence!',
    ];
    
    if (bias != 'OT7') {
      messages.add('Good day, $bias stan! 💜 Only $daysUntilRelease days until we see our bias shine in ARIRANG!');
    }
    
    return messages[DateTime.now().day % messages.length];
  }
}
