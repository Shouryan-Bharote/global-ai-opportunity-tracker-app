import 'package:ai_nexus/features/opportunities/models/opportunity_model.dart';

/// Abstract contract for Opportunity data source operations.
abstract class OpportunityRepository {
  /// Fetches opportunities from the data store.
  /// When [activeOnly] is true, only opportunities with `is_active == true` are returned.
  Future<List<OpportunityModel>> getOpportunities({bool activeOnly = true});

  /// Fetches a single opportunity by its Firestore document ID.
  Future<OpportunityModel?> getOpportunityById(String id);

  /// Toggles the local/user bookmark status for an opportunity.
  Future<void> toggleBookmark(String opportunityId);

  /// Searches opportunities by query matching title, description, organizer, or skills.
  Future<List<OpportunityModel>> searchOpportunities(String query);

  /// Filters opportunities by optional criteria.
  Future<List<OpportunityModel>> getOpportunitiesByFilter({
    String? opportunityType,
    String? locationType,
    String? difficulty,
    String? city,
    List<String>? requiredSkills,
    bool activeOnly = true,
  });

  /// Provides a real-time stream of opportunities.
  Stream<List<OpportunityModel>> watchOpportunities({bool activeOnly = true});
}
