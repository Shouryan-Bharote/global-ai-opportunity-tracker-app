import 'package:ai_nexus/core/theme/app_colors.dart';
import 'package:ai_nexus/core/theme/app_spacing.dart';
import 'package:ai_nexus/core/widgets/bounceable.dart';
import 'package:ai_nexus/features/auth/providers/auth_provider.dart';
import 'package:ai_nexus/features/opportunities/providers/opportunities_provider.dart';
import 'package:ai_nexus/features/profile/providers/profile_provider.dart';
import 'package:ai_nexus/features/profile/widgets/profile_header.dart';
import 'package:ai_nexus/features/schedule/providers/schedule_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // Selected interest for visual state toggle, matching the mockup
  final Set<String> _selectedInterests = {'Generative AI'};

  final List<String> _interests = [
    'Generative AI',
    'NLP',
    'Hackathons',
    'Computer vision',
    'Machine learning',
    'Agents',
  ];

  Future<void> _showEditProfileSheet(
    String currentName,
    String? currentAvatarUrl,
  ) async {
    final nameController = TextEditingController(text: currentName);
    final avatarController = TextEditingController(
      text: currentAvatarUrl ?? '',
    );
    final presets = [
      'https://i.pravatar.cc/150?img=47',
      'https://i.pravatar.cc/150?img=33',
      'https://i.pravatar.cc/150?img=5',
      'https://i.pravatar.cc/150?img=12',
    ];

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final isDark = Theme.of(sheetContext).brightness == Brightness.dark;
        final sheetBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
        final textColor = isDark ? Colors.white : Colors.black87;
        final subtextColor = isDark ? Colors.grey.shade400 : Colors.grey;

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: sheetBg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(24),
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Name',
                      style: TextStyle(
                        fontSize: 14,
                        color: subtextColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameController,
                      style: TextStyle(color: textColor),
                      decoration: const InputDecoration(
                        hintText: 'Enter name',
                      ),
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Profile Photo',
                      style: TextStyle(
                        fontSize: 14,
                        color: subtextColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select a preset avatar:',
                      style: TextStyle(fontSize: 13, color: subtextColor),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: presets
                          .map(
                            (url) => GestureDetector(
                              onTap: () {
                                avatarController.text = url;
                              },
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isDark
                                        ? const Color(0xFF333333)
                                        : Colors.grey.shade200,
                                    width: 2,
                                  ),
                                ),
                                child: ClipOval(
                                  child: Image.network(url, fit: BoxFit.cover),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Or import from device:',
                      style: TextStyle(fontSize: 13, color: subtextColor),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: const BorderSide(color: AppColors.primary),
                        ),
                        icon: const Icon(
                          Icons.photo_library_outlined,
                          color: AppColors.primary,
                        ),
                        label: const Text(
                          'Choose from Gallery',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () async {
                          final picker = ImagePicker();
                          final image = await picker.pickImage(
                            source: ImageSource.gallery,
                          );
                          if (image != null) {
                            avatarController.text = image.path;
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Or enter custom image URL:',
                      style: TextStyle(fontSize: 13, color: subtextColor),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: avatarController,
                      style: TextStyle(color: textColor),
                      decoration: const InputDecoration(
                        hintText: 'https://example.com/photo.jpg',
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () async {
                          final newName = nameController.text.trim();
                          final url = avatarController.text.trim();
                          if (newName.isNotEmpty) {
                            await ref
                                .read(profileProvider.notifier)
                                .updateName(newName);
                          }
                          await ref
                              .read(profileProvider.notifier)
                              .updateAvatarUrl(url);
                          if (sheetContext.mounted) Navigator.pop(sheetContext);
                        },
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showAboutDialog() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text(
          'About AI Opportunity Tracker',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Version 1.0.0',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF5274),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Centralized catalog for technical workshops, hackathons, and webinars from Unstop, Hack2Skill, Devfolio, MLH, and more.',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Developed by Member 1 (Mobile), Member 2 (Backend), and Member 3 (Scraper).',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _showSignOutDialog() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text(
          'Sign Out',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to sign out? Your session details will be cleared.',
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5274),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(dialogContext);
              await ref.read(authProvider.notifier).logout();
            },
            child: const Text('Sign Out'),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(62, 99, 245, 1),
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profileAsync = ref.watch(profileProvider);
    final opportunitiesAsync = ref.watch(opportunitiesProvider);

    final statsCardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final statsCardBorder = isDark ? const Color(0xFF2E2E2E) : null;
    final sectionTitleColor = isDark ? Colors.white : const Color(0xFF1D273F);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFFAF8FC),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overlapping Header Section using Stack
            Stack(
              clipBehavior: Clip.none,
              children: [
                profileAsync.when(
                  loading: () => const SizedBox(
                    height: 240,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, stack) => SizedBox(
                    height: 240,
                    child: Center(child: Text('Error: $error')),
                  ),
                  data: (user) {
                    if (user == null) return const SizedBox.shrink();
                    return ProfileHeader(
                      user: user,
                      onEditProfile: () =>
                          _showEditProfileSheet(user.name, user.avatarUrl),
                    );
                  },
                ),
                // Floating Overlapping Stats Card
                Positioned(
                  bottom: -32,
                  left: 24,
                  right: 24,
                  child: Container(
                    height: 72,
                    decoration: BoxDecoration(
                      color: statsCardBg,
                      borderRadius: BorderRadius.circular(24),
                      border: statsCardBorder != null
                          ? Border.all(color: statsCardBorder)
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.25 : 0.05,
                          ),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: opportunitiesAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, s) => const Center(child: Text('---')),
                      data: (allOpportunities) {
                        final savedOpportunities = allOpportunities
                            .where((e) => e.isBookmarked)
                            .toList();

                        final savedCount = savedOpportunities.length;
                        final interestsCount = _selectedInterests.length;
                        final totalHours = savedCount * 8;

                        return Row(
                          children: [
                            _buildStatItem(
                              'Interests',
                              interestsCount.toString(),
                              isDark,
                            ),
                            _buildVerticalDivider(isDark),
                            _buildStatItem(
                              'Saved',
                              savedCount.toString(),
                              isDark,
                            ),
                            _buildVerticalDivider(isDark),
                            _buildStatItem(
                              'Hours',
                              totalHours.toString(),
                              isDark,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 56),

            // Interests Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
              child: Text(
                'Interests',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: sectionTitleColor,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
              child: Wrap(
                spacing: 8,
                runSpacing: 10,
                children: _interests.map((interest) {
                  final isSelected = _selectedInterests.contains(interest);
                  final unselectedBg =
                      isDark ? const Color(0xFF1E1E1E) : Colors.white;
                  final unselectedBorder =
                      isDark ? const Color(0xFF3A3A3A) : Colors.grey.shade300;
                  final unselectedText =
                      isDark ? Colors.white70 : const Color(0xFF4A5568);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedInterests.remove(interest);
                        } else {
                          _selectedInterests.add(interest);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color.fromRGBO(62, 99, 245, 1)
                            : unselectedBg,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : unselectedBorder,
                        ),
                      ),
                      child: Text(
                        interest,
                        style: TextStyle(
                          color: isSelected ? Colors.white : unselectedText,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 36),

            // Menu Items List matching the mockup layout
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.bookmark_outline,
                    title: 'Saved Events',
                    isDark: isDark,
                    onTap: () {
                      ref.read(scheduleTabProvider.notifier).state = 'Saved';
                      context.go('/schedule');
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.pie_chart_outline,
                    title: 'Interests settings',
                    isDark: isDark,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Customize interests in the next release!',
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.notifications_none_outlined,
                    title: 'Notification',
                    isDark: isDark,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Notifications configuration coming soon!',
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.info_outline,
                    title: 'About AI events',
                    isDark: isDark,
                    onTap: () async {
                      await _showAboutDialog();
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Centered Red Log out link
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await _showSignOutDialog();
                    },
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text(
                      'Log out',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF5274),
                      foregroundColor: Colors.white,
                      elevation: 6,
                      shadowColor: const Color(0xFFFF5274).withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 120,
            ), // Height padding for navigation tab bar overlay
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, bool isDark) {
    final valueColor = isDark ? Colors.white : const Color(0xFF1D273F);
    final labelColor = isDark ? Colors.white54 : const Color(0xFF7A869A);

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: labelColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider(bool isDark) {
    return Container(
      width: 1,
      height: 36,
      color: isDark ? const Color(0xFF2E2E2E) : Colors.grey.shade200,
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final tileBg = isDark
        ? const Color(0xFF1E1E1E)
        : const Color(0xFFEDEDED).withValues(alpha: 0.5);
    final tileBorder = isDark ? const Color(0xFF2E2E2E) : null;
    final iconBg = isDark ? const Color(0xFF2D1A4A) : const Color(0xFFE2D6FF);
    final iconColor = isDark ? const Color(0xFFCB9EFF) : const Color(0xFF9000FF);
    final titleColor = isDark ? Colors.white : const Color(0xFF1D273F);
    final chevronColor = isDark ? Colors.white38 : const Color(0xFF7A869A);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Bounceable(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: tileBg,
            borderRadius: BorderRadius.circular(18),
            border: tileBorder != null ? Border.all(color: tileBorder) : null,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: chevronColor,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
