import 'package:flutter/material.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';

class SelectableCardGroup extends StatelessWidget {
  final List<String> options;
  final Set<String> selected;
  final ValueChanged<String> onTap;
  final String Function(String)? display;
  final String? validator;

  const SelectableCardGroup({
    super.key,
    required this.options,
    required this.selected,
    required this.onTap,
    this.display,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final ui = Responsive(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: ui.sw(2),
          runSpacing: ui.sh(6),
          children: options.map((option) {
            final isSelected = selected.contains(option);

            return InkWell(
              borderRadius: BorderRadius.circular(ui.sRadius(10)),
              onTap: () => onTap(option),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: EdgeInsets.symmetric(
                  horizontal: ui.sw(4),
                  vertical: ui.sh(6),
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryBlue.withValues(alpha: 0.08)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(ui.sRadius(2)),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryBlue
                        : AppColors.divider,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: ui.sIcon(6),
                      height: ui.sIcon(6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryBlue
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryBlue
                              : AppColors.divider,
                          width: 1,
                        ),
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check,
                              size: ui.sIcon(5),
                              color: Colors.white,
                            )
                          : null,
                    ),

                    SizedBox(width: ui.sw(2)),

                    Text(
                      display?.call(option) ?? option,
                      style: TextStyle(
                        fontSize: ui.ssp(10),
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: isSelected
                            ? AppColors.primaryBlue
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),

        if (validator != null) ...[
          SizedBox(height: ui.sh(4)),
          Text(
            validator!,
            style: TextStyle(color: AppColors.softCoral, fontSize: ui.ssp(11)),
          ),
        ],
      ],
    );
  }
}
