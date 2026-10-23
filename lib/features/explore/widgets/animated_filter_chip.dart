import 'package:ai_nexus/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AnimatedFilterChip extends StatefulWidget {
  const AnimatedFilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<AnimatedFilterChip> createState() => _AnimatedFilterChipState();
}

class _AnimatedFilterChipState extends State<AnimatedFilterChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );

    _scaleAnimation = Tween<double>(
      begin: 1,
      end: 0.95,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final unselectedBackground = isDarkMode
        ? const Color(0xFF16152B)
        : Colors.white;

    final unselectedText = isDarkMode ? Colors.white70 : Colors.black87;

    final unselectedBorder = isDarkMode
        ? const Color(0x3D3E63F5)
        : Colors.grey.withValues(alpha: 0.3);

    return Padding(
      padding: const EdgeInsets.only(right: 12),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: widget.isSelected
                      ? const LinearGradient(
                          colors: [
                            Colors.blue,
                            Colors.lightBlueAccent,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: widget.isSelected ? null : unselectedBackground,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: widget.isSelected
                        ? Colors.transparent
                        : isPressed
                            ? AppColors.primary.withValues(alpha: 0.45)
                            : unselectedBorder,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      color: widget.isSelected ? Colors.white : unselectedText,
                      fontWeight: widget.isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
