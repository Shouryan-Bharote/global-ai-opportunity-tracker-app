import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider for the active tab (Today, Upcoming, Saved)
final scheduleTabProvider = StateProvider<String>((ref) => 'Today');
