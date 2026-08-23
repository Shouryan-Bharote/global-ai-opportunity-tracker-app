import 'package:ai_nexus/features/opportunities/models/opportunity_model.dart';
import 'package:ai_nexus/features/opportunities/providers/opportunities_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// StateProvider for the selected category filter
final selectedCategoryProvider = StateProvider<String>((ref) => "Today's Events");

// Derived provider that reads from the global opportunitiesProvider
final homeOpportunitiesProvider = Provider<AsyncValue<List<OpportunityModel>>>((ref) {
  return ref.watch(opportunitiesProvider);
});

// Provider that filters opportunities based on the selected category
final filteredOpportunitiesProvider = Provider<List<OpportunityModel>>((ref) {
  final category = ref.watch(selectedCategoryProvider);
  final opportunitiesAsync = ref.watch(opportunitiesProvider);
  final allOpportunities = opportunitiesAsync.valueOrNull ?? [];

  return allOpportunities.where((opp) {
    if (category == "Today's Events" || category == 'Upcoming') {
      if (opp.deadline == null) return true;
      return !opp.deadline!.isBefore(DateTime.now());
    } else if (category == 'Hackathons') {
      return opp.opportunityType.toLowerCase() == 'hackathon';
    } else if (category == 'Competitions' || category == 'Meetings') {
      return opp.opportunityType.toLowerCase() == 'competition' ||
          opp.opportunityType.toLowerCase() == 'conference';
    } else if (category == 'Online') {
      return opp.isOnline;
    } else if (category == 'Near me' || category == 'In-Person') {
      return !opp.isOnline;
    }
    return true;
  }).toList();
});

// StateProvider for the Continue Exploring section
final selectedExploreCategoryProvider = StateProvider<String?>((ref) => null);

// Provider that filters opportunities based on Explore Category
final upcomingFilteredOpportunitiesProvider = Provider<List<OpportunityModel>>((ref) {
  final category = ref.watch(selectedExploreCategoryProvider);
  final opportunitiesAsync = ref.watch(opportunitiesProvider);
  final allOpportunities = opportunitiesAsync.valueOrNull ?? [];

  if (category == null) {
    return allOpportunities;
  }

  final lowerCat = category.toLowerCase();
  return allOpportunities.where((opp) {
    return opp.opportunityType.toLowerCase() == lowerCat ||
        opp.requiredSkills.any((s) => s.toLowerCase() == lowerCat);
  }).toList();
});
