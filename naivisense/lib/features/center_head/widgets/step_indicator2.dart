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
    final ui = Responsive(context);

    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.symmetric(
        horizontal: ui.sw(16),
        vertical: ui.sh(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(stepTitles.length, (i) {
              final done = i < currentStep;
              final current = i == currentStep;

              return Expanded(
                child: Row(
                  children: [
                    StepDot(
                      index: i + 1,
                      done: done,
                      current: current,
                    ),
                    if (i < stepTitles.length - 1)
                      Expanded(
                        child: Container(
                          height: ui.sh(2),
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

          SizedBox(height: ui.sh(6)),

          Text(
            'Step ${currentStep + 1} of ${stepTitles.length} — ${stepTitles[currentStep]}',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: ui.ssp(12),
            ),
          ),
        ],
      ),
    );
  }
}