import 'package:flutter/material.dart';
import '../models/clip.dart';
import '../services/accessibility_service.dart';
import '../services/mock_data_service.dart';
import '../theme/app_theme.dart';
import '../widgets/accessible_card.dart';
import '../widgets/transcript_dialog.dart';

class ClipsScreen extends StatelessWidget {
  const ClipsScreen({super.key});

  void _openClipPlayer(BuildContext context, ClipItem clip) {
    AccessibilityService.announce('Opening video clip: ${clip.title}');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ClipPlayerSheet(clip: clip),
    );
  }

  @override
  Widget build(BuildContext context) {
    final clips = MockDataService.sampleClips;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: clips.length,
      itemBuilder: (context, index) {
        final clip = clips[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: AccessibleCard(
            semanticLabel: clip.accessibilityLabel,
            semanticHint: 'Double tap to open video player or read transcript',
            onTap: () => _openClipPlayer(context, clip),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Video thumbnail preview frame
                Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceHighlight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Video Icon & Wave
                      const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.videocam_outlined, size: 54, color: AppTheme.goldAccent),
                          SizedBox(height: 6),
                          Text(
                            'HD VIDEO WITH AUDIO DESCRIPTION',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textMuted,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      // Duration badge bottom right
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: Text(
                            clip.durationDigital,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      // Audio Description Badge top left
                      if (clip.hasAudioDescription)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.cyanAccent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'AD INCLUDED',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Title & Category
                Text(
                  clip.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  clip.category,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.cyanAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  clip.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),

                // Action Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Semantics(
                      button: true,
                      label: 'Read transcript and scene descriptions for ${clip.title}',
                      child: TextButton.icon(
                        onPressed: () {
                          TranscriptDialog.show(
                            context,
                            title: clip.title,
                            visualDescription: clip.visualDescription,
                            transcriptText: clip.transcript,
                          );
                        },
                        icon: const Icon(Icons.description, color: AppTheme.goldAccent, size: 20),
                        label: const Text(
                          'TRANSCRIPT',
                          style: TextStyle(color: AppTheme.goldAccent, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Semantics(
                      button: true,
                      label: 'Watch clip: ${clip.title}',
                      child: ElevatedButton.icon(
                        onPressed: () => _openClipPlayer(context, clip),
                        icon: const Icon(Icons.play_circle_fill, color: Colors.black, size: 20),
                        label: const Text('WATCH CLIP'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(120, 44),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ClipPlayerSheet extends StatefulWidget {
  final ClipItem clip;

  const _ClipPlayerSheet({required this.clip});

  @override
  State<_ClipPlayerSheet> createState() => _ClipPlayerSheetState();
}

class _ClipPlayerSheetState extends State<_ClipPlayerSheet> {
  bool _isPlaying = true;
  bool _adEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: AppTheme.goldAccent, width: 2),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(
                        widget.clip.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.goldAccent,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppTheme.textPrimary, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Player View
              Container(
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isPlaying ? Icons.movie_filter : Icons.pause_circle_outline,
                        size: 64,
                        color: AppTheme.goldAccent,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isPlaying ? 'Playing with Binaural Audio' : 'Paused',
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _adEnabled ? 'Audio Description Active' : 'Standard Sound Track',
                        style: const TextStyle(color: AppTheme.cyanAccent, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Semantics(
                    button: true,
                    label: _isPlaying ? 'Pause video clip' : 'Play video clip',
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _isPlaying = !_isPlaying;
                        });
                        AccessibilityService.announce(_isPlaying ? 'Video playing' : 'Video paused');
                      },
                      icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                      label: Text(_isPlaying ? 'PAUSE' : 'PLAY'),
                    ),
                  ),
                  Semantics(
                    button: true,
                    label: _adEnabled ? 'Turn Audio Description off' : 'Turn Audio Description on',
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _adEnabled = !_adEnabled;
                        });
                        AccessibilityService.announce(
                          _adEnabled ? 'Audio Description enabled' : 'Audio Description disabled',
                        );
                      },
                      icon: const Icon(Icons.closed_caption),
                      label: Text(_adEnabled ? 'AD ON' : 'AD OFF'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Description and Transcript Button
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Scene Description:',
                        style: TextStyle(
                          color: AppTheme.cyanAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.clip.visualDescription,
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, height: 1.4),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          TranscriptDialog.show(
                            context,
                            title: widget.clip.title,
                            visualDescription: widget.clip.visualDescription,
                            transcriptText: widget.clip.transcript,
                          );
                        },
                        icon: const Icon(Icons.text_snippet, color: Colors.black),
                        label: const Text('OPEN FULL TRANSCRIPT'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          backgroundColor: AppTheme.surfaceHighlight,
                          foregroundColor: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
