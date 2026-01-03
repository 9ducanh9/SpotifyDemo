import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/repositories/track_repository.dart';
import '../../../../data/models/music_track_model.dart';

/// Repository provider
final trackRepositoryProvider = Provider<TrackRepository>((ref) {
  return TrackRepository();
});

/// Provider for all tracks
final tracksProvider = FutureProvider<List<MusicTrack>>((ref) async {
  final repository = ref.watch(trackRepositoryProvider);
  return await repository.getAllTracks();
});

/// Provider for search query
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Provider for filtered/sorted tracks
final filteredTracksProvider = FutureProvider<List<MusicTrack>>((ref) async {
  final repository = ref.watch(trackRepositoryProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  
  if (searchQuery.isEmpty) {
    return await repository.getAllTracks();
  }
  return await repository.searchTracks(searchQuery);
});

/// Provider for favorite tracks
final favoriteTracksProvider = FutureProvider<List<MusicTrack>>((ref) async {
  final repository = ref.watch(trackRepositoryProvider);
  return await repository.getFavoriteTracks();
});

/// Provider for sort field
final sortFieldProvider = StateProvider<String?>((ref) => null);

/// Provider for sort ascending
final sortAscendingProvider = StateProvider<bool>((ref) => true);

/// Provider for sorted tracks
final sortedTracksProvider = FutureProvider<List<MusicTrack>>((ref) async {
  final repository = ref.watch(trackRepositoryProvider);
  final sortField = ref.watch(sortFieldProvider);
  
  if (sortField == null) {
    return await repository.getAllTracks();
  }
  
  final ascending = ref.watch(sortAscendingProvider);
  return await repository.getTracksSortedBy(sortField, ascending: ascending);
});

/// Provider for track actions (add, update, delete)
final trackActionsProvider = Provider<TrackActions>((ref) {
  final repository = ref.watch(trackRepositoryProvider);
  return TrackActions(repository, ref);
});

/// Class to handle track actions and refresh providers
class TrackActions {
  final TrackRepository _repository;
  final Ref _ref;

  TrackActions(this._repository, this._ref);

  /// Add a new track
  Future<int> addTrack(MusicTrack track) async {
    final result = await _repository.addTrack(track);
    _ref.invalidate(tracksProvider);
    _ref.invalidate(filteredTracksProvider);
    _ref.invalidate(favoriteTracksProvider);
    _ref.invalidate(sortedTracksProvider);
    return result;
  }

  /// Update a track
  Future<int> updateTrack(MusicTrack track) async {
    final result = await _repository.updateTrack(track);
    _ref.invalidate(tracksProvider);
    _ref.invalidate(filteredTracksProvider);
    _ref.invalidate(favoriteTracksProvider);
    _ref.invalidate(sortedTracksProvider);
    return result;
  }

  /// Delete a track
  Future<int> deleteTrack(int id) async {
    final result = await _repository.deleteTrack(id);
    _ref.invalidate(tracksProvider);
    _ref.invalidate(filteredTracksProvider);
    _ref.invalidate(favoriteTracksProvider);
    _ref.invalidate(sortedTracksProvider);
    return result;
  }

  /// Toggle favorite status
  Future<int> toggleFavorite(int trackId, bool isFavorite) async {
    final result = await _repository.toggleFavorite(trackId, isFavorite);
    _ref.invalidate(tracksProvider);
    _ref.invalidate(filteredTracksProvider);
    _ref.invalidate(favoriteTracksProvider);
    _ref.invalidate(sortedTracksProvider);
    return result;
  }
}
