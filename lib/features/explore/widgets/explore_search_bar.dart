import 'package:ai_nexus/core/theme/app_colors.dart';
import 'package:ai_nexus/features/explore/providers/explore_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExploreSearchBar extends ConsumerStatefulWidget {
  const ExploreSearchBar({super.key});

  @override
  ConsumerState<ExploreSearchBar> createState() => _ExploreSearchBarState();
}

class _ExploreSearchBarState extends ConsumerState<ExploreSearchBar> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _textController = TextEditingController();
  bool _isFocused = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final initialQuery = ref.read(exploreSearchQueryProvider);
      if (initialQuery.isNotEmpty) {
        _textController.text = initialQuery;
        setState(() {
          _hasText = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      // Expand dynamically when focused or has text, shrink when blank and unfocused
      margin: EdgeInsets.symmetric(horizontal: (_isFocused || _hasText) ? 16 : 40),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: (_isFocused || _hasText) ? 6 : 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: _isFocused ? AppColors.primary.withOpacity(0.5) : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _isFocused 
                ? AppColors.primary.withOpacity(0.15) 
                : Colors.black.withOpacity(0.06),
            blurRadius: _isFocused ? 20 : 12,
            offset: Offset(0, _isFocused ? 6 : 4),
            spreadRadius: _isFocused ? 1 : 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: _isFocused ? AppColors.primary : Colors.grey.shade400,
            size: 26,
          ),
          const SizedBox(width: 16),
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
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: 'Search for events, workshops...',
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 15,
                  fontWeight: FontWeight.normal,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          
          // Clear Button that dynamically pops in when typing
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
            child: _hasText
                ? GestureDetector(
                    key: const ValueKey('clearBtn'),
                    onTap: () {
                      _textController.clear();
                      ref.read(exploreSearchQueryProvider.notifier).state = '';
                      setState(() {
                        _hasText = false;
                      });
                      _focusNode.requestFocus();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, size: 14, color: Colors.grey.shade600),
                    ),
                  )
                : const SizedBox.shrink(key: ValueKey('empty')),
          ),

          // Decorative Mic Icon with Blue Gradient
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: _isFocused ? const LinearGradient(
                colors: [Colors.blue, Colors.lightBlueAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ) : null,
              color: _isFocused ? null : AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.mic_none_rounded,
              color: _isFocused ? Colors.white : AppColors.primary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
