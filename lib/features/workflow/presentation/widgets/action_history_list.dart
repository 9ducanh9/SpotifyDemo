import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/action_history.dart';
import '../../../../core/services/workflow_service.dart';
import 'package:intl/intl.dart';

/// Widget to display action history for a track
class ActionHistoryList extends ConsumerWidget {
  final int trackId;

  const ActionHistoryList({super.key, required this.trackId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(
      FutureProvider((ref) async {
        final workflowService = WorkflowService();
        return await workflowService.getActionHistory(trackId);
      }),
    );

    return historyAsync.when(
      data: (history) {
        if (history.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No action history'),
            ),
          );
        }

        return Card(
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final action = history[index];
              return ListTile(
                leading: _getActionIcon(action.action),
                title: Text(_formatAction(action.action)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('By: ${action.performedBy}'),
                    Text(
                      DateFormat('yyyy-MM-dd HH:mm:ss').format(action.timestamp),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (action.comment != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          'Comment: ${action.comment}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  Icon _getActionIcon(String action) {
    switch (action) {
      case 'created':
        return const Icon(Icons.add_circle);
      case 'updated':
        return const Icon(Icons.edit);
      case 'workflow_transition':
        return const Icon(Icons.swap_horiz);
      case 'deleted':
        return const Icon(Icons.delete);
      default:
        return const Icon(Icons.info);
    }
  }

  String _formatAction(String action) {
    return action.replaceAll('_', ' ').split(' ').map((word) {
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }
}
