class AppConstants {
  // App Info
  static const String appName = 'ARMY Translator';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Real-time BTS translation for ARMY 💜';
  
  // Supported Languages
  static const Map<String, String> supportedLanguages = {
    'en': 'English',
    'es': 'Español',
    'pt': 'Português',
    'fr': 'Français',
    'de': 'Deutsch',
    'ja': '日本語',
    'zh': '中文',
    'id': 'Bahasa Indonesia',
    'vi': 'Tiếng Việt',
    'th': 'ภาษาไทย',
    'ar': 'العربية',
  };
  
  // BTS Members
  static const List<String> members = [
    'RM',
    'Jin',
    'SUGA',
    'J-Hope',
    'Jimin',
    'V',
    'Jungkook',
  ];
  
  static const Map<String, Map<String, String>> memberInfo = {
    'RM': {'emoji': '🐨', 'color': 'blue'},           // Koala (BT21: Koya)
    'Jin': {'emoji': '🐹', 'color': 'pink'},          // Hamster
    'SUGA': {'emoji': '😺', 'color': 'white'},        // Smiling cat
    'J-Hope': {'emoji': '🐿️', 'color': 'green'},     // Squirrel
    'Jimin': {'emoji': '🐥', 'color': 'gold'},        // Baby chick
    'V': {'emoji': '🐯', 'color': 'green'},           // Tiger (or 🐻 Bear)
    'Jungkook': {'emoji': '🐰', 'color': 'purple'},   // Rabbit
  };
  
  // API Endpoints
  static const String whisperApiUrl = 'https://api.openai.com/v1/audio/transcriptions';
  static const String gptApiUrl = 'https://api.openai.com/v1/chat/completions';
  static const String papagoApiUrl = 'https://openapi.naver.com/v1/papago/n2mt';
  static const String deeplApiUrl = 'https://api-free.deepl.com/v2/translate';
  
  // Audio Settings
  static const int sampleRate = 16000;
  static const int audioChannels = 1;
  static const int chunkDurationMs = 3000;
  static const int maxRecordingDurationMinutes = 120;
  
  // Storage Keys
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keyTargetLanguage = 'target_language';
  static const String keyOpenAIKey = 'openai_api_key';
  static const String keyPapagoClientId = 'papago_client_id';
  static const String keyPapagoSecret = 'papago_secret';
  static const String keyDeepLKey = 'deepl_api_key';
  static const String keyPreferredTranslator = 'preferred_translator';
  static const String keyShowOriginalText = 'show_original_text';
  static const String keySubtitleFontSize = 'subtitle_font_size';
  static const String keyAutoSaveSession = 'auto_save_session';
  static const String keyGptPolishEnabled = 'gpt_polish_enabled';
  
  // Translation Providers
  static const List<String> translationProviders = [
    'papago',
    'deepl',
    'google',
  ];
  
  // Subtitle Settings
  static const double defaultSubtitleFontSize = 20.0;
  static const double minSubtitleFontSize = 14.0;
  static const double maxSubtitleFontSize = 32.0;
  
  // Premium
  static const String premiumMonthlyId = 'army_translator_premium_monthly';
  static const double premiumPrice = 4.99;
  
  // Legal
  static const String disclaimer = '''
Fan-made translation tool – not affiliated with BTS, HYBE, or BigHit Music.
Audio captured from public sources only.
For personal entertainment use.
Respect artist privacy and content rights.
''';
  
  static const String privacyUrl = 'https://armytranslator.app/privacy';
  static const String termsUrl = 'https://armytranslator.app/terms';
}
