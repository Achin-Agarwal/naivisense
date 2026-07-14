import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/responsive.dart';

class ParentHomeHeader extends StatelessWidget {
  final String parentName;

  const ParentHomeHeader({super.key, required this.parentName});

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(r.w(20, tablet: 24, desktop: 28)),
      decoration: BoxDecoration(
        gradient: AppColors.parentGradient,
        borderRadius: r.borderRadius(18, tablet: 20, desktop: 24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: .12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome Back 👋",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: r.sp(14, tablet: 15, desktop: 16),
                    fontWeight: FontWeight.w500,
                  ),
                ),

                r.gapH(8),

                Text(
                  parentName,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: r.sp(28, tablet: 32, desktop: 36),
                  ),
                ),

                r.gapH(8),

                Text(
                  AppDateUtils.formatDate(DateTime.now()),
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: r.sp(13, tablet: 14, desktop: 15),
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: EdgeInsets.all(r.w(16, tablet: 18, desktop: 20)),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.family_restroom_rounded,
              color: Colors.white,
              size: r.icon(34, tablet: 38, desktop: 44),
            ),
          ),
        ],
      ),
    );
  }
}
