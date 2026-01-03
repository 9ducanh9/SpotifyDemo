import 'package:flutter_test/flutter_test.dart';
import 'package:local_music_player/data/models/music_track_model.dart';

void main() {
  group('MusicTrack Model Tests', () {
    test('should create a MusicTrack with all required fields', () {
      final track = MusicTrack(
        id: 1,
        title: 'Test Song',
        artist: 'Test Artist',
        duration: 180,
        filePath: '/path/to/song.mp3',
        createdAt: DateTime(2024, 1, 1),
        isFavorite: false,
      );

      expect(track.id, 1);
      expect(track.title, 'Test Song');
      expect(track.artist, 'Test Artist');
      expect(track.duration, 180);
      expect(track.filePath, '/path/to/song.mp3');
      expect(track.isFavorite, false);
    });

    test('should format duration correctly as MM:SS', () {
      final track1 = MusicTrack(
        title: 'Song 1',
        artist: 'Artist',
        duration: 125,
        filePath: '/path/to/song.mp3',
        createdAt: DateTime.now(),
      );
      expect(track1.formattedDuration, '02:05');

      final track2 = MusicTrack(
        title: 'Song 2',
        artist: 'Artist',
        duration: 3661,
        filePath: '/path/to/song.mp3',
        createdAt: DateTime.now(),
      );
      expect(track2.formattedDuration, '61:01');
    });

    test('should convert to and from Map correctly', () {
      final originalTrack = MusicTrack(
        id: 1,
        title: 'Test Song',
        artist: 'Test Artist',
        duration: 180,
        filePath: '/path/to/song.mp3',
        createdAt: DateTime(2024, 1, 1, 12, 0, 0),
        isFavorite: true,
      );

      final map = originalTrack.toMap();
      final restoredTrack = MusicTrack.fromMap(map);

      expect(restoredTrack.id, originalTrack.id);
      expect(restoredTrack.title, originalTrack.title);
      expect(restoredTrack.artist, originalTrack.artist);
      expect(restoredTrack.duration, originalTrack.duration);
      expect(restoredTrack.filePath, originalTrack.filePath);
      expect(restoredTrack.isFavorite, originalTrack.isFavorite);
      expect(restoredTrack.createdAt, originalTrack.createdAt);
    });

    test('should create a copy with updated fields', () {
      final originalTrack = MusicTrack(
        id: 1,
        title: 'Original Title',
        artist: 'Original Artist',
        duration: 180,
        filePath: '/path/to/song.mp3',
        createdAt: DateTime(2024, 1, 1),
        isFavorite: false,
      );

      final updatedTrack = originalTrack.copyWith(
        title: 'Updated Title',
        isFavorite: true,
      );

      expect(updatedTrack.id, originalTrack.id);
      expect(updatedTrack.title, 'Updated Title');
      expect(updatedTrack.artist, originalTrack.artist);
      expect(updatedTrack.duration, originalTrack.duration);
      expect(updatedTrack.isFavorite, true);
    });

    test('should handle equality correctly', () {
      final track1 = MusicTrack(
        id: 1,
        title: 'Song',
        artist: 'Artist',
        duration: 180,
        filePath: '/path/to/song.mp3',
        createdAt: DateTime(2024, 1, 1),
        isFavorite: false,
      );

      final track2 = MusicTrack(
        id: 1,
        title: 'Song',
        artist: 'Artist',
        duration: 180,
        filePath: '/path/to/song.mp3',
        createdAt: DateTime(2024, 1, 1),
        isFavorite: false,
      );

      final track3 = MusicTrack(
        id: 2,
        title: 'Song',
        artist: 'Artist',
        duration: 180,
        filePath: '/path/to/song.mp3',
        createdAt: DateTime(2024, 1, 1),
        isFavorite: false,
      );

      expect(track1 == track2, true);
      expect(track1 == track3, false);
    });
  });
}
