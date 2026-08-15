import 'package:ai_nexus/features/events/models/event_model.dart';
import 'package:ai_nexus/features/events/providers/events_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ============================================================
// EXPLORE FILTER STATE
// ============================================================

// Selected top filter:
// All, This Week, Free, Paid, Offline, Online
final exploreFilterProvider = StateProvider<String>((ref) => 'All');

// Selected category.
// null = no category selected.
final exploreCategoryProvider = StateProvider<String?>((ref) => null);

// Selected city.
// null = no city selected.
final exploreCityProvider = StateProvider<String?>((ref) => null);

// Search text entered by the user.
final exploreSearchQueryProvider = StateProvider<String>((ref) => '');

// Controls "See all" / "Show less".
final exploreResultsExpandedProvider = StateProvider<bool>((ref) => false);

// ============================================================
// FILTERED EVENTS
// ============================================================

final exploreFilteredEventsProvider = Provider<AsyncValue<List<EventModel>>>((
  ref,
) {
  // Read current Explore selections.
  final activeFilter = ref.watch(exploreFilterProvider);
  final activeCategory = ref.watch(exploreCategoryProvider);
  final activeCity = ref.watch(exploreCityProvider);

  final searchQuery = ref
      .watch(exploreSearchQueryProvider)
      .trim()
      .toLowerCase();

  // Get all events from the main events provider.
  final eventsAsyncValue = ref.watch(eventsProvider);

  return eventsAsyncValue.whenData((allEvents) {
    return allEvents.where((event) {
      // ======================================================
      // 1. SEARCH
      // ======================================================

      if (searchQuery.isNotEmpty) {
        final title = event.title.toLowerCase();
        final description = event.description.toLowerCase();
        final host = event.host.toLowerCase();

        final matchesSearch =
            title.contains(searchQuery) ||
            description.contains(searchQuery) ||
            host.contains(searchQuery);

        if (!matchesSearch) {
          return false;
        }
      }

      // ======================================================
      // 2. TOP FILTER CHIPS
      // ======================================================

      // Online
      if (activeFilter == 'Online') {
        if (!event.isOnline) {
          return false;
        }
      }

      // Offline
      if (activeFilter == 'Offline') {
        if (event.isOnline) {
          return false;
        }
      }

      // This Week
      if (activeFilter == 'This Week') {
        final now = DateTime.now();

        // Start of current week: Monday
        final startOfWeek =
            DateTime(
              now.year,
              now.month,
              now.day,
            ).subtract(
              Duration(days: now.weekday - 1),
            );

        // Start of next week
        final startOfNextWeek = startOfWeek.add(const Duration(days: 7));

        // Event must start during this week.
        if (event.startDate.isBefore(startOfWeek) ||
            !event.startDate.isBefore(startOfNextWeek)) {
          return false;
        }
      }

      // ======================================================
      // FREE / PAID
      // ======================================================
      //
      // Your EventModel currently does NOT contain:
      //
      // price
      // isFree
      // ticketPrice
      //
      // Therefore we intentionally do not filter Free/Paid
      // yet. We should add this properly later instead of
      // guessing from event data.

      // ======================================================
      // 3. CATEGORY
      // ======================================================

      if (activeCategory != null && activeCategory.trim().isNotEmpty) {
        final selectedCategory = activeCategory.trim().toLowerCase();

        final hasCategory = event.tags.any(
          (tag) => tag.trim().toLowerCase() == selectedCategory,
        );

        if (!hasCategory) {
          return false;
        }
      }

      // ======================================================
      // 4. CITY
      // ======================================================

      if (activeCity != null && activeCity.trim().isNotEmpty) {
        final selectedCity = activeCity.trim().toLowerCase();

        final eventLocation = event.location.trim().toLowerCase();

        if (!eventLocation.contains(selectedCity)) {
          return false;
        }
      }

      // ======================================================
      // EVENT PASSES ALL FILTERS
      // ======================================================

      return true;
    }).toList();
  });
});
