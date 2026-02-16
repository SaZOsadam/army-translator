import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../services/openai_service.dart';
import '../../services/auth_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final OpenAIService _openAIService = OpenAIService();
  final AuthService _authService = AuthService();

  bool _hasApiKey = false;
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'en';
  String _selectedBias = 'OT7';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final hasKey = await _openAIService.hasApiKey();
    final user = _authService.currentUser;

    if (user != null) {
      final userData = await _authService.getUserData(user.id);
      if (userData != null && mounted) {
        setState(() {
          _hasApiKey = hasKey;
          _selectedLanguage = userData.language;
          _selectedBias = userData.bias;
        });
      }
    } else {
      setState(() => _hasApiKey = hasKey);
    }
  }

  void _showApiKeyDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _hasApiKey ? Icons.check_circle : Icons.key,
              color: _hasApiKey ? AppColors.success : AppColors.primaryPurple,
            ),
            const SizedBox(width: 8),
            Text(_hasApiKey ? 'Update API Key' : 'Add API Key'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your OpenAI API key to enable AI theory generation. '
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
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _launchUrl('https://platform.openai.com/api-keys'),
              child: const Text(
                'Get your API key from OpenAI →',
                style: TextStyle(
                  color: AppColors.primaryPurple,
                  decoration: TextDecoration.underline,
                ),
              ),
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
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('API key saved! 💜'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showBiasSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Your Bias',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppConstants.biasOptions.map((bias) {
                final isSelected = _selectedBias == bias;
                final color = AppColors.memberColors[bias]!;
                final emoji = AppConstants.memberInfo[bias]!['emoji']!;

                return GestureDetector(
                  onTap: () async {
                    setState(() => _selectedBias = bias);
                    final user = _authService.currentUser;
                    if (user != null) {
                      await _authService.updateUserProfile(
                        uid: user.id,
                        bias: bias,
                      );
                    }
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? color : color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: color,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(emoji, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Text(
                          bias,
                          style: TextStyle(
                            color: isSelected ? Colors.white : color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Language',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...AppConstants.supportedLanguages.map((lang) {
              final isSelected = _selectedLanguage == lang['code'];

              return ListTile(
                onTap: () async {
                  setState(() => _selectedLanguage = lang['code']!);
                  final user = _authService.currentUser;
                  if (user != null) {
                    await _authService.updateUserProfile(
                      uid: user.id,
                      language: lang['code'],
                    );
                  }
                  Navigator.pop(context);
                },
                leading: Text(
                  lang['flag']!,
                  style: const TextStyle(fontSize: 24),
                ),
                title: Text(lang['name']!),
                trailing: isSelected
                    ? const Icon(Icons.check, color: AppColors.primaryPurple)
                    : null,
              );
            }),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Personalization'),
          _buildSettingsTile(
            icon: Icons.person,
            title: 'Your Bias',
            subtitle: _selectedBias,
            trailing: Text(
              AppConstants.memberInfo[_selectedBias]!['emoji']!,
              style: const TextStyle(fontSize: 24),
            ),
            onTap: _showBiasSelector,
          ),
          _buildSettingsTile(
            icon: Icons.language,
            title: 'Language',
            subtitle: AppConstants.supportedLanguages
                .firstWhere((l) => l['code'] == _selectedLanguage)['name']!,
            onTap: _showLanguageSelector,
          ),
          _buildSettingsTile(
            icon: Icons.dark_mode,
            title: 'Dark Mode',
            subtitle: isDark ? 'On' : 'Off',
            trailing: Switch(
              value: isDark,
              onChanged: (value) {
                ref.read(themeModeProvider.notifier).state =
                    value ? ThemeMode.dark : ThemeMode.light;
              },
              activeColor: AppColors.primaryPurple,
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('AI Settings'),
          _buildSettingsTile(
            icon: Icons.key,
            title: 'OpenAI API Key',
            subtitle: _hasApiKey ? 'Configured ✓' : 'Not configured',
            subtitleColor: _hasApiKey ? AppColors.success : AppColors.warning,
            onTap: _showApiKeyDialog,
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Notifications'),
          _buildSettingsTile(
            icon: Icons.notifications,
            title: 'Push Notifications',
            subtitle: 'Teasers, countdowns, daily messages',
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() => _notificationsEnabled = value);
              },
              activeColor: AppColors.primaryPurple,
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Support'),
          _buildSettingsTile(
            icon: Icons.favorite,
            title: 'Love Myself Campaign',
            subtitle: 'Support UNICEF',
            onTap: () => _launchUrl(AppConstants.loveMyselfUrl),
          ),
          _buildSettingsTile(
            icon: Icons.help_outline,
            title: 'Help & FAQ',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.feedback_outlined,
            title: 'Send Feedback',
            onTap: () {},
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('About'),
          _buildSettingsTile(
            icon: Icons.info_outline,
            title: 'App Version',
            subtitle: AppConstants.appVersion,
          ),
          _buildSettingsTile(
            icon: Icons.policy_outlined,
            title: 'Privacy Policy',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            onTap: () {},
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text('💜', style: TextStyle(fontSize: 32)),
                const SizedBox(height: 8),
                Text(
                  'ARMY Hub',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppConstants.disclaimer,
                  style: Theme.of(context).textTheme.labelLarge,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primaryPurple,
            ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? subtitleColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.primaryPurple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primaryPurple),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(color: subtitleColor),
            )
          : null,
      trailing: trailing ??
          (onTap != null
              ? const Icon(Icons.chevron_right, color: AppColors.textMuted)
              : null),
    );
  }
}
