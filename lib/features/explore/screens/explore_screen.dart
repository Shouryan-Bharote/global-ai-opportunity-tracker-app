import 'package:ai_nexus/core/theme/app_spacing.dart';
import 'package:ai_nexus/features/explore/widgets/explore_categories.dart';
import 'package:ai_nexus/features/explore/widgets/explore_filter_chips.dart';
import 'package:ai_nexus/features/explore/widgets/explore_results.dart';
import 'package:ai_nexus/features/explore/widgets/explore_search_bar.dart';
import 'package:ai_nexus/features/explore/widgets/popular_cities.dart';
import 'package:flutter/material.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the current app theme.
    final theme = Theme.of(context);

    return Scaffold(
      // IMPORTANT:
      // This automatically changes between light and dark mode.
      backgroundColor: theme.scaffoldBackgroundColor,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            bottom: 120,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==========================================
              // SEARCH BAR
              // ==========================================
              const ExploreSearchBar(),

              const SizedBox(
                height: AppSpacing.s24,
              ),

              // ==========================================
              // FILTER CHIPS
              // ==========================================
              const ExploreFilterChips(),

              const SizedBox(
                height: AppSpacing.s32,
              ),

              // ==========================================
              // CATEGORIES
              // ==========================================
              const ExploreCategories(),

              const SizedBox(
                height: AppSpacing.s32,
              ),

              // ==========================================
              // POPULAR CITIES
              // ==========================================
              const PopularCities(),

              const SizedBox(
                height: AppSpacing.s32,
              ),

              // ==========================================
              // SEARCH RESULTS
              // ==========================================
              const ExploreResults(),

              const SizedBox(
                height: AppSpacing.s24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
