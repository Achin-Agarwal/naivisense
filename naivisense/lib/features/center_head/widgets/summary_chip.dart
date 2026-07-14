import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';

class SummaryChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const SummaryChip({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: r.h(14, tablet: 16, desktop: 18),
        horizontal: r.w(12, tablet: 14, desktop: 16),
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(
          r.radius(12, tablet: 14, desktop: 16),
        ),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: r.sp(20, tablet: 22, desktop: 24),
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),

          r.gapH(4, tablet: 5, desktop: 6),

          Text(
            label,
            textAlign: TextAlign.center,
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
