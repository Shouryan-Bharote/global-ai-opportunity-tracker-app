import 'package:ai_nexus/core/theme/app_colors.dart';
import 'package:ai_nexus/core/theme/app_radius.dart';
import 'package:ai_nexus/core/theme/app_spacing.dart';
import 'package:ai_nexus/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
    required this.onPressed,
    this.isLoading = false,
    this.text = 'Continue with Google',
    super.key,
  });

  final VoidCallback? onPressed;
  final bool isLoading;
  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSpacing.s56,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.border, width: 1.2),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.large),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
        ),
        child: isLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: AppColors.primary,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const _GoogleGLogo(size: 22),
                  const SizedBox(width: AppSpacing.s12),
                  Text(
                    text,
                    style: AppTypography.button.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _GoogleGLogo extends StatelessWidget {
  const _GoogleGLogo({this.size = 24});
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GoogleGLogoPainter(),
      ),
    );
  }
}

class _GoogleGLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = w / 2;

    final redPaint = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.fill;
    final yellowPaint = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.fill;
    final greenPaint = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.fill;
    final bluePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;

    // Draw Google 4-color arcs
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Blue (Right arc + horizontal bar)
    final bluePath = Path()
      ..moveTo(center.dx, center.dy - radius * 0.22)
      ..lineTo(center.dx + radius * 0.98, center.dy - radius * 0.22)
      ..arcTo(rect, -0.22, 1.35, false)
      ..lineTo(center.dx, center.dy)
      ..close();
    canvas.drawPath(bluePath, bluePaint);

    // Green (Bottom arc)
    final greenPath = Path()
      ..arcTo(rect, 1.13, 1.25, false)
      ..lineTo(center.dx, center.dy)
      ..close();
    canvas.drawPath(greenPath, greenPaint);

    // Yellow (Bottom-left arc)
    final yellowPath = Path()
      ..arcTo(rect, 2.38, 1.25, false)
      ..lineTo(center.dx, center.dy)
      ..close();
    canvas.drawPath(yellowPath, yellowPaint);

    // Red (Top arc)
    final redPath = Path()
      ..arcTo(rect, 3.63, 1.5, false)
      ..lineTo(center.dx, center.dy)
      ..close();
    canvas.drawPath(redPath, redPaint);

    // Inner white cutout circle for the "G" ring hole
    final innerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.60, innerPaint);

    // Inner horizontal blue bar
    final barRect = Rect.fromLTRB(
      center.dx,
      center.dy - radius * 0.22,
      center.dx + radius * 0.95,
      center.dy + radius * 0.22,
    );
    canvas.drawRect(barRect, bluePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
