import 'package:ai_nexus/core/providers/repository_providers.dart';
import 'package:ai_nexus/features/opportunities/models/opportunity_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Global notifier for Opportunities fetched from Firebase Firestore.
class OpportunitiesNotifier extends AsyncNotifier<List<OpportunityModel>> {
  @override
  Future<List<OpportunityModel>> build() async {
    final repository = ref.watch(opportunityRepositoryProvider);
    return repository.getOpportunities();
  }

  /// Toggles bookmark with optimistic state update.
  Future<void> toggleBookmark(String opportunityId) async {
    final repository = ref.read(opportunityRepositoryProvider);
    final previousState = state;

    // Optimistic UI update
    state = state.whenData((opportunities) {
      return opportunities.map((opp) {
        if (opp.id == opportunityId) {
          return opp.copyWith(isBookmarked: !opp.isBookmarked);
        }
        return opp;
      }).toList();
    });

    try {
      await repository.toggleBookmark(opportunityId);
    } on Exception {
      // Rollback on failure
      state = previousState;
    }
  }

  /// Refreshes opportunities from Firestore.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(opportunityRepositoryProvider);
      return repository.getOpportunities();
    });
  }
}

/// Global provider for Firestore opportunities.
final opportunitiesProvider =
    AsyncNotifierProvider<OpportunitiesNotifier, List<OpportunityModel>>(
  OpportunitiesNotifier.new,
);
