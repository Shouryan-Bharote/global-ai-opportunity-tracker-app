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
    final filteredOpportunitiesAsync = ref.watch(exploreFilteredOpportunitiesProvider);
    final isExpanded = ref.watch(exploreResultsExpandedProvider);

    return filteredOpportunitiesAsync.when(
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 12),
              Text(
                'Unable to load opportunities.\n$e',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ),
        ),
      ),

      // ============================================================
      // DATA
      // ============================================================
      data: (filteredOpportunities) {
        final displayOpportunities = isExpanded || filteredOpportunities.length <= 2
            ? filteredOpportunities
            : filteredOpportunities.take(2).toList();

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
                    'Opportunities (${filteredOpportunities.length})',
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
                      if (filteredOpportunities.length > 2)
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
              child: filteredOpportunities.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Center(
                        child: Text(
                          'No opportunities found for these filters',
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
                        ...displayOpportunities.map(
                          (opp) {
                            final displayDate = opp.deadline ?? opp.createdAt;
                            final formattedDay = DateFormat('dd').format(displayDate);
                            final formattedMonth =
                                DateFormat('MMM').format(displayDate).toUpperCase();
                            final subtitle =
                                '${opp.opportunityType} • ${opp.locationType} • ${opp.displayOrganizer}';

                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: 12,
                              ),
                              child: _ResultCardItem(
                                day: formattedDay,
                                month: formattedMonth,
                                title: opp.title,
                                subtitle: subtitle,
                                isDeadline: opp.deadline != null,
                                onTap: () {
                                  context.push('/opportunities/${opp.id}');
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
    this.isDeadline = true,
  });

  final String day;
  final String month;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDeadline;

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

    _scaleAnimation = Tween<double>(
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
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isPressed
                      ? AppColors.primary.withValues(alpha: 0.45)
                      : isDark
                          ? const Color(0xFF444444)
                          : Colors.grey.withValues(alpha: 0.3),
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
              child: Row(
                children: [
                  // ====================================================
                  // DATE / DEADLINE BOX
                  // ====================================================
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF30243D)
                          : Colors.purple.shade100.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? Colors.deepPurple.shade300.withValues(alpha: 0.5)
                            : Colors.purple.shade200,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          widget.day,
                          style: TextStyle(
                            color: isDark
                                ? Colors.purple.shade200
                                : Colors.deepPurple,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                        Text(
                          widget.month,
                          style: TextStyle(
                            color: isDark
                                ? Colors.purple.shade200
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
                  // OPPORTUNITY INFORMATION
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
