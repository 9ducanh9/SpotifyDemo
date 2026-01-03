import 'package:flutter/material.dart';
import '../../../../data/models/workflow_status.dart';

/// Widget to display workflow status as a chip
class WorkflowStatusChip extends StatelessWidget {
  final WorkflowStatus status;

  const WorkflowStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case WorkflowStatus.draft:
        backgroundColor = Colors.grey.shade300;
        textColor = Colors.grey.shade900;
        break;
      case WorkflowStatus.review:
        backgroundColor = Colors.blue.shade100;
        textColor = Colors.blue.shade900;
        break;
      case WorkflowStatus.approved:
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade900;
        break;
      case WorkflowStatus.completed:
        backgroundColor = Colors.purple.shade100;
        textColor = Colors.purple.shade900;
        break;
      case WorkflowStatus.rejected:
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade900;
        break;
    }

    return Chip(
      label: Text(
        status.displayName,
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      ),
      backgroundColor: backgroundColor,
    );
  }
}
