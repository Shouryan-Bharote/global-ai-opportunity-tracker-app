import 'package:ai_nexus/core/theme/app_spacing.dart';
import 'package:ai_nexus/features/explore/providers/explore_provider.dart';
import 'package:ai_nexus/features/explore/widgets/animated_filter_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PopularCities extends ConsumerWidget {
  const PopularCities({super.key});

  static const List<String> _cities = [
    'Online',
    'India',
    'United States',
    'Global',
    'Europe',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCity = ref.watch(exploreCityProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s24,
          ),
          child: Text(
            'Locations',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1D273F),
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.s16),

        SizedBox(
          height: 48,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s24,
            ),
            itemCount: _cities.length,
            itemBuilder: (context, index) {
              final city = _cities[index];
              final isSelected = city == selectedCity;

              return AnimatedFilterChip(
                label: city,
                isSelected: isSelected,
                onTap: () {
                  if (selectedCity == city) {
                    ref.read(exploreCityProvider.notifier).state = null;
                  } else {
                    ref.read(exploreCityProvider.notifier).state = city;
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
