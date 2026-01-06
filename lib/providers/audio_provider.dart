import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/track.dart';
import '../services/audio_service.dart';
import 'track_provider.dart';

enum RepeatMode { off, all, one }

class AudioState {
  final Track? currentTrack;
  final Duration position;
  final Duration duration;
  final PlayerState state;
  final RepeatMode repeatMode;
  final bool isShuffle;

  AudioState({
    this.currentTrack,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.state = PlayerState.stopped,
    this.repeatMode = RepeatMode.off,
    this.isShuffle = false,
  });

  AudioState copyWith({
    Track? currentTrack,
    Duration? position,
    Duration? duration,
    PlayerState? state,
    RepeatMode? repeatMode,
    bool? isShuffle,
  }) {
    return AudioState(
      currentTrack: currentTrack ?? this.currentTrack,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      state: state ?? this.state,
      repeatMode: repeatMode ?? this.repeatMode,
      isShuffle: isShuffle ?? this.isShuffle,
    );
  }
}

final audioServiceProvider = Provider<AudioService>((ref) {
  final s = AudioService();
  ref.onDispose(s.dispose);
  return s;
});

final audioStateProvider =
NotifierProvider<AudioNotifier, AudioState>(AudioNotifier.new);

class AudioNotifier extends Notifier<AudioState> {
  @override
  AudioState build() {
    final service = ref.read(audioServiceProvider);

    service.positionStream.listen(
          (p) => state = state.copyWith(position: p),
    );
    service.durationStream.listen(
          (d) => state = state.copyWith(duration: d),
    );
    service.stateStream.listen(
          (s) => state = state.copyWith(state: s),
    );

    return AudioState();
  }

  Future<void> playTrack(Track track) async {
    await ref.read(audioServiceProvider).playTrack(track);
    state = state.copyWith(currentTrack: track);
  }

  Future<void> pause() => ref.read(audioServiceProvider).pause();
  Future<void> resume() => ref.read(audioServiceProvider).resume();

  Future<void> stop() async {
    await ref.read(audioServiceProvider).stop();
    state = state.copyWith(currentTrack: null);
  }

  Future<void> seek(Duration d) =>
      ref.read(audioServiceProvider).seek(d);

  void toggleShuffle() =>
      state = state.copyWith(isShuffle: !state.isShuffle);

  void toggleRepeatMode() {
    final next = {
      RepeatMode.off: RepeatMode.all,
      RepeatMode.all: RepeatMode.one,
      RepeatMode.one: RepeatMode.off,
    }[state.repeatMode]!;
    state = state.copyWith(repeatMode: next);
  }

  Future<void> nextTrack() async {
    final tracks = ref.read(trackListProvider).tracks;
    if (tracks.isEmpty || state.currentTrack == null) return;

    final idx =
    tracks.indexWhere((t) => t.id == state.currentTrack!.id);
    final next = tracks[(idx + 1) % tracks.length];
    await playTrack(next);
  }

  Future<void> previousTrack() async {
    final tracks = ref.read(trackListProvider).tracks;
    if (tracks.isEmpty || state.currentTrack == null) return;

    final idx =
    tracks.indexWhere((t) => t.id == state.currentTrack!.id);
    final prev = tracks[(idx - 1 + tracks.length) % tracks.length];
    await playTrack(prev);
  }
}
