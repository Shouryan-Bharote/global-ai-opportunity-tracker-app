import 'package:ai_nexus/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CustomNavBar extends StatelessWidget {
  const CustomNavBar({
    required this.selectedIndex,
    required this.onDestinationSelected,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF16152B) : const Color(0xFF18181B),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isDarkMode
              ? const Color(0x3D3E63F5)
              : AppColors.primary.withValues(alpha: 0.15),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.25 : 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavBarItem(
            icon: Icons.home_rounded,
            label: 'Home',
            selected: selectedIndex == 0,
            isDarkMode: isDarkMode,
            onTap: () => onDestinationSelected(0),
          ),
          _NavBarItem(
            icon: Icons.explore_rounded,
            label: 'Explore',
            selected: selectedIndex == 1,
            isDarkMode: isDarkMode,
            onTap: () => onDestinationSelected(1),
          ),
          _NavBarItem(
            icon: Icons.calendar_today_rounded,
            label: 'Schedule',
            selected: selectedIndex == 2,
            isDarkMode: isDarkMode,
            onTap: () => onDestinationSelected(2),
          ),
          _NavBarItem(
            icon: Icons.person_rounded,
            label: 'Profile',
            selected: selectedIndex == 3,
            isDarkMode: isDarkMode,
            onTap: () => onDestinationSelected(3),
          ),
        ],
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.isDarkMode,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final bool isDarkMode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final activeColor =
        isDarkMode ? const Color(0xFF7095FF) : const Color(0xFF3E63F5);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                gradient: selected
                    ? const LinearGradient(
                        colors: [Color(0xFF3E63F5), Color(0xFF5D7BFF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: selected ? null : Colors.transparent,
                shape: BoxShape.circle,
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                icon,
                color: selected ? Colors.white : Colors.white54,
                size: 24,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 11,
                color: selected ? activeColor : Colors.white60,
                fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                fontFamily: 'Inter',
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
