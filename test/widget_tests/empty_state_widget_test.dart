import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:local_music_player/features/tracks/presentation/widgets/empty_state_widget.dart';

void main() {
  testWidgets('EmptyStateWidget displays message', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EmptyStateWidget(
            message: 'No tracks found',
          ),
        ),
      ),
    );

    // Verify message is displayed
    expect(find.text('No tracks found'), findsOneWidget);
    expect(find.byIcon(Icons.music_off), findsOneWidget);
  });

  testWidgets('EmptyStateWidget displays action button when provided', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EmptyStateWidget(
            message: 'No tracks found',
            action: ElevatedButton(
              onPressed: null,
              child: Text('Add Track'),
            ),
          ),
        ),
      ),
    );

    // Verify action button is displayed
    expect(find.text('Add Track'), findsOneWidget);
  });
}
