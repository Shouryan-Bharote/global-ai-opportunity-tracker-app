import 'package:ai_nexus/core/theme/app_colors.dart';
import 'package:ai_nexus/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    required this.isDarkMode,
    required this.onThemeToggle,
    super.key,
  });

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
          // ── App Logo + Brand ──
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
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'AI Nexus',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1D273F),
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                'Opportunity Tracker',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF9A9AA8),
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),

          const Spacer(),

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
                        isDarkMode
                            ? Icons.nightlight_round
                            : Icons.wb_sunny,
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
