import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/session_model.dart';
import '../models/subtitle_model.dart';

class CacheService {
  static const String _sessionsKey = 'cached_sessions';
  static const String _settingsKey = 'app_settings';
  static const String _apiKeysKey = 'api_keys';
  static const String _dictionaryKey = 'bts_dictionary';
  static const int _maxCachedSessions = 50;

  static SharedPreferences? _prefs;

  /// Initialize shared preferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Get SharedPreferences instance
  static Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ============ SESSION CACHING ============

  /// Save session to local cache
  static Future<bool> saveSession(SessionModel session, List<SubtitleModel> subtitles) async {
    try {
      final p = await prefs;
      
      // Get existing sessions
      final sessions = await getCachedSessions();
      
      // Add new session
      final sessionData = {
        'session': session.toJson(),
        'subtitles': subtitles.map((s) => s.toJson()).toList(),
        'cachedAt': DateTime.now().toIso8601String(),
      };
      
      // Check if session already exists
      final existingIndex = sessions.indexWhere((s) => s['session']['id'] == session.id);
      if (existingIndex >= 0) {
        sessions[existingIndex] = sessionData;
      } else {
        sessions.insert(0, sessionData);
      }
      
      // Limit cache size
      if (sessions.length > _maxCachedSessions) {
        sessions.removeRange(_maxCachedSessions, sessions.length);
      }
      
      // Save to preferences
      final jsonString = jsonEncode(sessions);
      return await p.setString(_sessionsKey, jsonString);
    } catch (e) {
      print('Error saving session to cache: $e');
      return false;
    }
  }

  /// Get all cached sessions
  static Future<List<Map<String, dynamic>>> getCachedSessions() async {
    try {
      final p = await prefs;
      final jsonString = p.getString(_sessionsKey);
      if (jsonString == null) return [];
      
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error getting cached sessions: $e');
      return [];
    }
  }

  /// Get a specific cached session with subtitles
  static Future<Map<String, dynamic>?> getCachedSession(String sessionId) async {
    try {
      final sessions = await getCachedSessions();
      return sessions.firstWhere(
        (s) => s['session']['id'] == sessionId,
        orElse: () => {},
      );
    } catch (e) {
      return null;
    }
  }

  /// Delete a cached session
  static Future<bool> deleteCachedSession(String sessionId) async {
    try {
      final p = await prefs;
      final sessions = await getCachedSessions();
      sessions.removeWhere((s) => s['session']['id'] == sessionId);
      return await p.setString(_sessionsKey, jsonEncode(sessions));
    } catch (e) {
      return false;
    }
  }

  /// Clear all cached sessions
  static Future<bool> clearAllSessions() async {
    try {
      final p = await prefs;
      return await p.remove(_sessionsKey);
    } catch (e) {
      return false;
    }
  }

  // ============ SETTINGS CACHING ============

  /// Save app settings
  static Future<bool> saveSettings(Map<String, dynamic> settings) async {
    try {
      final p = await prefs;
      return await p.setString(_settingsKey, jsonEncode(settings));
    } catch (e) {
      return false;
    }
  }

  /// Get app settings
  static Future<Map<String, dynamic>> getSettings() async {
    try {
      final p = await prefs;
      final jsonString = p.getString(_settingsKey);
      if (jsonString == null) return _defaultSettings;
      return jsonDecode(jsonString);
    } catch (e) {
      return _defaultSettings;
    }
  }

  static Map<String, dynamic> get _defaultSettings => {
    'autoSave': true,
    'showOriginalText': true,
    'fontSize': 16.0,
    'translationProvider': 'google',
    'theme': 'dark',
    'hapticFeedback': true,
  };

  // ============ API KEYS CACHING ============

  /// Save API keys securely
  static Future<bool> saveApiKeys(Map<String, String> keys) async {
    try {
      final p = await prefs;
      // In production, use flutter_secure_storage instead
      return await p.setString(_apiKeysKey, jsonEncode(keys));
    } catch (e) {
      return false;
    }
  }

  /// Get API keys
  static Future<Map<String, String>> getApiKeys() async {
    try {
      final p = await prefs;
      final jsonString = p.getString(_apiKeysKey);
      if (jsonString == null) return {};
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, v.toString()));
    } catch (e) {
      return {};
    }
  }

  /// Check if API keys are configured
  static Future<bool> hasApiKeys() async {
    final keys = await getApiKeys();
    return keys.containsKey('openai') && keys['openai']!.isNotEmpty;
  }

  // ============ DICTIONARY CACHING ============

  /// Cache BTS dictionary for offline use
  static Future<bool> cacheDictionary(Map<String, dynamic> dictionary) async {
    try {
      final p = await prefs;
      return await p.setString(_dictionaryKey, jsonEncode(dictionary));
    } catch (e) {
      return false;
    }
  }

  /// Get cached dictionary
  static Future<Map<String, dynamic>?> getCachedDictionary() async {
    try {
      final p = await prefs;
      final jsonString = p.getString(_dictionaryKey);
      if (jsonString == null) return null;
      return jsonDecode(jsonString);
    } catch (e) {
      return null;
    }
  }

  // ============ FILE CACHING ============

  /// Get cache directory path
  static Future<String> get cacheDir async {
    final directory = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${directory.path}/cache');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir.path;
  }

  /// Save file to cache
  static Future<File?> saveFileToCache(String filename, List<int> bytes) async {
    try {
      final dir = await cacheDir;
      final file = File('$dir/$filename');
      return await file.writeAsBytes(bytes);
    } catch (e) {
      return null;
    }
  }

  /// Get file from cache
  static Future<File?> getFileFromCache(String filename) async {
    try {
      final dir = await cacheDir;
      final file = File('$dir/$filename');
      if (await file.exists()) {
        return file;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get total cache size
  static Future<int> getCacheSize() async {
    try {
      final dir = await cacheDir;
      final directory = Directory(dir);
      int totalSize = 0;
      
      await for (final entity in directory.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
      
      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  /// Clear file cache
  static Future<bool> clearFileCache() async {
    try {
      final dir = await cacheDir;
      final directory = Directory(dir);
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Format bytes to human readable string
  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
