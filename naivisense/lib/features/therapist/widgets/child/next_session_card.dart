import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../data/models/session.dart';

class NextSessionCard extends StatelessWidget {
  final AsyncValue<SessionModel?> nextSession;

  const NextSessionCard({super.key, required this.nextSession});

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    return nextSession.when(
      loading: () => const SizedBox.shrink(),

      error: (_, _) => const SizedBox.shrink(),

      data: (session) {
        if (session == null) {
          return Container(
            padding: EdgeInsets.symmetric(
              horizontal: responsive.w(16, tablet: 20, desktop: 24),
              vertical: responsive.h(14, tablet: 16, desktop: 18),
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: responsive.borderRadius(
                14,
                tablet: 16,
                desktop: 18,
              ),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.event_busy_outlined,
                  color: AppColors.textSecondary,
                  size: responsive.icon(22, tablet: 24, desktop: 26),
                ),

                responsive.gapW(12, tablet: 14, desktop: 16),

                Expanded(
                  child: Text(
                    'No upcoming session scheduled',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: responsive.sp(13, tablet: 14, desktop: 15),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          // height: responsive.h(120, tablet: 130, desktop: 140),
          padding: EdgeInsets.all(responsive.w(18, tablet: 20, desktop: 24)),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.08),
            borderRadius: responsive.borderRadius(16, tablet: 18, desktop: 20),
            border: Border.all(
              color: AppColors.primaryBlue.withValues(alpha: 0.20),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(
                  responsive.w(10, tablet: 11, desktop: 12),
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: .12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.event,
                  color: AppColors.primaryBlue,
                  size: responsive.icon(24, tablet: 26, desktop: 28),
                ),
              ),

              responsive.gapW(16, tablet: 18, desktop: 20),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Next Session',
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w700,
                        fontSize: responsive.sp(13, tablet: 14, desktop: 15),
                      ),
                    ),

                    responsive.gapH(6, tablet: 8, desktop: 10),

                    Text(
                      session.typeLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: responsive.sp(16, tablet: 17, desktop: 18),
                      ),
                    ),

                    responsive.gapH(6, tablet: 8, desktop: 10),

                    Wrap(
                      spacing: responsive.w(14),
                      runSpacing: responsive.h(6),
                      children: [
                        _InfoChip(
                          icon: Icons.calendar_today_outlined,
                          text: AppDateUtils.formatDate(session.scheduledAt),
                        ),

                        _InfoChip(
                          icon: Icons.access_time_outlined,
                          text: AppDateUtils.formatTime(session.scheduledAt),
                        ),

                        _InfoChip(
                          icon: Icons.timelapse_outlined,
                          text: '${session.durationMin} min',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.w(10),
        vertical: responsive.h(6),
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: responsive.icon(14), color: AppColors.primaryBlue),
          responsive.gapW(6, tablet: 8, desktop: 10),
          Text(text, style: TextStyle(fontSize: responsive.sp(12))),
        ],
      ),
    );
  }
}
