import '../../data/models/music_track_model.dart';
import '../../data/database/database_helper.dart';
import '../../core/services/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Conflict resolution strategies
enum ConflictResolutionStrategy {
  keepLatest,      // Keep the latest version (by timestamp)
  keepLocal,       // Always keep local version
  keepCloud,       // Always keep cloud version
  askUser,         // Ask user to choose
}

/// Conflict data model
class ConflictData {
  final MusicTrack localTrack;
  final Map<String, dynamic> cloudTrack;
  final DateTime localModifiedAt;
  final DateTime cloudModifiedAt;

  ConflictData({
    required this.localTrack,
    required this.cloudTrack,
    required this.localModifiedAt,
    required this.cloudModifiedAt,
  });
}

/// Service to handle data conflicts during cloud sync
class ConflictResolutionService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Detect conflicts between local and cloud data
  Future<List<ConflictData>> detectConflicts(String userId) async {
    final conflicts = <ConflictData>[];
    final localTracks = await _dbHelper.getAllTracks();
    
    // Get cloud tracks
    final cloudSnapshot = await FirebaseService.getTracksFromCloud(userId).first;
    
    for (final localTrack in localTracks) {
      if (localTrack.id == null) continue;
      
      final cloudDoc = cloudSnapshot.docs.firstWhere(
        (doc) => doc.data()['id'] == localTrack.id,
        orElse: () => throw Exception('Track not found in cloud'),
      );
      
      final cloudData = cloudDoc.data() as Map<String, dynamic>;
      final cloudModifiedAt = cloudData['lastModifiedAt'] != null
          ? DateTime.parse(cloudData['lastModifiedAt'] as String)
          : DateTime.parse(cloudData['createdAt'] as String);
      
      final localModifiedAt = localTrack.lastModifiedAt ?? localTrack.createdAt;
      
      // Check if there's a conflict (both modified, but differently)
      if (cloudModifiedAt.isAfter(localTrack.createdAt) &&
          localModifiedAt.isAfter(DateTime.parse(cloudData['createdAt'] as String))) {
        // Both have been modified - potential conflict
        if (!_areTracksEqual(localTrack, cloudData)) {
          conflicts.add(
            ConflictData(
              localTrack: localTrack,
              cloudTrack: cloudData,
              localModifiedAt: localModifiedAt,
              cloudModifiedAt: cloudModifiedAt,
            ),
          );
        }
      }
    }
    
    return conflicts;
  }

  /// Check if tracks are equal (ignoring timestamps)
  bool _areTracksEqual(MusicTrack local, Map<String, dynamic> cloud) {
    return local.title == cloud['title'] &&
           local.artist == cloud['artist'] &&
           local.duration == cloud['duration'] &&
           local.isFavorite == (cloud['isFavorite'] as bool? ?? false) &&
           local.workflowStatus.value == (cloud['workflowStatus'] as String? ?? 'draft');
  }

  /// Resolve conflicts using specified strategy
  Future<void> resolveConflicts(
    List<ConflictData> conflicts,
    ConflictResolutionStrategy strategy,
  ) async {
    for (final conflict in conflicts) {
      switch (strategy) {
        case ConflictResolutionStrategy.keepLatest:
          await _resolveKeepLatest(conflict);
          break;
        case ConflictResolutionStrategy.keepLocal:
          await _resolveKeepLocal(conflict);
          break;
        case ConflictResolutionStrategy.keepCloud:
          await _resolveKeepCloud(conflict);
          break;
        case ConflictResolutionStrategy.askUser:
          // This would be handled in UI
          break;
      }
    }
  }

  /// Resolve conflict by keeping the latest version
  Future<void> _resolveKeepLatest(ConflictData conflict) async {
    if (conflict.cloudModifiedAt.isAfter(conflict.localModifiedAt)) {
      // Cloud is newer - keep cloud
      await _resolveKeepCloud(conflict);
    } else {
      // Local is newer - keep local
      await _resolveKeepLocal(conflict);
    }
  }

  /// Resolve conflict by keeping local version
  Future<void> _resolveKeepLocal(ConflictData conflict) async {
    // Update cloud with local version
    final user = FirebaseService.currentUser;
    if (user != null && conflict.localTrack.id != null) {
      await FirebaseService.syncTrackToCloud(
        trackId: conflict.localTrack.id.toString(),
        trackData: conflict.localTrack.toMap(),
        userId: user.uid,
      );
    }
  }

  /// Resolve conflict by keeping cloud version
  Future<void> _resolveKeepCloud(ConflictData conflict) async {
    // Update local with cloud version
    final cloudTrack = MusicTrack.fromMap(conflict.cloudTrack);
    await _dbHelper.updateTrack(cloudTrack);
  }

  /// Merge conflicts (combine non-conflicting fields)
  Future<void> mergeConflicts(ConflictData conflict) async {
    // Merge strategy: keep cloud for most fields, but preserve local favorites
    final mergedTrack = conflict.localTrack.copyWith(
      title: conflict.cloudTrack['title'] as String,
      artist: conflict.cloudTrack['artist'] as String,
      duration: conflict.cloudTrack['duration'] as int,
      workflowStatus: WorkflowStatusExtension.fromString(
        conflict.cloudTrack['workflowStatus'] as String? ?? 'draft',
      ),
      // Keep local favorite status
    );

    await _dbHelper.updateTrack(mergedTrack);

    // Update cloud
    final user = FirebaseService.currentUser;
    if (user != null && mergedTrack.id != null) {
      await FirebaseService.syncTrackToCloud(
        trackId: mergedTrack.id.toString(),
        trackData: mergedTrack.toMap(),
        userId: user.uid,
      );
    }
  }
}
