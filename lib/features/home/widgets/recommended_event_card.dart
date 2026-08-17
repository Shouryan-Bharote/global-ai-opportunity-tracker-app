import 'package:ai_nexus/core/theme/app_colors.dart';
import 'package:ai_nexus/core/theme/app_radius.dart';
import 'package:ai_nexus/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

class RecommendedEventCard extends StatefulWidget {
  const RecommendedEventCard({
    required this.title,
    required this.tag,
    required this.date,
    required this.location,
    required this.gradientColors,
    required this.onTap,
    this.imageUrl,
    super.key,
  });

  final String title;
  final String tag;
  final String date;
  final String location;
  final List<Color> gradientColors;
  final VoidCallback onTap;
  final String? imageUrl;

  @override
  State<RecommendedEventCard> createState() => _RecommendedEventCardState();
}

class _RecommendedEventCardState extends State<RecommendedEventCard>
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
    _scaleAnimation = Tween<double>(begin: 1, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
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
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.s16),
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final isDarkMode = Theme.of(context).brightness == Brightness.dark;
            final isPressed = _controller.value > 0.3;
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: 240,
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF16152B) : Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.large),
                  border: Border.all(
                    color: isPressed
                        ? AppColors.primary
                        : (isDarkMode
                            ? const Color(0x3D3E63F5)
                            : AppColors.border.withValues(alpha: 0.6)),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDarkMode
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(AppRadius.large),
                          topRight: Radius.circular(AppRadius.large),
                        ),
                        gradient: widget.imageUrl == null
                            ? LinearGradient(
                                colors: widget.gradientColors,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        image: widget.imageUrl != null
                            ? DecorationImage(
                                image: NetworkImage(widget.imageUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      padding: const EdgeInsets.all(AppSpacing.s12),
                      alignment: Alignment.topLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? const Color(0xFF231E3D)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDarkMode
                                ? AppColors.primary.withValues(alpha: 0.3)
                                : Colors.transparent,
                          ),
                        ),
                        child: Text(
                          widget.tag,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode
                                ? const Color(0xFFC084FC)
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.s12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 18,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppSpacing.s8),
                          Row(
                            children: [
                              Icon(Icons.calendar_today,
                                  size: 16,
                                  color: isDarkMode
                                      ? Colors.grey.shade400
                                      : AppColors.textSecondary),
                              const SizedBox(width: AppSpacing.s4),
                              Text(
                                widget.date,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDarkMode
                                      ? Colors.grey.shade400
                                      : AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.s8),
                              Icon(Icons.location_on,
                                  size: 16,
                                  color: isDarkMode
                                      ? AppColors.secondary
                                      : AppColors.textSecondary),
                              const SizedBox(width: AppSpacing.s4),
                              Expanded(
                                child: Text(
                                  widget.location,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDarkMode
                                        ? Colors.grey.shade400
                                        : AppColors.textSecondary,
                                  ),
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
            );
          },
        ),
      ),
    );
  }
}
