import 'package:ai_nexus/features/opportunities/models/opportunity_model.dart';
import 'package:ai_nexus/features/opportunities/providers/opportunities_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ============================================================
// EXPLORE FILTER STATE
// ============================================================

// Selected top filter: All, This Week, Free, Paid, Offline, Online
final exploreFilterProvider = StateProvider<String>((ref) => 'All');

// Selected category / opportunity type (e.g. 'Hackathons', 'Conferences', null)
final exploreCategoryProvider = StateProvider<String?>((ref) => null);

// Selected city / location filter
final exploreCityProvider = StateProvider<String?>((ref) => null);

// Search text entered by the user
final exploreSearchQueryProvider = StateProvider<String>((ref) => '');

// Controls "See all" / "Show less"
final exploreResultsExpandedProvider = StateProvider<bool>((ref) => false);

// ============================================================
// FILTERED OPPORTUNITIES
// ============================================================

final exploreFilteredOpportunitiesProvider =
    Provider<AsyncValue<List<OpportunityModel>>>((ref) {
  final activeFilter = ref.watch(exploreFilterProvider);
  final activeCategory = ref.watch(exploreCategoryProvider);
  final activeCity = ref.watch(exploreCityProvider);
  final searchQuery = ref.watch(exploreSearchQueryProvider).trim().toLowerCase();

  // Watch canonical Firestore opportunities provider
  final opportunitiesAsync = ref.watch(opportunitiesProvider);

  return opportunitiesAsync.whenData((allOpportunities) {
    return allOpportunities.where((opp) {
      // 1. SEARCH FILTER
      if (searchQuery.isNotEmpty) {
        final title = opp.title.toLowerCase();
        final description = opp.description?.toLowerCase() ?? '';
        final organizer = opp.organizer.toLowerCase();
        final source = opp.source.toLowerCase();
        final skills = opp.requiredSkills.map((s) => s.toLowerCase()).join(' ');

        final matchesSearch = title.contains(searchQuery) ||
            description.contains(searchQuery) ||
            organizer.contains(searchQuery) ||
            source.contains(searchQuery) ||
            skills.contains(searchQuery);

        if (!matchesSearch) return false;
      }

      // 2. TOP FILTER CHIPS
      if (activeFilter == 'Online') {
        if (!opp.isOnline) return false;
      } else if (activeFilter == 'Offline' || activeFilter == 'In-Person') {
        if (opp.isOnline) return false;
      } else if (activeFilter == 'This Week') {
        if (opp.deadline == null) return false;
        final now = DateTime.now();
        final startOfWeek = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(Duration(days: now.weekday - 1));
        final startOfNextWeek = startOfWeek.add(const Duration(days: 7));

        if (opp.deadline!.isBefore(startOfWeek) ||
            !opp.deadline!.isBefore(startOfNextWeek)) {
          return false;
        }
      }

      // 3. CATEGORY / OPPORTUNITY TYPE FILTER
      if (activeCategory != null && activeCategory.trim().isNotEmpty) {
        final targetCat = activeCategory.trim().toLowerCase();
        final oppType = opp.opportunityType.toLowerCase();

        final matchesType = oppType == targetCat ||
            oppType.contains(targetCat) ||
            targetCat.contains(oppType) ||
            opp.requiredSkills.any((s) => s.toLowerCase() == targetCat);

        if (!matchesType) return false;
      }

      // 4. CITY / LOCATION FILTER
      if (activeCity != null && activeCity.trim().isNotEmpty) {
        final targetCity = activeCity.trim().toLowerCase();
        final location = opp.locationType.toLowerCase();
        final desc = opp.description?.toLowerCase() ?? '';

        if (!location.contains(targetCity) && !desc.contains(targetCity)) {
          return false;
        }
      }

      return true;
    }).toList();
  });
});
