import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';

class QuickStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const QuickStat({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
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
        color: AppColors.surface,
        borderRadius: r.borderRadius(14, tablet: 16, desktop: 18),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: r.icon(22, tablet: 24, desktop: 26)),

          r.gapH(6, tablet: 7, desktop: 8),

          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: r.sp(20, tablet: 22, desktop: 24),
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),

          r.gapH(2),

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
