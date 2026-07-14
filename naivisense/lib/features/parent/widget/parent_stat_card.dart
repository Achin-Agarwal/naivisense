import 'package:flutter/material.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';

class ParentStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;

  const ParentStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return Container(
      width: double.infinity,
      padding: r.allPadding(18, tablet: 20, desktop: 22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: r.borderRadius(20, tablet: 22, desktop: 24),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: r.w(54, tablet: 60, desktop: 66),
            width: r.w(54, tablet: 60, desktop: 66),
            decoration: BoxDecoration(
              color: color.withValues(alpha: .12),
              borderRadius: r.borderRadius(16, tablet: 18, desktop: 20),
            ),
            child: Icon(
              icon,
              color: color,
              size: r.icon(26, tablet: 28, desktop: 30),
            ),
          ),

          r.gapW(16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: r.sp(28, tablet: 32, desktop: 36),
                    fontWeight: FontWeight.bold,
                    color: color,
                    height: 1,
                  ),
                ),

                r.gapH(6),

                Text(
                  title,
                  style: TextStyle(
                    fontSize: r.sp(14, tablet: 15, desktop: 16),
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),

                if (subtitle != null) ...[
                  r.gapH(4),

                  Text(
                    subtitle!,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: r.sp(12, tablet: 13, desktop: 14),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
