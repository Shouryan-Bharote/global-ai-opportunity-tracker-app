import 'package:ai_nexus/core/providers/location_provider.dart';
import 'package:ai_nexus/core/providers/repository_providers.dart';
import 'package:ai_nexus/features/events/models/event_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EventsNotifier extends AsyncNotifier<List<EventModel>> {
  @override
  Future<List<EventModel>> build() async {
    final repository = ref.watch(eventRepositoryProvider);
    
    // Watch location state. This will automatically rebuild the events 
    // when location is fetched.
    final locationAsync = ref.watch(locationProvider);
    
    // If location is loading, we can still fetch events without location,
    // or wait. Progressive loading means we can fetch with location if available.
    final position = locationAsync.valueOrNull;

    return repository.getEvents(
      latitude: position?.latitude,
      longitude: position?.longitude,
    );
  }

  // ============================================================
  // TOGGLE BOOKMARK
  // ============================================================

  Future<void> toggleBookmark(String eventId) async {
    final repository = ref.read(eventRepositoryProvider);

    // Save the current state in case we need to restore it.
    final previousState = state;

    // ==========================================================
    // OPTIMISTIC UPDATE
    // ==========================================================
    // Update the UI immediately without waiting for the
    // repository/database operation.

    state = state.whenData(
      (events) {
        return events.map(
          (event) {
            if (event.id == eventId) {
              return event.copyWith(
                isBookmarked: !event.isBookmarked,
              );
            }

            return event;
          },
        ).toList();
      },
    );

    // ==========================================================
    // SAVE TO REPOSITORY
    // ==========================================================

    try {
      await repository.toggleBookmark(eventId);
    } on Object catch (_) {
      // ========================================================
      // ROLLBACK
      // ========================================================
      // If saving fails, restore the previous UI state.

      state = previousState;
    }
  }
}

// ============================================================
// EVENTS PROVIDER
// ============================================================

final eventsProvider = AsyncNotifierProvider<EventsNotifier, List<EventModel>>(
  EventsNotifier.new,
);
