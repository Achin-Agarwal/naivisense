import 'package:flutter/material.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';

class SeveritySelector extends StatelessWidget {
  final List<(String, String, Color)> severities;
  final String selectedSeverity;
  final ValueChanged<String> onChanged;

  const SeveritySelector({
    super.key,
    required this.severities,
    required this.selectedSeverity,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final ui = Responsive(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < Responsive.mobileBreakpoint;

        final spacing = ui.sw(6);

        return Wrap(
          spacing: spacing,
          runSpacing: ui.sh(8),
          children: severities.map((severity) {
            final (value, label, color) = severity;
            final selected = selectedSeverity == value;

            return SizedBox(
              width: isMobile
                  ? (constraints.maxWidth - spacing) / 2
                  : (constraints.maxWidth - (spacing * 3)) / 4,
              child: GestureDetector(
                onTap: () => onChanged(value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: EdgeInsets.symmetric(
                    vertical: isMobile ? ui.sh(12) : ui.sh(14),
                    horizontal: ui.sw(8),
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? color.withValues(alpha: 0.12)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(ui.sRadius(8)),
                    border: Border.all(
                      color: selected ? color : AppColors.divider,
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: isMobile ? ui.sIcon(6) : ui.sIcon(8),
                        height: isMobile ? ui.sIcon(6) : ui.sIcon(8),
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(height: ui.sh(6)),
                      Text(
                        label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isMobile ? ui.ssp(11) : ui.ssp(12),
                          fontWeight: FontWeight.w600,
                          color: selected ? color : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
