import 'package:ai_nexus/features/events/models/event_model.dart';
import 'package:ai_nexus/features/events/providers/events_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// StateProvider for the selected category filter
final selectedCategoryProvider = StateProvider<String>((ref) => "Today's Events");

// Derived provider that reads from the global eventsProvider (single source of truth).
// Previously this was a standalone FutureProvider hitting MockEvents directly.
final homeEventsProvider = Provider<AsyncValue<List<EventModel>>>((ref) {
  return ref.watch(eventsProvider);
});

// Provider that filters events based on the selected category
final filteredEventsProvider = Provider<List<EventModel>>((ref) {
  // Watch the selected category and the fetched events
  final category = ref.watch(selectedCategoryProvider);
  final eventsAsyncValue = ref.watch(eventsProvider);

  // If events are not yet loaded, return empty list (handled by UI)
  final allEvents = eventsAsyncValue.valueOrNull ?? [];

  return allEvents.where((event) {
    if (category == "Today's Events") {
      // Check if start date is today
      final now = DateTime.now();
      return event.startDate.year == now.year &&
          event.startDate.month == now.month &&
          event.startDate.day == now.day;
    } else if (category == 'Meetings') {
      return event.tags.contains('Meeting');
    } else if (category == 'Hackathons') {
      return event.tags.contains('Hackathon');
    } else if (category == 'Online') {
      return event.isOnline;
    } else if (category == 'Near me') {
      return event.tags.contains('Near me');
    }
    return true; // Default
  }).toList();
});

// StateProvider for the Continue Exploring section
final selectedExploreCategoryProvider = StateProvider<String?>((ref) => null);

// Provider that filters Upcoming events based on Explore Category
final upcomingFilteredEventsProvider = Provider<List<EventModel>>((ref) {
  final category = ref.watch(selectedExploreCategoryProvider);
  final eventsAsyncValue = ref.watch(eventsProvider);
  final allEvents = eventsAsyncValue.valueOrNull ?? [];

  if (category == null) {
    return allEvents;
  }

  return allEvents.where((event) {
    return event.tags.contains(category);
  }).toList();
});
