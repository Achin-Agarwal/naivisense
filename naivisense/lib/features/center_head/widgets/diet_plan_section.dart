import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naivisense/core/utils/date_utils.dart';
import 'package:naivisense/data/models/diet_plan.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import 'empty_card.dart';
import 'loading_card.dart';
import 'section_header.dart';

class DietPlanSection extends StatelessWidget {
  final AsyncValue<DietPlanModel?> plan;

  const DietPlanSection({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Diet Chart',
          icon: Icons.restaurant_outlined,
        ),

        r.gapH(12, tablet: 14, desktop: 16),

        plan.when(
          loading: () => const LoadingCard(),

          error: (e, _) => const EmptyCard(message: 'Could not load diet plan'),

          data: (p) {
            if (p == null) {
              return const EmptyCard(message: 'No active diet plan');
            }

            return Container(
              padding: r.allPadding(14, tablet: 16, desktop: 18),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: r.borderRadius(12, tablet: 14, desktop: 16),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${AppDateUtils.formatDate(p.startDate)} → ${AppDateUtils.formatDate(p.endDate)}',
                          style: TextStyle(
                            fontSize: r.sp(12, tablet: 13, desktop: 14),
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),

                      r.gapW(8, tablet: 10, desktop: 12),

                      Text(
                        '${p.meals.length} meals',
                        style: TextStyle(
                          fontSize: r.sp(12, tablet: 13, desktop: 14),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  r.gapH(10, tablet: 12, desktop: 14),

                  ...p.meals
                      .take(6)
                      .map(
                        (m) => Padding(
                          padding: EdgeInsets.only(
                            bottom: r.h(6, tablet: 8, desktop: 10),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${m.mealTime.toUpperCase()}: ${m.name}',
                                  style: TextStyle(
                                    fontSize: r.sp(13, tablet: 14, desktop: 15),
                                  ),
                                ),
                              ),

                              r.gapW(8, tablet: 10, desktop: 12),

                              Text(
                                '${m.caloriesApprox} kcal',
                                style: TextStyle(
                                  fontSize: r.sp(12, tablet: 13, desktop: 14),
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                  if (p.meals.length > 6)
                    Text(
                      '+ ${p.meals.length - 6} more',
                      style: TextStyle(
                        fontSize: r.sp(11, tablet: 12, desktop: 13),
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
