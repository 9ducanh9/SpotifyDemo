/// Workflow status enum for multi-step processes
enum WorkflowStatus {
  draft,      // Initial state
  review,     // Under review
  approved,   // Approved
  completed,  // Completed
  rejected,   // Rejected
}

extension WorkflowStatusExtension on WorkflowStatus {
  String get displayName {
    switch (this) {
      case WorkflowStatus.draft:
        return 'Draft';
      case WorkflowStatus.review:
        return 'Under Review';
      case WorkflowStatus.approved:
        return 'Approved';
      case WorkflowStatus.completed:
        return 'Completed';
      case WorkflowStatus.rejected:
        return 'Rejected';
    }
  }

  String get value {
    switch (this) {
      case WorkflowStatus.draft:
        return 'draft';
      case WorkflowStatus.review:
        return 'review';
      case WorkflowStatus.approved:
        return 'approved';
      case WorkflowStatus.completed:
        return 'completed';
      case WorkflowStatus.rejected:
        return 'rejected';
    }
  }

  static WorkflowStatus fromString(String value) {
    switch (value) {
      case 'draft':
        return WorkflowStatus.draft;
      case 'review':
        return WorkflowStatus.review;
      case 'approved':
        return WorkflowStatus.approved;
      case 'completed':
        return WorkflowStatus.completed;
      case 'rejected':
        return WorkflowStatus.rejected;
      default:
        return WorkflowStatus.draft;
    }
  }
}
