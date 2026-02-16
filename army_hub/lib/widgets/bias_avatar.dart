import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../config/constants.dart';

class BiasAvatar extends StatelessWidget {
  final String bias;
  final double size;
  final bool showName;
  final bool isSelected;
  final VoidCallback? onTap;

  const BiasAvatar({
    super.key,
    required this.bias,
    this.size = 60,
    this.showName = false,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final memberInfo = AppConstants.memberInfo[bias];
    final color = AppColors.memberColors[bias] ?? AppColors.primaryPurple;
    final emoji = memberInfo?['emoji'] ?? '💜';

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: isSelected ? color : color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(size * 0.3),
              border: Border.all(
                color: isSelected ? color : Colors.transparent,
                width: 3,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                emoji,
                style: TextStyle(fontSize: size * 0.5),
              ),
            ),
          ),
          if (showName) ...[
            const SizedBox(height: 8),
            Text(
              bias,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? color : null,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class BiasAvatarRow extends StatelessWidget {
  final String selectedBias;
  final ValueChanged<String> onBiasSelected;
  final double avatarSize;
  final bool showNames;

  const BiasAvatarRow({
    super.key,
    required this.selectedBias,
    required this.onBiasSelected,
    this.avatarSize = 50,
    this.showNames = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: showNames ? avatarSize + 30 : avatarSize,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: AppConstants.biasOptions.length,
        itemBuilder: (context, index) {
          final bias = AppConstants.biasOptions[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: BiasAvatar(
              bias: bias,
              size: avatarSize,
              showName: showNames,
              isSelected: selectedBias == bias,
              onTap: () => onBiasSelected(bias),
            ),
          );
        },
      ),
    );
  }
}
