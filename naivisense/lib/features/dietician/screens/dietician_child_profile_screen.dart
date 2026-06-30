import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../providers/dietician_provider.dart';
import 'create_diet_chart_screen.dart';

class DieticianChildProfileScreen extends ConsumerWidget {
  final String childId;
  final String? requestId;

  const DieticianChildProfileScreen({
    super.key,
    required this.childId,
    this.requestId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dietPlan = ref.watch(dieticianChildDietPlanProvider(childId));

    return LayoutBuilder(
      builder: (context, constraints) {
        // ===============================
        // Responsive Breakpoints
        // ===============================

        final width = constraints.maxWidth;

        final isMobile = width < 600;
        final isTablet = width >= 600 && width < 1024;
        final isDesktop = width >= 1024;

        final horizontalPadding = isMobile ? 16.0 : 24.0;

        return Scaffold(
          backgroundColor: AppColors.background,

          appBar: AppBar(
            title: Text(
              'Child Diet Profile',
              style: TextStyle(
                fontSize: isMobile ? 20 : 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: AppColors.surface,
            elevation: 0,
            leading: BackButton(onPressed: () => Navigator.pop(context)),
          ),

          body: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(dieticianChildDietPlanProvider(childId));
            },

            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),

                child: ListView(
                  padding: EdgeInsets.all(horizontalPadding),

                  children: [
                    _ActiveDietPlan(dietPlan: dietPlan),

                    SizedBox(height: isMobile ? 20 : 28),

                    SizedBox(
                      width: double.infinity,
                      height: isMobile ? 50 : 56,

                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CreateDietChartScreen(
                                childId: childId,
                                requestId: requestId,
                              ),
                            ),
                          );
                        },

                        icon: Icon(Icons.add, size: isMobile ? 18 : 22),

                        label: Text(
                          "Create New Diet Chart",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: isMobile ? 15 : 16,
                          ),
                        ),

                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mintGreen,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ========================================================
// Active Diet Plan Card
// ========================================================

class _ActiveDietPlan extends StatelessWidget {
  final AsyncValue dietPlan;

  const _ActiveDietPlan({required this.dietPlan});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final isMobile = width < 600;
    final isTablet = width >= 600 && width < 1024;

    final titleSize = isMobile ? 15.0 : 18.0;
    final subtitleSize = isMobile ? 12.0 : 14.0;
    final mealSize = isMobile ? 13.0 : 15.0;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 22),

      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Icon(
                Icons.restaurant_outlined,
                color: AppColors.primaryBlue,
                size: isMobile ? 18 : 22,
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  "Current Diet Plan",
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: isMobile ? 14 : 20),

          dietPlan.when(
            loading: () => const LinearProgressIndicator(),

            error: (_, __) => Text(
              "No active diet plan",
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: subtitleSize,
              ),
            ),

            data: (plan) {
              if (plan == null) {
                return Text(
                  "No active diet plan assigned",
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: subtitleSize,
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    "${AppDateUtils.formatDate(plan.startDate)} → ${AppDateUtils.formatDate(plan.endDate)}",

                    style: TextStyle(
                      fontSize: subtitleSize,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  SizedBox(height: isMobile ? 12 : 16),

                  ...((plan.meals as List)
                      .take(4)
                      .map(
                        (meal) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),

                          child: Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            runSpacing: 8,

                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),

                                decoration: BoxDecoration(
                                  color: AppColors.mintGreen.withValues(
                                    alpha: .10,
                                  ),

                                  borderRadius: BorderRadius.circular(6),
                                ),

                                child: Text(
                                  meal.mealTime.toString().toUpperCase(),

                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.mintGreen,
                                  ),
                                ),
                              ),

                              SizedBox(
                                width: isMobile ? width * .45 : 300,

                                child: Text(
                                  meal.name.toString(),

                                  overflow: TextOverflow.ellipsis,

                                  maxLines: 2,

                                  style: TextStyle(fontSize: mealSize),
                                ),
                              ),

                              Text(
                                "${meal.caloriesApprox} kcal",

                                style: TextStyle(
                                  fontSize: subtitleSize,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
