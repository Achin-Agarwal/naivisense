import 'package:flutter/material.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';

class TimePickerButton extends StatelessWidget {
  final String label;
  final String? time;
  final void Function(String) onPicked;

  const TimePickerButton({
    super.key,
    required this.label,
    required this.time,
    required this.onPicked,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return GestureDetector(
      onTap: () async {
        final parts = time?.split(':');

        final initial = parts != null
            ? TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]))
            : TimeOfDay.now();

        final picked = await showTimePicker(
          context: context,
          initialTime: initial,
        );

        if (picked != null) {
          onPicked(
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}',
          );
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: r.w(12), vertical: r.h(10)),
        decoration: BoxDecoration(
          color: AppColors.background,
          border: Border.all(color: AppColors.divider),
          borderRadius: BorderRadius.circular(r.radius(8)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.access_time,
              size: r.icon(16),
              color: AppColors.textSecondary,
            ),

            SizedBox(width: r.w(6)),

            Expanded(
              child: Text(
                time != null ? '$label: $time' : label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: r.font(13, tablet: 14, desktop: 15),
                  color: time != null
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
