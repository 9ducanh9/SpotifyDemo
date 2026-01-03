import 'package:flutter_test/flutter_test.dart';
import 'package:local_music_player/data/repositories/track_repository.dart';
import 'package:local_music_player/data/models/music_track_model.dart';
import 'package:local_music_player/data/database/database_helper.dart';

void main() {
  late TrackRepository repository;
  late DatabaseHelper dbHelper;

  setUp(() async {
    dbHelper = DatabaseHelper.instance;
    repository = TrackRepository();
  });

  tearDown(() async {
    // Clean up test data
    await dbHelper.deleteAllTracks();
  });

  group('TrackRepository Tests', () {
    test('should add a new track', () async {
      final track = MusicTrack(
        title: 'Test Song',
        artist: 'Test Artist',
        duration: 180,
        filePath: '/path/to/song.mp3',
        createdAt: DateTime.now(),
      );

      final id = await repository.addTrack(track);
      expect(id, greaterThan(0));

      final retrievedTrack = await repository.getTrackById(id);
      expect(retrievedTrack, isNotNull);
      expect(retrievedTrack!.title, track.title);
      expect(retrievedTrack.artist, track.artist);
    });

    test('should retrieve all tracks', () async {
      // Add multiple tracks
      final track1 = MusicTrack(
        title: 'Song 1',
        artist: 'Artist 1',
        duration: 180,
        filePath: '/path/to/song1.mp3',
        createdAt: DateTime.now(),
      );

      final track2 = MusicTrack(
        title: 'Song 2',
        artist: 'Artist 2',
        duration: 200,
        filePath: '/path/to/song2.mp3',
        createdAt: DateTime.now(),
      );

      await repository.addTrack(track1);
      await repository.addTrack(track2);

      final allTracks = await repository.getAllTracks();
      expect(allTracks.length, greaterThanOrEqualTo(2));
    });

    test('should search tracks by title or artist', () async {
      final track1 = MusicTrack(
        title: 'Amazing Song',
        artist: 'Great Artist',
        duration: 180,
        filePath: '/path/to/song1.mp3',
        createdAt: DateTime.now(),
      );

      final track2 = MusicTrack(
        title: 'Another Song',
        artist: 'Amazing Singer',
        duration: 200,
        filePath: '/path/to/song2.mp3',
        createdAt: DateTime.now(),
      );

      await repository.addTrack(track1);
      await repository.addTrack(track2);

      // Search by title
      final results1 = await repository.searchTracks('Amazing');
      expect(results1.length, greaterThanOrEqualTo(1));
      expect(results1.any((t) => t.title.contains('Amazing')), true);

      // Search by artist
      final results2 = await repository.searchTracks('Amazing');
      expect(results2.length, greaterThanOrEqualTo(1));
    });

    test('should update a track', () async {
      final track = MusicTrack(
        title: 'Original Title',
        artist: 'Original Artist',
        duration: 180,
        filePath: '/path/to/song.mp3',
        createdAt: DateTime.now(),
      );

      final id = await repository.addTrack(track);
      final updatedTrack = track.copyWith(
        id: id,
        title: 'Updated Title',
        artist: 'Updated Artist',
      );

      await repository.updateTrack(updatedTrack);

      final retrievedTrack = await repository.getTrackById(id);
      expect(retrievedTrack!.title, 'Updated Title');
      expect(retrievedTrack.artist, 'Updated Artist');
    });

    test('should delete a track', () async {
      final track = MusicTrack(
        title: 'To Delete',
        artist: 'Artist',
        duration: 180,
        filePath: '/path/to/song.mp3',
        createdAt: DateTime.now(),
      );

      final id = await repository.addTrack(track);
      await repository.deleteTrack(id);

      final retrievedTrack = await repository.getTrackById(id);
      expect(retrievedTrack, isNull);
    });

    test('should toggle favorite status', () async {
      final track = MusicTrack(
        title: 'Favorite Song',
        artist: 'Artist',
        duration: 180,
        filePath: '/path/to/song.mp3',
        createdAt: DateTime.now(),
        isFavorite: false,
      );

      final id = await repository.addTrack(track);
      
      // Toggle to favorite
      await repository.toggleFavorite(id, true);
      var retrievedTrack = await repository.getTrackById(id);
      expect(retrievedTrack!.isFavorite, true);

      // Toggle back to not favorite
      await repository.toggleFavorite(id, false);
      retrievedTrack = await repository.getTrackById(id);
      expect(retrievedTrack!.isFavorite, false);
    });

    test('should get favorite tracks only', () async {
      final track1 = MusicTrack(
        title: 'Favorite 1',
        artist: 'Artist',
        duration: 180,
        filePath: '/path/to/song1.mp3',
        createdAt: DateTime.now(),
        isFavorite: true,
      );

      final track2 = MusicTrack(
        title: 'Not Favorite',
        artist: 'Artist',
        duration: 180,
        filePath: '/path/to/song2.mp3',
        createdAt: DateTime.now(),
        isFavorite: false,
      );

      await repository.addTrack(track1);
      await repository.addTrack(track2);

      final favorites = await repository.getFavoriteTracks();
      expect(favorites.length, greaterThanOrEqualTo(1));
      expect(favorites.every((t) => t.isFavorite), true);
    });
  });
}
