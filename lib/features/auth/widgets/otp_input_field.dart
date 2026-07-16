import 'package:ai_nexus/core/theme/app_colors.dart';
import 'package:ai_nexus/core/theme/app_radius.dart';
import 'package:ai_nexus/core/theme/app_spacing.dart';
import 'package:ai_nexus/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class OtpInputField extends HookWidget {
  const OtpInputField({
    required this.length,
    required this.onCompleted,
    super.key,
  });

  final int length;
  final ValueChanged<String> onCompleted;

  @override
  Widget build(BuildContext context) {
    final controllers = List.generate(length, (_) => useTextEditingController());
    final focusNodes = List.generate(length, (_) => useFocusNode());

    void onChanged(String value, int index) {
      if (value.isNotEmpty) {
        if (index < length - 1) {
          focusNodes[index + 1].requestFocus();
        } else {
          focusNodes[index].unfocus();
          final otp = controllers.map((c) => c.text).join();
          if (otp.length == length) {
            onCompleted(otp);
          }
        }
      } else if (value.isEmpty && index > 0) {
        focusNodes[index - 1].requestFocus();
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(length, (index) {
        return SizedBox(
          width: 50,
          height: 60,
          child: TextFormField(
            controller: controllers[index],
            focusNode: focusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            style: AppTypography.textTheme.headlineMedium?.copyWith(
              color: AppColors.textPrimary,
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: AppColors.inputBackground,
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.medium),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.medium),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.medium),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
            onChanged: (value) => onChanged(value, index),
          ),
        );
      }),
    );
  }
}
