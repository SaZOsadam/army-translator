import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../services/audio_service.dart';
import '../../widgets/subtitle_display.dart';
import '../../widgets/audio_waveform.dart';
import '../../models/subtitle_model.dart';

class LiveViewScreen extends StatefulWidget {
  const LiveViewScreen({super.key});

  @override
  State<LiveViewScreen> createState() => _LiveViewScreenState();
}

class _LiveViewScreenState extends State<LiveViewScreen> {
  final AudioService _audioService = AudioServiceProvider.instance;
  final List<SubtitleModel> _subtitles = [];
  bool _isRecording = false;
  bool _isPaused = false;
  bool _showOriginal = true;
  Duration _duration = Duration.zero;
  Timer? _durationTimer;
  String? _currentSpeaker;

  @override
  void initState() {
    super.initState();
    _startRecording();
  }

  @override
  void dispose() {
    _stopRecording();
    _durationTimer?.cancel();
    super.dispose();
  }

  Future<void> _startRecording() async {
    final started = await _audioService.startRecording();
    
    if (started) {
      setState(() {
        _isRecording = true;
        _isPaused = false;
      });
      
      _startDurationTimer();
      
      // TODO: Connect to translation pipeline
      // _audioService.audioStream?.listen(_processAudioChunk);
      
      // Add sample subtitles for demo
      _addDemoSubtitles();
    } else {
      // Show permission error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Microphone permission required'),
            backgroundColor: AppColors.confidenceLow,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  void _startDurationTimer() {
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isRecording && !_isPaused) {
        setState(() {
          _duration += const Duration(seconds: 1);
        });
      }
    });
  }

  Future<void> _togglePause() async {
    if (_isPaused) {
      await _audioService.resumeRecording();
    } else {
      await _audioService.pauseRecording();
    }
    
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  Future<void> _stopRecording() async {
    _durationTimer?.cancel();
    await _audioService.stopRecording();
    
    setState(() {
      _isRecording = false;
    });
  }

  void _addDemoSubtitles() {
    // Demo subtitles for testing UI
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _isRecording) {
        setState(() {
          _subtitles.add(SubtitleModel(
            id: '1',
            originalText: '안녕하세요 아미 여러분',
            translatedText: 'Hello ARMY everyone',
            startMs: 0,
            endMs: 3000,
            confidence: 0.95,
            speaker: 'RM',
            isActive: true,
          ));
        });
      }
    });

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _isRecording) {
        setState(() {
          _subtitles.add(SubtitleModel(
            id: '2',
            originalText: '오늘 뭐 했어요?',
            translatedText: 'What did you do today?',
            startMs: 3000,
            endMs: 5000,
            confidence: 0.92,
            speaker: 'Jimin',
            isActive: true,
          ));
        });
      }
    });

    Future.delayed(const Duration(seconds: 8), () {
      if (mounted && _isRecording) {
        setState(() {
          _subtitles.add(SubtitleModel(
            id: '3',
            originalText: '보라해',
            translatedText: 'I purple you 💜',
            startMs: 5000,
            endMs: 7000,
            confidence: 0.98,
            speaker: 'V',
            isActive: true,
          ));
        });
      }
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildSubtitleArea(),
            ),
            _buildControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              _stopRecording();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close, color: Colors.white),
          ),
          const SizedBox(width: 8),
          
          // Recording indicator
          if (_isRecording)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _isPaused 
                    ? AppColors.confidenceMedium.withOpacity(0.2)
                    : AppColors.recording.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _isPaused 
                          ? AppColors.confidenceMedium 
                          : AppColors.recording,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isPaused ? 'PAUSED' : 'LIVE',
                    style: TextStyle(
                      color: _isPaused 
                          ? AppColors.confidenceMedium 
                          : AppColors.recording,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          
          const Spacer(),
          
          // Duration
          Text(
            _formatDuration(_duration),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Settings
          IconButton(
            onPressed: () {
              setState(() => _showOriginal = !_showOriginal);
            },
            icon: Icon(
              _showOriginal 
                  ? Icons.subtitles 
                  : Icons.subtitles_outlined,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitleArea() {
    return Stack(
      children: [
        // Waveform background
        if (_isRecording && !_isPaused)
          Positioned.fill(
            child: Opacity(
              opacity: 0.3,
              child: AudioWaveform(
                isActive: _isRecording && !_isPaused,
              ),
            ),
          ),
        
        // Subtitles
        Positioned.fill(
          child: SubtitleDisplay(
            subtitles: _subtitles,
            showOriginal: _showOriginal,
          ),
        ),
        
        // Empty state
        if (_subtitles.isEmpty)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '🎤',
                  style: TextStyle(fontSize: 60),
                ),
                const SizedBox(height: 16),
                Text(
                  _isRecording 
                      ? 'Listening for Korean speech...'
                      : 'Ready to translate',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildMemberSelector() {
    final members = [
      {'name': 'RM', 'emoji': '🐨'},
      {'name': 'Jin', 'emoji': '🐹'},
      {'name': 'SUGA', 'emoji': '😺'},
      {'name': 'J-Hope', 'emoji': '🐿️'},
      {'name': 'Jimin', 'emoji': '🐥'},
      {'name': 'V', 'emoji': '🐯'},
      {'name': 'Jungkook', 'emoji': '🐰'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Text(
            'Who\'s speaking?',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: members.map((member) {
              final isSelected = _currentSpeaker == member['name'];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _currentSpeaker = isSelected ? null : member['name'];
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppColors.primaryPurple.withOpacity(0.3)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected 
                        ? Border.all(color: AppColors.primaryPurple, width: 2)
                        : null,
                  ),
                  child: Column(
                    children: [
                      Text(
                        member['emoji']!,
                        style: const TextStyle(fontSize: 28),
                      ),
                      if (isSelected)
                        Text(
                          member['name']!,
                          style: const TextStyle(
                            color: AppColors.primaryPurple,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.8),
            Colors.black,
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMemberSelector(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Export button
              _buildControlButton(
                icon: Icons.download_outlined,
                label: 'Export',
                onTap: _showExportDialog,
              ),
              
              // Main recording button
              GestureDetector(
                onTap: _togglePause,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: _isPaused 
                        ? AppColors.purpleGradient 
                        : AppColors.recordingGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (_isPaused 
                            ? AppColors.primaryPurple 
                            : AppColors.recording).withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isPaused ? Icons.play_arrow : Icons.pause,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
              
              // Stop button
              _buildControlButton(
                icon: Icons.stop,
                label: 'Stop',
                onTap: () {
                  _stopRecording();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: AppColors.cardDark,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
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
          const Text(
            'Export Subtitles',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          _buildExportOption(
            icon: Icons.subtitles,
            title: 'SRT File',
            subtitle: 'Standard subtitle format',
            onTap: () {
              Navigator.pop(context);
              // Export as SRT
            },
          ),
          _buildExportOption(
            icon: Icons.text_snippet,
            title: 'Text File',
            subtitle: 'Plain text with timestamps',
            onTap: () {
              Navigator.pop(context);
              // Export as TXT
            },
          ),
          _buildExportOption(
            icon: Icons.translate,
            title: 'Bilingual',
            subtitle: 'Korean + English side by side',
            onTap: () {
              Navigator.pop(context);
              // Export bilingual
            },
          ),
          _buildExportOption(
            icon: Icons.copy,
            title: 'Copy to Clipboard',
            subtitle: 'Copy all translations',
            onTap: () {
              Navigator.pop(context);
              final text = _subtitles
                  .map((s) => s.translatedText)
                  .join('\n');
              Clipboard.setData(ClipboardData(text: text));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied to clipboard')),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildExportOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.primaryPurple.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primaryPurple),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.white.withOpacity(0.5),
          fontSize: 12,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.white.withOpacity(0.3),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
