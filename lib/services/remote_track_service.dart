import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:encrypt/encrypt.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/track.dart';
import 'accessibility_service.dart';
import 'mock_data_service.dart';

class RemoteTrackService extends ChangeNotifier {
  static const String _cacheKey = 'cached_tracks_json_v1';
  static const String _remoteUrl =
      'https://raw.githubusercontent.com/blind-genius/blind-genius-app/main/tracks_metadata.enc';
  static const String _secretKey = 'BlindGeniusMusicSecretKey2026!@#'; // Exactly 32 bytes

  List<Track> _tracks = [];
  bool _isLoading = false;
  String? _lastError;

  List<Track> get tracks => _tracks;
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;

  RemoteTrackService() {
    _init();
  }

  Future<void> _init() async {
    // 1. Load initial tracks immediately from local cache or fallback
    await _loadFromLocal();
    // 2. Fetch updates silently in background from GitHub
    fetchRemoteTracks(silent: true);
  }

  Future<void> _loadFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_cacheKey);
      if (cachedJson != null && cachedJson.isNotEmpty) {
        final List<dynamic> list = json.decode(cachedJson);
        _tracks = list.map((item) => Track.fromJson(item as Map<String, dynamic>)).toList();
        notifyListeners();
        return;
      }
    } catch (e) {
      debugPrint('Error loading cached tracks: $e');
    }

    // Fallback to bundled list
    _tracks = List.from(MockDataService.tracks);
    notifyListeners();
  }

  Future<void> fetchRemoteTracks({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      _lastError = null;
      notifyListeners();
      AccessibilityService.announce('در حال بررسی و دریافت جدیدترین قطعات موسیقی...');
    }

    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);
      final request = await client.getUrl(Uri.parse(_remoteUrl));
      request.headers.set('User-Agent', 'BlindGenius-App');
      final response = await request.close();

      if (response.statusCode == 200) {
        final encryptedBase64 = await response.transform(utf8.decoder).join();
        final decryptedJson = _decryptPayload(encryptedBase64.trim());
        final List<dynamic> list = json.decode(decryptedJson);
        final newTracks = list.map((item) => Track.fromJson(item as Map<String, dynamic>)).toList();

        final oldCount = _tracks.length;
        _tracks = newTracks;

        // Save to offline cache
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_cacheKey, decryptedJson);

        _lastError = null;
        notifyListeners();

        if (newTracks.length > oldCount) {
          final added = newTracks.length - oldCount;
          AccessibilityService.hapticSuccess();
          AccessibilityService.announce('آرشیو به‌روزرسانی شد. $added قطعه جدید اضافه گردید.');
        } else if (!silent) {
          AccessibilityService.announce('آرشیو موسیقی به‌روز است. مجموعاً ${newTracks.length} قطعه موجود است.');
        }
      } else {
        _lastError = 'خطای ارتباط با سرور (${response.statusCode})';
        if (!silent) {
          AccessibilityService.announce(_lastError!);
        }
      }
    } catch (e) {
      debugPrint('Error fetching remote tracks: $e');
      _lastError = 'عدم دسترسی به اینترنت';
      if (!silent) {
        AccessibilityService.announce('خطا در ارتباط با اینترنت. از آرشیو ذخیره‌شده استفاده می‌شود.');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  static String _decryptPayload(String combinedBase64) {
    final key = Key.fromUtf8(_secretKey);
    final rawBytes = base64.decode(combinedBase64);
    if (rawBytes.length < 17) {
      throw Exception('Invalid encrypted payload');
    }
    final ivBytes = rawBytes.sublist(0, 16);
    final cipherBytes = rawBytes.sublist(16);

    final iv = IV(Uint8List.fromList(ivBytes));
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    return encrypter.decrypt(Encrypted(Uint8List.fromList(cipherBytes)), iv: iv);
  }
}
