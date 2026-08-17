import 'dart:async';
import 'package:ai_nexus/core/theme/app_colors.dart';
import 'package:ai_nexus/core/theme/app_spacing.dart';
import 'package:ai_nexus/core/theme/app_typography.dart';
import 'package:ai_nexus/features/auth/providers/auth_provider.dart';
import 'package:ai_nexus/features/auth/widgets/custom_text_field.dart';
import 'package:ai_nexus/features/auth/widgets/password_field.dart';
import 'package:ai_nexus/features/auth/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SignUpScreen extends HookConsumerWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final nameController = useTextEditingController();
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    
    final authState = ref.watch(authProvider);

    // Listen for auth success/error
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), backgroundColor: AppColors.error),
        );
      }
      if (next.isAuthenticated) {
        context.go('/home'); // Redirect to placeholder home
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.s40),
                Text(
                  'Create Account',
                  style: AppTypography.textTheme.headlineLarge,
                ),
                const SizedBox(height: AppSpacing.s8),
                Text(
                  'Sign up to get started',
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.s40),
                
                CustomTextField(
                  controller: nameController,
                  hintText: 'Full Name',
                  prefixIcon: Icons.person_outline,
                  validator: (val) => val == null || val.isEmpty ? 'Please enter your name' : null,
                ),
                const SizedBox(height: AppSpacing.s16),
                
                CustomTextField(
                  controller: emailController,
                  hintText: 'Email Address',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: (val) => val == null || val.isEmpty ? 'Please enter your email' : null,
                ),
                const SizedBox(height: AppSpacing.s16),
                
                PasswordField(
                  controller: passwordController,
                  hintText: 'Password',
                  validator: (val) => val == null || val.length < 6 ? 'Password must be at least 6 characters' : null,
                ),
                const SizedBox(height: AppSpacing.s40),
                
                PrimaryButton(
                  text: 'Sign Up',
                  isLoading: authState.isLoading,
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      unawaited(
                        ref.read(authProvider.notifier).register(
                          nameController.text,
                          emailController.text,
                          passwordController.text,
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.s24),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.go('/auth'),
                      child: Text(
                        'Sign In',
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
