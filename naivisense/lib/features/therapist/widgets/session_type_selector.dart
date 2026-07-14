import 'package:flutter/material.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';

class SessionTypeSelector extends StatelessWidget {
  final List<Map<String, dynamic>> sessionTypes;
  final String selectedType;
  final ValueChanged<String> onSelected;

  const SessionTypeSelector({
    super.key,
    required this.sessionTypes,
    required this.selectedType,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    final sessionGridCount = responsive.isDesktop
        ? 4
        : responsive.isTablet
        ? 2
        : 2;

    final childAspectRatio = responsive.isMobile ? 2.6 : 3.0;

    return GridView.count(
      crossAxisCount: sessionGridCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: responsive.h(10, tablet: 12, desktop: 14),
      crossAxisSpacing: responsive.w(10, tablet: 12, desktop: 14),
      childAspectRatio: childAspectRatio,
      children: sessionTypes.map((type) {
        final key = type['key'] as String;
        final label = type['label'] as String;
        final icon = type['icon'] as IconData;

        final selected = selectedType == key;

        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => onSelected(key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primaryBlue.withValues(alpha: 0.1)
                    : AppColors.surface,
                border: Border.all(
                  color: selected ? AppColors.primaryBlue : AppColors.divider,
                  width: selected ? 1.5 : 1,
                ),
                borderRadius: BorderRadius.circular(
                  responsive.radius(12, tablet: 14, desktop: 16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: responsive.icon(16, tablet: 18, desktop: 20),
                    color: selected
                        ? AppColors.primaryBlue
                        : AppColors.textSecondary,
                  ),

                  responsive.gapW(6, tablet: 8, desktop: 10),

                  Flexible(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: responsive.sp(12, tablet: 13, desktop: 12),
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: selected
                            ? AppColors.primaryBlue
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
