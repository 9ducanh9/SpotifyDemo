import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/track.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

final databaseServiceProvider = Provider<LocalDatabaseService>((ref) {
  return LocalDatabaseService();
});

final trackListProvider =
NotifierProvider<TrackListNotifier, TrackListState>(
    TrackListNotifier.new);

class TrackListState {
  final List<Track> tracks;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final String sortBy;

  TrackListState({
    this.tracks = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.sortBy = 'title',
  });

  TrackListState copyWith({
    List<Track>? tracks,
    bool? isLoading,
    String? error,
    String? searchQuery,
    String? sortBy,
  }) {
    return TrackListState(
      tracks: tracks ?? this.tracks,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

class TrackListNotifier extends Notifier<TrackListState> {
  @override
  TrackListState build() {
    Future.microtask(() => loadTracks());
    return TrackListState();
  }

  LocalDatabaseService get _db => ref.read(databaseServiceProvider);

  Future<void> loadTracks({bool fromLocal = false}) async {
    state = state.copyWith(isLoading: true);
    try {
      final tracks = await _db.getAllTracks(
        search: state.searchQuery.isEmpty ? null : state.searchQuery,
        sortBy: state.sortBy,
      );
      state = state.copyWith(tracks: tracks, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> search(String query) async {
    state = state.copyWith(searchQuery: query);
    await loadTracks();
  }

  Future<void> sortBy(String field) async {
    state = state.copyWith(sortBy: field);
    await loadTracks();
  }

  Future<void> filterByGenre(String? genre) async {
    state = state.copyWith(isLoading: true);
    final tracks = await _db.getAllTracks(
      search: state.searchQuery.isEmpty ? null : state.searchQuery,
      sortBy: state.sortBy,
      genre: genre,
    );
    state = state.copyWith(tracks: tracks, isLoading: false);
  }

  Future<void> updateTrack(Track track) async {
    await _db.updateTrack(track);
    await loadTracks();
  }

  Future<void> deleteTrack(int id) async {
    await _db.deleteTrack(id);
    await loadTracks();
  }
}
