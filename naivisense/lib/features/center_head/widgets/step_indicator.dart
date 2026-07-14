import 'package:flutter/material.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/features/center_head/widgets/step_dot.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep;
  final List<String> stepTitles;

  const StepIndicator({
    super.key,
    required this.currentStep,
    required this.stepTitles,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.symmetric(
        horizontal: r.isMobile
            ? r.w(16)
            : r.isTablet
            ? r.w(24)
            : r.w(40),
        vertical: r.isMobile ? r.h(12) : r.h(18),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: r.isMobile
                ? double.infinity
                : r.isTablet
                ? 700
                : 850,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: List.generate(4, (i) {
                  final done = i < currentStep;
                  final current = i == currentStep;

                  return Expanded(
                    child: Row(
                      children: [
                        StepDot(index: i + 1, done: done, current: current),
                        if (i < 3)
                          Expanded(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              height: 2,
                              color: done
                                  ? AppColors.primaryBlue
                                  : AppColors.divider,
                            ),
                          ),
                      ],
                    ),
                  );
                }),
              ),

              SizedBox(height: r.h(10)),

              Text(
                'Step ${currentStep + 1} of ${stepTitles.length} — ${stepTitles[currentStep]}',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: r.sp(13),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
