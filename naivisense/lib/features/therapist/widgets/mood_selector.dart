import 'package:flutter/material.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';

class MoodSelector extends StatelessWidget {
  const MoodSelector({
    super.key,
    required this.selectedMood,
    required this.onChanged,
    required this.moodData,
  });

  final String selectedMood;
  final ValueChanged<String> onChanged;
  final List<Map<String, dynamic>> moodData;

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    final crossAxisCount = r.isMobile ? 2 : 4;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: moodData.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: r.w(10),
        mainAxisSpacing: r.h(10),
        childAspectRatio: r.isMobile ? 1.15 : 1.0,
      ),
      itemBuilder: (context, index) {
        final mood = moodData[index];

        final key = mood['key'] as String;
        final emoji = mood['emoji'] as String;
        final label = mood['label'] as String;
        final color = mood['color'] as Color;

        final selected = selectedMood == key;

        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => onChanged(key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              decoration: BoxDecoration(
                color: selected
                    ? color.withValues(alpha: 0.15)
                    : AppColors.surface,
                border: Border.all(
                  color: selected ? color : AppColors.divider,
                  width: selected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(r.radius(16)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    emoji,
                    style: TextStyle(fontSize: selected ? r.sp(34) : r.sp(28)),
                  ),

                  r.gapH(8),

                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: r.sp(12),
                      fontWeight: selected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: selected ? color : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
