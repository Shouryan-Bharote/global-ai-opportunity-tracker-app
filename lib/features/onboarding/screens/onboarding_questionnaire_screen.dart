import 'dart:async';

import 'package:ai_nexus/core/constants/ai_interest_catalog.dart';
import 'package:ai_nexus/core/theme/app_colors.dart';
import 'package:ai_nexus/core/theme/app_spacing.dart';
import 'package:ai_nexus/features/auth/providers/auth_provider.dart';
import 'package:ai_nexus/features/auth/providers/onboarding_provider.dart';
import 'package:ai_nexus/features/profile/providers/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OnboardingQuestionnaireScreen extends ConsumerStatefulWidget {
  const OnboardingQuestionnaireScreen({super.key});

  @override
  ConsumerState<OnboardingQuestionnaireScreen> createState() =>
      _OnboardingQuestionnaireScreenState();
}

class _OnboardingQuestionnaireScreenState
    extends ConsumerState<OnboardingQuestionnaireScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _nicknameController = TextEditingController();

  int _currentPage = 0;
  String _selectedRole = 'AI Developer / Engineer';
  String _selectedEventMode = 'Both / Flexible';
  final Set<String> _selectedInterests = {};
  String _activeCategory = 'All';
  String _searchQuery = '';

  final List<Map<String, dynamic>> _roles = [
    {
      'title': 'AI Developer / Engineer',
      'subtitle': 'Hands-on coding, frameworks, models & tools',
      'icon': Icons.code_rounded,
      'color': const Color(0xFF6366F1),
    },
    {
      'title': 'Student / Learner',
      'subtitle': 'Student hackathons, beginner workshops & mentorship',
      'icon': Icons.school_rounded,
      'color': const Color(0xFF3B82F6),
    },
    {
      'title': 'Researcher / Scientist',
      'subtitle': 'Academic papers, symposiums & frontier AI',
      'icon': Icons.psychology_rounded,
      'color': const Color(0xFF8B5CF6),
    },
    {
      'title': 'Founder / Entrepreneur',
      'subtitle': 'Pitch nights, venture capital & demo days',
      'icon': Icons.rocket_launch_rounded,
      'color': const Color(0xFFF59E0B),
    },
    {
      'title': 'Tech Enthusiast',
      'subtitle': 'AI news, product releases & community meetups',
      'icon': Icons.auto_awesome_rounded,
      'color': const Color(0xFF10B981),
    },
  ];

  final List<Map<String, dynamic>> _eventModes = [
    {
      'title': 'Both / Flexible',
      'subtitle': 'Show both virtual webinars and local in-person meetups',
      'icon': Icons.all_inclusive_rounded,
    },
    {
      'title': 'Online & Virtual',
      'subtitle': 'Join from anywhere: webinars, remote hackathons & streams',
      'icon': Icons.laptop_chromebook_rounded,
    },
    {
      'title': 'In-Person',
      'subtitle': 'Meet people face-to-face at physical venues and summits',
      'icon': Icons.location_on_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedInterests.addAll(AiInterestCatalog.defaultSelectedNames);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(profileProvider).valueOrNull;
      final authUser = ref.read(authProvider).user;
      final existingName = user?.name ?? authUser?.name;

      if (existingName != null && existingName.trim().isNotEmpty) {
        final firstPart = existingName.trim().split(' ').first;
        _nicknameController.text = firstPart;
      } else {
        _nicknameController.text = 'AI Explorer';
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      unawaited(_finishOnboarding());
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _finishOnboarding() async {
    final nickname = _nicknameController.text.trim().isNotEmpty
        ? _nicknameController.text.trim()
        : 'AI Explorer';

    final interestsList = _selectedInterests.isNotEmpty
        ? _selectedInterests.toList()
        : AiInterestCatalog.defaultSelectedNames;

    await ref.read(onboardingProvider.notifier).completeOnboarding(
          nickname: nickname,
          role: _selectedRole,
          interests: interestsList,
          eventMode: _selectedEventMode,
          ref: ref,
        );

    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0E17) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentPage > 0
            ? IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: isDark ? Colors.white : Colors.black87,
                  size: 20,
                ),
                onPressed: _prevPage,
              )
            : null,
        title: _buildProgressIndicator(isDark),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _finishOnboarding,
            child: Text(
              'Skip',
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (idx) => setState(() => _currentPage = idx),
        children: [
          _buildStep1NicknameAndRole(isDark),
          _buildStep2Interests(isDark),
          _buildStep3EventMode(isDark),
        ],
      ),
      bottomNavigationBar: _buildBottomCTA(isDark),
    );
  }

  Widget _buildProgressIndicator(bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        final isActive = index == _currentPage;
        final isPassed = index < _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 6,
          width: isActive ? 28 : 12,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary
                : (isPassed
                    ? AppColors.primary.withValues(alpha: 0.5)
                    : (isDark ? Colors.white12 : Colors.grey.shade300)),
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
  }

  // --- STEP 1: NICKNAME & ROLE ---
  Widget _buildStep1NicknameAndRole(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.2),
                  const Color(0xFFC084FC).withValues(alpha: 0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '👋 Welcome to AI Events Tracker',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'What should we call you?',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Pick a nickname or handle for your profile and event networking.',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white60 : Colors.grey.shade600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),

          // Nickname Input
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1B2E) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.35),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.alternate_email_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _nicknameController,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Enter your nickname...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                if (_nicknameController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    color: Colors.grey,
                    onPressed: () {
                      _nicknameController.clear();
                      setState(() {});
                    },
                  ),
              ],
            ),
          ),

          const SizedBox(height: 36),

          // Role Selection Title
          Text(
            'What describes your role best?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 14),

          // Role List
          ..._roles.map((role) {
            final isSelected = _selectedRole == role['title'];
            return GestureDetector(
              onTap: () => setState(() => _selectedRole = role['title'] as String),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? const Color(0xFF241F3D) : const Color(0xFFEEF2FF))
                      : (isDark ? const Color(0xFF161524) : Colors.white),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : (isDark ? Colors.white10 : Colors.grey.shade200),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: (role['color'] as Color).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        role['icon'] as IconData,
                        color: role['color'] as Color,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            role['title'] as String,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            role['subtitle'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white60 : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isSelected
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: isSelected ? AppColors.primary : Colors.grey.shade400,
                      size: 22,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // --- STEP 2: INTERESTS SELECTION (ULTRA-PREMIUM) ---
  Widget _buildStep2Interests(bool isDark) {
    final filteredInterests = AiInterestCatalog.allInterests.where((item) {
      final matchesCat = _activeCategory == 'All' || item.category == _activeCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.tags.any((t) => t.toLowerCase().contains(_searchQuery.toLowerCase()));
      return matchesCat && matchesSearch;
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Personalize Your AI Feed',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Choose topics to tune your recommendations and event alerts.',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white60 : Colors.grey.shade600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_selectedInterests.length} Selected',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Search Bar
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1B2E) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? Colors.white12 : Colors.grey.shade300,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded, size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        onChanged: (val) => setState(() => _searchQuery = val),
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Search AI topics (e.g. LLMs, Vision, Hackathons)...',
                          hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Categories Filter Tabs
              SizedBox(
                height: 34,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: AiInterestCatalog.categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, idx) {
                    final cat = AiInterestCatalog.categories[idx];
                    final isCatActive = _activeCategory == cat;
                    return GestureDetector(
                      onTap: () => setState(() => _activeCategory = cat),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isCatActive
                              ? AppColors.primary
                              : (isDark ? const Color(0xFF161524) : Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            cat,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isCatActive ? FontWeight.bold : FontWeight.w500,
                              color: isCatActive
                                  ? Colors.white
                                  : (isDark ? Colors.white70 : Colors.black87),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        const Divider(height: 1),

        // Grid of Interests
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24, vertical: 12),
            itemCount: filteredInterests.length,
            itemBuilder: (context, index) {
              final interest = filteredInterests[index];
              final isSelected = _selectedInterests.contains(interest.name);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedInterests.remove(interest.name);
                    } else {
                      _selectedInterests.add(interest.name);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark ? const Color(0xFF261F42) : const Color(0xFFF0F3FF))
                        : (isDark ? const Color(0xFF161524) : Colors.white),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : (isDark ? Colors.white10 : Colors.grey.shade200),
                      width: isSelected ? 1.8 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              interest.accentColor.withValues(alpha: 0.25),
                              interest.accentColor.withValues(alpha: 0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          interest.icon,
                          color: interest.accentColor,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  interest.name,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.white10
                                        : Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    interest.category,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isDark
                                          ? Colors.white54
                                          : Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              interest.description,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white54 : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? AppColors.primary : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.grey.shade400,
                            width: 1.5,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- STEP 3: EVENT MODE & SUMMARY ---
  Widget _buildStep3EventMode(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '🎯 Almost Done',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF10B981),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'How do you like to attend?',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Choose your preferred event attendance style.',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white60 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),

          // Event Mode Cards
          ..._eventModes.map((mode) {
            final isSelected = _selectedEventMode == mode['title'];
            return GestureDetector(
              onTap: () => setState(() => _selectedEventMode = mode['title'] as String),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? const Color(0xFF241F3D) : const Color(0xFFEEF2FF))
                      : (isDark ? const Color(0xFF161524) : Colors.white),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : (isDark ? Colors.white10 : Colors.grey.shade200),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        mode['icon'] as IconData,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mode['title'] as String,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            mode['subtitle'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white60 : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isSelected
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: isSelected ? AppColors.primary : Colors.grey.shade400,
                      size: 22,
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 24),

          // Overview Profile Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1E1B38), const Color(0xFF141324)]
                    : [const Color(0xFFEEF2FF), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        _nicknameController.text.isNotEmpty
                            ? _nicknameController.text[0].toUpperCase()
                            : 'A',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _nicknameController.text.isNotEmpty
                                ? _nicknameController.text
                                : 'AI Explorer',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            _selectedRole,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_selectedInterests.length} Topics',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.bolt_rounded, color: Color(0xFFF59E0B), size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Events tagged with your interests will be pinned and highlighted at the top of your feed!',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white70 : Colors.grey.shade700,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- BOTTOM CTA BAR ---
  Widget _buildBottomCTA(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131220) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: _nextPage,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            shadowColor: AppColors.primary.withValues(alpha: 0.4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _currentPage == 2 ? 'Launch Experience 🚀' : 'Continue',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                _currentPage == 2
                    ? Icons.arrow_forward_rounded
                    : Icons.arrow_forward_ios_rounded,
                color: Colors.white,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
