import 'package:ai_nexus/core/theme/app_colors.dart';
import 'package:ai_nexus/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// Shared app header used across all main screens (Home, Explore, Schedule, Profile).
///
/// Displays the AI Nexus branding on the left and a dark/light theme toggle
/// on the right. The [subtitle] and [pageTitle] change per screen.
class AppHeader extends StatelessWidget {
  const AppHeader({
    required this.pageTitle,
    required this.isDarkMode,
    required this.onThemeToggle,
    this.subtitle,
    super.key,
  });

  /// The page-specific title displayed beneath the branding (e.g. "Home", "Explore").
  final String pageTitle;

  /// Optional small subtitle shown above the page title.
  final String? subtitle;

  final bool isDarkMode;
  final ValueChanged<bool> onThemeToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s24,
        vertical: 14,
      ),
      child: Row(
        children: [
          // ── App Logo ──
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentPurple.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'AI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // ── Page Title Column ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode
                          ? Colors.grey.shade400
                          : const Color(0xFF9A9AA8),
                      letterSpacing: 0.2,
                    ),
                  ),
                Text(
                  pageTitle,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: isDarkMode ? Colors.white : const Color(0xFF1D273F),
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),

          // ── Dark / Light Theme Toggle ──
          GestureDetector(
            onTap: () => onThemeToggle(!isDarkMode),
            child: Container(
              width: 56,
              height: 32,
              decoration: BoxDecoration(
                color: isDarkMode
                    ? const Color(0xFF2C2C2E)
                    : const Color(0xFFE5E5EA),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    left: isDarkMode ? 26 : 2,
                    top: 2,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        isDarkMode ? Icons.nightlight_round : Icons.wb_sunny,
                        color: isDarkMode ? Colors.indigo : Colors.orange,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
