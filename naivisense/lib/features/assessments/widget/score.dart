import 'package:flutter/material.dart';
import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/features/assessments/data/assessment_domains.dart';

class ScoreLegend extends StatelessWidget {
  final Color color;

  const ScoreLegend({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return Wrap(
      spacing: r.w(10, tablet: 12, desktop: 14),
      runSpacing: r.h(8, tablet: 10, desktop: 12),
      children: List.generate(
        4,
        (i) => Container(
          padding: EdgeInsets.symmetric(
            horizontal: r.w(10, tablet: 12, desktop: 14),
            vertical: r.h(5, tablet: 6, desktop: 7),
          ),
          decoration: BoxDecoration(
            color: kScoreColors[i].withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(
              r.radius(20, tablet: 22, desktop: 24),
            ),
            border: Border.all(color: kScoreColors[i].withValues(alpha: 0.4)),
          ),
          child: Text(
            '$i - ${kScoreLabels[i]}',
            style: TextStyle(
              fontSize: r.sp(11, tablet: 12, desktop: 13),
              fontWeight: FontWeight.w600,
              color: kScoreColors[i],
            ),
          ),
        ),
      ),
    );
  }
}
