import 'package:flutter/material.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';

class ChipGroup extends StatelessWidget {
  final List<String> options;
  final Set<String> selected;
  final ValueChanged<String> onTap;
  final bool single;
  final String Function(String)? display;
  final Map<String, Color>? colors;
  final String? validator;

  const ChipGroup({
    super.key,
    required this.options,
    required this.selected,
    required this.onTap,
    this.single = false,
    this.display,
    this.colors,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final ui = Responsive(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: ui.sw(8),
          runSpacing: ui.sh(8),
          children: options.map((opt) {
            final isSelected = selected.contains(opt);
            final label = display != null ? display!(opt) : opt;
            final color = colors?[opt] ?? AppColors.primaryBlue;

            return GestureDetector(
              onTap: () => onTap(opt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: EdgeInsets.symmetric(
                  horizontal: ui.sw(14),
                  vertical: ui.sh(8),
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withValues(alpha: 0.12)
                      : AppColors.background,
                  border: Border.all(
                    color: isSelected ? color : AppColors.divider,
                    width: isSelected ? 1.5 : 1,
                  ),
                  borderRadius: BorderRadius.circular(ui.sRadius(20)),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: ui.ssp(13),
                    color: isSelected ? color : AppColors.textSecondary,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        if (validator != null) ...[
          SizedBox(height: ui.sh(4)),
          Text(
            validator!,
            style: TextStyle(color: AppColors.softCoral, fontSize: ui.ssp(12)),
          ),
        ],
      ],
    );
  }
}
