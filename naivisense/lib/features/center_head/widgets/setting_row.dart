import 'package:flutter/material.dart';
import 'package:naivisense/features/center_head/screens/settings_screen.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';

class SettingRow extends StatelessWidget {
  final SettingsEntry entry;
  final VoidCallback onDelete;

  const SettingRow({super.key, required this.entry, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return Container(
      margin: EdgeInsets.only(bottom: r.h(10, tablet: 12, desktop: 14)),
      padding: EdgeInsets.symmetric(
        horizontal: r.w(14, tablet: 16, desktop: 18),
        vertical: r.h(12, tablet: 14, desktop: 16),
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          r.radius(12, tablet: 14, desktop: 16),
        ),
        border: Border.all(color: AppColors.divider),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: r.w(12, tablet: 14, desktop: 16),
        runSpacing: r.h(12, tablet: 14, desktop: 16),
        children: [
          SizedBox(
            width: r.isMobile
                ? r.screenWidth * 0.60
                : r.isTablet
                ? 420
                : 520,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.key,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: r.sp(13, tablet: 14, desktop: 15),
                  ),
                ),
                r.gapH(4, tablet: 5, desktop: 6),
                Text(
                  '${entry.value}',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: r.sp(12, tablet: 13, desktop: 14),
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            splashRadius: r.w(24, tablet: 26, desktop: 28),
            icon: Icon(
              Icons.delete_outline,
              size: r.icon(20, tablet: 22, desktop: 24),
              color: AppColors.softCoral,
            ),
          ),
        ],
      ),
    );
  }
}
