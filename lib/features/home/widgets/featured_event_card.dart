import 'package:ai_nexus/core/theme/app_colors.dart';
import 'package:ai_nexus/core/theme/app_radius.dart';
import 'package:ai_nexus/core/theme/app_spacing.dart';
import 'package:ai_nexus/core/widgets/bounceable.dart';
import 'package:flutter/material.dart';

class FeaturedEventCard extends StatelessWidget {
  const FeaturedEventCard({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.location,
    required this.onRegister,
    this.imageUrl,
    this.isBookmarked = false,
    this.onBookmark,
    this.heroTag,
    super.key,
  });

  final String title;
  final String subtitle;
  final String date;
  final String location;
  final VoidCallback onRegister;
  final String? imageUrl;
  final bool isBookmarked;
  final VoidCallback? onBookmark;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    Widget cardContent = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s20,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF141326), // Deep aesthetic midnight surface
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
        image: imageUrl != null
            ? DecorationImage(
                image: NetworkImage(imageUrl!),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withValues(alpha: 0.65), // Aesthetic dark overlay
                  BlendMode.darken,
                ),
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Ambient Glow Circle (when no image provided)
          if (imageUrl == null)
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.6),
                      AppColors.accentPurple.withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Glassmorphic Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: AppColors.onlineIndicator,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Featured • Trending',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              
              SizedBox(
                width: 250,
                child: Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 15,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    date,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.location_on_rounded,
                    size: 15,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Bounceable(
                    onTap: onRegister,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Register',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Bounceable(
                    onTap: onBookmark ?? () {},
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isBookmarked
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.12),
                        border: Border.all(
                          color: isBookmarked
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.25),
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, 
                        color: isBookmarked ? AppColors.primary : Colors.white, 
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    if (heroTag != null) {
      cardContent = Hero(
        tag: heroTag!,
        child: Material(
          type: MaterialType.transparency,
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}
