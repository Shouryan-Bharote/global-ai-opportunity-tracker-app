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

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    widget.onTap();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF16152B) : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.large),
          border: Border.all(
            color: _isPressed
                ? AppColors.primary
                : (isDarkMode
                    ? const Color(0x3D3E63F5)
                    : AppColors.border.withValues(alpha: 0.6)),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            // Date Badge
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF231E3D) : const Color(0xFFF3E8FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDarkMode
                      ? AppColors.primary.withValues(alpha: 0.3)
                      : AppColors.accentPink.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.day,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? const Color(0xFFC084FC) : const Color(0xFF5D009B),
                      height: 1.1,
                    ),
                  ),
                  Text(
                    widget.month,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? const Color(0xFFC084FC) : const Color(0xFF5D009B),
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
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.grey.shade400 : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}
