import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:naivisense/features/parent/providers/parent_provider.dart';
import 'package:naivisense/features/parent/widget/info_tile.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../data/models/child.dart';
import '../../../../shared/widgets/app_card.dart';

class ParentChildCard extends ConsumerWidget {
  final ChildModel child;

  const ParentChildCard({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = Responsive(context);

    final sessions = ref.watch(parentSessionsProvider(child.id));
    final plan = ref.watch(parentActivePlanProvider(child.id));

    final upcoming =
        sessions.valueOrNull
            ?.where(
              (s) =>
                  s.status == 'scheduled' &&
                  s.scheduledAt.isAfter(DateTime.now()),
            )
            .toList()
          ?..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

    return AppCard(
      onTap: () => context.push('/parent/child/${child.id}', extra: child),

      child: Padding(
        padding: r.allPadding(2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //----------------------------------------------------------
            // Header
            //----------------------------------------------------------
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: r.avatar(26, tablet: 30, desktop: 34),
                  backgroundColor: AppColors.mintGreen.withValues(alpha: .15),
                  child: Text(
                    child.name[0].toUpperCase(),
                    style: TextStyle(
                      color: AppColors.mintGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: r.sp(18, tablet: 20, desktop: 22),
                    ),
                  ),
                ),

                r.gapW(14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        child.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: r.sp(17, tablet: 18, desktop: 19),
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      SizedBox(height: r.h(4)),

                      Text(
                        "${child.ageYears} yrs",
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: r.sp(13),
                        ),
                      ),
                    ],
                  ),
                ),

                // _SeverityBadge(severity: child.severity),
              ],
            ),

            r.gapH(18),

            //----------------------------------------------------------
            // Diagnosis
            //----------------------------------------------------------
            Wrap(
              spacing: r.w(8),
              runSpacing: r.h(8),
              children: child.diagnosis.map((diagnosis) {
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: r.w(12),
                    vertical: r.h(6),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    diagnosis,
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w600,
                      fontSize: r.sp(12),
                    ),
                  ),
                );
              }).toList(),
            ),

            r.gapH(18),

            //----------------------------------------------------------
            // Information Cards
            //----------------------------------------------------------
            InfoTile(
              icon: Icons.assignment_outlined,
              color: AppColors.primaryBlue,
              label: plan.valueOrNull != null
                  ? "${plan.valueOrNull!.tasks.length} tasks this week"
                  : "No active plan",
            ),

            r.gapH(10),

            InfoTile(
              icon: Icons.event_outlined,
              color: AppColors.mintGreen,
              label: (upcoming?.isNotEmpty ?? false)
                  ? AppDateUtils.formatDate(upcoming!.first.scheduledAt)
                  : "No upcoming session",
            ),

            const Spacer(),

            //----------------------------------------------------------
            // Button
            //----------------------------------------------------------
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  context.push('/parent/child/${child.id}', extra: child);
                },
                icon: const Icon(Icons.arrow_forward),
                label: const Text("View Details"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SeverityBadge extends StatelessWidget {
  final String severity;

  const _SeverityBadge({required this.severity});

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    final (label, color) = switch (severity) {
      'mild' => ('Mild', AppColors.mintGreen),
      'moderate' => ('Moderate', AppColors.warmYellow),
      'severe' => ('Severe', AppColors.softCoral),
      _ => ('Unknown', AppColors.textSecondary),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: r.w(10), vertical: r.h(5)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withValues(alpha: .25)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: r.sp(11),
        ),
      ),
    );
  }
}
