import 'package:flutter/material.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';

class AlertTypeGrid extends StatelessWidget {
  final List<(String, IconData, String)> alertTypes;
  final String selectedAlertType;
  final ValueChanged<String> onChanged;

  const AlertTypeGrid({
    super.key,
    required this.alertTypes,
    required this.selectedAlertType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final ui = Responsive(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < Responsive.mobileBreakpoint;
        final isTablet =
            constraints.maxWidth >= Responsive.mobileBreakpoint &&
            constraints.maxWidth < Responsive.tabletBreakpoint;

        final crossAxisCount = isMobile
            ? 2
            : isTablet
            ? 3
            : 4;

        final iconSize = isMobile ? ui.sIcon(10) : ui.sIcon(14);
        final labelFontSize = isMobile ? ui.ssp(10) : ui.ssp(12);

        final spacing = isMobile ? ui.sw(6) : ui.sw(8);

        final childAspectRatio = isMobile ? 1.2 : 1.4;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: alertTypes.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: childAspectRatio,
          ),
          itemBuilder: (context, index) {
            final (value, icon, label) = alertTypes[index];
            final selected = selectedAlertType == value;

            return GestureDetector(
              onTap: () => onChanged(value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primaryBlue.withValues(alpha: 0.10)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(ui.sRadius(8)),
                  border: Border.all(
                    color: selected ? AppColors.primaryBlue : AppColors.divider,
                    width: selected ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: iconSize,
                      color: selected
                          ? AppColors.primaryBlue
                          : AppColors.textSecondary,
                    ),
                    SizedBox(height: ui.sh(6)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: ui.sw(4)),
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: labelFontSize,
                          fontWeight: FontWeight.w500,
                          color: selected
                              ? AppColors.primaryBlue
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
