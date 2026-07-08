import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';

class StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? iconColor;

  const StatTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);
    final theme = Theme.of(context);

    return Container(
      padding: r.allPadding(10, tablet: 12, desktop: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: r.borderRadius(12, tablet: 14, desktop: 16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: iconColor ?? AppColors.primaryBlue,
            size: r.icon(20, tablet: 22, desktop: 24),
          ),

          r.gapH(6),

          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontSize: r.sp(18, tablet: 20, desktop: 22),
              fontWeight: FontWeight.bold,
            ),
          ),

          r.gapH(2),

          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: r.sp(12, tablet: 13, desktop: 14),
            ),
          ),
        ],
      ),
    );
  }
}
