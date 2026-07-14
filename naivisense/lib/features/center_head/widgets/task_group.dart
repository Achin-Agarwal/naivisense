import 'package:flutter/material.dart';
import 'package:naivisense/data/models/home_plan.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';

class TaskGroup extends StatelessWidget {
  final String title;
  final List<HomePlanTask> tasks;

  const TaskGroup({super.key, required this.title, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return Container(
      padding: r.allPadding(14, tablet: 16, desktop: 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: r.borderRadius(14, tablet: 16, desktop: 18),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: r.sp(13, tablet: 14, desktop: 15),
              color: AppColors.textSecondary,
            ),
          ),

          r.gapH(8, tablet: 10, desktop: 12),

          ...tasks.map(
            (t) => Padding(
              padding: EdgeInsets.only(bottom: r.h(8, tablet: 10, desktop: 12)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.icon,
                    style: TextStyle(
                      fontSize: r.sp(18, tablet: 19, desktop: 20),
                    ),
                  ),

                  r.gapW(10, tablet: 11, desktop: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: r.sp(13, tablet: 14, desktop: 15),
                          ),
                        ),

                        Text(
                          '${t.durationMin} min  •  ${t.frequency}  •  ×${t.targetCount}',
                          style: TextStyle(
                            fontSize: r.sp(11, tablet: 12, desktop: 13),
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
