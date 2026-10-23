import 'dart:async';

import 'package:ai_nexus/core/constants/ai_interest_catalog.dart';
import 'package:ai_nexus/core/providers/location_provider.dart';
import 'package:ai_nexus/core/theme/app_colors.dart';
import 'package:ai_nexus/core/theme/app_spacing.dart';
import 'package:ai_nexus/core/widgets/skeleton_loader.dart';
import 'package:ai_nexus/features/events/models/event_model.dart';
import 'package:ai_nexus/features/events/providers/events_provider.dart';
import 'package:ai_nexus/features/home/providers/home_provider.dart';
import 'package:ai_nexus/features/home/widgets/category_chips.dart';
import 'package:ai_nexus/features/home/widgets/explore_category_card.dart';
import 'package:ai_nexus/features/home/widgets/featured_event_card.dart';
import 'package:ai_nexus/features/home/widgets/recommended_event_card.dart';
import 'package:ai_nexus/features/home/widgets/section_title.dart';
import 'package:ai_nexus/features/home/widgets/upcoming_event_tile.dart';
import 'package:ai_nexus/features/profile/providers/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  static const int _kInitialPage = 10002;
  late final PageController _featuredPageController;
  Timer? _featuredTimer;
  final ValueNotifier<int> _currentFeaturedPage = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _featuredPageController = PageController(initialPage: _kInitialPage);
    _startFeaturedTimer();
    _startAutoRefreshTimer();
  }

  Timer? _autoRefreshTimer;

  void _startAutoRefreshTimer() {
    // Silently refresh data every 5 minutes in the background.
    // We do NOT invalidate (which causes a loading state); instead we
    // let the next user-triggered pull-to-refresh pick up fresh data.
    // The timer just keeps location fresh.
    _autoRefreshTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      if (!mounted) return;
      // Only re-fetch location silently; events will refresh on next
      // pull-to-refresh or app resume (when no data is present).
      ref.invalidate(locationProvider);
    });
  }

  void _startFeaturedTimer() {
    _featuredTimer?.cancel();
    _featuredTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_featuredPageController.hasClients) return;
      final scheduleEvents = ref.read(eventsProvider).valueOrNull ?? [];
      final count = scheduleEvents.take(3).length;
      if (count <= 1) return;

      final currentPosition =
          _featuredPageController.page?.round() ?? _kInitialPage;
      _featuredPageController.animateToPage(
        currentPosition + 1,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _featuredTimer?.cancel();
    _autoRefreshTimer?.cancel();
    _featuredPageController.dispose();
    _currentFeaturedPage.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Always refresh location on resume.
      ref.invalidate(locationProvider);

      // Only force a full reload if we have NO data yet (first launch).
      // If data is already showing, keep it visible while a silent
      // background fetch happens on the next pull-to-refresh.
      final eventsState = ref.read(eventsProvider);
      final hasData = eventsState.valueOrNull?.isNotEmpty ?? false;
      if (!hasData) {
        ref.invalidate(eventsProvider);
      }
    }
  }

  bool _showAllUpcoming = false;

  List<CategoryChipData> _getCategories(int inPersonCount) => [
    const CategoryChipData(
      label: "Today's Events",
      icon: Icons.local_fire_department,
    ),
    const CategoryChipData(label: 'Hackathons', icon: Icons.code_rounded),
    const CategoryChipData(label: 'Competitions', icon: Icons.emoji_events_outlined),
    const CategoryChipData(label: 'Online', icon: Icons.public),
    if (inPersonCount > 0)
      const CategoryChipData(label: 'Near me', icon: Icons.location_on_outlined),
  ];

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  Future<void> _onRefresh() async {
    ref
      ..invalidate(locationProvider)
      ..invalidate(eventsProvider);
    await Future.wait([
      ref.read(locationProvider.future),
      ref.read(eventsProvider.future),
    ]);
  }

  Future<void> _enableLocation() async {
    ref.invalidate(locationProvider);
    final position = await ref.read(locationProvider.future);
    if (position == null) {
      await ref.read(locationServiceProvider).openSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;

    final selectedCategory = ref.watch(selectedCategoryProvider);
    final selectedExploreCategory = ref.watch(selectedExploreCategoryProvider);
    final filteredEvents = ref.watch(filteredEventsProvider);
    final eventsAsync = ref.watch(eventsProvider);
    final isEventsLoading = eventsAsync.isLoading;
    final scheduleEvents = eventsAsync.valueOrNull ?? [];
    final hasBackendError = eventsAsync.hasError && scheduleEvents.isEmpty;
    final locationAsync = ref.watch(locationProvider);
    final hasLocation = locationAsync.valueOrNull != null;
    final userName = ref.watch(profileProvider).valueOrNull?.name ?? 'there';
    final userInterests = ref.watch(userInterestsProvider);
    final todayDate = DateFormat('EEEE, MMM d').format(DateTime.now());

    final upcomingEvents = ref.watch(upcomingFilteredEventsProvider);
    final hasMoreUpcoming = upcomingEvents.length > 2;
    final displayedUpcomingEvents = _showAllUpcoming
        ? upcomingEvents
        : upcomingEvents.take(2).toList();

    final top3FeaturedEvents = scheduleEvents.take(3).toList();
    final totalOpportunities = scheduleEvents.length;
    final inPersonCount = scheduleEvents.where((e) => !e.isOnline).length;
    final categories = _getCategories(inPersonCount);

    final badgeBg = isDarkMode
        ? const Color(0xFF292929)
        : const Color(0xFFF0EEF5);
    final badgeTextColor = isDarkMode
        ? Colors.grey.shade400
        : const Color(0xFF7A869A);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ============================================================
              // WELCOME SECTION
              // ============================================================
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s24,
                  12,
                  AppSpacing.s24,
                  4,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // DATE BADGE
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: badgeBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 14,
                                color: badgeTextColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                todayDate,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: badgeTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 8),

                        // LOCATION BADGE
                        GestureDetector(
                          onTap: locationAsync.valueOrNull == null
                              ? _enableLocation
                              : null,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: badgeBg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  inPersonCount > 0
                                      ? Icons.location_on_rounded
                                      : Icons.public_rounded,
                                  size: 14,
                                  color: const Color(0xFF6C5CE7),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  locationAsync.isLoading
                                      ? 'Locating...'
                                      : (inPersonCount > 0
                                            ? '$inPersonCount In-Person Near You'
                                            : (hasLocation
                                                ? 'Global & Remote'
                                                : 'Global Opportunities')),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: badgeTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // GREETING
                    Text(
                      '${_getGreeting()}, $userName 👋',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                        letterSpacing: -0.5,
                        height: 1.2,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // DYNAMIC EVENT COUNT HEADER
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                          color: colorScheme.onSurface,
                        ),
                        children: [
                          if (inPersonCount > 0) ...[
                            TextSpan(
                              text: 'There are ',
                              style: TextStyle(
                                color: isDarkMode
                                    ? Colors.grey.shade500
                                    : const Color(0xFFB0B0B8),
                              ),
                            ),
                            TextSpan(
                              text: '$inPersonCount in-person events ',
                              style: TextStyle(
                                color: isDarkMode
                                    ? Colors.grey.shade300
                                    : const Color(0xFF4A4A58),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextSpan(
                              text: 'available near you.',
                              style: TextStyle(
                                color: isDarkMode
                                    ? Colors.grey.shade500
                                    : const Color(0xFFB0B0B8),
                              ),
                            ),
                          ] else ...[
                            TextSpan(
                              text: 'Explore ',
                              style: TextStyle(
                                color: isDarkMode
                                    ? Colors.grey.shade500
                                    : const Color(0xFFB0B0B8),
                              ),
                            ),
                            TextSpan(
                              text: totalOpportunities > 0
                                  ? '$totalOpportunities opportunities '
                                  : 'active opportunities ',
                              style: TextStyle(
                                color: isDarkMode
                                    ? Colors.grey.shade300
                                    : const Color(0xFF4A4A58),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextSpan(
                              text: 'available worldwide.',
                              style: TextStyle(
                                color: isDarkMode
                                    ? Colors.grey.shade500
                                    : const Color(0xFFB0B0B8),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              if (hasBackendError)
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s24,
                    vertical: 8,
                  ),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? const Color(0xFF331B24)
                        : const Color(0xFFFFF0F2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.redAccent.withValues(alpha: 0.4),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.cloud_off_rounded,
                        color: Colors.redAccent,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Server Connection Issue',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.redAccent,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Unable to reach backend opportunities service.',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDarkMode
                                    ? Colors.white70
                                    : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => ref.invalidate(eventsProvider),
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Retry'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: AppSpacing.s16),

              // ============================================================
              // CATEGORY CHIPS
              // ============================================================
              CategoryChips(
                categories: categories,
                selectedCategory: selectedCategory,
                onCategorySelected: (category) {
                  ref.read(selectedCategoryProvider.notifier).state = category;
                },
              ),

              const SizedBox(height: AppSpacing.s24),

              // ============================================================
              // FEATURED EVENTS CAROUSEL (TOP 3)
              // ============================================================
              if (top3FeaturedEvents.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s24,
                  ),
                  child: hasBackendError
                      ? Container(
                          height: 180,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? const Color(0xFF16152B)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isDarkMode
                                  ? Colors.white12
                                  : Colors.grey.shade200,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_off_rounded,
                                size: 36,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Featured events currently unavailable',
                                style: TextStyle(
                                  color: colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : const EventSkeletonCard(height: 250),
                )
              else
                Column(
                  children: [
                    SizedBox(
                      height: 275,
                      child: PageView.builder(
                        controller: _featuredPageController,
                        itemCount: 100000,
                        onPageChanged: (index) {
                          final realIndex = index % top3FeaturedEvents.length;
                          if (_currentFeaturedPage.value != realIndex) {
                            _currentFeaturedPage.value = realIndex;
                          }
                        },
                        itemBuilder: (context, index) {
                          final realIndex = index % top3FeaturedEvents.length;
                          final event = top3FeaturedEvents[realIndex];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.s24,
                            ),
                            child: FeaturedEventCard(
                              title: event.title,
                              subtitle: EventModel.cleanHtml(event.description),
                              date: event.isDateTba
                                  ? 'Date TBA'
                                  : DateFormat('MMM d').format(event.startDate),
                              location: event.location,
                              imageUrl:
                                  event.imageUrl ??
                                  'https://h2svision.github.io/publicAssets2/bah2026/why_participate.webp',
                              heroTag: 'featured_event_${event.id}_image',
                              onRegister: () {
                                unawaited(
                                  context.push(
                                    '/events/${Uri.encodeComponent(event.id)}',
                                    extra:
                                        event.imageUrl ??
                                        'https://h2svision.github.io/publicAssets2/bah2026/why_participate.webp',
                                  ),
                                );
                              },
                              isBookmarked: event.isBookmarked,
                              onBookmark: () {
                                unawaited(
                                  ref
                                      .read(eventsProvider.notifier)
                                      .toggleBookmark(event.id),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    // PAGE INDICATOR DOTS
                    ValueListenableBuilder<int>(
                      valueListenable: _currentFeaturedPage,
                      builder: (context, currentPage, _) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(top3FeaturedEvents.length, (
                            index,
                          ) {
                            final isActive = index == currentPage;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutCubic,
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: isActive ? 20 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? AppColors.primary
                                    : (isDarkMode
                                          ? Colors.white.withValues(alpha: 0.2)
                                          : AppColors.primary.withValues(
                                              alpha: 0.2,
                                            )),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            );
                          }),
                        );
                      },
                    ),
                  ],
                ),

              const SizedBox(height: AppSpacing.s16),

              // ============================================================
              // RECOMMENDED FOR YOU
              // ============================================================
              const SectionTitle(
                title: 'Recommended for you',
                // onActionTap: () => context.go('/explore'), // hidden until a dedicated "All Recommended" screen exists
              ),

              SizedBox(
                height: 220,
                child: isEventsLoading
                    ? ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.s24,
                        ),
                        itemCount: 3,
                        itemBuilder: (context, index) => const Padding(
                          padding: EdgeInsets.only(right: 16),
                          child: EventSkeletonCard(width: 300),
                        ),
                      )
                    : filteredEvents.isEmpty
                    ? Center(
                        child: Text(
                          'No events found for this category',
                          style: TextStyle(
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.s24,
                        ),
                        itemCount: filteredEvents.length,
                        itemBuilder: (context, index) {
                          final event = filteredEvents[index];
                          final isInterestMatch = AiInterestCatalog.eventMatchesInterests(
                            event.tags,
                            userInterests,
                          );
                          return RecommendedEventCard(
                            title: event.title,
                            tag: event.tags.isNotEmpty
                                ? event.tags.first
                                : 'Event',
                            date: event.isDateTba
                                ? 'Date TBA'
                                : DateFormat('MMM d').format(event.startDate),
                            location: event.location,
                            isInterestMatch: isInterestMatch,
                            imageUrl:
                                event.imageUrl ??
                                'https://picsum.photos/400/200?random=$index',
                            gradientColors: const [
                              Color(0xFF8A4DFF),
                              Color(0xFF3E63F5),
                            ],
                            onTap: () {
                              unawaited(context.push('/events/${Uri.encodeComponent(event.id)}'));
                            },
                          );
                        },
                      ),
              ),

              const SizedBox(height: AppSpacing.s16),

              // ============================================================
              // CONTINUE EXPLORING
              // ============================================================
              SectionTitle(
                title: 'Continue Exploring',
                actionText: selectedExploreCategory != null ? 'Clear filter' : 'See all',
                onActionTap: selectedExploreCategory != null
                    ? () {
                        ref.read(selectedExploreCategoryProvider.notifier).state = null;
                      }
                    : () => context.go('/explore'),
              ),

              SizedBox(
                height: 170,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s24,
                  ),
                  children: [
                    _buildExploreCard(
                      'AI',
                      _countEventsForTopic(scheduleEvents, 'AI'),
                      Icons.lightbulb_outline,
                      Colors.white,
                      isDarkMode,
                      selectedExploreCategory,
                    ),
                    _buildExploreCard(
                      'Data Science',
                      _countEventsForTopic(scheduleEvents, 'Data Science'),
                      Icons.analytics_outlined,
                      AppColors.background,
                      isDarkMode,
                      selectedExploreCategory,
                    ),
                    _buildExploreCard(
                      'Cybersecurity',
                      _countEventsForTopic(scheduleEvents, 'Cybersecurity'),
                      Icons.security_outlined,
                      Colors.white,
                      isDarkMode,
                      selectedExploreCategory,
                    ),
                    _buildExploreCard(
                      'Robotics',
                      _countEventsForTopic(scheduleEvents, 'Robotics'),
                      Icons.smart_toy_outlined,
                      isDarkMode
                          ? const Color(0xFF392A33)
                          : const Color(0xFFFFE5F0),
                      isDarkMode,
                      selectedExploreCategory,
                    ),
                    _buildExploreCard(
                      'Cloud',
                      _countEventsForTopic(scheduleEvents, 'Cloud'),
                      Icons.cloud_outlined,
                      Colors.white,
                      isDarkMode,
                      selectedExploreCategory,
                    ),
                    _buildExploreCard(
                      'Web3',
                      _countEventsForTopic(scheduleEvents, 'Web3'),
                      Icons.currency_bitcoin_outlined,
                      isDarkMode
                          ? const Color(0xFF293342)
                          : const Color(0xFFE5F0FF),
                      isDarkMode,
                      selectedExploreCategory,
                    ),
                    _buildExploreCard(
                      'Design',
                      _countEventsForTopic(scheduleEvents, 'Design'),
                      Icons.design_services_outlined,
                      Colors.white,
                      isDarkMode,
                      selectedExploreCategory,
                    ),
                    _buildExploreCard(
                      'Marketing',
                      _countEventsForTopic(scheduleEvents, 'Marketing'),
                      Icons.campaign_outlined,
                      isDarkMode
                          ? const Color(0xFF293329)
                          : const Color(0xFFE5FFE5),
                      isDarkMode,
                      selectedExploreCategory,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.s16),

              // ============================================================
              // UPCOMING THIS WEEK
              // ============================================================
              SectionTitle(
                title: 'Upcoming this week',
                actionText: _showAllUpcoming ? 'Show less' : 'Show  all',
                onActionTap: hasMoreUpcoming
                    ? () {
                        setState(() {
                          _showAllUpcoming = !_showAllUpcoming;
                        });
                      }
                    : null,
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s24,
                ),
                child: isEventsLoading
                    ? Column(
                        children: List.generate(
                          3,
                          (index) => const Padding(
                            padding: EdgeInsets.only(bottom: 12),
                            child: EventSkeletonCard(height: 100),
                          ),
                        ),
                      )
                    : displayedUpcomingEvents.isEmpty
                    ? Center(
                        child: Text(
                          'No upcoming events',
                          style: TextStyle(
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      )
                    : Column(
                        children: displayedUpcomingEvents.map((event) {
                          final d = event.isDateTba ? '--' : DateFormat('d').format(event.startDate);
                          final m = event.isDateTba ? 'TBA' : DateFormat('MMM').format(event.startDate);
                          return UpcomingEventTile(
                            day: d,
                            month: m,
                            title: event.title,
                            subtitle: event.isOnline
                                ? 'Online'
                                : event.location,
                            onTap: () {
                              unawaited(context.push('/events/${Uri.encodeComponent(event.id)}'));
                            },
                          );
                        }).toList(),
                      ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  String _countEventsForTopic(List<EventModel> events, String topic) {
    final t = topic.toLowerCase();
    final count = events.where((e) {
      return e.tags.any((tag) => tag.toLowerCase().contains(t)) ||
          e.title.toLowerCase().contains(t) ||
          e.description.toLowerCase().contains(t);
    }).length;
    return '$count ${count == 1 ? 'event' : 'events'}';
  }

  Widget _buildExploreCard(
    String title,
    String subtitle,
    IconData icon,
    Color lightBg,
    bool isDarkMode,
    String? selectedExploreCategory,
  ) {
    return ExploreCategoryCard(
      title: title,
      subtitle: subtitle,
      icon: icon,
      backgroundColor: isDarkMode ? const Color(0xFF292929) : lightBg,
      isSelected: selectedExploreCategory == title,
      onTap: () {
        ref.read(selectedExploreCategoryProvider.notifier).state =
            selectedExploreCategory == title ? null : title;
      },
    );
  }
}
