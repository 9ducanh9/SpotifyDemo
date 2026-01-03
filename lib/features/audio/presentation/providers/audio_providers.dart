import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../../data/models/music_track_model.dart';

/// Provider for audio player instance
final audioPlayerProvider = Provider<AudioPlayer>((ref) {
  final player = AudioPlayer();
  ref.onDispose(() {
    player.dispose();
  });
  return player;
});

/// Provider for currently playing track
final currentTrackProvider = StateProvider<MusicTrack?>((ref) => null);

/// Provider for playback state
final playbackStateProvider = StateProvider<PlayerState>((ref) => PlayerState.stopped);

/// Provider for playback position
final playbackPositionProvider = StateProvider<Duration>((ref) => Duration.zero);

/// Provider for track duration
final trackDurationProvider = StateProvider<Duration>((ref) => Duration.zero);

/// Provider for audio actions
final audioActionsProvider = Provider<AudioActions>((ref) {
  final player = ref.watch(audioPlayerProvider);
  return AudioActions(player, ref);
});

/// Class to handle audio playback actions
class AudioActions {
  final AudioPlayer _player;
  final Ref _ref;

  AudioActions(this._player, this._ref) {
    _setupListeners();
  }

  void _setupListeners() {
    // Listen to player state changes
    _player.onPlayerStateChanged.listen((state) {
      _ref.read(playbackStateProvider.notifier).state = state;
    });

    // Listen to position changes
    _player.onPositionChanged.listen((position) {
      _ref.read(playbackPositionProvider.notifier).state = position;
    });

    // Listen to duration changes
    _player.onDurationChanged.listen((duration) {
      _ref.read(trackDurationProvider.notifier).state = duration;
    });

    // Listen to completion
    _player.onPlayerComplete.listen((_) {
      _ref.read(playbackStateProvider.notifier).state = PlayerState.stopped;
      _ref.read(playbackPositionProvider.notifier).state = Duration.zero;
    });
  }

  /// Play a track
  Future<void> playTrack(MusicTrack track) async {
    final currentTrack = _ref.read(currentTrackProvider);
    
    // If same track is playing, resume/pause
    if (currentTrack?.id == track.id) {
      final state = _ref.read(playbackStateProvider);
      if (state == PlayerState.playing) {
        await pause();
      } else {
        await resume();
      }
      return;
    }

    // Stop current track and play new one
    await _player.stop();
    _ref.read(currentTrackProvider.notifier).state = track;
    await _player.play(DeviceFileSource(track.filePath));
  }

  /// Pause playback
  Future<void> pause() async {
    await _player.pause();
  }

  /// Resume playback
  Future<void> resume() async {
    await _player.resume();
  }

  /// Stop playback
  Future<void> stop() async {
    await _player.stop();
    _ref.read(currentTrackProvider.notifier).state = null;
    _ref.read(playbackPositionProvider.notifier).state = Duration.zero;
  }

  /// Seek to position
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }
}
