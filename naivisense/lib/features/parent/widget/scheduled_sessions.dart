import 'package:flutter/material.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/data/models/child.dart';
import 'package:naivisense/features/parent/widget/empty_hint.dart';
import 'package:naivisense/features/parent/widget/section_header.dart';
import 'package:naivisense/shared/widgets/app_card.dart';

class ScheduledSessions extends StatelessWidget {
  final ChildModel child;

  const ScheduledSessions({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    const dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    final assignments = child.therapists
        .where((a) => a.schedule != null && a.schedule!.days.isNotEmpty)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Scheduled Sessions',
          icon: Icons.calendar_month_outlined,
        ),

        r.gapH(16),

        if (assignments.isEmpty)
          EmptyHint(message: 'No recurring schedule set yet')
        else
          ...assignments.map((assignment) {
            final schedule = assignment.schedule!;
            final daysLabel = schedule.days.map((d) => dayNames[d]).join(', ');

            return Padding(
              padding: EdgeInsets.only(bottom: r.h(12)),
              child: AppCard(
                color: AppColors.primaryBlue.withValues(alpha: 0.03),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(r.w(12)),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.10),
                        borderRadius: r.borderRadius(10),
                      ),
                      child: Icon(
                        Icons.repeat,
                        color: AppColors.primaryBlue,
                        size: r.icon(22, tablet: 24, desktop: 26),
                      ),
                    ),

                    r.gapW(14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            assignment.therapyType,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: r.sp(15, tablet: 16, desktop: 17),
                            ),
                          ),

                          if (assignment.therapistName != null) ...[
                            r.gapH(2),
                            Text(
                              assignment.therapistName!,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: r.sp(12, tablet: 13, desktop: 14),
                              ),
                            ),
                          ],

                          r.gapH(6),

                          Text(
                            '$daysLabel  •  ${schedule.fromTime} – ${schedule.toTime}',
                            style: TextStyle(
                              color: AppColors.primaryBlue,
                              fontSize: r.sp(12, tablet: 13, desktop: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}
