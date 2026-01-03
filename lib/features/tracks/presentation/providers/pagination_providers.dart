import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/music_track_model.dart';
import 'track_providers.dart';

/// Pagination state provider
final paginationStateProvider = StateProvider<PaginationState>((ref) {
  return PaginationState(page: 0, pageSize: 20, hasMore: true);
});

/// Paginated tracks provider
final paginatedTracksProvider = FutureProvider<List<MusicTrack>>((ref) async {
  final pagination = ref.watch(paginationStateProvider);
  final repository = ref.watch(trackRepositoryProvider);
  
  // Get all tracks
  final allTracks = await repository.getAllTracks();
  
  // Calculate pagination
  final startIndex = pagination.page * pagination.pageSize;
  final endIndex = startIndex + pagination.pageSize;
  
  if (startIndex >= allTracks.length) {
    return [];
  }
  
  final paginatedTracks = allTracks.sublist(
    startIndex,
    endIndex > allTracks.length ? allTracks.length : endIndex,
  );
  
  // Update hasMore
  ref.read(paginationStateProvider.notifier).state = pagination.copyWith(
    hasMore: endIndex < allTracks.length,
  );
  
  return paginatedTracks;
});

/// Pagination state class
class PaginationState {
  final int page;
  final int pageSize;
  final bool hasMore;

  PaginationState({
    required this.page,
    required this.pageSize,
    required this.hasMore,
  });

  PaginationState copyWith({
    int? page,
    int? pageSize,
    bool? hasMore,
  }) {
    return PaginationState(
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

/// Pagination actions provider
final paginationActionsProvider = Provider<PaginationActions>((ref) {
  return PaginationActions(ref);
});

/// Class to handle pagination actions
class PaginationActions {
  final Ref _ref;

  PaginationActions(this._ref);

  /// Load next page
  void loadNextPage() {
    final current = _ref.read(paginationStateProvider);
    if (current.hasMore) {
      _ref.read(paginationStateProvider.notifier).state =
          current.copyWith(page: current.page + 1);
      _ref.invalidate(paginatedTracksProvider);
    }
  }

  /// Reset pagination
  void reset() {
    _ref.read(paginationStateProvider.notifier).state = PaginationState(
      page: 0,
      pageSize: 20,
      hasMore: true,
    );
    _ref.invalidate(paginatedTracksProvider);
  }
}
