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

class _ScheduleScreenState extends ConsumerState<ScheduleScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 3,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // =====================================================
          // TABS
          // =====================================================
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s24,
            ),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : Colors.grey.withValues(alpha: 0.25),
                ),
              ),
              child: TabBar(
                controller: _tabController,

                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    colors: [
                      Colors.blue,
                      Colors.lightBlueAccent,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),

                labelColor: Colors.white,

                unselectedLabelColor: theme.colorScheme.onSurface.withValues(
                  alpha: 0.75,
                ),

                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),

                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),

                dividerColor: Colors.transparent,

                indicatorSize: TabBarIndicatorSize.tab,

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

          // =====================================================
          // TAB CONTENT
          // =====================================================
          Expanded(
            child: eventsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              ),

              error: (error, stack) => _buildErrorState(
                context,
                error,
              ),

              data: (allEvents) {
                final todayEvents = _getTodayEvents(allEvents);

                final upcomingEvents = _getUpcomingEvents(
                  allEvents,
                );

                final savedEvents = allEvents
                    .where(
                      (event) => event.isBookmarked,
                    )
                    .toList();

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildEventList(
                      todayEvents,
                      'Today',
                    ),
                    _buildEventList(
                      upcomingEvents,
                      'Upcoming',
                    ),
                    _buildEventList(
                      savedEvents,
                      'Saved',
                      isSavedTab: true,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TODAY EVENTS
  // ============================================================

  List<EventModel> _getTodayEvents(
    List<EventModel> events,
  ) {
    final now = DateTime.now();

    final startOfToday = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final startOfTomorrow = startOfToday.add(
      const Duration(days: 1),
    );

    final todayEvents = events.where((event) {
      return !event.startDate.isBefore(startOfToday) &&
          event.startDate.isBefore(startOfTomorrow);
    }).toList();

    todayEvents.sort(
      (a, b) => a.startDate.compareTo(b.startDate),
    );

    return todayEvents;
  }

  // ============================================================
  // UPCOMING EVENTS
  // ============================================================

  List<EventModel> _getUpcomingEvents(
    List<EventModel> events,
  ) {
    final now = DateTime.now();

    final upcomingEvents = events.where((event) {
      return event.startDate.isAfter(now);
    }).toList();

    upcomingEvents.sort(
      (a, b) => a.startDate.compareTo(b.startDate),
    );

    return upcomingEvents;
  }

  // ============================================================
  // EVENT LIST
  // ============================================================

  Widget _buildEventList(
    List<EventModel> events,
    String tabName, {
    bool isSavedTab = false,
  }) {
    if (events.isEmpty) {
      return _buildEmptyState(
        tabName,
      );
    }

    return ListView.builder(
      padding:
          const EdgeInsets.symmetric(
            horizontal: AppSpacing.s24,
          ).copyWith(
            bottom: 120,
          ),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];

        // ======================================================
        // SAVED EVENTS
        // ======================================================

        if (isSavedTab) {
          return Dismissible(
            key: Key(
              'saved_${event.id}',
            ),
            direction: DismissDirection.endToStart,

            onDismissed: (direction) {
              unawaited(
                ref.read(eventsProvider.notifier).toggleBookmark(event.id),
              );

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${event.title} removed from saved',
                  ),
                  duration: const Duration(
                    seconds: 2,
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },

            background: Container(
              margin: const EdgeInsets.only(
                bottom: 16,
              ),
              decoration: BoxDecoration(
                color: Colors.red.shade400,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(
                right: 24,
              ),
              child: const Icon(
                Icons.delete_outline,
                color: Colors.white,
                size: 30,
              ),
            ),

            child: Padding(
              padding: const EdgeInsets.only(
                bottom: 16,
              ),
              child: ScheduleEventCard(
                event: event,
              ),
            ),
          );
        }

        // ======================================================
        // NORMAL EVENTS
        // ======================================================

        return Padding(
          padding: const EdgeInsets.only(
            bottom: 16,
          ),
          child: ScheduleEventCard(
            event: event,
          ),
        );
      },
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState(
    String tab,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isSaved = tab == 'Saved';

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 32,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSaved
                  ? Icons.bookmark_border_rounded
                  : Icons.event_busy_rounded,
              size: 64,
              color: isDark ? Colors.white38 : Colors.grey.shade400,
            ),

            const SizedBox(height: 16),

            Text(
              'No $tab events',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              isSaved
                  ? 'Save events to see them here!'
                  : 'Check out Explore to find more events.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget _buildErrorState(
    BuildContext context,
    Object error,
  ) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: theme.colorScheme.error,
            ),

            const SizedBox(height: 16),

            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              '$error',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
