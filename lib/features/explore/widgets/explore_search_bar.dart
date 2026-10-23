import 'dart:async';

import 'package:ai_nexus/core/theme/app_colors.dart';
import 'package:ai_nexus/features/explore/providers/explore_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExploreSearchBar extends ConsumerStatefulWidget {
  const ExploreSearchBar({super.key});

  @override
  ConsumerState<ExploreSearchBar> createState() => _ExploreSearchBarState();
}

class _ExploreSearchBarState extends ConsumerState<ExploreSearchBar>
    with SingleTickerProviderStateMixin {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _textController = TextEditingController();

  bool _isFocused = false;
  bool _hasText = false;

  // Debounce timer — fires the provider update 300ms after the user stops typing.
  Timer? _debounce;

  late final AnimationController _micController;
  late final Animation<double> _micScale;

  @override
  void initState() {
    super.initState();

    _micController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );

    _micScale = Tween<double>(
      begin: 1,
      end: 0.88,
    ).animate(
      CurvedAnimation(
        parent: _micController,
        curve: Curves.easeInOut,
      ),
    );

    _focusNode.addListener(() {
      if (mounted) {
        setState(() => _isFocused = _focusNode.hasFocus);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final initialQuery = ref.read(exploreSearchQueryProvider);
      if (initialQuery.isNotEmpty) {
        _textController.text = initialQuery;
        setState(() => _hasText = true);
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _focusNode.dispose();
    _textController.dispose();
    _micController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _debounce?.cancel();
    _textController.clear();
    ref.read(exploreSearchQueryProvider.notifier).state = '';
    setState(() => _hasText = false);
    _focusNode.requestFocus();
  }

  void _onChanged(String value) {
    // Update clear-button visibility immediately so it feels responsive.
    setState(() => _hasText = value.isNotEmpty);

    // Debounce: only push to the provider after 300ms of quiet typing.
    // This prevents the filtered-events list from recomputing on every keystroke.
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        ref.read(exploreSearchQueryProvider.notifier).state = value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // All colours derived from the active theme — update instantly on switch.
    final searchBackground = isDark ? const Color(0xFF16152B) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final hintColor = Colors.grey.shade400;
    final clearButtonColor =
        isDark ? const Color(0xFF231E3D) : Colors.grey.shade200;
    final clearIconColor =
        isDark ? Colors.grey.shade300 : Colors.grey.shade600;

    return AnimatedContainer(
      // Only animates when _isFocused changes (margin squeeze + border/shadow).
      // Keyed on _isFocused so typing (_hasText changes) does NOT retrigger it.
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,

      margin: EdgeInsets.symmetric(
        horizontal: _isFocused ? 16 : 24,
        vertical: 4,
      ),

      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),

      decoration: BoxDecoration(
        color: searchBackground,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: _isFocused
              ? AppColors.primary
              : (isDark ? const Color(0x3D3E63F5) : AppColors.border),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: _isFocused
                ? AppColors.primary.withValues(alpha: 0.14)
                : Colors.black.withValues(alpha: isDark ? 0.25 : 0.07),
            blurRadius: _isFocused ? 22 : 14,
            offset: Offset(0, _isFocused ? 8 : 4),
            spreadRadius: _isFocused ? 2 : 0,
          ),
        ],
      ),

      child: Row(
        children: [
          // ─── Search icon ─────────────────────────────────────────────
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Icon(
              Icons.search_rounded,
              key: ValueKey(_isFocused),
              color: _isFocused ? AppColors.primary : Colors.grey.shade400,
              size: 24,
            ),
          ),

          const SizedBox(width: 12),

          // ─── Text field ──────────────────────────────────────────────
          Expanded(
            child: TextField(
              controller: _textController,
              focusNode: _focusNode,
              onChanged: _onChanged,

              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),

              cursorColor: AppColors.primary,

              decoration: InputDecoration(
                hintText: 'Search here...',
                hintStyle: TextStyle(
                  color: hintColor,
                  fontSize: 15,
                  fontWeight: FontWeight.normal,
                ),

                // CRITICAL FIX: disable theme-level fill.
                // AppTheme sets inputDecorationTheme.filled = true with a
                // coloured fillColor. Without explicitly setting filled:false
                // here, the TextField renders its own background rectangle
                // (white in light mode, dark-surface in dark mode) INSIDE our
                // already-coloured pill container, creating a visible box.
                filled: false,
                fillColor: Colors.transparent,

                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,

                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),

          // ─── Clear button ─────────────────────────────────────────────
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, anim) => ScaleTransition(
              scale: anim,
              child: FadeTransition(opacity: anim, child: child),
            ),
            child: _hasText
                ? GestureDetector(
                    key: const ValueKey('clear'),
                    onTap: _clearSearch,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: clearButtonColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 13,
                        color: clearIconColor,
                      ),
                    ),
                  )
                : const SizedBox.shrink(key: ValueKey('no-clear')),
          ),

          // ─── Mic button ───────────────────────────────────────────────
          GestureDetector(
            onTapDown: (_) => _micController.forward(),
            onTapUp: (_) => _micController.reverse(),
            onTapCancel: () => _micController.reverse(),
            onTap: _focusNode.requestFocus,

            child: ScaleTransition(
              scale: _micScale,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: _isFocused
                      ? LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withValues(alpha: 0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: _isFocused
                      ? null
                      : AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: _isFocused
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Icon(
                  Icons.mic_rounded,
                  color: _isFocused ? Colors.white : AppColors.primary,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
