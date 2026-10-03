import 'package:flutter/material.dart';
import '../models/track.dart';
import '../services/accessibility_service.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';

class NowPlayingBar extends StatelessWidget {
  final AudioPlaybackService audioService;

  const NowPlayingBar({super.key, required this.audioService});

  @override
  Widget build(BuildContext context) {
    final track = audioService.currentTrack;
    if (track == null) return const SizedBox.shrink();

    final isPlaying = audioService.isPlaying;
    final position = audioService.position;
    final total = audioService.totalDuration;

    return Semantics(
      container: true,
      label: 'Mini player: ${track.title} by ${track.artist}. '
          'Currently ${isPlaying ? "Playing" : "Paused"}. '
          'Elapsed: ${AccessibilityService.formatDurationSpoken(position)} of ${AccessibilityService.formatDurationSpoken(total)}.',
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.surfaceHighlight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.goldAccent, width: 1.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Linear Progress Indicator
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: LinearProgressIndicator(
                value: audioService.progressRatio,
                backgroundColor: AppTheme.border,
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.goldAccent),
                minHeight: 4,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  // Album / Track Icon
                  Semantics(
                    excludeSemantics: true,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: const Icon(Icons.music_note, color: AppTheme.goldAccent, size: 26),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Title and Artist
                  Expanded(
                    child: InkWell(
                      onTap: () => _openFullPlayerModal(context, track),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            track.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${track.artist} • ${AccessibilityService.formatDurationDigital(position)} / ${track.durationDigital}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Rewind 10s
                  Semantics(
                    button: true,
                    label: 'Rewind 10 seconds',
                    hint: 'Double tap to skip backward 10 seconds',
                    child: IconButton(
                      icon: const Icon(Icons.replay_10, color: AppTheme.textPrimary, size: 26),
                      onPressed: audioService.seekBackward,
                    ),
                  ),
                  // Play / Pause
                  Semantics(
                    button: true,
                    label: isPlaying ? 'Pause ${track.title}' : 'Resume ${track.title}',
                    hint: 'Double tap to toggle playback',
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.goldAccent,
                      ),
                      child: IconButton(
                        icon: Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.black,
                          size: 28,
                        ),
                        onPressed: audioService.togglePlayPause,
                      ),
                    ),
                  ),
                  // Forward 10s
                  Semantics(
                    button: true,
                    label: 'Fast forward 10 seconds',
                    hint: 'Double tap to skip forward 10 seconds',
                    child: IconButton(
                      icon: const Icon(Icons.forward_10, color: AppTheme.textPrimary, size: 26),
                      onPressed: audioService.seekForward,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openFullPlayerModal(BuildContext context, Track track) {
    AccessibilityService.announce('Opening full player for ${track.title}');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _FullPlayerSheet(audioService: audioService, track: track),
    );
  }
}

class _FullPlayerSheet extends StatefulWidget {
  final AudioPlaybackService audioService;
  final Track track;

  const _FullPlayerSheet({required this.audioService, required this.track});

  @override
  State<_FullPlayerSheet> createState() => _FullPlayerSheetState();
}

class _FullPlayerSheetState extends State<_FullPlayerSheet> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.audioService,
      builder: (context, _) {
        final track = widget.audioService.currentTrack ?? widget.track;
        final isPlaying = widget.audioService.isPlaying;
        final position = widget.audioService.position;
        final total = widget.audioService.totalDuration;
        final totalSeconds = total.inSeconds == 0 ? 1 : total.inSeconds;
        final currentSeconds = position.inSeconds.clamp(0, totalSeconds);

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          decoration: const BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(color: AppTheme.goldAccent, width: 2),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppTheme.border,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Semantics(
                        header: true,
                        child: const Text(
                          'Now Playing',
                          style: TextStyle(
                            color: AppTheme.goldAccent,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Semantics(
                        button: true,
                        label: 'Close full player sheet',
                        child: IconButton(
                          icon: const Icon(Icons.keyboard_arrow_down, size: 32, color: AppTheme.textPrimary),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Cover Art / Visual Sound Graphic with accessibility label
                  Semantics(
                    label: 'Artwork for ${track.title}. Golden grand piano acoustic wave visualizer.',
                    child: Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceHighlight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.border, width: 2),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isPlaying ? Icons.graphic_eq : Icons.piano,
                            size: 80,
                            color: AppTheme.goldAccent,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            track.tag,
                            style: const TextStyle(
                              color: AppTheme.cyanAccent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Title & Artist
                  Semantics(
                    label: 'Track title: ${track.title}, Artist: ${track.artist}',
                    child: Column(
                      children: [
                        Text(
                          track.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          track.artist,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Key & BPM details for musicians
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceHighlight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Key: ${track.musicalKey}',
                          style: const TextStyle(fontSize: 13, color: AppTheme.goldAccent),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceHighlight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Tempo: ${track.bpm} BPM',
                          style: const TextStyle(fontSize: 13, color: AppTheme.cyanAccent),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Accessible Slider
                  Semantics(
                    slider: true,
                    label: 'Playback progress slider',
                    value: '${AccessibilityService.formatDurationSpoken(position)} of ${AccessibilityService.formatDurationSpoken(total)}',
                    increasedValue: 'Skip forward 10 seconds',
                    decreasedValue: 'Skip backward 10 seconds',
                    onIncrease: widget.audioService.seekForward,
                    onDecrease: widget.audioService.seekBackward,
                    child: Slider(
                      value: currentSeconds.toDouble(),
                      min: 0.0,
                      max: totalSeconds.toDouble(),
                      onChanged: (val) {
                        widget.audioService.seek(Duration(seconds: val.toInt()));
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AccessibilityService.formatDurationDigital(position),
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                        ),
                        Text(
                          track.durationDigital,
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Full Controls Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Semantics(
                        button: true,
                        label: 'Rewind 10 seconds',
                        child: IconButton(
                          iconSize: 36,
                          icon: const Icon(Icons.replay_10, color: AppTheme.textPrimary),
                          onPressed: widget.audioService.seekBackward,
                        ),
                      ),
                      Semantics(
                        button: true,
                        label: isPlaying ? 'Pause ${track.title}' : 'Play ${track.title}',
                        child: Container(
                          width: 68,
                          height: 68,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.goldAccent,
                          ),
                          child: IconButton(
                            iconSize: 38,
                            icon: Icon(
                              isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.black,
                            ),
                            onPressed: widget.audioService.togglePlayPause,
                          ),
                        ),
                      ),
                      Semantics(
                        button: true,
                        label: 'Fast forward 10 seconds',
                        child: IconButton(
                          iconSize: 36,
                          icon: const Icon(Icons.forward_10, color: AppTheme.textPrimary),
                          onPressed: widget.audioService.seekForward,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
