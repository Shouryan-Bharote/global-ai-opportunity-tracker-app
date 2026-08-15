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

  late final AnimationController _micController;
  late final Animation<double> _micScale;

  @override
  void initState() {
    super.initState();

    _micController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );

    _micScale =
        Tween<double>(
          begin: 1,
          end: 0.88,
        ).animate(
          CurvedAnimation(
            parent: _micController,
            curve: Curves.easeInOut,
          ),
        );

    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final initialQuery = ref.read(exploreSearchQueryProvider);

      if (initialQuery.isNotEmpty) {
        _textController.text = initialQuery;
        setState(() => _hasText = true);
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _textController.dispose();
    _micController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _textController.clear();

    ref.read(exploreSearchQueryProvider.notifier).state = '';

    setState(() => _hasText = false);

    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    // Get colors from the current Flutter theme.
    // These automatically change when light/dark mode changes.
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isDark = theme.brightness == Brightness.dark;

    final searchBackground = isDark ? const Color(0xFF2A2A2A) : Colors.white;

    final textColor = isDark ? Colors.white : Colors.black87;

    final hintColor = isDark ? Colors.grey.shade400 : Colors.grey.shade400;

    final clearButtonColor = isDark
        ? const Color(0xFF444444)
        : Colors.grey.shade200;

    final clearIconColor = isDark ? Colors.grey.shade300 : Colors.grey.shade600;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,

      margin: EdgeInsets.symmetric(
        horizontal: _isFocused ? 16 : 24,
        vertical: 4,
      ),

      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),

      decoration: BoxDecoration(
        color: searchBackground,
        borderRadius: BorderRadius.circular(32),

        boxShadow: [
          BoxShadow(
            color: _isFocused
                ? AppColors.primary.withValues(alpha: 0.14)
                : Colors.black.withValues(
                    alpha: isDark ? 0.25 : 0.07,
                  ),
            blurRadius: _isFocused ? 22 : 14,
            offset: Offset(
              0,
              _isFocused ? 8 : 4,
            ),
            spreadRadius: _isFocused ? 2 : 0,
          ),
        ],
      ),

      child: Row(
        children: [
          // =========================
          // SEARCH ICON
          // =========================
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Icon(
              Icons.search_rounded,
              key: ValueKey(_isFocused),
              color: _isFocused
                  ? AppColors.primary
                  : isDark
                  ? Colors.grey.shade400
                  : Colors.grey.shade400,
              size: 24,
            ),
          ),

          const SizedBox(width: 12),

          // =========================
          // SEARCH TEXT FIELD
          // =========================
          Expanded(
            child: TextField(
              controller: _textController,
              focusNode: _focusNode,

              onChanged: (value) {
                ref.read(exploreSearchQueryProvider.notifier).state = value;

                setState(() {
                  _hasText = value.isNotEmpty;
                });
              },

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

                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,

                isDense: true,

                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                ),
              ),
            ),
          ),

          // =========================
          // CLEAR BUTTON
          // =========================
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),

            transitionBuilder: (child, anim) {
              return ScaleTransition(
                scale: anim,
                child: FadeTransition(
                  opacity: anim,
                  child: child,
                ),
              );
            },

            child: _hasText
                ? GestureDetector(
                    key: const ValueKey('clear'),

                    onTap: _clearSearch,

                    child: Container(
                      padding: const EdgeInsets.all(5),

                      margin: const EdgeInsets.only(
                        right: 8,
                      ),

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
                : const SizedBox.shrink(
                    key: ValueKey('no-clear'),
                  ),
          ),

          // =========================
          // MICROPHONE BUTTON
          // =========================
          GestureDetector(
            onTapDown: (_) {
              _micController.forward();
            },

            onTapUp: (_) {
              _micController.reverse();
            },

            onTapCancel: () {
              _micController.reverse();
            },

            onTap: () {
              // Voice search can be connected later.
              _focusNode.requestFocus();
            },

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
                            AppColors.primary.withValues(
                              alpha: 0.7,
                            ),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,

                  color: _isFocused
                      ? null
                      : AppColors.primary.withValues(
                          alpha: 0.1,
                        ),

                  borderRadius: BorderRadius.circular(14),

                  boxShadow: _isFocused
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(
                              alpha: 0.35,
                            ),
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
