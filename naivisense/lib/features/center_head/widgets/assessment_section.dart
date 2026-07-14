import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naivisense/data/models/child.dart';
import 'package:naivisense/features/assessments/screens/assessment_result_screen.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import 'admin_assessment_button.dart';
import 'admin_assessment_row.dart';
import 'empty_card.dart';
import 'loading_card.dart';
import 'section_header.dart';

class AssessmentSection extends StatelessWidget {
  final ChildModel child;
  final AsyncValue<dynamic> assessments;
  final void Function(BuildContext context, String type) openWizard;

  const AssessmentSection({
    super.key,
    required this.child,
    required this.assessments,
    required this.openWizard,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    final list = (assessments.valueOrNull as List?) ?? [];
    final isLoading = assessments.isLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Assessments',
          icon: Icons.assignment_outlined,
        ),

        r.gapH(12, tablet: 14, desktop: 16),

        LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < Responsive.mobileBreakpoint;

            final spacing = r.w(12, tablet: 14, desktop: 16);

            final itemWidth = isMobile
                ? constraints.maxWidth
                : (constraints.maxWidth - spacing) / 2;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                SizedBox(
                  width: itemWidth,
                  child: AdminAssessmentButton(
                    label: list.isEmpty
                        ? 'Start Initial Assessment'
                        : 'New Monthly Assessment',
                    icon: list.isEmpty
                        ? Icons.play_arrow_rounded
                        : Icons.refresh_rounded,
                    color: AppColors.primaryBlue,
                    onTap: () => openWizard(
                      context,
                      list.isEmpty ? 'initial' : 'monthly',
                    ),
                  ),
                ),

                SizedBox(
                  width: itemWidth,
                  child: AdminAssessmentButton(
                    label: 'Quarterly Review',
                    icon: Icons.bar_chart_rounded,
                    color: const Color(0xFF9B59B6),
                    onTap: () => openWizard(context, 'quarterly'),
                  ),
                ),
              ],
            );
          },
        ),

        if (isLoading) ...[
          r.gapH(12, tablet: 14, desktop: 16),
          const LoadingCard(),
        ] else if (list.isEmpty) ...[
          r.gapH(12, tablet: 14, desktop: 16),
          const EmptyCard(
            message:
                'No assessments done yet. Start the initial assessment above.',
          ),
        ] else ...[
          r.gapH(14, tablet: 16, desktop: 18),

          ...list
              .take(6)
              .map(
                (assessment) => Padding(
                  padding: EdgeInsets.only(
                    bottom: r.h(10, tablet: 12, desktop: 14),
                  ),
                  child: AdminAssessmentRow(
                    assessment: assessment,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AssessmentResultScreen(
                            assessment: assessment,
                            child: child,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
        ],
      ],
    );
  }
}
