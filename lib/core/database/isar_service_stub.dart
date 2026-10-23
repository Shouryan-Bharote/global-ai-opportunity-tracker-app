import 'package:ai_nexus/features/events/models/event_model.dart';

class IsarService {
  factory IsarService() {
    return _instance;
  }

  IsarService._internal();

  static final IsarService _instance = IsarService._internal();

  dynamic get db => null;

  Future<void> init() async {}

  Future<void> cacheEvents(List<EventModel> events) async {}

  Future<List<EventModel>> getCachedEvents() async => [];

  Future<EventModel?> getCachedEventById(String eventId) async => null;
}
