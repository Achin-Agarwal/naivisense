import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/features/therapist/widgets/child/section_title.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../data/models/child.dart';
import '../../../../data/models/session.dart';
import '../../../../shared/widgets/trend_chart.dart';
import '../../../reports/screens/weekly_report_screen.dart';
import 'empty_message.dart';

class ProgressChartsSection extends StatelessWidget {
  final ChildModel child;
  final AsyncValue<List<SessionModel>> sessions;

  const ProgressChartsSection({
    super.key,
    required this.child,
    required this.sessions,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    final completed =
        (sessions.valueOrNull
                  ?.where((s) => s.status == 'completed' && s.notes != null)
                  .toList() ??
              [])
          ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

    if (completed.isEmpty) {
      return const ProfileCard(
        title: 'Progress Trends',
        icon: Icons.show_chart,
        child: EmptyMessage(message: 'No completed sessions with notes yet'),
      );
    }

    final labels = completed
        .map((e) => AppDateUtils.formatShortDate(e.scheduledAt))
        .toList();

    return ProfileCard(
      title: 'Progress Trends',
      icon: Icons.show_chart,
      child: Column(
        children: [
          TrendChart(
            title: 'Attention',
            values: completed
                .map((e) => e.notes!.attentionScore.toDouble())
                .toList(),
            labels: labels,
            lineColor: AppColors.primaryBlue,
          ),

          responsive.gapH(24),

          TrendChart(
            title: 'Communication',
            values: completed
                .map((e) => e.notes!.communicationScore.toDouble())
                .toList(),
            labels: labels,
            lineColor: AppColors.mintGreen,
          ),

          responsive.gapH(24),

          TrendChart(
            title: 'Motor Skills',
            values: completed
                .map((e) => e.notes!.motorScore.toDouble())
                .toList(),
            labels: labels,
            lineColor: AppColors.warmYellow,
          ),

          responsive.gapH(24),

          TrendChart(
            title: 'Behavior',
            values: completed
                .map((e) => e.notes!.behaviorScore.toDouble())
                .toList(),
            labels: labels,
            lineColor: AppColors.softCoral,
          ),

          responsive.gapH(20),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              icon: const Icon(Icons.open_in_new),
              label: const Text('View Full Report'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WeeklyReportScreen(
                      childId: child.id,
                      childName: child.name,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
