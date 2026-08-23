import 'package:ai_nexus/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class ExploreCategoryCard extends StatefulWidget {
  const ExploreCategoryCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.backgroundColor,
    required this.onTap,
    this.isSelected = false,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color backgroundColor;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  State<ExploreCategoryCard> createState() => _ExploreCategoryCardState();
}

class _ExploreCategoryCardState extends State<ExploreCategoryCard>
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
    _scaleAnimation = Tween<double>(begin: 1, end: 0.92).animate(
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
    final titleColor = widget.isSelected
        ? AppColors.primary
        : (isDark ? Colors.white : AppColors.textPrimary);
    final subtitleColor = widget.isSelected
        ? AppColors.primary.withValues(alpha: 0.7)
        : (isDark ? Colors.white54 : AppColors.textSecondary);
    final iconColor = widget.isSelected
        ? AppColors.primary
        : (isDark ? Colors.white70 : AppColors.textPrimary);

    return Padding(
      padding: const EdgeInsets.only(right: 20),
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
                width: 140,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: (widget.isSelected || isPressed)
                        ? AppColors.primary.withValues(alpha: 0.55)
                        : borderColor.withValues(alpha: 0.6),
                    width: 1.5,
                  ),
                  boxShadow: isDark
                      ? null
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        // Slightly adjust icon background in dark
                        color: isDark
                            ? widget.backgroundColor.withValues(alpha: 0.25)
                            : widget.backgroundColor,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        widget.icon,
                        size: 32,
                        color: iconColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: widget.isSelected
                                ? FontWeight.w800
                                : FontWeight.bold,
                            color: titleColor,
                            fontSize: 16,
                          ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: subtitleColor,
                            fontSize: 13,
                          ),
                      textAlign: TextAlign.center,
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
