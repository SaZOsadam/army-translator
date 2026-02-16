import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

// Shared preferences provider
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

// User bias provider
final userBiasProvider = StateProvider<String>((ref) => 'OT7');

// User language provider
final userLanguageProvider = StateProvider<String>((ref) => 'en');

// Is premium provider
final isPremiumProvider = StateProvider<bool>((ref) => false);

// Onboarding complete provider
final onboardingCompleteProvider = FutureProvider<bool>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return prefs.getBool(AppConstants.keyOnboardingComplete) ?? false;
});

// User preferences notifier
class UserPreferencesNotifier extends StateNotifier<UserPreferences> {
  final SharedPreferences _prefs;

  UserPreferencesNotifier(this._prefs)
      : super(UserPreferences.fromPrefs(_prefs));

  void setBias(String bias) {
    _prefs.setString(AppConstants.keyUserBias, bias);
    state = state.copyWith(bias: bias);
  }

  void setLanguage(String language) {
    _prefs.setString(AppConstants.keyUserLanguage, language);
    state = state.copyWith(language: language);
  }

  void setOnboardingComplete(bool complete) {
    _prefs.setBool(AppConstants.keyOnboardingComplete, complete);
    state = state.copyWith(onboardingComplete: complete);
  }

  void setDarkMode(bool isDark) {
    _prefs.setString(AppConstants.keyThemeMode, isDark ? 'dark' : 'light');
    state = state.copyWith(isDarkMode: isDark);
  }
}

class UserPreferences {
  final String bias;
  final String language;
  final bool onboardingComplete;
  final bool isDarkMode;

  UserPreferences({
    required this.bias,
    required this.language,
    required this.onboardingComplete,
    required this.isDarkMode,
  });

  factory UserPreferences.fromPrefs(SharedPreferences prefs) {
    return UserPreferences(
      bias: prefs.getString(AppConstants.keyUserBias) ?? 'OT7',
      language: prefs.getString(AppConstants.keyUserLanguage) ?? 'en',
      onboardingComplete: prefs.getBool(AppConstants.keyOnboardingComplete) ?? false,
      isDarkMode: prefs.getString(AppConstants.keyThemeMode) != 'light',
    );
  }

  UserPreferences copyWith({
    String? bias,
    String? language,
    bool? onboardingComplete,
    bool? isDarkMode,
  }) {
    return UserPreferences(
      bias: bias ?? this.bias,
      language: language ?? this.language,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}

final userPreferencesProvider =
    StateNotifierProvider<UserPreferencesNotifier, UserPreferences>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider).maybeWhen(
        data: (prefs) => prefs,
        orElse: () => null,
      );

  if (prefs == null) {
    throw Exception('SharedPreferences not initialized');
  }

  return UserPreferencesNotifier(prefs);
});

// Leaderboard provider
final leaderboardProvider = FutureProvider<List<LeaderboardEntry>>((ref) async {
  final authService = AuthService();
  final currentUser = authService.currentUser;
  
  // Mock data for now
  return [
    LeaderboardEntry(
      rank: 1,
      displayName: 'ARMYforever_7',
      bias: 'OT7',
      theoriesGenerated: 156,
      isCurrentUser: false,
    ),
    LeaderboardEntry(
      rank: 2,
      displayName: 'JKmaknae',
      bias: 'Jungkook',
      theoriesGenerated: 142,
      isCurrentUser: false,
    ),
    LeaderboardEntry(
      rank: 3,
      displayName: 'ChimChimLover',
      bias: 'Jimin',
      theoriesGenerated: 128,
      isCurrentUser: false,
    ),
    LeaderboardEntry(
      rank: 4,
      displayName: currentUser?.displayName ?? 'You',
      bias: 'V',
      theoriesGenerated: 45,
      isCurrentUser: true,
    ),
  ];
});

class LeaderboardEntry {
  final int rank;
  final String displayName;
  final String bias;
  final int theoriesGenerated;
  final bool isCurrentUser;

  LeaderboardEntry({
    required this.rank,
    required this.displayName,
    required this.bias,
    required this.theoriesGenerated,
    required this.isCurrentUser,
  });
}
