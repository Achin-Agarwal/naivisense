import 'package:flutter/material.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/data/models/goal.dart';

class GoalRow extends StatelessWidget {
  final GoalModel goal;

  const GoalRow({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    final (statusColor, icon) = switch (goal.status) {
      'completed' => (AppColors.mintGreen, Icons.check_circle_rounded),
      'active' => (AppColors.primaryBlue, Icons.play_circle_fill_rounded),
      'accepted' => (AppColors.mintGreen, Icons.thumb_up_alt_rounded),
      'paused' => (AppColors.warmYellow, Icons.pause_circle_filled_rounded),
      _ => (AppColors.textSecondary, Icons.radio_button_unchecked_rounded),
    };

    return Container(
      margin: EdgeInsets.only(bottom: responsive.h(12)),
      padding: EdgeInsets.all(responsive.w(14, tablet: 16, desktop: 18)),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: responsive.borderRadius(14, tablet: 16, desktop: 18),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(responsive.w(10)),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: .12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: statusColor,
              size: responsive.icon(20, tablet: 22, desktop: 24),
            ),
          ),

          responsive.gapW(12, tablet: 14, desktop: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: responsive.sp(14, tablet: 15, desktop: 16),
                  ),
                ),

                if (goal.description != null &&
                    goal.description!.trim().isNotEmpty) ...[
                  responsive.gapH(4),
                  Text(
                    goal.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: responsive.sp(12, tablet: 13, desktop: 14),
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),

          responsive.gapW(12, tablet: 14, desktop: 16),

          Container(
            padding: EdgeInsets.symmetric(
              horizontal: responsive.w(12),
              vertical: responsive.h(6),
            ),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: .12),
              borderRadius: responsive.borderRadius(20),
            ),
            child: Text(
              goal.statusLabel,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.w600,
                fontSize: responsive.sp(11, tablet: 12, desktop: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
