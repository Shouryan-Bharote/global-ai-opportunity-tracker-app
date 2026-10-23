import 'package:ai_nexus/core/constants/ai_interest_catalog.dart';
import 'package:ai_nexus/core/providers/location_provider.dart';
import 'package:ai_nexus/features/auth/providers/onboarding_provider.dart';
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

  // Keep all events in pool; ranking below prioritizes user interests and location
  final pool = allEvents;

  // Filter by selected category chip
  var categoryFiltered = pool.where((event) {
    switch (category) {
      case "Today's Events":
        if (event.isDateTba) return false;
        final now = DateTime.now();
        final isToday = event.startDate.year == now.year &&
            event.startDate.month == now.month &&
            event.startDate.day == now.day;
        final isOngoing = now.isAfter(event.startDate) && now.isBefore(event.endDate);
        return isToday || isOngoing;
      case 'Meetings':
        return event.tags.any((t) {
          final l = t.toLowerCase();
          return l.contains('meet') ||
              l.contains('conference') ||
              l.contains('summit') ||
              l.contains('webinar');
        });
      case 'Hackathons':
        return event.tags.any((t) {
          final l = t.toLowerCase();
          return l.contains('hack') ||
              l.contains('challenge');
        });
      case 'Competitions':
        return event.tags.any((t) {
          final l = t.toLowerCase();
          return l.contains('competition') ||
              l.contains('quiz') ||
              l.contains('contest') ||
              l.contains('challenge');
        });
      case 'Online':
        return event.isOnline;
      case 'Near me':
        return !event.isOnline;
      default:
        return true;
    }
  }).toList();

  // If no events match "Today's Events" specifically, fall back to showing all upcoming events
  if (categoryFiltered.isEmpty && category == "Today's Events") {
    categoryFiltered = List<EventModel>.from(pool);
  }

  // Rank by matching user interests
  return categoryFiltered
    ..sort((a, b) {
      var scoreA = 0;
      var scoreB = 0;

      // Smart catalog matching boost
      if (AiInterestCatalog.eventMatchesInterests(a.tags, userInterests)) {
        scoreA += 4;
      }
      if (AiInterestCatalog.eventMatchesInterests(b.tags, userInterests)) {
        scoreB += 4;
      }

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
      if (hasLocation) {
        if (!a.isOnline) scoreA += 1;
        if (!b.isOnline) scoreB += 1;
      }
      return scoreB.compareTo(scoreA);
    });
});

// StateProvider for the Continue Exploring section
final selectedExploreCategoryProvider = StateProvider<String?>((ref) => null);

// User interests provider (delegates to persistent userInterestsNotifierProvider)
final userInterestsProvider = Provider<List<String>>((ref) {
  return ref.watch(userInterestsNotifierProvider);
});

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

      // Smart catalog matching boost (+6 points)
      if (AiInterestCatalog.eventMatchesInterests(a.tags, userInterests)) {
        scoreA += 6;
      }
      if (AiInterestCatalog.eventMatchesInterests(b.tags, userInterests)) {
        scoreB += 6;
      }

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
  return allEvents.where((event) => event.tags.any((t) => t.toLowerCase().contains(category.toLowerCase()))).toList();
});
