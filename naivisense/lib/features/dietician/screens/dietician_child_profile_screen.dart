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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Child Diet Profile'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: BackButton(onPressed: () => Navigator.pop(context)),
      ),
      body: RefreshIndicator(
        onRefresh: () async =>
            ref.invalidate(dieticianChildDietPlanProvider(childId)),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _ActiveDietPlan(dietPlan: dietPlan),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreateDietChartScreen(
                      childId:   childId,
                      requestId: requestId,
                    ),
                  ),
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Create New Diet Chart',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mintGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveDietPlan extends StatelessWidget {
  final AsyncValue<dynamic> dietPlan;
  const _ActiveDietPlan({required this.dietPlan});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.restaurant_outlined,
                  color: AppColors.primaryBlue, size: 18),
              SizedBox(width: 8),
              Text('Current Diet Plan',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 14),
          dietPlan.when(
            loading: () => const LinearProgressIndicator(),
            error: (_, _) => const Text('No active diet plan',
                style: TextStyle(color: AppColors.textSecondary)),
            data: (p) {
              if (p == null) {
                return const Text('No active diet plan assigned',
                    style: TextStyle(color: AppColors.textSecondary));
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${AppDateUtils.formatDate(p.startDate)} → ${AppDateUtils.formatDate(p.endDate)}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 10),
                  ...((p.meals as List).take(4).map((m) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.mintGreen
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(m.mealTime.toString().toUpperCase(),
                                  style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.mintGreen)),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(m.name.toString(),
                                  style: const TextStyle(fontSize: 13)),
                            ),
                            Text('${m.caloriesApprox} kcal',
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary)),
                          ],
                        ),
                      ))),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
