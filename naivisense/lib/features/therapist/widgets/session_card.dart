import 'package:flutter/material.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/date_utils.dart';
import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/data/models/session.dart';
import 'package:naivisense/shared/widgets/app_card.dart';

class SessionCard extends StatelessWidget {
  final SessionModel session;
  final String childName;
  final VoidCallback onNotes;

  const SessionCard({super.key, 
    required this.session,
    required this.childName,
    required this.onNotes,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    final isCompleted = session.status == 'completed';

    return AppCard(
      child: Row(
        children: [
          Container(
            width: 4,
            height: responsive.h(52, tablet: 56, desktop: 60),
            decoration: BoxDecoration(
              color: isCompleted ? AppColors.mintGreen : AppColors.primaryBlue,
              borderRadius: responsive.borderRadius(12, desktop: 14),
            ),
          ),

          SizedBox(width: responsive.w(10, tablet: 12, desktop: 12)),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  childName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: responsive.sp(14, tablet: 16, desktop: 17),
                  ),
                ),

                SizedBox(height: responsive.h(4, tablet: 5, desktop: 6)),

                Text(
                  '${session.typeLabel} • '
                  '${AppDateUtils.formatTime(session.scheduledAt)} • '
                  '${session.durationMin} min',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: responsive.sp(12, tablet: 13, desktop: 14),
                  ),
                ),
              ],
            ),
          ),

          isCompleted
              ? Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.w(8, tablet: 10, desktop: 12),
                    vertical: responsive.h(4, tablet: 5, desktop: 6),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.mintGreen.withValues(alpha: 0.12),
                    borderRadius: responsive.borderRadius(12, desktop: 14),
                  ),
                  child: Text(
                    'Done',
                    style: TextStyle(
                      color: AppColors.mintGreen,
                      fontSize: responsive.sp(11, tablet: 12, desktop: 13),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : TextButton(
                  onPressed: onNotes,
                  child: Text(
                    'Add Notes',
                    style: TextStyle(
                      fontSize: responsive.sp(12, tablet: 13, desktop: 14),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
