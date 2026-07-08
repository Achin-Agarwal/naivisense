import 'package:flutter/material.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/core/utils/string_utils.dart';
import 'package:naivisense/data/models/child.dart';

class DiagnosisChips extends StatelessWidget {
  final ChildModel child;

  const DiagnosisChips({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    return Wrap(
      spacing: responsive.w(8),
      runSpacing: responsive.h(8),
      children: child.diagnosis
          .map(
            (d) => Container(
              padding: EdgeInsets.symmetric(
                horizontal: responsive.w(12),
                vertical: responsive.h(6),
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primaryBlue.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                toTitleCase(d),
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                  fontSize: responsive.sp(12),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}