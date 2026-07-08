import 'package:flutter/material.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';

class ScoreChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const ScoreChip({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.w(12),
        vertical: responsive.h(8),
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: responsive.borderRadius(12, tablet: 14, desktop: 16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$value',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: responsive.sp(16, tablet: 17, desktop: 18),
            ),
          ),
          responsive.gapH(2),
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: responsive.sp(11, tablet: 12, desktop: 13),
            ),
          ),
        ],
      ),
    );
  }
}
