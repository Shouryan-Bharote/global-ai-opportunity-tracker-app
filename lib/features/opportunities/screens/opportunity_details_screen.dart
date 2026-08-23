import 'dart:async';
import 'dart:ui';
import 'package:ai_nexus/core/theme/app_colors.dart';
import 'package:ai_nexus/core/theme/app_spacing.dart';
import 'package:ai_nexus/features/opportunities/models/opportunity_model.dart';
import 'package:ai_nexus/features/opportunities/providers/opportunities_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class OpportunityDetailsScreen extends ConsumerStatefulWidget {
  const OpportunityDetailsScreen({
    required this.opportunityId,
    this.imageUrl,
    super.key,
  });

  final String opportunityId;
  final String? imageUrl;

  @override
  ConsumerState<OpportunityDetailsScreen> createState() =>
      _OpportunityDetailsScreenState();
}

class _OpportunityDetailsScreenState
    extends ConsumerState<OpportunityDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  OpportunityModel? _findOpportunity() {
    final asyncVal = ref.watch(opportunitiesProvider);
    final list = asyncVal.valueOrNull ?? [];
    final idx = list.indexWhere((e) => e.id == widget.opportunityId);
    if (idx == -1) return null;
    return list[idx];
  }

  @override
  Widget build(BuildContext context) {
    final opportunity = _findOpportunity();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (opportunity == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Opportunity Details'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.search_off_rounded, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Opportunity Not Found',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'The requested opportunity could not be loaded.',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.pop(),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final hasDeadline = opportunity.deadline != null;
    final deadlineFormatted = hasDeadline
        ? DateFormat('dd MMM yyyy, h:mm a').format(opportunity.deadline!)
        : 'Open / Rolling';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBody: true,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 320,
              pinned: true,
              backgroundColor: isDark ? Colors.black : Colors.deepPurple.shade900,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () => context.pop(),
              ),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.share_outlined,
                    color: Colors.white,
                    size: 22,
                  ),
                  onPressed: () {
                    unawaited(
                      SharePlus.instance.share(
                        ShareParams(
                          text: 'Check out this opportunity on AI Nexus:\n'
                              '${opportunity.title}\n\n'
                              'Organized by: ${opportunity.displayOrganizer}\n'
                              'Type: ${opportunity.opportunityType}\n'
                              'Deadline: $deadlineFormatted\n'
                              'Location: ${opportunity.locationType}\n\n'
                              'Apply / Learn more: ${opportunity.url}',
                          subject: opportunity.title,
                        ),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(
                    opportunity.isBookmarked
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    color: opportunity.isBookmarked
                        ? AppColors.primary
                        : Colors.white,
                    size: 24,
                  ),
                  onPressed: () {
                    unawaited(
                      ref
                          .read(opportunitiesProvider.notifier)
                          .toggleBookmark(opportunity.id),
                    );
                  },
                ),
                const SizedBox(width: AppSpacing.s8),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background Image / Gradient
                    if (opportunity.imageUrl != null || widget.imageUrl != null)
                      Image.network(
                        opportunity.imageUrl ?? widget.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF2E0854), Color(0xFF0F0C29)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF2E0854), Color(0xFF1B003A), Color(0xFF0D0518)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),

                    // Gradient Overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.3),
                              Colors.black.withValues(alpha: 0.85),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Opportunity Title & Badges
                    Positioned(
                      bottom: 20,
                      left: AppSpacing.s24,
                      right: AppSpacing.s24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Badges Row
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              _buildBadge(
                                label: opportunity.opportunityType,
                                color: Colors.blueAccent,
                              ),
                              _buildBadge(
                                label: opportunity.locationType,
                                color: opportunity.isOnline
                                    ? Colors.tealAccent
                                    : Colors.orangeAccent,
                              ),
                              if (opportunity.difficulty != null)
                                _buildBadge(
                                  label: opportunity.difficulty!,
                                  color: Colors.purpleAccent,
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            opportunity.title,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Organized by ${opportunity.displayOrganizer}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Pinned Tab Header
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 3,
                  labelColor: isDark ? Colors.white : AppColors.primary,
                  unselectedLabelColor: Colors.grey,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  tabs: const [
                    Tab(text: 'Overview'),
                    Tab(text: 'Requirements & Skills'),
                  ],
                ),
                backgroundColor: theme.scaffoldBackgroundColor,
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // TAB 1: OVERVIEW
            _buildOverviewTab(context, opportunity, isDark),

            // TAB 2: REQUIREMENTS & SKILLS
            _buildSkillsTab(context, opportunity, isDark),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context, opportunity),
    );
  }

  Widget _buildBadge({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildOverviewTab(
    BuildContext context,
    OpportunityModel opp,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark ? const Color(0xFF333333) : Colors.grey.shade200;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Key Highlights Grid
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              children: [
                _buildInfoRow(
                  icon: Icons.calendar_today_rounded,
                  iconColor: Colors.blueAccent,
                  label: 'Deadline',
                  value: opp.deadline != null
                      ? DateFormat('EEEE, MMM d, yyyy').format(opp.deadline!)
                      : 'Rolling / Not specified',
                  isDark: isDark,
                ),
                const Divider(height: 24),
                _buildInfoRow(
                  icon: Icons.emoji_events_rounded,
                  iconColor: Colors.amber,
                  label: 'Prizes Total',
                  value: opp.prizesTotal != null && opp.prizesTotal! > 0
                      ? '\$${NumberFormat('#,##0').format(opp.prizesTotal)}'
                      : 'Recognition / Non-cash',
                  isDark: isDark,
                ),
                const Divider(height: 24),
                _buildInfoRow(
                  icon: Icons.public_rounded,
                  iconColor: Colors.tealAccent,
                  label: 'Format & Location',
                  value: opp.locationType,
                  isDark: isDark,
                ),
                const Divider(height: 24),
                _buildInfoRow(
                  icon: Icons.source_rounded,
                  iconColor: Colors.purpleAccent,
                  label: 'Source Platform',
                  value: opp.source.isNotEmpty ? opp.source : 'AI Nexus',
                  isDark: isDark,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Description Section
          Text(
            'About This Opportunity',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Text(
              opp.description ?? 'No detailed description provided for this opportunity.',
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: isDark ? Colors.grey.shade300 : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsTab(
    BuildContext context,
    OpportunityModel opp,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark ? const Color(0xFF333333) : Colors.grey.shade200;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Required & Recommended Skills',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: opp.requiredSkills.isEmpty
                ? Text(
                    'No specific skills listed. All experience levels are welcome to apply!',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: opp.requiredSkills.map((skill) {
                      return Chip(
                        label: Text(skill),
                        backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                        labelStyle: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        side: BorderSide(
                          color: AppColors.primary.withValues(alpha: 0.3),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      );
                    }).toList(),
                  ),
          ),

          const SizedBox(height: 24),

          // Difficulty Assessment
          Text(
            'Target Level',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.trending_up_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      opp.difficulty ?? 'All Levels Welcome',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Appropriate for ${opp.difficulty?.toLowerCase() ?? 'all'} participants',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
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

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, OpportunityModel opp) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          decoration: BoxDecoration(
            color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.85),
            border: Border(
              top: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.grey.shade300,
              ),
            ),
          ),
          child: Row(
            children: [
              // External Link Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (opp.url.isNotEmpty) {
                      unawaited(
                        SharePlus.instance.share(
                          ShareParams(
                            text: 'Opportunity link: ${opp.url}',
                            subject: opp.title,
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.open_in_new_rounded, size: 18),
                  label: const Text(
                    'View & Apply',
                    style: TextStyle(
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
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar, {required this.backgroundColor});

  final TabBar _tabBar;
  final Color backgroundColor;

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: backgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
