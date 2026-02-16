import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../services/speech_to_text_service.dart';
import '../../services/translation_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SpeechToTextService _sttService = SpeechToTextService();
  final TranslationService _translationService = TranslationService();
  
  String _targetLanguage = 'en';
  bool _showOriginalText = true;
  bool _gptPolishEnabled = false;
  bool _autoSaveSession = true;
  double _subtitleFontSize = 20.0;
  TranslationProvider _translationProvider = TranslationProvider.google;
  bool _hasOpenAIKey = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final hasKey = await _sttService.hasApiKey();
    final provider = await _translationService.getPreferredProvider();
    
    setState(() {
      _targetLanguage = prefs.getString(AppConstants.keyTargetLanguage) ?? 'en';
      _showOriginalText = prefs.getBool(AppConstants.keyShowOriginalText) ?? true;
      _gptPolishEnabled = prefs.getBool(AppConstants.keyGptPolishEnabled) ?? false;
      _autoSaveSession = prefs.getBool(AppConstants.keyAutoSaveSession) ?? true;
      _subtitleFontSize = prefs.getDouble(AppConstants.keySubtitleFontSize) ?? 20.0;
      _translationProvider = provider;
      _hasOpenAIKey = hasKey;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyTargetLanguage, _targetLanguage);
    await prefs.setBool(AppConstants.keyShowOriginalText, _showOriginalText);
    await prefs.setBool(AppConstants.keyGptPolishEnabled, _gptPolishEnabled);
    await prefs.setBool(AppConstants.keyAutoSaveSession, _autoSaveSession);
    await prefs.setDouble(AppConstants.keySubtitleFontSize, _subtitleFontSize);
    await _translationService.setPreferredProvider(_translationProvider);
  }

  void _showApiKeyDialog() {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: const Text('OpenAI API Key', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'sk-...',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
            filled: true,
            fillColor: AppColors.darkBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await _sttService.setApiKey(controller.text);
                setState(() => _hasOpenAIKey = true);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('API key saved')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection('Translation', [
            _buildLanguageSelector(),
            _buildProviderSelector(),
            _buildApiKeyTile(),
          ]),
          
          _buildSection('Display', [
            _buildSwitchTile(
              'Show Original Korean',
              'Display Korean text above translation',
              _showOriginalText,
              (v) => setState(() { _showOriginalText = v; _saveSettings(); }),
            ),
            _buildFontSizeSlider(),
          ]),
          
          _buildSection('AI Features', [
            _buildSwitchTile(
              'GPT Polish',
              'Use AI to make translations more natural',
              _gptPolishEnabled,
              (v) => setState(() { _gptPolishEnabled = v; _saveSettings(); }),
            ),
          ]),
          
          _buildSection('Storage', [
            _buildSwitchTile(
              'Auto-save Sessions',
              'Automatically save translation history',
              _autoSaveSession,
              (v) => setState(() { _autoSaveSession = v; _saveSettings(); }),
            ),
          ]),
          
          _buildSection('About', [
            const ListTile(
              title: Text('Version', style: TextStyle(color: Colors.white)),
              trailing: Text(AppConstants.appVersion, style: TextStyle(color: Colors.white70)),
            ),
            ListTile(
              title: const Text('Privacy Policy', style: TextStyle(color: Colors.white)),
              trailing: const Icon(Icons.open_in_new, color: Colors.white54),
              onTap: () {},
            ),
          ]),
          
          const SizedBox(height: 24),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              AppConstants.disclaimer,
              style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: AppColors.primaryPurple,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: children),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildLanguageSelector() {
    return ListTile(
      title: const Text('Target Language', style: TextStyle(color: Colors.white)),
      trailing: DropdownButton<String>(
        value: _targetLanguage,
        dropdownColor: AppColors.cardDark,
        underline: const SizedBox(),
        items: AppConstants.supportedLanguages.entries.map((e) {
          return DropdownMenuItem(value: e.key, child: Text(e.value, style: const TextStyle(color: Colors.white)));
        }).toList(),
        onChanged: (v) {
          if (v != null) {
            setState(() => _targetLanguage = v);
            _saveSettings();
          }
        },
      ),
    );
  }

  Widget _buildProviderSelector() {
    return ListTile(
      title: const Text('Translation Provider', style: TextStyle(color: Colors.white)),
      trailing: DropdownButton<TranslationProvider>(
        value: _translationProvider,
        dropdownColor: AppColors.cardDark,
        underline: const SizedBox(),
        items: const [
          DropdownMenuItem(value: TranslationProvider.google, child: Text('Google', style: TextStyle(color: Colors.white))),
          DropdownMenuItem(value: TranslationProvider.papago, child: Text('Papago', style: TextStyle(color: Colors.white))),
          DropdownMenuItem(value: TranslationProvider.deepl, child: Text('DeepL', style: TextStyle(color: Colors.white))),
        ],
        onChanged: (v) {
          if (v != null) {
            setState(() => _translationProvider = v);
            _saveSettings();
          }
        },
      ),
    );
  }

  Widget _buildApiKeyTile() {
    return ListTile(
      title: const Text('OpenAI API Key', style: TextStyle(color: Colors.white)),
      subtitle: Text(
        _hasOpenAIKey ? 'Configured ✓' : 'Required for Whisper STT',
        style: TextStyle(color: _hasOpenAIKey ? AppColors.confidenceHigh : Colors.white54),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.white54),
      onTap: _showApiKeyDialog,
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
      value: value,
      onChanged: onChanged,
      activeThumbColor: AppColors.primaryPurple,
    );
  }

  Widget _buildFontSizeSlider() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtitle Size', style: TextStyle(color: Colors.white)),
              Text('${_subtitleFontSize.toInt()}px', style: const TextStyle(color: AppColors.primaryPurple)),
            ],
          ),
          Slider(
            value: _subtitleFontSize,
            min: AppConstants.minSubtitleFontSize,
            max: AppConstants.maxSubtitleFontSize,
            activeColor: AppColors.primaryPurple,
            onChanged: (v) => setState(() => _subtitleFontSize = v),
            onChangeEnd: (v) => _saveSettings(),
          ),
        ],
      ),
    );
  }
}
