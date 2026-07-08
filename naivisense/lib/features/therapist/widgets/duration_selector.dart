import 'package:flutter/material.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';

class DurationSelector extends StatelessWidget {
  final List<int> durations;
  final int selectedDuration;
  final ValueChanged<int> onSelected;

  const DurationSelector({
    super.key,
    required this.durations,
    required this.selectedDuration,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    return Wrap(
      spacing: responsive.w(8, tablet: 10, desktop: 12),
      runSpacing: responsive.h(8, tablet: 10, desktop: 12),
      children: durations.map((duration) {
        final selected = selectedDuration == duration;

        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => onSelected(duration),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              constraints: BoxConstraints(
                minWidth: responsive.w(60, tablet: 70, desktop: 80),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: responsive.w(14, tablet: 18, desktop: 20),
                vertical: responsive.h(12, tablet: 14, desktop: 16),
              ),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primaryBlue.withValues(alpha: 0.10)
                    : AppColors.surface,
                border: Border.all(
                  color: selected ? AppColors.primaryBlue : AppColors.divider,
                  width: selected ? 1.5 : 1,
                ),
                borderRadius: BorderRadius.circular(
                  responsive.radius(10, tablet: 12, desktop: 14),
                ),
              ),
              child: Text(
                '$duration min',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: responsive.sp(13, tablet: 14, desktop: 15),
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  color: selected
                      ? AppColors.primaryBlue
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
