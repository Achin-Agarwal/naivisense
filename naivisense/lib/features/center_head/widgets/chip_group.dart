import 'package:flutter/material.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';


class ChipGroup extends StatelessWidget {
  final List<String> options;
  final Set<String> selected;
  final void Function(String) onTap;
  final bool single;
  final String Function(String)? display;
  final String? validator;

  const ChipGroup({
    super.key,
    required this.options,
    required this.selected,
    required this.onTap,
    this.single = false,
    this.display,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: r.w(8, tablet: 10, desktop: 12),
          runSpacing: r.h(8, tablet: 10, desktop: 12),
          children: options.map((opt) {
            final isSelected = selected.contains(opt);
            final label = display?.call(opt) ?? opt;

            return MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => onTap(opt),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  padding: EdgeInsets.symmetric(
                    horizontal: r.w(
                      14,
                      tablet: 16,
                      desktop: 18,
                    ),
                    vertical: r.h(
                      8,
                      tablet: 10,
                      desktop: 12,
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryBlue.withValues(alpha: 0.12)
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(
                      r.radius(
                        30,
                        tablet: 32,
                        desktop: 34,
                      ),
                    ),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryBlue
                          : AppColors.divider,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: r.sp(
                        13,
                        tablet: 13.5,
                        desktop: 14,
                      ),
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: isSelected
                          ? AppColors.primaryBlue
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        if (validator != null) ...[
          SizedBox(height: r.h(6)),
          Text(
            validator!,
            style: TextStyle(
              color: AppColors.softCoral,
              fontSize: r.sp(
                12,
                tablet: 12.5,
                desktop: 13,
              ),
            ),
          ),
        ],
      ],
    );
  }
}