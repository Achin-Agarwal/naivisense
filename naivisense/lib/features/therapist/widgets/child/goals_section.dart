import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/data/models/goal.dart';
import 'package:naivisense/features/therapist/widgets/child/goal_row.dart';
import 'package:naivisense/features/therapist/widgets/child/section_title.dart';
import 'empty_message.dart';

class GoalsSection extends ConsumerWidget {
  final AsyncValue<List<GoalModel>> goals;

  const GoalsSection({super.key, required this.goals});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responsive = Responsive(context);
    return ProfileCard(
      title: 'Therapy Goals',
      icon: Icons.flag_outlined,
      child: goals.when(
        loading: () => const SizedBox(
          height: 80,
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primaryBlue,
            ),
          ),
        ),

        error: (_, __) => const EmptyMessage(message: 'Could not load goals'),

        data: (list) {
          if (list.isEmpty) {
            return const EmptyMessage(message: 'No goals set yet');
          }

          final active = list.where((g) => !g.isCompleted).toList();

          final completed = list.where((g) => g.isCompleted).length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...active.take(5).map((goal) => GoalRow(goal: goal)),

              if (completed > 0) ...[
                responsive.gapH(8),

                Text(
                  '$completed goal(s) completed',
                  style: const TextStyle(
                    color: AppColors.mintGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
