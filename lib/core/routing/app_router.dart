import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/tracks/presentation/screens/home_screen.dart';
import '../../features/tracks/presentation/screens/track_list_screen.dart';
import '../../features/tracks/presentation/screens/track_detail_screen.dart';
import '../../features/tracks/presentation/screens/add_edit_track_screen.dart';

/// Application routing configuration
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/tracks',
      name: 'tracks',
      builder: (context, state) => const TrackListScreen(),
    ),
    GoRoute(
      path: '/tracks/:id',
      name: 'track-detail',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return TrackDetailScreen(trackId: id);
      },
    ),
    GoRoute(
      path: '/tracks/add',
      name: 'add-track',
      builder: (context, state) => const AddEditTrackScreen(),
    ),
    GoRoute(
      path: '/tracks/:id/edit',
      name: 'edit-track',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return AddEditTrackScreen(trackId: id);
      },
    ),
  ],
);
