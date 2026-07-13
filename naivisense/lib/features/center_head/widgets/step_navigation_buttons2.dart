import 'package:flutter/material.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/shared/widgets/app_button.dart';

class StepNavigationButtons extends StatelessWidget {
  final int currentStep;
  final bool loading;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const StepNavigationButtons({
    super.key,
    required this.currentStep,
    required this.loading,
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final ui = Responsive(context);

    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.fromLTRB(ui.sw(20), ui.sh(12), ui.sw(20), ui.sh(24)),
      child: Row(
        children: [
          if (currentStep > 0)
            Expanded(
              child: AppButton(
                label: 'Back',
                outlined: true,
                onPressed: onBack,
              ),
            ),

          if (currentStep > 0) SizedBox(width: ui.sw(12)),

          Expanded(
            child: AppButton(
              label: currentStep == 5 ? 'Submit Enrollment' : 'Next',
              loading: loading,
              onPressed: onNext,
              icon: currentStep == 5 ? Icons.check : Icons.arrow_forward,
            ),
          ),
        ],
      ),
    );
  }
}
