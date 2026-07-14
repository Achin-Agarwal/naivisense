import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';

class InlineStaffCard extends StatelessWidget {
  final String name;
  final String phone;
  final String role;
  final Color roleColor;
  final IconData roleIcon;
  final String subtitle;

  const InlineStaffCard({
    super.key,
    required this.name,
    required this.phone,
    required this.role,
    required this.roleColor,
    required this.roleIcon,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Container(
      padding: r.allPadding(16, tablet: 18, desktop: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: r.borderRadius(16, tablet: 18, desktop: 20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: r.avatar(24, tablet: 26, desktop: 28),
            backgroundColor: roleColor.withValues(alpha: 0.12),
            child: Text(
              initial,
              style: TextStyle(
                color: roleColor,
                fontWeight: FontWeight.w700,
                fontSize: r.sp(18, tablet: 19, desktop: 20),
              ),
            ),
          ),

          r.gapW(14, tablet: 16, desktop: 18),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: r.sp(15, tablet: 16, desktop: 17),
                  ),
                ),

                r.gapH(2),

                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: r.sp(12, tablet: 13, desktop: 14),
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: EdgeInsets.symmetric(
              horizontal: r.w(10, tablet: 11, desktop: 12),
              vertical: r.h(5, tablet: 5.5, desktop: 6),
            ),
            decoration: BoxDecoration(
              color: roleColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(
                r.radius(20, tablet: 22, desktop: 24),
              ),
              border: Border.all(color: roleColor.withValues(alpha: 0.25)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  roleIcon,
                  color: roleColor,
                  size: r.icon(13, tablet: 14, desktop: 15),
                ),

                r.gapW(4),

                Text(
                  role,
                  style: TextStyle(
                    fontSize: r.sp(11, tablet: 12, desktop: 13),
                    fontWeight: FontWeight.w600,
                    color: roleColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
