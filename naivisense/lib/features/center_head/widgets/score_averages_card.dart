import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import 'score_bar.dart';

class ScoreAveragesCard extends StatelessWidget {
  final List<double> attention;
  final List<double> communication;
  final List<double> motor;
  final List<double> behavior;

  const ScoreAveragesCard({
    super.key,
    required this.attention,
    required this.communication,
    required this.motor,
    required this.behavior,
  });

  double _average(List<double> values) {
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return Container(
      padding: r.allPadding(16, tablet: 18, desktop: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: r.borderRadius(16, tablet: 18, desktop: 20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Average Scores',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: r.sp(18, tablet: 20, desktop: 22),
            ),
          ),

          r.gapH(14, tablet: 16, desktop: 18),

          ScoreBar(
            label: 'Attention',
            value: _average(attention),
            color: AppColors.primaryBlue,
          ),

          r.gapH(8, tablet: 10, desktop: 12),

          ScoreBar(
            label: 'Communication',
            value: _average(communication),
            color: AppColors.mintGreen,
          ),

          r.gapH(8, tablet: 10, desktop: 12),

          ScoreBar(
            label: 'Motor Skills',
            value: _average(motor),
            color: AppColors.warmYellow,
          ),

          r.gapH(8, tablet: 10, desktop: 12),

          ScoreBar(
            label: 'Behavior',
            value: _average(behavior),
            color: AppColors.softCoral,
          ),
        ],
      ),
    );
  }
}
