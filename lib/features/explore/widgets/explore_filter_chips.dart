import 'package:ai_nexus/core/theme/app_spacing.dart';
import 'package:ai_nexus/features/explore/providers/explore_provider.dart';
import 'package:ai_nexus/features/explore/widgets/animated_filter_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExploreFilterChips extends ConsumerWidget {
  const ExploreFilterChips({super.key});

  static const List<String> _filters = [
    'All',
    'This Week',
    'Online',
    'Offline',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilter = ref.watch(exploreFilterProvider);

    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s24,
        ),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = filter == selectedFilter;

          return AnimatedFilterChip(
            label: filter,
            isSelected: isSelected,
            onTap: () {
              ref.read(exploreFilterProvider.notifier).state = filter;
            },
          );
        },
      ),
    );
  }
}
