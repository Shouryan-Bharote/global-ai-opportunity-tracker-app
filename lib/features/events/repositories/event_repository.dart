import 'package:ai_nexus/features/events/models/event_model.dart';

/// Abstract contract for all event data sources.
///
/// To integrate a real database, create a new class that implements
/// this interface (e.g., `HttpEventRepository`, `FirebaseEventRepository`)
/// and swap it in `repository_providers.dart`. No UI changes needed.
abstract class EventRepository {
  /// Fetches all events. Can optionally pass location to fetch nearby events.
  Future<List<EventModel>> getEvents({double? latitude, double? longitude});

  /// Fetches a single event by its ID.
  Future<EventModel?> getEventById(String id);

  /// Toggles the bookmark status of an event.
  Future<void> toggleBookmark(String eventId);

  /// Searches events by a text query (matches title, description, host).
  Future<List<EventModel>> searchEvents(String query);

  /// Filters events by optional criteria.
  /// All parameters are optional — only non-null ones are applied.
  Future<List<EventModel>> getEventsByFilter({
    String? category,
    String? city,
    bool? isOnline,
    List<String>? tags,
    double? latitude,
    double? longitude,
  });
}
