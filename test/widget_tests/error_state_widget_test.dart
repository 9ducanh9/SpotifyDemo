import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:local_music_player/features/tracks/presentation/widgets/error_state_widget.dart';

void main() {
  testWidgets('ErrorStateWidget displays error message', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ErrorStateWidget(
            message: 'Error loading tracks',
          ),
        ),
      ),
    );

    // Verify error message is displayed
    expect(find.text('Error loading tracks'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
  });

  testWidgets('ErrorStateWidget displays retry button when onRetry is provided', (WidgetTester tester) async {
    bool retryCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ErrorStateWidget(
            message: 'Error loading tracks',
            onRetry: () {
              retryCalled = true;
            },
          ),
        ),
      ),
    );

    // Verify retry button is displayed
    expect(find.text('Retry'), findsOneWidget);

    // Tap retry button
    await tester.tap(find.text('Retry'));
    await tester.pump();

    // Verify retry was called
    expect(retryCalled, true);
  });
}
