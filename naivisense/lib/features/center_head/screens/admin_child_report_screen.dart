import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naivisense/features/center_head/widgets/active_plan_section.dart';
import 'package:naivisense/features/center_head/widgets/alerts_section.dart';
import 'package:naivisense/features/center_head/widgets/assessment_section.dart';
import 'package:naivisense/features/center_head/widgets/child_hero_app_bar.dart';
import 'package:naivisense/features/center_head/widgets/diagnosis_section.dart';
import 'package:naivisense/features/center_head/widgets/diet_plan_section.dart';
import 'package:naivisense/features/center_head/widgets/progress_charts_section.dart';
import 'package:naivisense/features/center_head/widgets/quick_stats_section.dart';
import 'package:naivisense/features/center_head/widgets/session_history_section.dart';
import 'package:naivisense/features/center_head/widgets/staff_section.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/models/child.dart';
import '../../../features/assessments/providers/assessment_provider.dart';
import '../../../features/assessments/screens/assessment_wizard_screen.dart';
import '../providers/center_head_provider.dart';

String _shortIdOrFallback(String id, String fallback) {
  if (id.isEmpty) return fallback;
  return id.length <= 8 ? id : id.substring(0, 8);
}

class AdminChildReportScreen extends ConsumerWidget {
  final ChildModel child;

  const AdminChildReportScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = Responsive(context);

    final sessions = ref.watch(adminChildSessionsProvider(child.id));
    final plan = ref.watch(adminChildPlanProvider(child.id));
    final dietPlan = ref.watch(adminChildDietPlanProvider(child.id));
    final alerts = ref.watch(adminChildAlertsProvider(child.id));
    final assessments = ref.watch(childAssessmentsProvider(child.id));

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(adminChildSessionsProvider(child.id));
                ref.invalidate(adminChildPlanProvider(child.id));
                ref.invalidate(adminChildDietPlanProvider(child.id));
                ref.invalidate(adminChildAlertsProvider(child.id));
                ref.invalidate(childAssessmentsProvider(child.id));
              },
              child: CustomScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                slivers: [
                  ChildHeroAppBar(child: child),

                  SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: r.isDesktop ? 950 : r.maxWidth,
                        ),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            r.horizontalPadding,
                            r.h(16),
                            r.horizontalPadding,
                            r.h(32) + MediaQuery.of(context).padding.bottom,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              DiagnosisSection(diagnosis: child.diagnosis),

                              SizedBox(height: r.h(22)),

                              AssessmentSection(
                                child: child,
                                assessments: assessments,
                                openWizard: _openWizard,
                              ),

                              SizedBox(height: r.h(26)),

                              QuickStatsSection(
                                sessions: sessions,
                                alerts: alerts,
                              ),

                              SizedBox(height: r.h(26)),

                              StaffSection(
                                child: child,
                                sessions: sessions,
                                shortIdOrFallback: _shortIdOrFallback,
                              ),

                              SizedBox(height: r.h(26)),

                              ProgressChartsSection(sessions: sessions),

                              SizedBox(height: r.h(26)),

                              ActivePlanSection(plan: plan),

                              SizedBox(height: r.h(26)),

                              DietPlanSection(plan: dietPlan),

                              SizedBox(height: r.h(26)),

                              SessionHistorySection(sessions: sessions),

                              SizedBox(height: r.h(26)),

                              AlertsSection(alerts: alerts),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _openWizard(BuildContext context, String type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AssessmentWizardScreen(child: child, assessmentType: type),
      ),
    );
  }
}
