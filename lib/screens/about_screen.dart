import 'package:flutter/material.dart';
import '../models/achievement.dart';
import '../services/accessibility_service.dart';
import '../services/mock_data_service.dart';
import '../theme/app_theme.dart';
import '../widgets/accessible_card.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final achievements = MockDataService.sampleAchievements;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Profile Card
          AccessibleCard(
            semanticLabel: 'Blind Genius Biography Banner. International virtuoso pianist, composer, and accessibility pioneer.',
            child: Row(
              children: [
                // Avatar / Motif
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.surfaceHighlight,
                    border: Border.all(color: AppTheme.goldAccent, width: 2),
                  ),
                  child: const Icon(Icons.piano, color: AppTheme.goldAccent, size: 40),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Blind Genius',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Virtuoso Pianist & Audio Architect',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.goldAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Universal Accessibility Advocate',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.cyanAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Biography Section
          Semantics(
            header: true,
            child: const Text(
              'BIOGRAPHY',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.goldAccent,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 8),
          AccessibleCard(
            semanticLabel:
                'Full biography: Blind from birth, Blind Genius discovered the piano keyboard at age four, perceiving harmonies as vibrant architectural structures. Over two decades, he pioneered binaural recording techniques and toured globally, proving that musical mastery transcends sight.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'The Architecture of Sound in the Dark',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Blind from birth, Blind Genius discovered the piano keyboard at the age of four. '
                  'Without visual distraction, acoustic resonances became vivid three-dimensional landscapes. '
                  'By age twelve, he possessed absolute pitch and the ability to transcribe complex symphonies entirely by ear.',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Today, Blind Genius is celebrated worldwide for breathtaking live concert improvisations, '
                  'binaural 3D acoustic compositions, and designing revolutionary tactile music interfaces that enable visually impaired '
                  'artists everywhere to compose, perform, and inspire.',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceHighlight,
                    borderRadius: BorderRadius.circular(10),
                    border: const Border(left: BorderSide(color: AppTheme.goldAccent, width: 4)),
                  ),
                  child: const Text(
                    '"Sight perceives boundaries; sound dissolves them entirely."',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Achievements Timeline Section
          Semantics(
            header: true,
            child: const Text(
              'HONORS & ACHIEVEMENTS',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.goldAccent,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              final ach = achievements[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AccessibleCard(
                  semanticLabel: ach.accessibilityLabel,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.goldAccent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          ach.year,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ach.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              ach.organization,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.cyanAccent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              ach.description,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppTheme.textSecondary,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          // Accessibility Commitment Card
          Semantics(
            header: true,
            child: const Text(
              'ACCESSIBILITY COMMITMENT',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.cyanAccent,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 8),
          AccessibleCard(
            semanticLabel:
                'Blind Genius Accessibility Pledge. This application is certified for Google TalkBack and screen readers. Every control features spoken hints, high contrast, tactile haptic feedback, and audio transcripts.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.accessibility, color: AppTheme.cyanAccent, size: 28),
                    SizedBox(width: 10),
                    Text(
                      'Universal Screen Reader Support',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '• 100% TalkBack semantic annotations on all buttons, sliders, and views.\n'
                  '• Spoken time durations (e.g. "3 minutes and 40 seconds").\n'
                  '• Tactile haptic confirmations for playback and registration.\n'
                  '• Transcripts and audio descriptions for all clips and video releases.\n'
                  '• WCAG AAA compliant high-contrast dark theme.',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 14, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Community & Contact
          Semantics(
            header: true,
            child: const Text(
              'CONNECT & COLLABORATE',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.goldAccent,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Semantics(
                  button: true,
                  label: 'Send message to Blind Genius management',
                  child: OutlinedButton.icon(
                    onPressed: () {
                      AccessibilityService.announce('Opening contact form');
                    },
                    icon: const Icon(Icons.email_outlined, color: AppTheme.goldAccent),
                    label: const Text('CONTACT'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Semantics(
                  button: true,
                  label: 'Join official Blind Genius accessible community channel',
                  child: OutlinedButton.icon(
                    onPressed: () {
                      AccessibilityService.announce('Opening community channel');
                    },
                    icon: const Icon(Icons.people_outline, color: AppTheme.cyanAccent),
                    label: const Text('COMMUNITY'),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
