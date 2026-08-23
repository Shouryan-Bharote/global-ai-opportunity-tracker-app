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

  void _onTapDown(TapDownDetails details) => _controller.forward();
  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }
  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark ? const Color(0xFF3A3A3A) : AppColors.border;
    final titleColor = isDark ? Colors.white : AppColors.textPrimary;
    final subtitleColor =
        isDark ? Colors.white54 : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.s16),
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
                width: 240,
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(AppRadius.large),
                  border: Border.all(
                    color: isPressed
                        ? AppColors.primary.withValues(alpha: 0.45)
                        : borderColor.withValues(alpha: 0.6),
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
                    // Image / Gradient Header
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
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.tag,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),

                    // Content
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.s12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: titleColor,
                              fontSize: 15,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppSpacing.s8),
                          Row(
                            children: [
                              Icon(Icons.calendar_today,
                                  size: 14, color: subtitleColor),
                              const SizedBox(width: AppSpacing.s4),
                              Text(
                                widget.date,
                                style: TextStyle(
                                    fontSize: 12, color: subtitleColor),
                              ),
                              const SizedBox(width: AppSpacing.s8),
                              Icon(Icons.location_on,
                                  size: 14, color: subtitleColor),
                              const SizedBox(width: AppSpacing.s4),
                              Expanded(
                                child: Text(
                                  widget.location,
                                  style: TextStyle(
                                      fontSize: 12, color: subtitleColor),
                                  overflow: TextOverflow.ellipsis,
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
