import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/track_providers.dart';
import '../providers/pagination_providers.dart';
import '../widgets/track_list_item.dart';
import '../widgets/loading_widget.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/error_state_widget.dart';
import '../../../../data/models/music_track_model.dart';

/// Screen to display list of all tracks
class TrackListScreen extends ConsumerStatefulWidget {
  const TrackListScreen({super.key});

  @override
  ConsumerState<TrackListScreen> createState() => _TrackListScreenState();
}

class _TrackListScreenState extends ConsumerState<TrackListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _sortField = 'createdAt';
  bool _sortAscending = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort Tracks'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Title'),
              value: 'title',
              groupValue: _sortField,
              onChanged: (value) {
                setState(() {
                  _sortField = value!;
                });
                Navigator.pop(context);
                ref.read(sortFieldProvider.notifier).state = value;
              },
            ),
            RadioListTile<String>(
              title: const Text('Artist'),
              value: 'artist',
              groupValue: _sortField,
              onChanged: (value) {
                setState(() {
                  _sortField = value!;
                });
                Navigator.pop(context);
                ref.read(sortFieldProvider.notifier).state = value;
              },
            ),
            RadioListTile<String>(
              title: const Text('Date Created'),
              value: 'createdAt',
              groupValue: _sortField,
              onChanged: (value) {
                setState(() {
                  _sortField = value!;
                });
                Navigator.pop(context);
                ref.read(sortFieldProvider.notifier).state = value;
              },
            ),
            RadioListTile<String>(
              title: const Text('Duration'),
              value: 'duration',
              groupValue: _sortField,
              onChanged: (value) {
                setState(() {
                  _sortField = value!;
                });
                Navigator.pop(context);
                ref.read(sortFieldProvider.notifier).state = value;
              },
            ),
            const Divider(),
            CheckboxListTile(
              title: const Text('Ascending'),
              value: _sortAscending,
              onChanged: (value) {
                setState(() {
                  _sortAscending = value!;
                });
                ref.read(sortAscendingProvider.notifier).state = value;
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteTrack(MusicTrack track) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Track'),
        content: Text('Are you sure you want to delete "${track.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && track.id != null) {
      try {
        await ref.read(trackActionsProvider).deleteTrack(track.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Track deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting track: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = ref.watch(searchQueryProvider);
    final sortField = ref.watch(sortFieldProvider);
    
    // Determine which provider to use based on search/sort state
    final tracksAsync = searchQuery.isNotEmpty
        ? ref.watch(filteredTracksProvider)
        : sortField != null
            ? ref.watch(sortedTracksProvider)
            : ref.watch(tracksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Tracks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search'),
            tooltip: 'Advanced Search',
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortDialog,
            tooltip: 'Sort',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by title or artist...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(searchQueryProvider.notifier).state = '';
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).state = value;
              },
            ),
          ),
          Expanded(
            child: tracksAsync.when(
              data: (tracks) {
                if (tracks.isEmpty) {
                  return EmptyStateWidget(
                    message: searchQuery.isNotEmpty
                        ? 'No tracks found matching "$searchQuery"'
                        : 'No tracks yet. Add your first track!',
                    action: ElevatedButton.icon(
                      onPressed: () => context.go('/tracks/add'),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Track'),
                    ),
                  );
                }
                // For now, show all tracks. Pagination can be enabled for very large lists
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(tracksProvider);
                    ref.invalidate(filteredTracksProvider);
                    ref.invalidate(sortedTracksProvider);
                  },
                  child: ListView.builder(
                    itemCount: tracks.length,
                    itemBuilder: (context, index) {
                      final track = tracks[index];
                      return TrackListItem(
                        track: track,
                        onTap: () => context.go('/tracks/${track.id}'),
                        onEdit: () => context.go('/tracks/${track.id}/edit'),
                        onDelete: () => _deleteTrack(track),
                      );
                    },
                  ),
                );
              },
              loading: () => const LoadingWidget(message: 'Loading tracks...'),
              error: (error, stack) => ErrorStateWidget(
                message: 'Error loading tracks: $error',
                onRetry: () {
                  ref.invalidate(tracksProvider);
                  ref.invalidate(filteredTracksProvider);
                  ref.invalidate(sortedTracksProvider);
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/tracks/add'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
