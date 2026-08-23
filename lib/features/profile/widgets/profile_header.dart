import 'dart:io';
import 'package:ai_nexus/core/theme/app_colors.dart';
import 'package:ai_nexus/features/auth/models/user_model.dart';
import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    required this.user,
    required this.onEditProfile,
    super.key,
  });

  final UserModel user;
  final VoidCallback onEditProfile;

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials(user.name);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Banner: light blue in light mode, deep navy in dark mode
    final bannerColor =
        isDark ? const Color(0xFF1A1F35) : const Color(0xFFE6EEFA);
    final nameColor =
        isDark ? Colors.white : const Color(0xFF1D273F);
    final emailColor =
        isDark ? Colors.white54 : const Color(0xFF7A869A);
    // Avatar inner circle
    final avatarInnerColor =
        isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: bannerColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
      child: Column(
        children: [
          // Circular Avatar Stack with tap trigger
          GestureDetector(
            onTap: onEditProfile,
            child: Stack(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: avatarInnerColor,
                      ),
                      child: ClipOval(
                        child: user.avatarUrl != null &&
                                user.avatarUrl!.isNotEmpty
                            ? (user.avatarUrl!.startsWith('http://') ||
                                    user.avatarUrl!.startsWith('https://')
                                ? Image.network(
                                    user.avatarUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            _initialsBox(
                                                initials, avatarInnerColor),
                                  )
                                : Image.file(
                                    File(user.avatarUrl!),
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            _initialsBox(
                                                initials, avatarInnerColor),
                                  ))
                            : _initialsBox(initials, avatarInnerColor),
                      ),
                    ),
                  ),
                ),
                // Edit floating button
                Positioned(
                  bottom: 0,
                  right: 4,
                  child: Container(
                    height: 32,
                    width: 32,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                      border: Border.all(color: avatarInnerColor, width: 2),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon:
                          const Icon(Icons.edit, size: 16, color: Colors.white),
                      onPressed: onEditProfile,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user.name,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: nameColor,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            user.email,
            style: TextStyle(
              fontSize: 15,
              color: emailColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _initialsBox(String initials, Color bg) {
    return ColoredBox(
      color: bg,
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
