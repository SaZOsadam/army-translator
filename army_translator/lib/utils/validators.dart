class Validators {
  static String? validateApiKey(String? value, {String keyName = 'API key'}) {
    if (value == null || value.trim().isEmpty) {
      return '$keyName is required';
    }
    if (value.length < 10) {
      return '$keyName appears to be invalid';
    }
    return null;
  }

  static String? validateOpenAIKey(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'OpenAI API key is required';
    }
    if (!value.startsWith('sk-')) {
      return 'OpenAI key should start with sk-';
    }
    if (value.length < 40) {
      return 'OpenAI key appears to be invalid';
    }
    return null;
  }

  static String? validateSessionTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Session title is required';
    }
    if (value.length > 100) {
      return 'Title must be less than 100 characters';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  static bool isKoreanText(String text) {
    final koreanRegex = RegExp(r'[\uAC00-\uD7AF\u1100-\u11FF\u3130-\u318F]');
    return koreanRegex.hasMatch(text);
  }

  static bool containsKorean(String text) {
    return isKoreanText(text);
  }
}
