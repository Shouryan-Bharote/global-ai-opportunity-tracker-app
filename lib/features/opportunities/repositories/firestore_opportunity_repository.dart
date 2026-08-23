import 'package:ai_nexus/features/opportunities/models/opportunity_model.dart';
import 'package:ai_nexus/features/opportunities/repositories/opportunity_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Firestore implementation of [OpportunityRepository].
///
/// Connects directly to the `opportunities` collection in Firebase Firestore.
class FirestoreOpportunityRepository implements OpportunityRepository {
  FirestoreOpportunityRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  static const String _collectionName = 'opportunities';

  // In-memory set of bookmarked opportunity IDs for client session persistence
  final Set<String> _bookmarkedIds = {};

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(_collectionName);

  @override
  Future<List<OpportunityModel>> getOpportunities({bool activeOnly = true}) async {
    try {
      Query<Map<String, dynamic>> query = _collection;

      if (activeOnly) {
        query = query.where('is_active', isEqualTo: true);
      }

      final snapshot = await query.get();

      return snapshot.docs.map((doc) {
        final model = OpportunityModel.fromFirestore(doc);
        if (_bookmarkedIds.contains(model.id)) {
          return model.copyWith(isBookmarked: true);
        }
        return model;
      }).toList();
    } on Exception catch (e, st) {
      debugPrint('FirestoreOpportunityRepository.getOpportunities error: $e\n$st');
      rethrow;
    }
  }

  @override
  Future<OpportunityModel?> getOpportunityById(String id) async {
    try {
      final doc = await _collection.doc(id).get();
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      final model = OpportunityModel.fromFirestore(doc);
      if (_bookmarkedIds.contains(model.id)) {
        return model.copyWith(isBookmarked: true);
      }
      return model;
    } on Exception catch (e, st) {
      debugPrint('FirestoreOpportunityRepository.getOpportunityById error: $e\n$st');
      rethrow;
    }
  }

  @override
  Future<void> toggleBookmark(String opportunityId) async {
    if (_bookmarkedIds.contains(opportunityId)) {
      _bookmarkedIds.remove(opportunityId);
    } else {
      _bookmarkedIds.add(opportunityId);
    }
  }

  @override
  Future<List<OpportunityModel>> searchOpportunities(String query) async {
    final all = await getOpportunities();
    if (query.trim().isEmpty) return all;

    final lower = query.trim().toLowerCase();
    return all.where((opp) {
      final matchTitle = opp.title.toLowerCase().contains(lower);
      final matchDesc = opp.description?.toLowerCase().contains(lower) ?? false;
      final matchOrganizer = opp.organizer.toLowerCase().contains(lower);
      final matchSource = opp.source.toLowerCase().contains(lower);
      final matchSkills = opp.requiredSkills.any((s) => s.toLowerCase().contains(lower));
      return matchTitle || matchDesc || matchOrganizer || matchSource || matchSkills;
    }).toList();
  }

  @override
  Future<List<OpportunityModel>> getOpportunitiesByFilter({
    String? opportunityType,
    String? locationType,
    String? difficulty,
    String? city,
    List<String>? requiredSkills,
    bool activeOnly = true,
  }) async {
    final all = await getOpportunities(activeOnly: activeOnly);

    return all.where((opp) {
      // Filter by opportunity type
      if (opportunityType != null && opportunityType.isNotEmpty && opportunityType != 'All') {
        if (opp.opportunityType.toLowerCase() != opportunityType.toLowerCase()) {
          return false;
        }
      }

      // Filter by location type (Online, Hybrid, In-Person)
      if (locationType != null && locationType.isNotEmpty) {
        if (opp.locationType.toLowerCase() != locationType.toLowerCase()) {
          return false;
        }
      }

      // Filter by difficulty
      if (difficulty != null && difficulty.isNotEmpty) {
        if (opp.difficulty?.toLowerCase() != difficulty.toLowerCase()) {
          return false;
        }
      }

      // Filter by required skills
      if (requiredSkills != null && requiredSkills.isNotEmpty) {
        final oppSkillsLower = opp.requiredSkills.map((s) => s.toLowerCase()).toSet();
        for (final skill in requiredSkills) {
          if (!oppSkillsLower.contains(skill.toLowerCase())) {
            return false;
          }
        }
      }

      return true;
    }).toList();
  }

  @override
  Stream<List<OpportunityModel>> watchOpportunities({bool activeOnly = true}) {
    Query<Map<String, dynamic>> query = _collection;
    if (activeOnly) {
      query = query.where('is_active', isEqualTo: true);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final model = OpportunityModel.fromFirestore(doc);
        if (_bookmarkedIds.contains(model.id)) {
          return model.copyWith(isBookmarked: true);
        }
        return model;
      }).toList();
    });
  }
}
