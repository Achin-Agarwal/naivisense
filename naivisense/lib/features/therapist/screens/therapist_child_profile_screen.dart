import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/features/assessments/providers/assessment_provider.dart';
import 'package:naivisense/features/therapist/widgets/child/active_plan_card.dart';
import 'package:naivisense/features/therapist/widgets/child/add_session_button.dart';
import 'package:naivisense/features/therapist/widgets/child/assessment_section.dart';
import 'package:naivisense/features/therapist/widgets/child/child_profile_app_bar.dart';
import 'package:naivisense/features/therapist/widgets/child/diagnosis_section.dart';
import 'package:naivisense/features/therapist/widgets/child/diet_plan_section.dart';
import 'package:naivisense/features/therapist/widgets/child/goals_section.dart';
import 'package:naivisense/features/therapist/widgets/child/next_session_card.dart';
import 'package:naivisense/features/therapist/widgets/child/progress_charts.dart';
import 'package:naivisense/features/therapist/widgets/child/quick_stats_section.dart';
import 'package:naivisense/features/therapist/widgets/child/reviews_section.dart';
import 'package:naivisense/features/therapist/widgets/child/session_history_section.dart';
import 'package:naivisense/features/therapist/widgets/child/videos_section.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/child.dart';
import '../../../data/models/diet_plan.dart';
import '../../../data/models/home_plan.dart';
import '../../../data/models/session.dart';
import '../../../data/models/goal.dart';
import '../../../data/models/review.dart';
import '../../../data/models/video_item.dart';
import '../../../data/models/ai_draft.dart';
import '../providers/therapist_provider.dart';
import '../widgets/child/ai_drafts_section.dart';

class TherapistChildProfileScreen extends ConsumerWidget {
  final ChildModel child;
  const TherapistChildProfileScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responsive = Responsive(context);

    final sessions = ref.watch(therapistChildSessionsProvider(child.id));
    final nextSession = ref.watch(therapistChildNextSessionProvider(child.id));
    final plan = ref.watch(therapistChildPlanProvider(child.id));
    final dietPlan = ref.watch(therapistChildDietPlanProvider(child.id));
    final assessments = ref.watch(childAssessmentsProvider(child.id));
    final goals = ref.watch(therapistChildGoalsProvider(child.id));
    final reviews = ref.watch(therapistChildReviewsProvider(child.id));
    final videos = ref.watch(therapistChildVideosProvider(child.id));
    final aiDrafts = ref.watch(therapistAiDraftsProvider(child.id));

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(therapistChildSessionsProvider(child.id));
          ref.invalidate(therapistChildNextSessionProvider(child.id));
          ref.invalidate(therapistChildPlanProvider(child.id));
          ref.invalidate(therapistChildDietPlanProvider(child.id));
          ref.invalidate(childAssessmentsProvider(child.id));
          ref.invalidate(therapistChildGoalsProvider(child.id));
          ref.invalidate(therapistChildReviewsProvider(child.id));
          ref.invalidate(therapistChildVideosProvider(child.id));
          ref.invalidate(therapistAiDraftsProvider(child.id));
        },
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            ChildProfileAppBar(child: child),

            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: responsive.w(
                  responsive.isDesktop
                      ? 8
                      : responsive.isTablet
                      ? 5
                      : 4,
                ),
              ).copyWith(bottom: responsive.h(4)),
              sliver: SliverToBoxAdapter(
                child: _buildContent(
                  context,
                  responsive,
                  sessions,
                  nextSession,
                  plan,
                  dietPlan,
                  assessments,
                  goals,
                  reviews,
                  videos,
                  aiDrafts,
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
    Responsive r,
    AsyncValue<List<SessionModel>> sessions,
    AsyncValue<SessionModel?> nextSession,
    AsyncValue<HomePlanModel?> plan,
    AsyncValue<DietPlanModel?> dietPlan,
    AsyncValue<dynamic> assessments,
    AsyncValue<List<GoalModel>> goals,
    AsyncValue<List<ReviewModel>> reviews,
    AsyncValue<List<VideoItemModel>> videos,
    AsyncValue<List<AiDraftModel>> aiDrafts,
  ) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        r.gapH(18),

        // DiagnosisChips(child: child),

        // r.gapH(8),
        if (r.isMobile) ...[
          NextSessionCard(nextSession: nextSession),

          r.gapH(8),

          QuickStatsSection(sessions: sessions),
        ] else ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 250,
                  child: NextSessionCard(nextSession: nextSession),
                ),
              ),

              r.gapW(16),

              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 250,
                  child: QuickStatsSection(sessions: sessions),
                ),
              ),
            ],
          ),
        ],

        r.gapH(8),

        AssessmentSection(child: child, assessments: assessments),

        r.gapH(8),

        AddSessionButton(child: child),

        r.gapH(8),

        ProgressChartsSection(child: child, sessions: sessions),

        r.gapH(8),

        ActivePlanCard(plan: plan),

        r.gapH(8),

        DietPlanSection(plan: dietPlan),

        r.gapH(8),

        GoalsSection(goals: goals),

        r.gapH(8),

        ReviewsSection(reviews: reviews),

        r.gapH(8),

        VideosSection(videos: videos),

        r.gapH(8),

        AiDraftsSection(child: child, aiDrafts: aiDrafts),

        r.gapH(8),

        SessionHistorySection(child: child, sessions: sessions),

        r.gapH(4),
      ],
    );

    if (r.isMobile) {
      return content;
    }

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: r.isDesktop ? 900 : 750),
        child: content,
      ),
    );
  }
}
