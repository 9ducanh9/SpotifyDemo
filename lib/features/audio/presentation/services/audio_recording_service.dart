import 'dart:io';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service for audio recording
class AudioRecordingService {
  final AudioRecorder _recorder = AudioRecorder();

  /// Check and request microphone permission
  Future<bool> checkPermission() async {
    final status = await Permission.microphone.status;
    if (status.isDenied) {
      final result = await Permission.microphone.request();
      return result.isGranted;
    }
    return status.isGranted;
  }

  /// Start recording audio
  Future<String?> startRecording() async {
    final hasPermission = await checkPermission();
    if (!hasPermission) {
      throw Exception('Microphone permission not granted');
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final recordingsDir = Directory('${directory.path}/recordings');
      if (!await recordingsDir.exists()) {
        await recordingsDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${recordingsDir.path}/recording_$timestamp.m4a';

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: filePath,
      );

      return filePath;
    } catch (e) {
      throw Exception('Failed to start recording: $e');
    }
  }

  /// Stop recording and return the file path
  Future<String?> stopRecording() async {
    try {
      return await _recorder.stop();
    } catch (e) {
      throw Exception('Failed to stop recording: $e');
    }
  }

  /// Check if currently recording
  Future<bool> isRecording() async {
    return await _recorder.isRecording();
  }

  /// Dispose resources
  void dispose() {
    _recorder.dispose();
  }
}
