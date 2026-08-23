import 'dart:async';

import 'package:ai_nexus/core/theme/app_colors.dart';
import 'package:ai_nexus/core/theme/app_spacing.dart';
import 'package:ai_nexus/features/opportunities/models/opportunity_model.dart';
import 'package:ai_nexus/features/opportunities/providers/opportunities_provider.dart';
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
    final opportunitiesAsync = ref.watch(opportunitiesProvider);
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
                tabs: const [
                  Tab(text: 'Closing Soon'),
                  Tab(text: 'Upcoming'),
                  Tab(text: 'Saved'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // =====================================================
          // TAB CONTENT
          // =====================================================
          Expanded(
            child: opportunitiesAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              ),
              error: (error, stack) => _buildErrorState(
                context,
                error,
              ),
              data: (allOpportunities) {
                final closingSoon = _getClosingSoonOpportunities(allOpportunities);
                final upcoming = _getUpcomingOpportunities(allOpportunities);
                final saved = allOpportunities
                    .where((opp) => opp.isBookmarked)
                    .toList();

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOpportunityList(
                      closingSoon,
                      'Closing Soon',
                    ),
                    _buildOpportunityList(
                      upcoming,
                      'Upcoming',
                    ),
                    _buildOpportunityList(
                      saved,
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
  // CLOSING SOON (Within 7 days)
  // ============================================================

  List<OpportunityModel> _getClosingSoonOpportunities(
    List<OpportunityModel> opportunities,
  ) {
    final now = DateTime.now();
    final in7Days = now.add(const Duration(days: 7));

    final list = opportunities.where((opp) {
      if (opp.deadline == null) return false;
      return !opp.deadline!.isBefore(now) && opp.deadline!.isBefore(in7Days);
    }).toList();

    list.sort((a, b) => a.deadline!.compareTo(b.deadline!));
    return list;
  }

  // ============================================================
  // UPCOMING (All with future deadline or open)
  // ============================================================

  List<OpportunityModel> _getUpcomingOpportunities(
    List<OpportunityModel> opportunities,
  ) {
    final now = DateTime.now();

    final list = opportunities.where((opp) {
      if (opp.deadline == null) return true;
      return !opp.deadline!.isBefore(now);
    }).toList();

    list.sort((a, b) {
      if (a.deadline == null && b.deadline == null) return 0;
      if (a.deadline == null) return 1;
      if (b.deadline == null) return -1;
      return a.deadline!.compareTo(b.deadline!);
    });

    return list;
  }

  // ============================================================
  // OPPORTUNITY LIST
  // ============================================================

  Widget _buildOpportunityList(
    List<OpportunityModel> opportunities,
    String tabName, {
    bool isSavedTab = false,
  }) {
    if (opportunities.isEmpty) {
      return _buildEmptyState(
        tabName,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s24,
      ).copyWith(
        bottom: 120,
      ),
      itemCount: opportunities.length,
      itemBuilder: (context, index) {
        final opp = opportunities[index];

        if (isSavedTab) {
          return Dismissible(
            key: Key('saved_${opp.id}'),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 24),
              decoration: BoxDecoration(
                color: Colors.red.shade400,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            onDismissed: (_) {
              ref
                  .read(opportunitiesProvider.notifier)
                  .toggleBookmark(opp.id);
            },
            child: ScheduleEventCard(
              opportunity: opp,
            ),
          );
        }

        return ScheduleEventCard(
          opportunity: opp,
        );
      },
    );
  }

  Widget _buildEmptyState(String tabName) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            tabName == 'Saved'
                ? Icons.bookmark_border_rounded
                : Icons.event_busy_rounded,
            size: 64,
            color: isDark
                ? Colors.white.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No $tabName Opportunities',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            tabName == 'Saved'
                ? 'Opportunities you bookmark will appear here.'
                : 'Check back later for new opportunities.',
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading schedule:\n$error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(opportunitiesProvider.notifier).refresh();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
