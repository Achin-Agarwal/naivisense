import 'package:flutter/material.dart';
import 'package:naivisense/core/utils/date_utils.dart';
import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/features/therapist/widgets/tappable_field.dart';

class DateTimeSelector extends StatelessWidget {
  final DateTime date;
  final TimeOfDay time;
  final VoidCallback onDateTap;
  final VoidCallback onTimeTap;

  const DateTimeSelector({
    super.key,
    required this.date,
    required this.time,
    required this.onDateTap,
    required this.onTimeTap,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Stack vertically if width is too small
        final vertical = constraints.maxWidth < 420;

        if (vertical) {
          return Column(
            children: [
              TappableField(
                label: AppDateUtils.formatDate(date),
                icon: Icons.calendar_today_outlined,
                onTap: onDateTap,
              ),

              r.gapH(12),

              TappableField(
                label: time.format(context),
                icon: Icons.access_time_outlined,
                onTap: onTimeTap,
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: TappableField(
                label: AppDateUtils.formatDate(date),
                icon: Icons.calendar_today_outlined,
                onTap: onDateTap,
              ),
            ),

            r.gapW(12, tablet: 16, desktop: 20),

            Expanded(
              child: TappableField(
                label: time.format(context),
                icon: Icons.access_time_outlined,
                onTap: onTimeTap,
              ),
            ),
          ],
        );
      },
    );
  }
}
