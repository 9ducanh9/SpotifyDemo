import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:go_router/go_router.dart';
import '../providers/audio_provider.dart';
import '../providers/track_provider.dart';

/// Widget điều khiển phát nhạc (play/pause, next/previous, progress bar)
class PlayerControls extends ConsumerStatefulWidget {
  const PlayerControls({super.key});

  @override
  ConsumerState<PlayerControls> createState() => _PlayerControlsState();
}

class _PlayerControlsState extends ConsumerState<PlayerControls> {
  bool _isDragging = false;
  double _dragValue = 0.0;

  @override
  Widget build(BuildContext context) {
    final audioState = ref.watch(audioStateProvider);
    final audioNotifier = ref.read(audioStateProvider.notifier);
    final trackState = ref.watch(trackListProvider);

    if (audioState.currentTrack == null) {
      return const SizedBox.shrink();
    }

    final track = audioState.currentTrack!;
    final position = _isDragging ? Duration(seconds: _dragValue.toInt()) : audioState.position;
    final duration = audioState.duration;
    final isPlaying = audioState.state == PlayerState.playing;
    final repeatMode = audioState.repeatMode;
    final isShuffle = audioState.isShuffle;

    // Tự động chuyển bài tiếp theo khi bài hát kết thúc
    if (duration.inSeconds > 0 && 
        position.inSeconds >= duration.inSeconds && 
        isPlaying) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleTrackEnd(audioNotifier, repeatMode);
      });
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress bar
          if (duration.inSeconds > 0)
            Column(
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                  ),
                  child: Slider(
                    value: position.inSeconds.toDouble().clamp(0.0, duration.inSeconds.toDouble()),
                    max: duration.inSeconds.toDouble(),
                    onChanged: (value) {
                      setState(() {
                        _isDragging = true;
                        _dragValue = value;
                      });
                    },
                    onChangeEnd: (value) {
                      audioNotifier.seek(Duration(seconds: value.toInt()));
                      setState(() {
                        _isDragging = false;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(position),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        _formatDuration(duration),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          
          const SizedBox(height: 12),
          
          // Track info (tappable để mở player screen)
          InkWell(
            onTap: () {
              if (track.id != null) {
                context.push('/player/${track.id}');
              }
            },
            child: Column(
              children: [
                Text(
                  track.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (track.artist != null)
                  Text(
                    track.artist!,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Main control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Shuffle button
              IconButton(
                icon: Icon(
                  Icons.shuffle,
                  color: isShuffle ? Theme.of(context).primaryColor : Colors.grey,
                ),
                iconSize: 24,
                onPressed: () => audioNotifier.toggleShuffle(),
                tooltip: isShuffle ? 'Tắt phát ngẫu nhiên' : 'Bật phát ngẫu nhiên',
              ),
              
              const SizedBox(width: 8),
              
              // Previous button
              IconButton(
                icon: const Icon(Icons.skip_previous),
                iconSize: 32,
                onPressed: trackState.tracks.length > 1
                    ? () => audioNotifier.previousTrack()
                    : null,
                tooltip: 'Bài trước',
              ),
              
              const SizedBox(width: 8),
              
              // Play/Pause button
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).primaryColor,
                ),
                child: IconButton(
                  icon: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                  ),
                  iconSize: 32,
                  onPressed: () {
                    if (isPlaying) {
                      audioNotifier.pause();
                    } else {
                      audioNotifier.resume();
                    }
                  },
                  tooltip: isPlaying ? 'Tạm dừng' : 'Phát',
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Next button
              IconButton(
                icon: const Icon(Icons.skip_next),
                iconSize: 32,
                onPressed: trackState.tracks.length > 1
                    ? () => audioNotifier.nextTrack()
                    : null,
                tooltip: 'Bài tiếp',
              ),
              
              const SizedBox(width: 8),
              
              // Repeat button
              IconButton(
                icon: Icon(
                  repeatMode == RepeatMode.one
                      ? Icons.repeat_one
                      : Icons.repeat,
                  color: repeatMode != RepeatMode.off
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                ),
                iconSize: 24,
                onPressed: () => audioNotifier.toggleRepeatMode(),
                tooltip: repeatMode == RepeatMode.off
                    ? 'Lặp lại tất cả'
                    : repeatMode == RepeatMode.all
                        ? 'Lặp lại một bài'
                        : 'Tắt lặp lại',
              ),
            ],
          ),
          
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  /// Xử lý khi bài hát kết thúc (tự động chuyển bài hoặc lặp lại)
  void _handleTrackEnd(AudioNotifier audioNotifier, RepeatMode repeatMode) {
    if (repeatMode == RepeatMode.one) {
      // Lặp lại bài hiện tại
      final currentTrack = ref.read(audioStateProvider).currentTrack;
      if (currentTrack != null) {
        audioNotifier.playTrack(currentTrack);
      }
    } else if (repeatMode == RepeatMode.all || repeatMode == RepeatMode.off) {
      // Chuyển sang bài tiếp theo (hoặc dừng nếu repeatMode.off và hết danh sách)
      audioNotifier.nextTrack();
    }
  }

  /// Định dạng Duration thành chuỗi MM:SS
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
