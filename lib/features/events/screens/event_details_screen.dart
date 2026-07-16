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
    try {
      return events.firstWhere((e) => e.id == widget.eventId);
    } catch (_) {
      return null;
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

    final isLive = event.startDate.isBefore(DateTime.now()) && event.endDate.isAfter(DateTime.now());
    final isUpcoming = event.startDate.isAfter(DateTime.now());
    final dateFormatted = DateFormat('dd MMM yyyy').format(event.startDate).toUpperCase();
    final timeFormatted = '${DateFormat('h:mm a').format(event.startDate)} TO ${DateFormat('h:mm a').format(event.endDate)}';

    return Scaffold(
      backgroundColor: Colors.black,
      extendBody: true,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 440.0,
              pinned: true,
              backgroundColor: Colors.black,
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
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.accentPurple.withOpacity(0.3),
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
                            Colors.black.withOpacity(0.4),
                            Colors.black.withOpacity(0.7),
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
                                color: Colors.white.withOpacity(0.15),
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
                              filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                              child: Container(
                                padding: const EdgeInsets.all(AppSpacing.s20),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white.withOpacity(0.2)),
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
                                                ? Colors.greenAccent.withOpacity(0.2)
                                                : AppColors.primary.withOpacity(0.2),
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
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 3,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: Colors.black54,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  tabs: const [
                    Tab(text: 'About'),
                    Tab(text: 'Schedule'),
                    Tab(text: 'Speaker'),
                  ],
                ),
              ),
            ),
          ];
        },
        body: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF3F4F6),
          ),
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildAboutTab(event),
              _buildScheduleTab(event),
              _buildSpeakerTab(event),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(event, isLive),
    );
  }

  Widget _buildAboutTab(EventModel event) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.s24).copyWith(bottom: 120),
      children: [
        const Text(
          'About this Event',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: AppSpacing.s16),
        Text(
          event.description,
          style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.6),
        ),
        const SizedBox(height: AppSpacing.s24),
        // Event Details Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border.withOpacity(0.6)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Event Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 16),
              _buildDetailRow(Icons.business, 'Host', event.host),
              const SizedBox(height: 12),
              _buildDetailRow(Icons.calendar_today, 'Date', DateFormat('EEEE, MMMM d, yyyy').format(event.startDate)),
              const SizedBox(height: 12),
              _buildDetailRow(Icons.access_time, 'Time', '${DateFormat('h:mm a').format(event.startDate)} - ${DateFormat('h:mm a').format(event.endDate)}'),
              const SizedBox(height: 12),
              _buildDetailRow(event.isOnline ? Icons.videocam : Icons.location_on, 'Location', event.location),
              const SizedBox(height: 12),
              _buildDetailRow(Icons.link, 'Website', event.url),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s24),
        const Text('Tags', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: AppSpacing.s12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: event.tags.map((tag) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Text(tag, style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600)),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.black45, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 15, color: Colors.black87)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleTab(EventModel event) {
    // Generate schedule items based on event duration
    final duration = event.endDate.difference(event.startDate);
    final hours = duration.inHours;
    
    final scheduleItems = <Map<String, String>>[];
    var currentTime = event.startDate;
    
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
      children: scheduleItems.map((item) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.s20),
        child: _buildScheduleItem(item['time']!, item['title']!, item['desc']!),
      )).toList(),
    );
  }

  Widget _buildScheduleItem(String time, String title, String description) {
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
          height: 80,
          color: Colors.black12,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
              const SizedBox(height: 6),
              Text(description, style: const TextStyle(color: Colors.black54, fontSize: 14, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSpeakerTab(EventModel event) {
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
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.s20),
          child: _buildSpeakerTile(
            speaker['name']!,
            speaker['role']!,
            'https://i.pravatar.cc/150?img=${widget.eventId.hashCode + index}',
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSpeakerTile(String name, String role, String imageUrl) {
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
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.black87)),
              const SizedBox(height: 4),
              Text(role, style: const TextStyle(color: Colors.black54, fontSize: 15)),
            ],
          ),
        ),
        const Icon(Icons.chevron_right, color: Colors.black54),
      ],
    );
  }

  Widget _buildBottomBar(EventModel event, bool isLive) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 32),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.4),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B41E3),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isLive) ...[
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: AppSpacing.s8),
                        ],
                        Text(
                          isLive ? 'Watch live now' : event.isOnline ? 'Join Online' : 'Register Now',
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.s12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: IconButton(
                    padding: const EdgeInsets.all(16),
                    icon: Icon(
                      event.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: event.isBookmarked ? AppColors.primary : Colors.black87,
                      size: 26,
                    ),
                    onPressed: () {
                      ref.read(eventsProvider.notifier).toggleBookmark(event.id);
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
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height + 20;
  @override
  double get maxExtent => _tabBar.preferredSize.height + 20;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF3F4F6),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 4),
            width: 48,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(child: _tabBar),
          Container(
            height: 1,
            color: Colors.black12,
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
