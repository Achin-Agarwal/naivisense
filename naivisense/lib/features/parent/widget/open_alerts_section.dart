import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/data/models/alert.dart';
import 'package:naivisense/features/parent/widget/section_header.dart';


class OpenAlertsSection extends StatelessWidget {
  final AsyncValue<List<AlertModel>> alerts;

  const OpenAlertsSection({
    super.key,
    required this.alerts,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    final openAlerts =
        alerts.valueOrNull
            ?.where((alert) => alert.status == 'open')
            .toList() ??
        [];

    if (openAlerts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Open Alerts',
          icon: Icons.warning_amber_outlined,
          color: AppColors.softCoral,
        ),

        r.gapH(16),

        ...openAlerts.map(
          (alert) => Padding(
            padding: EdgeInsets.only(
              bottom: r.h(10),
            ),
            child: Container(
              padding: r.allPadding(14),
              decoration: BoxDecoration(
                color: AppColors.softCoral.withValues(alpha: 0.07),
                borderRadius: r.borderRadius(12),
                border: Border.all(
                  color: AppColors.softCoral.withValues(alpha: 0.30),
                ),
              ),
              child: Wrap(
                spacing: r.w(14),
                runSpacing: r.h(10),
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.softCoral,
                    size: r.icon(
                      22,
                      tablet: 24,
                      desktop: 26,
                    ),
                  ),

                  SizedBox(
                    width: r.isMobile
                        ? MediaQuery.sizeOf(context).width * 0.55
                        : r.w(
                            420,
                            tablet: 460,
                            desktop: 500,
                          ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alert.typeLabel,
                          style: TextStyle(
                            color: AppColors.softCoral,
                            fontWeight: FontWeight.w600,
                            fontSize: r.sp(
                              14,
                              tablet: 15,
                              desktop: 16,
                            ),
                          ),
                        ),

                        r.gapH(2),

                        Text(
                          alert.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: r.sp(
                              12,
                              tablet: 13,
                              desktop: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: r.w(10),
                      vertical: r.h(5),
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.softCoral.withValues(alpha: 0.15),
                      borderRadius: r.borderRadius(8),
                    ),
                    child: Text(
                      alert.severity.toUpperCase(),
                      style: TextStyle(
                        color: AppColors.softCoral,
                        fontWeight: FontWeight.w700,
                        fontSize: r.sp(
                          11,
                          tablet: 12,
                          desktop: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}