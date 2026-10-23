import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_model.freezed.dart';

@freezed
class EventModel with _$EventModel {
  const factory EventModel({
    required String id,
    required String title,
    required String description,
    required String host,
    required DateTime startDate,
    required DateTime endDate,
    required String location,
    required bool isOnline,
    required String url,
    required List<String> tags,
    String? imageUrl,
    @Default(false) bool isBookmarked,
  }) = _EventModel;
  const EventModel._();

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as String,
      title: cleanHtml(json['title'] as String?),
      description: cleanHtml(json['description'] as String?),
      host: cleanHtml(json['host'] as String?),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      location: json['location'] as String,
      isOnline: json['isOnline'] as bool,
      url: json['url'] as String,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      imageUrl: json['imageUrl'] as String?,
      isBookmarked: json['isBookmarked'] as bool? ?? false,
    );
  }

  static String cleanHtml(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '';
    var text = raw;

    // Convert block-level tags to line breaks
    text = text.replaceAll(RegExp('</?(?:div|p|h[1-6]|li|tr|section|article)[^>]*>', caseSensitive: false), '\n');
    text = text.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
    text = text.replaceAll(RegExp('</?(?:td|th|span|strong|b|em|i|a)[^>]*>', caseSensitive: false), ' ');

    // Strip any remaining HTML tags
    text = text.replaceAll(RegExp('<[^>]*>'), '');

    // Unescape common HTML entities
    text = text
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&apos;', "'")
        .replaceAll('&#8217;', "'")
        .replaceAll('&#8220;', '"')
        .replaceAll('&#8221;', '"')
        .replaceAll('&#8211;', '-');

    // Clean up excessive whitespace
    text = text.replaceAll(RegExp(r'[ \t]+'), ' ');
    text = text.replaceAll(RegExp(r'\n\s*\n\s*\n+'), '\n\n');
    return text.trim();
  }

  bool get isDateTba => startDate.millisecondsSinceEpoch <= 0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'host': host,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'location': location,
      'isOnline': isOnline,
      'url': url,
      'tags': tags,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'isBookmarked': isBookmarked,
    };
  }
}
