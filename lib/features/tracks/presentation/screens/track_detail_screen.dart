import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../../data/models/music_track_model.dart';
import '../../../../data/repositories/track_repository.dart';
import '../providers/track_providers.dart';
import '../../audio/presentation/providers/audio_providers.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_state_widget.dart';
import 'package:intl/intl.dart';

/// Screen to display track details and playback controls
class TrackDetailScreen extends ConsumerStatefulWidget {
  final int trackId;

  const TrackDetailScreen({super.key, required this.trackId});

  @override
  ConsumerState<TrackDetailScreen> createState() => _TrackDetailScreenState();
}

class _TrackDetailScreenState extends ConsumerState<TrackDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final trackAsync = ref.watch(
      FutureProvider((ref) async {
        final repository = ref.watch(trackRepositoryProvider);
        return await repository.getTrackById(widget.trackId);
      }),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Details'),
        actions: [
          if (trackAsync.value != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => context.go('/tracks/${widget.trackId}/edit'),
            ),
        ],
      ),
      body: trackAsync.when(
        data: (track) {
          if (track == null) {
            return const Center(child: Text('Track not found'));
          }
          return _buildTrackDetails(track);
        },
        loading: () => const LoadingWidget(message: 'Loading track...'),
        error: (error, stack) => ErrorStateWidget(
          message: 'Error loading track: $error',
          onRetry: () => ref.invalidate(trackAsync),
        ),
      ),
    );
  }

  Widget _buildTrackDetails(MusicTrack track) {
    final currentTrack = ref.watch(currentTrackProvider);
    final playbackState = ref.watch(playbackStateProvider);
    final playbackPosition = ref.watch(playbackPositionProvider);
    final trackDuration = ref.watch(trackDurationProvider);
    
    final isCurrentTrack = currentTrack?.id == track.id;
    final isPlaying = isCurrentTrack && playbackState == PlayerState.playing;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Icon(
                    Icons.music_note,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    track.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    track.artist,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (track.isFavorite)
                        Icon(
                          Icons.favorite,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      const SizedBox(width: 8),
                      Text(track.formattedDuration),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Playback controls
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (isCurrentTrack && trackDuration.inSeconds > 0) ...[
                    Slider(
                      value: playbackPosition.inSeconds.toDouble(),
                      min: 0,
                      max: trackDuration.inSeconds.toDouble(),
                      onChanged: (value) {
                        ref.read(audioActionsProvider).seek(
                              Duration(seconds: value.toInt()),
                            );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_formatDuration(playbackPosition)),
                          Text(_formatDuration(trackDuration)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.skip_previous),
                        iconSize: 32,
                        onPressed: () {},
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          if (isPlaying) {
                            ref.read(audioActionsProvider).pause();
                          } else {
                            ref.read(audioActionsProvider).playTrack(track);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(20),
                        ),
                        child: Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.skip_next),
                        iconSize: 32,
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Track information
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Track Information',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Title', track.title),
                  _buildInfoRow('Artist', track.artist),
                  _buildInfoRow('Duration', track.formattedDuration),
                  _buildInfoRow(
                    'Created',
                    DateFormat('yyyy-MM-dd HH:mm').format(track.createdAt),
                  ),
                  _buildInfoRow('File Path', track.filePath),
                  _buildInfoRow('Favorite', track.isFavorite ? 'Yes' : 'No'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Favorite button
          ElevatedButton.icon(
            onPressed: () async {
              await ref.read(trackActionsProvider).toggleFavorite(
                    track.id!,
                    !track.isFavorite,
                  );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      track.isFavorite
                          ? 'Removed from favorites'
                          : 'Added to favorites',
                    ),
                  ),
                );
              }
            },
            icon: Icon(track.isFavorite ? Icons.favorite : Icons.favorite_border),
            label: Text(track.isFavorite ? 'Remove from Favorites' : 'Add to Favorites'),
            style: ElevatedButton.styleFrom(
              backgroundColor: track.isFavorite
                  ? Theme.of(context).colorScheme.errorContainer
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
