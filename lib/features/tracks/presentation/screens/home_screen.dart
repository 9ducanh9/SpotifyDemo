import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/app_router.dart';
import '../../auth/presentation/providers/auth_providers.dart';
import '../providers/sync_providers.dart';

/// Home screen with navigation to main features
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userDoc = ref.watch(userDocumentProvider);
    final isAdmin = userDoc.value?.isAdmin ?? false;
    final connectivityStatus = ref.watch(connectivityStatusProvider);
    final syncStatus = ref.watch(syncStatusProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Music Player'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: connectivityStatus.value == true
                ? () async {
                    try {
                      await ref.read(syncActionsProvider).twoWaySync();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Sync completed')),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Sync failed: $e')),
                        );
                      }
                    }
                  }
                : null,
            tooltip: 'Sync',
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.bar_chart),
                    SizedBox(width: 8),
                    Text('Statistics'),
                  ],
                ),
                onTap: () => context.go('/statistics'),
              ),
              if (isAdmin)
                PopupMenuItem(
                  child: const Row(
                    children: [
                      Icon(Icons.admin_panel_settings),
                      SizedBox(width: 8),
                      Text('Admin Panel'),
                    ],
                  ),
                  onTap: () => context.go('/admin'),
                ),
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Sign Out'),
                  ],
                ),
                onTap: () async {
                  await ref.read(authActionsProvider).signOut();
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (syncStatus != null)
              Card(
                color: syncStatus!.contains('failed')
                    ? Colors.red.shade50
                    : Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Icon(
                        syncStatus!.contains('failed')
                            ? Icons.error
                            : Icons.check_circle,
                        color: syncStatus!.contains('failed')
                            ? Colors.red
                            : Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          syncStatus!,
                          style: TextStyle(
                            color: syncStatus!.contains('failed')
                                ? Colors.red.shade900
                                : Colors.green.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (connectivityStatus.value == false)
              Card(
                color: Colors.orange.shade50,
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Icon(Icons.wifi_off, color: Colors.orange),
                      SizedBox(width: 8),
                      Text('Offline mode - changes will sync when online'),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 32),
            const Icon(
              Icons.music_note,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            Text(
              'Welcome${userDoc.value?.email != null ? " ${userDoc.value!.email.split('@')[0]}" : ""}',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            if (isAdmin)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Chip(
                  label: const Text('Admin'),
                  avatar: const Icon(Icons.admin_panel_settings, size: 18),
                ),
              ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: () => context.go('/tracks'),
              icon: const Icon(Icons.library_music),
              label: const Text('View All Tracks'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => context.go('/tracks/add'),
              icon: const Icon(Icons.add),
              label: const Text('Add New Track'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const Spacer(),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Features',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    const Row(
                      children: [
                        Icon(Icons.play_circle_outline),
                        SizedBox(width: 8),
                        Text('Play local audio files'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Icon(Icons.mic),
                        SizedBox(width: 8),
                        Text('Record audio'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Icon(Icons.search),
                        SizedBox(width: 8),
                        Text('Search and filter tracks'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Icon(Icons.favorite),
                        SizedBox(width: 8),
                        Text('Mark favorites'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
