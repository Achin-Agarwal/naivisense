import 'package:flutter/material.dart';
import 'package:naivisense/core/utils/date_utils.dart';
import 'package:naivisense/data/models/alert.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';

class AlertHistoryCard extends StatelessWidget {
  final AlertModel alert;

  const AlertHistoryCard({super.key, required this.alert});

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    final (sevColor, _) = switch (alert.severity) {
      'high' => (AppColors.softCoral, 'High'),
      'critical' => (const Color(0xFFB00020), 'Critical'),
      'medium' => (AppColors.warmYellow, 'Medium'),
      _ => (AppColors.mintGreen, 'Low'),
    };

    final (statColor, statLabel) = switch (alert.status) {
      'resolved' => (AppColors.mintGreen, 'Resolved'),
      'seen' => (AppColors.primaryBlue, 'Seen'),
      _ => (AppColors.softCoral, 'Open'),
    };

    return Container(
      padding: EdgeInsets.all(r.w(14, tablet: 16, desktop: 18)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          r.radius(14, tablet: 16, desktop: 18),
        ),
        border: Border.all(
          color: alert.status == 'open'
              ? sevColor.withValues(alpha: 0.3)
              : AppColors.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: r.w(10, tablet: 11, desktop: 12),
                height: r.w(10, tablet: 11, desktop: 12),
                decoration: BoxDecoration(
                  color: sevColor,
                  shape: BoxShape.circle,
                ),
              ),

              r.gapW(8, tablet: 10, desktop: 12),

              Expanded(
                child: Text(
                  alert.typeLabel,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: r.sp(14, tablet: 15, desktop: 16),
                  ),
                ),
              ),

              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: r.w(10, tablet: 11, desktop: 12),
                  vertical: r.h(4, tablet: 5, desktop: 6),
                ),
                decoration: BoxDecoration(
                  color: statColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    r.radius(12, tablet: 13, desktop: 14),
                  ),
                ),
                child: Text(
                  statLabel,
                  style: TextStyle(
                    fontSize: r.sp(11, tablet: 12, desktop: 13),
                    fontWeight: FontWeight.w600,
                    color: statColor,
                  ),
                ),
              ),
            ],
          ),

          r.gapH(8, tablet: 9, desktop: 10),

          Text(
            alert.description,
            style: TextStyle(
              fontSize: r.sp(13, tablet: 14, desktop: 15),
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),

          r.gapH(6, tablet: 7, desktop: 8),

          Text(
            AppDateUtils.formatDate(alert.createdAt),
            style: TextStyle(
              fontSize: r.sp(11, tablet: 12, desktop: 13),
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
