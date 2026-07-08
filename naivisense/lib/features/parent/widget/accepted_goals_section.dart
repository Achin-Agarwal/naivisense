import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/data/models/goal.dart';
import 'package:naivisense/shared/widgets/app_card.dart';


class AcceptedGoalsSection extends StatelessWidget {
  final AsyncValue<List<GoalModel>> goals;

  const AcceptedGoalsSection({
    super.key,
    required this.goals,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return goals.when(
      loading: () => const SizedBox.shrink(),

      error: (_, __) => const SizedBox.shrink(),

      data: (goalList) {
        final acceptedGoals = goalList
            .where((goal) => goal.isAccepted || goal.isCompleted)
            .toList();

        if (acceptedGoals.isEmpty) {
          return const SizedBox.shrink();
        }

        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Therapy Goals',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: r.sp(
                        17,
                        tablet: 18,
                        desktop: 20,
                      ),
                    ),
              ),

              r.gapH(16),

              ...acceptedGoals.map(
                (goal) => Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: r.h(4),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        goal.isCompleted
                            ? Icons.check_circle
                            : Icons.radio_button_checked,
                        color: goal.isCompleted
                            ? AppColors.mintGreen
                            : AppColors.primaryBlue,
                        size: r.icon(
                          18,
                          tablet: 20,
                          desktop: 22,
                        ),
                      ),

                      r.gapW(8),

                      Expanded(
                        child: Text(
                          goal.title,
                          style: TextStyle(
                            fontSize: r.sp(
                              14,
                              tablet: 15,
                              desktop: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}