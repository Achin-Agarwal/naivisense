import 'package:flutter/material.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Gradient? gradient;

  const AppHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.description,
    this.icon = Icons.psychology,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return Column(
      children: [
        Container(
          width: r.w(82, tablet: 90, desktop: 100),
          height: r.w(82, tablet: 90, desktop: 100),
          decoration: BoxDecoration(
            gradient: gradient ?? AppColors.therapistGradient,
            borderRadius: r.borderRadius(22, tablet: 24, desktop: 26),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .05),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: r.icon(42, tablet: 46, desktop: 52),
          ),
        ),

        r.gapH(22, tablet: 26, desktop: 30),

        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: r.sp(28, tablet: 32, desktop: 36),
          ),
        ),

        r.gapH(8),

        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
            fontSize: r.sp(14, tablet: 15, desktop: 16),
          ),
        ),

        r.gapH(6),

        Text(
          description,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            fontSize: r.sp(13, tablet: 14, desktop: 15),
          ),
        ),
      ],
    );
  }
}
