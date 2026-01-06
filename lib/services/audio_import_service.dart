import 'dart:io';
import 'package:path/path.dart' as path;
import '../models/track.dart';
import 'audio_file_service.dart';
import 'database_service.dart';

/// Service import file audio từ các nguồn khác nhau (Downloads, assets, etc.)
class AudioImportService {
  final AudioFileService _audioFileService = AudioFileService();
  final LocalDatabaseService _databaseService = LocalDatabaseService();

  /// Quét và import file audio từ thư mục Downloads
  Future<List<Track>> scanAndImportFromDownloads() async {
    final List<Track> importedTracks = [];
    
    try {
      // Lấy thư mục Downloads
      final downloadsDir = await _getDownloadsDirectory();
      if (downloadsDir == null || !await downloadsDir.exists()) {
        return importedTracks;
      }

      // Quét tất cả file audio
      final audioFiles = await _scanAudioFiles(downloadsDir);
      
      // Import từng file
      for (final file in audioFiles) {
        try {
          final track = await _importAudioFile(file);
          if (track != null) {
            importedTracks.add(track);
          }
        } catch (e) {
          // Bỏ qua file lỗi, tiếp tục với file khác
          continue;
        }
      }

      return importedTracks;
    } catch (e) {
      return importedTracks;
    }
  }

  /// Import file audio cụ thể
  Future<Track?> importAudioFile(File file) async {
    return await _importAudioFile(file);
  }

  /// Import file audio (internal method)
  Future<Track?> _importAudioFile(File file) async {
    try {
      // Kiểm tra file đã tồn tại trong database chưa
      final fileName = path.basename(file.path);
      final existingTracks = await _databaseService.getAllTracks();
      final alreadyExists = existingTracks.any((track) => 
        track.fileUrl.contains(fileName) || 
        path.basename(track.fileUrl) == fileName
      );

      if (alreadyExists) {
        return null; // File đã tồn tại
      }

      // Copy file vào thư mục app
      final copiedPath = await _audioFileService.copyAudioFileToApp(file);
      
      // Lấy metadata
      final metadata = await _audioFileService.getAudioMetadata(copiedPath);
      
      // Tạo Track object
      final track = Track(
        title: metadata['title'] as String,
        duration: metadata['duration'] as int,
        fileUrl: copiedPath,
        createdAt: DateTime.now(),
      );

      // Lưu vào database
      await _databaseService.insertTrack(track);

      return track;
    } catch (e) {
      return null;
    }
  }

  /// Quét file audio trong thư mục
  Future<List<File>> _scanAudioFiles(Directory directory) async {
    final List<File> audioFiles = [];
    
    try {
      final entities = directory.listSync(recursive: false);
      
      for (final entity in entities) {
        if (entity is File) {
          final ext = path.extension(entity.path).toLowerCase();
          if (['.mp3', '.m4a', '.wav', '.aac', '.flac', '.ogg'].contains(ext)) {
            audioFiles.add(entity);
          }
        }
      }
    } catch (e) {
      // Ignore errors
    }

    return audioFiles;
  }

  /// Lấy thư mục Downloads
  Future<Directory?> _getDownloadsDirectory() async {
    try {
      if (Platform.isAndroid) {
        // Android: /storage/emulated/0/Download
        final downloadsPath = '/storage/emulated/0/Download';
        final dir = Directory(downloadsPath);
        if (await dir.exists()) {
          return dir;
        }
        
        // Thử đường dẫn khác
        final altPath = '/sdcard/Download';
        final altDir = Directory(altPath);
        if (await altDir.exists()) {
          return altDir;
        }
      } else if (Platform.isWindows) {
        // Windows: %USERPROFILE%\Downloads
        final userProfile = Platform.environment['USERPROFILE'];
        if (userProfile != null) {
          final downloadsPath = path.join(userProfile, 'Downloads');
          final dir = Directory(downloadsPath);
          if (await dir.exists()) {
            return dir;
          }
        }
      } else if (Platform.isMacOS || Platform.isLinux) {
        // macOS/Linux: ~/Downloads
        final homeDir = Platform.environment['HOME'];
        if (homeDir != null) {
          final downloadsPath = path.join(homeDir, 'Downloads');
          final dir = Directory(downloadsPath);
          if (await dir.exists()) {
            return dir;
          }
        }
      }
    } catch (e) {
      // Ignore errors
    }

    return null;
  }

  /// Quét file từ đường dẫn cụ thể
  Future<List<Track>> scanDirectory(String directoryPath) async {
    final List<Track> importedTracks = [];
    
    try {
      final dir = Directory(directoryPath);
      if (!await dir.exists()) {
        return importedTracks;
      }

      final audioFiles = await _scanAudioFiles(dir);
      
      for (final file in audioFiles) {
        try {
          final track = await _importAudioFile(file);
          if (track != null) {
            importedTracks.add(track);
          }
        } catch (e) {
          continue;
        }
      }

      return importedTracks;
    } catch (e) {
      return importedTracks;
    }
  }

  /// Import tất cả bài hát từ assets/audio
  /// Đọc trực tiếp từ thư mục assets (không qua Flutter asset bundle)
  Future<List<Track>> importFromAssets() async {
    final List<Track> importedTracks = [];
    
    try {
      // Đường dẫn thư mục assets/audio trong project
      // Lấy từ thư mục hiện tại (khi chạy từ project root)
      final currentDir = Directory.current;
      final assetsDir = Directory(path.join(currentDir.path, 'assets', 'audio'));
      
      if (!await assetsDir.exists()) {
        return importedTracks;
      }

      // Quét tất cả file audio trong thư mục
      final audioFiles = await _scanAudioFiles(assetsDir);

      // Kiểm tra tracks đã tồn tại trong database
      final existingTracks = await _databaseService.getAllTracks();
      final existingFileNames = existingTracks
          .map((track) => path.basename(track.fileUrl))
          .toSet();

      // Import từng file
      for (final file in audioFiles) {
        try {
          final fileName = path.basename(file.path);
          
          // Kiểm tra đã tồn tại chưa
          if (existingFileNames.contains(fileName) ||
              existingTracks.any((track) => 
                  path.basename(track.fileUrl).contains(path.basenameWithoutExtension(fileName)))) {
            continue; // Bỏ qua file đã tồn tại
          }

          // Copy file vào app directory và import
          final track = await _importFromAssetFile(file);
          if (track != null) {
            importedTracks.add(track);
          }
        } catch (e) {
          // Bỏ qua file lỗi, tiếp tục với file khác
          continue;
        }
      }

      return importedTracks;
    } catch (e) {
      return importedTracks;
    }
  }

  /// Import một file từ assets (đọc trực tiếp từ File system)
  Future<Track?> _importFromAssetFile(File sourceFile) async {
    try {
      // Copy vào thư mục app
      final copiedPath = await _audioFileService.copyAudioFileToApp(sourceFile);
      
      // Lấy metadata
      final metadata = await _audioFileService.getAudioMetadata(copiedPath);
      
      // Parse tên file để lấy title và artist nếu có
      final fileName = path.basenameWithoutExtension(sourceFile.path);
      final parsedInfo = _parseFileName(fileName);
      
      // Tạo Track object
      final track = Track(
        title: parsedInfo['title'] ?? metadata['title'] as String,
        duration: metadata['duration'] as int,
        fileUrl: copiedPath,
        artist: parsedInfo['artist'] as String?,
        genre: parsedInfo['genre'] as String?,
        createdAt: DateTime.now(),
      );

      // Lưu vào database
      await _databaseService.insertTrack(track);

      return track;
    } catch (e) {
      return null;
    }
  }

  /// Parse tên file để lấy thông tin title, artist, genre
  /// Format: "001 - Title - Artist.mp3" hoặc "Title - Artist [Genre].mp3"
  Map<String, dynamic> _parseFileName(String fileName) {
    final result = <String, dynamic>{};
    
    // Bỏ số thứ tự ở đầu (nếu có): "001 - "
    String cleanName = fileName.replaceFirst(RegExp(r'^\d+\s*-\s*'), '');
    
    // Tách các phần bằng " - " hoặc " ｜ "
    final parts = cleanName
        .split(RegExp(r'\s*-\s*|\s*｜\s*'))
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();
    
    if (parts.isEmpty) {
      result['title'] = fileName;
      return result;
    }
    
    // Phần đầu thường là title
    result['title'] = parts[0];
    
    // Tìm artist (thường ở giữa hoặc cuối)
    if (parts.length > 1) {
      // Loại bỏ các tag như [OFFICIAL MV], (Official Video), etc.
      final artistParts = parts.sublist(1).where((p) {
        final lower = p.toLowerCase();
        return !lower.contains('official') &&
               !lower.contains('mv') &&
               !lower.contains('video') &&
               !lower.contains('lyrics') &&
               !lower.contains('remix');
      }).toList();
      
      if (artistParts.isNotEmpty) {
        result['artist'] = artistParts.first;
      }
    }
    
    // Tìm genre (thường trong ngoặc vuông hoặc ở cuối)
    final genreMatch = RegExp(r'\[([^\]]+)\]|\(([^\)]+)\)').firstMatch(fileName);
    if (genreMatch != null) {
      result['genre'] = genreMatch.group(1) ?? genreMatch.group(2);
    }
    
    return result;
  }
}


