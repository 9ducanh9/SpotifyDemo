import '../../data/models/music_track_model.dart';
import '../../data/models/action_history.dart';
import '../../data/models/workflow_status.dart';
import '../../data/database/database_helper.dart';
import '../../core/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service to handle multi-step workflow processes
class WorkflowService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Transition track to next workflow status
  Future<void> transitionWorkflow({
    required int trackId,
    required WorkflowStatus newStatus,
    String? comment,
  }) async {
    final track = await _dbHelper.getTrackById(trackId);
    if (track == null) throw Exception('Track not found');

    final currentStatus = track.workflowStatus;
    
    // Validate transition
    if (!_isValidTransition(currentStatus, newStatus)) {
      throw Exception(
        'Invalid transition from ${currentStatus.displayName} to ${newStatus.displayName}',
      );
    }

    // Update workflow status
    await _dbHelper.updateWorkflowStatus(trackId, newStatus.value);

    // Record action history
    final user = FirebaseAuth.instance.currentUser;
    await _dbHelper.insertActionHistory(
      ActionHistory(
        trackId: trackId,
        action: 'workflow_transition',
        performedBy: user?.email ?? user?.uid ?? 'system',
        timestamp: DateTime.now(),
        metadata: {
          'from': currentStatus.value,
          'to': newStatus.value,
        },
        comment: comment,
      ),
    );
  }

  /// Check if transition is valid
  bool _isValidTransition(WorkflowStatus from, WorkflowStatus to) {
    // Define valid transitions
    switch (from) {
      case WorkflowStatus.draft:
        return to == WorkflowStatus.review || to == WorkflowStatus.rejected;
      case WorkflowStatus.review:
        return to == WorkflowStatus.approved || 
               to == WorkflowStatus.rejected ||
               to == WorkflowStatus.draft;
      case WorkflowStatus.approved:
        return to == WorkflowStatus.completed || 
               to == WorkflowStatus.review;
      case WorkflowStatus.completed:
        return false; // Completed is final state
      case WorkflowStatus.rejected:
        return to == WorkflowStatus.draft || 
               to == WorkflowStatus.review;
    }
  }

  /// Get tracks by workflow status
  Future<List<MusicTrack>> getTracksByStatus(WorkflowStatus status) async {
    return await _dbHelper.getTracksByWorkflowStatus(status.value);
  }

  /// Get action history for a track
  Future<List<ActionHistory>> getActionHistory(int trackId) async {
    return await _dbHelper.getActionHistory(trackId);
  }

  /// Record a custom action
  Future<void> recordAction({
    required int trackId,
    required String action,
    Map<String, dynamic>? metadata,
    String? comment,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    await _dbHelper.insertActionHistory(
      ActionHistory(
        trackId: trackId,
        action: action,
        performedBy: user?.email ?? user?.uid ?? 'system',
        timestamp: DateTime.now(),
        metadata: metadata,
        comment: comment,
      ),
    );
  }
}
