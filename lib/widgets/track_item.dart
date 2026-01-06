import 'package:flutter/material.dart';
import '../models/track.dart';

/// Widget hiển thị một track item trong danh sách
class TrackItem extends StatelessWidget {
  final Track track;
  final VoidCallback? onTap;
  final VoidCallback? onToggleFavorite;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final bool showActions;

  const TrackItem({
    super.key,
    required this.track,
    this.onTap,
    this.onToggleFavorite,
    this.onDelete,
    this.onEdit,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Icon(
            Icons.music_note,
            color: Colors.blue.shade700,
          ),
        ),
        title: Text(
          track.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (track.artist != null)
              Text(
                track.artist!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            if (track.genre != null)
              Text(
                '${track.genre} • ${track.formattedDuration}',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
              ),
          ],
        ),
        trailing: showActions
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onToggleFavorite != null)
                    IconButton(
                      icon: Icon(
                        track.isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: track.isFavorite ? Colors.red : null,
                      ),
                      onPressed: onToggleFavorite,
                      tooltip: track.isFavorite ? 'Bỏ yêu thích' : 'Yêu thích',
                    ),
                  if (onEdit != null)
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: onEdit,
                      tooltip: 'Sửa',
                    ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: onDelete,
                      tooltip: 'Xóa',
                    ),
                ],
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}

