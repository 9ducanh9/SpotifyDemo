import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/track_provider.dart';
import '../../widgets/track_item.dart';
import '../../widgets/loading_indicator.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  String _selectedSort = 'title';
  String? _selectedGenre;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trackState = ref.watch(trackListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tìm kiếm'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Tìm kiếm bài hát',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              ref.read(trackListProvider.notifier).loadTracks();
                            },
                          )
                        : null,
                    border: const OutlineInputBorder(),
                  ),
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      ref.read(trackListProvider.notifier).search(value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedSort,
                        decoration: const InputDecoration(
                          labelText: 'Sắp xếp',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'title', child: Text('Theo tên')),
                          DropdownMenuItem(value: 'play_count', child: Text('Theo lượt phát')),
                          DropdownMenuItem(value: 'created_at', child: Text('Theo ngày tạo')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedSort = value);
                            ref.read(trackListProvider.notifier).sortBy(value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedGenre,
                        decoration: const InputDecoration(
                          labelText: 'Thể loại',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: null, child: Text('Tất cả')),
                          DropdownMenuItem(value: 'Pop', child: Text('Pop')),
                          DropdownMenuItem(value: 'Rock', child: Text('Rock')),
                          DropdownMenuItem(value: 'Jazz', child: Text('Jazz')),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedGenre = value);                          ref.read(trackListProvider.notifier).filterByGenre(value);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildResults(trackState),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(TrackListState state) {
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
          ],
        ),
      );
    }

    if (state.tracks.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Không tìm thấy kết quả'),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: state.tracks.length,
      padding: const EdgeInsets.all(8),
      itemBuilder: (context, index) {
        final track = state.tracks[index];
        return TrackItem(
          track: track,
          onTap: () => context.push('/player/${track.id}'),
        );
      },
    );
  }
}

