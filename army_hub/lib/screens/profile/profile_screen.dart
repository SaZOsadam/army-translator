import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../config/constants.dart';
import '../../services/auth_service.dart';
import '../../services/supabase_service.dart';
import '../../models/user_model.dart';
import '../../models/theory_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();

  UserModel? _user;
  List<TheoryModel> _userTheories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final currentUser = _authService.currentUser;
    if (currentUser != null) {
      try {
        final userData = await _authService.getUserData(currentUser.id);
        final theoriesData = await SupabaseService.getUserTheories();
        final theories =
            theoriesData.map((e) => TheoryModel.fromJson(e)).toList();

        setState(() {
          _user = userData;
          _userTheories = theories;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _user = UserModel(
            uid: currentUser.id,
            email: currentUser.email ?? '',
            displayName: currentUser.userMetadata?['username'] ?? 'ARMY',
            bias: 'OT7',
            language: 'en',
            createdAt: DateTime.now(),
            theoriesGenerated: 0,
          );
          _isLoading = false;
        });
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_user == null) {
      return _buildNotSignedIn();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 24),
          _buildStatsCard(),
          const SizedBox(height: 24),
          _buildBadgesSection(),
          const SizedBox(height: 24),
          _buildTheoriesSection(),
          const SizedBox(height: 24),
          _buildActionsSection(),
        ],
      ),
    );
  }

  Widget _buildNotSignedIn() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('💜', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            'Sign in to view your profile',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    final memberInfo = AppConstants.memberInfo[_user!.bias];
    final memberColor =
        AppColors.memberColors[_user!.bias] ?? AppColors.primaryPurple;

    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: AppColors.purpleGradient,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryPurple.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: Text(
              memberInfo?['emoji'] ?? '💜',
              style: const TextStyle(fontSize: 48),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _user!.displayName,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: memberColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: memberColor.withOpacity(0.3)),
          ),
          child: Text(
            '${_user!.bias} stan',
            style: TextStyle(
              color: memberColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (_user!.isPremium) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              gradient: AppColors.goldGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('👑', style: TextStyle(fontSize: 14)),
                SizedBox(width: 4),
                Text(
                  'Premium ARMY',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('🔮', '${_user!.theoriesGenerated}', 'Theories'),
          _buildStatDivider(),
          _buildStatItem('🏆', '${_user!.badges.length}', 'Badges'),
          _buildStatDivider(),
          _buildStatItem('📊', '${_user!.predictions.length}', 'Predictions'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge,
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 50,
      color: AppColors.textMuted.withOpacity(0.2),
    );
  }

  Widget _buildBadgesSection() {
    final badges = [
      {
        'emoji': '🎖️',
        'name': 'First Theory',
        'unlocked': _user!.theoriesGenerated > 0
      },
      {
        'emoji': '🔥',
        'name': '10 Theories',
        'unlocked': _user!.theoriesGenerated >= 10
      },
      {'emoji': '💫', 'name': 'Trending', 'unlocked': false},
      {'emoji': '🏆', 'name': 'Top Predictor', 'unlocked': false},
      {'emoji': '💜', 'name': 'OG ARMY', 'unlocked': true},
      {'emoji': '👑', 'name': 'Premium', 'unlocked': _user!.isPremium},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Badges',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: badges.map((badge) {
            final unlocked = badge['unlocked'] as bool;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: unlocked
                    ? AppColors.primaryPurple.withOpacity(0.1)
                    : Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: unlocked
                      ? AppColors.primaryPurple.withOpacity(0.3)
                      : AppColors.textMuted.withOpacity(0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    badge['emoji'] as String,
                    style: TextStyle(
                      fontSize: 20,
                      color: unlocked ? null : Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    badge['name'] as String,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: unlocked
                          ? Theme.of(context).textTheme.bodyMedium?.color
                          : AppColors.textMuted,
                    ),
                  ),
                  if (!unlocked) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.lock,
                        size: 14, color: AppColors.textMuted),
                  ],
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTheoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your Theories',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton(
              onPressed: () {},
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_userTheories.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Column(
                children: [
                  const Text('🔮', style: TextStyle(fontSize: 40)),
                  const SizedBox(height: 8),
                  Text(
                    'No theories yet',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Generate your first ARIRANG theory!',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ],
              ),
            ),
          )
        else
          ...(_userTheories
              .take(3)
              .map((theory) => _buildTheoryPreview(theory))),
      ],
    );
  }

  Widget _buildTheoryPreview(TheoryModel theory) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            theory.output,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.favorite, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(
                '${theory.likes}',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(width: 16),
              Icon(Icons.share, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(
                '${theory.shares}',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection() {
    return Column(
      children: [
        _buildActionTile(
          icon: Icons.settings,
          title: 'Settings',
          onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
        ),
        _buildActionTile(
          icon: Icons.help_outline,
          title: 'Help & Support',
          onTap: () {},
        ),
        _buildActionTile(
          icon: Icons.favorite,
          title: 'Love Myself Campaign',
          subtitle: 'Support UNICEF',
          onTap: () {},
        ),
        const SizedBox(height: 8),
        _buildActionTile(
          icon: Icons.logout,
          title: 'Sign Out',
          color: AppColors.error,
          onTap: _signOut,
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (color ?? AppColors.primaryPurple).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color ?? AppColors.primaryPurple),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: Icon(
        Icons.chevron_right,
        color: color ?? AppColors.textMuted,
      ),
    );
  }
}
