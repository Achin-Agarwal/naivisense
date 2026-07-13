import 'package:flutter/material.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';

class ResponsiveErrorBanner extends StatelessWidget {
  final String message;
  final EdgeInsetsGeometry? margin;

  const ResponsiveErrorBanner({super.key, required this.message, this.margin});

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return Container(
      margin: margin ?? EdgeInsets.only(bottom: r.h(18)),
      padding: EdgeInsets.all(r.w(14, tablet: 16, desktop: 18)),
      decoration: BoxDecoration(
        color: AppColors.softCoral.withValues(alpha: .10),
        borderRadius: r.borderRadius(14),
        border: Border.all(color: AppColors.softCoral.withValues(alpha: .25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.softCoral,
            size: r.icon(20),
          ),

          r.gapW(12),

          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: AppColors.softCoral,
                fontSize: r.sp(13),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
