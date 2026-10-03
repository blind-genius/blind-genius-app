import 'package:flutter_test/flutter_test.dart';
import 'package:blind_genius/services/audio_service.dart';
import 'package:blind_genius/services/mock_data_service.dart';
import 'package:blind_genius/main.dart';

void main() {
  testWidgets('Blind Genius launches on Welcome Screen for first-time users', (WidgetTester tester) async {
    final audioService = AudioPlaybackService();

    // Launch app with hasSeenWelcome = false
    await tester.pumpWidget(BlindGeniusApp(
      hasSeenWelcome: false,
      audioService: audioService,
    ));

    // Verify Welcome Screen and Skip button exist
    expect(find.text('Blind Genius Intro'), findsOneWidget);
    expect(find.text('SKIP INTRO'), findsOneWidget);
    expect(find.text('ENTER BLIND GENIUS APP'), findsOneWidget);
  });

  testWidgets('Blind Genius main screen shows all 4 navigation tabs', (WidgetTester tester) async {
    final audioService = AudioPlaybackService();

    // Launch app with hasSeenWelcome = true (direct to main screen)
    await tester.pumpWidget(BlindGeniusApp(
      hasSeenWelcome: true,
      audioService: audioService,
    ));

    // Verify 4 accessible bottom navigation tabs
    expect(find.text('Music'), findsOneWidget);
    expect(find.text('Clips'), findsOneWidget);
    expect(find.text('Challenges'), findsOneWidget);
    expect(find.text('About'), findsOneWidget);
  });

  test('AudioPlaybackService plays and pauses tracks correctly', () {
    final audioService = AudioPlaybackService();
    final sampleTrack = MockDataService.sampleTracks.first;

    expect(audioService.isPlaying, isFalse);
    expect(audioService.currentTrack, isNull);

    // Play track
    audioService.playTrack(sampleTrack);
    expect(audioService.isPlaying, isTrue);
    expect(audioService.currentTrack?.id, equals(sampleTrack.id));

    // Pause track
    audioService.pause();
    expect(audioService.isPlaying, isFalse);
  });
}
