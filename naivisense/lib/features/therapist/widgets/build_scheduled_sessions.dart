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
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: responsive.w(6, tablet: 8, desktop: 10),
          vertical: responsive.h(2),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 5,
              height: responsive.h(56, tablet: 60, desktop: 64),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            responsive.gapW(12, tablet: 14, desktop: 16),

            Expanded(
              child: responsive.isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          toTitleCase(slot.childName),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: responsive.sp(
                                  15,
                                  tablet: 16,
                                  desktop: 17,
                                ),
                              ),
                        ),

                        responsive.gapH(8),

                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _ScheduleInfoChip(
                              icon: Icons.psychology_outlined,
                              text: slot.therapyType,
                            ),
                            _ScheduleInfoChip(
                              icon: Icons.schedule,
                              text: slot.schedule.timeLabel,
                            ),
                            _ScheduleInfoChip(
                              icon: Icons.calendar_today_outlined,
                              text: slot.schedule.daysLabel,
                            ),
                          ],
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            toTitleCase(slot.childName),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: responsive.sp(
                                    15,
                                    tablet: 16,
                                    desktop: 17,
                                  ),
                                ),
                          ),
                        ),

                        Expanded(
                          flex: 3,
                          child: Wrap(
                            alignment: WrapAlignment.end,
                            spacing: 10,
                            runSpacing: 8,
                            children: [
                              _ScheduleInfoChip(
                                icon: Icons.psychology_outlined,
                                text: slot.therapyType,
                              ),
                              _ScheduleInfoChip(
                                icon: Icons.schedule,
                                text: slot.schedule.timeLabel,
                              ),
                              _ScheduleInfoChip(
                                icon: Icons.calendar_today_outlined,
                                text: slot.schedule.daysLabel,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
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

class _ScheduleInfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ScheduleInfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.w(10),
        vertical: responsive.h(6),
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 6,
        children: [
          Icon(icon, size: responsive.sp(14), color: AppColors.primaryBlue),
          Text(text, style: TextStyle(fontSize: responsive.sp(12))),
        ],
      ),
    );
  }
}
