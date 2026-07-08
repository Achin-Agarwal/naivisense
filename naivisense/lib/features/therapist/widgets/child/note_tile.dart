import 'package:flutter/material.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';

class NoteTile extends StatelessWidget {
  final String title;
  final String? value;
  final IconData icon;
  final Color color;

  const NoteTile({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (value == null || value!.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final responsive = Responsive(context);

    return Padding(
      padding: EdgeInsets.only(bottom: responsive.h(14)),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(responsive.w(14)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            responsive.radius(14, tablet: 16, desktop: 18),
          ),
          border: Border.all(color: AppColors.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(responsive.w(10)),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(responsive.radius(12)),
              ),
              child: Icon(
                icon,
                color: color,
                size: responsive.icon(20, tablet: 22, desktop: 24),
              ),
            ),

            responsive.gapW(14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: responsive.sp(14, tablet: 15, desktop: 16),
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  SizedBox(height: responsive.h(6)),

                  Text(
                    value!,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: responsive.sp(13, tablet: 14, desktop: 15),
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
