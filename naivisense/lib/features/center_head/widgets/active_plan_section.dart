import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naivisense/core/utils/date_utils.dart';
import 'package:naivisense/data/models/home_plan.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import 'empty_card.dart';
import 'loading_card.dart';
import 'section_header.dart';
import 'task_group.dart';

class ActivePlanSection extends StatelessWidget {
  final AsyncValue<HomePlanModel?> plan;

  const ActivePlanSection({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Home Plan',
          icon: Icons.assignment_outlined,
        ),

        r.gapH(12, tablet: 14, desktop: 16),

        plan.when(
          loading: () => const LoadingCard(),

          error: (e, _) => const EmptyCard(message: 'Could not load plan'),

          data: (p) {
            if (p == null) {
              return const EmptyCard(message: 'No active home plan');
            }

            return Column(
              children: [
                Container(
                  padding: r.allPadding(14, tablet: 16, desktop: 18),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.06),
                    borderRadius: r.borderRadius(12, tablet: 14, desktop: 16),
                    border: Border.all(
                      color: AppColors.primaryBlue.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.date_range_outlined,
                        color: AppColors.primaryBlue,
                        size: r.icon(18, tablet: 20, desktop: 22),
                      ),

                      r.gapW(8, tablet: 10, desktop: 12),

                      Expanded(
                        child: Text(
                          '${AppDateUtils.formatDate(p.startDate)} → ${AppDateUtils.formatDate(p.endDate)}',
                          style: TextStyle(
                            fontSize: r.sp(13, tablet: 14, desktop: 15),
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ),

                      r.gapW(8, tablet: 10, desktop: 12),

                      Text(
                        '${p.tasks.length} tasks',
                        style: TextStyle(
                          fontSize: r.sp(12, tablet: 13, desktop: 14),
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                if (p.morningTasks.isNotEmpty) ...[
                  r.gapH(10, tablet: 12, desktop: 14),
                  TaskGroup(title: 'Morning', tasks: p.morningTasks),
                ],

                if (p.afternoonTasks.isNotEmpty) ...[
                  r.gapH(10, tablet: 12, desktop: 14),
                  TaskGroup(title: 'Afternoon', tasks: p.afternoonTasks),
                ],

                if (p.eveningTasks.isNotEmpty) ...[
                  r.gapH(10, tablet: 12, desktop: 14),
                  TaskGroup(title: 'Evening', tasks: p.eveningTasks),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}
