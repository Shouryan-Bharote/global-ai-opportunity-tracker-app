import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Canonical opportunity types supported by the system.
enum OpportunityType {
  hackathon('Hackathon'),
  competition('Competition'),
  conference('Conference'),
  fellowship('Fellowship'),
  grant('Grant'),
  other('Other');

  const OpportunityType(this.value);
  final String value;

  static OpportunityType fromString(String? raw) {
    if (raw == null) return OpportunityType.other;
    final clean = raw.trim().toLowerCase();
    for (final type in OpportunityType.values) {
      if (type.value.toLowerCase() == clean || type.name.toLowerCase() == clean) {
        return type;
      }
    }
    return OpportunityType.other;
  }
}

/// Canonical difficulty levels.
enum DifficultyLevel {
  beginner('Beginner'),
  intermediate('Intermediate'),
  advanced('Advanced');

  const DifficultyLevel(this.value);
  final String value;

  static DifficultyLevel? fromString(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final clean = raw.trim().toLowerCase();
    for (final level in DifficultyLevel.values) {
      if (level.value.toLowerCase() == clean || level.name.toLowerCase() == clean) {
        return level;
      }
    }
    return null;
  }
}

/// Canonical location types.
enum LocationType {
  online('Online'),
  hybrid('Hybrid'),
  inPerson('In-Person');

  const LocationType(this.value);
  final String value;

  static LocationType fromString(String? raw) {
    if (raw == null) return LocationType.online;
    final clean = raw.trim().toLowerCase().replaceAll('-', '').replaceAll(' ', '');
    for (final loc in LocationType.values) {
      final locClean = loc.value.toLowerCase().replaceAll('-', '').replaceAll(' ', '');
      if (locClean == clean || loc.name.toLowerCase() == clean) {
        return loc;
      }
    }
    return LocationType.online;
  }
}

/// Canonical domain model representing an opportunity retrieved from Firestore.
@immutable
class OpportunityModel {
  const OpportunityModel({
    required this.id,
    required this.title,
    required this.url,
    required this.source,
    required this.organizer,
    required this.opportunityType,
    this.description,
    this.prizesTotal,
    this.deadline,
    this.locationType = 'Online',
    this.difficulty,
    this.requiredSkills = const [],
    this.isActive = true,
    required this.createdAt,
    this.isBookmarked = false,
    this.imageUrl,
  });

  final String id;
  final String title;
  final String url;
  final String source;
  final String organizer;
  final String opportunityType;
  final String? description;
  final double? prizesTotal;
  final DateTime? deadline;
  final String locationType;
  final String? difficulty;
  final List<String> requiredSkills;
  final bool isActive;
  final DateTime createdAt;
  final bool isBookmarked;
  final String? imageUrl;

  /// Helper: Check if opportunity is online.
  bool get isOnline => locationType.trim().toLowerCase() == 'online';

  /// Helper: Friendly organizer display.
  String get displayOrganizer {
    if (organizer.isNotEmpty) return organizer;
    if (source.isNotEmpty) return source;
    return 'Opportunity';
  }

  /// Helper: Check whether deadline has passed.
  bool get isExpired {
    if (deadline == null) return false;
    return deadline!.isBefore(DateTime.now());
  }

  /// Helper: Check whether deadline is within upcoming 7 days.
  bool get isUpcomingSoon {
    if (deadline == null) return false;
    final now = DateTime.now();
    final diff = deadline!.difference(now);
    return !diff.isNegative && diff.inDays <= 7;
  }

  /// Factory constructor for parsing Firestore DocumentSnapshot.
  factory OpportunityModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? <String, dynamic>{};
    return OpportunityModel.fromMap(data, snapshot.id);
  }

  /// Factory constructor to parse raw Map data safely.
  factory OpportunityModel.fromMap(
    Map<String, dynamic> data,
    String id,
  ) {
    // 1. Title
    final title = (data['title'] ?? '').toString();

    // 2. Url
    final url = (data['url'] ?? '').toString();

    // 3. Source
    final source = (data['source'] ?? '').toString();

    // 4. Organizer
    final organizer = (data['organizer'] ?? '').toString();

    // 5. Opportunity Type (from snake_case opportunity_type or camelCase)
    final rawType = (data['opportunity_type'] ?? data['opportunityType'] ?? 'Other').toString();
    final opportunityType = OpportunityType.fromString(rawType).value;

    // 6. Description
    final rawDesc = data['description'];
    final description = rawDesc != null && rawDesc.toString().trim().isNotEmpty
        ? rawDesc.toString().trim()
        : null;

    // 7. Prizes Total (handles int, double, num, string num, or null)
    final prizesTotal = _parsePrize(data['prizes_total'] ?? data['prizesTotal']);

    // 8. Deadline (handles Timestamp, ISO string, DateTime, int milliseconds)
    final deadline = _parseDate(data['deadline']);

    // 9. Location Type (Online, Hybrid, In-Person)
    final rawLocation = (data['location_type'] ?? data['locationType'] ?? 'Online').toString();
    final locationType = LocationType.fromString(rawLocation).value;

    // 10. Difficulty
    final rawDifficulty = data['difficulty']?.toString();
    final difficulty = DifficultyLevel.fromString(rawDifficulty)?.value;

    // 11. Required Skills
    final rawSkills = data['required_skills'] ?? data['requiredSkills'];
    final List<String> requiredSkills = [];
    if (rawSkills is List) {
      for (final skill in rawSkills) {
        if (skill != null && skill.toString().trim().isNotEmpty) {
          requiredSkills.add(skill.toString().trim());
        }
      }
    } else if (rawSkills is String && rawSkills.trim().isNotEmpty) {
      requiredSkills.addAll(
        rawSkills.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty),
      );
    }

    // 12. Is Active
    final rawIsActive = data['is_active'] ?? data['isActive'];
    final isActive = rawIsActive is bool ? rawIsActive : (rawIsActive != 'false' && rawIsActive != 0);

    // 13. Created At
    final createdAt = _parseDate(data['created_at'] ?? data['createdAt']) ?? DateTime.now();

    // 14. Optional local/UI fields
    final isBookmarked = data['isBookmarked'] as bool? ?? false;
    final imageUrl = data['imageUrl']?.toString() ?? data['image_url']?.toString();

    return OpportunityModel(
      id: id,
      title: title,
      url: url,
      source: source,
      organizer: organizer,
      opportunityType: opportunityType,
      description: description,
      prizesTotal: prizesTotal,
      deadline: deadline,
      locationType: locationType,
      difficulty: difficulty,
      requiredSkills: requiredSkills,
      isActive: isActive,
      createdAt: createdAt,
      isBookmarked: isBookmarked,
      imageUrl: imageUrl,
    );
  }

  /// Converts the model to a Firestore-compatible Map (using snake_case field names).
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'url': url,
      'source': source,
      'organizer': organizer,
      'opportunity_type': opportunityType,
      if (description != null) 'description': description,
      if (prizesTotal != null) 'prizes_total': prizesTotal,
      if (deadline != null) 'deadline': Timestamp.fromDate(deadline!),
      'location_type': locationType,
      if (difficulty != null) 'difficulty': difficulty,
      'required_skills': requiredSkills,
      'is_active': isActive,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  /// Converts the model to a Dart JSON Map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'source': source,
      'organizer': organizer,
      'opportunityType': opportunityType,
      'description': description,
      'prizesTotal': prizesTotal,
      'deadline': deadline?.toIso8601String(),
      'locationType': locationType,
      'difficulty': difficulty,
      'requiredSkills': requiredSkills,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'isBookmarked': isBookmarked,
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }

  /// Copy with modifications.
  OpportunityModel copyWith({
    String? id,
    String? title,
    String? url,
    String? source,
    String? organizer,
    String? opportunityType,
    String? description,
    double? prizesTotal,
    DateTime? deadline,
    String? locationType,
    String? difficulty,
    List<String>? requiredSkills,
    bool? isActive,
    DateTime? createdAt,
    bool? isBookmarked,
    String? imageUrl,
  }) {
    return OpportunityModel(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      source: source ?? this.source,
      organizer: organizer ?? this.organizer,
      opportunityType: opportunityType ?? this.opportunityType,
      description: description ?? this.description,
      prizesTotal: prizesTotal ?? this.prizesTotal,
      deadline: deadline ?? this.deadline,
      locationType: locationType ?? this.locationType,
      difficulty: difficulty ?? this.difficulty,
      requiredSkills: requiredSkills ?? this.requiredSkills,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  /// Defensive date parser handling Timestamp, ISO string, and epoch.
  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return null;
      return DateTime.tryParse(trimmed);
    }
    if (value is num) {
      try {
        return DateTime.fromMillisecondsSinceEpoch(value.toInt());
      } on Exception {
        return null;
      }
    }
    return null;
  }

  /// Defensive prize parser handling num and strings.
  static double? _parsePrize(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      final clean = value.replaceAll(RegExp('[^0-9.]'), '');
      return double.tryParse(clean);
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OpportunityModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          url == other.url &&
          source == other.source &&
          organizer == other.organizer &&
          opportunityType == other.opportunityType &&
          description == other.description &&
          prizesTotal == prizesTotal &&
          deadline == other.deadline &&
          locationType == other.locationType &&
          difficulty == other.difficulty &&
          isActive == other.isActive &&
          isBookmarked == other.isBookmarked;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      url.hashCode ^
      opportunityType.hashCode ^
      (deadline?.hashCode ?? 0) ^
      isBookmarked.hashCode;

  @override
  String toString() {
    return 'OpportunityModel(id: $id, title: $title, type: $opportunityType, deadline: $deadline, location: $locationType)';
  }
}
