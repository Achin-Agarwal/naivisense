import 'package:flutter/material.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const SectionTitle({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.primaryBlue,
          size: responsive.icon(20, tablet: 22, desktop: 24),
        ),

        responsive.gapW(8, tablet: 10, desktop: 12),

        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: responsive.sp(16, tablet: 18, desktop: 20),
            ),
          ),
        ),
      ],
    );
  }
}
