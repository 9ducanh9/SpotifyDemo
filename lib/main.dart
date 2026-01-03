import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  try {
    await FirebaseService.initialize();
  } catch (e) {
    // Handle Firebase initialization error
    // In production, you might want to show an error or use a fallback
    debugPrint('Firebase initialization error: $e');
  }
  
  runApp(
    const ProviderScope(
      child: LocalMusicPlayerApp(),
    ),
  );
}

/// Main application widget
class LocalMusicPlayerApp extends ConsumerWidget {
  const LocalMusicPlayerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    
    return MaterialApp.router(
      title: 'Local Music Player',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
