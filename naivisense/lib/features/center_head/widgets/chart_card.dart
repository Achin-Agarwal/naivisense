import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';

class ChartCard extends StatelessWidget {
  final Widget child;

  const ChartCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return Container(
      padding: r.allPadding(16, tablet: 18, desktop: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: r.borderRadius(16, tablet: 18, desktop: 20),
        border: Border.all(color: AppColors.divider),
      ),
      child: child,
    );
  }
}
