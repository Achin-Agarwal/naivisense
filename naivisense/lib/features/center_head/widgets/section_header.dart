import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const SectionHeader({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return Row(
      children: [
        Container(
          padding: r.allPadding(8, tablet: 9, desktop: 10),
          decoration: BoxDecoration(
            color: AppColors.centerHeadGradient.colors.first.withValues(
              alpha: 0.1,
            ),
            borderRadius: r.borderRadius(10, tablet: 12, desktop: 14),
          ),
          child: Icon(
            icon,
            color: AppColors.centerHeadGradient.colors.first,
            size: r.icon(18, tablet: 20, desktop: 22),
          ),
        ),

        r.gapW(10, tablet: 12, desktop: 14),

        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: r.sp(20, tablet: 22, desktop: 24),
            ),
          ),
        ),
      ],
    );
  }
}
