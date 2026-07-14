import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';

class EmptyCard extends StatelessWidget {
  final String message;

  const EmptyCard({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return Container(
      width: double.infinity,
      padding: r.allPadding(20, tablet: 22, desktop: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: r.borderRadius(14, tablet: 16, desktop: 18),
        border: Border.all(color: AppColors.divider),
      ),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: r.sp(13, tablet: 14, desktop: 15),
          ),
        ),
      ),
    );
  }
}
