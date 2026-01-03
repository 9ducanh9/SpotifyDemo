import 'package:flutter_test/flutter_test.dart';
import 'package:local_music_player/data/database/database_helper.dart';
import 'package:local_music_player/data/models/music_track_model.dart';
import 'package:local_music_player/data/models/user_model.dart';

void main() {
  late DatabaseHelper dbHelper;

  setUp(() async {
    dbHelper = DatabaseHelper.instance;
  });

  tearDown(() async {
    // Clean up test data
    await dbHelper.deleteAllTracks();
  });

  group('DatabaseHelper Tests', () {
    test('should insert and retrieve a track', () async {
      final track = MusicTrack(
        title: 'Test Song',
        artist: 'Test Artist',
        duration: 180,
        filePath: '/path/to/song.mp3',
        createdAt: DateTime.now(),
        isFavorite: false,
      );

      final id = await dbHelper.insertTrack(track);
      expect(id, greaterThan(0));

      final retrievedTrack = await dbHelper.getTrackById(id);
      expect(retrievedTrack, isNotNull);
      expect(retrievedTrack!.title, track.title);
      expect(retrievedTrack.artist, track.artist);
      expect(retrievedTrack.duration, track.duration);
    });

    test('should update a track', () async {
      final track = MusicTrack(
        title: 'Original',
        artist: 'Artist',
        duration: 180,
        filePath: '/path/to/song.mp3',
        createdAt: DateTime.now(),
      );

      final id = await dbHelper.insertTrack(track);
      final updatedTrack = track.copyWith(
        id: id,
        title: 'Updated',
      );

      await dbHelper.updateTrack(updatedTrack);
      final retrievedTrack = await dbHelper.getTrackById(id);
      expect(retrievedTrack!.title, 'Updated');
    });

    test('should delete a track', () async {
      final track = MusicTrack(
        title: 'To Delete',
        artist: 'Artist',
        duration: 180,
        filePath: '/path/to/song.mp3',
        createdAt: DateTime.now(),
      );

      final id = await dbHelper.insertTrack(track);
      await dbHelper.deleteTrack(id);

      final retrievedTrack = await dbHelper.getTrackById(id);
      expect(retrievedTrack, isNull);
    });

    test('should insert and retrieve a user', () async {
      final user = User(
        email: 'test@example.com',
        role: 'regular',
      );

      final id = await dbHelper.insertUser(user);
      expect(id, greaterThan(0));

      final retrievedUser = await dbHelper.getUserByEmail('test@example.com');
      expect(retrievedUser, isNotNull);
      expect(retrievedUser!.email, user.email);
      expect(retrievedUser.role, user.role);
    });

    test('should get tracks sorted by field', () async {
      final track1 = MusicTrack(
        title: 'B Song',
        artist: 'Artist',
        duration: 200,
        filePath: '/path/to/song1.mp3',
        createdAt: DateTime(2024, 1, 1),
      );

      final track2 = MusicTrack(
        title: 'A Song',
        artist: 'Artist',
        duration: 180,
        filePath: '/path/to/song2.mp3',
        createdAt: DateTime(2024, 1, 2),
      );

      await dbHelper.insertTrack(track1);
      await dbHelper.insertTrack(track2);

      final sortedTracks = await dbHelper.getTracksSortedBy('title', ascending: true);
      expect(sortedTracks.length, greaterThanOrEqualTo(2));
      // First track should be 'A Song' when sorted ascending
      expect(sortedTracks.first.title, 'A Song');
    });
  });
}
