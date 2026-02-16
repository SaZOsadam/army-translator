class TranscriptModel {
  final String id;
  final String sessionId;
  final DateTime timestamp;
  final String originalText;
  final String translatedText;
  final double confidence;
  final String? speaker;
  final int startMs;
  final int endMs;

  TranscriptModel({
    required this.id,
    required this.sessionId,
    required this.timestamp,
    required this.originalText,
    required this.translatedText,
    required this.confidence,
    this.speaker,
    required this.startMs,
    required this.endMs,
  });

  factory TranscriptModel.fromJson(Map<String, dynamic> data) {
    return TranscriptModel(
      id: data['id'] ?? '',
      sessionId: data['session_id'] ?? '',
      timestamp: data['timestamp'] != null
          ? DateTime.parse(data['timestamp'])
          : DateTime.now(),
      originalText: data['original_text'] ?? '',
      translatedText: data['translated_text'] ?? '',
      confidence: (data['confidence'] ?? 0.0).toDouble(),
      speaker: data['speaker'],
      startMs: data['start_ms'] ?? 0,
      endMs: data['end_ms'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'timestamp': timestamp.toIso8601String(),
      'original_text': originalText,
      'translated_text': translatedText,
      'confidence': confidence,
      'speaker': speaker,
      'start_ms': startMs,
      'end_ms': endMs,
    };
  }

  TranscriptModel copyWith({
    String? id,
    String? sessionId,
    DateTime? timestamp,
    String? originalText,
    String? translatedText,
    double? confidence,
    String? speaker,
    int? startMs,
    int? endMs,
  }) {
    return TranscriptModel(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      timestamp: timestamp ?? this.timestamp,
      originalText: originalText ?? this.originalText,
      translatedText: translatedText ?? this.translatedText,
      confidence: confidence ?? this.confidence,
      speaker: speaker ?? this.speaker,
      startMs: startMs ?? this.startMs,
      endMs: endMs ?? this.endMs,
    );
  }

  // Format as SRT subtitle entry
  String toSrt(int index) {
    final startTime = _formatSrtTime(startMs);
    final endTime = _formatSrtTime(endMs);
    return '$index\n$startTime --> $endTime\n$translatedText\n';
  }

  String _formatSrtTime(int ms) {
    final hours = (ms ~/ 3600000).toString().padLeft(2, '0');
    final minutes = ((ms % 3600000) ~/ 60000).toString().padLeft(2, '0');
    final seconds = ((ms % 60000) ~/ 1000).toString().padLeft(2, '0');
    final milliseconds = (ms % 1000).toString().padLeft(3, '0');
    return '$hours:$minutes:$seconds,$milliseconds';
  }

  // Confidence level
  String get confidenceLevel {
    if (confidence >= 0.9) return 'high';
    if (confidence >= 0.7) return 'medium';
    return 'low';
  }
}
