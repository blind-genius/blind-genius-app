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

  factory Track.fromJson(Map<String, dynamic> json) {
    Duration dur = const Duration(minutes: 3);
    final rawDur = json['duration'];
    if (rawDur is String && rawDur.contains(':')) {
      final parts = rawDur.split(':');
      if (parts.length >= 2) {
        final m = int.tryParse(parts[0]) ?? 0;
        final s = int.tryParse(parts[1]) ?? 0;
        dur = Duration(minutes: m, seconds: s);
      }
    } else if (rawDur is int) {
      dur = Duration(seconds: rawDur);
    }

    final rawTags = json['tags'];
    List<String> parsedTags = [];
    if (rawTags is List) {
      parsedTags = rawTags.map((e) => e.toString()).toList();
    }

    String category = 'نوازندگی';
    final title = json['title']?.toString() ?? '';
    final caption = json['caption']?.toString() ?? json['description']?.toString() ?? '';
    if (title.contains('آرامش') || caption.contains('آرامش') || title.contains('طلوع')) {
      category = 'آرامش‌بخش';
    } else if (title.contains('دکلمه')) {
      category = 'دکلمه و شعر';
    } else if (title.contains('الکترونیک') || caption.contains('الکترونیک')) {
      category = 'الکترونیک';
    } else if (title.contains('حماسی')) {
      category = 'حماسی';
    } else if (title.contains('تکنوازی') || title.contains('پیانو')) {
      category = 'تکنوازی پیانو';
    } else if (parsedTags.isNotEmpty) {
      category = parsedTags.first.replaceAll('#', '');
    }

    return Track(
      id: json['id']?.toString() ?? '',
      telegramMessageId: json['telegram_message_id'] as int?,
      title: title,
      artist: json['artist']?.toString() ?? 'نابغه نابینا',
      duration: dur,
      tag: json['tag']?.toString() ?? category,
      tags: parsedTags,
      description: caption,
      filename: json['filename']?.toString() ?? '',
      streamUrl: json['stream_url']?.toString() ?? '',
      telegramLink: json['telegram_link']?.toString() ?? '',
      musicalKey: json['musical_key']?.toString() ?? 'C Major',
      bpm: json['bpm'] as int? ?? 120,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'telegram_message_id': telegramMessageId,
      'title': title,
      'artist': artist,
      'duration': '${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}',
      'tag': tag,
      'tags': tags,
      'caption': description,
      'filename': filename,
      'stream_url': streamUrl,
      'telegram_link': telegramLink,
      'musical_key': musicalKey,
      'bpm': bpm,
    };
  }
}

