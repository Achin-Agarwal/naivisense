import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/data/models/child.dart';
import 'package:naivisense/shared/widgets/app_button.dart';
import 'package:naivisense/shared/widgets/app_card.dart';

class RaiseAlertCard extends ConsumerWidget {
  final ChildModel child;

  const RaiseAlertCard({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = Responsive(context);

    return AppCard(
      color: AppColors.softCoral.withValues(alpha: 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.report_problem_outlined,
                color: AppColors.softCoral,
                size: r.icon(22, tablet: 24, desktop: 26),
              ),

              r.gapW(8),

              Expanded(
                child: Text(
                  'Report a Concern',
                  style: TextStyle(
                    color: AppColors.softCoral,
                    fontWeight: FontWeight.w600,
                    fontSize: r.sp(17, tablet: 18, desktop: 20),
                  ),
                ),
              ),
            ],
          ),

          r.gapH(6),

          Text(
            'Let your therapist know about fever, regression, behavioral changes, or any health concern.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: r.sp(14, tablet: 15, desktop: 16),
            ),
          ),

          r.gapH(14),

          AppButton(
            label: 'Raise Alert',
            outlined: true,
            icon: Icons.add_alert_outlined,
            onPressed: () =>
                context.push('/parent/child/${child.id}/alert', extra: child),
          ),
        ],
      ),
    );
  }
}
