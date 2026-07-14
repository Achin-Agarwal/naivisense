import 'package:flutter/material.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/theme/app_colors.dart';

class GradientHeader extends StatelessWidget {
  final String name;

  const GradientHeader({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(r.w(20, tablet: 24, desktop: 28)),
      decoration: BoxDecoration(
        gradient: AppColors.centerHeadGradient,
        borderRadius: BorderRadius.circular(
          r.radius(16, tablet: 18, desktop: 20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Center Dashboard',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontSize: r.sp(24, tablet: 28, desktop: 32),
            ),
          ),
          r.gapH(4, tablet: 6, desktop: 8),
          Text(
            'Overview of all therapists and children',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
              fontSize: r.sp(14, tablet: 15, desktop: 16),
            ),
          ),
        ],
      ),
    );
  }
}
