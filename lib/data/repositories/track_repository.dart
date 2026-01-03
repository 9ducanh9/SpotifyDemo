import '../database/database_helper.dart';
import '../models/music_track_model.dart';

/// Repository for track data operations
class TrackRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Get all tracks
  Future<List<MusicTrack>> getAllTracks() async {
    return await _dbHelper.getAllTracks();
  }

  /// Get track by ID
  Future<MusicTrack?> getTrackById(int id) async {
    return await _dbHelper.getTrackById(id);
  }

  /// Search tracks
  Future<List<MusicTrack>> searchTracks(String query) async {
    if (query.isEmpty) {
      return await getAllTracks();
    }
    return await _dbHelper.searchTracks(query);
  }

  /// Get favorite tracks
  Future<List<MusicTrack>> getFavoriteTracks() async {
    return await _dbHelper.getFavoriteTracks();
  }

  /// Get tracks sorted by field
  Future<List<MusicTrack>> getTracksSortedBy(String field, {bool ascending = true}) async {
    return await _dbHelper.getTracksSortedBy(field, ascending: ascending);
  }

  /// Add a new track
  Future<int> addTrack(MusicTrack track) async {
    return await _dbHelper.insertTrack(track);
  }

  /// Update a track
  Future<int> updateTrack(MusicTrack track) async {
    if (track.id == null) {
      throw Exception('Cannot update track without ID');
    }
    return await _dbHelper.updateTrack(track);
  }

  /// Delete a track
  Future<int> deleteTrack(int id) async {
    return await _dbHelper.deleteTrack(id);
  }

  /// Toggle favorite status
  Future<int> toggleFavorite(int trackId, bool isFavorite) async {
    return await _dbHelper.toggleFavorite(trackId, isFavorite);
  }
}
