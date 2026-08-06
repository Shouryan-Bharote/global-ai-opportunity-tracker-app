import 'dart:async';
import 'package:ai_nexus/core/theme/app_colors.dart';
import 'package:ai_nexus/core/theme/app_spacing.dart';

import 'package:ai_nexus/features/events/models/event_model.dart';
import 'package:ai_nexus/features/events/providers/events_provider.dart';
import 'package:ai_nexus/features/schedule/widgets/schedule_event_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

            // Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.4)),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      colors: [Colors.blue, Colors.lightBlueAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black87,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  // Tweak padding so tabs fill the space
                  labelPadding: EdgeInsets.zero,
                  tabs: const [
                    Tab(text: 'Today'),
                    Tab(text: 'Upcoming'),
                    Tab(text: 'Saved'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s24),

            // Swipeable Content
            Expanded(
              child: eventsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
                data: (allEvents) {
                  final todayEvents = allEvents.where((e) => allEvents.indexOf(e).isEven).toList();
                  final upcomingEvents = allEvents.where((e) => allEvents.indexOf(e).isOdd).toList();
                  final savedEvents = allEvents.where((e) => e.isBookmarked).toList();

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildEventList(todayEvents, 'Today'),
                      _buildEventList(upcomingEvents, 'Upcoming'),
                      _buildEventList(savedEvents, 'Saved', isSavedTab: true),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      );
  }

  Widget _buildEventList(List<EventModel> events, String tabName, {bool isSavedTab = false}) {
    if (events.isEmpty) {
      return _buildEmptyState(tabName);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24).copyWith(bottom: 120),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        
        if (isSavedTab) {
          return Dismissible(
            key: Key(event.id),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              unawaited(ref.read(eventsProvider.notifier).toggleBookmark(event.id));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${event.title} removed from saved'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            background: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.red.shade400,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 24),
              child: const Icon(Icons.delete_outline, color: Colors.white, size: 30),
            ),
            child: ScheduleEventCard(event: event),
          );
        }
        
        return ScheduleEventCard(event: event);
      },
    );
  }

  Widget _buildEmptyState(String tab) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            tab == 'Saved' ? Icons.bookmark_border : Icons.event_busy,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No $tab events',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            tab == 'Saved' 
                ? 'Save events to see them here!' 
                : 'Check out Explore to find more events.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
