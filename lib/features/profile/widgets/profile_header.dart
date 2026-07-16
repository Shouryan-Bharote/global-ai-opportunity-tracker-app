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

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFE6EEFA), // Light blue background from mockup
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 48), // Padding bottom is larger to allow stats card overlap
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
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient, // Theme primary gradient border
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4), // Acts as border width
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: ClipOval(
                        child: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                            ? (user.avatarUrl!.startsWith('http://') || user.avatarUrl!.startsWith('https://')
                                ? Image.network(
                                    user.avatarUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => ColoredBox(
                                      color: Colors.white,
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
                                    ),
                                  )
                                : Image.file(
                                    File(user.avatarUrl!),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => ColoredBox(
                                      color: Colors.white,
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
                                    ),
                                  ))
                            : ColoredBox(
                                color: Colors.white,
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
                              ),
                      ),
                    ),
                  ),
                ),
                // Edit profile floating trigger button
                Positioned(
                  bottom: 0,
                  right: 4,
                  child: Container(
                    height: 32,
                    width: 32,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient, // Gradient button
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.edit, size: 16, color: Colors.white),
                      onPressed: onEditProfile,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // User Name
          Text(
            user.name,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D273F), // Dark blue-grey text from mockup
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          // User Email
          Text(
            user.email,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF7A869A), // Cool grey text from mockup
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
