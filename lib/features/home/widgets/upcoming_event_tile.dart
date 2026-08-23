import 'package:ai_nexus/core/theme/app_colors.dart';
import 'package:ai_nexus/core/theme/app_radius.dart';
import 'package:flutter/material.dart';

class UpcomingEventTile extends StatefulWidget {
  const UpcomingEventTile({
    required this.day,
    required this.month,
    required this.title,
    required this.subtitle,
    required this.onTap,
    super.key,
  });

  final String day;
  final String month;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  State<UpcomingEventTile> createState() => _UpcomingEventTileState();
}

class _UpcomingEventTileState extends State<UpcomingEventTile> {
  bool _isPressed = false;

  void _onTapDown(TapDownDetails details) => setState(() => _isPressed = true);
  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    widget.onTap();
  }
  void _onTapCancel() => setState(() => _isPressed = false);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark ? const Color(0xFF3A3A3A) : AppColors.border;
    final titleColor = isDark ? Colors.white : AppColors.textPrimary;
    final subtitleColor = isDark ? Colors.white54 : AppColors.textSecondary;
    final chevronColor = isDark ? Colors.white38 : AppColors.textHint;

    // Date badge colors adapt: purple tint for both, but lighter in dark
    final dateBadgeBg = isDark ? const Color(0xFF2D1A4A) : const Color(0xFFF3E8FF);
    final dateBadgeBorder = isDark
        ? AppColors.accentPink.withValues(alpha: 0.25)
        : AppColors.accentPink.withValues(alpha: 0.3);
    final dateTextColor = isDark ? const Color(0xFFCB9EFF) : const Color(0xFF5D009B);

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(AppRadius.large),
          border: Border.all(
            color: _isPressed
                ? AppColors.primary.withValues(alpha: 0.5)
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
        child: Row(
          children: [
            // Date Badge
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: dateBadgeBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: dateBadgeBorder),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.day,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: dateTextColor,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    widget.month,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: dateTextColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: titleColor,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: subtitleColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: chevronColor),
          ],
        ),
      ),
    );
  }
}
