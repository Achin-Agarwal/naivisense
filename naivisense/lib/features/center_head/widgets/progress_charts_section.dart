import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naivisense/core/utils/date_utils.dart';
import 'package:naivisense/data/models/session.dart';
import 'package:naivisense/shared/widgets/trend_chart.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import 'chart_card.dart';
import 'empty_card.dart';
import 'score_averages_card.dart';
import 'section_header.dart';

class ProgressChartsSection extends StatelessWidget {
  final AsyncValue<List<SessionModel>> sessions;

  const ProgressChartsSection({super.key, required this.sessions});

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    final completed =
        (sessions.valueOrNull
                  ?.where((s) => s.status == 'completed' && s.notes != null)
                  .toList() ??
              [])
          ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

    if (completed.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Progress Charts', icon: Icons.show_chart),

          r.gapH(12, tablet: 14, desktop: 16),

          const EmptyCard(message: 'No completed sessions with notes yet'),
        ],
      );
    }

    final labels = completed
        .map((s) => AppDateUtils.formatShortDate(s.scheduledAt))
        .toList();

    final attention = completed
        .map((s) => s.notes!.attentionScore.toDouble())
        .toList();

    final communication = completed
        .map((s) => s.notes!.communicationScore.toDouble())
        .toList();

    final motor = completed.map((s) => s.notes!.motorScore.toDouble()).toList();

    final behavior = completed
        .map((s) => s.notes!.behaviorScore.toDouble())
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Progress Charts', icon: Icons.show_chart),

        r.gapH(16, tablet: 18, desktop: 20),

        ChartCard(
          child: TrendChart(
            title: 'Attention',
            values: attention,
            labels: labels,
            lineColor: AppColors.primaryBlue,
          ),
        ),

        r.gapH(12, tablet: 14, desktop: 16),

        ChartCard(
          child: TrendChart(
            title: 'Communication',
            values: communication,
            labels: labels,
            lineColor: AppColors.mintGreen,
          ),
        ),

        r.gapH(12, tablet: 14, desktop: 16),

        ChartCard(
          child: TrendChart(
            title: 'Motor Skills',
            values: motor,
            labels: labels,
            lineColor: AppColors.warmYellow,
          ),
        ),

        r.gapH(12, tablet: 14, desktop: 16),

        ChartCard(
          child: TrendChart(
            title: 'Behavior',
            values: behavior,
            labels: labels,
            lineColor: AppColors.softCoral,
          ),
        ),

        r.gapH(12, tablet: 14, desktop: 16),

        ScoreAveragesCard(
          attention: attention,
          communication: communication,
          motor: motor,
          behavior: behavior,
        ),
      ],
    );
  }
}
