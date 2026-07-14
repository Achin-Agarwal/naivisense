import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';

class ScoreBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const ScoreBar({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    final pct = (value / 10).clamp(0.0, 1.0);

    return Row(
      children: [
        SizedBox(
          width: r.w(100, tablet: 125, desktop: 140),
          child: Text(
            label,
            style: TextStyle(
              fontSize: r.sp(12, tablet: 13, desktop: 14),
              color: AppColors.textSecondary,
            ),
          ),
        ),

        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              r.radius(4, tablet: 5, desktop: 6),
            ),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: color.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: r.h(8, tablet: 9, desktop: 10),
            ),
          ),
        ),

        r.gapW(8, tablet: 10, desktop: 12),

        SizedBox(
          width: r.w(36, tablet: 40, desktop: 42),
          child: Text(
            value.toStringAsFixed(1),
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: r.sp(12, tablet: 13, desktop: 14),
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
