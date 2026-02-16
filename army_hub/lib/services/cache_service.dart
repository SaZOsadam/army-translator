import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class CacheService {
  static const String _theoriesKey = 'cached_theories';
  static const String _userKey = 'cached_user';
  static const String _settingsKey = 'app_settings';
  static const String _countdownKey = 'countdown_data';
  static const String _dailyMessageKey = 'daily_message';
  static const String _pollsKey = 'cached_polls';
  static const int _maxCachedTheories = 100;

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

  // ============ THEORY CACHING ============

  /// Save theory to local cache
  static Future<bool> saveTheory(Map<String, dynamic> theory) async {
    try {
      final p = await prefs;
      final theories = await getCachedTheories();
      
      final theoryData = {
        ...theory,
        'cachedAt': DateTime.now().toIso8601String(),
      };
      
      // Check if theory already exists
      final existingIndex = theories.indexWhere((t) => t['id'] == theory['id']);
      if (existingIndex >= 0) {
        theories[existingIndex] = theoryData;
      } else {
        theories.insert(0, theoryData);
      }
      
      // Limit cache size
      if (theories.length > _maxCachedTheories) {
        theories.removeRange(_maxCachedTheories, theories.length);
      }
      
      return await p.setString(_theoriesKey, jsonEncode(theories));
    } catch (e) {
      print('Error saving theory to cache: $e');
      return false;
    }
  }

  /// Get all cached theories
  static Future<List<Map<String, dynamic>>> getCachedTheories() async {
    try {
      final p = await prefs;
      final jsonString = p.getString(_theoriesKey);
      if (jsonString == null) return [];
      
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  /// Get user's cached theories
  static Future<List<Map<String, dynamic>>> getUserTheories(String userId) async {
    final theories = await getCachedTheories();
    return theories.where((t) => t['userId'] == userId).toList();
  }

  /// Delete a cached theory
  static Future<bool> deleteCachedTheory(String theoryId) async {
    try {
      final p = await prefs;
      final theories = await getCachedTheories();
      theories.removeWhere((t) => t['id'] == theoryId);
      return await p.setString(_theoriesKey, jsonEncode(theories));
    } catch (e) {
      return false;
    }
  }

  // ============ USER CACHING ============

  /// Save user data for offline access
  static Future<bool> saveUser(Map<String, dynamic> user) async {
    try {
      final p = await prefs;
      return await p.setString(_userKey, jsonEncode(user));
    } catch (e) {
      return false;
    }
  }

  /// Get cached user
  static Future<Map<String, dynamic>?> getCachedUser() async {
    try {
      final p = await prefs;
      final jsonString = p.getString(_userKey);
      if (jsonString == null) return null;
      return jsonDecode(jsonString);
    } catch (e) {
      return null;
    }
  }

  /// Clear cached user
  static Future<bool> clearUser() async {
    try {
      final p = await prefs;
      return await p.remove(_userKey);
    } catch (e) {
      return false;
    }
  }

  // ============ COUNTDOWN CACHING ============

  /// Save countdown data for offline access
  static Future<bool> saveCountdownData(Map<String, dynamic> data) async {
    try {
      final p = await prefs;
      final cacheData = {
        ...data,
        'cachedAt': DateTime.now().toIso8601String(),
      };
      return await p.setString(_countdownKey, jsonEncode(cacheData));
    } catch (e) {
      return false;
    }
  }

  /// Get cached countdown data
  static Future<Map<String, dynamic>?> getCountdownData() async {
    try {
      final p = await prefs;
      final jsonString = p.getString(_countdownKey);
      if (jsonString == null) return null;
      return jsonDecode(jsonString);
    } catch (e) {
      return null;
    }
  }

  // ============ DAILY MESSAGE CACHING ============

  /// Save daily message
  static Future<bool> saveDailyMessage(Map<String, dynamic> message) async {
    try {
      final p = await prefs;
      final cacheData = {
        ...message,
        'date': DateTime.now().toIso8601String().split('T')[0],
      };
      return await p.setString(_dailyMessageKey, jsonEncode(cacheData));
    } catch (e) {
      return false;
    }
  }

  /// Get today's cached daily message
  static Future<Map<String, dynamic>?> getDailyMessage() async {
    try {
      final p = await prefs;
      final jsonString = p.getString(_dailyMessageKey);
      if (jsonString == null) return null;
      
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      final cachedDate = data['date'] as String?;
      final today = DateTime.now().toIso8601String().split('T')[0];
      
      // Return null if cached message is from a different day
      if (cachedDate != today) return null;
      
      return data;
    } catch (e) {
      return null;
    }
  }

  // ============ POLLS CACHING ============

  /// Save polls for offline viewing
  static Future<bool> savePolls(List<Map<String, dynamic>> polls) async {
    try {
      final p = await prefs;
      return await p.setString(_pollsKey, jsonEncode(polls));
    } catch (e) {
      return false;
    }
  }

  /// Get cached polls
  static Future<List<Map<String, dynamic>>> getCachedPolls() async {
    try {
      final p = await prefs;
      final jsonString = p.getString(_pollsKey);
      if (jsonString == null) return [];
      
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
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
    'bias': null,
    'notifications': true,
    'dailyReminder': true,
    'theme': 'dark',
    'hapticFeedback': true,
  };

  // ============ CACHE MANAGEMENT ============

  /// Get cache directory path
  static Future<String> get cacheDir async {
    final directory = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${directory.path}/army_hub_cache');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir.path;
  }

  /// Get total cache size in bytes
  static Future<int> getCacheSize() async {
    try {
      final p = await prefs;
      int totalSize = 0;
      
      for (final key in [_theoriesKey, _userKey, _countdownKey, _dailyMessageKey, _pollsKey, _settingsKey]) {
        final value = p.getString(key);
        if (value != null) {
          totalSize += value.length;
        }
      }
      
      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  /// Clear all cached data
  static Future<bool> clearAllCache() async {
    try {
      final p = await prefs;
      await p.remove(_theoriesKey);
      await p.remove(_userKey);
      await p.remove(_countdownKey);
      await p.remove(_dailyMessageKey);
      await p.remove(_pollsKey);
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
