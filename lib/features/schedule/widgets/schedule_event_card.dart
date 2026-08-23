import 'dart:async';

import 'package:ai_nexus/core/theme/app_colors.dart';
import 'package:ai_nexus/features/opportunities/models/opportunity_model.dart';
import 'package:ai_nexus/features/opportunities/providers/opportunities_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ScheduleEventCard extends ConsumerStatefulWidget {
  const ScheduleEventCard({
    required this.opportunity,
    super.key,
  });

  final OpportunityModel opportunity;

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

    _scaleAnimation = Tween<double>(
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

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    unawaited(_controller.reverse());
    context.push(
      '/opportunities/${widget.opportunity.id}',
    );
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  void _toggleBookmark() {
    unawaited(
      ref
          .read(opportunitiesProvider.notifier)
          .toggleBookmark(widget.opportunity.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final displayDate =
        widget.opportunity.deadline ?? widget.opportunity.createdAt;
    final day = displayDate.day;
    final month = DateFormat('MMM').format(displayDate).toUpperCase();
    final dayOfWeek = DateFormat('EEE').format(displayDate).toUpperCase();
    final time = DateFormat('h:mm a').format(displayDate);

    final dateString = '${_getOrdinal(day)} $month - $dayOfWeek - $time';

    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.10)
        : Colors.grey.withValues(alpha: 0.25);
    final titleColor = isDark ? Colors.white : Colors.black87;
    final secondaryColor =
        isDark ? Colors.white.withValues(alpha: 0.60) : Colors.grey.shade600;
    final dateColor = isDark ? Colors.purple.shade200 : Colors.deepPurple;
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
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
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
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row: Date badge + Bookmark
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 14,
                            color: dateColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            dateString,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: dateColor,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: _toggleBookmark,
                        icon: Icon(
                          widget.opportunity.isBookmarked
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          color: widget.opportunity.isBookmarked
                              ? AppColors.primary
                              : (isDark ? Colors.white54 : Colors.grey),
                          size: 20,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Middle Row: Thumbnail + Info
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Thumbnail
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 64,
                          height: 64,
                          color: imagePlaceholderColor,
                          child: widget.opportunity.imageUrl != null
                              ? Image.network(
                                  widget.opportunity.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Center(
                                    child: Icon(
                                      Icons.rocket_launch_rounded,
                                      color: AppColors.primary,
                                      size: 28,
                                    ),
                                  ),
                                )
                              : Center(
                                  child: Icon(
                                    Icons.rocket_launch_rounded,
                                    color: AppColors.primary,
                                    size: 28,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(width: 14),

                      // Title & details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.opportunity.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: titleColor,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'By ${widget.opportunity.displayOrganizer}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                color: secondaryColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                _buildSmallBadge(
                                  widget.opportunity.opportunityType,
                                  Colors.blueAccent,
                                ),
                                _buildSmallBadge(
                                  widget.opportunity.locationType,
                                  widget.opportunity.isOnline
                                      ? Colors.tealAccent
                                      : Colors.orangeAccent,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSmallBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _getOrdinal(int n) {
    if (n >= 11 && n <= 13) return '${n}th';
    switch (n % 10) {
      case 1:
        return '${n}st';
      case 2:
        return '${n}nd';
      case 3:
        return '${n}rd';
      default:
        return '${n}th';
    }
  }
}
