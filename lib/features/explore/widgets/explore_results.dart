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
      loading: () => const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, st) => Center(child: Text('Error: $e')),
      data: (filteredEvents) {
        // Limit to 2 events if not expanded
        final displayEvents = isExpanded || filteredEvents.length <= 2 
            ? filteredEvents 
            : filteredEvents.take(2).toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Result',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Map View is coming soon!'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        icon: const Icon(Icons.map_outlined, color: Colors.blue),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        style: IconButton.styleFrom(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (filteredEvents.length > 2)
                        TextButton(
                          onPressed: () {
                            ref.read(exploreResultsExpandedProvider.notifier).state = !isExpanded;
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            isExpanded ? 'Show less' : 'See all',
                            style: const TextStyle(
                              color: Colors.blue, // Blue link color from design
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
              child: filteredEvents.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Center(
                        child: Text(
                          'No events found for these filters',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        ...displayEvents.map((event) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _ResultCardItem(
                              day: DateFormat('dd').format(event.startDate),
                              month: DateFormat('MMM').format(event.startDate).toUpperCase(),
                              title: event.title,
                              subtitle: '${DateFormat('EEE').format(event.startDate)} . ${event.isOnline ? 'Online' : 'Offline'} . ${event.location}',
                              onTap: () {
                                context.push('/events/${event.id}');
                              },
                            ),
                          );
                        }),
                        const SizedBox(height: 120), // Bottom padding for navbar
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }
}

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

class _ResultCardItemState extends State<_ResultCardItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
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
    _controller.reverse();
    widget.onTap();
  }
  
  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
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
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isPressed 
                      ? AppColors.primary.withOpacity(0.45) 
                      : Colors.grey.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade100.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.purple.shade200),
                    ),
                    child: Column(
                      children: [
                        Text(
                          widget.day,
                          style: const TextStyle(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                        Text(
                          widget.month,
                          style: const TextStyle(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.subtitle,
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: Colors.grey,
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
