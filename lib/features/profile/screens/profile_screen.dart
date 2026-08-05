
import 'package:ai_nexus/core/theme/app_colors.dart';
import 'package:ai_nexus/core/theme/app_spacing.dart';
import 'package:ai_nexus/core/widgets/bounceable.dart';
import 'package:ai_nexus/features/auth/providers/auth_provider.dart';
import 'package:ai_nexus/features/events/providers/events_provider.dart';
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
    'Agents'
  ];

  @override
  void initState() {
    super.initState();
    // profileProvider is auto-initialized by Riverpod — no manual .build() call needed.
  }

  Future<void> _showEditProfileSheet(String currentName, String? currentAvatarUrl) async {
    final nameController = TextEditingController(text: currentName);
    final avatarController = TextEditingController(text: currentAvatarUrl ?? '');
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
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Edit Profile',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text('Name', style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    hintText: 'Enter name',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 24),
                const Text('Profile Photo', style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Select a preset avatar:', style: TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: presets.map((url) => GestureDetector(
                    onTap: () {
                      avatarController.text = url;
                    },
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade200, width: 2),
                      ),
                      child: ClipOval(child: Image.network(url, fit: BoxFit.cover)),
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 20),
                const Text('Or import from device:', style: TextStyle(fontSize: 13, color: Colors.grey)),
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
                    icon: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
                    label: const Text(
                      'Choose from Gallery',
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () async {
                      final picker = ImagePicker();
                      final image = await picker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        avatarController.text = image.path;
                      }
                    },
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Or enter custom image URL:', style: TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 8),
                TextField(
                  controller: avatarController,
                  decoration: const InputDecoration(
                    hintText: 'https://example.com/photo.jpg',
                    border: OutlineInputBorder(),
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
                        await ref.read(profileProvider.notifier).updateName(newName);
                      }
                      // Either update with new URL or clear it if they delete the text
                      await ref.read(profileProvider.notifier).updateAvatarUrl(url);
                      if (context.mounted) Navigator.pop(context);
                    },
                    child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('About AI Opportunity Tracker'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version 1.0.0',
              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF5274)),
            ),
            SizedBox(height: 8),
            Text(
              'Centralized catalog for technical workshops, hackathons, and webinars from Unstop, Hack2Skill, Devfolio, MLH, and more.',
            ),
            SizedBox(height: 12),
            Text(
              'Developed by Member 1 (Mobile), Member 2 (Backend), and Member 3 (Scraper).',
              style: TextStyle(fontSize: 12, color: Colors.black54),
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
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out? Your session details will be cleared.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF5274), foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authProvider.notifier).logout();
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }




  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);
    final eventsAsync = ref.watch(eventsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FC), // Soft purple-tinted white background from mockup
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
                      onEditProfile: () => _showEditProfileSheet(user.name, user.avatarUrl),
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: eventsAsync.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, s) => const Center(child: Text('---')),
                      data: (allEvents) {
                        final savedEvents = allEvents.where((e) => e.isBookmarked).toList();
                        
                        final savedCount = savedEvents.length;
                        final interestsCount = _selectedInterests.length;

                        // Total dedication hours represented by all bookmarked events combined duration
                        final totalHours = savedEvents.fold<int>(0, (sum, event) {
                          return sum + event.endDate.difference(event.startDate).inHours;
                        });

                        return Row(
                          children: [
                            _buildStatItem('Interests', interestsCount.toString()),
                            _buildVerticalDivider(),
                            _buildStatItem('Saved', savedCount.toString()),
                            _buildVerticalDivider(),
                            _buildStatItem('Hours', totalHours.toString()),
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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.s24),
              child: Text(
                'Interests',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D273F), // Dark blue-grey text color from mockup
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
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isSelected ? Colors.transparent : Colors.grey.shade300,
                        ),
                      ),
                      child: Text(
                        interest,
                        style: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF4A5568),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
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
                    onTap: () {
                      // Navigate directly to schedule saved opportunities tab
                      ref.read(scheduleTabProvider.notifier).state = 'Saved';
                      context.go('/schedule');
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.pie_chart_outline,
                    title: 'Interests settings',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Customize interests in the next release!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.notifications_none_outlined,
                    title: 'Notification',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Notifications configuration coming soon!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.info_outline,
                    title: 'About AI events',
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
              child: TextButton(
                onPressed: () async {
                  await _showSignOutDialog();
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text(
                  'Log out',
                  style: TextStyle(
                    color: Color(0xFFFF5274), // Red/Pink destructive color
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 120), // Height padding for navigation tab bar overlay
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D273F), // Dark blue-grey text
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF7A869A), // Cool grey text
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 36,
      color: Colors.grey.shade200,
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Bounceable(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFEDEDED).withValues(alpha: 0.5), // Very light grey tile background from mockup
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFE2D6FF), // Soft purple icon container background from mockup
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF9000FF), // Deep purple icon from mockup
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D273F), // Dark grey text
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF7A869A), // Cool grey chevron from mockup
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
