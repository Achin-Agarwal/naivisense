import 'package:flutter/material.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';

class SeverityCard extends StatelessWidget {
  final Responsive ui;
  final String value;
  final String title;
  final Color color;
  final String selectedValue;
  final ValueChanged<String> onChanged;

  const SeverityCard({
    super.key,
    required this.ui,
    required this.value,
    required this.title,
    required this.color,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected = selectedValue == value;

    return InkWell(
      borderRadius: BorderRadius.circular(ui.sRadius(10)),
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: ui.isMobile ? double.infinity : 160,
        padding: EdgeInsets.symmetric(vertical: ui.sh(8), horizontal: ui.sw(6)),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.10) : Colors.white,
          borderRadius: BorderRadius.circular(ui.sRadius(2)),
          border: Border.all(
            color: selected ? color : AppColors.divider,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected)
              Icon(Icons.check_circle_rounded, color: color, size: ui.sIcon(6)),

            if (selected) SizedBox(width: ui.sw(4)),

            Flexible(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selected ? color : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: ui.ssp(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
