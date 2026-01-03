import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/tracks/presentation/screens/home_screen.dart';
import '../../features/tracks/presentation/screens/track_list_screen.dart';
import '../../features/tracks/presentation/screens/track_detail_screen.dart';
import '../../features/tracks/presentation/screens/add_edit_track_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/statistics/presentation/screens/statistics_screen.dart';
import '../../features/admin/presentation/screens/admin_screen.dart';
import '../../features/tracks/presentation/screens/advanced_search_screen.dart';
import '../../features/workflow/presentation/screens/workflow_screen.dart';
import '../../features/reporting/presentation/screens/reporting_screen.dart';

/// Application routing configuration with authentication guards
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final isLoggingIn = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/forgot-password';

      // Redirect to login if not authenticated
      if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }

      // Redirect to home if already logged in and trying to access auth pages
      if (isLoggedIn && isLoggingIn) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
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
      GoRoute(
        path: '/statistics',
        name: 'statistics',
        builder: (context, state) => const StatisticsScreen(),
      ),
      GoRoute(
        path: '/admin',
        name: 'admin',
        builder: (context, state) => const AdminScreen(),
      ),
      GoRoute(
        path: '/search',
        name: 'advanced-search',
        builder: (context, state) => const AdvancedSearchScreen(),
      ),
      GoRoute(
        path: '/tracks/:id/workflow',
        name: 'workflow',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return WorkflowScreen(trackId: id);
        },
      ),
      GoRoute(
        path: '/reports',
        name: 'reports',
        builder: (context, state) => const ReportingScreen(),
      ),
    ],
  );
});
