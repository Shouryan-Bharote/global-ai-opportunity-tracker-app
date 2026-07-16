import 'package:ai_nexus/features/events/repositories/event_repository.dart';
import 'package:ai_nexus/features/events/repositories/mock_event_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return MockEventRepository();
});
