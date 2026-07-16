import 'package:ai_nexus/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CustomNavBar extends StatelessWidget {
  const CustomNavBar({required this.selectedIndex, required this.onDestinationSelected, super.key});
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.fromLTRB(30, 0, 30, 20),
        height: 79,
        padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 7),
        decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(31)),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _NavBarItem(icon: Icons.home_outlined, label: 'Home', selected: selectedIndex == 0, onTap: () => onDestinationSelected(0)),
          _NavBarItem(icon: Icons.search_rounded, label: 'Explore', selected: selectedIndex == 1, onTap: () => onDestinationSelected(1)),
          _NavBarItem(icon: Icons.calendar_today_outlined, label: 'Schedule', selected: selectedIndex == 2, onTap: () => onDestinationSelected(2)),
          _NavBarItem(icon: Icons.person_outline_rounded, label: 'Profile', selected: selectedIndex == 3, onTap: () => onDestinationSelected(3)),
        ]),
      );
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({required this.icon, required this.label, required this.selected, required this.onTap, super.key});
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: SizedBox(width: 56, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          AnimatedContainer(duration: const Duration(milliseconds: 180), padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: selected ? const Color(0xFF258CF1) : Colors.transparent, shape: BoxShape.circle, boxShadow: selected ? [BoxShadow(color: AppColors.primary.withOpacity(.32), blurRadius: 12, spreadRadius: 5)] : null), child: Icon(icon, color: selected ? Colors.white : Colors.white54, size: 25)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 10, color: selected ? const Color(0xFF258CF1) : Colors.white70, fontWeight: selected ? FontWeight.w500 : FontWeight.w400)),
        ])),
      );
}
