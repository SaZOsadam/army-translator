import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../services/openai_service.dart';
import '../../services/auth_service.dart';

import '../../models/theory_model.dart';
import '../../widgets/gradient_button.dart';

class TheoryGeneratorScreen extends StatefulWidget {
  const TheoryGeneratorScreen({super.key});

  @override
  State<TheoryGeneratorScreen> createState() => _TheoryGeneratorScreenState();
}

class _TheoryGeneratorScreenState extends State<TheoryGeneratorScreen> {
  final _inputController = TextEditingController();
  final _openAIService = OpenAIService();
  final _authService = AuthService();
  
  String _selectedBias = 'OT7';
  String? _generatedTheory;
  bool _isLoading = false;
  bool _hasApiKey = false;

  @override
  void initState() {
    super.initState();
    _checkApiKey();
    _loadUserBias();
  }

  Future<void> _checkApiKey() async {
    final hasKey = await _openAIService.hasApiKey();
    setState(() => _hasApiKey = hasKey);
  }

  Future<void> _loadUserBias() async {
    final user = _authService.currentUser;
    if (user != null) {
      final userData = await _authService.getUserData(user.id);
      if (userData != null && mounted) {
        setState(() {
          _selectedBias = userData.bias;
        });
      }
    }
  }

  Future<void> _generateTheory() async {
    if (_inputController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please describe a teaser, symbol, or lyric first! 💜'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    if (!_hasApiKey) {
      _showApiKeyDialog();
      return;
    }

    setState(() {
      _isLoading = true;
      _generatedTheory = null;
    });

    try {
      final theory = await _openAIService.generateTheory(
        userInput: _inputController.text.trim(),
        bias: _selectedBias,
      );

      setState(() {
        _generatedTheory = theory;
        _isLoading = false;
      });

      // Save theory to Supabase
      final user = _authService.currentUser;
      if (user != null) {
        await SupabaseService.createTheory(
          title: _inputController.text.trim().length > 50 
              ? '${_inputController.text.trim().substring(0, 50)}...' 
              : _inputController.text.trim(),
          content: theory,
          prompt: _inputController.text.trim(),
          tags: [_selectedBias],
        );
        await _authService.incrementTheoriesGenerated(user.id);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showApiKeyDialog() {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('OpenAI API Key Required'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'To generate AI theories, please enter your OpenAI API key. '
              'Your key is stored securely on your device.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'sk-...',
                labelText: 'API Key',
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await _openAIService.setApiKey(controller.text.trim());
                setState(() => _hasApiKey = true);
                Navigator.pop(context);
                _generateTheory();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _shareTheory() {
    if (_generatedTheory == null) return;
    
    final shareText = '''
🔮 ARIRANG Theory by ARMY 💜

${_generatedTheory!}

Generated with ARMY Hub App
#BTS #ARIRANG #BTSComeback #ARMY
''';

    Share.share(shareText);
  }

  void _copyTheory() {
    if (_generatedTheory == null) return;
    
    Clipboard.setData(ClipboardData(text: _generatedTheory!));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Theory copied to clipboard! 💜'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theory Generator 🔮'),
        actions: [
          if (_generatedTheory != null)
            IconButton(
              onPressed: _shareTheory,
              icon: const Icon(Icons.share),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIntroCard(),
            const SizedBox(height: 24),
            _buildBiasSelector(),
            const SizedBox(height: 24),
            _buildInputSection(),
            const SizedBox(height: 24),
            _buildGenerateButton(),
            if (_isLoading) ...[
              const SizedBox(height: 32),
              _buildLoadingState(),
            ],
            if (_generatedTheory != null) ...[
              const SizedBox(height: 32),
              _buildTheoryResult(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIntroCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.purpleGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Text('✨', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI-Powered Theories',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Describe a teaser, symbol, or lyric and let AI decode it ARMY-style!',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBiasSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Focus on member:',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 45,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: AppConstants.biasOptions.length,
            itemBuilder: (context, index) {
              final bias = AppConstants.biasOptions[index];
              final isSelected = _selectedBias == bias;
              final color = AppColors.memberColors[bias]!;
              final emoji = AppConstants.memberInfo[bias]!['emoji']!;

              return GestureDetector(
                onTap: () => setState(() => _selectedBias = bias),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isSelected ? color : color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: color,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 6),
                      Text(
                        bias,
                        style: TextStyle(
                          color: isSelected ? Colors.white : color,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What do you want to decode?',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _inputController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Describe a teaser image, MV scene, lyric, or symbol...\n\nExample: "The red circle appearing in the teaser trailer with the sunset background"',
            hintStyle: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Pro tip: Be specific about colors, symbols, or lyrics you noticed!',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildGenerateButton() {
    return GradientButton(
      onPressed: _isLoading ? null : _generateTheory,
      text: _isLoading ? 'Generating...' : 'Generate Theory 🔮',
      gradient: AppColors.purpleGradient,
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation(AppColors.primaryPurple),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'AI is channeling ARMY energy... 💜',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Generating your theory',
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildTheoryResult() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryPurple.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: AppColors.purpleGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🔮', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      '$_selectedBias Theory',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _copyTheory,
                icon: const Icon(Icons.copy, size: 20),
                tooltip: 'Copy',
              ),
              IconButton(
                onPressed: _shareTheory,
                icon: const Icon(Icons.share, size: 20),
                tooltip: 'Share',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _generatedTheory!,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildActionChip(Icons.favorite_border, 'Like'),
              const SizedBox(width: 8),
              _buildActionChip(Icons.bookmark_border, 'Save'),
              const Spacer(),
              TextButton.icon(
                onPressed: _generateTheory,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Regenerate'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.primaryPurple),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.primaryPurple,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
          ),
        ],
      ),
    );
  }
}
