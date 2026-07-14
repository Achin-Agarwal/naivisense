import 'package:flutter/material.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/data/models/schedule_entry.dart';
import 'package:naivisense/features/center_head/widgets/time_picker_button.dart';

class SchedulePicker extends StatelessWidget {
  final String target;
  final ScheduleEntry? schedule;
  final List<String> dayLabels;
  final List<String> dayFullNames;
  final bool required;

  final void Function(List<int> days, String? fromTime, String? toTime)
  onChanged;

  const SchedulePicker({
    super.key,
    required this.target,
    required this.schedule,
    required this.dayLabels,
    required this.dayFullNames,
    required this.onChanged,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    final days = schedule?.days ?? [];
    final fromTime = schedule?.fromTime;
    final toTime = schedule?.toTime;

    final showDayError = required && days.isEmpty;
    final showTimeError =
        required &&
        days.isNotEmpty &&
        (fromTime == null ||
            fromTime.isEmpty ||
            toTime == null ||
            toTime.isEmpty);

    return Container(
      padding: EdgeInsets.all(r.w(12)),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.05),
        border: Border.all(
          color: showDayError || showTimeError
              ? AppColors.softCoral
              : AppColors.primaryBlue.withValues(alpha: 0.2),
        ),
        borderRadius: BorderRadius.circular(r.radius(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Session Schedule',
            style: TextStyle(
              fontSize: r.font(12, tablet: 13, desktop: 14),
              fontWeight: FontWeight.w600,
              color: AppColors.primaryBlue,
            ),
          ),

          SizedBox(height: r.h(8)),

          Wrap(
            spacing: r.w(6),
            runSpacing: r.h(6),
            children: List.generate(dayLabels.length, (i) {
              final selected = days.contains(i);

              return GestureDetector(
                onTap: () {
                  final updated = List<int>.from(days);

                  if (selected) {
                    updated.remove(i);
                  } else {
                    updated.add(i);
                  }

                  updated.sort();

                  onChanged(updated, fromTime ?? '09:00', toTime ?? '10:00');
                },
                child: Container(
                  width: r.value(mobile: 32, tablet: 36, desktop: 40),
                  height: r.value(mobile: 32, tablet: 36, desktop: 40),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected
                        ? AppColors.primaryBlue
                        : AppColors.background,
                    border: Border.all(
                      color: selected
                          ? AppColors.primaryBlue
                          : AppColors.divider,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      dayLabels[i],
                      style: TextStyle(
                        fontSize: r.font(11, tablet: 12, desktop: 13),
                        fontWeight: FontWeight.w600,
                        color: selected
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),

          if (showDayError) ...[
            SizedBox(height: r.h(8)),
            Text(
              'Please select at least one day.',
              style: TextStyle(
                color: AppColors.softCoral,
                fontSize: r.font(11, tablet: 12, desktop: 12),
              ),
            ),
          ],

          if (days.isNotEmpty) ...[
            SizedBox(height: r.h(10)),

            Row(
              children: [
                Expanded(
                  child: TimePickerButton(
                    label: 'From',
                    time: fromTime,
                    onPicked: (t) {
                      onChanged(days, t, toTime ?? '10:00');
                    },
                  ),
                ),

                SizedBox(width: r.w(10)),

                Expanded(
                  child: TimePickerButton(
                    label: 'To',
                    time: toTime,
                    onPicked: (t) {
                      onChanged(days, fromTime ?? '09:00', t);
                    },
                  ),
                ),
              ],
            ),

            if (showTimeError) ...[
              SizedBox(height: r.h(8)),
              Text(
                'Please select both start and end time.',
                style: TextStyle(
                  color: AppColors.softCoral,
                  fontSize: r.font(11, tablet: 12, desktop: 12),
                ),
              ),
            ],

            if (fromTime != null && toTime != null) ...[
              SizedBox(height: r.h(8)),

              Text(
                '${days.map((d) => dayFullNames[d]).join(', ')}  •  $fromTime – $toTime',
                style: TextStyle(
                  fontSize: r.font(12, tablet: 13, desktop: 14),
                  color: AppColors.primaryBlue,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
