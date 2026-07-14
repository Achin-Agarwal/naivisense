import 'package:flutter/material.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';

class TappableField extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const TappableField({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(
            responsive.radius(12, tablet: 14, desktop: 14),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: responsive.w(10, tablet: 12, desktop: 14),
              vertical: responsive.h(14, tablet: 16, desktop: 18),
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.divider),
              borderRadius: BorderRadius.circular(
                responsive.radius(12, tablet: 14, desktop: 14),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: responsive.icon(18, tablet: 20, desktop: 22),
                  color: AppColors.textSecondary,
                ),

                SizedBox(width: responsive.w(8, tablet: 10, desktop: 12)),

                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: TextStyle(
                      fontSize: responsive.sp(14, tablet: 15, desktop: 16),
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
