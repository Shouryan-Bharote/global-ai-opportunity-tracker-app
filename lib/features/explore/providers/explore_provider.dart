import 'package:ai_nexus/features/events/models/event_model.dart';
import 'package:ai_nexus/features/events/providers/events_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// StateProvider for the active Filter Chip
final exploreFilterProvider = StateProvider<String>((ref) => 'All');

// StateProvider for the active Category (null means none selected)
final exploreCategoryProvider = StateProvider<String?>((ref) => null);

// StateProvider for the active Popular City (null means none selected)
final exploreCityProvider = StateProvider<String?>((ref) => null);

// StateProvider for the Search Query
final exploreSearchQueryProvider = StateProvider<String>((ref) => '');

// StateProvider for Result List expansion
final exploreResultsExpandedProvider = StateProvider<bool>((ref) => false);

// Provider that filters events based on all active selections
final exploreFilteredEventsProvider = Provider<AsyncValue<List<EventModel>>>((ref) {
  final activeFilter = ref.watch(exploreFilterProvider);
  final activeCategory = ref.watch(exploreCategoryProvider);
  final activeCity = ref.watch(exploreCityProvider);
  final searchQuery = ref.watch(exploreSearchQueryProvider).toLowerCase();
  
  final eventsAsyncValue = ref.watch(eventsProvider);

  return eventsAsyncValue.whenData((allEvents) {
    return allEvents.where((event) {
      // 1. Filter by Search Query
      if (searchQuery.isNotEmpty && !event.title.toLowerCase().contains(searchQuery)) {
        return false;
      }

      // 2. Filter by Top Chips
      if (activeFilter == 'Online' && !event.isOnline) return false;
      if (activeFilter == 'Offline' && event.isOnline) return false;
      
      // 3. Filter by Category
      if (activeCategory != null && activeCategory.isNotEmpty) {
        if (!event.tags.contains(activeCategory)) return false;
      }

      // 4. Filter by City
      if (activeCity != null && activeCity.isNotEmpty) {
        if (!event.location.toLowerCase().contains(activeCity.toLowerCase())) return false;
      }

      return true;
    }).toList();
  });
});
