import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../config/routes.dart';
import '../models/theory_model.dart';

class TheoryCard extends StatelessWidget {
  final TheoryModel theory;
  final VoidCallback? onLike;
  final VoidCallback? onShare;
  final bool showFullContent;

  const TheoryCard({
    super.key,
    required this.theory,
    this.onLike,
    this.onShare,
    this.showFullContent = false,
  });

  @override
  Widget build(BuildContext context) {
    final memberInfo = AppConstants.memberInfo[theory.bias];
    final memberColor = AppColors.memberColors[theory.bias] ?? AppColors.primaryPurple;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.theoryDetail,
          arguments: {'theoryId': theory.id},
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: memberColor.withOpacity(0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, memberInfo, memberColor),
            const SizedBox(height: 12),
            _buildContent(context),
            const SizedBox(height: 12),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    Map<String, String>? memberInfo,
    Color memberColor,
  ) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: memberColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              memberInfo?['emoji'] ?? '💜',
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                theory.userDisplayName,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              Text(
                '${theory.bias} stan • ${_formatDate(theory.createdAt)}',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontSize: 11,
                    ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            gradient: AppColors.purpleGradient,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🔮', style: TextStyle(fontSize: 12)),
              SizedBox(width: 4),
              Text(
                'AI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return Text(
      theory.output,
      maxLines: showFullContent ? null : 4,
      overflow: showFullContent ? null : TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            height: 1.5,
          ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      children: [
        _buildActionButton(
          context,
          icon: Icons.favorite_border,
          label: '${theory.likes}',
          onTap: onLike,
        ),
        const SizedBox(width: 16),
        _buildActionButton(
          context,
          icon: Icons.share_outlined,
          label: '${theory.shares}',
          onTap: onShare,
        ),
        const Spacer(),
        Text(
          'Read more →',
          style: TextStyle(
            color: AppColors.primaryPurple,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textMuted),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontSize: 12,
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
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';

    return '${date.month}/${date.day}';
  }
}
