import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';

class SeverityBadge extends StatelessWidget {
  final String severity;

  const SeverityBadge({super.key, required this.severity});

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    final (label, color) = switch (severity) {
      'mild' => ('Mild', AppColors.mintGreen),
      'moderate' => ('Moderate', AppColors.warmYellow),
      'severe' => ('Severe', AppColors.softCoral),
      _ => ('—', Colors.white70),
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: r.w(10, tablet: 11, desktop: 12),
        vertical: r.h(4, tablet: 5, desktop: 6),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(
          r.radius(20, tablet: 22, desktop: 24),
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: r.sp(11, tablet: 12, desktop: 13),
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
