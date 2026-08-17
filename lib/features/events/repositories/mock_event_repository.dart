import 'package:ai_nexus/core/mock/mock_events.dart';
import 'package:ai_nexus/features/events/models/event_model.dart';
import 'package:ai_nexus/features/events/repositories/event_repository.dart';

/// Mock implementation of [EventRepository].
/// 
/// Uses in-memory data from [MockEvents]. When you're ready to connect
/// a real backend, create a new class (e.g., `HttpEventRepository`)
/// that implements [EventRepository] and swap it in `repository_providers.dart`.
class MockEventRepository implements EventRepository {
  // In-memory state to persist bookmarks during the session
  final List<EventModel> _events = List.from(MockEvents.events);

  @override
  Future<List<EventModel>> getEvents({double? latitude, double? longitude}) async {
    // Simulate network delay to test loading states
    await Future<void>.delayed(const Duration(milliseconds: 800));
    return List.unmodifiable(_events);
  }

  @override
  Future<EventModel?> getEventById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final index = _events.indexWhere((event) => event.id == id);
    if (index == -1) return null;
    return _events[index];
  }

  @override
  Future<void> toggleBookmark(String eventId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final index = _events.indexWhere((event) => event.id == eventId);
    if (index != -1) {
      final currentEvent = _events[index];
      _events[index] = currentEvent.copyWith(isBookmarked: !currentEvent.isBookmarked);
    }
  }

  @override
  Future<List<EventModel>> searchEvents(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (query.isEmpty) return List.unmodifiable(_events);

    final lowerQuery = query.toLowerCase();
    return _events.where((event) {
      return event.title.toLowerCase().contains(lowerQuery) ||
          event.description.toLowerCase().contains(lowerQuery) ||
          event.host.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  @override
  Future<List<EventModel>> getEventsByFilter({
    String? category,
    String? city,
    bool? isOnline,
    List<String>? tags,
    double? latitude,
    double? longitude,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));

    return _events.where((event) {
      // Filter by category (matches tag)
      if (category != null && category.isNotEmpty) {
        if (!event.tags.contains(category)) return false;
      }

      // Filter by city (partial match on location)
      if (city != null && city.isNotEmpty) {
        if (!event.location.toLowerCase().contains(city.toLowerCase())) {
          return false;
        }
      }

      // Filter by online/offline
      if (isOnline != null) {
        if (event.isOnline != isOnline) return false;
      }

      // Filter by tags (event must contain ALL specified tags)
      if (tags != null && tags.isNotEmpty) {
        for (final tag in tags) {
          if (!event.tags.contains(tag)) return false;
        }
      }

      return true;
    }).toList();
  }
}
