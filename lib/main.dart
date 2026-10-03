import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/audio_service.dart';
import 'theme/app_theme.dart';
import 'screens/welcome_screen.dart';
import 'screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style for high-contrast accessibility
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.surface,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Check first launch state
  final prefs = await SharedPreferences.getInstance();
  final bool hasSeenWelcome = prefs.getBool('has_seen_welcome') ?? false;

  final audioService = AudioPlaybackService();

  runApp(BlindGeniusApp(
    hasSeenWelcome: hasSeenWelcome,
    audioService: audioService,
  ));
}

class BlindGeniusApp extends StatelessWidget {
  final bool hasSeenWelcome;
  final AudioPlaybackService audioService;

  const BlindGeniusApp({
    super.key,
    required this.hasSeenWelcome,
    required this.audioService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blind Genius',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      // Enables enhanced TalkBack accessibility semantics across the entire widget tree
      showSemanticsDebugger: false,
      home: hasSeenWelcome
          ? MainNavigationScreen(audioService: audioService)
          : WelcomeScreen(audioService: audioService),
    );
  }
}
