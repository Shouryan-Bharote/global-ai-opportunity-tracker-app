import 'package:flutter/material.dart';

class PlatformInfo {
  const PlatformInfo({
    required this.name,
    required this.badgeColor,
    required this.textColor,
    required this.icon,
  });

  final String name;
  final Color badgeColor;
  final Color textColor;
  final IconData icon;
}

class PlatformBadgeHelper {
  PlatformBadgeHelper._();

  static PlatformInfo getPlatformInfo(String url, String host) {
    final lowerUrl = url.toLowerCase();
    final lowerHost = host.toLowerCase();

    if (lowerUrl.contains('devpost.com') || lowerHost.contains('devpost')) {
      return const PlatformInfo(
        name: 'Devpost Hackathon',
        badgeColor: Color(0xFF003E54),
        textColor: Colors.white,
        icon: Icons.code_rounded,
      );
    }
    if (lowerUrl.contains('unstop.com') || lowerHost.contains('unstop')) {
      return const PlatformInfo(
        name: 'Unstop Competition',
        badgeColor: Color(0xFF1C4980),
        textColor: Color(0xFFFFB800),
        icon: Icons.emoji_events_rounded,
      );
    }
    if (lowerUrl.contains('devfolio.co') || lowerHost.contains('devfolio')) {
      return const PlatformInfo(
        name: 'Devfolio Sprint',
        badgeColor: Color(0xFF273339),
        textColor: Color(0xFF3770FF),
        icon: Icons.terminal_rounded,
      );
    }
    if (lowerUrl.contains('mlh.io') || lowerHost.contains('mlh')) {
      return const PlatformInfo(
        name: 'MLH Member Event',
        badgeColor: Color(0xFFE73427),
        textColor: Colors.white,
        icon: Icons.military_tech_rounded,
      );
    }
    if (lowerUrl.contains('lu.ma') || lowerHost.contains('luma')) {
      return const PlatformInfo(
        name: 'Luma Community',
        badgeColor: Color(0xFF2D1B2D),
        textColor: Color(0xFFFF6B81),
        icon: Icons.group_work_rounded,
      );
    }
    if (lowerUrl.contains('kaggle.com') || lowerHost.contains('kaggle')) {
      return const PlatformInfo(
        name: 'Kaggle Challenge',
        badgeColor: Color(0xFF1E3A5F),
        textColor: Color(0xFF20BEFF),
        icon: Icons.insights_rounded,
      );
    }
    if (lowerUrl.contains('eventbrite.com') || lowerHost.contains('eventbrite')) {
      return const PlatformInfo(
        name: 'Eventbrite Summit',
        badgeColor: Color(0xFFF05537),
        textColor: Colors.white,
        icon: Icons.confirmation_number_rounded,
      );
    }
    if (lowerUrl.contains('meetup.com') || lowerHost.contains('meetup')) {
      return const PlatformInfo(
        name: 'Meetup Network',
        badgeColor: Color(0xFFF64060),
        textColor: Colors.white,
        icon: Icons.people_outline_rounded,
      );
    }

    return const PlatformInfo(
      name: 'Global AI Opportunity',
      badgeColor: Color(0xFF3B82F6),
      textColor: Colors.white,
      icon: Icons.auto_awesome_rounded,
    );
  }
}

class PlatformBadge extends StatelessWidget {
  const PlatformBadge({
    required this.url,
    required this.host,
    this.fontSize = 11,
    super.key,
  });

  final String url;
  final String host;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final info = PlatformBadgeHelper.getPlatformInfo(url, host);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: info.badgeColor.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: info.textColor.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: info.badgeColor.withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(info.icon, size: fontSize + 3, color: info.textColor),
          const SizedBox(width: 5),
          Text(
            info.name,
            style: TextStyle(
              color: info.textColor,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
