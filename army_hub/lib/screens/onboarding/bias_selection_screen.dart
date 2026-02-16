import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../config/constants.dart';
import '../../widgets/gradient_button.dart';

class BiasSelectionScreen extends StatefulWidget {
  const BiasSelectionScreen({super.key});

  @override
  State<BiasSelectionScreen> createState() => _BiasSelectionScreenState();
}

class _BiasSelectionScreenState extends State<BiasSelectionScreen> {
  String? _selectedBias;
  String _selectedLanguage = 'en';

  Future<void> _continue() async {
    if (_selectedBias == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your bias! 💜'),
          backgroundColor: AppColors.primaryPurple,
        ),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyUserBias, _selectedBias!);
    await prefs.setString(AppConstants.keyUserLanguage, _selectedLanguage);
    await prefs.setBool(AppConstants.keyOnboardingComplete, true);

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Who\'s your bias? 💜',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select your favorite member (or choose OT7 if you love them all equally!)',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.4,
                    ),
                    itemCount: AppConstants.biasOptions.length,
                    itemBuilder: (context, index) {
                      final bias = AppConstants.biasOptions[index];
                      final isSelected = _selectedBias == bias;
                      final memberInfo = AppConstants.memberInfo[bias]!;
                      final color = AppColors.memberColors[bias]!;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedBias = bias;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white
                                : Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? color
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                memberInfo['emoji']!,
                                style: const TextStyle(fontSize: 32),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                bias,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? AppColors.textDark
                                      : Colors.white,
                                ),
                              ),
                              if (bias != 'OT7')
                                Text(
                                  memberInfo['fullName']!,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isSelected
                                        ? AppColors.textMuted
                                        : Colors.white.withOpacity(0.7),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Preferred Language',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedLanguage,
                      isExpanded: true,
                      dropdownColor: AppColors.darkCard,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                      items: AppConstants.supportedLanguages.map((lang) {
                        return DropdownMenuItem<String>(
                          value: lang['code'],
                          child: Text('${lang['flag']} ${lang['name']}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedLanguage = value!;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                GradientButton(
                  onPressed: _continue,
                  text: 'Continue',
                  gradient: const LinearGradient(
                    colors: [Colors.white, Colors.white],
                  ),
                  textColor: AppColors.primaryPurple,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
