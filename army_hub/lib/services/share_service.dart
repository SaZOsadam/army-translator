import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../models/theory_model.dart';

class ShareService {
  static const String appHashtag = '#ARMYHub';
  static const String btsHashtags = '#BTS #ARMY #ARIRANG #방탄소년단';

  /// Share a theory to social media
  static Future<void> shareTheory(TheoryModel theory) async {
    final text = _buildTheoryShareText(theory);
    await Share.share(text);
  }

  /// Share theory as a card preview
  static Future<void> shareTheoryCard(TheoryModel theory, {String? username}) async {
    final text = '''
🔮 BTS THEORY by ${username ?? 'ARMY'}

💭 "${theory.prompt}"

🤖 AI Analysis:
${_truncate(theory.output, 500)}

What do you think? 👇

$appHashtag $btsHashtags 💜
''';
    await Share.share(text);
  }

  /// Share countdown milestone
  static Future<void> shareCountdownMilestone({
    required int daysLeft,
    required String albumName,
  }) async {
    final emoji = _getMilestoneEmoji(daysLeft);
    final text = '''
$emoji $daysLeft DAYS until $albumName! $emoji

The wait is almost over, ARMY! 💜

$appHashtag $btsHashtags
#${albumName.replaceAll(' ', '')}
''';
    await Share.share(text);
  }

  /// Share poll result
  static Future<void> sharePollResult({
    required String question,
    required String winningOption,
    required int percentage,
  }) async {
    final text = '''
📊 ARMY POLL RESULTS

❓ $question

🏆 Winner: $winningOption ($percentage%)

What's your prediction?

$appHashtag $btsHashtags 💜
''';
    await Share.share(text);
  }

  /// Share leaderboard achievement
  static Future<void> shareLeaderboardRank({
    required int rank,
    required int points,
    required String username,
  }) async {
    final medal = _getRankMedal(rank);
    final text = '''
$medal Ranked #$rank on ARMY Hub!

🎯 $points points
👤 $username

Join the community and compete with fellow ARMY! 💜

$appHashtag $btsHashtags
''';
    await Share.share(text);
  }

  /// Build share text for theory
  static String _buildTheoryShareText(TheoryModel theory) {
    return '''
🔮 BTS THEORY

💭 ${theory.prompt}

🤖 ${_truncate(theory.output, 400)}

$appHashtag $btsHashtags 💜
''';
  }

  /// Get milestone emoji based on days left
  static String _getMilestoneEmoji(int daysLeft) {
    if (daysLeft <= 1) return '🎉';
    if (daysLeft <= 7) return '🔥';
    if (daysLeft <= 30) return '⏰';
    return '📅';
  }

  /// Get rank medal
  static String _getRankMedal(int rank) {
    switch (rank) {
      case 1: return '🥇';
      case 2: return '🥈';
      case 3: return '🥉';
      default: return '🏅';
    }
  }

  /// Truncate text
  static String _truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}

/// Share theory bottom sheet
class ShareTheorySheet extends StatelessWidget {
  final TheoryModel theory;
  final String? username;

  const ShareTheorySheet({
    super.key,
    required this.theory,
    this.username,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Share Theory',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          
          // Preview
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFA020F0).withOpacity(0.2),
                  const Color(0xFF6739C6).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFA020F0).withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('🔮', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 8),
                    const Text(
                      'BTS THEORY',
                      style: TextStyle(
                        color: Color(0xFFA020F0),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'by ${username ?? 'ARMY'}',
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  theory.prompt,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  theory.output,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Share options
          Row(
            children: [
              Expanded(
                child: _ShareButton(
                  icon: Icons.share,
                  label: 'Share',
                  onTap: () {
                    ShareService.shareTheory(theory);
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ShareButton(
                  icon: Icons.card_giftcard,
                  label: 'Share Card',
                  onTap: () {
                    ShareService.shareTheoryCard(theory, username: username);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _ShareButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ShareButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFA020F0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Share countdown milestone sheet
class ShareCountdownSheet extends StatelessWidget {
  final int daysLeft;
  final String albumName;

  const ShareCountdownSheet({
    super.key,
    required this.daysLeft,
    required this.albumName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            daysLeft <= 7 ? '🔥' : '⏰',
            style: const TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 16),
          Text(
            '$daysLeft DAYS',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          Text(
            'until $albumName',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ShareService.shareCountdownMilestone(
                  daysLeft: daysLeft,
                  albumName: albumName,
                );
                Navigator.pop(context);
              },
              icon: const Icon(Icons.share),
              label: const Text('Share with ARMY'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA020F0),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
