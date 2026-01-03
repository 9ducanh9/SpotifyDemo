import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../../features/tracks/presentation/providers/track_providers.dart';
import '../../../../core/services/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Admin screen (only accessible to admin users)
class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userDoc = ref.watch(userDocumentProvider);
    final isAdmin = userDoc.value?.isAdmin ?? false;

    if (!isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin')),
        body: const Center(
          child: Text('Access denied. Admin privileges required.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.people),
              title: const Text('All Users'),
              subtitle: const Text('View and manage all users'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Navigate to users management screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Users management coming soon')),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.cloud_sync),
              title: const Text('Cloud Sync Status'),
              subtitle: const Text('Monitor sync status across all users'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Show sync status
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sync status coming soon')),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('Global Statistics'),
              subtitle: const Text('View statistics for all users'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Show global statistics
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Global statistics coming soon')),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('System Settings'),
              subtitle: const Text('Configure system-wide settings'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Show system settings
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('System settings coming soon')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
