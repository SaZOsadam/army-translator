import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/constants.dart';

class SpeechToTextResult {
  final String text;
  final double confidence;
  final String language;
  final int durationMs;

  SpeechToTextResult({
    required this.text,
    required this.confidence,
    required this.language,
    required this.durationMs,
  });
}

class SpeechToTextService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  // Get stored API key
  Future<String?> getApiKey() async {
    return await _secureStorage.read(key: AppConstants.keyOpenAIKey);
  }

  // Store API key securely
  Future<void> setApiKey(String apiKey) async {
    await _secureStorage.write(key: AppConstants.keyOpenAIKey, value: apiKey);
  }

  // Check if API key is configured
  Future<bool> hasApiKey() async {
    final key = await getApiKey();
    return key != null && key.isNotEmpty;
  }

  // Transcribe audio using OpenAI Whisper
  Future<SpeechToTextResult> transcribe(Uint8List audioData) async {
    final apiKey = await getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('OpenAI API key not configured');
    }

    try {
      final uri = Uri.parse(AppConstants.whisperApiUrl);
      
      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $apiKey';
      
      // Add audio file
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          audioData,
          filename: 'audio.wav',
        ),
      );
      
      // Add parameters
      request.fields['model'] = 'whisper-1';
      request.fields['language'] = 'ko'; // Korean
      request.fields['response_format'] = 'verbose_json';
      request.fields['prompt'] = 'BTS Weverse live, casual Korean conversation with ARMY';

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        return SpeechToTextResult(
          text: data['text'] ?? '',
          confidence: _extractConfidence(data),
          language: data['language'] ?? 'ko',
          durationMs: ((data['duration'] ?? 0) * 1000).toInt(),
        );
      } else {
        debugPrint('Whisper API error: ${response.statusCode} - ${response.body}');
        throw Exception('Transcription failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Transcription error: $e');
      rethrow;
    }
  }

  // Extract confidence from segments
  double _extractConfidence(Map<String, dynamic> data) {
    try {
      final segments = data['segments'] as List?;
      if (segments == null || segments.isEmpty) return 0.9;

      double totalConfidence = 0;
      for (final segment in segments) {
        totalConfidence += (segment['no_speech_prob'] != null 
            ? 1 - segment['no_speech_prob'] 
            : 0.9);
      }
      return totalConfidence / segments.length;
    } catch (e) {
      return 0.9;
    }
  }

  // Transcribe with retry logic
  Future<SpeechToTextResult> transcribeWithRetry(
    Uint8List audioData, {
    int maxRetries = 3,
  }) async {
    Exception? lastError;
    
    for (var i = 0; i < maxRetries; i++) {
      try {
        return await transcribe(audioData);
      } catch (e) {
        lastError = e is Exception ? e : Exception(e.toString());
        debugPrint('Transcription attempt ${i + 1} failed: $e');
        
        if (i < maxRetries - 1) {
          await Future.delayed(Duration(seconds: i + 1));
        }
      }
    }
    
    throw lastError ?? Exception('Transcription failed after $maxRetries attempts');
  }
}
