import 'package:flutter/material.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';

class EmptyHint extends StatelessWidget {
  final String message;
  final IconData? icon;

  const EmptyHint({super.key, required this.message, this.icon});

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(r.w(16, tablet: 18, desktop: 20)),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: r.borderRadius(14, tablet: 16, desktop: 18),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: AppColors.textSecondary,
              size: r.icon(18, tablet: 20, desktop: 22),
            ),
            r.gapW(10),
          ],

          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: r.sp(13, tablet: 14, desktop: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
