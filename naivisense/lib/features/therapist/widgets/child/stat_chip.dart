import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/app_card.dart';
import 'stat_data.dart';

class StatChip extends StatelessWidget {
  final StatData data;

  const StatChip({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    return AppCard(
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(responsive.w(10)),
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              data.icon,
              color: data.color,
              size: responsive.icon(22),
            ),
          ),

          responsive.gapW(12,tablet: 14, desktop: 16),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: responsive.sp(20),
                  ),
                ),

                responsive.gapH(4),

                Text(
                  data.label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: responsive.sp(13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
