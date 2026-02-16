import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../services/speech_to_text_service.dart';
import '../../services/translation_service.dart';
import '../../utils/validators.dart';

class ApiSetupScreen extends StatefulWidget {
  const ApiSetupScreen({super.key});

  @override
  State<ApiSetupScreen> createState() => _ApiSetupScreenState();
}

class _ApiSetupScreenState extends State<ApiSetupScreen> {
  final PageController _pageController = PageController();
  final SpeechToTextService _sttService = SpeechToTextService();
  final TranslationService _translationService = TranslationService();
  
  int _currentStep = 0;
  bool _isLoading = false;
  
  // Controllers
  final _openAIController = TextEditingController();
  final _papagoIdController = TextEditingController();
  final _papagoSecretController = TextEditingController();
  final _deeplController = TextEditingController();
  
  TranslationProvider _selectedProvider = TranslationProvider.google;

  @override
  void dispose() {
    _pageController.dispose();
    _openAIController.dispose();
    _papagoIdController.dispose();
    _papagoSecretController.dispose();
    _deeplController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep++);
    } else {
      _completeSetup();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep--);
    }
  }

  Future<void> _completeSetup() async {
    setState(() => _isLoading = true);
    
    try {
      // Save OpenAI key
      if (_openAIController.text.isNotEmpty) {
        await _sttService.setApiKey(_openAIController.text.trim());
      }
      
      // Save translation provider keys
      if (_papagoIdController.text.isNotEmpty && _papagoSecretController.text.isNotEmpty) {
        await _translationService.setPapagoCredentials(
          _papagoIdController.text.trim(),
          _papagoSecretController.text.trim(),
        );
      }
      
      if (_deeplController.text.isNotEmpty) {
        await _translationService.setDeepLKey(_deeplController.text.trim());
      }
      
      await _translationService.setPreferredProvider(_selectedProvider);
      
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.confidenceLow),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        title: const Text('API Setup'),
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _previousStep,
              )
            : null,
      ),
      body: Column(
        children: [
          // Progress indicator
          _buildProgressIndicator(),
          
          // Pages
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildOpenAIStep(),
                _buildTranslationStep(),
                _buildSummaryStep(),
              ],
            ),
          ),
          
          // Bottom button
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: List.generate(3, (index) {
          final isActive = index <= _currentStep;
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primaryPurple : AppColors.cardDark,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildOpenAIStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🎤 Speech Recognition',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'OpenAI Whisper converts Korean speech to text',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),
          
          _buildInfoCard(
            icon: Icons.key,
            title: 'OpenAI API Key',
            subtitle: 'Required for speech-to-text',
            isRequired: true,
          ),
          const SizedBox(height: 16),
          
          TextField(
            controller: _openAIController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'sk-...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
              prefixIcon: const Icon(Icons.vpn_key, color: AppColors.primaryPurple),
              filled: true,
              fillColor: AppColors.cardDark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          _buildHelpLink(
            'Get your API key from OpenAI',
            'https://platform.openai.com/api-keys',
          ),
          
          const SizedBox(height: 32),
          _buildCostEstimate(),
        ],
      ),
    );
  }

  Widget _buildTranslationStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🌍 Translation Provider',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose your preferred translation service',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),
          
          _buildProviderOption(
            provider: TranslationProvider.google,
            title: 'Google Translate',
            subtitle: 'Free, no API key needed',
            emoji: '🆓',
          ),
          const SizedBox(height: 12),
          
          _buildProviderOption(
            provider: TranslationProvider.papago,
            title: 'Naver Papago',
            subtitle: 'Best for Korean (requires API key)',
            emoji: '🇰🇷',
          ),
          const SizedBox(height: 12),
          
          _buildProviderOption(
            provider: TranslationProvider.deepl,
            title: 'DeepL',
            subtitle: 'High quality (requires API key)',
            emoji: '✨',
          ),
          
          const SizedBox(height: 24),
          
          // Papago credentials
          if (_selectedProvider == TranslationProvider.papago) ...[
            TextField(
              controller: _papagoIdController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('Papago Client ID'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _papagoSecretController,
              style: const TextStyle(color: Colors.white),
              obscureText: true,
              decoration: _inputDecoration('Papago Client Secret'),
            ),
            const SizedBox(height: 12),
            _buildHelpLink('Get Papago API', 'https://developers.naver.com/'),
          ],
          
          // DeepL key
          if (_selectedProvider == TranslationProvider.deepl) ...[
            TextField(
              controller: _deeplController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('DeepL API Key'),
            ),
            const SizedBox(height: 12),
            _buildHelpLink('Get DeepL API', 'https://www.deepl.com/pro-api'),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '✅ Ready to Translate!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Review your configuration',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),
          
          _buildSummaryItem(
            '🎤 Speech Recognition',
            _openAIController.text.isNotEmpty ? 'OpenAI Whisper ✓' : 'Not configured',
            _openAIController.text.isNotEmpty,
          ),
          const SizedBox(height: 16),
          
          _buildSummaryItem(
            '🌍 Translation',
            _getProviderName(_selectedProvider),
            true,
          ),
          const SizedBox(height: 16),
          
          _buildSummaryItem(
            '📚 BTS Dictionary',
            '100+ terms included ✓',
            true,
          ),
          
          const SizedBox(height: 32),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryPurple.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Text('💜', style: TextStyle(fontSize: 32)),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'You can always change these settings later',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _nextStep,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryPurple,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : Text(
                  _currentStep == 2 ? 'Start Translating' : 'Continue',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isRequired,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryPurple.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryPurple),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (isRequired)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.confidenceMedium.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Required',
                style: TextStyle(
                  color: AppColors.confidenceMedium,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProviderOption({
    required TranslationProvider provider,
    required String title,
    required String subtitle,
    required String emoji,
  }) {
    final isSelected = _selectedProvider == provider;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedProvider = provider),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryPurple.withOpacity(0.1) : AppColors.cardDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryPurple : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? AppColors.primaryPurple : Colors.white.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpLink(String text, String url) {
    return GestureDetector(
      onTap: () {
        // Open URL
      },
      child: Row(
        children: [
          const Icon(Icons.help_outline, color: AppColors.primaryPurple, size: 16),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.primaryPurple,
              fontSize: 14,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostEstimate() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '💰 Estimated Cost',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '~\$0.006 per minute of audio',
            style: TextStyle(color: Colors.white.withOpacity(0.7)),
          ),
          Text(
            '1 hour of Weverse Live ≈ \$0.36',
            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value, bool isConfigured) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                Text(value, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14)),
              ],
            ),
          ),
          Icon(
            isConfigured ? Icons.check_circle : Icons.warning,
            color: isConfigured ? AppColors.confidenceHigh : AppColors.confidenceMedium,
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
      filled: true,
      fillColor: AppColors.cardDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  String _getProviderName(TranslationProvider provider) {
    switch (provider) {
      case TranslationProvider.google:
        return 'Google Translate (Free)';
      case TranslationProvider.papago:
        return 'Naver Papago';
      case TranslationProvider.deepl:
        return 'DeepL';
    }
  }
}
