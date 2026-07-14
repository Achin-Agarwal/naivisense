import 'package:flutter/material.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';

class AiButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const AiButton({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    return SizedBox(
      height: responsive.h(42, tablet: 46, desktop: 48),
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryBlue,
          side: BorderSide(
            color: AppColors.primaryBlue.withValues(alpha: 0.35),
          ),
          backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.04),
          shape: RoundedRectangleBorder(
            borderRadius: responsive.borderRadius(12, tablet: 14, desktop: 16),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: responsive.w(16, tablet: 18, desktop: 22),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: responsive.sp(13, tablet: 14, desktop: 15),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
