import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:audioplayers/audioplayers.dart';

/// Service xử lý file audio (chọn file, copy, metadata)
class AudioFileService {
  static const String _audioDirectoryName = 'music';

  /// Lấy thư mục lưu trữ audio của ứng dụng
  Future<Directory> getAudioDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final audioDir = Directory(path.join(appDir.path, _audioDirectoryName));
    
    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }
    
    return audioDir;
  }

  /// Chọn file audio từ thiết bị
  /// Note: FilePicker tự xử lý permissions thông qua system file picker
  /// Không cần request permission trước trên Android 11+ và iOS
  Future<FilePickerResult?> pickAudioFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'm4a', 'wav', 'aac', 'flac', 'ogg'],
        allowMultiple: false,
      );

      return result;
    } catch (e) {
      // Xử lý lỗi từ file picker
      throw Exception('Không thể chọn file: ${e.toString()}');
    }
  }

  /// Copy file audio vào thư mục của ứng dụng
  Future<String> copyAudioFileToApp(File sourceFile) async {
    final audioDir = await getAudioDirectory();
    final fileName = path.basename(sourceFile.path);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final newFileName = '${timestamp}_$fileName';
    final destFile = File(path.join(audioDir.path, newFileName));

    await sourceFile.copy(destFile.path);
    return destFile.path;
  }

  /// Lấy metadata từ file audio (duration, title, artist)
  Future<Map<String, dynamic>> getAudioMetadata(String filePath) async {
    try {
      final player = AudioPlayer();
      
      // Set source để lấy duration
      await player.setSource(DeviceFileSource(filePath));
      
      // Đợi một chút để player load file
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Lấy duration
      final duration = await player.getDuration() ?? const Duration(seconds: 0);
      
      await player.dispose();

      // Lấy tên file làm title mặc định
      final fileName = path.basenameWithoutExtension(filePath);
      
      return {
        'duration': duration.inSeconds,
        'title': _cleanFileName(fileName),
        'filePath': filePath,
      };
    } catch (e) {
      // Nếu không lấy được metadata, trả về giá trị mặc định
      final fileName = path.basenameWithoutExtension(filePath);
      return {
        'duration': 0, // Sẽ cần nhập thủ công
        'title': _cleanFileName(fileName),
        'filePath': filePath,
      };
    }
  }

  /// Làm sạch tên file (bỏ timestamp prefix nếu có)
  String _cleanFileName(String fileName) {
    // Bỏ timestamp prefix nếu có format: timestamp_filename
    final parts = fileName.split('_');
    if (parts.length > 1) {
      // Kiểm tra nếu phần đầu là số (timestamp)
      final firstPart = parts[0];
      if (firstPart.length >= 10 && int.tryParse(firstPart) != null) {
        return parts.sublist(1).join('_');
      }
    }
    return fileName;
  }

  /// Lấy danh sách file audio trong thư mục của app
  Future<List<File>> getLocalAudioFiles() async {
    final audioDir = await getAudioDirectory();
    if (!await audioDir.exists()) {
      return [];
    }

    final files = audioDir.listSync()
        .whereType<File>()
        .where((file) {
          final ext = path.extension(file.path).toLowerCase();
          return ['.mp3', '.m4a', '.wav', '.aac', '.flac', '.ogg'].contains(ext);
        })
        .toList();

    return files;
  }

  /// Xóa file audio
  Future<bool> deleteAudioFile(String filePath) async {
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
    final file = File(filePath);
    return await file.exists();
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

  /// Format kích thước file (bytes -> MB/KB)
  String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
  }
}


