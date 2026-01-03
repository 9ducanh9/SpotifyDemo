import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/sync_service.dart';
import '../../../../core/services/connectivity_service.dart';

/// Sync service provider
final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService();
});

/// Connectivity status provider
final connectivityStatusProvider = StreamProvider<bool>((ref) async* {
  final connectivity = ref.watch(connectivityServiceProvider);
  yield await connectivity.isConnected();
  
  await for (final result in connectivity.connectivityStream) {
    yield result != ConnectivityResult.none;
  }
});

/// Sync status provider
final syncStatusProvider = StateProvider<String?>((ref) => null);

/// Sync actions provider
final syncActionsProvider = Provider<SyncActions>((ref) {
  return SyncActions(ref);
});

/// Class to handle sync actions
class SyncActions {
  final Ref _ref;

  SyncActions(this._ref);

  /// Sync to cloud
  Future<void> syncToCloud() async {
    try {
      _ref.read(syncStatusProvider.notifier).state = 'Syncing to cloud...';
      final syncService = _ref.read(syncServiceProvider);
      await syncService.syncToCloud();
      _ref.read(syncStatusProvider.notifier).state = 'Synced successfully';
    } catch (e) {
      _ref.read(syncStatusProvider.notifier).state = 'Sync failed: $e';
      rethrow;
    }
  }

  /// Sync from cloud
  Future<void> syncFromCloud() async {
    try {
      _ref.read(syncStatusProvider.notifier).state = 'Syncing from cloud...';
      final syncService = _ref.read(syncServiceProvider);
      await syncService.syncFromCloud();
      _ref.read(syncStatusProvider.notifier).state = 'Synced successfully';
      // Invalidate tracks to refresh UI
      _ref.invalidate(tracksProvider);
    } catch (e) {
      _ref.read(syncStatusProvider.notifier).state = 'Sync failed: $e';
      rethrow;
    }
  }

  /// Two-way sync
  Future<void> twoWaySync() async {
    try {
      _ref.read(syncStatusProvider.notifier).state = 'Syncing...';
      final syncService = _ref.read(syncServiceProvider);
      await syncService.twoWaySync();
      _ref.read(syncStatusProvider.notifier).state = 'Synced successfully';
      // Invalidate tracks to refresh UI
      _ref.invalidate(tracksProvider);
    } catch (e) {
      _ref.read(syncStatusProvider.notifier).state = 'Sync failed: $e';
      rethrow;
    }
  }
}
