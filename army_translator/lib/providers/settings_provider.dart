import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';
import '../services/translation_service.dart';

class AppSettings {
  final String targetLanguage;
  final bool showOriginalText;
  final bool gptPolishEnabled;
  final bool autoSaveSession;
  final double subtitleFontSize;
  final TranslationProvider translationProvider;

  AppSettings({
    this.targetLanguage = 'en',
    this.showOriginalText = true,
    this.gptPolishEnabled = false,
    this.autoSaveSession = true,
    this.subtitleFontSize = 20.0,
    this.translationProvider = TranslationProvider.google,
  });

  AppSettings copyWith({
    String? targetLanguage,
    bool? showOriginalText,
    bool? gptPolishEnabled,
    bool? autoSaveSession,
    double? subtitleFontSize,
    TranslationProvider? translationProvider,
  }) {
    return AppSettings(
      targetLanguage: targetLanguage ?? this.targetLanguage,
      showOriginalText: showOriginalText ?? this.showOriginalText,
      gptPolishEnabled: gptPolishEnabled ?? this.gptPolishEnabled,
      autoSaveSession: autoSaveSession ?? this.autoSaveSession,
      subtitleFontSize: subtitleFontSize ?? this.subtitleFontSize,
      translationProvider: translationProvider ?? this.translationProvider,
    );
  }
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(AppSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    final providerStr = prefs.getString(AppConstants.keyPreferredTranslator);
    TranslationProvider provider = TranslationProvider.google;
    if (providerStr == 'papago') provider = TranslationProvider.papago;
    if (providerStr == 'deepl') provider = TranslationProvider.deepl;

    state = AppSettings(
      targetLanguage: prefs.getString(AppConstants.keyTargetLanguage) ?? 'en',
      showOriginalText: prefs.getBool(AppConstants.keyShowOriginalText) ?? true,
      gptPolishEnabled: prefs.getBool(AppConstants.keyGptPolishEnabled) ?? false,
      autoSaveSession: prefs.getBool(AppConstants.keyAutoSaveSession) ?? true,
      subtitleFontSize: prefs.getDouble(AppConstants.keySubtitleFontSize) ?? 20.0,
      translationProvider: provider,
    );
  }

  Future<void> setTargetLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyTargetLanguage, language);
    state = state.copyWith(targetLanguage: language);
  }

  Future<void> setShowOriginalText(bool show) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyShowOriginalText, show);
    state = state.copyWith(showOriginalText: show);
  }

  Future<void> setGptPolishEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyGptPolishEnabled, enabled);
    state = state.copyWith(gptPolishEnabled: enabled);
  }

  Future<void> setAutoSaveSession(bool autoSave) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyAutoSaveSession, autoSave);
    state = state.copyWith(autoSaveSession: autoSave);
  }

  Future<void> setSubtitleFontSize(double size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(AppConstants.keySubtitleFontSize, size);
    state = state.copyWith(subtitleFontSize: size);
  }

  Future<void> setTranslationProvider(TranslationProvider provider) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyPreferredTranslator, provider.name);
    state = state.copyWith(translationProvider: provider);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});

// Convenience providers
final targetLanguageProvider = Provider<String>((ref) {
  return ref.watch(settingsProvider).targetLanguage;
});

final showOriginalTextProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider).showOriginalText;
});

final subtitleFontSizeProvider = Provider<double>((ref) {
  return ref.watch(settingsProvider).subtitleFontSize;
});
