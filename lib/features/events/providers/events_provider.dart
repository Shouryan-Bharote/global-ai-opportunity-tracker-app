import 'package:ai_nexus/core/providers/repository_providers.dart';
import 'package:ai_nexus/features/events/models/event_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EventsNotifier extends AsyncNotifier<List<EventModel>> {
  @override
  Future<List<EventModel>> build() async {
    final repository = ref.watch(eventRepositoryProvider);
    return await repository.getEvents();
  }

  Future<void> toggleBookmark(String eventId) async {
    final repository = ref.read(eventRepositoryProvider);
    
    // Optimistic update for snappy UI
    state = state.whenData((events) {
      return events.map((e) {
        if (e.id == eventId) {
          return e.copyWith(isBookmarked: !e.isBookmarked);
        }
        return e;
      }).toList();
    });

    try {
      await repository.toggleBookmark(eventId);
    } catch (e) {
      // Revert on failure by refreshing
      ref.invalidateSelf();
    }
  }
}

final eventsProvider = AsyncNotifierProvider<EventsNotifier, List<EventModel>>(() {
  return EventsNotifier();
});
