import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../providers/audio_provider.dart';
import '../../providers/track_provider.dart';

class PlayerScreen extends ConsumerWidget {
  final int trackId;
  const PlayerScreen({super.key, required this.trackId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackState = ref.watch(trackListProvider);
    final audio = ref.watch(audioStateProvider);
    final notifier = ref.read(audioStateProvider.notifier);

    // Tìm track trong danh sách
    final track = trackState.tracks.firstWhere(
      (t) => t.id == trackId,
      orElse: () => throw Exception('Track not found'),
    );
    final isPlaying = audio.state == PlayerState.playing;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: IconButton(
          iconSize: 64,
          color: Colors.white,
          icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
          onPressed: () async {
            if (isPlaying) {
              await notifier.pause();
            } else {
              if (audio.currentTrack?.id == track.id) {
                await notifier.resume();
              } else {
                await notifier.playTrack(track);
              }
            }
          },
        ),
      ),
    );
  }
}
