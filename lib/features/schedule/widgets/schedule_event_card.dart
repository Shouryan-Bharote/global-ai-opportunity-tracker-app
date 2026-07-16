import 'dart:async';
import 'package:ai_nexus/core/theme/app_colors.dart';
import 'package:ai_nexus/features/events/models/event_model.dart';
import 'package:ai_nexus/features/events/providers/events_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ScheduleEventCard extends ConsumerStatefulWidget {
  const ScheduleEventCard({
    required this.event,
    super.key,
  });

  final EventModel event;

  @override
  ConsumerState<ScheduleEventCard> createState() => _ScheduleEventCardState();
}

class _ScheduleEventCardState extends ConsumerState<ScheduleEventCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) => _controller.forward();
  
  void _onTapUp(TapUpDetails details) {
    unawaited(_controller.reverse());
    unawaited(context.push('/events/${widget.event.id}'));
  }
  
  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    // Format Date: "1ST MAY- SAT -2:00 PM"
    final dayFormat = DateFormat('d');
    final monthFormat = DateFormat('MMM').format(widget.event.startDate).toUpperCase();
    final dayOfWeek = DateFormat('EEE').format(widget.event.startDate).toUpperCase();
    final timeFormat = DateFormat('h:mm a').format(widget.event.startDate);
    
    // Add ordinal suffix (st, nd, rd, th)
    String getOrdinal(int day) {
      if (day >= 11 && day <= 13) return '${day}TH';
      switch (day % 10) {
        case 1: return '${day}ST';
        case 2: return '${day}ND';
        case 3: return '${day}RD';
        default: return '${day}TH';
      }
    }
    
    final dayStr = getOrdinal(int.parse(dayFormat.format(widget.event.startDate)));
    final dateString = '$dayStr $monthFormat- $dayOfWeek -$timeFormat';

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final isPressed = _controller.value > 0.3;
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isPressed 
                      ? AppColors.primary.withValues(alpha: 0.45) 
                      : Colors.grey.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        widget.event.imageUrl ?? 'https://picsum.photos/200?random=${widget.event.id.hashCode}',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 80,
                          height: 80,
                          color: AppColors.primary.withValues(alpha: 0.1),
                          child: const Icon(Icons.event, color: AppColors.primary, size: 28),
                        ),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey.shade100,
                            child: const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Right Content Section
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  dateString,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.deepPurple, // Theme accent color
                                  ),
                                ),
                              ),
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  unawaited(ref.read(eventsProvider.notifier).toggleBookmark(widget.event.id));
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 12, bottom: 8),
                                  child: Icon(
                                    widget.event.isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                                    size: 26,
                                    color: widget.event.isBookmarked ? AppColors.primary : Colors.grey.shade500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.event.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 16,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  widget.event.location,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
