import 'package:flutter/material.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';

class SectionHeading extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? color;

  const SectionHeading({
    super.key,
    required this.title,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    final headingColor = color ?? AppColors.primaryBlue;

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(responsive.w(8)),
          decoration: BoxDecoration(
            color: headingColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(responsive.radius(10)),
          ),
          child: Icon(
            icon,
            color: headingColor,
            size: responsive.icon(18, tablet: 20, desktop: 22),
          ),
        ),

        responsive.gapW(10),

        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: responsive.sp(15, tablet: 16, desktop: 17),
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
