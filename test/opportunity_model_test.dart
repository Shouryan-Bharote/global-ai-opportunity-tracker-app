import 'package:ai_nexus/features/opportunities/models/opportunity_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OpportunityModel parsing & serialization', () {
    test('parses canonical Firestore document data with Timestamps', () {
      final now = DateTime(2026, 8, 23, 12);
      final deadline = DateTime(2026, 9, 15, 23, 59, 59);

      final map = <String, dynamic>{
        'title': 'AI Global Challenge',
        'url': 'https://example.com/challenge',
        'source': 'Devpost',
        'organizer': 'Google DeepMind',
        'opportunity_type': 'Hackathon',
        'description': 'Solve reasoning challenges with LLMs.',
        'prizes_total': 50000.0,
        'deadline': Timestamp.fromDate(deadline),
        'location_type': 'Online',
        'difficulty': 'Intermediate',
        'required_skills': ['Python', 'Dart', 'Machine Learning'],
        'is_active': true,
        'created_at': Timestamp.fromDate(now),
      };

      final model = OpportunityModel.fromMap(map, 'opp_doc_123');

      expect(model.id, 'opp_doc_123');
      expect(model.title, 'AI Global Challenge');
      expect(model.url, 'https://example.com/challenge');
      expect(model.source, 'Devpost');
      expect(model.organizer, 'Google DeepMind');
      expect(model.opportunityType, 'Hackathon');
      expect(model.description, 'Solve reasoning challenges with LLMs.');
      expect(model.prizesTotal, 50000.0);
      expect(model.deadline, deadline);
      expect(model.locationType, 'Online');
      expect(model.difficulty, 'Intermediate');
      expect(model.requiredSkills, ['Python', 'Dart', 'Machine Learning']);
      expect(model.isActive, isTrue);
      expect(model.createdAt, now);
      expect(model.isOnline, isTrue);
      expect(model.displayOrganizer, 'Google DeepMind');
    });

    test('parses ISO string dates defensively (backward compatibility)', () {
      final map = <String, dynamic>{
        'title': 'Legacy String Date Hackathon',
        'url': 'https://example.com/hack',
        'source': 'Unstop',
        'organizer': 'Tech Group',
        'opportunity_type': 'Competition',
        'deadline': '2026-09-14T00:00:00.000',
        'created_at': '2026-08-20T10:00:00.000',
        'location_type': 'In-Person',
        'is_active': true,
      };

      final model = OpportunityModel.fromMap(map, 'legacy_doc_1');

      expect(model.id, 'legacy_doc_1');
      expect(model.deadline, DateTime.parse('2026-09-14T00:00:00.000'));
      expect(model.createdAt, DateTime.parse('2026-08-20T10:00:00.000'));
      expect(model.isOnline, isFalse);
      expect(model.locationType, 'In-Person');
    });

    test('handles missing or nullable optional fields safely without throwing', () {
      final map = <String, dynamic>{
        'title': 'Minimal Opportunity',
        'url': 'https://example.com/minimal',
        'source': 'Kaggle',
        'organizer': '',
        'created_at': Timestamp.fromDate(DateTime(2026)),
      };

      final model = OpportunityModel.fromMap(map, 'min_1');

      expect(model.id, 'min_1');
      expect(model.title, 'Minimal Opportunity');
      expect(model.description, isNull);
      expect(model.prizesTotal, isNull);
      expect(model.deadline, isNull);
      expect(model.difficulty, isNull);
      expect(model.requiredSkills, isEmpty);
      expect(model.opportunityType, 'Other');
      expect(model.locationType, 'Online');
      expect(model.isActive, isTrue);
      expect(model.displayOrganizer, 'Kaggle');
      expect(model.isExpired, isFalse);
    });

    test('safely maps unknown enum values to default fallbacks', () {
      final map = <String, dynamic>{
        'title': 'New Category Event',
        'url': 'https://example.com/new',
        'source': 'Web',
        'organizer': 'Global Corp',
        'opportunity_type': 'BrandNewCategoryNotInEnum',
        'location_type': 'Metaverse',
        'difficulty': 'SuperExpertLevel',
        'created_at': Timestamp.now(),
      };

      final model = OpportunityModel.fromMap(map, 'unknown_enums_doc');

      expect(model.opportunityType, 'Other');
      expect(model.locationType, 'Online');
      expect(model.difficulty, isNull);
    });

    test('serializes to Firestore map using canonical snake_case names', () {
      final now = DateTime(2026, 8, 23, 10);
      final deadline = DateTime(2026, 9, 30, 23, 59, 59);

      final model = OpportunityModel(
        id: 'serialize_test_1',
        title: 'Serialization Hackathon',
        url: 'https://test.com',
        source: 'Devpost',
        organizer: 'AI Nexus',
        opportunityType: 'Hackathon',
        description: 'Test description',
        prizesTotal: 10000,
        deadline: deadline,
        locationType: 'Hybrid',
        difficulty: 'Advanced',
        requiredSkills: const ['Flutter', 'Firebase'],
        createdAt: now,
      );

      final firestoreMap = model.toFirestore();

      expect(firestoreMap['title'], 'Serialization Hackathon');
      expect(firestoreMap['opportunity_type'], 'Hackathon');
      expect(firestoreMap['prizes_total'], 10000.0);
      expect(firestoreMap['location_type'], 'Hybrid');
      expect(firestoreMap['required_skills'], ['Flutter', 'Firebase']);
      expect(firestoreMap['is_active'], isTrue);
      expect(firestoreMap['deadline'], isA<Timestamp>());
      expect(firestoreMap['created_at'], isA<Timestamp>());
    });

    test('copyWith updates specific fields correctly', () {
      final model = OpportunityModel(
        id: 'c1',
        title: 'Original Title',
        url: 'https://example.com',
        source: 'Source',
        organizer: 'Organizer',
        opportunityType: 'Hackathon',
        createdAt: DateTime(2026),
      );

      final updated = model.copyWith(
        title: 'Updated Title',
        isBookmarked: true,
      );

      expect(updated.id, 'c1');
      expect(updated.title, 'Updated Title');
      expect(updated.isBookmarked, isTrue);
      expect(updated.opportunityType, 'Hackathon');
    });
  });
}
