import 'package:ai_nexus/core/theme/app_colors.dart';
import 'package:ai_nexus/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

class CategoryChips extends StatelessWidget {
  const CategoryChips({
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
    super.key,
  });

  final List<CategoryChipData> categories;
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unselectedBg = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    final unselectedBorder = isDark ? const Color(0xFF3A3A3A) : AppColors.border;
    final unselectedText = isDark ? Colors.white70 : AppColors.textPrimary;

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category.label == selectedCategory;

          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.s8),
            child: GestureDetector(
              onTap: () => onCategorySelected(category.label),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [Colors.blue, Colors.lightBlueAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isSelected ? null : unselectedBg,
                  borderRadius: BorderRadius.circular(20),
                  border: isSelected
                      ? null
                      : Border.all(color: unselectedBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (category.icon != null) ...[
                      Icon(
                        category.icon,
                        size: 16,
                        color: isSelected ? Colors.white : unselectedText,
                      ),
                      const SizedBox(width: AppSpacing.s8),
                    ],
                    Text(
                      category.label,
                      style: TextStyle(
                        color: isSelected ? Colors.white : unselectedText,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class CategoryChipData {
  const CategoryChipData({
    required this.label,
    this.icon,
  });

  final String label;
  final IconData? icon;
}
