import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';

class DiagnosisSection extends StatelessWidget {
  final List<String> diagnosis;

  const DiagnosisSection({super.key, required this.diagnosis});

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Diagnosis',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppColors.textSecondary,
            fontSize: r.sp(14, tablet: 15, desktop: 16),
          ),
        ),

        r.gapH(8, tablet: 10, desktop: 12),

        Wrap(
          spacing: r.w(8, tablet: 10, desktop: 12),
          runSpacing: r.h(6, tablet: 8, desktop: 10),
          children: diagnosis
              .map(
                (item) => Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: r.w(12, tablet: 14, desktop: 16),
                    vertical: r.h(6, tablet: 7, desktop: 8),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.centerHeadGradient.colors.first.withValues(
                      alpha: 0.1,
                    ),
                    borderRadius: r.borderRadius(20, tablet: 22, desktop: 24),
                    border: Border.all(
                      color: AppColors.centerHeadGradient.colors.first
                          .withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: r.sp(12, tablet: 13, desktop: 14),
                      fontWeight: FontWeight.w500,
                      color: AppColors.centerHeadGradient.colors.first,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
