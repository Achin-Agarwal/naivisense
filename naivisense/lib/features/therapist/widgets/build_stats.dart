import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/shared/widgets/stat_tile.dart';

class DashboardStats extends StatelessWidget {
  const DashboardStats({
    super.key,
    required this.children,
    required this.sessions,
    required this.pending,
  });

  final AsyncValue children;
  final AsyncValue sessions;
  final AsyncValue pending;

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    final childCount = children.valueOrNull?.length ?? 0;
    final sessionCount = sessions.valueOrNull?.length ?? 0;
    final pendingCount = pending.valueOrNull?.length ?? 0;

    return GridView.count(
      crossAxisCount: responsive
          .value(mobile: 1, tablet: 3, desktop: 4)
          .toInt(),

      childAspectRatio: responsive.w(2.8, tablet: 2, desktop: 1.5),

      mainAxisSpacing: responsive.w(12, tablet: 16, desktop: 20),

      crossAxisSpacing: responsive.w(12, tablet: 16, desktop: 20),

      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),

      children: [
        StatTile(
          label: 'Children',
          value: '$childCount',
          icon: Icons.child_care,
          iconColor: AppColors.primaryBlue,
        ),
        StatTile(
          label: 'Sessions',
          value: '$sessionCount',
          icon: Icons.event_note,
          iconColor: AppColors.mintGreen,
        ),
        StatTile(
          label: 'Pending',
          value: '$pendingCount',
          icon: Icons.pending_actions,
          iconColor: AppColors.warmYellow,
        ),
      ],
    );
  }
}
