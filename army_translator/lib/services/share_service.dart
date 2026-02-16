import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../models/subtitle_model.dart';
import '../models/session_model.dart';

class ShareService {
  static const String appHashtag = '#ARMYTranslator';
  static const String btsHashtags = '#BTS #ARMY #방탄소년단';

  /// Share a single subtitle line
  static Future<void> shareSubtitle(SubtitleModel subtitle) async {
    final text = _buildSubtitleShareText(subtitle);
    await Share.share(text);
  }

  /// Share multiple subtitles as a thread
  static Future<void> shareSubtitles(List<SubtitleModel> subtitles, {String? sessionTitle}) async {
    final text = _buildMultipleSubtitlesText(subtitles, sessionTitle: sessionTitle);
    await Share.share(text);
  }

  /// Share session summary
  static Future<void> shareSession(SessionModel session, List<SubtitleModel> subtitles) async {
    final text = _buildSessionShareText(session, subtitles);
    await Share.share(text);
  }

  /// Share as image (for Instagram stories)
  static Future<void> shareAsImage({
    required String koreanText,
    required String englishText,
    String? speaker,
  }) async {
    // Create a shareable text since we can't generate images
    final text = '''
🎤 ${ speaker ?? 'BTS' }

🇰🇷 $koreanText

🇺🇸 $englishText

$appHashtag $btsHashtags
''';
    await Share.share(text);
  }

  /// Share SRT file
  static Future<void> shareSrtFile(List<SubtitleModel> subtitles, String filename) async {
    final srtContent = SubtitleExporter.toSrt(subtitles);
    final file = await _createTempFile('$filename.srt', srtContent);
    await Share.shareXFiles([XFile(file.path)], text: 'Subtitles from $appHashtag');
  }

  /// Share to specific platform
  static Future<void> shareToTwitter(String text) async {
    final twitterText = _truncateForTwitter(text);
    await Share.share(twitterText);
  }

  /// Build share text for a single subtitle
  static String _buildSubtitleShareText(SubtitleModel subtitle) {
    final speaker = subtitle.speaker != null ? '🎤 ${subtitle.speaker}\n\n' : '';
    return '''
$speaker🇰🇷 ${subtitle.originalText}

🇺🇸 ${subtitle.translatedText}

$appHashtag $btsHashtags 💜
''';
  }

  /// Build share text for multiple subtitles
  static String _buildMultipleSubtitlesText(List<SubtitleModel> subtitles, {String? sessionTitle}) {
    final buffer = StringBuffer();
    
    if (sessionTitle != null) {
      buffer.writeln('📺 $sessionTitle\n');
    }
    
    for (int i = 0; i < subtitles.length && i < 10; i++) {
      final sub = subtitles[i];
      if (sub.speaker != null) {
        buffer.writeln('🎤 ${sub.speaker}');
      }
      buffer.writeln('🇰🇷 ${sub.originalText}');
      buffer.writeln('🇺🇸 ${sub.translatedText}');
      buffer.writeln();
    }
    
    if (subtitles.length > 10) {
      buffer.writeln('... and ${subtitles.length - 10} more lines');
      buffer.writeln();
    }
    
    buffer.writeln('$appHashtag $btsHashtags 💜');
    
    return buffer.toString();
  }

  /// Build share text for a session
  static String _buildSessionShareText(SessionModel session, List<SubtitleModel> subtitles) {
    final topSubtitles = subtitles.take(5).toList();
    
    return '''
📺 ${session.title}
⏱️ ${session.formattedDuration} | 💬 ${session.transcriptCount} lines

${_buildMultipleSubtitlesText(topSubtitles)}

Translated with $appHashtag 💜
$btsHashtags
''';
  }

  /// Truncate text for Twitter's character limit
  static String _truncateForTwitter(String text) {
    const maxLength = 280;
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - 3)}...';
  }

  /// Create temporary file for sharing
  static Future<File> _createTempFile(String filename, String content) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$filename');
    await file.writeAsString(content);
    return file;
  }
}

/// Share bottom sheet widget
class ShareBottomSheet extends StatelessWidget {
  final String koreanText;
  final String englishText;
  final String? speaker;
  final VoidCallback? onClose;

  const ShareBottomSheet({
    super.key,
    required this.koreanText,
    required this.englishText,
    this.speaker,
    this.onClose,
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
          Row(
            children: [
              const Text(
                'Share Translation',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: onClose ?? () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white54),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Preview
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (speaker != null)
                  Text(
                    '🎤 $speaker',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                const SizedBox(height: 8),
                Text(
                  '🇰🇷 $koreanText',
                  style: const TextStyle(color: Color(0xFFE0B0FF), fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  '🇺🇸 $englishText',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Share options
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildShareOption(
                context,
                icon: Icons.share,
                label: 'Share',
                color: const Color(0xFFA020F0),
                onTap: () {
                  ShareService.shareAsImage(
                    koreanText: koreanText,
                    englishText: englishText,
                    speaker: speaker,
                  );
                  Navigator.pop(context);
                },
              ),
              _buildShareOption(
                context,
                icon: Icons.copy,
                label: 'Copy',
                color: Colors.blue,
                onTap: () {
                  // Copy to clipboard handled elsewhere
                  Navigator.pop(context);
                },
              ),
              _buildShareOption(
                context,
                icon: Icons.download,
                label: 'Save',
                color: Colors.green,
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildShareOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
