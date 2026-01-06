import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/recording.dart';
import '../../services/recording_service.dart';
import '../../widgets/loading_indicator.dart';

class RecordingsScreen extends ConsumerStatefulWidget {
  const RecordingsScreen({super.key});

  @override
  ConsumerState<RecordingsScreen> createState() => _RecordingsScreenState();
}

class _RecordingsScreenState extends ConsumerState<RecordingsScreen> {
  final RecordingService _recordingService = RecordingService();
  List<Recording> _recordings = [];
  bool _isLoading = true;
  String? _playingFilePath;

  @override
  void initState() {
    super.initState();
    _loadRecordings();
  }

  Future<void> _loadRecordings() async {
    setState(() => _isLoading = true);
    try {
      final recordings = await _recordingService.getAllRecordings();
      // Filter out files that no longer exist
      final existingRecordings = <Recording>[];
      for (final recording in recordings) {
        if (await _recordingService.fileExists(recording.filePath)) {
          existingRecordings.add(recording);
        }
      }
      setState(() {
        _recordings = existingRecordings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải danh sách ghi âm: $e')),
        );
      }
    }
  }

  Future<void> _playRecording(Recording recording, int index) async {
    try {
      // Check if file exists
      if (!recording.exists()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File không tồn tại')),
          );
        }
        await _loadRecordings();
        return;
      }

      // Create a temporary Track from recording to play
      // We'll use audio provider to play the file
      // Note: This is a simplified approach - in production you might want
      // a dedicated method to play recordings
      
      setState(() {
        _playingFilePath = recording.filePath;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đang phát: ${recording.displayName}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // TODO: Integrate with audio player to actually play the recording
      // For now, just indicate that it's "playing"
      // In a full implementation, you would:
      // 1. Create a Track object from the recording
      // 2. Use audioStateProvider.notifier.playTrack(track, fromLocal: true)
      // 3. Navigate to player screen or show inline player
      
    } catch (e) {
      setState(() {
        _playingFilePath = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi phát: $e')),
        );
      }
    }
  }

  Future<void> _deleteRecording(Recording recording, int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa "${recording.displayName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final success = await _recordingService.deleteRecording(recording.filePath);
        if (success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Đã xóa file ghi âm'),
                backgroundColor: Colors.green,
              ),
            );
          }
          await _loadRecordings();
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Không thể xóa file'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ghi Âm Cá Nhân'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRecordings,
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : _recordings.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.mic_off,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Chưa có file ghi âm nào',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sử dụng tính năng ghi âm để tạo file mới',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadRecordings,
                  child: ListView.builder(
                    itemCount: _recordings.length,
                    padding: const EdgeInsets.all(8),
                    itemBuilder: (context, index) {
                      final recording = _recordings[index];
                      final isPlaying = _playingFilePath == recording.filePath;
                      
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isPlaying 
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey.shade300,
                            child: Icon(
                              isPlaying ? Icons.equalizer : Icons.mic,
                              color: isPlaying 
                                  ? Colors.white
                                  : Colors.grey.shade700,
                            ),
                          ),
                          title: Text(
                            recording.displayName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                'Tạo: ${recording.formattedDate}',
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              ),
                              Text(
                                'Kích thước: ${recording.formattedSize}',
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'play') {
                                _playRecording(recording, index);
                              } else if (value == 'delete') {
                                _deleteRecording(recording, index);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'play',
                                child: Row(
                                  children: [
                                    Icon(Icons.play_arrow, size: 20),
                                    SizedBox(width: 8),
                                    Text('Phát'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, size: 20, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Xóa', style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          onTap: () => _playRecording(recording, index),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

