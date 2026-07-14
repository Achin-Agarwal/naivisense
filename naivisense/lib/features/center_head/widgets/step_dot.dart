import 'package:flutter/material.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';


class StepDot extends StatelessWidget {
  final int index;
  final bool done;
  final bool current;

  const StepDot({
    super.key,
    required this.index,
    required this.done,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: r.w(28, tablet: 32, desktop: 36),
      height: r.w(28, tablet: 32, desktop: 36),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done || current ? AppColors.primaryBlue : AppColors.background,
        border: Border.all(
          color: done || current ? AppColors.primaryBlue : AppColors.divider,
          width: 1.5,
        ),
      ),
      child: Center(
        child: done
            ? Icon(
                Icons.check,
                color: Colors.white,
                size: r.icon(14, tablet: 16, desktop: 18),
              )
            : Text(
                '$index',
                style: TextStyle(
                  fontSize: r.sp(12, tablet: 13, desktop: 15),
                  fontWeight: FontWeight.w600,
                  color: current ? Colors.white : AppColors.textSecondary,
                ),
              ),
      ),
    );
  }
}
