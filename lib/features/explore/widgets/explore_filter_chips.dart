import 'package:ai_nexus/core/theme/app_colors.dart';
import 'package:ai_nexus/core/theme/app_spacing.dart';
import 'package:ai_nexus/features/explore/providers/explore_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExploreFilterChips extends ConsumerWidget {
  const ExploreFilterChips({super.key});

  static const List<String> _filters = [
    'All',
    'This Week',
    'Free',
    'Paid',
    'Offline',
    'Online',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilter = ref.watch(exploreFilterProvider);

    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s24,
        ),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = filter == selectedFilter;

          return _FilterChipItem(
            label: filter,
            isSelected: isSelected,
            onTap: () {
              ref.read(exploreFilterProvider.notifier).state = filter;
            },
          );
        },
      ),
    );
  }
}

class _FilterChipItem extends StatefulWidget {
  const _FilterChipItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_FilterChipItem> createState() => _FilterChipItemState();
}

class _FilterChipItemState extends State<_FilterChipItem>
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
    // Check whether the app is currently in dark mode.
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Colors for the unselected chip.
    final unselectedBackground = isDarkMode
        ? const Color(0xFF16152B)
        : Colors.white;

    final unselectedText = isDarkMode ? Colors.white70 : Colors.black87;

    final unselectedBorder = isDarkMode
        ? const Color(0x3D3E63F5)
        : Colors.grey.withValues(alpha: 0.3);

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  // Selected chip stays blue in both modes.
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

                  // Unselected chip changes with dark mode.
                  color: widget.isSelected ? null : unselectedBackground,

                  borderRadius: BorderRadius.circular(24),

                  border: Border.all(
                    color: widget.isSelected
                        ? Colors.transparent
                        : isPressed
                        ? AppColors.primary.withValues(
                            alpha: 0.45,
                          )
                        : unselectedBorder,
                    width: 1.5,
                  ),
                ),

                child: Center(
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      // Text changes with dark mode.
                      color: widget.isSelected ? Colors.white : unselectedText,

                      fontWeight: widget.isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,

                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
