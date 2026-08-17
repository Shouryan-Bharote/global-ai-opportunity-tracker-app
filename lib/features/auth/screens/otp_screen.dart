import 'dart:async';
import 'package:ai_nexus/core/theme/app_colors.dart';
import 'package:ai_nexus/core/theme/app_spacing.dart';
import 'package:ai_nexus/features/auth/widgets/otp_input_field.dart';
import 'package:ai_nexus/features/auth/widgets/primary_button.dart';
import 'package:ai_nexus/features/auth/widgets/step_indicator.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

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
            children: [
              const SizedBox(height: AppSpacing.s24),
              const StepIndicator(totalSteps: 3, currentStep: 2),
              const SizedBox(height: AppSpacing.s48),
              
              // Icon Placeholder
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.stepIndicatorInactive,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.mark_email_read_outlined, size: 40, color: AppColors.primary),
              ),
              const SizedBox(height: AppSpacing.s32),
              
              Text(
                'Enter OTP',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.s16),
              
              Text(
                'Enter the OTP code we just sent\nyou on your registered Email/Phone number',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.s32),
              
              OtpInputField(
                length: 5,
                onCompleted: (value) {
                  // handle OTP complete
                },
              ),
              const SizedBox(height: AppSpacing.s32),
              
              PrimaryButton(
                text: 'Reset Password',
                onPressed: () {
                  unawaited(context.push('/reset_password'));
                },
              ),
              const SizedBox(height: AppSpacing.s24),
              
              Row(
                children: [
                  Text(
                    "Didn't get OTP? ",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Handle resend
                    },
                    child: Text(
                      'Resend OTP',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
