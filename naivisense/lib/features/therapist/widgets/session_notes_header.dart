import 'package:flutter/material.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/date_utils.dart';
import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/core/utils/string_utils.dart';
import 'package:naivisense/data/models/session.dart';

class SessionNotesHeader extends StatelessWidget {
  const SessionNotesHeader({
    super.key,
    required this.childName,
    required this.session,
  });

  final String childName;
  final SessionModel session;

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.fromLTRB(
        r.w(20),
        0,
        r.w(20),
        r.h(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: r.avatar(22),
            backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.12),
            child: Text(
              childName[0].toUpperCase(),
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w700,
                fontSize: r.sp(18),
              ),
            ),
          ),

          r.gapW(12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  toTitleCase(childName),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: r.sp(16),
                  ),
                ),

                r.gapH(2),

                Text(
                  '${session.typeLabel} • ${AppDateUtils.formatTime(session.scheduledAt)} • ${session.durationMin} min',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: r.sp(12),
                  ),
                ),
              ],
            ),
          ),

          r.gapW(8),

          Container(
            padding: EdgeInsets.symmetric(
              horizontal: r.w(10),
              vertical: r.h(4),
            ),
            decoration: BoxDecoration(
              color: AppColors.mintGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(
                r.radius(20),
              ),
            ),
            child: Text(
              session.mode == 'online'
                  ? 'Online'
                  : 'In-Person',
              style: TextStyle(
                color: AppColors.mintGreen,
                fontWeight: FontWeight.w600,
                fontSize: r.sp(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}