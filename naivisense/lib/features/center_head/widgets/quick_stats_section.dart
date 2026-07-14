import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naivisense/data/models/alert.dart';
import 'package:naivisense/data/models/session.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import 'quick_stat.dart';

class QuickStatsSection extends StatelessWidget {
  final AsyncValue<List<SessionModel>> sessions;
  final AsyncValue<List<AlertModel>> alerts;

  const QuickStatsSection({
    super.key,
    required this.sessions,
    required this.alerts,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    final total = sessions.valueOrNull?.length ?? 0;

    final completed =
        sessions.valueOrNull?.where((s) => s.status == 'completed').length ?? 0;

    final openAlerts =
        alerts.valueOrNull?.where((a) => a.status == 'open').length ?? 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < Responsive.mobileBreakpoint;

        final stats = [
          Expanded(
            child: QuickStat(
              label: 'Total\nSessions',
              value: '$total',
              color: AppColors.primaryBlue,
              icon: Icons.event_note_outlined,
            ),
          ),
          Expanded(
            child: QuickStat(
              label: 'Completed',
              value: '$completed',
              color: AppColors.mintGreen,
              icon: Icons.check_circle_outline,
            ),
          ),
          Expanded(
            child: QuickStat(
              label: 'Open\nAlerts',
              value: '$openAlerts',
              color: openAlerts > 0
                  ? AppColors.softCoral
                  : AppColors.textSecondary,
              icon: Icons.notifications_active_outlined,
            ),
          ),
        ];

        if (isMobile) {
          return Column(
            children: [
              stats[0],
              r.gapH(12, tablet: 14, desktop: 16),
              stats[1],
              r.gapH(12, tablet: 14, desktop: 16),
              stats[2],
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            stats[0],
            r.gapW(12, tablet: 14, desktop: 16),
            stats[1],
            r.gapW(12, tablet: 14, desktop: 16),
            stats[2],
          ],
        );
      },
    );
  }
}
