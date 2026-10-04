import '../services/accessibility_service.dart';

class Track {
  final String id;
  final int? telegramMessageId;
  final String title;
  final String artist;
  final Duration duration;
  final String tag;
  final List<String> tags;
  final String description;
  final String musicalKey;
  final int bpm;
  final String notes;
  final String filename;
  final String streamUrl;
  final String telegramLink;

  const Track({
    required this.id,
    this.telegramMessageId,
    required this.title,
    required this.artist,
    required this.duration,
    required this.tag,
    this.tags = const [],
    required this.description,
    this.musicalKey = 'C Major',
    this.bpm = 120,
    this.notes = '',
    this.filename = '',
    this.streamUrl = '',
    this.telegramLink = '',
  });

  bool get hasStreamUrl => streamUrl.isNotEmpty;

  String get durationSpoken => AccessibilityService.formatDurationSpoken(duration);
  String get durationDigital => AccessibilityService.formatDurationDigital(duration);

  /// Semantic description read aloud by screen readers (TalkBack)
  String get accessibilityLabel =>
      'قطعه $title، اثر $artist. دسته‌بندی: $tag. مدت زمان: $durationSpoken. ${hasStreamUrl ? "آماده پخش آنلاین." : ""} برای پخش دو بار ضربه بزنید.';
}
