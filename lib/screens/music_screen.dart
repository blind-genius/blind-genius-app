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
  late String _selectedTag;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedTag = MockDataService.musicTags.first;
  }

  List<Track> get _filteredTracks {
    return MockDataService.sampleTracks.where((track) {
      final isAll = _selectedTag == 'همه' || _selectedTag == 'All';
      final matchesTag = isAll || track.tag == _selectedTag;
      final q = _searchQuery.trim().toLowerCase();
      final matchesQuery = q.isEmpty ||
          track.title.toLowerCase().contains(q) ||
          track.artist.toLowerCase().contains(q) ||
          track.description.toLowerCase().contains(q) ||
          track.tags.any((t) => t.toLowerCase().contains(q));
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
      'فیلتر $tag انتخاب شد. شامل $count قطعه.',
    );
  }

  void _showTrackDetails(Track track) {
    AccessibilityService.announce('نمایش جزئیات قطعه ${track.title}');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(color: AppTheme.goldAccent, width: 2),
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
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
                  track.artist,
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 15),
                ),
                const Divider(color: AppTheme.border, height: 24),
                // Caption / Story
                Text(
                  track.description,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 16),

                // Tags if available
                if (track.tags.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: track.tags.map((t) {
                      return Chip(
                        backgroundColor: AppTheme.surfaceHighlight,
                        side: const BorderSide(color: AppTheme.cyanAccent, width: 0.8),
                        label: Text(
                          '#$t',
                          style: const TextStyle(color: AppTheme.cyanAccent, fontSize: 12),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                ],

                // Metadata Chips
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    Chip(
                      backgroundColor: AppTheme.surfaceHighlight,
                      avatar: const Icon(Icons.category, size: 16, color: AppTheme.goldAccent),
                      label: Text(track.tag),
                    ),
                    Chip(
                      backgroundColor: AppTheme.surfaceHighlight,
                      avatar: const Icon(Icons.timer, size: 16, color: AppTheme.goldAccent),
                      label: Text(track.durationDigital),
                    ),
                    if (track.hasStreamUrl)
                      const Chip(
                        backgroundColor: AppTheme.surfaceHighlight,
                        avatar: Icon(Icons.cloud_done, size: 16, color: AppTheme.mintGreen),
                        label: Text('پخش ابری مستقیم', style: TextStyle(color: AppTheme.mintGreen)),
                      ),
                    if (track.telegramMessageId != null)
                      Chip(
                        backgroundColor: AppTheme.surfaceHighlight,
                        avatar: const Icon(Icons.send, size: 16, color: AppTheme.cyanAccent),
                        label: Text('تلگرام #${track.telegramMessageId}', style: const TextStyle(color: AppTheme.cyanAccent)),
                      ),
                  ],
                ),
                const SizedBox(height: 24),

                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    widget.audioService.playTrack(track);
                  },
                  icon: const Icon(Icons.play_arrow, color: Colors.black, size: 26),
                  label: Text('پخش ${track.title}'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(54),
                    backgroundColor: AppTheme.goldAccent,
                    foregroundColor: Colors.black,
                  ),
                ),
              ],
            ),
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
                    label: 'جستجو در آرشیو قطعات موسیقی',
                    hint: 'عنوان، شاعر یا برچسب مورد نظر را تایپ کنید',
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: AppTheme.textPrimary),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppTheme.surfaceHighlight,
                        hintText: 'جستجو در ۲۴ قطعه موسیقی...',
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
                                  AccessibilityService.announce('جستجو پاک شد');
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
                      'دسته‌بندی‌ها',
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
                          label: 'فیلتر $tag. ${isSelected ? "انتخاب شده." : ""}',
                          hint: 'دو بار ضربه بزنید برای اعمال فیلتر',
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
                        label: 'هیچ قطعه‌ای مطابق با جستجو یا فیلتر پیدا نشد.',
                        child: const Padding(
                          padding: EdgeInsets.all(32),
                          child: Text(
                            'قطعه‌ای مطابق با جستجو یافت نشد.\nدسته‌بندی دیگری را انتخاب کنید.',
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
                            semanticHint: 'برای پخش یا مشاهده توضیحات کامل دو بار ضربه بزنید',
                            borderColor: isCurrentTrack ? AppTheme.goldAccent : null,
                            backgroundColor: isCurrentTrack ? AppTheme.surfaceHighlight : null,
                            onTap: () => widget.audioService.playTrack(track),
                            child: Row(
                              children: [
                                // Play / Pause Button with explicit semantics
                                Semantics(
                                  button: true,
                                  label: isCurrentPlaying
                                      ? 'توقف قطعه ${track.title}'
                                      : 'پخش قطعه ${track.title}',
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
                                          if (track.hasStreamUrl) ...[
                                            const Icon(Icons.cloud_done, size: 14, color: AppTheme.mintGreen),
                                            const SizedBox(width: 4),
                                            const Text(
                                              'آنلاین',
                                              style: TextStyle(fontSize: 12, color: AppTheme.mintGreen, fontWeight: FontWeight.bold),
                                            ),
                                          ] else ...[
                                            const Icon(Icons.music_note, size: 14, color: AppTheme.cyanAccent),
                                            const SizedBox(width: 4),
                                            Text(
                                              track.tag,
                                              style: const TextStyle(fontSize: 12, color: AppTheme.cyanAccent),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // Song details info button
                                Semantics(
                                  button: true,
                                  label: 'مشاهده داستان و توضیحات قطعه ${track.title}',
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
