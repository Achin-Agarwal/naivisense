import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';

class SpecialtyChip extends StatelessWidget {
  final String label;

  const SpecialtyChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: r.w(10, tablet: 12, desktop: 14),
        vertical: r.h(4, tablet: 5, desktop: 6),
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(
          r.radius(20, tablet: 22, desktop: 24),
        ),
        border: Border.all(
          color: AppColors.primaryBlue.withValues(alpha: 0.25),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: r.sp(11, tablet: 12, desktop: 13),
          fontWeight: FontWeight.w500,
          color: AppColors.primaryBlue,
        ),
      ),
    );
  }
}
