import 'package:ai_nexus/features/opportunities/repositories/firestore_opportunity_repository.dart';
import 'package:ai_nexus/features/opportunities/repositories/opportunity_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final opportunityRepositoryProvider = Provider<OpportunityRepository>((ref) {
  return FirestoreOpportunityRepository();
});
