import 'package:ai_nexus/core/theme/app_colors.dart';
import 'package:ai_nexus/core/theme/app_spacing.dart';
import 'package:ai_nexus/features/explore/providers/explore_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PopularCities extends ConsumerWidget {
  const PopularCities({super.key});

  static const List<String> _cities = [
    'San Francisco',
    'Toronto',
    'Singapore',
    'India',
    'New York',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCity = ref.watch(exploreCityProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s24,
          ),
          child: Text(
            'Popular Cities',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1D273F),
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.s16),

        SizedBox(
          height: 48,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s24,
            ),
            itemCount: _cities.length,
            itemBuilder: (context, index) {
              final city = _cities[index];
              final isSelected = city == selectedCity;

              return _CityChipItem(
                city: city,
                isSelected: isSelected,
                onTap: () {
                  if (selectedCity == city) {
                    ref.read(exploreCityProvider.notifier).state = null;
                  } else {
                    ref.read(exploreCityProvider.notifier).state = city;
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CityChipItem extends StatefulWidget {
  const _CityChipItem({
    required this.city,
    required this.isSelected,
    required this.onTap,
  });

  final String city;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_CityChipItem> createState() => _CityChipItemState();
}

class _CityChipItemState extends State<_CityChipItem>
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
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

                  // Normal chip background
                  color: widget.isSelected
                      ? null
                      : isDark
                      ? const Color(0xFF16152B)
                      : Colors.white,

                  borderRadius: BorderRadius.circular(24),

                  border: Border.all(
                    color: widget.isSelected
                        ? Colors.transparent
                        : isPressed
                        ? AppColors.primary.withValues(alpha: 0.45)
                        : isDark
                        ? const Color(0x3D3E63F5)
                        : Colors.grey.withValues(alpha: 0.3),
                    width: 1.2,
                  ),

                  boxShadow: widget.isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),

                child: Center(
                  child: Text(
                    widget.city,
                    style: TextStyle(
                      color: widget.isSelected
                          ? Colors.white
                          : isDark
                          ? Colors.white70
                          : Colors.black87,
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
