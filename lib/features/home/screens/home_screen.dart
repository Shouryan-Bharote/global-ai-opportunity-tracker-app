import 'dart:async';

import 'package:ai_nexus/core/providers/location_provider.dart';
import 'package:ai_nexus/core/theme/app_colors.dart';
import 'package:ai_nexus/core/theme/app_spacing.dart';
import 'package:ai_nexus/core/widgets/skeleton_loader.dart';
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
  int _currentFeaturedPage = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _featuredPageController = PageController(initialPage: _kInitialPage);
    _startFeaturedTimer();
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
    _featuredPageController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(locationProvider);
    }
  }

  bool _showAllUpcoming = false;

  final categories = const [
    CategoryChipData(
      label: "Today's Events",
      icon: Icons.local_fire_department,
    ),
    CategoryChipData(label: 'Meetings', icon: Icons.stars_rounded),
    CategoryChipData(label: 'Hackathons', icon: Icons.hourglass_bottom),
    CategoryChipData(label: 'Online', icon: Icons.public),
    CategoryChipData(label: 'Near me', icon: Icons.location_on_outlined),
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
    final isEventsLoading = ref.watch(homeEventsProvider).isLoading;
    final scheduleEvents = ref.watch(eventsProvider).valueOrNull ?? [];
    final locationAsync = ref.watch(locationProvider);
    final hasLocation = locationAsync.valueOrNull != null;
    final userName = ref.watch(profileProvider).valueOrNull?.name ?? 'there';
    final todayDate = DateFormat('EEEE, MMM d').format(DateTime.now());

    final upcomingEvents = ref.watch(upcomingFilteredEventsProvider);
    final hasMoreUpcoming = upcomingEvents.length > 2;
    final displayedUpcomingEvents = _showAllUpcoming
        ? upcomingEvents
        : upcomingEvents.take(2).toList();

    final top3FeaturedEvents = scheduleEvents.take(3).toList();

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
                                  Icons.location_on_rounded,
                                  size: 14,
                                  color: hasLocation
                                      ? const Color(0xFF6C5CE7)
                                      : badgeTextColor,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  locationAsync.isLoading
                                      ? 'Locating...'
                                      : (hasLocation
                                            ? 'Near You'
                                            : 'Location Off (Tap to Enable)'),
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
                    GestureDetector(
                      onTap: hasLocation ? null : _enableLocation,
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                            color: colorScheme.onSurface,
                          ),
                          children: [
                            if (hasLocation) ...[
                              TextSpan(
                                text: 'There are ',
                                style: TextStyle(
                                  color: isDarkMode
                                      ? Colors.grey.shade500
                                      : const Color(0xFFB0B0B8),
                                ),
                              ),
                              TextSpan(
                                text: '${scheduleEvents.length} events ',
                                style: TextStyle(
                                  color: isDarkMode
                                      ? Colors.grey.shade300
                                      : const Color(0xFF4A4A58),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              TextSpan(
                                text: 'in your area.',
                                style: TextStyle(
                                  color: isDarkMode
                                      ? Colors.grey.shade500
                                      : const Color(0xFFB0B0B8),
                                ),
                              ),
                            ] else ...[
                              TextSpan(
                                text: 'Location is off. ',
                                style: TextStyle(
                                  color: isDarkMode
                                      ? const Color(0xFFFF7675)
                                      : const Color(0xFFD63031),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              TextSpan(
                                text:
                                    'Tap to turn on & discover events near you.',
                                style: TextStyle(
                                  color: isDarkMode
                                      ? Colors.grey.shade400
                                      : const Color(0xFF7A869A),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ],
                        ),
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
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.s24,
                  ),
                  child: EventSkeletonCard(height: 250),
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
                          if (_currentFeaturedPage != realIndex) {
                            setState(() {
                              _currentFeaturedPage = realIndex;
                            });
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
                              subtitle: event.description,
                              date: DateFormat('MMM d').format(event.startDate),
                              location: event.location,
                              imageUrl:
                                  event.imageUrl ??
                                  'https://h2svision.github.io/publicAssets2/bah2026/why_participate.webp',
                              heroTag: 'featured_event_${event.id}_image',
                              onRegister: () {
                                unawaited(
                                  context.push(
                                    '/events/${event.id}',
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(top3FeaturedEvents.length, (
                        index,
                      ) {
                        final isActive = index == _currentFeaturedPage;
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
                          return RecommendedEventCard(
                            title: event.title,
                            tag: event.tags.isNotEmpty
                                ? event.tags.first
                                : 'Event',
                            date: DateFormat('MMM d').format(event.startDate),
                            location: event.location,
                            imageUrl:
                                event.imageUrl ??
                                'https://picsum.photos/400/200?random=$index',
                            gradientColors: const [
                              Color(0xFF8A4DFF),
                              Color(0xFF3E63F5),
                            ],
                            onTap: () {
                              unawaited(context.push('/events/${event.id}'));
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
                onActionTap: () => context.go('/explore'),
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
                      '126 events',
                      Icons.lightbulb_outline,
                      Colors.white,
                      isDarkMode,
                      selectedExploreCategory,
                    ),
                    _buildExploreCard(
                      'Data Science',
                      '84 events',
                      Icons.analytics_outlined,
                      AppColors.background,
                      isDarkMode,
                      selectedExploreCategory,
                    ),
                    _buildExploreCard(
                      'Cybersecurity',
                      '52 events',
                      Icons.security_outlined,
                      Colors.white,
                      isDarkMode,
                      selectedExploreCategory,
                    ),
                    _buildExploreCard(
                      'Robotics',
                      '91 events',
                      Icons.smart_toy_outlined,
                      isDarkMode
                          ? const Color(0xFF392A33)
                          : const Color(0xFFFFE5F0),
                      isDarkMode,
                      selectedExploreCategory,
                    ),
                    _buildExploreCard(
                      'Cloud',
                      '112 events',
                      Icons.cloud_outlined,
                      Colors.white,
                      isDarkMode,
                      selectedExploreCategory,
                    ),
                    _buildExploreCard(
                      'Web3',
                      '45 events',
                      Icons.currency_bitcoin_outlined,
                      isDarkMode
                          ? const Color(0xFF293342)
                          : const Color(0xFFE5F0FF),
                      isDarkMode,
                      selectedExploreCategory,
                    ),
                    _buildExploreCard(
                      'Design',
                      '78 events',
                      Icons.design_services_outlined,
                      Colors.white,
                      isDarkMode,
                      selectedExploreCategory,
                    ),
                    _buildExploreCard(
                      'Marketing',
                      '63 events',
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
                          final d = DateFormat('d').format(event.startDate);
                          final m = DateFormat('MMM').format(event.startDate);
                          return UpcomingEventTile(
                            day: d,
                            month: m,
                            title: event.title,
                            subtitle: event.isOnline
                                ? 'Online'
                                : event.location,
                            onTap: () {
                              unawaited(context.push('/events/${event.id}'));
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
