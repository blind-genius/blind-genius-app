import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/track.dart';
import 'accessibility_service.dart';

class AudioPlaybackService extends ChangeNotifier {
  Track? _currentTrack;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _totalDuration = Duration.zero;
  Timer? _playbackTimer;
  double _volume = 1.0;
  bool _isMuted = false;

  Track? get currentTrack => _currentTrack;
  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  Duration get totalDuration => _totalDuration;
  double get volume => _isMuted ? 0.0 : _volume;
  bool get isMuted => _isMuted;

  double get progressRatio {
    if (_totalDuration.inMilliseconds == 0) return 0.0;
    return (_position.inMilliseconds / _totalDuration.inMilliseconds).clamp(0.0, 1.0);
  }

  void playTrack(Track track) {
    if (_currentTrack?.id == track.id) {
      if (!_isPlaying) {
        resume();
      }
      return;
    }

    _currentTrack = track;
    _position = Duration.zero;
    _totalDuration = track.duration;
    _isPlaying = true;
    _startTimer();
    notifyListeners();

    AccessibilityService.hapticHeavy();
    AccessibilityService.announce(
      'Now playing ${track.title} by ${track.artist}. Duration ${track.durationSpoken}.',
    );
  }

  void togglePlayPause() {
    if (_currentTrack == null) return;
    if (_isPlaying) {
      pause();
    } else {
      resume();
    }
  }

  void pause() {
    if (!_isPlaying) return;
    _isPlaying = false;
    _playbackTimer?.cancel();
    notifyListeners();

    AccessibilityService.hapticMedium();
    AccessibilityService.announce(
      'Paused ${_currentTrack?.title ?? "playback"} at ${AccessibilityService.formatDurationSpoken(_position)}.',
    );
  }

  void resume() {
    if (_isPlaying || _currentTrack == null) return;
    _isPlaying = true;
    _startTimer();
    notifyListeners();

    AccessibilityService.hapticHeavy();
    AccessibilityService.announce(
      'Resumed ${_currentTrack?.title ?? "playback"}.',
    );
  }

  void seek(Duration newPosition) {
    if (_currentTrack == null) return;
    final clamped = newPosition < Duration.zero
        ? Duration.zero
        : (newPosition > _totalDuration ? _totalDuration : newPosition);
    _position = clamped;
    notifyListeners();

    AccessibilityService.announce(
      'Position set to ${AccessibilityService.formatDurationSpoken(_position)} of ${AccessibilityService.formatDurationSpoken(_totalDuration)}.',
    );
  }

  void seekForward({int seconds = 10}) {
    if (_currentTrack == null) return;
    final target = _position + Duration(seconds: seconds);
    seek(target);
    AccessibilityService.hapticSelection();
  }

  void seekBackward({int seconds = 10}) {
    if (_currentTrack == null) return;
    final target = _position - Duration(seconds: seconds);
    seek(target);
    AccessibilityService.hapticSelection();
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    notifyListeners();
    AccessibilityService.hapticSelection();
    AccessibilityService.announce(_isMuted ? 'Audio muted' : 'Audio unmuted');
  }

  void _startTimer() {
    _playbackTimer?.cancel();
    _playbackTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPlaying) {
        timer.cancel();
        return;
      }
      if (_position.inSeconds < _totalDuration.inSeconds) {
        _position += const Duration(seconds: 1);
        notifyListeners();
      } else {
        // Track finished
        _position = _totalDuration;
        _isPlaying = false;
        timer.cancel();
        notifyListeners();
        AccessibilityService.announce('Track ${_currentTrack?.title} finished playing.');
      }
    });
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    super.dispose();
  }
}
