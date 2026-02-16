import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/subtitle_model.dart';
import '../models/session_model.dart';
import '../services/audio_service.dart';
import '../services/speech_to_text_service.dart';
import '../services/translation_service.dart';
import '../services/gpt_polish_service.dart';
import '../services/supabase_service.dart';

// Audio service provider
final audioServiceProvider = Provider<AudioService>((ref) {
  return AudioServiceProvider.instance;
});

// STT service provider
final sttServiceProvider = Provider<SpeechToTextService>((ref) {
  return SpeechToTextService();
});

// Translation service provider
final translationServiceProvider = Provider<TranslationService>((ref) {
  return TranslationService();
});

// GPT polish service provider
final gptPolishServiceProvider = Provider<GptPolishService>((ref) {
  return GptPolishService();
});

// Recording state
enum RecordingStatus { idle, recording, paused, processing }

class TranslationState {
  final RecordingStatus status;
  final List<SubtitleModel> subtitles;
  final Duration duration;
  final String? error;
  final SessionModel? currentSession;

  TranslationState({
    this.status = RecordingStatus.idle,
    this.subtitles = const [],
    this.duration = Duration.zero,
    this.error,
    this.currentSession,
  });

  TranslationState copyWith({
    RecordingStatus? status,
    List<SubtitleModel>? subtitles,
    Duration? duration,
    String? error,
    SessionModel? currentSession,
  }) {
    return TranslationState(
      status: status ?? this.status,
      subtitles: subtitles ?? this.subtitles,
      duration: duration ?? this.duration,
      error: error,
      currentSession: currentSession ?? this.currentSession,
    );
  }
}

class TranslationNotifier extends StateNotifier<TranslationState> {
  final AudioService _audioService;
  final SpeechToTextService _sttService;
  final TranslationService _translationService;
  final GptPolishService _gptPolishService;

  Timer? _durationTimer;
  int _subtitleCounter = 0;

  TranslationNotifier(
    this._audioService,
    this._sttService,
    this._translationService,
    this._gptPolishService,
  ) : super(TranslationState());

  Future<bool> startRecording() async {
    try {
      final started = await _audioService.startRecording();
      if (!started) {
        state = state.copyWith(error: 'Failed to start recording');
        return false;
      }

      state = state.copyWith(
        status: RecordingStatus.recording,
        subtitles: [],
        duration: Duration.zero,
        error: null,
      );

      _startDurationTimer();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  void _startDurationTimer() {
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.status == RecordingStatus.recording) {
        state = state.copyWith(
            duration: state.duration + const Duration(seconds: 1));
      }
    });
  }

  Future<void> pauseRecording() async {
    await _audioService.pauseRecording();
    state = state.copyWith(status: RecordingStatus.paused);
  }

  Future<void> resumeRecording() async {
    await _audioService.resumeRecording();
    state = state.copyWith(status: RecordingStatus.recording);
  }

  Future<void> stopRecording() async {
    _durationTimer?.cancel();
    await _audioService.stopRecording();
    state = state.copyWith(status: RecordingStatus.idle);
  }

  Future<void> processAudioChunk(Uint8List audioData) async {
    try {
      state = state.copyWith(status: RecordingStatus.processing);

      // Step 1: Speech-to-text
      final sttResult = await _sttService.transcribe(audioData);
      if (sttResult.text.isEmpty) {
        state = state.copyWith(status: RecordingStatus.recording);
        return;
      }

      // Step 2: Translation
      final translationResult = await _translationService.translate(
        sttResult.text,
        from: 'ko',
        to: 'en',
      );

      // Step 3: GPT Polish (optional)
      final String finalTranslation = translationResult.translatedText;
      // final polished = await _gptPolishService.polishTranslation(
      //   originalKorean: sttResult.text,
      //   roughTranslation: translationResult.translatedText,
      // );
      // finalTranslation = polished;

      // Create subtitle
      final startMs = state.duration.inMilliseconds;
      final subtitle = SubtitleModel(
        id: '${_subtitleCounter++}',
        originalText: sttResult.text,
        translatedText: finalTranslation,
        startMs: startMs,
        endMs: startMs + sttResult.durationMs,
        confidence: sttResult.confidence,
        isActive: true,
      );

      // Update state
      state = state.copyWith(
        status: RecordingStatus.recording,
        subtitles: [...state.subtitles, subtitle],
      );
    } catch (e) {
      state = state.copyWith(
        status: RecordingStatus.recording,
        error: e.toString(),
      );
    }
  }

  void addSubtitle(SubtitleModel subtitle) {
    state = state.copyWith(
      subtitles: [...state.subtitles, subtitle],
    );
  }

  void clearSubtitles() {
    state = state.copyWith(subtitles: []);
    _subtitleCounter = 0;
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final translationProvider =
    StateNotifierProvider<TranslationNotifier, TranslationState>((ref) {
  return TranslationNotifier(
    ref.watch(audioServiceProvider),
    ref.watch(sttServiceProvider),
    ref.watch(translationServiceProvider),
    ref.watch(gptPolishServiceProvider),
  );
});

// Convenience providers
final isRecordingProvider = Provider<bool>((ref) {
  final state = ref.watch(translationProvider);
  return state.status == RecordingStatus.recording;
});

final subtitlesProvider = Provider<List<SubtitleModel>>((ref) {
  return ref.watch(translationProvider).subtitles;
});

final recordingDurationProvider = Provider<Duration>((ref) {
  return ref.watch(translationProvider).duration;
});
