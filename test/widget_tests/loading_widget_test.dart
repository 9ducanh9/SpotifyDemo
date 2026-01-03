import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:local_music_player/features/tracks/presentation/widgets/loading_widget.dart';

void main() {
  testWidgets('LoadingWidget displays CircularProgressIndicator', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LoadingWidget(),
        ),
      ),
    );

    // Verify loading indicator is displayed
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('LoadingWidget displays message when provided', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LoadingWidget(message: 'Loading tracks...'),
        ),
      ),
    );

    // Verify message is displayed
    expect(find.text('Loading tracks...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
