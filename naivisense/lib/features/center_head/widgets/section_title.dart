import 'package:flutter/material.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';


class SectionTitle extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color? color;
  final Color? iconColor;

  const SectionTitle({
    super.key,
    required this.text,
    required this.icon,
    this.color,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return Row(
      children: [
        Icon(
          icon,
          color: iconColor ?? AppColors.primaryBlue,
          size: r.icon(
            22,
            tablet: 25,
            desktop: 28,
          ),
        ),

        SizedBox(width: r.w(
          8,
          tablet: 10,
          desktop: 12,
        )),

        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: r.sp(
                17,
                tablet: 19,
                desktop: 22,
              ),
              fontWeight: FontWeight.w600,
              color: color ?? AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}