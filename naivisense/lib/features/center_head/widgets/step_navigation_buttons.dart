import 'package:flutter/material.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/shared/widgets/app_button.dart';

class StepNavigationButtons extends StatelessWidget {
  final int step;
  final bool loading;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const StepNavigationButtons({
    super.key,
    required this.step,
    required this.loading,
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.only(
        top: r.h(14),
        bottom: r.isMobile ? r.h(18) : r.h(22),
      ),
      child: Row(
        children: [
          if (step > 0) ...[
            Expanded(
              child: SizedBox(
                height: r.isMobile ? r.h(48) : r.h(54),
                child: AppButton(
                  label: 'Back',
                  outlined: true,
                  onPressed: onBack,
                ),
              ),
            ),

            SizedBox(width: r.isMobile ? r.w(12) : r.w(18)),
          ],

          Expanded(
            child: SizedBox(
              height: r.isMobile ? r.h(48) : r.h(54),
              child: AppButton(
                label: step == 3 ? 'Enroll Therapist' : 'Next',
                loading: loading,
                onPressed: onNext,
                icon: step == 3 ? Icons.check : Icons.arrow_forward,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
