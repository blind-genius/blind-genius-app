import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/accessibility_service.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import '../widgets/transcript_dialog.dart';
import 'main_navigation_screen.dart';

class WelcomeScreen extends StatefulWidget {
  final AudioPlaybackService audioService;

  const WelcomeScreen({super.key, required this.audioService});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _isPlaying = true;
  int _currentSeconds = 0;
  static const int _totalVideoDuration = 45; // 45-second high-impact intro
  Timer? _videoTimer;
  bool _audioDescriptionEnabled = true;

  final String _introTranscript =
      'Welcome to Blind Genius. Music is not what we see; it is what we feel, vibrate, and experience together. '
      'Inside this app, discover exclusive piano concerts, studio clips with integrated audio descriptions, '
      'interactive community rhythm challenges, and our inspiring journey. '
      'Every button and screen is optimized for your screen reader. Let the sound guide you.';

  final String _visualSceneDescription =
      'A warm cinematic video starts with a close-up of Blind Genius smiling beside a concert grand piano. '
      'Soundwaves illuminate in golden ripples across the screen as his hands glide over the keys. '
      'Titles appear: "Blind Genius - Empowering Sound, Erasing Barriers".';

  @override
  void initState() {
    super.initState();
    _startSimulatedVideo();
    // Announce to TalkBack upon screen mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AccessibilityService.announce(
        'Welcome to Blind Genius. Introductory video is playing with Audio Description enabled. '
        'A skip button labeled Skip Intro is located at the top right and bottom of the screen. '
        'Double tap it at any time to proceed to the main dashboard.',
      );
    });
  }

  void _startSimulatedVideo() {
    _videoTimer?.cancel();
    _videoTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPlaying) return;
      if (_currentSeconds < _totalVideoDuration) {
        setState(() {
          _currentSeconds++;
        });
        // Periodically announce progress to screen reader every 15 seconds
        if (_currentSeconds % 15 == 0 && _currentSeconds < _totalVideoDuration) {
          AccessibilityService.announce(
            'Intro video: $_currentSeconds of $_totalVideoDuration seconds elapsed.',
          );
        }
      } else {
        timer.cancel();
        _onVideoFinished();
      }
    });
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
    AccessibilityService.hapticMedium();
    AccessibilityService.announce(
      _isPlaying ? 'Intro video resumed at $_currentSeconds seconds' : 'Intro video paused',
    );
  }

  void _toggleAudioDescription() {
    setState(() {
      _audioDescriptionEnabled = !_audioDescriptionEnabled;
    });
    AccessibilityService.hapticSelection();
    AccessibilityService.announce(
      _audioDescriptionEnabled
          ? 'Audio Description turned On. Scene details are being narrated.'
          : 'Audio Description turned Off.',
    );
  }

  void _onVideoFinished() {
    AccessibilityService.announce('Introductory video completed. Entering Blind Genius app.');
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    _videoTimer?.cancel();
    // Persist that the user has seen the intro video
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_welcome', true);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => MainNavigationScreen(audioService: widget.audioService),
      ),
    );
  }

  @override
  void dispose() {
    _videoTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _currentSeconds / _totalVideoDuration;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Semantics(
          header: true,
          child: const Text('Blind Genius Intro'),
        ),
        actions: [
          // Explicit TalkBack Skip Button in AppBar
          Semantics(
            button: true,
            label: 'Skip intro video and enter Blind Genius app',
            hint: 'Double tap to bypass video and immediately enter the main dashboard',
            child: TextButton.icon(
              onPressed: () {
                AccessibilityService.hapticMedium();
                AccessibilityService.announce('Skipping intro video. Navigating to main dashboard.');
                _navigateToHome();
              },
              icon: const Icon(Icons.skip_next, color: AppTheme.goldAccent, size: 28),
              label: const Text(
                'SKIP INTRO',
                style: TextStyle(
                  color: AppTheme.goldAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Screen Reader Guidance Banner
              Semantics(
                container: true,
                label: 'Introductory Video Player. Use controls below or tap Skip Intro to proceed.',
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceHighlight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.cyanAccent.withOpacity(0.4)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.accessibility_new, color: AppTheme.cyanAccent, size: 22),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'TalkBack Optimized: Double tap Skip at any time.',
                          style: TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Accessible Video Viewport
              Semantics(
                container: true,
                label: 'Video player showing: Blind Genius Welcome Film. '
                    '${_isPlaying ? "Playing" : "Paused"}. Progress: $_currentSeconds of $_totalVideoDuration seconds. '
                    'Audio description is ${_audioDescriptionEnabled ? "active" : "inactive"}.',
                child: Container(
                  height: 250,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.goldAccent, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.goldAccent.withOpacity(0.15),
                        blurRadius: 18,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Video graphics simulation
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isPlaying ? Icons.graphic_eq : Icons.play_circle_outline,
                            size: 64,
                            color: AppTheme.goldAccent,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Blind Genius: The Story of Sound',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$_currentSeconds s / $_totalVideoDuration s',
                            style: const TextStyle(
                              color: AppTheme.goldAccent,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      // Overlay Live Caption Badge
                      Positioned(
                        bottom: 12,
                        left: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: Text(
                            _audioDescriptionEnabled
                                ? 'AD: [Acoustic piano resonates with warm grand chords. Blind Genius smiles at the keys.]'
                                : '"Music is not what we see; it is what we feel."',
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Accessible Progress Bar
              Semantics(
                slider: true,
                label: 'Video progress slider',
                value: '$_currentSeconds seconds of $_totalVideoDuration seconds',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppTheme.surfaceHighlight,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.goldAccent),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Video Control Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Play / Pause Button
                  Semantics(
                    button: true,
                    label: _isPlaying ? 'Pause introductory video' : 'Play introductory video',
                    hint: 'Double tap to toggle video playback',
                    child: ElevatedButton.icon(
                      onPressed: _togglePlayPause,
                      icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, size: 24),
                      label: Text(_isPlaying ? 'PAUSE' : 'PLAY'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.surfaceHighlight,
                        foregroundColor: AppTheme.goldAccent,
                        side: const BorderSide(color: AppTheme.goldAccent, width: 1.5),
                        minimumSize: const Size(120, 50),
                      ),
                    ),
                  ),

                  // Audio Description (AD) Toggle
                  Semantics(
                    button: true,
                    label: _audioDescriptionEnabled
                        ? 'Disable Audio Description'
                        : 'Enable Audio Description',
                    hint: 'Double tap to toggle audio narration of visuals',
                    child: ElevatedButton.icon(
                      onPressed: _toggleAudioDescription,
                      icon: Icon(
                        _audioDescriptionEnabled ? Icons.closed_caption : Icons.closed_caption_disabled,
                        size: 24,
                      ),
                      label: Text(_audioDescriptionEnabled ? 'AD ON' : 'AD OFF'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _audioDescriptionEnabled
                            ? AppTheme.cyanAccent
                            : AppTheme.surfaceHighlight,
                        foregroundColor: _audioDescriptionEnabled ? Colors.black : AppTheme.textPrimary,
                        minimumSize: const Size(120, 50),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // View Transcript Button
              Semantics(
                button: true,
                label: 'Read introductory video transcript and scene descriptions',
                hint: 'Double tap to open dialog with full text transcript for screen readers',
                child: OutlinedButton.icon(
                  onPressed: () {
                    TranscriptDialog.show(
                      context,
                      title: 'Blind Genius Intro Film',
                      visualDescription: _visualSceneDescription,
                      transcriptText: _introTranscript,
                    );
                  },
                  icon: const Icon(Icons.text_snippet, color: AppTheme.goldAccent),
                  label: const Text('READ TRANSCRIPT'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Large Primary Skip / Enter Button
              Semantics(
                button: true,
                label: 'Skip Intro Video and Enter Blind Genius App',
                hint: 'Double tap to enter the main app dashboard with Music, Clips, Challenges, and Biography',
                child: ElevatedButton.icon(
                  onPressed: () {
                    AccessibilityService.hapticHeavy();
                    AccessibilityService.announce('Entering Blind Genius App');
                    _navigateToHome();
                  },
                  icon: const Icon(Icons.arrow_forward, color: Colors.black, size: 26),
                  label: const Text(
                    'ENTER BLIND GENIUS APP',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.goldAccent,
                    foregroundColor: Colors.black,
                    minimumSize: const Size.fromHeight(56),
                    elevation: 6,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
