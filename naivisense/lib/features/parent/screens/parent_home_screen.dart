import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/child.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/state_widgets.dart' as sw;
import '../providers/parent_provider.dart';

class ParentHomeScreen extends ConsumerWidget {
  const ParentHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).valueOrNull?.user;
    final children = ref.watch(parentChildrenProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        // ===========================
        // Responsive Breakpoints
        // ===========================

        final width = constraints.maxWidth;

        final isMobile = width < 600;
        final isTablet = width >= 600 && width < 1024;
        final isDesktop = width >= 1024;

        final screenWidth = MediaQuery.of(context).size.width;

        // Responsive sizing
        final horizontalPadding = isMobile ? 16.0 : 24.0;
        final headerPadding = isMobile ? 20.0 : 28.0;

        final avatarSize = isMobile
            ? 28.0
            : isTablet
            ? 34.0
            : 40.0;

        final titleSize = isMobile
            ? 28.0
            : isTablet
            ? 34.0
            : 38.0;

        final subtitleSize = isMobile ? 13.0 : 15.0;

        // Grid columns
        final childGridCount = isMobile
            ? 1
            : isTablet
            ? 2
            : 3;

        return Scaffold(
          backgroundColor: AppColors.background,

          appBar: AppBar(
            title: Text(
              'Hi, ${user?.name.split(' ').first ?? 'Parent'}',
              style: TextStyle(
                fontSize: isMobile ? 20 : 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: AppColors.surface,
            elevation: 0,
            actions: [
              IconButton(
                icon: Icon(
                  Icons.auto_awesome_outlined,
                  size: isMobile ? 22 : 26,
                ),
                tooltip: 'AI Chat',
                onPressed: () => context.go('/parent/chatbot'),
              ),

              IconButton(
                icon: Icon(Icons.logout, size: isMobile ? 22 : 26),
                onPressed: () => ref.read(authProvider.notifier).logout(),
              ),
            ],
          ),

          body: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(parentChildrenProvider);
            },

            child: CustomScrollView(
              slivers: [
                // ==================================================
                // Header
                // ==================================================
                SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),

                      child: Container(
                        margin: EdgeInsets.all(horizontalPadding),

                        padding: EdgeInsets.all(headerPadding),

                        decoration: BoxDecoration(
                          gradient: AppColors.parentGradient,
                          borderRadius: BorderRadius.circular(
                            MediaQuery.of(context).size.width < 600 ? 16 : 20,
                          ),
                        ),

                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  Text(
                                    "Welcome back,",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Colors.white70,
                                          fontSize: subtitleSize,
                                        ),
                                  ),

                                  SizedBox(height: screenWidth * 0.01),

                                  Text(
                                    user?.name.split(" ").first ?? "",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: titleSize,
                                        ),
                                  ),

                                  SizedBox(height: isMobile ? 6 : 10),

                                  Text(
                                    AppDateUtils.formatDate(DateTime.now()),
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: subtitleSize,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Container(
                              padding: EdgeInsets.all(avatarSize * 0.45),

                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.20),
                                shape: BoxShape.circle,
                              ),

                              child: Icon(
                                Icons.family_restroom,
                                size: avatarSize,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ==================================================
                // Main Content
                // ==================================================
                SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),

                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                          vertical: 8,
                        ),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            _buildStats(context, children, isMobile),

                            SizedBox(height: isMobile ? 24 : 32),

                            Text(
                              "Your Children",
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontSize: isMobile ? 24 : 28),
                            ),

                            SizedBox(height: isMobile ? 16 : 20),

                            children.when(
                              loading: () => const sw.LoadingWidget(),

                              error: (e, _) =>
                                  sw.ErrorWidget(message: e.toString()),

                              data: (list) {
                                if (list.isEmpty) {
                                  return const sw.EmptyWidget(
                                    message: "No children registered yet",
                                    icon: Icons.child_care,
                                  );
                                }

                                // =====================================
                                // Responsive Grid
                                // =====================================

                                return GridView.builder(
                                  shrinkWrap: true,

                                  physics: const NeverScrollableScrollPhysics(),

                                  itemCount: list.length,

                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: childGridCount,

                                        crossAxisSpacing: 16,

                                        mainAxisSpacing: 16,

                                        childAspectRatio: isMobile
                                            ? 1.50
                                            : isTablet
                                            ? 1.25
                                            : 1.20,
                                      ),

                                  itemBuilder: (context, index) {
                                    return _ChildSummaryCard(
                                      child: list[index],
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // =======================================================
  // Responsive Stats Section
  // =======================================================

  Widget _buildStats(
    BuildContext context,
    AsyncValue<List<ChildModel>> children,
    bool isMobile,
  ) {
    final count = children.valueOrNull?.length ?? 0;

    if (isMobile) {
      return Column(
        children: [
          _StatCard(
            label: "Children",
            value: "$count",
            icon: Icons.child_care,
            color: AppColors.primaryBlue,
          ),

          SizedBox(height: isMobile ? 12 : 16),

          _StatCard(
            label: "Active Plans",
            value: "$count",
            icon: Icons.assignment_outlined,
            color: AppColors.mintGreen,
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: "Children",
            value: "$count",
            icon: Icons.child_care,
            color: AppColors.primaryBlue,
          ),
        ),

        SizedBox(width: isMobile ? 12 : 16),

        Expanded(
          child: _StatCard(
            label: "Active Plans",
            value: "$count",
            icon: Icons.assignment_outlined,
            color: AppColors.mintGreen,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Responsive Stat Card
// ─────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final isMobile = width < 600;
    final isTablet = width >= 600 && width < 1024;

    final iconSize = isMobile
        ? 20.0
        : isTablet
        ? 24.0
        : 28.0;
    final valueSize = isMobile
        ? 22.0
        : isTablet
        ? 26.0
        : 30.0;
    final labelSize = isMobile ? 12.0 : 14.0;
    final padding = isMobile ? 16.0 : 20.0;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          MediaQuery.of(context).size.width < 600 ? 16 : 20,
        ),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 10 : 14),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(
                MediaQuery.of(context).size.width < 600 ? 12 : 16,
              ),
            ),
            child: Icon(icon, size: iconSize, color: color),
          ),
          SizedBox(width: isMobile ? 12 : 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: valueSize,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: labelSize,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Responsive Child Summary Card
// ─────────────────────────────────────────────────────────────

class _ChildSummaryCard extends ConsumerWidget {
  final ChildModel child;

  const _ChildSummaryCard({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(parentSessionsProvider(child.id));
    final plan = ref.watch(parentActivePlanProvider(child.id));

    final width = MediaQuery.of(context).size.width;

    final isMobile = width < 600;
    final isTablet = width >= 600 && width < 1024;

    final avatarRadius = isMobile
        ? 26.0
        : isTablet
        ? 30.0
        : 34.0;
    final avatarText = isMobile ? 20.0 : 24.0;
    final titleSize = isMobile ? 16.0 : 18.0;
    final subtitleSize = isMobile ? 12.0 : 13.0;

    final upcoming =
        sessions.valueOrNull
            ?.where(
              (s) =>
                  s.status == 'scheduled' &&
                  s.scheduledAt.isAfter(DateTime.now()),
            )
            .toList()
          ?..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

    return AppCard(
      onTap: () => context.push('/parent/child/${child.id}', extra: child),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Responsive header row
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              CircleAvatar(
                radius: avatarRadius,
                backgroundColor: AppColors.mintGreen.withValues(alpha: .15),
                child: Text(
                  child.name[0].toUpperCase(),
                  style: TextStyle(
                    color: AppColors.mintGreen,
                    fontWeight: FontWeight.w700,
                    fontSize: avatarText,
                  ),
                ),
              ),

              SizedBox(width: isMobile ? 12 : 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: titleSize,
                      ),
                    ),

                    SizedBox(height: isMobile ? 4 : 6),

                    Text(
                      '${child.ageYears} yrs • ${child.diagnosis.join(", ")}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: subtitleSize,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: isMobile ? 8 : 12),

              Flexible(child: _SeverityBadge(severity: child.severity)),
            ],
          ),

          SizedBox(height: isMobile ? 14 : 18),

          // Wrap prevents overflow
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              SizedBox(
                width: isMobile ? double.infinity : 220,
                child: _InfoChip(
                  icon: Icons.assignment_outlined,
                  color: AppColors.primaryBlue,
                  label: plan.valueOrNull != null
                      ? '${plan.valueOrNull!.tasks.length} tasks this week'
                      : 'No active plan',
                ),
              ),

              SizedBox(
                width: isMobile ? double.infinity : 220,
                child: _InfoChip(
                  icon: Icons.event_outlined,
                  color: AppColors.mintGreen,
                  label: (upcoming?.isNotEmpty ?? false)
                      ? AppDateUtils.formatDate(upcoming!.first.scheduledAt)
                      : 'No upcoming session',
                ),
              ),
            ],
          ),

          SizedBox(height: isMobile ? 12 : 18),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () =>
                  context.push('/parent/child/${child.id}', extra: child),
              icon: Icon(Icons.arrow_forward, size: isMobile ? 16 : 18),
              label: Text(
                'View Details',
                style: TextStyle(fontSize: isMobile ? 13 : 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Responsive Severity Badge
// ─────────────────────────────────────────────────────────────

class _SeverityBadge extends StatelessWidget {
  final String severity;

  const _SeverityBadge({required this.severity});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (severity) {
      'mild' => ('Mild', AppColors.mintGreen),
      'moderate' => ('Moderate', AppColors.warmYellow),
      'severe' => ('Severe', AppColors.softCoral),
      _ => ('—', AppColors.textSecondary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(
          MediaQuery.of(context).size.width < 600 ? 16 : 20,
        ),
        border: Border.all(color: color.withValues(alpha: .30)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: color,
          fontSize: 11,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Responsive Info Chip
// ─────────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final isMobile = width < 600;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 10 : 14,
        vertical: isMobile ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .07),
        borderRadius: BorderRadius.circular(
          MediaQuery.of(context).size.width < 600 ? 12 : 16,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: isMobile ? 14 : 18),

          SizedBox(width: isMobile ? 8 : 12),

          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: isMobile ? 12 : 13, color: color),
            ),
          ),
        ],
      ),
    );
  }
}
