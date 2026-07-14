import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naivisense/data/models/child.dart';
import 'package:naivisense/data/models/therapist_overview.dart';
import 'package:naivisense/data/models/user.dart';
import 'package:naivisense/shared/widgets/stat_tile.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';

class DashboardStats extends StatelessWidget {
  final AsyncValue<List<ChildModel>> children;
  final AsyncValue<List<TherapistOverview>> therapists;
  final AsyncValue<List<UserModel>> parents;

  const DashboardStats({
    super.key,
    required this.children,
    required this.therapists,
    required this.parents,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    final childCount = children.valueOrNull?.length ?? 0;
    final therapistCount = therapists.valueOrNull?.length ?? 0;
    final parentCount = parents.valueOrNull?.length ?? 0;

    final crossAxisCount = r.isDesktop
        ? 6
        : r.isTablet
        ? 4
        : 3;

    final childAspectRatio = r.isDesktop
        ? 1.15
        : r.isTablet
        ? 1.3
        : 0.8;

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: r.h(12, tablet: 14, desktop: 16),
      crossAxisSpacing: r.w(12, tablet: 14, desktop: 16),
      childAspectRatio: childAspectRatio,
      children: [
        StatTile(
          label: 'Children',
          value: '$childCount',
          icon: Icons.child_care,
          iconColor: AppColors.primaryBlue,
        ),
        StatTile(
          label: 'Therapists',
          value: '$therapistCount',
          icon: Icons.medical_services_outlined,
          iconColor: AppColors.mintGreen,
        ),
        StatTile(
          label: 'Parents',
          value: '$parentCount',
          icon: Icons.family_restroom,
          iconColor: const Color(0xFF9B59B6),
        ),
      ],
    );
  }
}
