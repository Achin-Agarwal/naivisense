import 'package:flutter/material.dart';
import 'package:naivisense/core/utils/date_utils.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/models/session.dart';
import 'notes_row.dart';

class SessionHistoryCard extends StatelessWidget {
  final SessionModel session;

  const SessionHistoryCard({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    final (statusColor, statusLabel) = switch (session.status) {
      'completed' => (AppColors.mintGreen, 'Completed'),
      'cancelled' => (AppColors.softCoral, 'Cancelled'),
      _ => (AppColors.warmYellow, 'Scheduled'),
    };

    return Container(
      padding: EdgeInsets.all(r.w(14, tablet: 16, desktop: 18)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          r.radius(14, tablet: 16, desktop: 18),
        ),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.typeLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: r.sp(14, tablet: 15, desktop: 16),
                      ),
                    ),

                    r.gapH(2, tablet: 3, desktop: 4),

                    Text(
                      '${AppDateUtils.formatDate(session.scheduledAt)}  •  '
                      '${session.durationMin} min  •  ${session.mode}',
                      style: TextStyle(
                        fontSize: r.sp(12, tablet: 13, desktop: 14),
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              r.gapW(8, tablet: 10, desktop: 12),

              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: r.w(10, tablet: 11, desktop: 12),
                  vertical: r.h(4, tablet: 5, desktop: 6),
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    r.radius(12, tablet: 13, desktop: 14),
                  ),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: r.sp(11, tablet: 12, desktop: 13),
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),

          if (session.notes != null) ...[
            Divider(height: r.h(16, tablet: 18, desktop: 20)),
            NotesRow(notes: session.notes!),
          ],
        ],
      ),
    );
  }
}
