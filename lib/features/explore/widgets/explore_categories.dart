import 'package:ai_nexus/core/theme/app_colors.dart';
import 'package:ai_nexus/core/theme/app_spacing.dart';
import 'package:ai_nexus/features/explore/providers/explore_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExploreCategories extends ConsumerWidget {
  const ExploreCategories({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(exploreCategoryProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.s24),
          child: Text(
            'Categories',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s16),
        SizedBox(
          height: 140,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
            children: [
              _CategoryCardItem(
                title: 'Conferences',
                events: '315 Events',
                icon: Icons.groups_outlined,
                iconBgColor: Colors.pink.shade100,
                iconColor: Colors.pink,
                isSelected: selectedCategory == 'Conferences',
                onTap: () => _handleTap(ref, 'Conferences', selectedCategory),
              ),
              _CategoryCardItem(
                title: 'Workshop',
                events: '215 events',
                icon: Icons.auto_awesome_outlined,
                iconBgColor: Colors.cyan.shade100,
                iconColor: Colors.cyan,
                isSelected: selectedCategory == 'Workshop',
                onTap: () => _handleTap(ref, 'Workshop', selectedCategory),
              ),
              _CategoryCardItem(
                title: 'Hackathons',
                events: '154 events',
                icon: Icons.hourglass_empty_outlined,
                iconBgColor: Colors.orange.shade100,
                iconColor: Colors.orange,
                isSelected: selectedCategory == 'Hackathons',
                onTap: () => _handleTap(ref, 'Hackathons', selectedCategory),
              ),
              _CategoryCardItem(
                title: 'Webinars',
                events: '123 events',
                icon: Icons.record_voice_over_outlined,
                iconBgColor: Colors.purple.shade100,
                iconColor: Colors.purple,
                isSelected: selectedCategory == 'Webinars',
                onTap: () => _handleTap(ref, 'Webinars', selectedCategory),
              ),
              _CategoryCardItem(
                title: 'Networking',
                events: '21 events',
                icon: Icons.handshake_outlined,
                iconBgColor: Colors.green.shade100,
                iconColor: Colors.green,
                isSelected: selectedCategory == 'Networking',
                onTap: () => _handleTap(ref, 'Networking', selectedCategory),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _handleTap(WidgetRef ref, String title, String? current) {
    if (current == title) {
      ref.read(exploreCategoryProvider.notifier).state = null; // deselect
    } else {
      ref.read(exploreCategoryProvider.notifier).state = title;
    }
  }
}

class _CategoryCardItem extends StatefulWidget {
  const _CategoryCardItem({
    required this.title,
    required this.events,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String events;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_CategoryCardItem> createState() => _CategoryCardItemState();
}

class _CategoryCardItemState extends State<_CategoryCardItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
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
    return GestureDetector(
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
              width: 120,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: widget.isSelected ? const LinearGradient(
                  colors: [Colors.blue, Colors.lightBlueAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ) : null,
                color: widget.isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.isSelected 
                      ? Colors.transparent 
                      : isPressed 
                          ? AppColors.primary.withOpacity(0.45) 
                          : Colors.grey.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: widget.iconBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(widget.icon, color: widget.iconColor, size: 24),
                  ),
                  const Spacer(),
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: widget.isSelected ? Colors.white : Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.events,
                    style: TextStyle(
                      fontSize: 13,
                      color: widget.isSelected ? Colors.white.withOpacity(0.9) : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
