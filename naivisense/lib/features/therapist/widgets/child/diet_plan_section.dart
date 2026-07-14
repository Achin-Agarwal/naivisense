import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naivisense/features/therapist/widgets/child/section_title.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../data/models/diet_plan.dart';
import 'empty_message.dart';

class DietPlanSection extends StatelessWidget {
  const DietPlanSection({super.key, required this.plan});

  final AsyncValue<DietPlanModel?> plan;

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return ProfileCard(
      title: 'Diet Chart',
      icon: Icons.restaurant_outlined,
      child: plan.when(
        loading: () => SizedBox(
          height: r.h(14),
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primaryBlue,
            ),
          ),
        ),

        error: (_, __) =>
            const EmptyMessage(message: 'Could not load diet plan'),

        data: (dietPlan) {
          if (dietPlan == null) {
            return const EmptyMessage(message: 'No active diet plan');
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Header
              Wrap(
                spacing: r.w(2),
                runSpacing: r.h(0.6),
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    color: AppColors.textSecondary,
                    size: r.icon(18),
                  ),

                  Text(
                    '${AppDateUtils.formatDate(dietPlan.startDate)}  →  ${AppDateUtils.formatDate(dietPlan.endDate)}',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: r.sp(12),
                    ),
                  ),

                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: r.w(2),
                      vertical: r.h(0.3),
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${dietPlan.meals.length} Meals',
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w600,
                        fontSize: r.sp(12),
                      ),
                    ),
                  ),
                ],
              ),

              r.gapH(1.6, tablet: 2, desktop: 3),

              if (dietPlan.notes != null && dietPlan.notes!.trim().isNotEmpty)
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: r.h(1.8)),
                  padding: EdgeInsets.all(r.w(3)),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: .05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    dietPlan.notes!,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: r.sp(13),
                    ),
                  ),
                ),

              ...dietPlan.meals.map((meal) => _MealCard(meal: meal)),
            ],
          );
        },
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  const _MealCard({required this.meal});

  final Meal meal;

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return Container(
      margin: EdgeInsets.only(bottom: r.h(1.5)),
      padding: EdgeInsets.all(r.w(3.5)),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: r.w(2),
            runSpacing: r.h(.5),
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                meal.name,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: r.sp(15),
                ),
              ),

              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: r.w(2),
                  vertical: r.h(.3),
                ),
                decoration: BoxDecoration(
                  color: AppColors.mintGreen.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  meal.mealTime,
                  style: TextStyle(
                    color: AppColors.mintGreen,
                    fontWeight: FontWeight.w600,
                    fontSize: r.sp(11),
                  ),
                ),
              ),
            ],
          ),

          if (meal.description != null &&
              meal.description!.trim().isNotEmpty) ...[
            r.gapH(.8, tablet: 1, desktop: 1.5),
            Text(meal.description!, style: TextStyle(fontSize: r.sp(13))),
          ],

          if (meal.ingredients.isNotEmpty) ...[
            r.gapH(.8, tablet: 1, desktop: 1.5),
            Text(
              "Ingredients",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: r.sp(12)),
            ),
            r.gapH(.3, tablet: .5, desktop: .7),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: meal.ingredients
                  .map(
                    (e) => Chip(
                      label: Text(e, style: TextStyle(fontSize: r.sp(11))),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  )
                  .toList(),
            ),
          ],

          r.gapH(1, tablet: 2, desktop: 3),

          Wrap(
            spacing: r.w(4),
            runSpacing: r.h(.5),
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.local_fire_department,
                    size: 16,
                    color: Colors.orange,
                  ),
                  r.gapW(4),
                  Text(
                    "${meal.caloriesApprox} kcal",
                    style: TextStyle(
                      fontSize: r.sp(12),
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.repeat,
                    size: 16,
                    color: AppColors.primaryBlue,
                  ),
                  r.gapW(4),
                  Text(
                    meal.frequency,
                    style: TextStyle(
                      fontSize: r.sp(12),
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
