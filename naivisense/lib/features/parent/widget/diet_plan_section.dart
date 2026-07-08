import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/date_utils.dart';
import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/data/models/diet_plan.dart';
import 'package:naivisense/features/parent/widget/empty_hint.dart';
import 'package:naivisense/features/parent/widget/section_header.dart';

class DietPlanSection extends StatelessWidget {
  final AsyncValue<DietPlanModel?> dietPlan;

  const DietPlanSection({super.key, required this.dietPlan});

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: "Diet Chart", icon: Icons.restaurant_outlined),

        r.gapH(16),

        dietPlan.when(
          loading: () => const LinearProgressIndicator(),

          error: (_, __) => EmptyHint(message: 'No active diet plan'),

          data: (plan) {
            if (plan == null) {
              return EmptyHint(message: 'No diet plan assigned yet');
            }

            return Column(
              children: [
                Container(
                  padding: r.allPadding(14),
                  decoration: BoxDecoration(
                    color: AppColors.mintGreen.withValues(alpha: 0.06),
                    borderRadius: r.borderRadius(12),
                    border: Border.all(
                      color: AppColors.mintGreen.withValues(alpha: 0.20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.date_range_outlined,
                        color: AppColors.mintGreen,
                        size: r.icon(18, tablet: 20, desktop: 22),
                      ),

                      r.gapW(8),

                      Expanded(
                        child: Text(
                          '${AppDateUtils.formatDate(plan.startDate)} → ${AppDateUtils.formatDate(plan.endDate)}',
                          style: TextStyle(
                            color: AppColors.mintGreen,
                            fontSize: r.sp(12, tablet: 13, desktop: 14),
                          ),
                        ),
                      ),

                      Text(
                        '${plan.meals.length} meals',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                          fontSize: r.sp(12, tablet: 13, desktop: 14),
                        ),
                      ),
                    ],
                  ),
                ),

                r.gapH(10),

                ...plan.meals.map(
                  (meal) => Container(
                    margin: EdgeInsets.only(bottom: r.h(10)),
                    padding: EdgeInsets.symmetric(
                      horizontal: r.w(16),
                      vertical: r.h(14),
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: r.borderRadius(12),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Wrap(
                      spacing: r.w(14),
                      runSpacing: r.h(10),
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: r.w(10),
                            vertical: r.h(5),
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.mintGreen.withValues(alpha: 0.10),
                            borderRadius: r.borderRadius(8),
                          ),
                          child: Text(
                            meal.mealTime.toUpperCase(),
                            style: TextStyle(
                              color: AppColors.mintGreen,
                              fontWeight: FontWeight.w700,
                              fontSize: r.sp(11, tablet: 12, desktop: 13),
                            ),
                          ),
                        ),

                        SizedBox(
                          width: r.isMobile
                              ? MediaQuery.sizeOf(context).width * 0.45
                              : r.w(260, tablet: 280, desktop: 320),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                meal.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: r.sp(14, tablet: 15, desktop: 16),
                                ),
                              ),

                              if (meal.ingredients.isNotEmpty)
                                Text(
                                  meal.ingredients.take(3).join(', '),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: r.sp(11, tablet: 12, desktop: 13),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        Text(
                          '${meal.caloriesApprox} kcal',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: r.sp(12, tablet: 13, desktop: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
