import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/track.dart';
import '../../services/media_store_service.dart';
import '../../services/audio_file_service.dart';
import '../../services/audio_import_service.dart';
import '../../providers/track_provider.dart';

/// Screen để thêm bài hát - với 2 options: Auto Scan hoặc Pick File
class AddTracksScreen extends ConsumerStatefulWidget {
  const AddTracksScreen({super.key});

  @override
  ConsumerState<AddTracksScreen> createState() => _AddTracksScreenState();
}

class _AddTracksScreenState extends ConsumerState<AddTracksScreen> {
  bool _isScanning = false;
  List<Track> _scannedTracks = [];
  Set<int> _selectedIndices = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm bài hát'),
      ),
      body: _scannedTracks.isEmpty
          ? _buildMethodSelection()
          : _buildTrackSelectionList(),
    );
  }

  /// Hiển thị 2 options: Auto Scan hoặc Pick File
  Widget _buildMethodSelection() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.music_note,
            size: 80,
            color: Colors.purple,
          ),
          const SizedBox(height: 32),
          const Text(
            'Chọn cách thêm bài hát',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          // Option 1: Auto Scan
          _buildMethodCard(
            icon: Icons.search,
            title: 'Quét nhạc trong máy',
            subtitle: 'Tự động tìm tất cả file nhạc trong thiết bị',
            color: Colors.blue,
            onTap: _scanDeviceAudio,
          ),
          const SizedBox(height: 16),
          // Option 2: Pick File
          _buildMethodCard(
            icon: Icons.folder_open,
            title: 'Chọn file nhạc',
            subtitle: 'Chọn file nhạc từ thiết bị',
            color: Colors.green,
            onTap: _pickAudioFiles,
          ),
        ],
      ),
    );
  }

  Widget _buildMethodCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: _isScanning ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  /// Hiển thị danh sách tracks đã scan và cho user chọn
  Widget _buildTrackSelectionList() {
    return Column(
      children: [
        // Header với nút Select All và Add Selected
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.blue.shade50,
          child: Row(
            children: [
              Text(
                'Đã tìm thấy ${_scannedTracks.length} bài hát',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() {
                    if (_selectedIndices.length == _scannedTracks.length) {
                      _selectedIndices.clear();
                    } else {
                      _selectedIndices = {
                        for (int i = 0; i < _scannedTracks.length; i++) i
                      };
                    }
                  });
                },
                child: Text(
                  _selectedIndices.length == _scannedTracks.length
                      ? 'Bỏ chọn tất cả'
                      : 'Chọn tất cả',
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _selectedIndices.isEmpty
                    ? null
                    : () => _addSelectedTracks(),
                icon: const Icon(Icons.add),
                label: Text('Thêm (${_selectedIndices.length})'),
              ),
            ],
          ),
        ),
        // Danh sách tracks
        Expanded(
          child: ListView.builder(
            itemCount: _scannedTracks.length,
            itemBuilder: (context, index) {
              final track = _scannedTracks[index];
              final isSelected = _selectedIndices.contains(index);

              return CheckboxListTile(
                value: isSelected,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedIndices.add(index);
                    } else {
                      _selectedIndices.remove(index);
                    }
                  });
                },
                title: Text(
                  track.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (track.artist != null)
                      Text('Nghệ sĩ: ${track.artist}'),
                    if (track.genre != null)
                      Text('Thể loại: ${track.genre}'),
                    Text(
                      'Thời lượng: ${_formatDuration(track.duration)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                secondary: const Icon(Icons.music_note),
                isThreeLine: true,
              );
            },
          ),
        ),
      ],
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  /// Auto scan device audio files
  Future<void> _scanDeviceAudio() async {
    setState(() => _isScanning = true);

    try {
      final mediaStore = MediaStoreService();
      
      // Kiểm tra và xin quyền
      if (!await mediaStore.hasAudioPermission()) {
        final granted = await mediaStore.requestAudioPermission();
        if (!granted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Cần quyền truy cập audio để quét nhạc'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }

      // Hiển thị loading
      if (!mounted) return;
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Expanded(child: Text('Đang quét nhạc trong máy...')),
            ],
          ),
        ),
      );

      // Quét audio files
      final tracks = await mediaStore.scanDeviceAudioFiles();

      if (!mounted) return;
      
      Navigator.pop(context); // Đóng loading dialog

      if (tracks.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không tìm thấy file nhạc nào'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        setState(() {
          _scannedTracks = tracks;
          _selectedIndices = {}; // Reset selection
        });
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Đóng loading dialog nếu có
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi quét: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isScanning = false);
    }
  }

  /// Pick audio files manually
  Future<void> _pickAudioFiles() async {
    try {
      final audioService = AudioFileService();
      final result = await audioService.pickAudioFile();

      if (result == null || result.files.isEmpty) {
        return; // User cancelled
      }

      setState(() => _isScanning = true);

      // Hiển thị loading
      if (!mounted) return;
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Expanded(child: Text('Đang xử lý file...')),
            ],
          ),
        ),
      );

      final List<Track> tracks = [];
      final mediaStore = MediaStoreService();

      for (final file in result.files) {
        if (file.path != null) {
          try {
            final fileObj = File(file.path!);
            final track = await mediaStore.createTrackFromFile(fileObj);
            if (track != null) {
              tracks.add(track);
            }
          } catch (e) {
            continue;
          }
        }
      }

      if (!mounted) return;
      
      Navigator.pop(context); // Đóng loading dialog

      if (tracks.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể đọc file nhạc'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        setState(() {
          _scannedTracks = tracks;
          _selectedIndices = {};
        });
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isScanning = false);
    }
  }

  /// Thêm các tracks đã chọn vào database
  Future<void> _addSelectedTracks() async {
    if (_selectedIndices.isEmpty) return;

    // Hiển thị loading
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Expanded(child: Text('Đang thêm bài hát...')),
          ],
        ),
      ),
    );

    try {
      final importService = AudioImportService();
      final selectedTracks = _selectedIndices
          .map((index) => _scannedTracks[index])
          .toList();

      int successCount = 0;
      
      for (final track in selectedTracks) {
        try {
          // Copy file vào app directory nếu là local file
          final file = File(track.fileUrl);
          if (await file.exists()) {
            // Import file (sẽ tự động copy và lưu vào DB)
            final importedTrack = await importService.importAudioFile(file);
            if (importedTrack != null) {
              successCount++;
            }
          }
        } catch (e) {
          continue;
        }
      }

      if (!mounted) return;
      
      Navigator.pop(context); // Đóng loading dialog

      // Refresh danh sách từ local DB để hiển thị ngay bài hát vừa thêm
      await ref.read(trackListProvider.notifier).loadTracks(fromLocal: true);

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã thêm $successCount bài hát thành công'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {},
          ),
        ),
      );

      Navigator.pop(context); // Quay lại màn hình trước
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi thêm: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

