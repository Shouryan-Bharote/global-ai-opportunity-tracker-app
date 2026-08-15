import 'package:ai_nexus/core/theme/app_colors.dart';
import 'package:ai_nexus/core/theme/app_spacing.dart';
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

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String selectedCategory = "Today's Events";

  final List<CategoryChipData> categories = const [
    CategoryChipData(
      label: "Today's Events",
      icon: Icons.local_fire_department,
    ),
    CategoryChipData(
      label: 'Meetings',
      icon: Icons.stars_rounded,
    ),
    CategoryChipData(
      label: 'Hackathons',
      icon: Icons.hourglass_bottom,
    ),
    CategoryChipData(
      label: 'Online',
      icon: Icons.public,
    ),
    CategoryChipData(
      label: 'Near me',
      icon: Icons.location_on_outlined,
    ),
  ];

  String _getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Good Morning';
    }

    if (hour < 17) {
      return 'Good Afternoon';
    }

    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    // Get current theme colors.
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Check whether dark mode is active.
    final isDarkMode = theme.brightness == Brightness.dark;

    final selectedCategory = ref.watch(selectedCategoryProvider);
    final filteredEvents = ref.watch(filteredEventsProvider);

    final isEventsLoading = ref.watch(homeEventsProvider).isLoading;

    final eventsAsync = ref.watch(eventsProvider);
    final scheduleEvents = eventsAsync.valueOrNull ?? [];

    final profileAsync = ref.watch(profileProvider);
    final user = profileAsync.valueOrNull;

    final userName = user?.name ?? 'there';

    final todayDate = DateFormat('EEEE, MMM d').format(DateTime.now());

    const featuredEventId = 'e1';

    final featuredEvent = scheduleEvents.isNotEmpty
        ? scheduleEvents.firstWhere(
            (e) => e.id == featuredEventId,
            orElse: () => scheduleEvents.first,
          )
        : null;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      body: SingleChildScrollView(
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
                  // DATE BADGE
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),

                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? const Color(0xFF292929)
                          : const Color(0xFFF0EEF5),

                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: Row(
                      mainAxisSize: MainAxisSize.min,

                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 14,

                          color: isDarkMode
                              ? Colors.grey.shade400
                              : const Color(0xFF7A869A),
                        ),

                        const SizedBox(width: 6),

                        Text(
                          todayDate,

                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,

                            color: isDarkMode
                                ? Colors.grey.shade400
                                : const Color(0xFF7A869A),
                          ),
                        ),
                      ],
                    ),
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

                  // EVENT COUNT
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                        color: colorScheme.onSurface,
                      ),

                      children: [
                        TextSpan(
                          text: 'There are ',

                          style: TextStyle(
                            color: isDarkMode
                                ? Colors.grey.shade500
                                : const Color(0xFFB0B0B8),
                          ),
                        ),

                        TextSpan(
                          text: '${scheduleEvents.length} New',

                          style: TextStyle(
                            color: isDarkMode
                                ? Colors.grey.shade400
                                : const Color(0xFF9A9AA8),
                          ),
                        ),

                        TextSpan(
                          text: ' events in your area.',

                          style: TextStyle(
                            color: isDarkMode
                                ? Colors.grey.shade500
                                : const Color(0xFFB0B0B8),
                          ),
                        ),
                      ],
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
            // FEATURED EVENT
            // ============================================================
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s24,
              ),

              child: featuredEvent == null
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : FeaturedEventCard(
                      title: 'AI SUMMIT 2026',

                      subtitle:
                          'A feature of generative Ai, agents and multimodel',

                      date: 'Jul 24',

                      location: 'San Francisco',

                      imageUrl:
                          'https://h2svision.github.io/publicAssets2/bah2026/why_participate.webp',

                      heroTag: 'event_${featuredEventId}_image',

                      onRegister: () {
                        context.push(
                          '/events/$featuredEventId',
                          extra:
                              'https://h2svision.github.io/publicAssets2/bah2026/why_participate.webp',
                        );
                      },

                      isBookmarked: featuredEvent.isBookmarked,

                      onBookmark: () {
                        ref
                            .read(eventsProvider.notifier)
                            .toggleBookmark(
                              featuredEventId,
                            );
                      },
                    ),
            ),

            const SizedBox(height: AppSpacing.s16),

            // ============================================================
            // RECOMMENDED FOR YOU
            // ============================================================
            SectionTitle(
              title: 'Recommended for you',
              onActionTap: () {},
            ),

            SizedBox(
              height: 220,

              child: isEventsLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
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

                          date: DateFormat('MMM d').format(
                            event.startDate,
                          ),

                          location: event.location,

                          imageUrl:
                              'https://picsum.photos/400/200?random=$index',

                          gradientColors: const [
                            Color(0xFF8A4DFF),
                            Color(0xFF3E63F5),
                          ],

                          onTap: () {
                            context.push(
                              '/events/${event.id}',
                            );
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
              onActionTap: () {},
            ),

            SizedBox(
              height: 170,

              child: ListView(
                scrollDirection: Axis.horizontal,

                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s24,
                ),

                children: [
                  // AI
                  ExploreCategoryCard(
                    title: 'AI',
                    subtitle: '126 events',
                    icon: Icons.lightbulb_outline,

                    backgroundColor: isDarkMode
                        ? const Color(0xFF292929)
                        : Colors.white,

                    isSelected:
                        ref.watch(
                          selectedExploreCategoryProvider,
                        ) ==
                        'AI',

                    onTap: () {
                      final current = ref.read(
                        selectedExploreCategoryProvider,
                      );

                      ref
                          .read(
                            selectedExploreCategoryProvider.notifier,
                          )
                          .state = current == 'AI'
                          ? null
                          : 'AI';
                    },
                  ),

                  // DATA SCIENCE
                  ExploreCategoryCard(
                    title: 'Data Science',
                    subtitle: '84 events',
                    icon: Icons.analytics_outlined,

                    backgroundColor: isDarkMode
                        ? const Color(0xFF292929)
                        : AppColors.background,

                    isSelected:
                        ref.watch(
                          selectedExploreCategoryProvider,
                        ) ==
                        'Data Science',

                    onTap: () {
                      final current = ref.read(
                        selectedExploreCategoryProvider,
                      );

                      ref
                          .read(
                            selectedExploreCategoryProvider.notifier,
                          )
                          .state = current == 'Data Science'
                          ? null
                          : 'Data Science';
                    },
                  ),

                  // CYBERSECURITY
                  ExploreCategoryCard(
                    title: 'Cybersecurity',
                    subtitle: '52 events',
                    icon: Icons.security_outlined,

                    backgroundColor: isDarkMode
                        ? const Color(0xFF292929)
                        : Colors.white,

                    isSelected:
                        ref.watch(
                          selectedExploreCategoryProvider,
                        ) ==
                        'Cybersecurity',

                    onTap: () {
                      final current = ref.read(
                        selectedExploreCategoryProvider,
                      );

                      ref
                          .read(
                            selectedExploreCategoryProvider.notifier,
                          )
                          .state = current == 'Cybersecurity'
                          ? null
                          : 'Cybersecurity';
                    },
                  ),

                  // ROBOTICS
                  ExploreCategoryCard(
                    title: 'Robotics',
                    subtitle: '91 events',
                    icon: Icons.smart_toy_outlined,

                    backgroundColor: isDarkMode
                        ? const Color(0xFF392A33)
                        : const Color(0xFFFFE5F0),

                    isSelected:
                        ref.watch(
                          selectedExploreCategoryProvider,
                        ) ==
                        'Robotics',

                    onTap: () {
                      final current = ref.read(
                        selectedExploreCategoryProvider,
                      );

                      ref
                          .read(
                            selectedExploreCategoryProvider.notifier,
                          )
                          .state = current == 'Robotics'
                          ? null
                          : 'Robotics';
                    },
                  ),

                  // CLOUD
                  ExploreCategoryCard(
                    title: 'Cloud',
                    subtitle: '112 events',
                    icon: Icons.cloud_outlined,

                    backgroundColor: isDarkMode
                        ? const Color(0xFF292929)
                        : Colors.white,

                    isSelected:
                        ref.watch(
                          selectedExploreCategoryProvider,
                        ) ==
                        'Cloud',

                    onTap: () {
                      final current = ref.read(
                        selectedExploreCategoryProvider,
                      );

                      ref
                          .read(
                            selectedExploreCategoryProvider.notifier,
                          )
                          .state = current == 'Cloud'
                          ? null
                          : 'Cloud';
                    },
                  ),

                  // WEB3
                  ExploreCategoryCard(
                    title: 'Web3',
                    subtitle: '45 events',
                    icon: Icons.currency_bitcoin_outlined,

                    backgroundColor: isDarkMode
                        ? const Color(0xFF293342)
                        : const Color(0xFFE5F0FF),

                    isSelected:
                        ref.watch(
                          selectedExploreCategoryProvider,
                        ) ==
                        'Web3',

                    onTap: () {
                      final current = ref.read(
                        selectedExploreCategoryProvider,
                      );

                      ref
                          .read(
                            selectedExploreCategoryProvider.notifier,
                          )
                          .state = current == 'Web3'
                          ? null
                          : 'Web3';
                    },
                  ),

                  // DESIGN
                  ExploreCategoryCard(
                    title: 'Design',
                    subtitle: '78 events',
                    icon: Icons.design_services_outlined,

                    backgroundColor: isDarkMode
                        ? const Color(0xFF292929)
                        : Colors.white,

                    isSelected:
                        ref.watch(
                          selectedExploreCategoryProvider,
                        ) ==
                        'Design',

                    onTap: () {
                      final current = ref.read(
                        selectedExploreCategoryProvider,
                      );

                      ref
                          .read(
                            selectedExploreCategoryProvider.notifier,
                          )
                          .state = current == 'Design'
                          ? null
                          : 'Design';
                    },
                  ),

                  // MARKETING
                  ExploreCategoryCard(
                    title: 'Marketing',
                    subtitle: '63 events',
                    icon: Icons.campaign_outlined,

                    backgroundColor: isDarkMode
                        ? const Color(0xFF293329)
                        : const Color(0xFFE5FFE5),

                    isSelected:
                        ref.watch(
                          selectedExploreCategoryProvider,
                        ) ==
                        'Marketing',

                    onTap: () {
                      final current = ref.read(
                        selectedExploreCategoryProvider,
                      );

                      ref
                          .read(
                            selectedExploreCategoryProvider.notifier,
                          )
                          .state = current == 'Marketing'
                          ? null
                          : 'Marketing';
                    },
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
              onActionTap: () {},
            ),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s24,
              ),

              child: isEventsLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : Builder(
                      builder: (context) {
                        final upcomingEvents = ref.watch(
                          upcomingFilteredEventsProvider,
                        );

                        final selectedExplore = ref.watch(
                          selectedExploreCategoryProvider,
                        );

                        if (upcomingEvents.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 20,
                              ),

                              child: Text(
                                selectedExplore == null
                                    ? 'No upcoming events'
                                    : 'No upcoming events for $selectedExplore',

                                style: TextStyle(
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: upcomingEvents.take(3).map(
                            (event) {
                              return UpcomingEventTile(
                                day: DateFormat('dd').format(
                                  event.startDate,
                                ),

                                month: DateFormat('MMM')
                                    .format(
                                      event.startDate,
                                    )
                                    .toUpperCase(),

                                title: event.title,

                                subtitle:
                                    'Fri . ${event.isOnline ? 'Online' : event.location}',

                                onTap: () {
                                  context.push(
                                    '/events/${event.id}',
                                  );
                                },
                              );
                            },
                          ).toList(),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
