class AppConstants {
  // App Info
  static const String appName = 'ARMY Hub';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'BTS Comeback AI';
  
  // ARIRANG Album Release Date
  static final DateTime albumReleaseDate = DateTime(2026, 3, 20, 0, 0, 0);
  static const String albumName = 'ARIRANG';
  
  // BTS Members
  static const List<String> btsMembers = [
    'RM',
    'Jin',
    'SUGA',
    'J-Hope',
    'Jimin',
    'V',
    'Jungkook',
  ];
  
  static const List<String> biasOptions = [
    'RM',
    'Jin',
    'SUGA',
    'J-Hope',
    'Jimin',
    'V',
    'Jungkook',
    'OT7',
  ];
  
  // Member Info
  static const Map<String, Map<String, String>> memberInfo = {
    'RM': {
      'fullName': 'Kim Namjoon',
      'position': 'Leader, Main Rapper',
      'emoji': '🐨',
    },
    'Jin': {
      'fullName': 'Kim Seokjin',
      'position': 'Vocalist, Visual',
      'emoji': '🐹',
    },
    'SUGA': {
      'fullName': 'Min Yoongi',
      'position': 'Lead Rapper, Producer',
      'emoji': '😺',  // Smiling cat
    },
    'J-Hope': {
      'fullName': 'Jung Hoseok',
      'position': 'Main Dancer, Sub Rapper',
      'emoji': '🐿️',
    },
    'Jimin': {
      'fullName': 'Park Jimin',
      'position': 'Main Dancer, Lead Vocalist',
      'emoji': '🐥',
    },
    'V': {
      'fullName': 'Kim Taehyung',
      'position': 'Vocalist, Visual',
      'emoji': '🐯',  // Tiger (or 🐻 Bear)
    },
    'Jungkook': {
      'fullName': 'Jeon Jungkook',
      'position': 'Main Vocalist, Lead Dancer, Sub Rapper, Center, Maknae',
      'emoji': '🐰',
    },
    'OT7': {
      'fullName': 'All Members',
      'position': 'Bangtan Sonyeondan',
      'emoji': '💜',
    },
  };
  
  // Supported Languages
  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
    {'code': 'ko', 'name': '한국어', 'flag': '🇰🇷'},
    {'code': 'es', 'name': 'Español', 'flag': '🇪🇸'},
    {'code': 'ja', 'name': '日本語', 'flag': '🇯🇵'},
    {'code': 'pt', 'name': 'Português', 'flag': '🇧🇷'},
    {'code': 'id', 'name': 'Bahasa Indonesia', 'flag': '🇮🇩'},
    {'code': 'th', 'name': 'ภาษาไทย', 'flag': '🇹🇭'},
    {'code': 'vi', 'name': 'Tiếng Việt', 'flag': '🇻🇳'},
    {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷'},
    {'code': 'de', 'name': 'Deutsch', 'flag': '🇩🇪'},
  ];
  
  // API Endpoints
  static const String openAIBaseUrl = 'https://api.openai.com/v1';
  static const String openAIChatEndpoint = '/chat/completions';
  
  // Storage Keys
  static const String keyUserBias = 'user_bias';
  static const String keyUserLanguage = 'user_language';
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keyThemeMode = 'theme_mode';
  static const String keyOpenAIKey = 'openai_api_key';
  static const String keyPremiumStatus = 'is_premium';
  
  // Premium Pricing
  static const double premiumMonthlyPrice = 4.99;
  static const double premiumYearlyPrice = 39.99;
  
  // Legal
  static const String disclaimer = '''
Fan-made, unofficial app.
Not affiliated with BTS, HYBE, or BigHit Music.
For entertainment purposes only.
All BTS-related content belongs to respective owners.
''';
  
  // Links
  static const String loveMyselfUrl = 'https://www.love-myself.org/';
  static const String unicefUrl = 'https://www.unicef.org/';
}
