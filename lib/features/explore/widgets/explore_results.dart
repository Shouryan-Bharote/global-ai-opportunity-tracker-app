import 'dart:async';
import 'package:ai_nexus/core/theme/app_colors.dart';
import 'package:ai_nexus/core/theme/app_spacing.dart';
import 'package:ai_nexus/features/explore/providers/explore_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ExploreResults extends ConsumerWidget {
  const ExploreResults({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredEventsAsync = ref.watch(exploreFilteredEventsProvider);
    final isExpanded = ref.watch(exploreResultsExpandedProvider);

    return filteredEventsAsync.when(
      // ============================================================
      // LOADING
      // ============================================================
      loading: () => const Padding(
        padding: EdgeInsets.all(40),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),

      // ============================================================
      // ERROR
      // ============================================================
      error: (e, st) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Error: $e',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ),
      ),

      // ============================================================
      // DATA
      // ============================================================
      data: (filteredEvents) {
        final displayEvents = isExpanded || filteredEvents.length <= 2
            ? filteredEvents
            : filteredEvents.take(2).toList();

        return Column(
          children: [
            // ========================================================
            // RESULT HEADER
            // ========================================================
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s24,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Result',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),

                  Row(
                    children: [
                      // ==================================================
                      // MAP BUTTON
                      // ==================================================
                      IconButton(
                        onPressed: () {
                          final isDark =
                              Theme.of(context).brightness == Brightness.dark;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Map View is coming soon!',
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: isDark
                                  ? const Color(0xFF2A2A2A)
                                  : Colors.white,
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.map_outlined,
                          color: Colors.blue,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        style: IconButton.styleFrom(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),

                      const SizedBox(width: 12),

                      // ==================================================
                      // SEE ALL / SHOW LESS
                      // ==================================================
                      if (filteredEvents.length > 2)
                        TextButton(
                          onPressed: () {
                            ref
                                    .read(
                                      exploreResultsExpandedProvider.notifier,
                                    )
                                    .state =
                                !isExpanded;
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            isExpanded ? 'Show less' : 'See all',
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.s16),

            // ========================================================
            // RESULTS LIST
            // ========================================================
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s24,
              ),
              child: filteredEvents.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Center(
                        child: Text(
                          'No events found for these filters',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.55),
                          ),
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        ...displayEvents.map(
                          (event) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: 12,
                              ),
                              child: _ResultCardItem(
                                day: DateFormat('dd').format(event.startDate),
                                month: DateFormat(
                                  'MMM',
                                ).format(event.startDate).toUpperCase(),
                                title: event.title,
                                subtitle:
                                    '${DateFormat('EEE').format(event.startDate)} • '
                                    '${event.isOnline ? 'Online' : 'Offline'} • '
                                    '${event.location}',
                                onTap: () {
                                  unawaited(
                                    context.push(
                                      '/events/${event.id}',
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),

                        // Bottom navigation spacing
                        const SizedBox(height: 120),
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }
}

// ====================================================================
// RESULT CARD
// ====================================================================

class _ResultCardItem extends StatefulWidget {
  const _ResultCardItem({
    required this.day,
    required this.month,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String day;
  final String month;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  State<_ResultCardItem> createState() => _ResultCardItemState();
}

class _ResultCardItemState extends State<_ResultCardItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

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
          end: 0.95,
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

  // ================================================================
  // PRESS ANIMATION
  // ================================================================

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  // ================================================================
  // BUILD CARD
  // ================================================================

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
              padding: const EdgeInsets.all(16),

              // ======================================================
              // CARD DECORATION
              // ======================================================
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF16152B) : Colors.white,

                borderRadius: BorderRadius.circular(16),

                border: Border.all(
                  color: isPressed
                      ? AppColors.primary
                      : isDark
                      ? const Color(0x3D3E63F5)
                      : Colors.grey.withValues(alpha: 0.3),
                  width: 1.2,
                ),

                boxShadow: isDark
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
              ),

              // ======================================================
              // CARD CONTENT
              // ======================================================
              child: Row(
                children: [
                  // ====================================================
                  // DATE BOX
                  // ====================================================
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF231E3D)
                          : Colors.purple.shade100.withValues(alpha: 0.5),

                      borderRadius: BorderRadius.circular(12),

                      border: Border.all(
                        color: isDark
                            ? AppColors.primary.withValues(alpha: 0.3)
                            : Colors.purple.shade200,
                      ),
                    ),

                    child: Column(
                      children: [
                        Text(
                          widget.day,
                          style: TextStyle(
                            color: isDark
                                ? const Color(0xFFC084FC)
                                : Colors.deepPurple,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),

                        Text(
                          widget.month,
                          style: TextStyle(
                            color: isDark
                                ? const Color(0xFFC084FC)
                                : Colors.deepPurple,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  // ====================================================
                  // EVENT INFORMATION
                  // ====================================================
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          widget.subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.6)
                                : Colors.grey.shade500,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // ====================================================
                  // ARROW
                  // ====================================================
                  Icon(
                    Icons.chevron_right,
                    color: isDark ? Colors.white54 : Colors.grey,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
