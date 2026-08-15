import 'package:ai_nexus/core/theme/app_colors.dart';
import 'package:ai_nexus/core/theme/app_spacing.dart';
import 'package:ai_nexus/features/explore/providers/explore_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExploreCategories extends ConsumerWidget {
  const ExploreCategories({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(exploreCategoryProvider);

    // Get current theme colors
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s24,
          ),
          child: Text(
            'Categories',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.s16),

        SizedBox(
          height: 140,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s24,
            ),
            children: [
              _CategoryCardItem(
                title: 'Conferences',
                events: '315 Events',
                icon: Icons.groups_outlined,
                iconBgColor: Colors.pink.shade100,
                iconColor: Colors.pink,
                isSelected: selectedCategory == 'Conferences',
                isDark: isDark,
                onTap: () => _handleTap(ref, 'Conferences', selectedCategory),
              ),

              _CategoryCardItem(
                title: 'Workshop',
                events: '215 events',
                icon: Icons.auto_awesome_outlined,
                iconBgColor: Colors.cyan.shade100,
                iconColor: Colors.cyan,
                isSelected: selectedCategory == 'Workshop',
                isDark: isDark,
                onTap: () => _handleTap(ref, 'Workshop', selectedCategory),
              ),

              _CategoryCardItem(
                title: 'Hackathons',
                events: '154 events',
                icon: Icons.hourglass_empty_outlined,
                iconBgColor: Colors.orange.shade100,
                iconColor: Colors.orange,
                isSelected: selectedCategory == 'Hackathons',
                isDark: isDark,
                onTap: () => _handleTap(ref, 'Hackathons', selectedCategory),
              ),

              _CategoryCardItem(
                title: 'Webinars',
                events: '123 events',
                icon: Icons.record_voice_over_outlined,
                iconBgColor: Colors.purple.shade100,
                iconColor: Colors.purple,
                isSelected: selectedCategory == 'Webinars',
                isDark: isDark,
                onTap: () => _handleTap(ref, 'Webinars', selectedCategory),
              ),

              _CategoryCardItem(
                title: 'Networking',
                events: '21 events',
                icon: Icons.handshake_outlined,
                iconBgColor: Colors.green.shade100,
                iconColor: Colors.green,
                isSelected: selectedCategory == 'Networking',
                isDark: isDark,
                onTap: () => _handleTap(ref, 'Networking', selectedCategory),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _handleTap(
    WidgetRef ref,
    String title,
    String? current,
  ) {
    if (current == title) {
      // Deselect
      ref.read(exploreCategoryProvider.notifier).state = null;
    } else {
      // Select
      ref.read(exploreCategoryProvider.notifier).state = title;
    }
  }
}

// ============================================================
// CATEGORY CARD
// ============================================================

class _CategoryCardItem extends StatefulWidget {
  const _CategoryCardItem({
    required this.title,
    required this.events,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  final String title;
  final String events;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  State<_CategoryCardItem> createState() => _CategoryCardItemState();
}

class _CategoryCardItemState extends State<_CategoryCardItem>
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
    final theme = Theme.of(context);

    // Card background changes automatically
    final cardColor = widget.isSelected
        ? null
        : widget.isDark
        ? const Color(0xFF1E1E1E)
        : Colors.white;

    // Text colors change automatically
    final titleColor = widget.isSelected
        ? Colors.white
        : theme.colorScheme.onSurface;

    final eventColor = widget.isSelected
        ? Colors.white.withValues(alpha: 0.9)
        : widget.isDark
        ? Colors.grey.shade400
        : Colors.grey.shade600;

    // Border changes automatically
    final borderColor = widget.isSelected
        ? Colors.transparent
        : Colors.grey.withValues(
            alpha: widget.isDark ? 0.25 : 0.3,
          );

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
              width: 120,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(12),

              decoration: BoxDecoration(
                // Selected = blue gradient
                // Unselected = theme-aware background
                gradient: widget.isSelected
                    ? const LinearGradient(
                        colors: [
                          Colors.blue,
                          Colors.lightBlueAccent,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,

                color: cardColor,

                borderRadius: BorderRadius.circular(16),

                border: Border.all(
                  color: widget.isSelected
                      ? Colors.transparent
                      : isPressed
                      ? AppColors.primary.withValues(
                          alpha: 0.45,
                        )
                      : borderColor,
                  width: 1.5,
                ),

                boxShadow: widget.isDark && !widget.isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: 0.25,
                          ),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  // Icon background
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: widget.iconBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.icon,
                      color: widget.iconColor,
                      size: 24,
                    ),
                  ),

                  const Spacer(),

                  // Category title
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: titleColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 2),

                  // Event count
                  Text(
                    widget.events,
                    style: TextStyle(
                      fontSize: 13,
                      color: eventColor,
                    ),
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
