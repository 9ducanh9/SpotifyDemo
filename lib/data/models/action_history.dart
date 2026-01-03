/// Model for tracking action history
class ActionHistory {
  final int? id;
  final int trackId;
  final String action; // e.g., 'created', 'updated', 'status_changed', 'approved'
  final String performedBy; // User ID or email
  final DateTime timestamp;
  final Map<String, dynamic>? metadata; // Additional data about the action
  final String? comment;

  ActionHistory({
    this.id,
    required this.trackId,
    required this.action,
    required this.performedBy,
    required this.timestamp,
    this.metadata,
    this.comment,
  });

  /// Create a copy with updated fields
  ActionHistory copyWith({
    int? id,
    int? trackId,
    String? action,
    String? performedBy,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
    String? comment,
  }) {
    return ActionHistory(
      id: id ?? this.id,
      trackId: trackId ?? this.trackId,
      action: action ?? this.action,
      performedBy: performedBy ?? this.performedBy,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
      comment: comment ?? this.comment,
    );
  }

  /// Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'trackId': trackId,
      'action': action,
      'performedBy': performedBy,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata != null ? metadata.toString() : null,
      'comment': comment,
    };
  }

  /// Create from Map (database retrieval)
  factory ActionHistory.fromMap(Map<String, dynamic> map) {
    Map<String, dynamic>? parsedMetadata;
    if (map['metadata'] != null) {
      try {
        // Simple parsing - in production, use proper JSON parsing
        final metadataStr = map['metadata'] as String;
        if (metadataStr.isNotEmpty && metadataStr != 'null') {
          parsedMetadata = {'raw': metadataStr}; // Simplified
        }
      } catch (e) {
        // Ignore parsing errors
      }
    }
    
    return ActionHistory(
      id: map['id'] as int?,
      trackId: map['trackId'] as int,
      action: map['action'] as String,
      performedBy: map['performedBy'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      metadata: parsedMetadata,
      comment: map['comment'] as String?,
    );
  }

  @override
  String toString() {
    return 'ActionHistory(id: $id, trackId: $trackId, action: $action, performedBy: $performedBy, timestamp: $timestamp)';
  }
}
