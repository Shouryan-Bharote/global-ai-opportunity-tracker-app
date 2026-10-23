import 'package:ai_nexus/core/constants/ai_interest_catalog.dart';
import 'package:ai_nexus/features/events/models/event_model.dart';
import 'package:flutter/material.dart';

class AiMatchResult {
  const AiMatchResult({
    required this.scorePercent,
    required this.matchedInterests,
    required this.reason,
    required this.accentColor,
    required this.badgeLabel,
  });

  final int scorePercent;
  final List<String> matchedInterests;
  final String reason;
  final Color accentColor;
  final String badgeLabel;
}

class AiMatchScoreCalculator {
  AiMatchScoreCalculator._();

  static AiMatchResult calculate({
    required EventModel event,
    required List<String> userInterests,
    String? userRole,
  }) {
    if (userInterests.isEmpty) {
      return const AiMatchResult(
        scorePercent: 78,
        matchedInterests: ['Trending in AI'],
        reason: 'Recommended for you based on current trending AI opportunities.',
        accentColor: Color(0xFF6366F1),
        badgeLabel: 'Trending Pick',
      );
    }

    final matched = <String>{};
    final eventText = '${event.title} ${event.description} ${event.tags.join(' ')} ${event.host}'.toLowerCase();

    // Check each user interest
    for (final interestName in userInterests) {
      final interest = AiInterestCatalog.allInterests.firstWhere(
        (i) => i.name.toLowerCase() == interestName.toLowerCase(),
        orElse: () => AiInterest(
          id: interestName.toLowerCase().replaceAll(' ', '_'),
          name: interestName,
          category: 'Custom',
          icon: Icons.tag,
          tags: [interestName.toLowerCase()],
          description: '',
        ),
      );

      var isMatch = false;

      // Check direct name match
      if (eventText.contains(interest.name.toLowerCase())) {
        isMatch = true;
      }

      // Check keywords
      if (!isMatch) {
        for (final tag in interest.tags) {
          if (eventText.contains(tag.toLowerCase())) {
            isMatch = true;
            break;
          }
        }
      }

      // Check event.tags direct match
      if (!isMatch) {
        for (final evTag in event.tags) {
          final evTagLower = evTag.toLowerCase();
          if (interest.tags.any((t) => t.toLowerCase() == evTagLower || evTagLower.contains(t.toLowerCase()))) {
            isMatch = true;
            break;
          }
        }
      }

      if (isMatch) {
        matched.add(interest.name);
      }
    }

    // Role bonus
    var roleBonus = 0;
    if (userRole != null) {
      final lowerRole = userRole.toLowerCase();
      if (lowerRole.contains('developer') || lowerRole.contains('engineer')) {
        if (eventText.contains('hackathon') || eventText.contains('code') || eventText.contains('build')) {
          roleBonus = 6;
        }
      } else if (lowerRole.contains('student')) {
        if (eventText.contains('student') || eventText.contains('beginner') || eventText.contains('hackathon')) {
          roleBonus = 8;
        }
      } else if (lowerRole.contains('researcher')) {
        if (eventText.contains('paper') || eventText.contains('symposium') || eventText.contains('conference')) {
          roleBonus = 8;
        }
      }
    }

    // Calculate score
    int baseScore;
    if (matched.isNotEmpty) {
      // 82% to 98% based on match count
      baseScore = 80 + (matched.length * 6) + roleBonus;
      if (baseScore > 98) baseScore = 98;
    } else {
      // General discovery match 60-74%
      baseScore = 65 + roleBonus;
    }

    Color accentColor;
    String badgeLabel;

    if (baseScore >= 90) {
      accentColor = const Color(0xFF10B981); // Emerald Green
      badgeLabel = '⚡ Outstanding Fit';
    } else if (baseScore >= 80) {
      accentColor = const Color(0xFF6366F1); // Indigo / Violet
      badgeLabel = '🎯 Strong Match';
    } else if (baseScore >= 70) {
      accentColor = const Color(0xFF3B82F6); // Blue
      badgeLabel = '✨ Good Match';
    } else {
      accentColor = const Color(0xFF8B5CF6); // Purple
      badgeLabel = '💡 Discovery Pick';
    }

    String reason;
    if (matched.isNotEmpty) {
      reason = 'High alignment with your preferences in ${matched.take(2).join(' & ')}.';
    } else {
      reason = 'Broad AI relevance with potential networking and learning value.';
    }

    return AiMatchResult(
      scorePercent: baseScore,
      matchedInterests: matched.isNotEmpty ? matched.toList() : ['AI Opportunity'],
      reason: reason,
      accentColor: accentColor,
      badgeLabel: badgeLabel,
    );
  }
}

class AiMatchCard extends StatelessWidget {
  const AiMatchCard({
    required this.event,
    required this.userInterests,
    this.userRole,
    super.key,
  });

  final EventModel event;
  final List<String> userInterests;
  final String? userRole;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final match = AiMatchScoreCalculator.calculate(
      event: event,
      userInterests: userInterests,
      userRole: userRole,
    );

    final accent = match.accentColor;
    final cardBg = isDark
        ? const Color(0xFF1E1D3B)
        : Colors.white;

    final borderColor = accent.withValues(alpha: isDark ? 0.35 : 0.25);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.3),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: isDark ? 0.2 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Ambient subtle glow gradient at top-right
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withValues(alpha: isDark ? 0.15 : 0.1),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Match badge & Score Pill
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: isDark ? 0.2 : 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: accent.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              match.badgeLabel,
                              style: TextStyle(
                                color: accent,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Big Score Display
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '${match.scorePercent}%',
                            style: TextStyle(
                              color: accent,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Match',
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black54,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: match.scorePercent / 100.0,
                      minHeight: 6,
                      backgroundColor: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.grey.withValues(alpha: 0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(accent),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Reason text
                  Text(
                    match.reason,
                    style: TextStyle(
                      color: isDark ? Colors.grey.shade300 : Colors.black87,
                      fontSize: 13,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  // Matching skill chips
                  if (match.matchedInterests.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: match.matchedInterests.take(3).map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.06)
                                : Colors.black.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.12)
                                  : Colors.black.withValues(alpha: 0.08),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                size: 12,
                                color: accent,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                tag,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
