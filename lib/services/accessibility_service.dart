import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

/// Helper service dedicated to screen reader announcements,
/// haptic confirmations, and spoken time representations.
class AccessibilityService {
  /// Announces a message directly to TalkBack or VoiceOver screen readers.
  static Future<void> announce(String message, {TextDirection textDirection = TextDirection.ltr}) async {
    try {
      await SemanticsService.announce(message, textDirection);
    } catch (_) {
      // Fallback safe ignore if semantics service is unavailable
    }
  }

  /// Triggers a success haptic pattern for completed actions.
  static Future<void> hapticSuccess() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  /// Triggers a light tactile haptic click for navigation or item selection.
  static Future<void> hapticSelection() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (_) {}
  }

  /// Triggers a medium tactile click for button presses or important actions.
  static Future<void> hapticMedium() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  /// Triggers a heavy tactile alert for state toggles like Play/Pause.
  static Future<void> hapticHeavy() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (_) {}
  }

  /// Converts a [Duration] into a screen-reader friendly spoken string.
  /// Example: 03:25 -> "3 minutes and 25 seconds"
  /// Avoids TalkBack pronouncing colons awkwardly.
  static String formatDurationSpoken(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    if (minutes == 0) {
      return '$seconds seconds';
    } else if (seconds == 0) {
      return '$minutes ${minutes == 1 ? "minute" : "minutes"}';
    } else {
      return '$minutes ${minutes == 1 ? "minute" : "minutes"} and $seconds ${seconds == 1 ? "second" : "seconds"}';
    }
  }

  /// Standard digital clock format: mm:ss
  static String formatDurationDigital(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
