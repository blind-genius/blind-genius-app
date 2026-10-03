import '../services/accessibility_service.dart';

class ClipItem {
  final String id;
  final String title;
  final Duration duration;
  final String category;
  final String description;
  final bool hasAudioDescription;
  final String transcript;
  final String visualDescription;

  const ClipItem({
    required this.id,
    required this.title,
    required this.duration,
    required this.category,
    required this.description,
    this.hasAudioDescription = true,
    required this.transcript,
    required this.visualDescription,
  });

  String get durationSpoken => AccessibilityService.formatDurationSpoken(duration);
  String get durationDigital => AccessibilityService.formatDurationDigital(duration);

  String get accessibilityLabel =>
      'Video clip: $title. Category: $category. Duration: $durationSpoken. '
      '${hasAudioDescription ? "Includes Audio Description." : "Standard audio."} '
      'Description: $description. Double tap to watch or listen.';
}
