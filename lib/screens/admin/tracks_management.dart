import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/track.dart';
import '../../services/api_service.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/track_item.dart';
import '../../utils/validators.dart';
import '../../utils/token_debug.dart';

class TracksManagementScreen extends ConsumerStatefulWidget {
  const TracksManagementScreen({super.key});

  @override
  ConsumerState<TracksManagementScreen> createState() => _TracksManagementScreenState();
}

class _TracksManagementScreenState extends ConsumerState<TracksManagementScreen> {
  final ApiService _apiService = ApiService();
  List<Track> _tracks = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTracks();
  }

  Future<void> _loadTracks() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Debug: Check token before API call
      final tokenInfo = await TokenDebug.checkToken();
      print('🔍 [Tracks Management] Token Debug:');
      print('  - Has Token: ${tokenInfo['hasToken']}');
      print('  - Token Length: ${tokenInfo['tokenLength']}');
      print('  - Token Preview: ${tokenInfo['tokenPreview']}');
      print('  - Role: ${tokenInfo['role']}');
      print('  - Is Admin: ${tokenInfo['isAdmin']}');
      print('  - Email: ${tokenInfo['email']}');
      
      final tracks = await _apiService.getAllTracksForAdmin();
      print('✅ [Tracks Management] Successfully loaded ${tracks.length} tracks');
      setState(() {
        _tracks = tracks;
        _isLoading = false;
      });
    } catch (e) {
      // Debug: Check token on error
      final tokenInfo = await TokenDebug.checkToken();
      print('❌ [Tracks Management] Error loading tracks: $e');
      print('🔍 Token Debug on Error:');
      print('  - Has Token: ${tokenInfo['hasToken']}');
      print('  - Token Length: ${tokenInfo['tokenLength']}');
      print('  - Role: ${tokenInfo['role']}');
      print('  - Is Admin: ${tokenInfo['isAdmin']}');
      
      setState(() {
        _error = 'Lỗi khi tải danh sách bài hát: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _showAddTrackDialog() async {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final durationController = TextEditingController();
    final fileUrlController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm bài hát mới'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Tên bài hát *',
                    border: OutlineInputBorder(),
                  ),
                  validator: Validators.trackTitle,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: durationController,
                  decoration: const InputDecoration(
                    labelText: 'Thời lượng (giây) *',
                    border: OutlineInputBorder(),
                    helperText: 'Ví dụ: 180 (3 phút)',
                  ),
                  keyboardType: TextInputType.number,
                  validator: Validators.trackDuration,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: fileUrlController,
                  decoration: const InputDecoration(
                    labelText: 'URL hoặc đường dẫn file *',
                    border: OutlineInputBorder(),
                    helperText: 'http://... hoặc /path/to/file.mp3',
                  ),
                  validator: Validators.trackFileUrl,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );

    if (result == true) {
      await _addTrack(
        titleController.text.trim(),
        int.parse(durationController.text.trim()),
        fileUrlController.text.trim(),
      );
    }
  }

  Future<void> _addTrack(String title, int duration, String fileUrl) async {
    try {
      final track = Track(
        title: title,
        duration: duration,
        fileUrl: fileUrl,
      );
      await _apiService.createTrack(track);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thêm bài hát thành công'),
            backgroundColor: Colors.green,
          ),
        );
      }
      await _loadTracks();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showEditTrackDialog(Track track) async {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: track.title);
    final durationController = TextEditingController(text: track.duration.toString());
    final fileUrlController = TextEditingController(text: track.fileUrl);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Sửa bài hát'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Tên bài hát *',
                      border: OutlineInputBorder(),
                    ),
                    validator: Validators.trackTitle,
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: durationController,
                    decoration: const InputDecoration(
                      labelText: 'Thời lượng (giây) *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: Validators.trackDuration,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: fileUrlController,
                    decoration: const InputDecoration(
                      labelText: 'URL hoặc đường dẫn file *',
                      border: OutlineInputBorder(),
                    ),
                    validator: Validators.trackFileUrl,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context, true);
                }
              },
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      await _updateTrack(
        track.copyWith(
          title: titleController.text.trim(),
          duration: int.parse(durationController.text.trim()),
          fileUrl: fileUrlController.text.trim(),
          updatedAt: DateTime.now(),
        ),
      );
    }
  }

  Future<void> _updateTrack(Track track) async {
    try {
      await _apiService.updateTrack(track.id!, track);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật bài hát thành công'),
            backgroundColor: Colors.green,
          ),
        );
      }
      await _loadTracks();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteTrack(Track track) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa "${track.title}"?'),
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
        await _apiService.deleteTrack(track.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã xóa bài hát thành công'),
              backgroundColor: Colors.green,
            ),
          );
        }
        await _loadTracks();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản Lý Bài Hát'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTracks,
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: TextStyle(color: Colors.red.shade700),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadTracks,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : _tracks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.music_off, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            'Chưa có bài hát nào',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadTracks,
                      child: ListView.builder(
                        itemCount: _tracks.length,
                        padding: const EdgeInsets.all(8),
                        itemBuilder: (context, index) {
                          final track = _tracks[index];
                          return TrackItem(
                            track: track,
                            onTap: () {},
                            onEdit: () => _showEditTrackDialog(track),
                            onDelete: () => _deleteTrack(track),
                          );
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTrackDialog,
        tooltip: 'Thêm bài hát mới',
        child: const Icon(Icons.add),
      ),
    );
  }
}

