class SubtitleModel {
  final String id;
  final String originalText;
  final String translatedText;
  final int startMs;
  final int endMs;
  final double confidence;
  final String? speaker;
  final bool isActive;

  SubtitleModel({
    required this.id,
    required this.originalText,
    required this.translatedText,
    required this.startMs,
    required this.endMs,
    required this.confidence,
    this.speaker,
    this.isActive = false,
  });

  SubtitleModel copyWith({
    String? id,
    String? originalText,
    String? translatedText,
    int? startMs,
    int? endMs,
    double? confidence,
    String? speaker,
    bool? isActive,
  }) {
    return SubtitleModel(
      id: id ?? this.id,
      originalText: originalText ?? this.originalText,
      translatedText: translatedText ?? this.translatedText,
      startMs: startMs ?? this.startMs,
      endMs: endMs ?? this.endMs,
      confidence: confidence ?? this.confidence,
      speaker: speaker ?? this.speaker,
      isActive: isActive ?? this.isActive,
    );
  }

  // Duration of this subtitle
  int get durationMs => endMs - startMs;

  // Format timestamp for display
  String get timestampFormatted {
    final minutes = (startMs ~/ 60000).toString().padLeft(2, '0');
    final seconds = ((startMs % 60000) ~/ 1000).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  // Convert to SRT format
  String toSrtEntry(int index) {
    return '''$index
${_formatSrtTimestamp(startMs)} --> ${_formatSrtTimestamp(endMs)}
$translatedText

''';
  }

  String _formatSrtTimestamp(int ms) {
    final hours = (ms ~/ 3600000).toString().padLeft(2, '0');
    final minutes = ((ms % 3600000) ~/ 60000).toString().padLeft(2, '0');
    final seconds = ((ms % 60000) ~/ 1000).toString().padLeft(2, '0');
    final milliseconds = (ms % 1000).toString().padLeft(3, '0');
    return '$hours:$minutes:$seconds,$milliseconds';
  }

  // Convert to VTT format
  String toVttEntry(int index) {
    return '''$index
${_formatVttTimestamp(startMs)} --> ${_formatVttTimestamp(endMs)}
$translatedText

''';
  }

  String _formatVttTimestamp(int ms) {
    final hours = (ms ~/ 3600000).toString().padLeft(2, '0');
    final minutes = ((ms % 3600000) ~/ 60000).toString().padLeft(2, '0');
    final seconds = ((ms % 60000) ~/ 1000).toString().padLeft(2, '0');
    final milliseconds = (ms % 1000).toString().padLeft(3, '0');
    return '$hours:$minutes:$seconds.$milliseconds';
  }
}

// Helper to generate SRT file content
class SubtitleExporter {
  static String toSrt(List<SubtitleModel> subtitles) {
    final buffer = StringBuffer();
    for (var i = 0; i < subtitles.length; i++) {
      buffer.write(subtitles[i].toSrtEntry(i + 1));
    }
    return buffer.toString();
  }

  static String toVtt(List<SubtitleModel> subtitles) {
    final buffer = StringBuffer();
    buffer.writeln('WEBVTT');
    buffer.writeln();
    for (var i = 0; i < subtitles.length; i++) {
      buffer.write(subtitles[i].toVttEntry(i + 1));
    }
    return buffer.toString();
  }

  static String toText(List<SubtitleModel> subtitles, {bool includeTimestamps = false}) {
    final buffer = StringBuffer();
    for (final subtitle in subtitles) {
      if (includeTimestamps) {
        buffer.writeln('[${subtitle.timestampFormatted}] ${subtitle.translatedText}');
      } else {
        buffer.writeln(subtitle.translatedText);
      }
    }
    return buffer.toString();
  }

  static String toBilingual(List<SubtitleModel> subtitles) {
    final buffer = StringBuffer();
    for (final subtitle in subtitles) {
      buffer.writeln('[${subtitle.timestampFormatted}]');
      buffer.writeln('KR: ${subtitle.originalText}');
      buffer.writeln('EN: ${subtitle.translatedText}');
      buffer.writeln();
    }
    return buffer.toString();
  }
}
