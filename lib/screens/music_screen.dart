import 'package:flutter/material.dart';
import '../models/track.dart';
import '../services/accessibility_service.dart';
import '../services/audio_service.dart';
import '../services/mock_data_service.dart';
import '../theme/app_theme.dart';
import '../widgets/accessible_card.dart';

class MusicScreen extends StatefulWidget {
  final AudioPlaybackService audioService;

  const MusicScreen({super.key, required this.audioService});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  String _selectedTag = 'All';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<Track> get _filteredTracks {
    return MockDataService.sampleTracks.where((track) {
      final matchesTag = _selectedTag == 'All' || track.tag == _selectedTag;
      final matchesQuery = _searchQuery.isEmpty ||
          track.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          track.artist.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          track.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesTag && matchesQuery;
    }).toList();
  }

  void _onTagSelected(String tag) {
    if (_selectedTag == tag) return;
    setState(() {
      _selectedTag = tag;
    });
    AccessibilityService.hapticSelection();
    final count = _filteredTracks.length;
    AccessibilityService.announce(
      'Selected filter $tag. Showing $count ${count == 1 ? "track" : "tracks"}.',
    );
  }

  void _showTrackDetails(Track track) {
    AccessibilityService.announce('Opening song notes for ${track.title}');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(color: AppTheme.goldAccent, width: 2),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(
                        track.title,
                        style: const TextStyle(
                          color: AppTheme.goldAccent,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppTheme.textPrimary),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'By ${track.artist}',
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 15),
              ),
              const Divider(color: AppTheme.border, height: 24),
              Text(
                track.description,
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15, height: 1.5),
              ),
              const SizedBox(height: 14),
              if (track.notes.isNotEmpty) ...[
                const Text(
                  'Acoustic Notes & Composition Story:',
                  style: TextStyle(
                    color: AppTheme.cyanAccent,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  track.notes,
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, height: 1.4),
                ),
                const SizedBox(height: 14),
              ],
              Row(
                children: [
                  Chip(
                    backgroundColor: AppTheme.surfaceHighlight,
                    label: Text('Key: ${track.musicalKey}'),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    backgroundColor: AppTheme.surfaceHighlight,
                    label: Text('${track.bpm} BPM'),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    backgroundColor: AppTheme.surfaceHighlight,
                    label: Text(track.durationDigital),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  widget.audioService.playTrack(track);
                },
                icon: const Icon(Icons.play_arrow, color: Colors.black),
                label: Text('PLAY ${track.title.toUpperCase()}'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.audioService,
      builder: (context, _) {
        final currentTrack = widget.audioService.currentTrack;
        final isPlaying = widget.audioService.isPlaying;

        return Column(
          children: [
            // Search Bar & Filter Header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              color: AppTheme.background,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    textField: true,
                    label: 'Search music tracks by title or keyword',
                    hint: 'Type here to filter tracks in real time',
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: AppTheme.textPrimary),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppTheme.surfaceHighlight,
                        hintText: 'Search tracks by title...',
                        hintStyle: const TextStyle(color: AppTheme.textMuted),
                        prefixIcon: const Icon(Icons.search, color: AppTheme.goldAccent),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: AppTheme.textPrimary),
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                    _searchQuery = '';
                                  });
                                  AccessibilityService.announce('Search cleared');
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppTheme.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppTheme.goldAccent, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Accessible Tags Horizontal Filter
                  Semantics(
                    header: true,
                    child: const Text(
                      'Categories',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: MockDataService.musicTags.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final tag = MockDataService.musicTags[index];
                        final isSelected = _selectedTag == tag;

                        return Semantics(
                          button: true,
                          selected: isSelected,
                          label: 'Filter by $tag. ${isSelected ? "Currently selected." : ""}',
                          hint: 'Double tap to filter music list',
                          child: ChoiceChip(
                            label: Text(tag),
                            selected: isSelected,
                            onSelected: (_) => _onTagSelected(tag),
                            selectedColor: AppTheme.goldAccent,
                            backgroundColor: AppTheme.surfaceHighlight,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.black : AppTheme.textPrimary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            ),
                            side: BorderSide(
                              color: isSelected ? AppTheme.goldAccent : AppTheme.border,
                              width: 1.5,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: AppTheme.border, height: 1),

            // Track List
            Expanded(
              child: _filteredTracks.isEmpty
                  ? Center(
                      child: Semantics(
                        label: 'No tracks found for the current search or filter.',
                        child: const Padding(
                          padding: EdgeInsets.all(32),
                          child: Text(
                            'No tracks found matching your query.\nTry picking another category.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppTheme.textMuted, fontSize: 16),
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      itemCount: _filteredTracks.length,
                      itemBuilder: (context, index) {
                        final track = _filteredTracks[index];
                        final isCurrentTrack = currentTrack?.id == track.id;
                        final isCurrentPlaying = isCurrentTrack && isPlaying;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: AccessibleCard(
                            semanticLabel: track.accessibilityLabel,
                            semanticHint: 'Double tap to play or view details',
                            borderColor: isCurrentTrack ? AppTheme.goldAccent : null,
                            backgroundColor: isCurrentTrack ? AppTheme.surfaceHighlight : null,
                            onTap: () => widget.audioService.playTrack(track),
                            child: Row(
                              children: [
                                // Play / Pause Button with explicit semantics
                                Semantics(
                                  button: true,
                                  label: isCurrentPlaying
                                      ? 'Pause track: ${track.title}'
                                      : 'Play track: ${track.title}',
                                  child: Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isCurrentTrack ? AppTheme.goldAccent : AppTheme.surfaceHighlight,
                                      border: Border.all(
                                        color: isCurrentTrack ? AppTheme.goldAccent : AppTheme.border,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: IconButton(
                                      icon: Icon(
                                        isCurrentPlaying ? Icons.pause : Icons.play_arrow,
                                        color: isCurrentTrack ? Colors.black : AppTheme.goldAccent,
                                        size: 30,
                                      ),
                                      onPressed: () {
                                        if (isCurrentTrack) {
                                          widget.audioService.togglePlayPause();
                                        } else {
                                          widget.audioService.playTrack(track);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),

                                // Track Metadata
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        track.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: isCurrentTrack ? AppTheme.goldAccent : AppTheme.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${track.artist} • ${track.tag}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.timer_outlined, size: 14, color: AppTheme.textMuted),
                                          const SizedBox(width: 4),
                                          Text(
                                            track.durationDigital,
                                            style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                          ),
                                          const SizedBox(width: 12),
                                          const Icon(Icons.piano, size: 14, color: AppTheme.cyanAccent),
                                          const SizedBox(width: 4),
                                          Text(
                                            track.musicalKey,
                                            style: const TextStyle(fontSize: 12, color: AppTheme.cyanAccent),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // Song details info button
                                Semantics(
                                  button: true,
                                  label: 'View details and story for ${track.title}',
                                  child: IconButton(
                                    icon: const Icon(Icons.info_outline, color: AppTheme.textMuted),
                                    onPressed: () => _showTrackDetails(track),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
