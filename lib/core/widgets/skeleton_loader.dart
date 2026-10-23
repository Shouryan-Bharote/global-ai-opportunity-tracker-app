import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// A single shimmer-animated placeholder bar/block.
class SkeletonLoader extends StatelessWidget {
  const SkeletonLoader({
    required this.width,
    required this.height,
    super.key,
    this.borderRadius = 16,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDarkMode ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDarkMode ? Colors.grey[700]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// A full event card-shaped skeleton shown while data is loading.
///
/// Fixes:
/// - Uses ClipRRect so the top-image shimmer never bleeds outside the
///   rounded card corners (was the source of the "white corner box" artifact).
/// - Removes the margin from the card itself so callers control spacing;
///   the extra margin was silently adding to the card's total height and
///   causing RenderFlex overflows inside constrained parents.
class EventSkeletonCard extends StatelessWidget {
  const EventSkeletonCard({
    super.key,
    this.width = double.infinity,
    this.height = 200,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDarkMode ? const Color(0xFF16152B) : Colors.white;
    final baseColor = isDarkMode ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDarkMode ? Colors.grey[700]! : Colors.grey[100]!;

    // Reserve exactly [height] pixels — no hidden margin.
    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        // Clip ALL children (including the image shimmer) to the card radius.
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image area ───────────────────────────────────────────
              Shimmer.fromColors(
                baseColor: baseColor,
                highlightColor: highlightColor,
                child: Container(
                  width: double.infinity,
                  height: height * 0.55,
                  color: baseColor,
                ),
              ),

              // ── Text lines ───────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title line
                      Shimmer.fromColors(
                        baseColor: baseColor,
                        highlightColor: highlightColor,
                        child: Container(
                          width: width == double.infinity ? 160 : width * 0.6,
                          height: 14,
                          decoration: BoxDecoration(
                            color: baseColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Subtitle / date line
                      Shimmer.fromColors(
                        baseColor: baseColor,
                        highlightColor: highlightColor,
                        child: Container(
                          width: width == double.infinity ? 100 : width * 0.4,
                          height: 11,
                          decoration: BoxDecoration(
                            color: baseColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
