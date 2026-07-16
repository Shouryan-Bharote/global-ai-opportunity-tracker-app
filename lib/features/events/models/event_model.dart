import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_model.freezed.dart';

@freezed
class EventModel with _$EventModel {
  const EventModel._();
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

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      host: json['host'] as String,
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
