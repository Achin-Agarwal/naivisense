import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';

class MiniScore extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const MiniScore(this.label, this.value, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$value',
          style: TextStyle(
            fontSize: r.sp(13, tablet: 14, desktop: 15),
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: r.sp(9, tablet: 10, desktop: 11),
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
