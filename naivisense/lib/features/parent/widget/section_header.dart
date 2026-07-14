import 'package:flutter/material.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? color;

  const SectionHeader({
    super.key,
    required this.title,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    final iconColor = color ?? AppColors.primaryBlue;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(r.w(8, tablet: 9, desktop: 10)),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.10),
            borderRadius: r.borderRadius(10),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: r.icon(18, tablet: 20, desktop: 22),
          ),
        ),

        r.gapW(10),

        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: r.sp(16, tablet: 17, desktop: 18),
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
