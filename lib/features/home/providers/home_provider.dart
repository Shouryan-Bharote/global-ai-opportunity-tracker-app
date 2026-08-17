import 'package:ai_nexus/core/providers/location_provider.dart';
import 'package:ai_nexus/features/events/models/event_model.dart';
import 'package:ai_nexus/features/events/providers/events_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// StateProvider for the selected category filter
final selectedCategoryProvider =
    StateProvider<String>((ref) => "Today's Events");

// Derived provider that reads from the global eventsProvider (single source of truth).
final homeEventsProvider = Provider<AsyncValue<List<EventModel>>>((ref) {
  return ref.watch(eventsProvider);
});

// Provider that filters events based on selected category, location state, and user interests
final filteredEventsProvider = Provider<List<EventModel>>((ref) {
  final category = ref.watch(selectedCategoryProvider);
  final eventsAsyncValue = ref.watch(eventsProvider);
  final locationAsync = ref.watch(locationProvider);
  final userInterests = ref.watch(userInterestsProvider);
  final hasLocation = locationAsync.valueOrNull != null;

  final allEvents = eventsAsyncValue.valueOrNull ?? [];
  if (allEvents.isEmpty) return [];

  // When location is ON, prefer nearby (in-person) events.
  // When location is OFF, use all events.
  final pool = hasLocation
      ? allEvents.where((e) => !e.isOnline || category == 'Online').toList()
      : allEvents;

  // Filter by selected category chip
  final categoryFiltered = pool.where((event) {
    switch (category) {
      case "Today's Events":
        final now = DateTime.now();
        return event.startDate.year == now.year &&
            event.startDate.month == now.month &&
            event.startDate.day == now.day;
      case 'Meetings':
        return event.tags.contains('Meeting');
      case 'Hackathons':
        return event.tags.contains('Hackathon');
      case 'Online':
        return event.isOnline;
      case 'Near me':
        return !event.isOnline || event.tags.contains('Near me');
      default:
        return true;
    }
  }).toList();

  // Rank by matching user interests
  return categoryFiltered
    ..sort((a, b) {
      var scoreA = 0;
      var scoreB = 0;
      for (final tag in a.tags) {
        if (userInterests.any((i) =>
            tag.toLowerCase().contains(i.toLowerCase()) ||
            i.toLowerCase().contains(tag.toLowerCase()))) {
          scoreA += 2;
        }
      }
      for (final tag in b.tags) {
        if (userInterests.any((i) =>
            tag.toLowerCase().contains(i.toLowerCase()) ||
            i.toLowerCase().contains(tag.toLowerCase()))) {
          scoreB += 2;
        }
      }
      return scoreB.compareTo(scoreA);
    });
});

// StateProvider for the Continue Exploring section
final selectedExploreCategoryProvider = StateProvider<String?>((ref) => null);

// User interests provider (defaults to key AI & Tech topics)
final userInterestsProvider = StateProvider<List<String>>(
  (ref) => ['AI', 'Data Science', 'Web3', 'Cybersecurity', 'Hackathon', 'Meeting'],
);

// Recommended Events Provider: Ranks by user interests and boosts nearby events
final recommendedEventsProvider = Provider<List<EventModel>>((ref) {
  final allEvents = ref.watch(eventsProvider).valueOrNull ?? [];
  if (allEvents.isEmpty) return [];

  final userInterests = ref.watch(userInterestsProvider);
  final hasLocation = ref.watch(locationProvider).valueOrNull != null;

  return List<EventModel>.from(allEvents)
    ..sort((a, b) {
      var scoreA = 0;
      var scoreB = 0;
      for (final tag in a.tags) {
        if (userInterests.any((i) =>
            tag.toLowerCase().contains(i.toLowerCase()) ||
            i.toLowerCase().contains(tag.toLowerCase()))) {
          scoreA += 2;
        }
      }
      for (final tag in b.tags) {
        if (userInterests.any((i) =>
            tag.toLowerCase().contains(i.toLowerCase()) ||
            i.toLowerCase().contains(tag.toLowerCase()))) {
          scoreB += 2;
        }
      }
      // Boost in-person events when location is ON
      if (hasLocation) {
        if (!a.isOnline) scoreA += 1;
        if (!b.isOnline) scoreB += 1;
      }
      return scoreB.compareTo(scoreA);
    });
});

// Provider that filters Upcoming events based on Explore Category
final upcomingFilteredEventsProvider = Provider<List<EventModel>>((ref) {
  final category = ref.watch(selectedExploreCategoryProvider);
  final allEvents = ref.watch(eventsProvider).valueOrNull ?? [];
  if (category == null) return allEvents;
  return allEvents.where((event) => event.tags.contains(category)).toList();
});
