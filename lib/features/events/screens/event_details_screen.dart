import 'dart:async';
import 'dart:ui';
import 'package:ai_nexus/core/theme/app_colors.dart';
import 'package:ai_nexus/core/theme/app_spacing.dart';
import 'package:ai_nexus/features/events/models/event_model.dart';
import 'package:ai_nexus/features/events/providers/events_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class EventDetailsScreen extends ConsumerStatefulWidget {
  const EventDetailsScreen({required this.eventId, this.imageUrl, super.key});
  
  final String eventId;
  final String? imageUrl;

  @override
  ConsumerState<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends ConsumerState<EventDetailsScreen> with SingleTickerProviderStateMixin {
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

    final isLive = event.startDate.isBefore(DateTime.now()) && event.endDate.isAfter(DateTime.now());
    final isUpcoming = event.startDate.isAfter(DateTime.now());
    final dateFormatted = DateFormat('dd MMM yyyy').format(event.startDate).toUpperCase();
    final timeFormatted = '${DateFormat('h:mm a').format(event.startDate)} TO ${DateFormat('h:mm a').format(event.endDate)}';

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
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                onPressed: () => context.pop(),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.share_outlined, color: Colors.white, size: 22),
                  onPressed: () async {
                    await SharePlus.instance.share(
                      ShareParams(
                        text: 'Check out this event on AI Nexus:\n'
                            '${event.title}\n\n'
                            'Hosted by: ${event.host}\n'
                            'Date: ${DateFormat('EEEE, MMM d, yyyy - h:mm a').format(event.startDate)}\n'
                            'Location: ${event.isOnline ? 'Online' : event.location}\n\n'
                            'Learn more: ${event.url}',
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
                      widget.imageUrl ?? 'https://picsum.photos/800/600?random=${widget.eventId.hashCode}',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => ColoredBox(
                        color: AppColors.accentPurple.withValues(alpha: 0.3),
                        child: const Icon(Icons.event, size: 80, color: Colors.white54),
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
                            children: event.tags.take(3).map((tag) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: Text(tag, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
                            )).toList(),
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
                            event.description,
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
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.calendar_today_outlined, color: Colors.white, size: 24),
                                        const SizedBox(width: AppSpacing.s12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(dateFormatted, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                              const SizedBox(height: 2),
                                              Text(timeFormatted, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                            ],
                                          ),
                                        ),
                                        const Icon(Icons.location_on, color: Colors.white, size: 24),
                                        const SizedBox(width: AppSpacing.s12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(event.location, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                              const SizedBox(height: 2),
                                              Text(
                                                event.isOnline ? 'Virtual Event' : 'In-Person',
                                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: AppSpacing.s16),
                                    const Divider(color: Colors.white24, height: 1),
                                    const SizedBox(height: AppSpacing.s16),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: isLive
                                                ? Colors.greenAccent.withValues(alpha: 0.2)
                                                : AppColors.primary.withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: 8,
                                                height: 8,
                                                decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                isLive ? 'Live Now' : isUpcoming ? 'Upcoming' : 'Past Event',
                                                style: TextStyle(
                                                  color: isLive ? Colors.greenAccent : Colors.white70,
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
                                          style: const TextStyle(color: Colors.white54, fontSize: 12),
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
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF2D20),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Live now',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
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
                  unselectedLabelColor: isDark ? Colors.grey.shade400 : Colors.black54,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
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
    final tagBgColor = isDark ? AppColors.primary.withValues(alpha: 0.25) : AppColors.primary.withValues(alpha: 0.08);
    final tagBorderColor = isDark ? AppColors.primary.withValues(alpha: 0.45) : AppColors.primary.withValues(alpha: 0.2);
    final tagTextColor = isDark ? const Color(0xFF9EA5FF) : AppColors.primary;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.s24).copyWith(bottom: 120),
      children: [
        Text(
          'About this Event',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: headingTextColor),
        ),
        const SizedBox(height: AppSpacing.s16),
        Text(
          event.description,
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
              Text('Event Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: headingTextColor)),
              const SizedBox(height: 16),
              _buildDetailRow(Icons.business, 'Host', event.host, detailLabelColor, detailValueColor, isDark),
              _buildDetailRow(Icons.calendar_today, 'Date', DateFormat('EEEE, MMMM d, yyyy').format(event.startDate), detailLabelColor, detailValueColor, isDark),
              _buildDetailRow(Icons.access_time, 'Time', '${DateFormat('h:mm a').format(event.startDate)} - ${DateFormat('h:mm a').format(event.endDate)}', detailLabelColor, detailValueColor, isDark),
              _buildDetailRow(event.isOnline ? Icons.videocam : Icons.location_on, 'Location', event.location, detailLabelColor, detailValueColor, isDark),
              _buildDetailRow(Icons.link, 'Website', event.url, detailLabelColor, detailValueColor, isDark),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s24),
        Text('Tags', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: headingTextColor)),
        const SizedBox(height: AppSpacing.s12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: event.tags.map((tag) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: tagBgColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: tagBorderColor, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(tag, style: TextStyle(color: tagTextColor, fontSize: 13, fontWeight: FontWeight.w600)),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, Color labelColor, Color valueColor, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF181733) : const Color(0xFFF8F9FE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0x353E63F5) : Colors.grey.withValues(alpha: 0.15),
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
            child: Icon(icon, size: 20, color: isDark ? const Color(0xFF8C9EFF) : AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: labelColor, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(fontSize: 15, color: valueColor, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleTab(EventModel event, bool isDark) {
    // Generate schedule items based on event duration
    final duration = event.endDate.difference(event.startDate);
    final hours = duration.inHours;
    
    final scheduleItems = <Map<String, String>>[];
    final currentTime = event.startDate;
    
    if (hours <= 4) {
      scheduleItems.addAll([
        {'time': DateFormat('h:mm a').format(currentTime), 'title': 'Welcome & Opening', 'desc': 'Introduction and event overview by ${event.host}.'},
        {'time': DateFormat('h:mm a').format(currentTime.add(const Duration(minutes: 30))), 'title': 'Main Session', 'desc': '${event.title} - core presentation and demonstrations.'},
        {'time': DateFormat('h:mm a').format(currentTime.add(Duration(hours: (hours * 0.6).round()))), 'title': 'Q&A / Discussion', 'desc': 'Open floor for questions and interactive discussion.'},
        {'time': DateFormat('h:mm a').format(event.endDate.subtract(const Duration(minutes: 15))), 'title': 'Closing Remarks', 'desc': 'Summary, next steps, and networking.'},
      ]);
    } else {
      scheduleItems.addAll([
        {'time': DateFormat('h:mm a').format(currentTime), 'title': 'Registration & Check-in', 'desc': 'Arrive, check in, and grab your badge.'},
        {'time': DateFormat('h:mm a').format(currentTime.add(const Duration(minutes: 45))), 'title': 'Opening Keynote', 'desc': '${event.host} presents the vision and agenda for ${event.title}.'},
        {'time': DateFormat('h:mm a').format(currentTime.add(const Duration(hours: 2))), 'title': 'Deep Dive Sessions', 'desc': 'Technical deep dives and hands-on workshops.'},
        {'time': DateFormat('h:mm a').format(currentTime.add(const Duration(hours: 4))), 'title': 'Networking Break', 'desc': 'Connect with fellow attendees and speakers.'},
        {'time': DateFormat('h:mm a').format(event.endDate.subtract(const Duration(hours: 1))), 'title': 'Closing Panel', 'desc': 'Panel discussion and audience Q&A.'},
      ]);
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.s24).copyWith(bottom: 120),
      children: scheduleItems.map((item) => Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.s16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF201F3D) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? const Color(0x3D3E63F5) : Colors.grey.withValues(alpha: 0.2),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: _buildScheduleItem(item['time']!, item['title']!, item['desc']!, isDark),
      )).toList(),
    );
  }

  Widget _buildScheduleItem(String time, String title, String description, bool isDark) {
    final titleColor = isDark ? Colors.white : Colors.black87;
    final descColor = isDark ? Colors.grey.shade400 : Colors.black54;
    final barColor = isDark ? Colors.white24 : Colors.black12;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 70,
          child: Text(time, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13)),
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
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: titleColor)),
              const SizedBox(height: 6),
              Text(description, style: TextStyle(color: descColor, fontSize: 14, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSpeakerTab(EventModel event, bool isDark) {
    // Generate speakers based on event host
    final speakers = [
      {'name': '${event.host} Team Lead', 'role': 'Lead Organizer, ${event.host}'},
      {'name': 'Guest Speaker', 'role': 'Industry Expert'},
      {'name': 'Moderator', 'role': 'Event Host, ${event.host}'},
    ];

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.s24).copyWith(bottom: 120),
      children: speakers.asMap().entries.map((entry) {
        final index = entry.key;
        final speaker = entry.value;
        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.s16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF201F3D) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? const Color(0x3D3E63F5) : Colors.grey.withValues(alpha: 0.2),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: _buildSpeakerTile(
            speaker['name']!,
            speaker['role']!,
            'https://i.pravatar.cc/150?img=${widget.eventId.hashCode + index}',
            isDark,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSpeakerTile(String name, String role, String imageUrl, bool isDark) {
    final nameColor = isDark ? Colors.white : Colors.black87;
    final roleColor = isDark ? Colors.grey.shade400 : Colors.black54;
    final iconColor = isDark ? Colors.grey.shade400 : Colors.black54;

    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage(imageUrl),
          onBackgroundImageError: (exception, stackTrace) {},
        ),
        const SizedBox(width: AppSpacing.s16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: nameColor)),
              const SizedBox(height: 4),
              Text(role, style: TextStyle(color: roleColor, fontSize: 15)),
            ],
          ),
        ),
        Icon(Icons.chevron_right, color: iconColor),
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
    final bookmarkBgColor = isDark ? const Color(0xFF201F3D) : Colors.white.withValues(alpha: 0.7);
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
                  color: isDark ? Colors.black.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Successfully registered for ${event.title}!'),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: isDark ? 4 : 2,
                      shadowColor: AppColors.primary.withValues(alpha: 0.4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.app_registration_rounded, size: 20, color: Colors.white),
                        const SizedBox(width: AppSpacing.s8),
                        Text(
                          event.isOnline ? 'Register for Online Event' : 'Register for Event',
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
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
                      color: isDark ? const Color(0x3D3E63F5) : Colors.grey.withValues(alpha: 0.2),
                      width: 1.2,
                    ),
                  ),
                  child: IconButton(
                    padding: const EdgeInsets.all(16),
                    icon: Icon(
                      event.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: bookmarkIconColor,
                      size: 26,
                    ),
                    onPressed: () {
                      unawaited(
                          ref.read(eventsProvider.notifier).toggleBookmark(event.id));
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
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final sheetBgColor = isDark ? const Color(0xFF16152B) : const Color(0xFFF3F4F6);
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
            color: isDark ? Colors.black.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.08),
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
