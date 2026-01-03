import '../../data/models/music_track_model.dart';
import '../../data/database/database_helper.dart';
import '../../data/models/action_history.dart';
import 'package:intl/intl.dart';

/// Time period for reports
enum ReportPeriod {
  daily,
  weekly,
  monthly,
  custom,
}

/// Report data model
class ReportData {
  final DateTime startDate;
  final DateTime endDate;
  final int totalTracks;
  final int tracksAdded;
  final int tracksModified;
  final int tracksDeleted;
  final int favoritesAdded;
  final int workflowTransitions;
  final Map<String, int> actionsByType;
  final List<MusicTrack> topTracks;
  final List<ActionHistory> recentActions;

  ReportData({
    required this.startDate,
    required this.endDate,
    required this.totalTracks,
    required this.tracksAdded,
    required this.tracksModified,
    required this.tracksDeleted,
    required this.favoritesAdded,
    required this.workflowTransitions,
    required this.actionsByType,
    required this.topTracks,
    required this.recentActions,
  });
}

/// Service for generating time-based reports
class ReportingService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Generate report for a time period
  Future<ReportData> generateReport(ReportPeriod period, {DateTime? customStart, DateTime? customEnd}) async {
    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate = now;

    switch (period) {
      case ReportPeriod.daily:
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case ReportPeriod.weekly:
        startDate = now.subtract(Duration(days: now.weekday - 1));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        break;
      case ReportPeriod.monthly:
        startDate = DateTime(now.year, now.month, 1);
        break;
      case ReportPeriod.custom:
        startDate = customStart ?? now.subtract(const Duration(days: 7));
        endDate = customEnd ?? now;
        break;
    }

    // Get all tracks
    final allTracks = await _dbHelper.getAllTracks();
    
    // Filter tracks in date range
    final tracksInRange = allTracks.where((track) {
      return track.createdAt.isAfter(startDate) && track.createdAt.isBefore(endDate);
    }).toList();

    // Get action history
    final allActions = await _dbHelper.getAllActionHistory();
    final actionsInRange = allActions.where((action) {
      return action.timestamp.isAfter(startDate) && action.timestamp.isBefore(endDate);
    }).toList();

    // Calculate metrics
    final tracksAdded = tracksInRange.length;
    final tracksModified = tracksInRange.where((t) => t.lastModifiedAt != null).length;
    final favoritesAdded = tracksInRange.where((t) => t.isFavorite).length;
    final workflowTransitions = actionsInRange
        .where((a) => a.action == 'workflow_transition')
        .length;

    // Group actions by type
    final actionsByType = <String, int>{};
    for (final action in actionsInRange) {
      actionsByType[action.action] = (actionsByType[action.action] ?? 0) + 1;
    }

    // Get top tracks (by creation date, most recent first)
    final topTracks = tracksInRange.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final top10Tracks = topTracks.take(10).toList();

    // Get recent actions
    final recentActions = actionsInRange.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final recent10Actions = recentActions.take(10).toList();

    return ReportData(
      startDate: startDate,
      endDate: endDate,
      totalTracks: allTracks.length,
      tracksAdded: tracksAdded,
      tracksModified: tracksModified,
      tracksDeleted: 0, // Would need to track deletions separately
      favoritesAdded: favoritesAdded,
      workflowTransitions: workflowTransitions,
      actionsByType: actionsByType,
      topTracks: top10Tracks,
      recentActions: recent10Actions,
    );
  }

  /// Compare two reports (before-after metrics)
  Future<Map<String, dynamic>> compareReports(ReportData before, ReportData after) {
    return {
      'tracksAddedChange': after.tracksAdded - before.tracksAdded,
      'tracksAddedPercentChange': before.tracksAdded > 0
          ? ((after.tracksAdded - before.tracksAdded) / before.tracksAdded * 100)
          : 0.0,
      'favoritesChange': after.favoritesAdded - before.favoritesAdded,
      'workflowTransitionsChange': after.workflowTransitions - before.workflowTransitions,
      'totalTracksChange': after.totalTracks - before.totalTracks,
      'actionsChange': _compareActions(before.actionsByType, after.actionsByType),
    };
  }

  Map<String, int> _compareActions(Map<String, int> before, Map<String, int> after) {
    final changes = <String, int>{};
    final allActions = {...before.keys, ...after.keys};
    
    for (final action in allActions) {
      final beforeCount = before[action] ?? 0;
      final afterCount = after[action] ?? 0;
      changes[action] = afterCount - beforeCount;
    }
    
    return changes;
  }
}
