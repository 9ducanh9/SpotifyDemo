import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_music_player/features/tracks/presentation/screens/home_screen.dart';
import 'package:local_music_player/core/routing/app_router.dart';

void main() {
  testWidgets('HomeScreen displays welcome message', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    // Verify that welcome text is displayed
    expect(find.text('Welcome'), findsOneWidget);
  });

  testWidgets('HomeScreen has navigation buttons', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    // Verify navigation buttons exist
    expect(find.text('View All Tracks'), findsOneWidget);
    expect(find.text('Add New Track'), findsOneWidget);
  });

  testWidgets('HomeScreen displays features list', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    // Verify features are displayed
    expect(find.text('Features'), findsOneWidget);
    expect(find.text('Play local audio files'), findsOneWidget);
  });
}
