import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naivisense/features/therapist/widgets/child/section_title.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../data/models/home_plan.dart';
import '../../../../shared/widgets/state_widgets.dart' as sw;

class ActivePlanCard extends StatelessWidget {
  final AsyncValue<HomePlanModel?> plan;

  const ActivePlanCard({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    return ProfileCard(
      title: 'Home Plan',
      icon: Icons.assignment_outlined,
      child: plan.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primaryBlue,
            ),
          ),
        ),

        error: (e, _) => const sw.EmptyWidget(
          message: 'Could not load plan',
          icon: Icons.error_outline,
        ),

        data: (p) {
          if (p == null) {
            return const sw.EmptyWidget(
              message: 'No active home plan',
              icon: Icons.assignment_outlined,
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: responsive.w(8),
                runSpacing: responsive.h(8),
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Icon(
                    Icons.date_range_outlined,
                    color: AppColors.textSecondary,
                    size: responsive.icon(18),
                  ),

                  Text(
                    '${AppDateUtils.formatDate(p.startDate)} → ${AppDateUtils.formatDate(p.endDate)}',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: responsive.sp(12),
                    ),
                  ),

                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.w(10),
                      vertical: responsive.h(4),
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${p.tasks.length} Tasks',
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w600,
                        fontSize: responsive.sp(11),
                      ),
                    ),
                  ),
                ],
              ),

              responsive.gapH(12, tablet: 16, desktop: 20),

              ...p.tasks
                  .take(4)
                  .map(
                    (task) => Padding(
                      padding: EdgeInsets.only(bottom: responsive.h(12)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.icon,
                            style: TextStyle(fontSize: responsive.sp(20)),
                          ),

                          responsive.gapW(12, tablet: 16, desktop: 20),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  task.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: responsive.sp(14),
                                  ),
                                ),

                                responsive.gapH(2, tablet: 4, desktop: 6),

                                Text(
                                  '${task.timeOfDay} • ${task.durationMin} min • ${task.frequency}',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: responsive.sp(12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

              if (p.tasks.length > 4)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      '+ ${p.tasks.length - 4} more tasks',
                      style: TextStyle(fontSize: responsive.sp(12)),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
