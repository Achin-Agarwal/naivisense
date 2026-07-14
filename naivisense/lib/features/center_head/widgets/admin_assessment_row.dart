import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';

class AdminAssessmentRow extends StatelessWidget {
  final dynamic assessment;
  final VoidCallback onTap;

  const AdminAssessmentRow({
    super.key,
    required this.assessment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    final score = (assessment.overallScorePct as double?) ?? 0.0;
    final risk = assessment.riskLevel as String? ?? 'amber';
    final type = assessment.type as String? ?? '';
    final date = assessment.date as DateTime? ?? DateTime.now();

    final riskColor = switch (risk) {
      'green' => AppColors.mintGreen,
      'red' => AppColors.softCoral,
      _ => AppColors.warmYellow,
    };

    final typeLabel = switch (type) {
      'initial' => 'Initial Assessment',
      'monthly' => 'Monthly Reassessment',
      'quarterly' => 'Quarterly Review',
      _ => type,
    };

    final riskLabel = switch (risk) {
      'green' => 'Low Risk',
      'red' => 'High Risk',
      _ => 'Moderate',
    };

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: r.h(8, tablet: 10, desktop: 12)),
        padding: EdgeInsets.symmetric(
          horizontal: r.w(14, tablet: 16, desktop: 18),
          vertical: r.h(12, tablet: 14, desktop: 16),
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(
            r.radius(10, tablet: 12, desktop: 14),
          ),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Container(
              width: r.w(10, tablet: 11, desktop: 12),
              height: r.w(10, tablet: 11, desktop: 12),
              decoration: BoxDecoration(
                color: riskColor,
                shape: BoxShape.circle,
              ),
            ),

            r.gapW(12, tablet: 14, desktop: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    typeLabel,
                    style: TextStyle(
                      fontSize: r.sp(13, tablet: 14, desktop: 15),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${date.day}/${date.month}/${date.year}',
                    style: TextStyle(
                      fontSize: r.sp(11, tablet: 12, desktop: 13),
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${score.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: r.sp(16, tablet: 17, desktop: 18),
                    fontWeight: FontWeight.w800,
                    color: riskColor,
                  ),
                ),
                Text(
                  riskLabel,
                  style: TextStyle(
                    fontSize: r.sp(10, tablet: 11, desktop: 12),
                    color: riskColor,
                  ),
                ),
              ],
            ),

            r.gapW(6, tablet: 8, desktop: 10),

            Icon(
              Icons.chevron_right,
              size: r.icon(18, tablet: 20, desktop: 22),
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
