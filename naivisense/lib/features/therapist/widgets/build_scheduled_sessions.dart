import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naivisense/core/utils/string_utils.dart';
import 'package:naivisense/data/models/child.dart';
import 'package:naivisense/shared/widgets/state_widgets.dart' as sw;

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/widgets/app_card.dart';
import '../../auth/providers/auth_provider.dart';

class ScheduledSessionsWidget extends ConsumerWidget {
  const ScheduledSessionsWidget({super.key, required this.children});

  final AsyncValue<List<ChildModel>> children;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responsive = Responsive(context);

    final user = ref.watch(authProvider).valueOrNull?.user;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Scheduled Sessions',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontSize: responsive.sp(20, tablet: 22, desktop: 24),
          ),
        ),

        responsive.gapH(12, tablet: 16, desktop: 20),

        children.when(
          loading: () => const sw.LoadingWidget(),

          error: (e, _) => sw.ErrorWidget(message: e.toString()),

          data: (list) {
            final slots = <ScheduleSlotRow>[];

            for (final child in list) {
              for (final assignment in child.therapists) {
                if (assignment.therapistId != user?.id) continue;

                final sched = assignment.schedule;

                if (sched == null || sched.days.isEmpty) continue;

                slots.add(
                  ScheduleSlotRow(
                    childName: child.name,
                    therapyType: assignment.therapyType,
                    schedule: sched,
                  ),
                );
              }
            }

            if (slots.isEmpty) {
              return const sw.EmptyWidget(
                message: 'No recurring schedule set',
                icon: Icons.calendar_month_outlined,
              );
            }

            return Column(
              children: slots
                  .map(
                    (slot) => Padding(
                      padding: EdgeInsets.only(
                        bottom: responsive.h(8, tablet: 10, desktop: 12),
                      ),
                      child: _ScheduleCard(slot: slot),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({required this.slot});

  final ScheduleSlotRow slot;

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    return AppCard(
      child: Row(
        children: [
          Container(
            width: 4,
            height: responsive.h(48, tablet: 52, desktop: 56),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: responsive.borderRadius(2),
            ),
          ),

          responsive.gapW(12, tablet: 16, desktop: 20),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  toTitleCase(slot.childName),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: responsive.sp(14, tablet: 15, desktop: 16),
                  ),
                ),

                responsive.gapH(8, tablet: 10, desktop: 12),

                Text(
                  '${slot.therapyType} • ${slot.schedule.timeLabel}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: responsive.sp(12, tablet: 13, desktop: 14),
                  ),
                ),

                Text(
                  slot.schedule.daysLabel,
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: responsive.sp(12, tablet: 13, desktop: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ScheduleSlotRow {
  final String childName;
  final String therapyType;
  final SessionSchedule schedule;

  ScheduleSlotRow({
    required this.childName,
    required this.therapyType,
    required this.schedule,
  });
}
