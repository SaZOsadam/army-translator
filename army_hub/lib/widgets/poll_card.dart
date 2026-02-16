import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/poll_model.dart';

class PollCard extends StatelessWidget {
  final PollModel poll;
  final String? selectedOptionId;
  final ValueChanged<String>? onVote;

  const PollCard({
    super.key,
    required this.poll,
    this.selectedOptionId,
    this.onVote,
  });

  @override
  Widget build(BuildContext context) {
    final canVote = poll.status == PollStatus.active && 
                    !poll.isExpired && 
                    selectedOptionId == null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryPurple.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 12),
          Text(
            poll.question,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 16),
          ...poll.options.map((option) => _buildOption(
                context,
                option,
                canVote: canVote,
              )),
          const SizedBox(height: 12),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: poll.status == PollStatus.active
                ? AppColors.success.withOpacity(0.1)
                : AppColors.textMuted.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                poll.status == PollStatus.active
                    ? Icons.circle
                    : Icons.check_circle,
                size: 10,
                color: poll.status == PollStatus.active
                    ? AppColors.success
                    : AppColors.textMuted,
              ),
              const SizedBox(width: 4),
              Text(
                poll.status == PollStatus.active ? 'Active' : 'Closed',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: poll.status == PollStatus.active
                      ? AppColors.success
                      : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        if (poll.category != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              poll.category!,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryPurple,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildOption(
    BuildContext context,
    PollOption option, {
    required bool canVote,
  }) {
    final isSelected = selectedOptionId == option.id;
    final percentage = option.getPercentage(poll.totalVotes);
    final isWinner = poll.status == PollStatus.closed &&
        option.votes ==
            poll.options.map((o) => o.votes).reduce((a, b) => a > b ? a : b);

    return GestureDetector(
      onTap: canVote ? () => onVote?.call(option.id) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: Stack(
          children: [
            // Background
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryPurple.withOpacity(0.1)
                    : AppColors.textMuted.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryPurple
                      : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
            // Progress bar (only show if voted or closed)
            if (selectedOptionId != null || poll.status == PollStatus.closed)
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                height: 48,
                width: (MediaQuery.of(context).size.width - 64) *
                    (percentage / 100),
                decoration: BoxDecoration(
                  gradient: isWinner
                      ? AppColors.goldGradient
                      : AppColors.purpleGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            // Content
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  if (canVote)
                    Container(
                      width: 20,
                      height: 20,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primaryPurple,
                          width: 2,
                        ),
                      ),
                    ),
                  Expanded(
                    child: Text(
                      option.text,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: percentage > 50 &&
                                (selectedOptionId != null ||
                                    poll.status == PollStatus.closed)
                            ? Colors.white
                            : Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ),
                  if (isWinner)
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Text('👑', style: TextStyle(fontSize: 16)),
                    ),
                  if (selectedOptionId != null ||
                      poll.status == PollStatus.closed)
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: percentage > 50
                            ? Colors.white
                            : AppColors.primaryPurple,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.people_outline,
          size: 16,
          color: AppColors.textMuted,
        ),
        const SizedBox(width: 4),
        Text(
          '${poll.totalVotes} votes',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontSize: 12,
              ),
        ),
        const Spacer(),
        if (poll.status == PollStatus.active) ...[
          Icon(
            Icons.timer_outlined,
            size: 16,
            color: AppColors.textMuted,
          ),
          const SizedBox(width: 4),
          Text(
            _formatTimeRemaining(poll.timeRemaining),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontSize: 12,
                ),
          ),
        ],
      ],
    );
  }

  String _formatTimeRemaining(Duration duration) {
    if (duration.isNegative) return 'Ended';

    if (duration.inDays > 0) {
      return '${duration.inDays}d left';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h left';
    } else {
      return '${duration.inMinutes}m left';
    }
  }
}
