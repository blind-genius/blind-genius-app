import '../services/accessibility_service.dart';

class Track {
  final String id;
  final String title;
  final String artist;
  final Duration duration;
  final String tag;
  final String description;
  final String musicalKey;
  final int bpm;
  final String notes;

  const Track({
    required this.id,
    required this.title,
    required this.artist,
    required this.duration,
    required this.tag,
    required this.description,
    this.musicalKey = 'C Major',
    this.bpm = 120,
    this.notes = '',
  });

  String get durationSpoken => AccessibilityService.formatDurationSpoken(duration);
  String get durationDigital => AccessibilityService.formatDurationDigital(duration);

  /// Semantic description read aloud by screen readers when focusing this track
  String get accessibilityLabel =>
      'Track $title by $artist. Category: $tag. Duration: $durationSpoken. Key: $musicalKey, Tempo: $bpm beats per minute. Double tap to play.';
}
