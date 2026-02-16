import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import '../config/constants.dart';

enum RecordingState {
  idle,
  recording,
  paused,
  processing,
}

class AudioService {
  final AudioRecorder _recorder = AudioRecorder();
  StreamController<Uint8List>? _audioStreamController;
  Timer? _chunkTimer;
  bool _isRecording = false;
  DateTime? _recordingStartTime;

  // Stream of audio chunks for processing
  Stream<Uint8List>? get audioStream => _audioStreamController?.stream;
  
  bool get isRecording => _isRecording;
  
  Duration get recordingDuration {
    if (_recordingStartTime == null) return Duration.zero;
    return DateTime.now().difference(_recordingStartTime!);
  }

  Future<bool> requestPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<bool> hasPermission() async {
    return await Permission.microphone.isGranted;
  }

  Future<bool> startRecording() async {
    try {
      // Check permission
      if (!await hasPermission()) {
        final granted = await requestPermission();
        if (!granted) {
          debugPrint('Microphone permission not granted');
          return false;
        }
      }

      // Check if recorder is available
      if (!await _recorder.hasPermission()) {
        debugPrint('Recorder does not have permission');
        return false;
      }

      // Initialize stream controller
      _audioStreamController = StreamController<Uint8List>.broadcast();

      // Configure recording
      const config = RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: AppConstants.sampleRate,
        numChannels: AppConstants.audioChannels,
      );

      // Start recording to stream
      final stream = await _recorder.startStream(config);
      
      _isRecording = true;
      _recordingStartTime = DateTime.now();

      // Listen to audio stream and forward chunks
      stream.listen(
        (data) {
          _audioStreamController?.add(data);
        },
        onError: (error) {
          debugPrint('Audio stream error: $error');
          _audioStreamController?.addError(error);
        },
        onDone: () {
          debugPrint('Audio stream done');
        },
      );

      debugPrint('Recording started');
      return true;
    } catch (e) {
      debugPrint('Error starting recording: $e');
      return false;
    }
  }

  Future<void> stopRecording() async {
    try {
      _isRecording = false;
      _chunkTimer?.cancel();
      
      await _recorder.stop();
      await _audioStreamController?.close();
      _audioStreamController = null;
      _recordingStartTime = null;
      
      debugPrint('Recording stopped');
    } catch (e) {
      debugPrint('Error stopping recording: $e');
    }
  }

  Future<void> pauseRecording() async {
    try {
      await _recorder.pause();
      debugPrint('Recording paused');
    } catch (e) {
      debugPrint('Error pausing recording: $e');
    }
  }

  Future<void> resumeRecording() async {
    try {
      await _recorder.resume();
      debugPrint('Recording resumed');
    } catch (e) {
      debugPrint('Error resuming recording: $e');
    }
  }

  Future<void> dispose() async {
    await stopRecording();
    _recorder.dispose();
  }

  // Get amplitude for waveform visualization
  Future<double> getAmplitude() async {
    try {
      final amplitude = await _recorder.getAmplitude();
      // Normalize to 0-1 range
      final normalized = (amplitude.current + 60) / 60;
      return normalized.clamp(0.0, 1.0);
    } catch (e) {
      return 0.0;
    }
  }
}

// Singleton instance
class AudioServiceProvider {
  static final AudioService _instance = AudioService();
  static AudioService get instance => _instance;
}
