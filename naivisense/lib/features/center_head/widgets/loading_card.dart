import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';

class LoadingCard extends StatelessWidget {
  const LoadingCard({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return Container(
      height: r.h(60, tablet: 64, desktop: 68),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          r.radius(14, tablet: 16, desktop: 18),
        ),
        border: Border.all(color: AppColors.divider),
      ),
      child: Center(
        child: SizedBox(
          width: r.icon(24, tablet: 26, desktop: 28),
          height: r.icon(24, tablet: 26, desktop: 28),
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primaryBlue,
          ),
        ),
      ),
    );
  }
}
