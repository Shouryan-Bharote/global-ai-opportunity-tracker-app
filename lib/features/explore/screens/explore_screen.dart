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

      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: 120,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==========================================
              // SEARCH BAR
              // ==========================================
              ExploreSearchBar(),

              SizedBox(
                height: AppSpacing.s24,
              ),

              // ==========================================
              // FILTER CHIPS
              // ==========================================
              ExploreFilterChips(),

              SizedBox(
                height: AppSpacing.s32,
              ),

              // ==========================================
              // CATEGORIES
              // ==========================================
              ExploreCategories(),

              SizedBox(
                height: AppSpacing.s32,
              ),

              // ==========================================
              // POPULAR CITIES
              // ==========================================
              PopularCities(),

              SizedBox(
                height: AppSpacing.s32,
              ),

              // ==========================================
              // SEARCH RESULTS
              // ==========================================
              ExploreResults(),

              SizedBox(
                height: AppSpacing.s24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
