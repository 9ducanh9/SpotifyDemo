import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/recording.dart';

/// Service quản lý các bản ghi âm
class RecordingService {
  /// Lấy thư mục lưu trữ recordings
  Future<Directory> getRecordingDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory;
  }

  /// Lấy danh sách tất cả các file recording
  Future<List<Recording>> getAllRecordings() async {
    try {
      final directory = await getRecordingDirectory();
      final files = directory.listSync()
          .whereType<File>()
          .where((file) {
            final fileName = path.basename(file.path);
            return fileName.startsWith('recording_') && 
                   (fileName.endsWith('.m4a') || fileName.endsWith('.m4a'));
          })
          .toList();

      final recordings = <Recording>[];
      for (final file in files) {
        final fileName = path.basename(file.path);
        final stat = await file.stat();
        
        // Extract timestamp from filename: recording_1234567890.m4a
        final match = RegExp(r'recording_(\d+)\.m4a$').firstMatch(fileName);
        DateTime createdAt;
        if (match != null) {
          final timestamp = int.tryParse(match.group(1)!);
          createdAt = timestamp != null 
              ? DateTime.fromMillisecondsSinceEpoch(timestamp)
              : stat.modified;
        } else {
          createdAt = stat.modified;
        }

        recordings.add(Recording(
          filePath: file.path,
          name: fileName,
          createdAt: createdAt,
          fileSize: await file.length(),
        ));
      }

      // Sort by creation date (newest first)
      recordings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return recordings;
    } catch (e) {
      return [];
    }
  }

  /// Xóa file recording
  Future<bool> deleteRecording(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Kiểm tra file có tồn tại không
  Future<bool> fileExists(String filePath) async {
    try {
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  /// Lấy kích thước file
  Future<int> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }
}




