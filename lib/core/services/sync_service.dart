import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/music_track_model.dart';
import '../../data/database/database_helper.dart';
import '../../core/services/firebase_service.dart';
import '../../core/services/connectivity_service.dart';

/// Service to handle cloud sync between local SQLite and Firestore
class SyncService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final ConnectivityService _connectivity = ConnectivityService();

  /// Sync local tracks to cloud
  Future<void> syncToCloud() async {
    final user = FirebaseService.currentUser;
    if (user == null) return;

    final isConnected = await _connectivity.isConnected();
    if (!isConnected) {
      throw Exception('No internet connection');
    }

    // Get all local tracks
    final localTracks = await _dbHelper.getAllTracks();

    // Upload each track to Firestore
    for (final track in localTracks) {
      if (track.id != null) {
        await FirebaseService.syncTrackToCloud(
          trackId: track.id.toString(),
          trackData: {
            'id': track.id,
            'title': track.title,
            'artist': track.artist,
            'duration': track.duration,
            'filePath': track.filePath,
            'createdAt': track.createdAt.toIso8601String(),
            'isFavorite': track.isFavorite,
            'syncedAt': FieldValue.serverTimestamp(),
          },
          userId: user.uid,
        );
      }
    }
  }

  /// Sync cloud tracks to local database
  Future<void> syncFromCloud() async {
    final user = FirebaseService.currentUser;
    if (user == null) return;

    final isConnected = await _connectivity.isConnected();
    if (!isConnected) {
      throw Exception('No internet connection');
    }

    // Get tracks from Firestore
    final snapshot = await FirebaseService.getTracksFromCloud(user.uid).first;

    // Import tracks to local database
    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      
      // Check if track already exists locally
      final existingTrack = await _dbHelper.getTrackById(data['id'] as int?);
      
      if (existingTrack == null) {
        // Create new track
        final track = MusicTrack(
          id: data['id'] as int?,
          title: data['title'] as String,
          artist: data['artist'] as String,
          duration: data['duration'] as int,
          filePath: data['filePath'] as String,
          createdAt: DateTime.parse(data['createdAt'] as String),
          isFavorite: (data['isFavorite'] as bool?) ?? false,
        );
        await _dbHelper.insertTrack(track);
      } else {
        // Update existing track (cloud takes precedence)
        final track = MusicTrack(
          id: data['id'] as int?,
          title: data['title'] as String,
          artist: data['artist'] as String,
          duration: data['duration'] as int,
          filePath: data['filePath'] as String,
          createdAt: DateTime.parse(data['createdAt'] as String),
          isFavorite: (data['isFavorite'] as bool?) ?? false,
        );
        await _dbHelper.updateTrack(track);
      }
    }
  }

  /// Two-way sync (merge local and cloud)
  Future<void> twoWaySync() async {
    final user = FirebaseService.currentUser;
    if (user == null) return;

    final isConnected = await _connectivity.isConnected();
    if (!isConnected) {
      throw Exception('No internet connection');
    }

    // Strategy: Upload local changes, then download cloud changes
    // In a production app, you'd want conflict resolution logic here
    
    // 1. Upload local tracks to cloud
    await syncToCloud();
    
    // 2. Download cloud tracks to local
    await syncFromCloud();
  }

  /// Mark track as synced
  Future<void> markTrackSynced(int trackId) async {
    final user = FirebaseService.currentUser;
    if (user == null) return;

    final track = await _dbHelper.getTrackById(trackId);
    if (track == null) return;

    await FirebaseService.syncTrackToCloud(
      trackId: trackId.toString(),
      trackData: track.toMap(),
      userId: user.uid,
    );
  }
}
