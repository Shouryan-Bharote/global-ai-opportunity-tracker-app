import 'dart:async';
import 'dart:convert';
import 'package:ai_nexus/core/database/isar_service.dart';
import 'package:ai_nexus/core/storage/secure_storage.dart';
import 'package:ai_nexus/features/events/models/event_model.dart';
import 'package:ai_nexus/features/events/repositories/event_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class HttpEventRepository implements EventRepository {
  HttpEventRepository(
    this._dio, [
    SecureStorage? storage,
    IsarService? isarService,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  ])  : _storage = storage ?? SecureStorage(),
        _isarService = isarService ?? IsarService(),
        _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final Dio _dio;
  final SecureStorage _storage;
  final IsarService _isarService;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  // Local set for bookmarks
  final Set<String> _bookmarkedIds = {};
  bool _bookmarksLoaded = false;

  Future<void> _ensureBookmarksLoaded() async {
    if (!_bookmarksLoaded) {
      // 1. Load local bookmarks from secure storage
      final saved = await _storage.getBookmarks();
      _bookmarkedIds.addAll(saved);
      _bookmarksLoaded = true;

      // 2. Asynchronously sync cloud bookmarks from Firestore if authenticated
      unawaited(_syncCloudBookmarks());
    }
  }

  Future<void> _syncCloudBookmarks() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final docRef = _firestore.collection('users').doc(user.uid);
      final snapshot = await docRef.get();

      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        final cloudList = data['bookmarks'] as List<dynamic>?;
        if (cloudList != null) {
          final cloudSet = cloudList.map((e) => e.toString()).toSet();
          _bookmarkedIds.addAll(cloudSet);
          await _storage.saveBookmarks(_bookmarkedIds);
        }
      }

      // Merge local bookmarks into the cloud document
      if (_bookmarkedIds.isNotEmpty) {
        await docRef.set({
          'bookmarks': FieldValue.arrayUnion(_bookmarkedIds.toList()),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      debugPrint('[HttpEventRepository] Cloud bookmarks synced: ${_bookmarkedIds.length} bookmarks');
    } on Object catch (e) {
      debugPrint('[HttpEventRepository] Cloud bookmark sync note (offline or initial): $e');
    }
  }

  @override
  Future<List<EventModel>> getEvents({double? latitude, double? longitude}) async {
    await _ensureBookmarksLoaded();
    try {
      final allItems = <dynamic>[];
      var offset = 0;
      const pageSize = 100;
      var total = 0;

      do {
        final response = await _dio.get<Map<String, dynamic>>(
          'opportunities',
          queryParameters: {'limit': pageSize, 'offset': offset},
        );

        final data = response.data;
        if (data == null || !data.containsKey('items')) {
          break;
        }

        final items = data['items'] as List<dynamic>;
        total = data['total'] as int? ?? items.length;
        allItems.addAll(items);
        offset += items.length;

        if (items.length < pageSize || allItems.length >= total) {
          break;
        }
      } while (offset < 1000);

      debugPrint('[HttpEventRepository] Successfully fetched ${allItems.length} opportunities from backend (total: $total)');
      final events = allItems
          .map((e) => _mapOpportunityToEvent(e as Map<String, dynamic>))
          .toList();

      // Cache opportunities in Isar for offline resilience
      unawaited(_isarService.cacheEvents(events));

      return events;
    } on Object catch (e, stack) {
      debugPrint('[HttpEventRepository] Network error, checking Isar offline cache: $e\n$stack');
      final cached = await _isarService.getCachedEvents();
      if (cached.isNotEmpty) {
        debugPrint('[HttpEventRepository] Offline mode active: serving ${cached.length} cached opportunities');
        return cached.map((e) => e.copyWith(isBookmarked: _bookmarkedIds.contains(e.id))).toList();
      }
      // No cache yet — return empty list instead of rethrowing so the
      // UI shows "no events" rather than an infinite loading skeleton.
      debugPrint('[HttpEventRepository] No cache available, returning empty list.');
      return [];
    }
  }

  @override
  Future<EventModel?> getEventById(String id) async {
    await _ensureBookmarksLoaded();
    try {
      final response = await _dio.get<Map<String, dynamic>>('opportunities/$id');
      final data = response.data;
      if (data == null) return null;
      return _mapOpportunityToEvent(data);
    } on Exception {
      final cached = await _isarService.getCachedEventById(id);
      if (cached != null) {
        return cached.copyWith(isBookmarked: _bookmarkedIds.contains(cached.id));
      }
      return null;
    }
  }

  @override
  Future<void> toggleBookmark(String eventId) async {
    await _ensureBookmarksLoaded();
    final isAdding = !_bookmarkedIds.contains(eventId);
    if (isAdding) {
      _bookmarkedIds.add(eventId);
    } else {
      _bookmarkedIds.remove(eventId);
    }

    // 1. Optimistic local persistence
    await _storage.saveBookmarks(_bookmarkedIds);

    // 2. Cloud Firestore sync
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final docRef = _firestore.collection('users').doc(user.uid);
        if (isAdding) {
          await docRef.set({
            'bookmarks': FieldValue.arrayUnion([eventId]),
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        } else {
          await docRef.set({
            'bookmarks': FieldValue.arrayRemove([eventId]),
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
      }
    } on Object catch (e) {
      debugPrint('[HttpEventRepository] Cloud bookmark update error (offline): $e');
    }
  }

  @override
  Future<List<EventModel>> searchEvents(String query) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        'opportunities',
        queryParameters: {'q': query, 'limit': 50},
      );

      final data = response.data;
      if (data == null || !data.containsKey('items')) {
        return [];
      }

      final items = data['items'] as List<dynamic>;
      return items
          .map((e) => _mapOpportunityToEvent(e as Map<String, dynamic>))
          .toList();
    } on Exception catch (e) {
      debugPrint('[HttpEventRepository] Error searching events: $e, falling back to local cache');
      final cached = await _isarService.getCachedEvents();
      final lower = query.toLowerCase();
      return cached
          .where((e) =>
              e.title.toLowerCase().contains(lower) ||
              e.description.toLowerCase().contains(lower) ||
              e.tags.any((t) => t.toLowerCase().contains(lower)))
          .map((e) => e.copyWith(isBookmarked: _bookmarkedIds.contains(e.id)))
          .toList();
    }
  }

  @override
  Future<List<EventModel>> getEventsByFilter({
    String? category,
    String? city,
    bool? isOnline,
    List<String>? tags,
    double? latitude,
    double? longitude,
  }) async {
    final queryParams = <String, dynamic>{
      'limit': 50,
      if (category case final cat? when cat.isNotEmpty) 'type': cat,
      ...?isOnline == null ? null : {'is_remote_friendly': isOnline},
      if (tags case final tagList? when tagList.isNotEmpty) 'tag': tagList.first,
    };

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        'opportunities',
        queryParameters: queryParams,
      );

      final data = response.data;
      if (data == null || !data.containsKey('items')) {
        return [];
      }

      final items = data['items'] as List<dynamic>;
      return items
          .map((e) => _mapOpportunityToEvent(e as Map<String, dynamic>))
          .toList();
    } on Exception catch (e) {
      debugPrint('[HttpEventRepository] Error filtering events: $e, falling back to cache');
      final cached = await _isarService.getCachedEvents();
      return cached.where((e) {
        if (isOnline != null && e.isOnline != isOnline) return false;
        if (tags != null && tags.isNotEmpty) {
          final tagLower = tags.first.toLowerCase();
          if (!e.tags.any((t) => t.toLowerCase() == tagLower)) return false;
        }
        return true;
      }).map((e) => e.copyWith(isBookmarked: _bookmarkedIds.contains(e.id))).toList();
    }
  }

  /// Map FastAPI OpportunityDB schema to the Flutter EventModel
  EventModel _mapOpportunityToEvent(Map<String, dynamic> json) {
    final id = json['id'] as String? ?? '';
    final title = EventModel.cleanHtml(json['title'] as String? ?? 'Untitled Opportunity');
    var description = EventModel.cleanHtml(json['description'] as String? ?? '');
    final source = json['source'] as String? ?? 'Global Opportunity';
    final sourceUrl = json['source_url'] as String? ?? '';
    final imageUrl = json['image_url'] as String?;
    var isOnline = json['is_remote_friendly'] as bool? ?? false;
    final rawLocation = json['location_json'];
    if (rawLocation is Map) {
      if (rawLocation['type'] == 'online') {
        isOnline = true;
      }
    }
    // Most scraped platforms (devpost) are predominantly remote/online hackathons
    if (source.toLowerCase() == 'devpost') {
      isOnline = true;
    }

    // Tags
    final rawTags = json['tags'];
    final tags = <String>[];
    if (rawTags is List) {
      for (final t in rawTags) {
        if (t != null && t.toString().trim().isNotEmpty) {
          tags.add(t.toString().trim());
        }
      }
    }
    final rawType = json['type'];
    if (rawType != null && rawType.toString().isNotEmpty) {
      final typeStr = rawType.toString();
      final capitalized = typeStr[0].toUpperCase() + typeStr.substring(1).toLowerCase();
      if (!tags.any((t) => t.toLowerCase() == typeStr.toLowerCase())) {
        tags.add(capitalized);
      }
    }

    // Dates: parse real dates from timeline or relative time strings
    DateTime? parsedStart;
    DateTime? parsedEnd;

    dynamic timelineData = json['timeline_json'];
    if (timelineData is String && timelineData.trim().startsWith('{')) {
      try {
        timelineData = jsonDecode(timelineData);
      } on Object catch (_) {}
    }

    if (timelineData is Map) {
      final startStr = timelineData['event_start'] ?? timelineData['submission_deadline'];
      final endStr = timelineData['event_end'] ?? timelineData['submission_deadline'];
      if (startStr != null) {
        try {
          parsedStart = DateTime.parse(startStr.toString());
        } on FormatException {
          // Fall back to null
        }
      }
      if (endStr != null) {
        try {
          parsedEnd = DateTime.parse(endStr.toString());
        } on FormatException {
          // Fall back to null
        }
      }
    }

    // Fallback: check for relative time strings in raw description (e.g. "11 days left", "9 hours left")
    if (parsedStart == null) {
      final rawDesc = json['description'] as String? ?? '';
      final hoursMatch = RegExp(r'(\d+)\s+hours?\s+left', caseSensitive: false).firstMatch(rawDesc);
      final daysMatch = RegExp(r'(\d+)\s+days?\s+left', caseSensitive: false).firstMatch(rawDesc);
      final monthMatch = RegExp(r'about\s+(\d*)\s*months?\s+left', caseSensitive: false).firstMatch(rawDesc);

      final now = DateTime.now();
      if (hoursMatch != null) {
        final hours = int.tryParse(hoursMatch.group(1) ?? '1') ?? 1;
        parsedStart = now;
        parsedEnd = now.add(Duration(hours: hours));
      } else if (daysMatch != null) {
        final days = int.tryParse(daysMatch.group(1) ?? '1') ?? 1;
        parsedStart = now;
        parsedEnd = now.add(Duration(days: days));
      } else if (monthMatch != null) {
        final months = int.tryParse(monthMatch.group(1) ?? '1') ?? 1;
        parsedStart = now;
        parsedEnd = now.add(Duration(days: months * 30));
      }
    }

    final startDate = parsedStart ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    final endDate = parsedEnd ??
        (parsedStart != null
            ? parsedStart.add(const Duration(days: 14))
            : DateTime.fromMillisecondsSinceEpoch(0, isUtc: true));

    // Host
    var host = source.toUpperCase();
    final rawOrganizer = json['organizer_json'];
    if (rawOrganizer is Map && rawOrganizer['name'] != null) {
      host = EventModel.cleanHtml(rawOrganizer['name'].toString());
    }

    if (description.isEmpty || description.length < 10) {
      description = 'Explore $title organized by $host. Participate to innovate, learn, and expand your skills in AI and technology.';
    }

    // Location
    var location = isOnline ? 'Online' : 'Global / Onsite';
    if (rawLocation is Map) {
      final city = rawLocation['city'];
      final country = rawLocation['country'];
      if (city != null || country != null) {
        location = [?city, ?country].join(', ');
      }
    }

    return EventModel(
      id: id,
      title: title,
      description: description,
      host: host,
      startDate: startDate,
      endDate: endDate,
      location: location,
      isOnline: isOnline,
      url: sourceUrl,
      tags: tags.isNotEmpty ? tags : ['AI', source],
      imageUrl: imageUrl,
      isBookmarked: _bookmarkedIds.contains(id),
    );
  }
}
