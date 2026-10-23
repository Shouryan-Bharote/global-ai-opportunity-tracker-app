import 'dart:async';

import 'package:ai_nexus/core/constants/ai_interest_catalog.dart';
import 'package:ai_nexus/core/providers/theme_provider.dart';
import 'package:ai_nexus/core/theme/app_colors.dart';
import 'package:ai_nexus/core/theme/app_spacing.dart';
import 'package:ai_nexus/core/widgets/bounceable.dart';
import 'package:ai_nexus/features/auth/providers/auth_provider.dart';
import 'package:ai_nexus/features/auth/providers/onboarding_provider.dart';
import 'package:ai_nexus/features/events/providers/events_provider.dart';
import 'package:ai_nexus/features/home/providers/home_provider.dart';
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
  @override
  void initState() {
    super.initState();
    // profileProvider is auto-initialized by Riverpod — no manual .build() call needed.
  }

  Future<void> _showInterestsBottomSheet() async {
    final isDarkMode = ref.read(isDarkModeProvider);
    var searchQuery = '';
    var activeCategory = 'All';

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final activeInterests = ref.watch(userInterestsNotifierProvider);
          final filtered = AiInterestCatalog.allInterests.where((item) {
            final matchesCat =
                activeCategory == 'All' || item.category == activeCategory;
            final matchesSearch = searchQuery.isEmpty ||
                item.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                item.description
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase()) ||
                item.tags
                    .any((t) => t.toLowerCase().contains(searchQuery.toLowerCase()));
            return matchesCat && matchesSearch;
          }).toList();

          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF16152B) : Colors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Customize Interests',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${activeInterests.length} Topics Tuning Your Feed',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Done',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? const Color(0xFF231E3D)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.search, size: 18, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            onChanged: (val) {
                              setModalState(() {
                                searchQuery = val;
                              });
                            },
                            style: TextStyle(
                              fontSize: 13,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                            decoration: const InputDecoration(
                              hintText:
                                  'Search topics (e.g. LLMs, Vision, Hackathons)...',
                              hintStyle:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 32,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: AiInterestCatalog.categories.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, idx) {
                      final cat = AiInterestCatalog.categories[idx];
                      final isCatActive = activeCategory == cat;
                      return GestureDetector(
                        onTap: () {
                          setModalState(() {
                            activeCategory = cat;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: isCatActive
                                ? AppColors.primary
                                : (isDarkMode
                                    ? const Color(0xFF231E3D)
                                    : Colors.grey.shade200),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              cat,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isCatActive
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: isCatActive
                                    ? Colors.white
                                    : (isDarkMode
                                        ? Colors.white70
                                        : Colors.black87),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: filtered.length,
                    itemBuilder: (context, idx) {
                      final item = filtered[idx];
                      final isSelected = activeInterests.any(
                        (i) => i.toLowerCase() == item.name.toLowerCase(),
                      );
                      return GestureDetector(
                        onTap: () {
                          unawaited(
                            ref
                                .read(userInterestsNotifierProvider.notifier)
                                .toggleInterest(item.name),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDarkMode
                                    ? const Color(0xFF261F42)
                                    : const Color(0xFFF0F3FF))
                                : (isDarkMode
                                    ? const Color(0xFF1E1B33)
                                    : Colors.white),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : (isDarkMode
                                      ? Colors.white10
                                      : Colors.grey.shade200),
                              width: isSelected ? 1.6 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color:
                                      item.accentColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(item.icon,
                                    color: item.accentColor, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: isDarkMode
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item.description,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDarkMode
                                            ? Colors.white60
                                            : Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                isSelected
                                    ? Icons.check_circle_rounded
                                    : Icons.add_circle_outline_rounded,
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.grey.shade400,
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showEditProfileSheet(
    String currentName,
    String? currentAvatarUrl,
  ) async {
    final isDarkMode = ref.read(isDarkModeProvider);
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
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF16152B) : Colors.white,
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
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Name',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.white70 : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameController,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter name',
                      hintStyle: TextStyle(
                        color: isDarkMode ? Colors.white38 : Colors.grey,
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Profile Photo',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.white70 : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select a preset avatar:',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDarkMode ? Colors.white54 : Colors.grey,
                    ),
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
                                  color: isDarkMode
                                      ? const Color(0x3D3E63F5)
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
                    style: TextStyle(
                      fontSize: 13,
                      color: isDarkMode ? Colors.white54 : Colors.grey,
                    ),
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
                    style: TextStyle(
                      fontSize: 13,
                      color: isDarkMode ? Colors.white54 : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: avatarController,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: 'https://example.com/photo.jpg',
                      hintStyle: TextStyle(
                        color: isDarkMode ? Colors.white38 : Colors.grey,
                      ),
                      border: const OutlineInputBorder(),
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
                        if (context.mounted) Navigator.pop(context);
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
      ),
    );
  }

  Future<void> _showAboutDialog() async {
    final isDarkMode = ref.read(isDarkModeProvider);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF16152B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'About AI Opportunity Tracker',
          style: TextStyle(
            color: isDarkMode ? Colors.white : const Color(0xFF1D273F),
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
                color: isDarkMode ? Colors.white70 : const Color(0xFF4A5568),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Developed by Member 1 (Mobile), Member 2 (Backend), and Member 3 (Scraper).',
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode ? Colors.white54 : Colors.black54,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _showSignOutDialog() async {
    final isDarkMode = ref.read(isDarkModeProvider);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF16152B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Sign Out',
          style: TextStyle(
            color: isDarkMode ? Colors.white : const Color(0xFF1D273F),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to sign out? Your session details will be cleared.',
          style: TextStyle(
            color: isDarkMode ? Colors.white70 : const Color(0xFF4A5568),
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5274),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(context);
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
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final profileAsync = ref.watch(profileProvider);
    final eventsAsync = ref.watch(eventsProvider);

    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF0D0C1D)
          : const Color(0xFFFAF8FC),
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
                      color: isDarkMode
                          ? const Color(0xFF16152B)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDarkMode
                            ? const Color(0x3D3E63F5)
                            : Colors.grey.shade200,
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDarkMode
                              ? AppColors.primary.withValues(alpha: 0.15)
                              : Colors.black.withValues(alpha: 0.05),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: eventsAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, s) => const Center(child: Text('---')),
                      data: (allEvents) {
                        final savedEvents = allEvents
                            .where((e) => e.isBookmarked)
                            .toList();

                        final savedCount = savedEvents.length;
                        final activeInterests = ref.watch(userInterestsProvider);
                        final interestsCount = activeInterests.length;

                        final totalHours = savedEvents.fold<int>(0, (
                          sum,
                          event,
                        ) {
                          return sum +
                              event.endDate.difference(event.startDate).inHours;
                        });

                        return Row(
                          children: [
                            _buildStatItem(
                              'Interests',
                              interestsCount.toString(),
                              isDarkMode,
                            ),
                            _buildVerticalDivider(isDarkMode),
                            _buildStatItem(
                              'Saved',
                              savedCount.toString(),
                              isDarkMode,
                            ),
                            _buildVerticalDivider(isDarkMode),
                            _buildStatItem(
                              'Hours',
                              totalHours.toString(),
                              isDarkMode,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Interests Section (Ultra-Premium Card)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF16152B) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDarkMode
                        ? const Color(0x3D3E63F5)
                        : Colors.grey.shade200,
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDarkMode
                          ? Colors.black.withValues(alpha: 0.25)
                          : const Color(0xFF6366F1).withValues(alpha: 0.06),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primary.withValues(alpha: 0.2),
                                    const Color(0xFFC084FC).withValues(alpha: 0.2),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.auto_awesome_rounded,
                                color: AppColors.primary,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'AI Interests',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode
                                        ? Colors.white
                                        : const Color(0xFF1D273F),
                                  ),
                                ),
                                Text(
                                  'Tunes your recommendations',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDarkMode
                                        ? Colors.white54
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: _showInterestsBottomSheet,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.edit_rounded,
                                  size: 13,
                                  color: AppColors.primary,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Edit',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Wrap of catalog interests with custom icons
                    Wrap(
                      spacing: 8,
                      runSpacing: 10,
                      children: [
                        ...AiInterestCatalog.allInterests.map((interest) {
                          final activeInterests = ref.watch(userInterestsNotifierProvider);
                          final isSelected = activeInterests.any(
                            (i) => i.toLowerCase() == interest.name.toLowerCase(),
                          );
                          return GestureDetector(
                            onTap: () async {
                              await ref.read(userInterestsNotifierProvider.notifier).toggleInterest(interest.name);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? const LinearGradient(
                                        colors: [
                                          Color(0xFF6366F1),
                                          Color(0xFF8B5CF6),
                                        ],
                                      )
                                    : null,
                                color: isSelected
                                    ? null
                                    : (isDarkMode
                                        ? const Color(0xFF1E1B33)
                                        : const Color(0xFFF1F5F9)),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.transparent
                                      : (isDarkMode
                                          ? Colors.white12
                                          : Colors.grey.shade300),
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    interest.icon,
                                    size: 14,
                                    color: isSelected
                                        ? Colors.white
                                        : (isDarkMode
                                            ? Colors.white70
                                            : Colors.grey.shade700),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    interest.name,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : (isDarkMode
                                              ? Colors.white70
                                              : const Color(0xFF334155)),
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      fontSize: 12,
                                    ),
                                  ),
                                  if (isSelected) ...[
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.check,
                                      size: 13,
                                      color: Colors.white,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        }),
                        // Explore All Chip
                        GestureDetector(
                          onTap: _showInterestsBottomSheet,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? const Color(0xFF201D38)
                                  : const Color(0xFFEEF2FF),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.4),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.add_rounded,
                                  size: 15,
                                  color: AppColors.primary,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Explore All',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Divider(height: 1),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.radar_rounded,
                          size: 14,
                          color: Color(0xFF10B981),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Your Home Feed and Recommended events are dynamically tuned to your selected topics.',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDarkMode
                                  ? Colors.white54
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Menu Items List matching the mockup layout
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: isDarkMode
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    title: 'Dark Mode',
                    isDarkMode: isDarkMode,
                    onTap: () {
                      ref.read(isDarkModeProvider.notifier).state = !isDarkMode;
                    },
                    trailing: Switch.adaptive(
                      value: isDarkMode,
                      activeTrackColor: AppColors.primary,
                      onChanged: (val) {
                        ref.read(isDarkModeProvider.notifier).state = val;
                      },
                    ),
                  ),
                  _buildMenuItem(
                    icon: Icons.bookmark_outline,
                    title: 'Saved Events',
                    isDarkMode: isDarkMode,
                    onTap: () {
                      ref.read(scheduleTabProvider.notifier).state = 'Saved';
                      context.go('/schedule');
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.tune_rounded,
                    title: 'Interests settings',
                    isDarkMode: isDarkMode,
                    onTap: _showInterestsBottomSheet,
                  ),
                  _buildMenuItem(
                    icon: Icons.notifications_none_outlined,
                    title: 'Notification',
                    isDarkMode: isDarkMode,
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
                    isDarkMode: isDarkMode,
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
                      shadowColor: const Color(
                        0xFFFF5274,
                      ).withValues(alpha: 0.4),
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

  Widget _buildStatItem(String label, String value, bool isDarkMode) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : const Color(0xFF1D273F),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode
                  ? Colors.grey.shade400
                  : const Color(0xFF7A869A),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider(bool isDarkMode) {
    return Container(
      width: 1,
      height: 36,
      color: isDarkMode
          ? const Color(0x3D3E63F5)
          : Colors.grey.shade200,
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isDarkMode,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Bounceable(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isDarkMode
                ? const Color(0xFF16152B)
                : const Color(0xFFEDEDED).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDarkMode
                  ? const Color(0x3D3E63F5)
                  : Colors.transparent,
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? AppColors.primary.withValues(alpha: 0.2)
                      : const Color(0xFFE2D6FF),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isDarkMode
                      ? AppColors.secondary
                      : const Color(0xFF9000FF),
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
                    color: isDarkMode ? Colors.white : const Color(0xFF1D273F),
                  ),
                ),
              ),
              trailing ??
                  Icon(
                    Icons.chevron_right,
                    color: isDarkMode
                        ? Colors.white54
                        : const Color(0xFF7A869A),
                    size: 20,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
