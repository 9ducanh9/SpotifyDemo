import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/track_providers.dart';
import '../widgets/track_list_item.dart';
import '../widgets/loading_widget.dart';
import '../widgets/empty_state_widget.dart';
import '../../../../data/models/music_track_model.dart';

/// Advanced search screen with multi-criteria filtering
class AdvancedSearchScreen extends ConsumerStatefulWidget {
  const AdvancedSearchScreen({super.key});

  @override
  ConsumerState<AdvancedSearchScreen> createState() =>
      _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends ConsumerState<AdvancedSearchScreen> {
  final _titleController = TextEditingController();
  final _artistController = TextEditingController();
  final _minDurationController = TextEditingController();
  final _maxDurationController = TextEditingController();
  bool _favoritesOnly = false;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _minDurationController.dispose();
    _maxDurationController.dispose();
    super.dispose();
  }

  List<MusicTrack> _filterTracks(List<MusicTrack> tracks) {
    return tracks.where((track) {
      // Title filter
      if (_titleController.text.isNotEmpty) {
        if (!track.title
            .toLowerCase()
            .contains(_titleController.text.toLowerCase())) {
          return false;
        }
      }

      // Artist filter
      if (_artistController.text.isNotEmpty) {
        if (!track.artist
            .toLowerCase()
            .contains(_artistController.text.toLowerCase())) {
          return false;
        }
      }

      // Duration filters
      if (_minDurationController.text.isNotEmpty) {
        final minDuration = int.tryParse(_minDurationController.text);
        if (minDuration != null && track.duration < minDuration) {
          return false;
        }
      }

      if (_maxDurationController.text.isNotEmpty) {
        final maxDuration = int.tryParse(_maxDurationController.text);
        if (maxDuration != null && track.duration > maxDuration) {
          return false;
        }
      }

      // Favorites filter
      if (_favoritesOnly && !track.isFavorite) {
        return false;
      }

      // Date filters
      if (_startDate != null && track.createdAt.isBefore(_startDate!)) {
        return false;
      }

      if (_endDate != null && track.createdAt.isAfter(_endDate!)) {
        return false;
      }

      return true;
    }).toList();
  }

  void _clearFilters() {
    setState(() {
      _titleController.clear();
      _artistController.clear();
      _minDurationController.clear();
      _maxDurationController.clear();
      _favoritesOnly = false;
      _startDate = null;
      _endDate = null;
    });
  }

  Future<void> _selectDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? (_startDate ?? DateTime.now()) : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tracksAsync = ref.watch(tracksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Search'),
      ),
      body: Column(
        children: [
          // Filters panel
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Filters',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      prefixIcon: Icon(Icons.title),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _artistController,
                    decoration: const InputDecoration(
                      labelText: 'Artist',
                      prefixIcon: Icon(Icons.person),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _minDurationController,
                          decoration: const InputDecoration(
                            labelText: 'Min Duration (s)',
                            prefixIcon: Icon(Icons.timer),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _maxDurationController,
                          decoration: const InputDecoration(
                            labelText: 'Max Duration (s)',
                            prefixIcon: Icon(Icons.timer_outlined),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    title: const Text('Favorites only'),
                    value: _favoritesOnly,
                    onChanged: (value) {
                      setState(() => _favoritesOnly = value ?? false);
                    },
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _selectDate(true),
                          icon: const Icon(Icons.calendar_today),
                          label: Text(_startDate == null
                              ? 'Start Date'
                              : 'From: ${_startDate!.toString().split(' ')[0]}'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _selectDate(false),
                          icon: const Icon(Icons.calendar_today),
                          label: Text(_endDate == null
                              ? 'End Date'
                              : 'To: ${_endDate!.toString().split(' ')[0]}'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: _clearFilters,
                    child: const Text('Clear Filters'),
                  ),
                ],
              ),
            ),
          ),
          // Results
          Expanded(
            child: tracksAsync.when(
              data: (tracks) {
                final filteredTracks = _filterTracks(tracks);
                if (filteredTracks.isEmpty) {
                  return EmptyStateWidget(
                    message: 'No tracks match your filters',
                    icon: Icons.search_off,
                  );
                }
                return ListView.builder(
                  itemCount: filteredTracks.length,
                  itemBuilder: (context, index) {
                    final track = filteredTracks[index];
                    return TrackListItem(
                      track: track,
                      onTap: () => context.go('/tracks/${track.id}'),
                      onEdit: () => context.go('/tracks/${track.id}/edit'),
                      onDelete: () async {
                        if (track.id != null) {
                          await ref
                              .read(trackActionsProvider)
                              .deleteTrack(track.id!);
                        }
                      },
                    );
                  },
                );
              },
              loading: () => const LoadingWidget(),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }
}
