import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/subtitle_model.dart';

class SubtitleDisplay extends StatelessWidget {
  final List<SubtitleModel> subtitles;
  final bool showOriginal;
  final double fontSize;

  const SubtitleDisplay({
    super.key,
    required this.subtitles,
    this.showOriginal = true,
    this.fontSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    if (subtitles.isEmpty) return const SizedBox();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      reverse: true,
      itemCount: subtitles.length,
      itemBuilder: (context, index) {
        final subtitle = subtitles[subtitles.length - 1 - index];
        return _SubtitleItem(
          subtitle: subtitle,
          showOriginal: showOriginal,
          fontSize: fontSize,
          isLatest: index == 0,
        );
      },
    );
  }
}

class _SubtitleItem extends StatelessWidget {
  final SubtitleModel subtitle;
  final bool showOriginal;
  final double fontSize;
  final bool isLatest;

  const _SubtitleItem({
    required this.subtitle,
    required this.showOriginal,
    required this.fontSize,
    required this.isLatest,
  });

  @override
  Widget build(BuildContext context) {
    final memberColor = subtitle.speaker != null
        ? AppColors.memberColors[subtitle.speaker] ?? Colors.white
        : Colors.white;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isLatest ? 1.0 : 0.6,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.subtitleBg,
          borderRadius: BorderRadius.circular(12),
          border: isLatest
              ? Border.all(color: AppColors.primaryPurple.withOpacity(0.5))
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Speaker & timestamp
            Row(
              children: [
                if (subtitle.speaker != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: memberColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      subtitle.speaker!,
                      style: TextStyle(
                        color: memberColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  subtitle.timestampFormatted,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 11,
                  ),
                ),
                const Spacer(),
                _buildConfidenceIndicator(),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Original Korean text
            if (showOriginal) ...[
              Text(
                subtitle.originalText,
                style: TextStyle(
                  color: AppColors.koreanText,
                  fontSize: fontSize * 0.85,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 4),
            ],
            
            // Translated text
            Text(
              subtitle.translatedText,
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfidenceIndicator() {
    Color color;
    if (subtitle.confidence >= 0.9) {
      color = AppColors.confidenceHigh;
    } else if (subtitle.confidence >= 0.7) {
      color = AppColors.confidenceMedium;
    } else {
      color = AppColors.confidenceLow;
    }

    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '${(subtitle.confidence * 100).toInt()}%',
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class LiveSubtitleOverlay extends StatelessWidget {
  final SubtitleModel? currentSubtitle;
  final bool showOriginal;
  final double fontSize;

  const LiveSubtitleOverlay({
    super.key,
    this.currentSubtitle,
    this.showOriginal = true,
    this.fontSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    if (currentSubtitle == null) return const SizedBox();

    return Positioned(
      bottom: 100,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.subtitleBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            if (showOriginal)
              Text(
                currentSubtitle!.originalText,
                style: TextStyle(
                  color: AppColors.koreanText,
                  fontSize: fontSize * 0.8,
                ),
                textAlign: TextAlign.center,
              ),
            if (showOriginal) const SizedBox(height: 8),
            Text(
              currentSubtitle!.translatedText,
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
