import 'package:ai_nexus/core/theme/app_colors.dart';
import 'package:ai_nexus/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

class StepIndicator extends StatelessWidget {
  const StepIndicator({
    required this.totalSteps,
    required this.currentStep,
    super.key,
  });

  final int totalSteps;
  final int currentStep; // 1-indexed

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        final isActive = (index + 1) == currentStep;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.s4),
          width: isActive ? 24 : 24,
          height: 4,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.stepIndicatorInactive,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}
