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

class _ScheduleEventCardState extends ConsumerState<ScheduleEventCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );

    _scaleAnimation =
        Tween<double>(
          begin: 1,
          end: 0.97,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeInOut,
          ),
        );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ============================================================
  // CARD TAP
  // ============================================================

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();

    unawaited(
      context.push(
        '/events/${widget.event.id}',
      ),
    );
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  // ============================================================
  // BOOKMARK
  // ============================================================

  void _toggleBookmark() {
    unawaited(
      ref.read(eventsProvider.notifier).toggleBookmark(widget.event.id),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // ==========================================================
    // DATE
    // ==========================================================

    final day = widget.event.startDate.day;

    final month =
        DateFormat(
              'MMM',
            )
            .format(
              widget.event.startDate,
            )
            .toUpperCase();

    final dayOfWeek =
        DateFormat(
              'EEE',
            )
            .format(
              widget.event.startDate,
            )
            .toUpperCase();

    final time =
        DateFormat(
          'h:mm a',
        ).format(
          widget.event.startDate,
        );

    final dateString = '${_getOrdinal(day)} $month - $dayOfWeek - $time';

    // ==========================================================
    // COLORS
    // ==========================================================

    final cardColor = isDark ? const Color(0xFF16152B) : Colors.white;

    final borderColor = isDark
        ? const Color(0x3D3E63F5)
        : Colors.grey.withValues(alpha: 0.25);

    final titleColor = isDark ? Colors.white : Colors.black87;

    final secondaryColor = isDark
        ? Colors.white.withValues(alpha: 0.60)
        : Colors.grey.shade600;

    final dateColor = isDark ? const Color(0xFFC084FC) : Colors.deepPurple;

    final imagePlaceholderColor = isDark
        ? const Color(0xFF30243D)
        : AppColors.primary.withValues(alpha: 0.10);

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
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isPressed
                      ? AppColors.primary.withValues(alpha: 0.45)
                      : borderColor,
                  width: 1.5,
                ),
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
              ),

              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ==================================================
                    // EVENT IMAGE
                    // ==================================================
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        widget.event.imageUrl ??
                            'https://picsum.photos/200?random=${widget.event.id.hashCode}',

                        width: 80,
                        height: 80,

                        fit: BoxFit.cover,

                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80,
                            height: 80,
                            color: imagePlaceholderColor,
                            child: const Icon(
                              Icons.event_rounded,
                              color: AppColors.primary,
                              size: 28,
                            ),
                          );
                        },

                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }

                          return Container(
                            width: 80,
                            height: 80,
                            color: isDark
                                ? const Color(0xFF292929)
                                : Colors.grey.shade100,
                            child: const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(width: 16),

                    // ==================================================
                    // EVENT DETAILS
                    // ==================================================
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ==========================================
                          // DATE + BOOKMARK
                          // ==========================================
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  dateString,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: dateColor,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 8),

                              // BOOKMARK BUTTON
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: _toggleBookmark,
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Icon(
                                      widget.event.isBookmarked
                                          ? Icons.bookmark_rounded
                                          : Icons.bookmark_outline_rounded,
                                      size: 24,
                                      color: widget.event.isBookmarked
                                          ? AppColors.primary
                                          : secondaryColor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 5),

                          // ==========================================
                          // TITLE
                          // ==========================================
                          Text(
                            widget.event.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: titleColor,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // ==========================================
                          // LOCATION
                          // ==========================================
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 16,
                                color: secondaryColor,
                              ),

                              const SizedBox(width: 4),

                              Expanded(
                                child: Text(
                                  widget.event.location,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: secondaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 4),

                          // ==========================================
                          // ONLINE / OFFLINE
                          // ==========================================
                          Row(
                            children: [
                              Icon(
                                widget.event.isOnline
                                    ? Icons.language_rounded
                                    : Icons.location_city_rounded,
                                size: 15,
                                color: secondaryColor,
                              ),

                              const SizedBox(width: 4),

                              Text(
                                widget.event.isOnline ? 'Online' : 'Offline',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: secondaryColor,
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

  // ============================================================
  // ORDINAL DATE
  // ============================================================

  String _getOrdinal(int day) {
    if (day >= 11 && day <= 13) {
      return '${day}TH';
    }

    switch (day % 10) {
      case 1:
        return '${day}ST';

      case 2:
        return '${day}ND';

      case 3:
        return '${day}RD';

      default:
        return '${day}TH';
    }
  }
}
