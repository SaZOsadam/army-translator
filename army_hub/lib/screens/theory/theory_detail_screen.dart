import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../services/supabase_service.dart';
import '../../models/theory_model.dart';

class TheoryDetailScreen extends StatefulWidget {
  final String theoryId;

  const TheoryDetailScreen({
    super.key,
    required this.theoryId,
  });

  @override
  State<TheoryDetailScreen> createState() => _TheoryDetailScreenState();
}

class _TheoryDetailScreenState extends State<TheoryDetailScreen> {
  TheoryModel? _theory;
  bool _isLoading = true;
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _loadTheory();
  }

  Future<void> _loadTheory() async {
    try {
      final data = await Supabase.instance.client
          .from('theories')
          .select()
          .eq('id', widget.theoryId)
          .maybeSingle();
      final theory = data != null ? TheoryModel.fromJson(data) : null;
      setState(() {
        _theory = theory;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load theory: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _likeTheory() async {
    if (_theory == null || _isLiked) return;

    try {
      await SupabaseService.likeTheory(widget.theoryId);
      setState(() {
        _isLiked = true;
        _theory = _theory!.copyWith(likes: _theory!.likes + 1);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to like theory'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _shareTheory() {
    if (_theory == null) return;

    final shareText = '''
🔮 ARIRANG Theory by ${_theory!.userDisplayName} 💜

${_theory!.output}

Generated with ARMY Hub App
#BTS #ARIRANG #BTSComeback #ARMY
''';

    Share.share(shareText);
  }

  void _copyTheory() {
    if (_theory == null) return;

    Clipboard.setData(ClipboardData(text: _theory!.output));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Theory copied to clipboard! 💜'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theory Details'),
        actions: [
          if (_theory != null) ...[
            IconButton(
              onPressed: _copyTheory,
              icon: const Icon(Icons.copy),
            ),
            IconButton(
              onPressed: _shareTheory,
              icon: const Icon(Icons.share),
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _theory == null
              ? _buildNotFound()
              : _buildTheoryContent(),
    );
  }

  Widget _buildNotFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔮', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            'Theory not found',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'This theory may have been deleted',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildTheoryContent() {
    final memberInfo = AppConstants.memberInfo[_theory!.bias];
    final memberColor =
        AppColors.memberColors[_theory!.bias] ?? AppColors.primaryPurple;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: memberColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: Text(
                    memberInfo?['emoji'] ?? '💜',
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _theory!.userDisplayName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    Text(
                      '${_theory!.bias} stan • ${_formatDate(_theory!.createdAt)}',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Input prompt
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: memberColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: memberColor.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_outline, size: 18, color: memberColor),
                    const SizedBox(width: 8),
                    Text(
                      'Original Prompt',
                      style: TextStyle(
                        color: memberColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _theory!.input,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Theory content
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primaryPurple.withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppColors.purpleGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('🔮', style: TextStyle(fontSize: 14)),
                          SizedBox(width: 6),
                          Text(
                            'AI Theory',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _theory!.output,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.7,
                      ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildActionButton(
                icon: _isLiked ? Icons.favorite : Icons.favorite_border,
                label: '${_theory!.likes}',
                color: _isLiked ? Colors.red : null,
                onTap: _likeTheory,
              ),
              const SizedBox(width: 24),
              _buildActionButton(
                icon: Icons.share,
                label: '${_theory!.shares}',
                onTap: _shareTheory,
              ),
              const SizedBox(width: 24),
              _buildActionButton(
                icon: Icons.copy,
                label: 'Copy',
                onTap: _copyTheory,
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Tags
          if (_theory!.tags.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _theory!.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '#$tag',
                    style: const TextStyle(
                      color: AppColors.primaryPurple,
                      fontSize: 13,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    Color? color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: (color ?? AppColors.primaryPurple).withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: color ?? AppColors.primaryPurple,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color ?? Theme.of(context).textTheme.labelLarge?.color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return '${date.month}/${date.day}/${date.year}';
  }
}
