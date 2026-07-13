import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/features/center_head/widgets/children_section.dart';
import 'package:naivisense/features/center_head/widgets/dashboard_stats.dart';
import 'package:naivisense/features/center_head/widgets/gradient_header.dart';
import 'package:naivisense/features/center_head/widgets/parents_section.dart';
import 'package:naivisense/features/center_head/widgets/therapists_section.dart';

import '../../../core/theme/app_colors.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../providers/center_head_provider.dart';

class CenterHeadHomeScreen extends ConsumerWidget {
  const CenterHeadHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = Responsive(context);
    final user = ref.watch(authProvider).valueOrNull?.user;
    final children = ref.watch(centerChildrenProvider);
    final therapists = ref.watch(therapistsOverviewProvider);
    final parents = ref.watch(allParentsProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(
              user?.name ?? 'Center Head',
              style: TextStyle(fontSize: r.sp(20, tablet: 22, desktop: 24)),
            ),
            backgroundColor: AppColors.surface,
            elevation: 0,
            actions: [
              IconButton(
                icon: Icon(
                  Icons.payments_outlined,
                  size: r.icon(24, tablet: 26, desktop: 28),
                ),
                tooltip: 'Payments',
                onPressed: () => context.push('/center-head/payments'),
              ),
              IconButton(
                icon: Icon(
                  Icons.settings_outlined,
                  size: r.icon(24, tablet: 26, desktop: 28),
                ),
                tooltip: 'Settings',
                onPressed: () => context.push('/center-head/settings'),
              ),
              IconButton(
                icon: Icon(
                  Icons.logout,
                  size: r.icon(24, tablet: 26, desktop: 28),
                ),
                onPressed: () => ref.read(authProvider.notifier).logout(),
              ),
            ],
          ),
          floatingActionButton: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FloatingActionButton.extended(
                heroTag: 'enroll_therapist',
                onPressed: () => context.push('/center-head/enroll-therapist'),
                backgroundColor: AppColors.mintGreen,
                icon: Icon(
                  Icons.psychology_outlined,
                  color: Colors.white,
                  size: r.icon(22, tablet: 24, desktop: 26),
                ),
                label: Text(
                  'Enroll Therapist',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: r.sp(14, tablet: 15, desktop: 16),
                  ),
                ),
              ),
              r.gapH(12, tablet: 14, desktop: 16),
              FloatingActionButton.extended(
                heroTag: 'register_parent',
                onPressed: () => context.push('/center-head/enroll-parent'),
                backgroundColor: const Color(0xFF9B59B6),
                icon: Icon(
                  Icons.family_restroom,
                  color: Colors.white,
                  size: r.icon(22, tablet: 24, desktop: 26),
                ),
                label: Text(
                  'Register Parent',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: r.sp(14, tablet: 15, desktop: 16),
                  ),
                ),
              ),
              r.gapH(12, tablet: 14, desktop: 16),
              FloatingActionButton.extended(
                heroTag: 'enroll_child',
                onPressed: () => context.push('/center-head/enroll'),
                backgroundColor: AppColors.primaryBlue,
                icon: Icon(
                  Icons.person_add_outlined,
                  color: Colors.white,
                  size: r.icon(22, tablet: 24, desktop: 26),
                ),
                label: Text(
                  'Enroll Child',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: r.sp(14, tablet: 15, desktop: 16),
                  ),
                ),
              ),
            ],
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: r.isDesktop ? 1200 : r.maxWidth,
              ),
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(centerChildrenProvider);
                  ref.invalidate(therapistsOverviewProvider);
                  ref.invalidate(allParentsProvider);
                },
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: r.horizontalPadding,
                        vertical: r.verticalPadding,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          GradientHeader(name: user?.name ?? ''),

                          r.gapH(20, tablet: 24, desktop: 28),

                          DashboardStats(
                            children: children,
                            therapists: therapists,
                            parents: parents,
                          ),

                          r.gapH(24, tablet: 28, desktop: 32),

                          TherapistsSection(therapists: therapists),

                          r.gapH(24, tablet: 28, desktop: 32),

                          ParentsSection(parents: parents, children: children),

                          r.gapH(24, tablet: 28, desktop: 32),

                          ChildrenSection(children: children),

                          r.gapH(24, tablet: 28, desktop: 32),
                        ]),
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
}
