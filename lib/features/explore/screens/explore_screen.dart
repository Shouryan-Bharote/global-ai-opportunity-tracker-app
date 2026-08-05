import 'package:ai_nexus/core/theme/app_colors.dart';
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
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            ExploreSearchBar(),
            SizedBox(height: AppSpacing.s24),
            
            // Filter Chips
            ExploreFilterChips(),
            SizedBox(height: AppSpacing.s32),
            
            // Categories
            ExploreCategories(),
            SizedBox(height: AppSpacing.s32),
            
            // Popular Cities
            PopularCities(),
            SizedBox(height: AppSpacing.s32),
            
            // Result list
            ExploreResults(),
          ],
        ),
      ),
    );
  }
}
