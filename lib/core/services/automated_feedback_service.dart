import '../../data/models/music_track_model.dart';
import '../../data/database/database_helper.dart';
import '../../core/services/reporting_service.dart';
import '../../core/services/export_service.dart';
import 'dart:io';

/// Feedback type
enum FeedbackType {
  positive,
  warning,
  suggestion,
}

/// Automated feedback model
class AutomatedFeedback {
  final FeedbackType type;
  final String title;
  final String message;
  final String? action;
  final DateTime timestamp;

  AutomatedFeedback({
    required this.type,
    required this.title,
    required this.message,
    this.action,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// Service to provide automated feedback based on analytics
class AutomatedFeedbackService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final ReportingService _reportingService = ReportingService();

  /// Generate automated feedback based on current data
  Future<List<AutomatedFeedback>> generateFeedback() async {
    final feedback = <AutomatedFeedback>[];
    
    // Get recent report
    final report = await _reportingService.generateReport(ReportPeriod.weekly);
    
    // Check for low activity
    if (report.tracksAdded < 3) {
      feedback.add(
        AutomatedFeedback(
          type: FeedbackType.suggestion,
          title: 'Low Activity',
          message: 'You\'ve added fewer tracks this week. Consider exploring new music!',
        ),
      );
    }

    // Check for high activity
    if (report.tracksAdded > 20) {
      feedback.add(
        AutomatedFeedback(
          type: FeedbackType.positive,
          title: 'Great Activity!',
          message: 'You\'ve added ${report.tracksAdded} tracks this week. Keep it up!',
        ),
      );
    }

    // Check for favorites
    final allTracks = await _dbHelper.getAllTracks();
    final favoriteRatio = allTracks.isEmpty
        ? 0.0
        : allTracks.where((t) => t.isFavorite).length / allTracks.length;
    
    if (favoriteRatio < 0.1 && allTracks.length > 10) {
      feedback.add(
        AutomatedFeedback(
          type: FeedbackType.suggestion,
          title: 'Organize Your Favorites',
          message: 'Only ${(favoriteRatio * 100).toStringAsFixed(0)}% of your tracks are favorited. Mark your favorites to organize your library!',
        ),
      );
    }

    // Check for workflow status
    final draftTracks = allTracks.where((t) => t.workflowStatus == WorkflowStatus.draft).length;
    if (draftTracks > 5) {
      feedback.add(
        AutomatedFeedback(
          type: FeedbackType.warning,
          title: 'Pending Reviews',
          message: 'You have $draftTracks tracks in draft status. Consider reviewing them!',
          action: 'Review Tracks',
        ),
      );
    }

    // Check for long tracks
    final longTracks = allTracks.where((t) => t.duration > 600).length;
    if (longTracks > 0) {
      feedback.add(
        AutomatedFeedback(
          type: FeedbackType.positive,
          title: 'Long Tracks',
          message: 'You have $longTracks tracks longer than 10 minutes. Great for extended listening!',
        ),
      );
    }

    return feedback;
  }

  /// Generate feedback report as PDF
  Future<File> generateFeedbackReport() async {
    final feedback = await generateFeedback();
    final report = await _reportingService.generateReport(ReportPeriod.weekly);
    
    // Create a simple text report
    final reportText = StringBuffer();
    reportText.writeln('Automated Feedback Report');
    reportText.writeln('Generated: ${DateTime.now()}');
    reportText.writeln('');
    reportText.writeln('Summary:');
    reportText.writeln('- Total Tracks: ${report.totalTracks}');
    reportText.writeln('- Tracks Added This Week: ${report.tracksAdded}');
    reportText.writeln('- Favorites: ${report.favoritesAdded}');
    reportText.writeln('');
    reportText.writeln('Feedback:');
    for (final item in feedback) {
      reportText.writeln('${item.type.name.toUpperCase()}: ${item.title}');
      reportText.writeln('  ${item.message}');
      reportText.writeln('');
    }

    // Save to file
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/feedback_report_${DateTime.now().millisecondsSinceEpoch}.txt');
    await file.writeAsString(reportText.toString());
    return file;
  }
}
