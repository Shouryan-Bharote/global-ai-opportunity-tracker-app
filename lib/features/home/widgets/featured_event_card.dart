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
      padding: const EdgeInsets.all(AppSpacing.s24),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0518), // Dark background matching Figma
        borderRadius: BorderRadius.circular(AppRadius.large),
        image: imageUrl != null
            ? DecorationImage(
                image: NetworkImage(imageUrl!),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withValues(alpha: 0.6), // Dark overlay for text readability
                  BlendMode.darken,
                ),
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Graphic Placeholder (only if no image provided)
          if (imageUrl == null)
            Positioned(
              right: -50,
              top: -20,
              bottom: -20,
              child: Container(
                width: 150,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF8A4DFF), Color(0xFF3E63F5)],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                ),
              ),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(color: Colors.white30),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Featured - Trending',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s24),
              
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppSpacing.s8),
              
              SizedBox(
                width: 200,
                child: Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s16),
              
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.white),
                  const SizedBox(width: AppSpacing.s4),
                  Text(
                    date,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: AppSpacing.s16),
                  const Icon(Icons.location_on_outlined, size: 16, color: Colors.white),
                  const SizedBox(width: AppSpacing.s4),
                  Text(
                    location,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s24),
              
              Row(
                children: [
                  Bounceable(
                    onTap: onRegister,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Text('Register', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                          SizedBox(width: 4),
                          Icon(Icons.chevron_right, size: 18, color: Colors.black),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s16),
                  Bounceable(
                    onTap: onBookmark ?? () {},
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isBookmarked ? Colors.white : Colors.transparent,
                        border: Border.all(color: Colors.white30),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isBookmarked ? Icons.bookmark : Icons.bookmark_outline, 
                        color: isBookmarked ? Colors.black : Colors.white, 
                        size: 20,
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
