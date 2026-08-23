import 'package:ai_nexus/core/theme/app_colors.dart';
import 'package:ai_nexus/core/theme/app_spacing.dart';
import 'package:ai_nexus/features/explore/providers/explore_provider.dart';
import 'package:ai_nexus/features/opportunities/providers/opportunities_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExploreCategories extends ConsumerWidget {
  const ExploreCategories({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(exploreCategoryProvider);
    final opportunitiesAsync = ref.watch(opportunitiesProvider);
    final opportunities = opportunitiesAsync.valueOrNull ?? [];

    int countType(String type) {
      return opportunities
          .where((opp) => opp.opportunityType.toLowerCase() == type.toLowerCase())
          .length;
    }

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
                title: 'Hackathons',
                events: '${countType('Hackathon')} opportunities',
                icon: Icons.hourglass_empty_outlined,
                iconBgColor: Colors.orange.shade100,
                iconColor: Colors.orange,
                isSelected: selectedCategory == 'Hackathon',
                isDark: isDark,
                onTap: () => _handleTap(ref, 'Hackathon', selectedCategory),
              ),

              _CategoryCardItem(
                title: 'Competitions',
                events: '${countType('Competition')} opportunities',
                icon: Icons.emoji_events_outlined,
                iconBgColor: Colors.amber.shade100,
                iconColor: Colors.amber.shade800,
                isSelected: selectedCategory == 'Competition',
                isDark: isDark,
                onTap: () => _handleTap(ref, 'Competition', selectedCategory),
              ),

              _CategoryCardItem(
                title: 'Conferences',
                events: '${countType('Conference')} opportunities',
                icon: Icons.groups_outlined,
                iconBgColor: Colors.pink.shade100,
                iconColor: Colors.pink,
                isSelected: selectedCategory == 'Conference',
                isDark: isDark,
                onTap: () => _handleTap(ref, 'Conference', selectedCategory),
              ),

              _CategoryCardItem(
                title: 'Fellowships',
                events: '${countType('Fellowship')} opportunities',
                icon: Icons.school_outlined,
                iconBgColor: Colors.cyan.shade100,
                iconColor: Colors.cyan.shade800,
                isSelected: selectedCategory == 'Fellowship',
                isDark: isDark,
                onTap: () => _handleTap(ref, 'Fellowship', selectedCategory),
              ),

              _CategoryCardItem(
                title: 'Grants',
                events: '${countType('Grant')} opportunities',
                icon: Icons.monetization_on_outlined,
                iconBgColor: Colors.green.shade100,
                iconColor: Colors.green.shade800,
                isSelected: selectedCategory == 'Grant',
                isDark: isDark,
                onTap: () => _handleTap(ref, 'Grant', selectedCategory),
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
      ref.read(exploreCategoryProvider.notifier).state = null;
    } else {
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
              width: 140,
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? AppColors.primary
                    : (widget.isDark ? const Color(0xFF1E1E1E) : Colors.white),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isPressed || widget.isSelected
                      ? AppColors.primary
                      : widget.isDark
                          ? const Color(0xFF333333)
                          : Colors.grey.withValues(alpha: 0.2),
                  width: widget.isSelected ? 2 : 1,
                ),
                boxShadow: widget.isDark
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: widget.isSelected
                          ? Colors.white.withValues(alpha: 0.2)
                          : (widget.isDark
                              ? widget.iconColor.withValues(alpha: 0.15)
                              : widget.iconBgColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.icon,
                      color: widget.isSelected ? Colors.white : widget.iconColor,
                      size: 24,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: widget.isSelected
                              ? Colors.white
                              : (widget.isDark ? Colors.white : Colors.black87),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.events,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: widget.isSelected
                              ? Colors.white.withValues(alpha: 0.8)
                              : (widget.isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600),
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
}
