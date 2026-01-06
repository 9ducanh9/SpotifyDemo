import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/track.dart';
import '../../providers/track_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/track_item.dart';
import '../../widgets/loading_indicator.dart';
import '../../utils/validators.dart';
import '../../services/audio_import_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final trackState = ref.watch(trackListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trình Phát Nhạc'),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_open),
            tooltip: 'Quét thư mục Downloads',
            onPressed: () => _scanDownloadsFolder(context),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search'),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: _buildBody(trackState),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
          switch (index) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.push('/search');
              break;
            case 2:
              context.push('/favorites');
              break;
            case 3:
              context.push('/statistics');
              break;
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Trang chủ'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Tìm kiếm'),
          NavigationDestination(icon: Icon(Icons.favorite), label: 'Yêu thích'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Thống kê'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-tracks'),
        tooltip: 'Thêm bài hát',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(TrackListState state) {
    if (state.isLoading) {
      return const LoadingIndicator();
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Lỗi: ${state.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(trackListProvider.notifier).loadTracks(),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (state.tracks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.music_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Chưa có bài hát nào'),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push('/add-tracks'),
              icon: const Icon(Icons.add),
              label: const Text('Thêm bài hát'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => ref.read(trackListProvider.notifier).loadTracks(),
              child: const Text('Tải lại'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(trackListProvider.notifier).loadTracks(),
      child: ListView.builder(
        itemCount: state.tracks.length,
        padding: const EdgeInsets.all(8),
        itemBuilder: (context, index) {
          final track = state.tracks[index];
          return TrackItem(
            track: track,
            onTap: () => context.push('/player/${track.id}'),
            onDelete: ref.watch(authStateProvider)?.canDelete == true
                ? () => _confirmDelete(context, track)
                : null,
            onEdit: ref.watch(authStateProvider)?.canEdit == true
                ? () => _showEditTrackDialog(context, track)
                : null,
          );
        },
      ),
    );
  }


  void _showEditTrackDialog(BuildContext context, Track track) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: track.title);
    final durationController = TextEditingController(text: track.duration.toString());
    final fileUrlController = TextEditingController(text: track.fileUrl);
    final artistController = TextEditingController(text: track.artist ?? '');
    final genreController = TextEditingController(text: track.genre ?? '');
    bool isFavorite = track.isFavorite;

    showDialog(
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
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: artistController,
                    decoration: const InputDecoration(
                      labelText: 'Nghệ sĩ',
                      border: OutlineInputBorder(),
                    ),
                    validator: Validators.artistName,
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: genreController,
                    decoration: const InputDecoration(
                      labelText: 'Thể loại',
                      border: OutlineInputBorder(),
                    ),
                    validator: Validators.genre,
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text('Yêu thích'),
                    value: isFavorite,
                    onChanged: (value) {
                      setState(() => isFavorite = value ?? false);
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final updatedTrack = track.copyWith(
                    title: titleController.text.trim(),
                    duration: int.parse(durationController.text.trim()),
                    fileUrl: fileUrlController.text.trim(),
                    artist: artistController.text.trim().isEmpty
                        ? null
                        : artistController.text.trim(),
                    genre: genreController.text.trim().isEmpty
                        ? null
                        : genreController.text.trim(),
                    isFavorite: isFavorite,
                    updatedAt: DateTime.now(),
                  );

                  try {
                    await ref.read(trackListProvider.notifier).updateTrack(updatedTrack);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Sửa bài hát thành công'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Lỗi: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Track track) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa "${track.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              try {
                await ref.read(trackListProvider.notifier).deleteTrack(track.id!);
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã xóa bài hát thành công'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  final errorMessage = e.toString().replaceFirst('Exception: ', '');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lỗi: $errorMessage'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  Future<void> _scanDownloadsFolder(BuildContext context) async {
    // Hiển thị dialog loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Đang quét thư mục Downloads...'),
          ],
        ),
      ),
    );

    try {
      final importService = AudioImportService();
      final importedTracks = await importService.scanAndImportFromDownloads();

      if (context.mounted) {
        Navigator.pop(context); // Đóng dialog loading

        if (importedTracks.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không tìm thấy file nhạc mới trong thư mục Downloads'),
              backgroundColor: Colors.orange,
            ),
          );
        } else {
          // Refresh danh sách từ local DB để hiển thị ngay bài hát vừa thêm
          await ref.read(trackListProvider.notifier).loadTracks(fromLocal: true);

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Đã thêm ${importedTracks.length} bài hát mới'),
                backgroundColor: Colors.green,
                action: SnackBarAction(
                  label: 'Xem',
                  onPressed: () {
                    // Scroll to top hoặc refresh từ local
                    ref.read(trackListProvider.notifier).loadTracks(fromLocal: true);
                  },
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Đóng dialog loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi quét thư mục: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

