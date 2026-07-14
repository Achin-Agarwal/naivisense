import 'package:flutter/material.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';

class SessionModeSelector extends StatelessWidget {
  final String selectedMode;
  final ValueChanged<String> onSelected;

  const SessionModeSelector({
    super.key,
    required this.selectedMode,
    required this.onSelected,
  });

  static const List<Map<String, dynamic>> _modes = [
    {'key': 'offline', 'label': 'In-Person', 'icon': Icons.people_outlined},
    {'key': 'online', 'label': 'Online', 'icon': Icons.video_call_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    return Row(
      children: _modes.asMap().entries.map((entry) {
        final index = entry.key;
        final mode = entry.value;

        final key = mode['key'] as String;
        final label = mode['label'] as String;
        final icon = mode['icon'] as IconData;

        final selected = selectedMode == key;

        return Expanded(
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => onSelected(key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: EdgeInsets.only(
                  right: index == 0
                      ? responsive.w(8, tablet: 10, desktop: 12)
                      : 0,
                ),
                padding: EdgeInsets.symmetric(
                  vertical: responsive.h(14, tablet: 16, desktop: 18),
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
                    responsive.radius(12, tablet: 14, desktop: 16),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: responsive.icon(22, tablet: 24, desktop: 26),
                      color: selected
                          ? AppColors.primaryBlue
                          : AppColors.textSecondary,
                    ),

                    responsive.gapH(4, tablet: 6, desktop: 8),

                    Text(
                      label,
                      style: TextStyle(
                        fontSize: responsive.sp(13, tablet: 14, desktop: 15),
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: selected
                            ? AppColors.primaryBlue
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
