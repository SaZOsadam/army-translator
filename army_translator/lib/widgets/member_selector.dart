import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../config/constants.dart';

class MemberSelector extends StatelessWidget {
  final String? selectedMember;
  final ValueChanged<String?> onMemberSelected;
  final bool allowNone;

  const MemberSelector({
    super.key,
    this.selectedMember,
    required this.onMemberSelected,
    this.allowNone = true,
  });

  @override
  Widget build(BuildContext context) {
    final members = ['Unknown', ...AppConstants.members];

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: members.length,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemBuilder: (context, index) {
          final member = members[index];
          final isSelected = selectedMember == member ||
              (selectedMember == null && member == 'Unknown');

          return _MemberChip(
            member: member,
            isSelected: isSelected,
            onTap: () => onMemberSelected(member == 'Unknown' ? null : member),
          );
        },
      ),
    );
  }
}

class _MemberChip extends StatelessWidget {
  final String member;
  final bool isSelected;
  final VoidCallback onTap;

  const _MemberChip({
    required this.member,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.memberColors[member] ?? AppColors.textSecondary;
    final emoji = AppConstants.memberInfo[member]?['emoji'] ?? '❓';

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : AppColors.cardDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              member,
              style: TextStyle(
                color: isSelected ? color : Colors.white70,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MemberBadge extends StatelessWidget {
  final String member;
  final double size;

  const MemberBadge({
    super.key,
    required this.member,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.memberColors[member] ?? AppColors.textSecondary;
    final emoji = AppConstants.memberInfo[member]?['emoji'] ?? '💜';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: TextStyle(fontSize: size * 0.7)),
          const SizedBox(width: 4),
          Text(
            member,
            style: TextStyle(
              color: color,
              fontSize: size * 0.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
