class SessionModel {
  final String id;
  final String userId;
  final String title;
  final DateTime startTime;
  final DateTime? endTime;
  final int durationSeconds;
  final int transcriptCount;
  final String sourceLanguage;
  final String targetLanguage;
  final bool isSaved;

  SessionModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.startTime,
    this.endTime,
    required this.durationSeconds,
    required this.transcriptCount,
    this.sourceLanguage = 'ko',
    required this.targetLanguage,
    this.isSaved = true,
  });

  factory SessionModel.fromJson(Map<String, dynamic> data) {
    return SessionModel(
      id: data['id'] ?? '',
      userId: data['user_id'] ?? '',
      title: data['title'] ?? 'Untitled Session',
      startTime: data['start_time'] != null
          ? DateTime.parse(data['start_time'])
          : DateTime.now(),
      endTime:
          data['end_time'] != null ? DateTime.parse(data['end_time']) : null,
      durationSeconds: data['duration_seconds'] ?? 0,
      transcriptCount: data['transcript_count'] ?? 0,
      sourceLanguage: data['source_language'] ?? 'ko',
      targetLanguage: data['target_language'] ?? 'en',
      isSaved: data['is_saved'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'title': title,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'duration_seconds': durationSeconds,
      'transcript_count': transcriptCount,
      'source_language': sourceLanguage,
      'target_language': targetLanguage,
      'is_saved': isSaved,
    };
  }

  SessionModel copyWith({
    String? id,
    String? userId,
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    int? durationSeconds,
    int? transcriptCount,
    String? sourceLanguage,
    String? targetLanguage,
    bool? isSaved,
  }) {
    return SessionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      transcriptCount: transcriptCount ?? this.transcriptCount,
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  // Formatted duration
  String get formattedDuration {
    final hours = durationSeconds ~/ 3600;
    final minutes = (durationSeconds % 3600) ~/ 60;
    final seconds = durationSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  // Formatted date
  String get formattedDate {
    final now = DateTime.now();
    final diff = now.difference(startTime);

    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${startTime.month}/${startTime.day}/${startTime.year}';
    }
  }
}
