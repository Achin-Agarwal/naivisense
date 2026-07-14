import 'package:flutter/material.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';

class AssessmentHistoryRow extends StatelessWidget {
  final dynamic assessment;
  final VoidCallback onTap;

  const AssessmentHistoryRow({
    super.key,
    required this.assessment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

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
      'initial' => 'Initial',
      'monthly' => 'Monthly',
      'quarterly' => 'Quarterly',
      _ => type,
    };

    return InkWell(
      borderRadius: responsive.borderRadius(12),
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: responsive.h(8)),
        child: Row(
          children: [
            Container(
              width: responsive.w(10),
              height: responsive.w(10),
              decoration: BoxDecoration(
                color: riskColor,
                shape: BoxShape.circle,
              ),
            ),

            responsive.gapW(12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    typeLabel,
                    style: TextStyle(
                      fontSize: responsive.sp(14, tablet: 15, desktop: 16),
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  responsive.gapH(2, tablet: 4, desktop: 6),

                  Text(
                    '${date.day}/${date.month}/${date.year}',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: responsive.sp(12, tablet: 13, desktop: 14),
                    ),
                  ),
                ],
              ),
            ),

            Container(
              padding: EdgeInsets.symmetric(
                horizontal: responsive.w(12),
                vertical: responsive.h(6),
              ),
              decoration: BoxDecoration(
                color: riskColor.withValues(alpha: 0.12),
                borderRadius: responsive.borderRadius(20),
              ),
              child: Text(
                '${score.toStringAsFixed(0)}%',
                style: TextStyle(
                  color: riskColor,
                  fontWeight: FontWeight.bold,
                  fontSize: responsive.sp(13, tablet: 14, desktop: 15),
                ),
              ),
            ),

            responsive.gapW(8),

            Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: responsive.icon(20, tablet: 22, desktop: 24),
            ),
          ],
        ),
      ),
    );
  }
}
