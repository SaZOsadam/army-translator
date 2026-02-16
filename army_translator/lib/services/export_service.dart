import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/subtitle_model.dart';
import '../models/transcript_model.dart';
import '../models/session_model.dart';

enum ExportFormat {
  srt,
  vtt,
  txt,
  bilingual,
}

class ExportService {
  // Export subtitles to file
  Future<String?> exportSubtitles(
    List<SubtitleModel> subtitles,
    String filename,
    ExportFormat format,
  ) async {
    try {
      String content;
      String extension;
      
      switch (format) {
        case ExportFormat.srt:
          content = SubtitleExporter.toSrt(subtitles);
          extension = 'srt';
          break;
        case ExportFormat.vtt:
          content = SubtitleExporter.toVtt(subtitles);
          extension = 'vtt';
          break;
        case ExportFormat.txt:
          content = SubtitleExporter.toText(subtitles, includeTimestamps: true);
          extension = 'txt';
          break;
        case ExportFormat.bilingual:
          content = SubtitleExporter.toBilingual(subtitles);
          extension = 'txt';
          break;
      }

      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/$filename.$extension';
      final file = File(path);
      await file.writeAsString(content);
      
      return path;
    } catch (e) {
      debugPrint('Export error: $e');
      return null;
    }
  }

  // Export transcripts from session
  Future<String?> exportSession(
    SessionModel session,
    List<TranscriptModel> transcripts,
    ExportFormat format,
  ) async {
    final subtitles = transcripts.map((t) => SubtitleModel(
      id: t.id,
      originalText: t.originalText,
      translatedText: t.translatedText,
      startMs: t.startMs,
      endMs: t.endMs,
      confidence: t.confidence,
      speaker: t.speaker,
    )).toList();

    final filename = _sanitizeFilename(session.title);
    return await exportSubtitles(subtitles, filename, format);
  }

  // Share exported file
  Future<void> shareFile(String filePath) async {
    try {
      await Share.shareXFiles([XFile(filePath)]);
    } catch (e) {
      debugPrint('Share error: $e');
    }
  }

  // Share text directly
  Future<void> shareText(String text, {String? subject}) async {
    try {
      await Share.share(text, subject: subject);
    } catch (e) {
      debugPrint('Share text error: $e');
    }
  }

  // Export and share in one step
  Future<void> exportAndShare(
    List<SubtitleModel> subtitles,
    String filename,
    ExportFormat format,
  ) async {
    final path = await exportSubtitles(subtitles, filename, format);
    if (path != null) {
      await shareFile(path);
    }
  }

  // Get export directory
  Future<String> getExportDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final exportDir = Directory('${directory.path}/exports');
    
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }
    
    return exportDir.path;
  }

  // List exported files
  Future<List<FileSystemEntity>> listExportedFiles() async {
    try {
      final exportDir = await getExportDirectory();
      final directory = Directory(exportDir);
      return await directory.list().toList();
    } catch (e) {
      debugPrint('List files error: $e');
      return [];
    }
  }

  // Delete exported file
  Future<bool> deleteExportedFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Delete file error: $e');
      return false;
    }
  }

  // Generate shareable image with subtitles
  Future<String?> generateSubtitleImage(
    SubtitleModel subtitle,
    String? memberName,
  ) async {
    // TODO: Implement image generation with subtitle text
    // This would use a canvas to draw the subtitle on a styled background
    return null;
  }

  String _sanitizeFilename(String name) {
    return name
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .toLowerCase();
  }
}
