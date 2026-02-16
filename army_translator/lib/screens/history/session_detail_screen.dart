import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/theme.dart';
import '../../models/session_model.dart';
import '../../models/transcript_model.dart';
import '../../services/supabase_service.dart';
import '../../services/export_service.dart';
import '../../models/subtitle_model.dart';

class SessionDetailScreen extends StatefulWidget {
  final String sessionId;

  const SessionDetailScreen({super.key, required this.sessionId});

  @override
  State<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends State<SessionDetailScreen> {
  final ExportService _exportService = ExportService();
  SessionModel? _session;
  List<TranscriptModel> _transcripts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    setState(() => _isLoading = true);

    try {
      final sessionData = await SupabaseService.getSession(widget.sessionId);
      final transcriptsData =
          await SupabaseService.getSessionSubtitles(widget.sessionId);

      setState(() {
        _session =
            sessionData != null ? SessionModel.fromJson(sessionData) : null;
        _transcripts =
            transcriptsData.map((e) => TranscriptModel.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _showExportDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildExportSheet(),
    );
  }

  Future<void> _exportAs(ExportFormat format) async {
    final subtitles = _transcripts
        .map((t) => SubtitleModel(
              id: t.id,
              originalText: t.originalText,
              translatedText: t.translatedText,
              startMs: t.startMs,
              endMs: t.endMs,
              confidence: t.confidence,
              speaker: t.speaker,
            ))
        .toList();

    final filename = _session?.title ?? 'session';
    final path =
        await _exportService.exportSubtitles(subtitles, filename, format);

    if (path != null && mounted) {
      await _exportService.shareFile(path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        title: Text(_session?.title ?? 'Session'),
        actions: [
          IconButton(
            onPressed: _showExportDialog,
            icon: const Icon(Icons.download_outlined),
          ),
          IconButton(
            onPressed: () {
              final text = _transcripts.map((t) => t.translatedText).join('\n');
              Clipboard.setData(ClipboardData(text: text));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied to clipboard')),
              );
            },
            icon: const Icon(Icons.copy),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _transcripts.isEmpty
              ? _buildEmptyState()
              : _buildContent(),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        'No transcripts in this session',
        style: TextStyle(color: Colors.white70),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        _buildSessionInfo(),
        Expanded(child: _buildTranscriptList()),
      ],
    );
  }

  Widget _buildSessionInfo() {
    if (_session == null) return const SizedBox();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem(Icons.timer, _session!.formattedDuration),
          _buildInfoItem(
              Icons.chat_bubble, '${_session!.transcriptCount} lines'),
          _buildInfoItem(
              Icons.translate, _session!.targetLanguage.toUpperCase()),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primaryPurple),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: Colors.white)),
      ],
    );
  }

  Widget _buildTranscriptList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _transcripts.length,
      itemBuilder: (context, index) {
        return _buildTranscriptItem(_transcripts[index]);
      },
    );
  }

  Widget _buildTranscriptItem(TranscriptModel transcript) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (transcript.speaker != null) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurple.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    transcript.speaker!,
                    style: const TextStyle(
                      color: AppColors.primaryPurple,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                _formatTime(transcript.startMs),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            transcript.originalText,
            style: const TextStyle(
              color: AppColors.koreanText,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            transcript.translatedText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportSheet() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Export',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
          const SizedBox(height: 16),
          ListTile(
            leading:
                const Icon(Icons.subtitles, color: AppColors.primaryPurple),
            title:
                const Text('SRT File', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              _exportAs(ExportFormat.srt);
            },
          ),
          ListTile(
            leading:
                const Icon(Icons.text_snippet, color: AppColors.primaryPurple),
            title:
                const Text('Text File', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              _exportAs(ExportFormat.txt);
            },
          ),
          ListTile(
            leading:
                const Icon(Icons.translate, color: AppColors.primaryPurple),
            title:
                const Text('Bilingual', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              _exportAs(ExportFormat.bilingual);
            },
          ),
        ],
      ),
    );
  }

  String _formatTime(int ms) {
    final minutes = (ms ~/ 60000).toString().padLeft(2, '0');
    final seconds = ((ms % 60000) ~/ 1000).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
