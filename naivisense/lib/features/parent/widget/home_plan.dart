import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/data/models/home_plan.dart';
import 'package:naivisense/features/parent/widget/empty_hint.dart';
import 'package:naivisense/features/parent/widget/section_header.dart';
import 'package:naivisense/features/parent/widget/task_group.dart';

class HomePlanSection extends ConsumerWidget {
  final AsyncValue<HomePlanModel?> plan;

  const HomePlanSection({super.key, required this.plan});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = Responsive(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: "This Week's Home Plan",
          icon: Icons.home_outlined,
        ),

        r.gapH(16),

        plan.when(
          loading: () => const LinearProgressIndicator(),

          error: (_, __) =>
              EmptyHint(message: 'No active home plan'),

          data: (homePlan) {
            if (homePlan == null) {
              return EmptyHint(
                message: 'No active home plan assigned yet',
              );
            }

            return Column(
              children: [
                if (homePlan.morningTasks.isNotEmpty)
                  TaskGroup(
                    title: '🌅 Morning',
                    tasks: homePlan.morningTasks,
                    plan: homePlan,
                    responsive: r,
                  ),

                if (homePlan.afternoonTasks.isNotEmpty)
                    TaskGroup(
                    title: '☀️ Afternoon',
                    tasks: homePlan.afternoonTasks,
                    plan: homePlan,
                    responsive: r,
                  ),

                if (homePlan.eveningTasks.isNotEmpty)
                  TaskGroup(
                    title: '🌙 Evening',
                    tasks: homePlan.eveningTasks,
                    plan: homePlan,
                    responsive: r,
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
