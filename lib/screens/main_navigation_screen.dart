import 'package:flutter/material.dart';
import '../services/accessibility_service.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import '../widgets/now_playing_bar.dart';
import 'welcome_screen.dart';
import 'music_screen.dart';
import 'clips_screen.dart';
import 'challenges_events_screen.dart';
import 'about_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final AudioPlaybackService audioService;

  const MainNavigationScreen({super.key, required this.audioService});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<String> _tabTitles = [
    'Music Library',
    'Video Clips',
    'Challenges & Events',
    'About Blind Genius',
  ];

  final List<String> _tabAnnouncements = [
    'Music tab selected. Showing audio tracks categorized by tags.',
    'Clips tab selected. Showing accessible videos with audio descriptions.',
    'Challenges and Events tab selected. Showing community challenges and live streams.',
    'About tab selected. Showing biography, honors, and achievements.',
  ];

  void _onTabTapped(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
    });
    AccessibilityService.hapticSelection();
    AccessibilityService.announce(_tabAnnouncements[index]);
  }

  void _replayIntroVideo() {
    AccessibilityService.announce('Opening introductory video');
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WelcomeScreen(audioService: widget.audioService),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      MusicScreen(audioService: widget.audioService),
      const ClipsScreen(),
      const ChallengesEventsScreen(),
      const AboutScreen(),
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Semantics(
          header: true,
          label: 'Current page: ${_tabTitles[_currentIndex]}',
          child: Text(_tabTitles[_currentIndex]),
        ),
        actions: [
          Semantics(
            button: true,
            label: 'Watch introductory welcome video again',
            hint: 'Double tap to play the intro film with audio description',
            child: IconButton(
              icon: const Icon(Icons.ondemand_video, color: AppTheme.goldAccent),
              tooltip: 'Replay Welcome Video',
              onPressed: _replayIntroVideo,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: pages,
              ),
            ),
            // Persistent accessible Now Playing mini player
            AnimatedBuilder(
              animation: widget.audioService,
              builder: (context, _) {
                return NowPlayingBar(audioService: widget.audioService);
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: Semantics(
        container: true,
        label: 'Main application navigation bar with 4 tabs',
        child: Container(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppTheme.border, width: 1.5)),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            items: [
              BottomNavigationBarItem(
                icon: Semantics(
                  label: 'Music tab, 1 of 4. Track list categorized by tags. ${_currentIndex == 0 ? "Selected" : ""}',
                  selected: _currentIndex == 0,
                  child: const Icon(Icons.library_music),
                ),
                activeIcon: const Icon(Icons.library_music, color: AppTheme.goldAccent),
                label: 'Music',
              ),
              BottomNavigationBarItem(
                icon: Semantics(
                  label: 'Clips tab, 2 of 4. Video list with audio descriptions. ${_currentIndex == 1 ? "Selected" : ""}',
                  selected: _currentIndex == 1,
                  child: const Icon(Icons.video_library),
                ),
                activeIcon: const Icon(Icons.video_library, color: AppTheme.goldAccent),
                label: 'Clips',
              ),
              BottomNavigationBarItem(
                icon: Semantics(
                  label: 'Challenges & Events tab, 3 of 4. Interactive challenges and live events. ${_currentIndex == 2 ? "Selected" : ""}',
                  selected: _currentIndex == 2,
                  child: const Icon(Icons.emoji_events),
                ),
                activeIcon: const Icon(Icons.emoji_events, color: AppTheme.goldAccent),
                label: 'Challenges',
              ),
              BottomNavigationBarItem(
                icon: Semantics(
                  label: 'About tab, 4 of 4. Biography and achievements. ${_currentIndex == 3 ? "Selected" : ""}',
                  selected: _currentIndex == 3,
                  child: const Icon(Icons.person),
                ),
                activeIcon: const Icon(Icons.person, color: AppTheme.goldAccent),
                label: 'About',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
