import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import '../models/track.dart';
import 'audio_file_service.dart';

/// Service quét và lấy danh sách audio files từ thiết bị (hỗ trợ Android MediaStore và iOS Music Library)
class MediaStoreService {
  final AudioFileService _audioFileService = AudioFileService();

  /// Quét toàn bộ audio files trong thiết bị
  /// Trả về danh sách Track chưa được import (chỉ metadata, chưa lưu vào DB)
  Future<List<Track>> scanDeviceAudioFiles() async {
    final List<Track> tracks = [];

    try {
      // Kiểm tra và xin quyền
      if (Platform.isAndroid) {
        // Android 13+ cần READ_MEDIA_AUDIO
        // Android < 13 cần READ_EXTERNAL_STORAGE
        PermissionStatus status;
        try {
          // Thử xin quyền audio (Android 13+)
          status = await Permission.audio.request();
        } catch (e) {
          // Fallback về storage permission (Android < 13)
          status = await Permission.storage.request();
        }

        if (!status.isGranted) {
          throw Exception('Cần quyền truy cập audio files để quét nhạc');
        }
      } else if (Platform.isIOS) {
        // iOS cần quyền truy cập Music Library
        // File picker sẽ tự xử lý quyền
      }

      // Quét các thư mục phổ biến
      final directories = await _getAudioDirectories();
      
      for (final dir in directories) {
        if (await dir.exists()) {
          final files = await _scanDirectoryRecursive(dir);
          for (final file in files) {
            try {
              final track = await createTrackFromFile(file);
              if (track != null) {
                tracks.add(track);
              }
            } catch (e) {
              // Bỏ qua file lỗi
              continue;
            }
          }
        }
      }

      return tracks;
    } catch (e) {
      rethrow;
    }
  }

  /// Lấy danh sách thư mục chứa audio phổ biến
  Future<List<Directory>> _getAudioDirectories() async {
    final List<Directory> directories = [];

    if (Platform.isAndroid) {
      // Android: Quét các thư mục phổ biến
      final commonPaths = [
        '/storage/emulated/0/Music',
        '/storage/emulated/0/Download',
        '/storage/emulated/0/DCIM',
        '/sdcard/Music',
        '/sdcard/Download',
      ];

      for (final dirPath in commonPaths) {
        final dir = Directory(dirPath);
        if (await dir.exists()) {
          directories.add(dir);
        }
      }
    } else if (Platform.isWindows) {
      // Windows: Quét thư mục Music và Downloads
      final userProfile = Platform.environment['USERPROFILE'];
      if (userProfile != null) {
        final musicDir = Directory(path.join(userProfile, 'Music'));
        final downloadsDir = Directory(path.join(userProfile, 'Downloads'));
        if (await musicDir.exists()) directories.add(musicDir);
        if (await downloadsDir.exists()) directories.add(downloadsDir);
      }
    } else if (Platform.isMacOS || Platform.isLinux) {
      // macOS/Linux: Quét thư mục Music và Downloads
      final homeDir = Platform.environment['HOME'];
      if (homeDir != null) {
        final musicDir = Directory(path.join(homeDir, 'Music'));
        final downloadsDir = Directory(path.join(homeDir, 'Downloads'));
        if (await musicDir.exists()) directories.add(musicDir);
        if (await downloadsDir.exists()) directories.add(downloadsDir);
      }
    }

    return directories;
  }

  /// Quét thư mục đệ quy để tìm tất cả file audio
  Future<List<File>> _scanDirectoryRecursive(Directory directory) async {
    final List<File> audioFiles = [];

    try {
      await for (final entity in directory.list(recursive: true)) {
        if (entity is File) {
          final ext = path.extension(entity.path).toLowerCase();
          if (['.mp3', '.m4a', '.wav', '.aac', '.flac', '.ogg', '.opus'].contains(ext)) {
            audioFiles.add(entity);
          }
        }
      }
    } catch (e) {
      // Bỏ qua lỗi permission hoặc access denied
    }

    return audioFiles;
  }

  /// Tạo Track object từ File (chỉ metadata, chưa lưu vào DB)
  Future<Track?> createTrackFromFile(File file) async {
    try {
      // Lấy metadata từ file
      final metadata = await _audioFileService.getAudioMetadata(file.path);
      
      // Parse tên file để lấy thông tin
      final fileName = path.basenameWithoutExtension(file.path);
      final parsedInfo = _parseFileName(fileName);

      return Track(
        title: parsedInfo['title'] ?? metadata['title'] as String,
        duration: metadata['duration'] as int,
        fileUrl: file.path, // Lưu path gốc, không copy
        artist: parsedInfo['artist'] as String?,
        genre: parsedInfo['genre'] as String?,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Parse tên file để lấy title, artist, genre
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
    
    result['title'] = parts[0];
    
    if (parts.length > 1) {
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
    
    final genreMatch = RegExp(r'\[([^\]]+)\]|\(([^\)]+)\)').firstMatch(fileName);
    if (genreMatch != null) {
      result['genre'] = genreMatch.group(1) ?? genreMatch.group(2);
    }
    
    return result;
  }

  /// Kiểm tra quyền truy cập audio
  Future<bool> hasAudioPermission() async {
    if (Platform.isAndroid) {
      try {
        return await Permission.audio.isGranted;
      } catch (e) {
        // Fallback về storage permission
        return await Permission.storage.isGranted;
      }
    }
    return true; // iOS/Desktop sẽ xử lý qua file picker
  }

  /// Yêu cầu quyền truy cập audio
  Future<bool> requestAudioPermission() async {
    if (Platform.isAndroid) {
      try {
        final status = await Permission.audio.request();
        return status.isGranted;
      } catch (e) {
        // Fallback về storage permission
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    }
    return true;
  }
}

