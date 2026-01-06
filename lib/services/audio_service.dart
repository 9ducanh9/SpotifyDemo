import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import '../models/track.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();

  final _positionController = StreamController<Duration>.broadcast();
  final _durationController = StreamController<Duration>.broadcast();
  final _stateController = StreamController<PlayerState>.broadcast();

  Stream<Duration> get positionStream => _positionController.stream;
  Stream<Duration> get durationStream => _durationController.stream;
  Stream<PlayerState> get stateStream => _stateController.stream;

  Track? _currentTrack;

  AudioService() {
    _init();
  }

  Future<void> _init() async {
    await _player.setPlayerMode(PlayerMode.mediaPlayer);
    await _player.setVolume(1.0);
    await _player.setPlaybackRate(1.0);

    _player.onPositionChanged.listen(_positionController.add);
    _player.onDurationChanged.listen(_durationController.add);
    _player.onPlayerStateChanged.listen(_stateController.add);
  }

  Future<void> playTrack(Track track) async {
    if (_currentTrack?.id == track.id &&
        _player.state == PlayerState.playing) {
      return;
    }

    _currentTrack = track;
    await _player.stop();

    final source = track.fileUrl.startsWith('http')
        ? UrlSource(track.fileUrl)
        : DeviceFileSource(track.fileUrl);

    await _player.play(source);
  }

  Future<void> pause() => _player.pause();
  Future<void> resume() => _player.resume();

  Future<void> stop() async {
    await _player.stop();
    _currentTrack = null;
  }

  Future<void> seek(Duration d) => _player.seek(d);

  Track? get currentTrack => _currentTrack;

  Future<void> dispose() async {
    await _player.dispose();
    await _positionController.close();
    await _durationController.close();
    await _stateController.close();
  }
}
