import 'package:flutter/material.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';

class DiagnosisChips extends StatelessWidget {
  final List<String> diagnosis;
  final String severity;

  const DiagnosisChips({
    super.key,
    required this.diagnosis,
    required this.severity,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    final (severityLabel, severityColor) = switch (severity) {
      'mild' => ('Mild', AppColors.mintGreen),
      'moderate' => ('Moderate', AppColors.warmYellow),
      'severe' => ('Severe', AppColors.softCoral),
      _ => ('—', AppColors.textSecondary),
    };

    return Wrap(
      spacing: r.w(8),
      runSpacing: r.h(8),
      children: [
        ...diagnosis.map(
          (item) => _DiagnosisChip(label: item, color: AppColors.primaryBlue),
        ),

        _DiagnosisChip(label: severityLabel, color: severityColor),
      ],
    );
  }
}

class _DiagnosisChip extends StatelessWidget {
  final String label;
  final Color color;

  const _DiagnosisChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: r.w(12, tablet: 14, desktop: 16),
        vertical: r.h(6, tablet: 7, desktop: 8),
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: r.borderRadius(20),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: r.sp(11, tablet: 12, desktop: 13),
        ),
      ),
    );
  }
}
