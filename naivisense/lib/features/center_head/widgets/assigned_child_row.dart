import 'package:flutter/material.dart';
import 'package:naivisense/data/models/therapist_overview.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';

class AssignedChildRow extends StatelessWidget {
  final TherapistChildSummary child;
  final bool showTherapyType;

  const AssignedChildRow({
    super.key,
    required this.child,
    this.showTherapyType = false,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    final (sevLabel, sevColor) = switch (child.severity) {
      'mild' => ('Mild', AppColors.mintGreen),
      'moderate' => ('Moderate', AppColors.warmYellow),
      'severe' => ('Severe', AppColors.softCoral),
      _ => ('—', AppColors.textSecondary),
    };

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: r.w(16, tablet: 20, desktop: 24),
        vertical: r.h(6, tablet: 8, desktop: 10),
      ),
      child: Row(
        children: [
          Icon(
            Icons.child_care,
            size: r.icon(16, tablet: 18, desktop: 20),
            color: AppColors.textSecondary,
          ),
          r.gapW(8, tablet: 10, desktop: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  child.name,
                  style: TextStyle(
                    fontSize: r.sp(13, tablet: 14, desktop: 15),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  showTherapyType && child.therapyType.isNotEmpty
                      ? '${child.therapyType}  •  ${child.diagnosis.join(', ')}'
                      : child.diagnosis.join(', '),
                  style: TextStyle(
                    fontSize: r.sp(11, tablet: 12, desktop: 13),
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: r.w(8, tablet: 10, desktop: 12),
              vertical: r.h(3, tablet: 4, desktop: 5),
            ),
            decoration: BoxDecoration(
              color: sevColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(
                r.radius(12, tablet: 14, desktop: 16),
              ),
              border: Border.all(color: sevColor.withValues(alpha: 0.3)),
            ),
            child: Text(
              sevLabel,
              style: TextStyle(
                fontSize: r.sp(10, tablet: 11, desktop: 12),
                fontWeight: FontWeight.w600,
                color: sevColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
