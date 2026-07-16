import 'package:ai_nexus/core/theme/app_colors.dart';
import 'package:ai_nexus/core/theme/app_spacing.dart';
import 'package:ai_nexus/features/auth/widgets/custom_text_field.dart';
import 'package:ai_nexus/features/auth/widgets/primary_button.dart';
import 'package:ai_nexus/features/auth/widgets/step_indicator.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: AppSpacing.s24),
              const StepIndicator(totalSteps: 3, currentStep: 1),
              const SizedBox(height: AppSpacing.s48),
              
              // Icon Placeholder
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.stepIndicatorInactive,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.mail_outline, size: 40, color: AppColors.primary),
              ),
              const SizedBox(height: AppSpacing.s32),
              
              Text(
                'Forget Password',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.s16),
              
              Text(
                'It was popularised in the 1960s with the release of Letraset sheetscontaining Lorem Ipsum.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.s32),
              
              const CustomTextField(
                hintText: 'Email I\'D/ Mobile Number',
              ),
              const SizedBox(height: AppSpacing.s32),
              
              PrimaryButton(
                text: 'Continue',
                onPressed: () {
                  context.push('/otp');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
