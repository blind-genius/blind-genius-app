import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../models/track.dart';
import 'accessibility_service.dart';

class AudioPlaybackService extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  Track? _currentTrack;
  bool _isPlaying = false;
  bool _isBuffering = false;
  Duration _position = Duration.zero;
  Duration _totalDuration = Duration.zero;
  double _volume = 1.0;
  bool _isMuted = false;

  StreamSubscription? _posSub;
  StreamSubscription? _durSub;
  StreamSubscription? _playerStateSub;

  AudioPlaybackService() {
    _initListeners();
  }

  void _initListeners() {
    _posSub = _player.positionStream.listen((pos) {
      _position = pos;
      notifyListeners();
    });

    _durSub = _player.durationStream.listen((dur) {
      if (dur != null && dur > Duration.zero) {
        _totalDuration = dur;
        notifyListeners();
      }
    });

    _playerStateSub = _player.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      final processingState = playerState.processingState;

      _isPlaying = isPlaying;
      _isBuffering = (processingState == ProcessingState.buffering ||
          processingState == ProcessingState.loading);

      if (processingState == ProcessingState.completed) {
        _isPlaying = false;
        _position = _totalDuration;
        notifyListeners();
        AccessibilityService.announce('پخش قطعه ${_currentTrack?.title ?? ""} به پایان رسید.');
      } else {
        notifyListeners();
      }
    });
  }

  Track? get currentTrack => _currentTrack;
  bool get isPlaying => _isPlaying;
  bool get isBuffering => _isBuffering;
  Duration get position => _position;
  Duration get totalDuration => _totalDuration;
  double get volume => _isMuted ? 0.0 : _volume;
  bool get isMuted => _isMuted;

  double get progressRatio {
    if (_totalDuration.inMilliseconds == 0) return 0.0;
    return (_position.inMilliseconds / _totalDuration.inMilliseconds).clamp(0.0, 1.0);
  }

  Future<void> playTrack(Track track) async {
    if (_currentTrack?.id == track.id) {
      if (!_isPlaying) {
        await resume();
      }
      return;
    }

    _currentTrack = track;
    _position = Duration.zero;
    _totalDuration = track.duration;
    _isPlaying = true;
    _isBuffering = true;
    notifyListeners();

    AccessibilityService.hapticHeavy();
    AccessibilityService.announce(
      'در حال بارگذاری و پخش ${track.title}. مدت زمان ${track.durationSpoken}.',
    );

    try {
      if (track.hasStreamUrl && track.streamUrl.isNotEmpty) {
        await _player.stop();
        await _player.setUrl(track.streamUrl);
        await _player.play();
      } else {
        _isBuffering = false;
        _isPlaying = false;
        notifyListeners();
        AccessibilityService.announce('فایل صوتی برای این قطعه موجود نیست.');
      }
    } catch (e) {
      debugPrint('Error playing audio track: $e');
      _isPlaying = false;
      _isBuffering = false;
      notifyListeners();
      AccessibilityService.announce('خطا در برقراری ارتباط و پخش قطعه صوتی.');
    }
  }

  Future<void> togglePlayPause() async {
    if (_currentTrack == null) return;
    if (_isPlaying) {
      await pause();
    } else {
      await resume();
    }
  }

  Future<void> pause() async {
    if (!_isPlaying) return;
    try {
      await _player.pause();
    } catch (e) {
      debugPrint('Error pausing player: $e');
    }
    _isPlaying = false;
    notifyListeners();

    AccessibilityService.hapticMedium();
    AccessibilityService.announce(
      'پخش ${_currentTrack?.title ?? "موزیک"} متوقف شد در ${AccessibilityService.formatDurationSpoken(_position)}.',
    );
  }

  Future<void> resume() async {
    if (_isPlaying || _currentTrack == null) return;
    try {
      await _player.play();
    } catch (e) {
      debugPrint('Error resuming player: $e');
    }
    _isPlaying = true;
    notifyListeners();

    AccessibilityService.hapticHeavy();
    AccessibilityService.announce(
      'ادامه پخش ${_currentTrack?.title ?? "موزیک"}.',
    );
  }

  Future<void> seek(Duration newPosition) async {
    if (_currentTrack == null) return;
    final clamped = newPosition < Duration.zero
        ? Duration.zero
        : (newPosition > _totalDuration ? _totalDuration : newPosition);
    _position = clamped;
    notifyListeners();

    try {
      await _player.seek(clamped);
    } catch (e) {
      debugPrint('Error seeking: $e');
    }

    AccessibilityService.announce(
      'موقعیت روی ${AccessibilityService.formatDurationSpoken(_position)} از ${AccessibilityService.formatDurationSpoken(_totalDuration)} تنظیم شد.',
    );
  }

  Future<void> seekForward({int seconds = 10}) async {
    if (_currentTrack == null) return;
    final target = _position + Duration(seconds: seconds);
    await seek(target);
    AccessibilityService.hapticSelection();
  }

  Future<void> seekBackward({int seconds = 10}) async {
    if (_currentTrack == null) return;
    final target = _position - Duration(seconds: seconds);
    await seek(target);
    AccessibilityService.hapticSelection();
  }

  Future<void> toggleMute() async {
    _isMuted = !_isMuted;
    try {
      await _player.setVolume(_isMuted ? 0.0 : _volume);
    } catch (e) {
      debugPrint('Error setting volume: $e');
    }
    notifyListeners();
    AccessibilityService.hapticSelection();
    AccessibilityService.announce(_isMuted ? 'صدا قطع شد' : 'صدا وصل شد');
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _durSub?.cancel();
    _playerStateSub?.cancel();
    _player.dispose();
    super.dispose();
  }
}
