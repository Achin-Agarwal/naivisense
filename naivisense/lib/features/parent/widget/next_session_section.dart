import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/date_utils.dart';
import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/data/models/session.dart';
import 'package:naivisense/shared/widgets/app_card.dart';

import 'section_header.dart';
import 'empty_hint.dart';

class NextSessionSection extends StatelessWidget {
  final AsyncValue<List<SessionModel>> sessions;

  const NextSessionSection({super.key, required this.sessions});

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    final upcoming =
        sessions.valueOrNull
            ?.where(
              (s) =>
                  s.status == 'scheduled' &&
                  s.scheduledAt.isAfter(DateTime.now()),
            )
            .toList()
          ?..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

    final next = upcoming?.isNotEmpty == true ? upcoming!.first : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Next Session', icon: Icons.event_outlined),

        r.gapH(14),

        if (next == null)
          const EmptyHint(
            message: 'No upcoming sessions scheduled',
            icon: Icons.event_busy_outlined,
          )
        else
          _NextSessionCard(session: next),
      ],
    );
  }
}

class _NextSessionCard extends StatelessWidget {
  final SessionModel session;

  const _NextSessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    final isOnline = session.mode == 'online';

    return AppCard(
      color: AppColors.primaryBlue.withValues(alpha: 0.04),

      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 360;

          return Wrap(
            spacing: r.w(14),
            runSpacing: r.h(12),
            crossAxisAlignment: WrapCrossAlignment.center,

            children: [
              Container(
                padding: EdgeInsets.all(r.w(12)),

                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.10),

                  borderRadius: r.borderRadius(14),
                ),

                child: Icon(
                  Icons.event,
                  color: AppColors.primaryBlue,
                  size: r.icon(24, tablet: 26, desktop: 28),
                ),
              ),

              SizedBox(
                width: compact
                    ? constraints.maxWidth - 40
                    : constraints.maxWidth * .50,

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      session.typeLabel,

                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,

                      style: TextStyle(
                        fontWeight: FontWeight.w600,

                        fontSize: r.sp(15, tablet: 16, desktop: 17),
                      ),
                    ),

                    r.gapH(5),

                    Text(
                      '${AppDateUtils.formatDate(session.scheduledAt)} • ${AppDateUtils.formatTime(session.scheduledAt)}',

                      maxLines: 2,

                      style: TextStyle(
                        color: AppColors.textSecondary,

                        fontSize: r.sp(12),
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: r.w(12),

                  vertical: r.h(6),
                ),

                decoration: BoxDecoration(
                  color: isOnline
                      ? AppColors.primaryBlue.withValues(alpha: .10)
                      : AppColors.mintGreen.withValues(alpha: .10),

                  borderRadius: r.borderRadius(20),
                ),

                child: Text(
                  isOnline ? 'Online' : 'In-Person',

                  style: TextStyle(
                    color: isOnline
                        ? AppColors.primaryBlue
                        : AppColors.mintGreen,

                    fontWeight: FontWeight.w600,

                    fontSize: r.sp(12),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
