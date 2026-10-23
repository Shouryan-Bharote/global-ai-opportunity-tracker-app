import 'dart:async';
import 'dart:ui';
import 'package:ai_nexus/core/theme/app_colors.dart';
import 'package:ai_nexus/core/theme/app_spacing.dart';
import 'package:ai_nexus/features/auth/providers/onboarding_provider.dart';
import 'package:ai_nexus/features/events/models/event_model.dart';
import 'package:ai_nexus/features/events/providers/events_provider.dart';
import 'package:ai_nexus/features/events/widgets/ai_match_card.dart';
import 'package:ai_nexus/features/events/widgets/platform_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class EventDetailsScreen extends ConsumerStatefulWidget {
  const EventDetailsScreen({required this.eventId, this.imageUrl, super.key});

  final String eventId;
  final String? imageUrl;

  @override
  ConsumerState<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends ConsumerState<EventDetailsScreen>
    with SingleTickerProviderStateMixin {
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

  EventModel? _findEvent() {
    final eventsAsync = ref.watch(eventsProvider);
    final events = eventsAsync.valueOrNull ?? [];
    final index = events.indexWhere((e) => e.id == widget.eventId);
    if (index == -1) return null;
    return events[index];
  }

  Future<void> _openEventUrl(String rawUrl) async {
    final cleanUrl = rawUrl.trim();
    if (cleanUrl.isEmpty) return;
    final uri = Uri.tryParse(
      cleanUrl.startsWith('http') ? cleanUrl : 'https://$cleanUrl',
    );
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _addToGoogleCalendar(EventModel event) async {
    if (event.isDateTba) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event date is TBA, cannot add to calendar yet.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    String formatGCalDate(DateTime dt) {
      final utc = dt.toUtc();
      final y = utc.year.toString().padLeft(4, '0');
      final m = utc.month.toString().padLeft(2, '0');
      final d = utc.day.toString().padLeft(2, '0');
      final h = utc.hour.toString().padLeft(2, '0');
      final min = utc.minute.toString().padLeft(2, '0');
      final s = utc.second.toString().padLeft(2, '0');
      return '$y$m${d}T$h$min${s}Z';
    }

    final startStr = formatGCalDate(event.startDate);
    final endDt = event.endDate.isAfter(event.startDate)
        ? event.endDate
        : event.startDate.add(const Duration(hours: 2));
    final endStr = formatGCalDate(endDt);

    final title = Uri.encodeComponent(event.title);
    final details = Uri.encodeComponent(
      'Organized by: ${event.host}\n\n'
      '${EventModel.cleanHtml(event.description)}\n\n'
      'Event Link: ${event.url}',
    );
    final location = Uri.encodeComponent(event.location);

    final gcalUrl =
        'https://calendar.google.com/calendar/render?action=TEMPLATE&text=$title&dates=$startStr/$endStr&details=$details&location=$location';

    final uri = Uri.tryParse(gcalUrl);
    if (uri != null) {
      try {
        final launched =
            await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!launched && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open Google Calendar.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } on Exception catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to open calendar: $e'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleRegistration(
    BuildContext context,
    EventModel event,
  ) async {
    final rawUrl = event.url.trim();
    Uri? uri;
    if (rawUrl.isNotEmpty) {
      uri = Uri.tryParse(
        rawUrl.startsWith('http') ? rawUrl : 'https://$rawUrl',
      );
    }

    if (uri != null && await canLaunchUrl(uri)) {
      // 1. Launch official registration URL in external browser
      await launchUrl(uri, mode: LaunchMode.externalApplication);

      // 2. Automatically track the event in Schedule tab if not already bookmarked
      if (!event.isBookmarked) {
        await ref.read(eventsProvider.notifier).toggleBookmark(event.id);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            content: Row(
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Opening official registration at ${event.host}. Event tracked in your Schedule!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No official registration link provided for ${event.title}.',
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final event = _findEvent();
    if (event == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Event Not Found')),
        body: const Center(child: Text('This event could not be found.')),
      );
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isLive =
        !event.isDateTba &&
        event.startDate.isBefore(DateTime.now()) &&
        event.endDate.isAfter(DateTime.now());
    final isUpcoming =
        event.isDateTba || event.startDate.isAfter(DateTime.now());
    final dateFormatted = event.isDateTba
        ? 'DATE TBA'
        : DateFormat('dd MMM yyyy').format(event.startDate).toUpperCase();
    final timeFormatted = event.isDateTba
        ? 'SCHEDULE TO BE ANNOUNCED'
        : '${DateFormat('h:mm a').format(event.startDate)} TO ${DateFormat('h:mm a').format(event.endDate)}';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0E17) : Colors.black,
      extendBody: true,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 440,
              pinned: true,
              backgroundColor: isDark ? const Color(0xFF0F0E17) : Colors.black,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () => context.pop(),
              ),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.share_outlined,
                    color: Colors.white,
                    size: 22,
                  ),
                  onPressed: () async {
                    final dateStr = event.isDateTba
                        ? 'Schedule to be announced'
                        : DateFormat(
                            'EEEE, MMM d, yyyy - h:mm a',
                          ).format(event.startDate);
                    await SharePlus.instance.share(
                      ShareParams(
                        text:
                            'Check out this opportunity on Global AI Opportunity Tracker:\n'
                            '${event.title}\n\n'
                            'Hosted by: ${event.host}\n'
                            'Date: $dateStr\n'
                            'Location: ${event.isOnline ? 'Online' : event.location}\n\n'
                            'Official link: ${event.url}',
                        subject: event.title,
                      ),
                    );
                  },
                ),
                const SizedBox(width: AppSpacing.s8),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background Image
                    Image.network(
                      widget.imageUrl ??
                          'https://picsum.photos/800/600?random=${widget.eventId.hashCode}',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => ColoredBox(
                        color: AppColors.accentPurple.withValues(alpha: 0.3),
                        child: const Icon(
                          Icons.event,
                          size: 80,
                          color: Colors.white54,
                        ),
                      ),
                    ),
                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.4),
                            Colors.black.withValues(alpha: 0.7),
                            Colors.black,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                    // Content
                    Positioned(
                      left: AppSpacing.s24,
                      right: AppSpacing.s24,
                      bottom: AppSpacing.s48,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tags
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              PlatformBadge(url: event.url, host: event.host),
                              ...event.tags
                                  .take(3)
                                  .map(
                                    (tag) => Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.15,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.white24),
                                      ),
                                      child: Text(
                                        tag,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.s12),
                          Text(
                            event.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.s8),
                          Text(
                            EventModel.cleanHtml(event.description),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppSpacing.s24),
                          // Glassmorphism Info Card
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                              child: Container(
                                padding: const EdgeInsets.all(AppSpacing.s20),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.calendar_today_outlined,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                        const SizedBox(width: AppSpacing.s12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                dateFormatted,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                timeFormatted,
                                                style: const TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(
                                          Icons.location_on,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                        const SizedBox(width: AppSpacing.s12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                event.location,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                event.isOnline
                                                    ? 'Virtual Event'
                                                    : 'In-Person',
                                                style: const TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: AppSpacing.s16),
                                    const Divider(
                                      color: Colors.white24,
                                      height: 1,
                                    ),
                                    const SizedBox(height: AppSpacing.s16),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isLive
                                                ? Colors.greenAccent.withValues(
                                                    alpha: 0.2,
                                                  )
                                                : AppColors.primary.withValues(
                                                    alpha: 0.2,
                                                  ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: 8,
                                                height: 8,
                                                decoration: const BoxDecoration(
                                                  color: Colors.greenAccent,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                isLive
                                                    ? 'Live Now'
                                                    : isUpcoming
                                                    ? 'Upcoming'
                                                    : 'Past Event',
                                                style: TextStyle(
                                                  color: isLive
                                                      ? Colors.greenAccent
                                                      : Colors.white70,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          'Hosted by ${event.host}',
                                          style: const TextStyle(
                                            color: Colors.white54,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Status badge
                    if (isLive)
                      Positioned(
                        bottom: 24,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF2D20),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Live now',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: isDark
                        ? AppColors.primary.withValues(alpha: 0.3)
                        : AppColors.primary.withValues(alpha: 0.12),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.6),
                      width: 1.2,
                    ),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: isDark ? Colors.white : AppColors.primary,
                  unselectedLabelColor: isDark
                      ? Colors.grey.shade400
                      : Colors.black54,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s16,
                  ),
                  tabs: const [
                    Tab(text: 'About'),
                    Tab(text: 'Schedule'),
                    Tab(text: 'Speaker'),
                  ],
                ),
                isDark: isDark,
              ),
            ),
          ];
        },
        body: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF16152B) : const Color(0xFFF3F4F6),
          ),
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildAboutTab(event, isDark),
              _buildScheduleTab(event, isDark),
              _buildSpeakerTab(event, isDark),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(event, isLive, isDark),
    );
  }

  Widget _buildAboutTab(EventModel event, bool isDark) {
    final headingTextColor = isDark ? Colors.white : Colors.black87;
    final bodyTextColor = isDark ? Colors.grey.shade300 : Colors.black87;
    final cardBgColor = isDark ? const Color(0xFF201F3D) : Colors.white;
    final cardBorderColor = isDark
        ? AppColors.primary.withValues(alpha: 0.35)
        : Colors.grey.withValues(alpha: 0.25);
    final detailLabelColor = isDark ? Colors.grey.shade400 : Colors.black45;
    final detailValueColor = isDark ? Colors.white : Colors.black87;
    final tagBgColor = isDark
        ? AppColors.primary.withValues(alpha: 0.25)
        : AppColors.primary.withValues(alpha: 0.08);
    final tagBorderColor = isDark
        ? AppColors.primary.withValues(alpha: 0.45)
        : AppColors.primary.withValues(alpha: 0.2);
    final tagTextColor = isDark ? const Color(0xFF9EA5FF) : AppColors.primary;
    final userInterests = ref.watch(userInterestsNotifierProvider);
    final userRole = ref.watch(userRoleProvider);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.s24).copyWith(bottom: 160),
      children: [
        // 1. AI Match Score Card ("Why this fits you")
        AiMatchCard(
          event: event,
          userInterests: userInterests,
          userRole: userRole,
        ),
        const SizedBox(height: AppSpacing.s16),

        // 2. Countdown timer to registration deadline
        if (event.startDate.isAfter(DateTime.now()) && !event.isDateTba) ...[
          _CountdownTimer(deadline: event.startDate),
          const SizedBox(height: AppSpacing.s16),
        ],

        Text(
          'About this Event',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: headingTextColor,
          ),
        ),
        const SizedBox(height: AppSpacing.s16),
        Text(
          EventModel.cleanHtml(event.description).isNotEmpty
              ? EventModel.cleanHtml(event.description)
              : 'Explore ${event.title} organized by ${event.host}. Check official event channels for complete agenda and updates.',
          style: TextStyle(fontSize: 16, color: bodyTextColor, height: 1.6),
        ),
        const SizedBox(height: AppSpacing.s24),
        // Event Details Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardBgColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: cardBorderColor, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.4)
                    : Colors.grey.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Event Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: headingTextColor,
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailRow(
                Icons.business,
                'Host',
                event.host,
                detailLabelColor,
                detailValueColor,
                isDark,
              ),
              _buildDetailWidgetRow(
                Icons.hub_outlined,
                'Platform Source',
                PlatformBadge(url: event.url, host: event.host),
                detailLabelColor,
                isDark,
              ),
              _buildDetailRow(
                Icons.calendar_today,
                'Date',
                event.isDateTba
                    ? 'To be announced'
                    : () {
                        final start = event.startDate;
                        final end = event.endDate;
                        final sameDay = start.year == end.year &&
                            start.month == end.month &&
                            start.day == end.day;
                        // Multi-day event: show range
                        if (!sameDay && end.isAfter(start)) {
                          final startFmt = DateFormat('MMM d').format(start);
                          final endFmt = DateFormat('MMM d, yyyy').format(end);
                          return '$startFmt – $endFmt';
                        }
                        // Single day
                        return DateFormat('EEEE, MMMM d, yyyy').format(start);
                      }(),
                detailLabelColor,
                detailValueColor,
                isDark,
              ),
              _buildDetailRow(
                event.isOnline ? Icons.videocam : Icons.location_on,
                'Location',
                event.location,
                detailLabelColor,
                detailValueColor,
                isDark,
              ),
              _buildDetailRow(
                Icons.link,
                'Website',
                event.url,
                detailLabelColor,
                detailValueColor,
                isDark,
              ),
              const SizedBox(height: 14),
              // 1-Tap Google Calendar Intent
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _addToGoogleCalendar(event),
                  icon: const Icon(
                    Icons.calendar_month_rounded,
                    color: AppColors.primary,
                    size: 19,
                  ),
                  label: const Text(
                    'Add to Google Calendar',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark ? Colors.white : AppColors.primary,
                    side: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.45),
                      width: 1.2,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s24),
        Text(
          'Tags',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: headingTextColor,
          ),
        ),
        const SizedBox(height: AppSpacing.s12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: event.tags
              .map(
                (tag) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: tagBgColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: tagBorderColor, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(
                          alpha: isDark ? 0.2 : 0.06,
                        ),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      color: tagTextColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
    Color labelColor,
    Color valueColor,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF181733) : const Color(0xFFF8F9FE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? const Color(0x353E63F5)
              : Colors.grey.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isDark ? const Color(0xFF8C9EFF) : AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: labelColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    color: valueColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailWidgetRow(
    IconData icon,
    String label,
    Widget valueWidget,
    Color labelColor,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF181733) : const Color(0xFFF8F9FE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? const Color(0x353E63F5)
              : Colors.grey.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isDark ? const Color(0xFF8C9EFF) : AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: labelColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                valueWidget,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleTab(EventModel event, bool isDark) {
    // ---------------------------------------------------------------
    // Determine whether we have a REAL start date from the backend.
    // If the start date is within 2 minutes of DateTime.now() it means
    // it's the default fallback value — no real timeline data exists.
    // ---------------------------------------------------------------
    final hasRealStartDate = !event.isDateTba;
    final hasRealEndDate =
        !event.isDateTba && event.endDate.isAfter(event.startDate);

    // No real dates → show honest "TBA" state
    if (!hasRealStartDate) {
      return ListView(
        padding: const EdgeInsets.all(AppSpacing.s24).copyWith(bottom: 120),
        children: [
          const SizedBox(height: 24),
          Icon(
            Icons.event_busy_rounded,
            size: 56,
            color: isDark ? Colors.white24 : Colors.black26,
          ),
          const SizedBox(height: 16),
          Text(
            'Schedule Not Yet Available',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "The organiser hasn't published a detailed schedule yet.\nCheck the official event page for updates.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: isDark ? Colors.white38 : Colors.black45,
            ),
          ),
          const SizedBox(height: 24),
          if (event.url.isNotEmpty)
            Center(
              child: InkWell(
                onTap: () => _openEventUrl(event.url),
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.open_in_new,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Visit Official Event Page',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      );
    }

    // ---------------------------------------------------------------
    // We have real dates. Build a timeline based on event duration.
    // ---------------------------------------------------------------
    final duration = event.endDate.difference(event.startDate);
    final days = duration.inDays;
    final hours = duration.inHours;

    final scheduleItems = <Map<String, String>>[];

    if (days >= 2) {
      // Multi-day event → show day milestones with real dates
      final fmt = DateFormat('EEE, MMM d');
      scheduleItems.addAll([
        {
          'time': fmt.format(event.startDate),
          'title': 'Day 1 – Opening & Registration',
          'desc':
              'Check in, opening keynote by ${event.host}, and introductions.',
        },
        if (days >= 3)
          {
            'time': fmt.format(event.startDate.add(const Duration(days: 1))),
            'title': 'Day 2 – Main Sessions',
            'desc': 'Workshops, deep dives, and networking opportunities.',
          },
        if (days >= 4)
          {
            'time': fmt.format(event.startDate.add(const Duration(days: 2))),
            'title': 'Day 3 – Demos & Presentations',
            'desc': 'Project presentations, judging, and sponsor showcases.',
          },
        {
          'time': fmt.format(
            hasRealEndDate
                ? event.endDate
                : event.startDate.add(Duration(days: days)),
          ),
          'title': 'Final Day – Awards & Closing',
          'desc': 'Results, prizes, closing remarks, and photo opportunities.',
        },
      ]);
    } else if (hours <= 4) {
      // Short single-day event → time-based with real start time
      scheduleItems.addAll([
        {
          'time': DateFormat('h:mm a').format(event.startDate),
          'title': 'Welcome & Opening',
          'desc': 'Introduction and event overview by ${event.host}.',
        },
        {
          'time': DateFormat(
            'h:mm a',
          ).format(event.startDate.add(const Duration(minutes: 30))),
          'title': 'Main Session',
          'desc': '${event.title} — core presentation and demonstrations.',
        },
        {
          'time': DateFormat(
            'h:mm a',
          ).format(event.startDate.add(Duration(hours: (hours * 0.6).round()))),
          'title': 'Q&A / Discussion',
          'desc': 'Open floor for questions and interactive discussion.',
        },
        {
          'time': DateFormat(
            'h:mm a',
          ).format(event.endDate.subtract(const Duration(minutes: 15))),
          'title': 'Closing Remarks',
          'desc': 'Summary, next steps, and networking.',
        },
      ]);
    } else {
      // Full-day event → time-based with real start time
      scheduleItems.addAll([
        {
          'time': DateFormat('h:mm a').format(event.startDate),
          'title': 'Registration & Check-in',
          'desc': 'Arrive, check in, and grab your badge.',
        },
        {
          'time': DateFormat(
            'h:mm a',
          ).format(event.startDate.add(const Duration(minutes: 45))),
          'title': 'Opening Keynote',
          'desc':
              '${event.host} presents the vision and agenda for ${event.title}.',
        },
        {
          'time': DateFormat(
            'h:mm a',
          ).format(event.startDate.add(const Duration(hours: 2))),
          'title': 'Deep Dive Sessions',
          'desc': 'Technical deep dives and hands-on workshops.',
        },
        {
          'time': DateFormat(
            'h:mm a',
          ).format(event.startDate.add(const Duration(hours: 4))),
          'title': 'Networking Break',
          'desc': 'Connect with fellow attendees and speakers.',
        },
        {
          'time': DateFormat(
            'h:mm a',
          ).format(event.endDate.subtract(const Duration(hours: 1))),
          'title': 'Closing Panel',
          'desc': 'Panel discussion and audience Q&A.',
        },
      ]);
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.s24).copyWith(bottom: 120),
      children: scheduleItems
          .map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.s16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF201F3D) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark
                      ? const Color(0x3D3E63F5)
                      : Colors.grey.withValues(alpha: 0.2),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.3)
                        : Colors.grey.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _buildScheduleItem(
                item['time']!,
                item['title']!,
                item['desc']!,
                isDark,
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildScheduleItem(
    String time,
    String title,
    String description,
    bool isDark,
  ) {
    final titleColor = isDark ? Colors.white : Colors.black87;
    final descColor = isDark ? Colors.grey.shade400 : Colors.black54;
    final barColor = isDark ? Colors.white24 : Colors.black12;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 70,
          child: Text(
            time,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              fontSize: 13,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          width: 2,
          height: 60,
          color: barColor,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: TextStyle(color: descColor, fontSize: 14, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSpeakerTab(EventModel event, bool isDark) {
    final titleColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.grey.shade400 : Colors.black54;
    final cardBgColor = isDark ? const Color(0xFF201F3D) : Colors.white;
    final cardBorderColor = isDark
        ? const Color(0x3D3E63F5)
        : Colors.grey.withValues(alpha: 0.2);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.s24).copyWith(bottom: 120),
      children: [
        // Verified Organizer Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cardBgColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: cardBorderColor, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.grey.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                child: Text(
                  event.host.isNotEmpty ? event.host[0].toUpperCase() : 'H',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            event.host,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: titleColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.verified,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Official Event Organizer',
                      style: TextStyle(color: subtitleColor, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s20),
        // Speakers Lineup TBA Card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: BoxDecoration(
            color: cardBgColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: cardBorderColor, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.grey.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.campaign_outlined,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Speakers Lineup TBA',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Guest speakers, mentors, and panelists will be announced by ${event.host} closer to the event schedule.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: subtitleColor,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(EventModel event, bool isLive, bool isDark) {
    final barBgColor = isDark
        ? const Color(0xEE16152B)
        : Colors.white.withValues(alpha: 0.85);
    final barBorderColor = isDark
        ? AppColors.primary.withValues(alpha: 0.45)
        : Colors.grey.withValues(alpha: 0.3);
    final bookmarkBgColor = isDark
        ? const Color(0xFF201F3D)
        : Colors.white.withValues(alpha: 0.7);
    final bookmarkIconColor = event.isBookmarked
        ? AppColors.primary
        : (isDark ? Colors.white : Colors.black87);

    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 32),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: barBgColor,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: barBorderColor, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.5)
                      : Colors.black.withValues(alpha: 0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _handleRegistration(context, event),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: isDark ? 4 : 2,
                      shadowColor: AppColors.primary.withValues(alpha: 0.4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.open_in_new_rounded,
                          size: 20,
                          color: Colors.white,
                        ),
                        const SizedBox(width: AppSpacing.s8),
                        Text(
                          event.isOnline
                              ? 'Register for Online Event'
                              : 'Register for In-Person Event',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.s12),
                Container(
                  decoration: BoxDecoration(
                    color: bookmarkBgColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? const Color(0x3D3E63F5)
                          : Colors.grey.withValues(alpha: 0.2),
                      width: 1.2,
                    ),
                  ),
                  child: IconButton(
                    padding: const EdgeInsets.all(16),
                    icon: Icon(
                      event.isBookmarked
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      color: bookmarkIconColor,
                      size: 26,
                    ),
                    onPressed: () {
                      unawaited(
                        ref
                            .read(eventsProvider.notifier)
                            .toggleBookmark(event.id),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar, {required this.isDark});

  final TabBar _tabBar;
  final bool isDark;

  @override
  double get minExtent => _tabBar.preferredSize.height + 20;
  @override
  double get maxExtent => _tabBar.preferredSize.height + 20;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final sheetBgColor = isDark
        ? const Color(0xFF16152B)
        : const Color(0xFFF3F4F6);
    final handleColor = isDark ? Colors.white30 : Colors.black12;

    return Container(
      decoration: BoxDecoration(
        color: sheetBgColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(32),
        ),
        border: Border(
          top: BorderSide(
            color: isDark
                ? AppColors.primary.withValues(alpha: 0.35)
                : Colors.white.withValues(alpha: 0.8),
            width: 1.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.5)
                : Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 6),
            width: 48,
            height: 4,
            decoration: BoxDecoration(
              color: handleColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(child: _tabBar),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return oldDelegate.isDark != isDark;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Live Countdown Timer Widget
// ─────────────────────────────────────────────────────────────────────────────

class _CountdownTimer extends StatefulWidget {
  const _CountdownTimer({required this.deadline});

  final DateTime deadline;

  @override
  State<_CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<_CountdownTimer>
    with SingleTickerProviderStateMixin {
  late Timer _timer;
  late Duration _remaining;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _remaining = widget.deadline.difference(DateTime.now());

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final updated = widget.deadline.difference(DateTime.now());
      if (mounted) setState(() => _remaining = updated);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  // ── helpers ──────────────────────────────────────────────────────────────

  bool get _isLive => _remaining.isNegative || _remaining == Duration.zero;
  bool get _isUrgent =>
      !_isLive && _remaining.inHours < 24;

  String _pad(int n) => n.toString().padLeft(2, '0');



  // ── colours ───────────────────────────────────────────────────────────────

  Color get _accentColor {
    if (_isLive) return const Color(0xFF22C55E); // green
    if (_isUrgent) return const Color(0xFFF97316); // amber-orange
    return const Color(0xFF6366F1); // indigo
  }

  String get _headerLabel {
    if (_isLive) return '🟢  Live Now';
    if (_isUrgent) return '🔥  Ending Soon!';
    return '⏳  Starts In';
  }

  // ── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = _accentColor;
    final bgColor = isDark
        ? accent.withValues(alpha: 0.12)
        : accent.withValues(alpha: 0.07);
    final borderColor = accent.withValues(alpha: 0.4);

    Widget card = Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.4),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.18),
            blurRadius: 18,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                _headerLabel,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: accent,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Countdown digits
          if (_isLive) Text(
                  'Event is happening right now!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: accent,
                  ),
                ) else Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _buildSegments(),
                ),
        ],
      ),
    );

    // pulse the card when urgent or live
    if (_isUrgent || _isLive) {
      card = ScaleTransition(scale: _pulseAnimation, child: card);
    }

    return card;
  }

  List<Widget> _buildSegments() {
    final d = _remaining.inDays;
    final h = _remaining.inHours.remainder(24);
    final m = _remaining.inMinutes.remainder(60);
    final s = _remaining.inSeconds.remainder(60);

    final segments = <_Seg>[
      if (d > 0) _Seg(value: d, label: 'DAYS'),
      _Seg(value: h, label: 'HRS'),
      _Seg(value: m, label: 'MIN'),
      _Seg(value: s, label: 'SEC'),
    ];

    final accent = _accentColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final widgets = <Widget>[];
    for (var i = 0; i < segments.length; i++) {
      final seg = segments[i];
      widgets.add(
        Column(
          children: [
            Text(
              _pad(seg.value),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : Colors.black87,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              seg.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: accent,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      );
      if (i < segments.length - 1) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Text(
              ':',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: accent.withValues(alpha: 0.7),
              ),
            ),
          ),
        );
      }
    }
    return widgets;
  }
}

class _Seg {
  const _Seg({required this.value, required this.label});
  final int value;
  final String label;
}
