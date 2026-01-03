import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_music_player/features/tracks/presentation/widgets/track_list_item.dart';
import 'package:local_music_player/data/models/music_track_model.dart';

void main() {
  final testTrack = MusicTrack(
    id: 1,
    title: 'Test Song',
    artist: 'Test Artist',
    duration: 180,
    filePath: '/path/to/song.mp3',
    createdAt: DateTime.now(),
    isFavorite: false,
  );

  testWidgets('TrackListItem displays track information', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: TrackListItem(
              track: testTrack,
            ),
          ),
        ),
      ),
    );

    // Verify track information is displayed
    expect(find.text('Test Song'), findsOneWidget);
    expect(find.text('Test Artist'), findsOneWidget);
    expect(find.text('03:00'), findsOneWidget); // 180 seconds = 3:00
  });

  testWidgets('TrackListItem shows favorite icon when track is favorite', (WidgetTester tester) async {
    final favoriteTrack = testTrack.copyWith(isFavorite: true);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: TrackListItem(
              track: favoriteTrack,
            ),
          ),
        ),
      ),
    );

    // Verify favorite icon is displayed
    expect(find.byIcon(Icons.favorite), findsOneWidget);
  });
}
