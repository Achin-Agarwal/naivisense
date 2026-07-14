import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/features/parent/widget/accepted_goals_section.dart';
import 'package:naivisense/features/parent/widget/child_detail_app_bar.dart';
import 'package:naivisense/features/parent/widget/diet_plan_section.dart';
import 'package:naivisense/features/parent/widget/home_plan.dart';
import 'package:naivisense/features/parent/widget/improvement_videos_section.dart';
import 'package:naivisense/features/parent/widget/last_session_notes_section.dart';
import 'package:naivisense/features/parent/widget/next_session_section.dart';
import 'package:naivisense/features/parent/widget/open_alerts_section.dart';
import 'package:naivisense/features/parent/widget/progress_section.dart';
import 'package:naivisense/features/parent/widget/published_reviews_section.dart';
import 'package:naivisense/features/parent/widget/raise_alert_card.dart';
import 'package:naivisense/features/parent/widget/scheduled_sessions.dart';
import 'package:naivisense/features/therapist/widgets/child/diagnosis_section.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/alert.dart';
import '../../../data/models/child.dart';
import '../../../data/models/diet_plan.dart';
import '../../../data/models/goal.dart';
import '../../../data/models/home_plan.dart';
import '../../../data/models/review.dart';
import '../../../data/models/video_item.dart';
import '../../../data/models/session.dart';
import '../providers/parent_provider.dart';

class ChildDetailScreen extends ConsumerWidget {
  final ChildModel child;
  const ChildDetailScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = Responsive(context);

    final sessions = ref.watch(parentSessionsProvider(child.id));
    final plan = ref.watch(parentActivePlanProvider(child.id));
    final dietPlan = ref.watch(parentDietPlanProvider(child.id));
    final alerts = ref.watch(parentAlertsProvider(child.id));
    final goals = ref.watch(parentGoalsProvider(child.id));
    final reviews = ref.watch(parentReviewsProvider(child.id));
    final videos = ref.watch(parentVideosProvider(child.id));

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(parentSessionsProvider(child.id));
          ref.invalidate(parentActivePlanProvider(child.id));
          ref.invalidate(parentDietPlanProvider(child.id));
          ref.invalidate(parentAlertsProvider(child.id));
          ref.invalidate(parentGoalsProvider(child.id));
          ref.invalidate(parentReviewsProvider(child.id));
          ref.invalidate(parentVideosProvider(child.id));
        },
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            ChildDetailAppBar(child: child),

            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: r.horizontalPadding,
                vertical: r.verticalPadding,
              ),
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: r.maxWidth),
                    child: _buildContent(
                      context,
                      ref,
                      sessions,
                      plan,
                      dietPlan,
                      alerts,
                      goals,
                      reviews,
                      videos,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<SessionModel>> sessions,
    AsyncValue<HomePlanModel?> plan,
    AsyncValue<DietPlanModel?> dietPlan,
    AsyncValue<List<AlertModel>> alerts,
    AsyncValue<List<GoalModel>> goals,
    AsyncValue<List<ReviewModel>> reviews,
    AsyncValue<List<VideoItemModel>> videos,
  ) {
    final r = Responsive(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // DiagnosisChips(child: child),
        // SizedBox(height: r.sectionSpacing),
        ProgressSection(
          childId: child.id,
          childName: child.name,
          sessions: sessions,
        ),

        SizedBox(height: r.sectionSpacing),

        NextSessionSection(sessions: sessions),

        SizedBox(height: r.sectionSpacing),

        ScheduledSessions(child: child),

        SizedBox(height: r.sectionSpacing),

        HomePlanSection(plan: plan),

        SizedBox(height: r.sectionSpacing),

        DietPlanSection(dietPlan: dietPlan),

        SizedBox(height: r.sectionSpacing),

        LastSessionNotesSection(sessions: sessions),

        SizedBox(height: r.sectionSpacing),

        OpenAlertsSection(alerts: alerts),

        SizedBox(height: r.sectionSpacing),

        AcceptedGoalsSection(goals: goals),

        SizedBox(height: r.sectionSpacing),

        PublishedReviewsSection(reviews: reviews),

        // SizedBox(height: r.sectionSpacing),
        ImprovementVideosSection(childId: child.id, videos: videos),

        SizedBox(height: r.sectionSpacing),

        RaiseAlertCard(child: child),

        SizedBox(height: r.verticalPadding),
      ],
    );
  }
}
