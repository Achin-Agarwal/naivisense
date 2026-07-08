import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/date_utils.dart';
import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/data/models/session.dart';
import 'package:naivisense/features/parent/widget/empty_hint.dart';
import 'package:naivisense/features/parent/widget/score_tile.dart';
import 'package:naivisense/features/parent/widget/section_header.dart';
import 'package:naivisense/features/reports/screens/weekly_report_screen.dart';

class ProgressSection extends StatelessWidget {
  final String childId;
  final String childName;
  final AsyncValue<List<SessionModel>> sessions;

  const ProgressSection({
    super.key,
    required this.childId,
    required this.childName,
    required this.sessions,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    final completed =
        sessions.valueOrNull
            ?.where((s) => s.status == 'completed' && s.notes != null)
            .toList()
          ?..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));

    final latest = completed?.isNotEmpty == true ? completed!.first : null;

    final gridCount = r.isMobile
        ? 2
        : r.isTablet
        ? 2
        : 4;

    final aspectRatio = r.isDesktop ? 1.5 : 1.25;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Progress (Last Session)',
          icon: Icons.show_chart_outlined,
        ),

        r.gapH(16),

        if (latest == null)
          const EmptyHint(message: 'No session notes yet')
        else
          GridView.count(
            crossAxisCount: gridCount,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: r.w(12),
            mainAxisSpacing: r.h(12),
            childAspectRatio: aspectRatio,
            children: [
              ScoreTile(
                title: 'Attention',
                score: latest.notes!.attentionScore,
                color: AppColors.primaryBlue,
              ),

              ScoreTile(
                title: 'Communication',
                score: latest.notes!.communicationScore,
                color: AppColors.mintGreen,
              ),

              ScoreTile(
                title: 'Motor Skills',
                score: latest.notes!.motorScore,
                color: AppColors.warmYellow,
              ),

              ScoreTile(
                title: 'Social',
                score: latest.notes!.behaviorScore,
                color: const Color(0xFFAB7AE0),
              ),
            ],
          ),

        if (latest != null) ...[
          r.gapH(12),

          Text(
            'From session on ${AppDateUtils.formatDate(latest.scheduledAt)}',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: r.sp(12),
            ),
          ),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WeeklyReportScreen(
                      childId: childId,
                      childName: childName,
                    ),
                  ),
                );
              },
              icon: Icon(Icons.bar_chart_outlined, size: r.icon(18)),
              label: Text(
                'View Full Report',
                style: TextStyle(fontSize: r.sp(13)),
              ),
              style: TextButton.styleFrom(foregroundColor: AppColors.mintGreen),
            ),
          ),
        ],
      ],
    );
  }
}
