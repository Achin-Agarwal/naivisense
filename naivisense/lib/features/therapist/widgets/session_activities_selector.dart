import 'package:flutter/material.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/features/therapist/widgets/session_title.dart';

class SessionActivitiesSelector extends StatelessWidget {
  const SessionActivitiesSelector({
    super.key,
    required this.activities,
    required this.selectedActivities,
    required this.onChanged,
  });

  final List<String> activities;
  final Set<String> selectedActivities;
  final ValueChanged<Set<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(
          title: 'Activities Used',
          icon: Icons.sports_handball_outlined,
        ),

        r.gapH(6),

        Text(
          'Select all activities done in this session',
          style: TextStyle(color: AppColors.textSecondary, fontSize: r.sp(12)),
        ),

        r.gapH(16),

        Wrap(
          spacing: r.w(10),
          runSpacing: r.h(10),
          children: activities.map((activity) {
            final selected = selectedActivities.contains(activity);

            return MouseRegion(
              cursor: SystemMouseCursors.click,
              child: InkWell(
                borderRadius: BorderRadius.circular(r.radius(24)),
                onTap: () {
                  final updated = Set<String>.from(selectedActivities);

                  if (selected) {
                    updated.remove(activity);
                  } else {
                    updated.add(activity);
                  }

                  onChanged(updated);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.symmetric(
                    horizontal: r.w(14),
                    vertical: r.h(10),
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primaryBlue.withValues(alpha: 0.10)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(r.radius(24)),
                    border: Border.all(
                      color: selected
                          ? AppColors.primaryBlue
                          : AppColors.divider,
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Text(
                    activity,
                    style: TextStyle(
                      fontSize: r.sp(13),
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      color: selected
                          ? AppColors.primaryBlue
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
