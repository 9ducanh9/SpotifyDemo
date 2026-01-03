import 'package:flutter/material.dart';
import '../../../../data/models/music_track_model.dart';
import '../../../../features/audio/presentation/providers/audio_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Widget to display a track in a list
class TrackListItem extends ConsumerWidget {
  final MusicTrack track;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TrackListItem({
    super.key,
    required this.track,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTrack = ref.watch(currentTrackProvider);
    final playbackState = ref.watch(playbackStateProvider);
    final isPlaying = currentTrack?.id == track.id &&
        playbackState == PlayerState.playing;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Icon(
            isPlaying ? Icons.pause : Icons.music_note,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        title: Text(
          track.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(track.artist),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  track.formattedDuration,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (track.isFavorite) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.favorite,
                    size: 16,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (track.isFavorite)
              IconButton(
                icon: const Icon(Icons.favorite),
                color: Theme.of(context).colorScheme.error,
                onPressed: () {
                  ref.read(trackActionsProvider).toggleFavorite(
                        track.id!,
                        false,
                      );
                },
              )
            else
              IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: () {
                  ref.read(trackActionsProvider).toggleFavorite(
                        track.id!,
                        true,
                      );
                },
              ),
            PopupMenuButton(
              itemBuilder: (context) => [
                if (onEdit != null)
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                if (onDelete != null)
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
              ],
              onSelected: (value) {
                if (value == 'edit' && onEdit != null) {
                  onEdit!();
                } else if (value == 'delete' && onDelete != null) {
                  onDelete!();
                }
              },
            ),
          ],
        ),
        onTap: onTap ?? () {
          ref.read(audioActionsProvider).playTrack(track);
        },
      ),
    );
  }
}
