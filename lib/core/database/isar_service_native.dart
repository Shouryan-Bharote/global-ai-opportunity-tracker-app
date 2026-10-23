import 'package:ai_nexus/core/database/collections/event_collection.dart';
import 'package:ai_nexus/features/events/models/event_model.dart';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class IsarService {
  factory IsarService() {
    return _instance;
  }

  IsarService._internal();
  late final Isar db;
  bool _initialized = false;

  static final IsarService _instance = IsarService._internal();

  Future<void> init() async {
    if (_initialized) return;
    try {
      final dir = await getApplicationDocumentsDirectory();
      db = await Isar.open(
        [EventEntitySchema],
        directory: dir.path,
      );
      _initialized = true;
    } on Object catch (e) {
      debugPrint('[IsarService] Init error: $e');
    }
  }

  Future<void> cacheEvents(List<EventModel> events) async {
    if (!_initialized) return;
    try {
      final entities = events.map((e) {
        final entity = EventEntity()
          ..eventId = e.id
          ..title = e.title
          ..description = e.description
          ..host = e.host
          ..startDate = e.startDate
          ..endDate = e.endDate
          ..location = e.location
          ..isOnline = e.isOnline
          ..url = e.url
          ..imageUrl = e.imageUrl
          ..tags = e.tags
          ..isBookmarked = e.isBookmarked;
        return entity;
      }).toList();

      await db.writeTxn(() async {
        await db.eventEntitys.putAllByEventId(entities);
      });
      debugPrint('[IsarService] Cached ${entities.length} events for offline mode');
    } on Object catch (e) {
      debugPrint('[IsarService] Error caching events: $e');
    }
  }

  Future<List<EventModel>> getCachedEvents() async {
    if (!_initialized) return [];
    try {
      final entities = await db.eventEntitys.where().findAll();
      return entities.map((entity) {
        return EventModel(
          id: entity.eventId,
          title: entity.title,
          description: entity.description,
          host: entity.host,
          startDate: entity.startDate,
          endDate: entity.endDate,
          location: entity.location,
          isOnline: entity.isOnline,
          url: entity.url,
          imageUrl: entity.imageUrl,
          tags: entity.tags,
          isBookmarked: entity.isBookmarked,
        );
      }).toList();
    } on Object catch (e) {
      debugPrint('[IsarService] Error loading cached events: $e');
      return [];
    }
  }

  Future<EventModel?> getCachedEventById(String eventId) async {
    if (!_initialized) return null;
    try {
      final entity = await db.eventEntitys.getByEventId(eventId);
      if (entity == null) return null;
      return EventModel(
        id: entity.eventId,
        title: entity.title,
        description: entity.description,
        host: entity.host,
        startDate: entity.startDate,
        endDate: entity.endDate,
        location: entity.location,
        isOnline: entity.isOnline,
        url: entity.url,
        imageUrl: entity.imageUrl,
        tags: entity.tags,
        isBookmarked: entity.isBookmarked,
      );
    } on Object catch (e) {
      debugPrint('[IsarService] Error loading cached event $eventId: $e');
      return null;
    }
  }
}
