import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../data/models/music_track_model.dart';
import '../../../../data/models/workflow_status.dart';
import '../../../../core/services/workflow_service.dart';
import '../../../../features/tracks/presentation/providers/track_providers.dart';
import '../../../../features/auth/presentation/providers/auth_providers.dart';
import '../widgets/workflow_status_chip.dart';
import '../widgets/action_history_list.dart';

/// Screen to manage workflow and view action history
class WorkflowScreen extends ConsumerWidget {
  final int trackId;

  const WorkflowScreen({super.key, required this.trackId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackAsync = ref.watch(
      FutureProvider((ref) async {
        final repository = ref.watch(trackRepositoryProvider);
        return await repository.getTrackById(trackId);
      }),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workflow Management'),
      ),
      body: trackAsync.when(
        data: (track) {
          if (track == null) {
            return const Center(child: Text('Track not found'));
          }
          return _buildWorkflowView(context, ref, track);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildWorkflowView(
    BuildContext context,
    WidgetRef ref,
    MusicTrack track,
  ) {
    final workflowService = WorkflowService();
    final currentStatus = track.workflowStatus;
    final isAdmin = ref.watch(userDocumentProvider)?.isAdmin ?? false;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Track info card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    track.artist,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  WorkflowStatusChip(status: currentStatus),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Workflow actions
          Text(
            'Workflow Actions',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _getAvailableActions(currentStatus, isAdmin)
                .map((action) => ElevatedButton(
                      onPressed: () => _handleWorkflowAction(
                        context,
                        ref,
                        workflowService,
                        action,
                      ),
                      child: Text(action.displayName),
                    ))
                .toList(),
          ),
          const SizedBox(height: 32),
          // Action history
          Text(
            'Action History',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ActionHistoryList(trackId: trackId),
        ],
      ),
    );
  }

  List<WorkflowStatus> _getAvailableActions(
    WorkflowStatus currentStatus,
    bool isAdmin,
  ) {
    switch (currentStatus) {
      case WorkflowStatus.draft:
        return [WorkflowStatus.review];
      case WorkflowStatus.review:
        if (isAdmin) {
          return [WorkflowStatus.approved, WorkflowStatus.rejected];
        }
        return [WorkflowStatus.draft];
      case WorkflowStatus.approved:
        return [WorkflowStatus.completed];
      case WorkflowStatus.completed:
        return [];
      case WorkflowStatus.rejected:
        return [WorkflowStatus.draft, WorkflowStatus.review];
    }
  }

  Future<void> _handleWorkflowAction(
    BuildContext context,
    WidgetRef ref,
    WorkflowService workflowService,
    WorkflowStatus newStatus,
  ) async {
    try {
      await workflowService.transitionWorkflow(
        trackId: trackId,
        newStatus: newStatus,
      );
      
      // Refresh track data
      ref.invalidate(tracksProvider);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Status changed to ${newStatus.displayName}',
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}
