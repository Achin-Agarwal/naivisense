import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naivisense/core/utils/string_utils.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/child.dart';
import '../../../data/models/diet_plan.dart';
import '../../../data/models/home_plan.dart';
import '../../../data/models/session.dart';
import '../../../data/models/goal.dart';
import '../../../data/models/review.dart';
import '../../../data/models/video_item.dart';
import '../../../data/models/ai_draft.dart';
import '../../../shared/widgets/trend_chart.dart';
import '../../../features/reports/screens/weekly_report_screen.dart';
import '../../../features/assessments/providers/assessment_provider.dart';
import '../../../features/assessments/screens/assessment_wizard_screen.dart';
import '../../../features/assessments/screens/assessment_result_screen.dart';
import '../../../data/repositories/ai_repository.dart';
import '../providers/therapist_provider.dart';
import 'create_session_screen.dart';
import 'session_notes_screen.dart';

class TherapistChildProfileScreen extends ConsumerWidget {
  final ChildModel child;
  const TherapistChildProfileScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(therapistChildSessionsProvider(child.id));
    final nextSession = ref.watch(therapistChildNextSessionProvider(child.id));
    final plan = ref.watch(therapistChildPlanProvider(child.id));
    final dietPlan = ref.watch(therapistChildDietPlanProvider(child.id));
    final assessments = ref.watch(childAssessmentsProvider(child.id));
    final goals = ref.watch(therapistChildGoalsProvider(child.id));
    final reviews = ref.watch(therapistChildReviewsProvider(child.id));
    final videos = ref.watch(therapistChildVideosProvider(child.id));
    final aiDrafts = ref.watch(therapistAiDraftsProvider(child.id));

    // Top-level LayoutBuilder provides breakpoint-aware sizing for this screen.
    return LayoutBuilder(
      builder: (context, constraints) {
        final media = MediaQuery.of(context);
        final ui = _ResponsiveUi.from(constraints.maxWidth, media);

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
                _buildAppBar(context, ui),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    ui.pagePadding,
                    0,
                    ui.pagePadding,
                    ui.bottomGap,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: _buildContent(
                      context,
                      ref,
                      ui,
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
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    _ResponsiveUi ui,
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
      children: [
        SizedBox(height: ui.sectionGap),
        _buildDiagnosis(context, ui),
        SizedBox(height: ui.sectionGap),
        _buildNextSession(context, nextSession, ui),
        SizedBox(height: ui.sectionGap),
        _buildQuickStats(sessions, ui),
        SizedBox(height: ui.sectionGap),
        _buildAssessmentSection(context, assessments, ui),
        SizedBox(height: ui.sectionGap),
        _buildAddSessionButton(context, ui),
        SizedBox(height: ui.sectionGapLg),
        _buildProgressCharts(context, sessions, ui),
        SizedBox(height: ui.sectionGapLg),
        _buildActivePlan(context, plan, ui),
        SizedBox(height: ui.sectionGapLg),
        _buildDietPlan(context, dietPlan, ui),
        SizedBox(height: ui.sectionGapLg),
        _buildGoals(context, ref, goals, ui),
        SizedBox(height: ui.sectionGapLg),
        _buildReviews(context, reviews, ui),
        SizedBox(height: ui.sectionGapLg),
        _buildVideos(context, videos, ui),
        SizedBox(height: ui.sectionGapLg),
        _buildAiDrafts(context, ref, aiDrafts, ui),
        SizedBox(height: ui.sectionGapLg),
        _buildSessionHistory(context, ref, sessions, ui),
      ],
    );

    if (ui.isMobile) return content;

    // Tablet/Desktop: constrain width for comfortable reading.
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: content,
      ),
    );
  }

  // ── Hero App Bar ─────────────────────────────────────────────────────────

  Widget _buildAppBar(BuildContext context, _ResponsiveUi ui) {
    final (sevLabel, sevColor) = switch (child.severity) {
      'mild' => ('Mild', AppColors.mintGreen),
      'moderate' => ('Moderate', AppColors.warmYellow),
      'severe' => ('Severe', AppColors.softCoral),
      _ => ('—', Colors.white70),
    };

    return SliverAppBar(
      expandedHeight: ui.appBarExpandedHeight,
      pinned: true,
      backgroundColor: AppColors.therapistGradient.colors.last,
      leading: BackButton(
        color: Colors.white,
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(gradient: AppColors.therapistGradient),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                ui.pagePadding + 4,
                ui.pagePadding + 36,
                ui.pagePadding + 4,
                ui.pagePadding + 4,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: ui.avatarRadius,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: Text(
                      child.name[0].toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: ui.avatarText,
                      ),
                    ),
                  ),
                  SizedBox(width: ui.itemGap),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          toTitleCase(child.name),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: ui.heroTitle,
                          ),
                        ),
                        SizedBox(height: ui.tinyGap),
                        Text(
                          '${child.ageYears} years old',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: ui.bodySm,
                          ),
                        ),
                        SizedBox(height: ui.smallGap),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: ui.chipH,
                            vertical: ui.chipV,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Text(
                            sevLabel,
                            style: TextStyle(
                              fontSize: ui.caption,
                              fontWeight: FontWeight.w600,
                              color: sevColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Next Session ─────────────────────────────────────────────────────────

  Widget _buildNextSession(
    BuildContext context,
    AsyncValue<SessionModel?> next,
    _ResponsiveUi ui,
  ) {
    return next.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (session) {
        if (session == null) {
          return Container(
            padding: EdgeInsets.symmetric(
              horizontal: ui.cardPadding,
              vertical: ui.itemGap,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(ui.radiusMd),
              border: Border.all(color: AppColors.divider),
            ),
            child: Wrap(
              spacing: ui.smallGap,
              runSpacing: ui.smallGap,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Icon(
                  Icons.event_outlined,
                  size: ui.iconSm + 2,
                  color: AppColors.textSecondary,
                ),
                Text(
                  'No upcoming session scheduled',
                  style: TextStyle(
                    fontSize: ui.bodySm,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }
        return Container(
          padding: EdgeInsets.all(ui.cardPadding),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(ui.radiusMd),
            border: Border.all(
              color: AppColors.primaryBlue.withValues(alpha: 0.25),
            ),
          ),
          child: Wrap(
            spacing: ui.smallGap,
            runSpacing: ui.smallGap,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(Icons.event, size: ui.iconMd, color: AppColors.primaryBlue),
              SizedBox(
                width: ui.isMobile
                    ? MediaQuery.sizeOf(context).width * 0.68
                    : 520,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Next Session',
                      style: TextStyle(
                        fontSize: ui.caption,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    SizedBox(height: ui.tinyGap),
                    Text(
                      '${session.typeLabel}  •  '
                      '${AppDateUtils.formatDate(session.scheduledAt)}  '
                      '${AppDateUtils.formatTime(session.scheduledAt)}  '
                      '•  ${session.durationMin} min',
                      style: TextStyle(
                        fontSize: ui.bodySm,
                        fontWeight: FontWeight.w500,
                      ),
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

  // ── Diagnosis ────────────────────────────────────────────────────────────

  Widget _buildDiagnosis(BuildContext context, _ResponsiveUi ui) {
    return Wrap(
      spacing: ui.smallGap,
      runSpacing: ui.smallGap,
      children: child.diagnosis
          .map(
            (d) => Container(
              padding: EdgeInsets.symmetric(
                horizontal: ui.chipH,
                vertical: ui.chipV,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primaryBlue.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                toTitleCase(d),
                style: TextStyle(
                  fontSize: ui.bodyXs,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  // ── Quick Stats ──────────────────────────────────────────────────────────

  Widget _buildQuickStats(
    AsyncValue<List<SessionModel>> sessions,
    _ResponsiveUi ui,
  ) {
    final all = sessions.valueOrNull ?? [];
    final completed = all.where((s) => s.status == 'completed').length;
    final upcoming = all
        .where(
          (s) =>
              s.status == 'scheduled' && s.scheduledAt.isAfter(DateTime.now()),
        )
        .length;

    final stats = [
      _StatData(
        label: 'Total',
        value: '${all.length}',
        color: AppColors.primaryBlue,
        icon: Icons.event_note_outlined,
      ),
      _StatData(
        label: 'Completed',
        value: '$completed',
        color: AppColors.mintGreen,
        icon: Icons.check_circle_outline,
      ),
      _StatData(
        label: 'Upcoming',
        value: '$upcoming',
        color: AppColors.warmYellow,
        icon: Icons.upcoming_outlined,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stats.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        // Responsive stat cards: 1/2/3 by breakpoint.
        crossAxisCount: ui.statGridCount,
        mainAxisSpacing: ui.gridGap,
        crossAxisSpacing: ui.gridGap,
        childAspectRatio: ui.statAspect,
      ),
      itemBuilder: (_, i) => _StatChip(data: stats[i], ui: ui),
    );
  }

  // ── Add Session ──────────────────────────────────────────────────────────

  Widget _buildAddSessionButton(BuildContext context, _ResponsiveUi ui) {
    return SizedBox(
      width: double.infinity,
      height: ui.buttonHeight,
      child: ElevatedButton.icon(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CreateSessionScreen(preselectedChild: child),
          ),
        ),
        icon: Icon(Icons.add, size: ui.iconMd),
        label: Text(
          'Schedule New Session',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: ui.bodySm),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ui.radiusMd),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  // ── Assessment Section ───────────────────────────────────────────────────

  void _startAssessment(BuildContext context, String type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AssessmentWizardScreen(child: child, assessmentType: type),
      ),
    );
  }

  Widget _buildAssessmentSection(
    BuildContext context,
    AsyncValue<dynamic> assessments,
    _ResponsiveUi ui,
  ) {
    final list = (assessments.valueOrNull as List?) ?? [];

    return _SectionCard(
      title: 'Assessments',
      icon: Icons.assignment_outlined,
      ui: ui,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Start assessment buttons
          Wrap(
            spacing: ui.smallGap,
            runSpacing: ui.smallGap,
            children: [
              SizedBox(
                width: ui.actionButtonWidth,
                child: _AssessmentTypeButton(
                  label: list.isEmpty
                      ? 'Initial Assessment'
                      : 'Monthly Reassessment',
                  icon: list.isEmpty ? Icons.play_arrow : Icons.refresh,
                  color: AppColors.primaryBlue,
                  onTap: () => _startAssessment(
                    context,
                    list.isEmpty ? 'initial' : 'monthly',
                  ),
                  ui: ui,
                ),
              ),
              SizedBox(
                width: ui.actionButtonWidth,
                child: _AssessmentTypeButton(
                  label: 'Quarterly Review',
                  icon: Icons.bar_chart_outlined,
                  color: const Color(0xFF9B59B6),
                  onTap: () => _startAssessment(context, 'quarterly'),
                  ui: ui,
                ),
              ),
            ],
          ),
          if (list.isNotEmpty) ...[
            SizedBox(height: ui.itemGap),
            const Divider(height: 1),
            SizedBox(height: ui.smallGap),
            Text(
              'Assessment History',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.textSecondary,
                fontSize: ui.bodyXs,
              ),
            ),
            SizedBox(height: ui.smallGap),
            ...list
                .take(5)
                .map(
                  (a) => _AssessmentHistoryRow(
                    assessment: a,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AssessmentResultScreen(assessment: a, child: child),
                      ),
                    ),
                    ui: ui,
                  ),
                ),
          ],
        ],
      ),
    );
  }

  // ── Progress Charts ──────────────────────────────────────────────────────

  Widget _buildProgressCharts(
    BuildContext context,
    AsyncValue<List<SessionModel>> sessions,
    _ResponsiveUi ui,
  ) {
    final completed =
        (sessions.valueOrNull
                  ?.where((s) => s.status == 'completed' && s.notes != null)
                  .toList() ??
              [])
          ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

    if (completed.isEmpty) {
      return _SectionCard(
        title: 'Progress Charts',
        icon: Icons.show_chart,
        ui: ui,
        child: _emptyMsg('No completed sessions with notes yet', ui),
      );
    }

    final labels = completed
        .map((s) => AppDateUtils.formatShortDate(s.scheduledAt))
        .toList();

    return _SectionCard(
      title: 'Progress Trends',
      icon: Icons.show_chart,
      ui: ui,
      child: Column(
        children: [
          TrendChart(
            title: 'Attention',
            values: completed
                .map((s) => s.notes!.attentionScore.toDouble())
                .toList(),
            labels: labels,
            lineColor: AppColors.primaryBlue,
          ),
          SizedBox(height: ui.sectionGap),
          TrendChart(
            title: 'Communication',
            values: completed
                .map((s) => s.notes!.communicationScore.toDouble())
                .toList(),
            labels: labels,
            lineColor: AppColors.mintGreen,
          ),
          SizedBox(height: ui.sectionGap),
          TrendChart(
            title: 'Motor Skills',
            values: completed
                .map((s) => s.notes!.motorScore.toDouble())
                .toList(),
            labels: labels,
            lineColor: AppColors.warmYellow,
          ),
          SizedBox(height: ui.sectionGap),
          TrendChart(
            title: 'Behavior',
            values: completed
                .map((s) => s.notes!.behaviorScore.toDouble())
                .toList(),
            labels: labels,
            lineColor: AppColors.softCoral,
          ),
          SizedBox(height: ui.sectionGap),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WeeklyReportScreen(
                    childId: child.id,
                    childName: child.name,
                  ),
                ),
              ),
              icon: Icon(Icons.open_in_new, size: ui.iconSm),
              label: Text(
                'View Full Report',
                style: TextStyle(fontSize: ui.bodySm),
              ),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Active Plan ──────────────────────────────────────────────────────────

  Widget _buildActivePlan(
    BuildContext context,
    AsyncValue<HomePlanModel?> plan,
    _ResponsiveUi ui,
  ) {
    return _SectionCard(
      title: 'Home Plan',
      icon: Icons.assignment_outlined,
      ui: ui,
      child: plan.when(
        loading: () => SizedBox(
          height: ui.loaderHeight,
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primaryBlue,
            ),
          ),
        ),
        error: (_, _) => _emptyMsg('Could not load plan', ui),
        data: (p) {
          if (p == null) return _emptyMsg('No active home plan', ui);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: ui.smallGap,
                runSpacing: ui.smallGap,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Icon(
                    Icons.date_range_outlined,
                    size: ui.iconSm,
                    color: AppColors.textSecondary,
                  ),
                  Text(
                    '${AppDateUtils.formatDate(p.startDate)} → ${AppDateUtils.formatDate(p.endDate)}',
                    style: TextStyle(
                      fontSize: ui.bodyXs,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${p.tasks.length} tasks',
                    style: TextStyle(
                      fontSize: ui.bodyXs,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ],
              ),
              if (p.tasks.isNotEmpty) ...[
                SizedBox(height: ui.itemGap),
                ...p.tasks
                    .take(4)
                    .map(
                      (t) => Padding(
                        padding: EdgeInsets.only(bottom: ui.smallGap),
                        child: Row(
                          children: [
                            Text(t.icon, style: TextStyle(fontSize: ui.iconMd)),
                            SizedBox(width: ui.smallGap),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t.title,
                                    style: TextStyle(
                                      fontSize: ui.bodySm,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '${t.timeOfDay}  •  ${t.durationMin} min  •  ${t.frequency}',
                                    style: TextStyle(
                                      fontSize: ui.caption,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                if (p.tasks.length > 4)
                  Text(
                    '+ ${p.tasks.length - 4} more tasks',
                    style: TextStyle(
                      fontSize: ui.bodyXs,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }

  // ── Session History ──────────────────────────────────────────────────────

  Widget _buildSessionHistory(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<SessionModel>> sessions,
    _ResponsiveUi ui,
  ) {
    return _SectionCard(
      title: 'Session History',
      icon: Icons.history,
      ui: ui,
      child: sessions.when(
        loading: () => SizedBox(
          height: ui.loaderHeight,
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primaryBlue,
            ),
          ),
        ),
        error: (e, _) => _emptyMsg('Could not load sessions', ui),
        data: (list) {
          if (list.isEmpty) return _emptyMsg('No sessions yet', ui);
          final sorted = [...list]
            ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sorted.length,
            separatorBuilder: (_, _) => Divider(height: ui.dividerHeight),
            itemBuilder: (_, i) =>
                _SessionRow(session: sorted[i], child: child, ref: ref, ui: ui),
          );
        },
      ),
    );
  }

  // ── Diet Chart ───────────────────────────────────────────────────────────
  Widget _buildDietPlan(
    BuildContext context,
    AsyncValue<DietPlanModel?> plan,
    _ResponsiveUi ui,
  ) {
    return _SectionCard(
      title: 'Diet Chart',
      icon: Icons.restaurant_outlined,
      ui: ui,
      child: plan.when(
        loading: () => SizedBox(
          height: ui.loaderHeight,
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primaryBlue,
            ),
          ),
        ),
        error: (_, _) => _emptyMsg('Could not load diet plan', ui),
        data: (p) {
          if (p == null) return _emptyMsg('No active diet plan', ui);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: ui.smallGap,
                runSpacing: ui.smallGap,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Icon(
                    Icons.date_range_outlined,
                    size: ui.iconSm,
                    color: AppColors.textSecondary,
                  ),
                  Text(
                    '${AppDateUtils.formatDate(p.startDate)} → ${AppDateUtils.formatDate(p.endDate)}',
                    style: TextStyle(
                      fontSize: ui.bodyXs,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${p.meals.length} meals',
                    style: TextStyle(
                      fontSize: ui.bodyXs,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ],
              ),
              SizedBox(height: ui.itemGap),
              if (p.notes != null && p.notes!.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(bottom: ui.itemGap),
                  child: Text(
                    p.notes!,
                    style: TextStyle(
                      fontSize: ui.bodySm,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ...p.meals.map(
                (m) => Container(
                  margin: EdgeInsets.only(bottom: ui.smallGap),
                  padding: EdgeInsets.all(ui.itemGap),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(ui.radiusMd + 2),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: ui.smallGap,
                        runSpacing: ui.smallGap,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            m.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: ui.bodyMd,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: ui.chipH - 2,
                              vertical: ui.chipV - 1,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.mintGreen.withValues(
                                alpha: 0.15,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              m.mealTime,
                              style: TextStyle(
                                fontSize: ui.caption,
                                color: AppColors.mintGreen,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (m.description != null && m.description!.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: ui.tinyGap),
                          child: Text(
                            m.description!,
                            style: TextStyle(fontSize: ui.bodyXs),
                          ),
                        ),
                      if (m.ingredients.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: ui.smallGap),
                          child: Text(
                            'Ingredients: ${m.ingredients.join(", ")}',
                            style: TextStyle(
                              fontSize: ui.bodyXs,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      Text(
                        '${m.caloriesApprox} kcal • ${m.frequency}',
                        style: TextStyle(
                          fontSize: ui.caption,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Videos ────────────────────────────────────────────────────────────────

  Widget _buildVideos(
    BuildContext context,
    AsyncValue<List<VideoItemModel>> videos,
    _ResponsiveUi ui,
  ) {
    return _SectionCard(
      title: 'Videos',
      icon: Icons.videocam_outlined,
      ui: ui,
      child: videos.when(
        loading: () => SizedBox(
          height: ui.loaderHeight,
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primaryBlue,
            ),
          ),
        ),
        error: (_, _) => _emptyMsg('Could not load videos', ui),
        data: (list) {
          if (list.isEmpty) return _emptyMsg('No videos uploaded yet', ui);
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: list.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              // Multi-item section uses responsive grid columns by breakpoint.
              crossAxisCount: ui.videoGridCount,
              mainAxisSpacing: ui.gridGap,
              crossAxisSpacing: ui.gridGap,
              childAspectRatio: ui.videoAspect,
            ),
            itemBuilder: (_, i) => _VideoRow(video: list[i], ui: ui),
          );
        },
      ),
    );
  }

  // ── AI Drafts ─────────────────────────────────────────────────────────────

  Widget _buildAiDrafts(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<AiDraftModel>> aiDrafts,
    _ResponsiveUi ui,
  ) {
    return _SectionCard(
      title: 'AI Plans & Insights',
      icon: Icons.auto_awesome_outlined,
      ui: ui,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _AiButton(
                label: 'Therapy Plan',
                onTap: () => _generateAi(context, ref, 'therapy_plan'),
                ui: ui,
              ),
              _AiButton(
                label: 'Home Plan',
                onTap: () => _generateAi(context, ref, 'home_plan'),
                ui: ui,
              ),
              _AiButton(
                label: 'Activities',
                onTap: () =>
                    _generateAi(context, ref, 'reinforcement_activities'),
                ui: ui,
              ),
              _AiButton(
                label: 'Insights',
                onTap: () => _generateAi(context, ref, 'insights'),
                ui: ui,
              ),
            ],
          ),
          SizedBox(height: ui.itemGap),
          const Divider(height: 1),
          SizedBox(height: ui.smallGap),
          aiDrafts.when(
            loading: () => SizedBox(
              height: ui.loaderHeight,
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
            error: (_, _) => _emptyMsg('Could not load drafts', ui),
            data: (list) {
              if (list.isEmpty) {
                return _emptyMsg('No AI drafts yet — tap a button above', ui);
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: list.length > 5 ? 5 : list.length,
                separatorBuilder: (_, _) => Divider(height: ui.itemGap),
                itemBuilder: (_, i) => _AiDraftRow(
                  draft: list[i],
                  onApprove: () async {
                    await ref
                        .read(aiRepositoryProvider)
                        .approveDraft(list[i].id);
                    ref.invalidate(therapistAiDraftsProvider(child.id));
                  },
                  onView: () => _showDraftContent(context, list[i]),
                  ui: ui,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _generateAi(
    BuildContext context,
    WidgetRef ref,
    String type,
  ) async {
    final notifier = ref.read(aiGenerateProvider.notifier);
    await notifier.generate(child.id, type);
    final state = ref.read(aiGenerateProvider);
    if (state.error != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${state.error}'),
          backgroundColor: AppColors.softCoral,
        ),
      );
    } else if (state.draft != null && context.mounted) {
      ref.invalidate(therapistAiDraftsProvider(child.id));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AI draft generated successfully')),
      );
      _showDraftContent(context, state.draft!);
    }
  }

  void _showDraftContent(BuildContext context, AiDraftModel draft) {
    final media = MediaQuery.of(context);
    final ui = _ResponsiveUi.from(media.size.width, media);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (_, controller) => Center(
          // Responsive form-like content width for larger screens.
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: ui.maxFormWidth),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                ui.pagePadding,
                ui.itemGap,
                ui.pagePadding,
                ui.bottomGap,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  SizedBox(height: ui.itemGap),
                  Text(
                    draft.typeLabel,
                    style: TextStyle(
                      fontSize: ui.titleLg,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: ui.tinyGap),
                  Text(
                    '${draft.isApproved ? "Approved" : "Pending"} • ${draft.modelUsed}',
                    style: TextStyle(
                      fontSize: ui.bodyXs,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Divider(height: ui.sectionGap),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: controller,
                      child: Text(
                        draft.content,
                        style: TextStyle(fontSize: ui.bodySm, height: 1.6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyMsg(String msg, _ResponsiveUi ui) => Padding(
    padding: EdgeInsets.symmetric(vertical: ui.itemGap),
    child: Center(
      child: Text(
        msg,
        style: TextStyle(color: AppColors.textSecondary, fontSize: ui.bodySm),
      ),
    ),
  );

  // ── Goals ─────────────────────────────────────────────────────────────────

  Widget _buildGoals(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<GoalModel>> goals,
    _ResponsiveUi ui,
  ) {
    return _SectionCard(
      title: 'Therapy Goals',
      icon: Icons.flag_outlined,
      ui: ui,
      child: goals.when(
        loading: () => SizedBox(
          height: ui.loaderHeight,
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primaryBlue,
            ),
          ),
        ),
        error: (_, _) => _emptyMsg('Could not load goals', ui),
        data: (list) {
          final active = list.where((g) => g.status != 'completed').toList();
          if (list.isEmpty) return _emptyMsg('No goals set yet', ui);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...active.take(5).map((g) => _GoalRow(goal: g, ui: ui)),
              if (list.any((g) => g.isCompleted)) ...[
                SizedBox(height: ui.smallGap),
                Text(
                  '${list.where((g) => g.isCompleted).length} goal(s) completed',
                  style: TextStyle(
                    fontSize: ui.bodyXs,
                    color: AppColors.mintGreen,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  // ── Reviews ───────────────────────────────────────────────────────────────

  Widget _buildReviews(
    BuildContext context,
    AsyncValue<List<ReviewModel>> reviews,
    _ResponsiveUi ui,
  ) {
    return _SectionCard(
      title: 'Reviews',
      icon: Icons.summarize_outlined,
      ui: ui,
      child: reviews.when(
        loading: () => SizedBox(
          height: ui.loaderHeight,
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primaryBlue,
            ),
          ),
        ),
        error: (_, _) => _emptyMsg('Could not load reviews', ui),
        data: (list) {
          if (list.isEmpty) return _emptyMsg('No reviews yet', ui);
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: list.length,
            separatorBuilder: (_, _) => Divider(height: ui.dividerHeight),
            itemBuilder: (_, i) => _ReviewRow(review: list[i], ui: ui),
          );
        },
      ),
    );
  }
}

// ── Responsive UI config ──────────────────────────────────────────────────

class _ResponsiveUi {
  final double width;
  final bool isMobile;
  final bool isTablet;
  final bool isDesktop;

  const _ResponsiveUi._(
    this.width, {
    required this.isMobile,
    required this.isTablet,
    required this.isDesktop,
  });

  static _ResponsiveUi from(double maxWidth, MediaQueryData media) {
    final width = maxWidth.isFinite ? maxWidth : media.size.width;
    return _ResponsiveUi._(
      width,
      isMobile: width < 600,
      isTablet: width >= 600 && width < 1024,
      isDesktop: width >= 1024,
    );
  }

  double _scale(double value, {double min = 0.9, double max = 1.25}) {
    final t = ((width - 360) / (1280 - 360)).clamp(0.0, 1.0);
    return value * (min + (max - min) * t);
  }

  double get pagePadding => _scale(16, min: 0.9, max: 1.35);
  double get sectionGap => _scale(16, min: 0.95, max: 1.2);
  double get sectionGapLg => _scale(24, min: 0.95, max: 1.15);
  double get itemGap => _scale(12, min: 0.9, max: 1.2);
  double get smallGap => _scale(8, min: 0.9, max: 1.2);
  double get tinyGap => _scale(4, min: 0.9, max: 1.2);
  double get bottomGap => _scale(32, min: 0.95, max: 1.2);
  double get gridGap => _scale(10, min: 0.9, max: 1.2);
  double get dividerHeight => _scale(16, min: 0.9, max: 1.2);

  double get radiusMd => _scale(12, min: 0.92, max: 1.15);
  double get radiusLg => _scale(16, min: 0.92, max: 1.15);

  double get iconSm => _scale(14, min: 0.9, max: 1.2);
  double get iconMd => _scale(18, min: 0.9, max: 1.2);
  double get iconLg => _scale(22, min: 0.9, max: 1.2);

  double get bodyXs => _scale(11, min: 0.95, max: 1.2);
  double get bodySm => _scale(13, min: 0.95, max: 1.2);
  double get bodyMd => _scale(14, min: 0.95, max: 1.2);
  double get titleLg => _scale(18, min: 0.95, max: 1.2);
  double get caption => _scale(10, min: 0.95, max: 1.2);

  double get avatarRadius => _scale(34, min: 0.82, max: 1.2);
  double get avatarText => _scale(26, min: 0.82, max: 1.2);
  double get heroTitle => _scale(20, min: 0.86, max: 1.2);
  double get appBarExpandedHeight => _scale(190, min: 0.88, max: 1.2);

  double get cardPadding => _scale(14, min: 0.92, max: 1.2);
  double get chipH => _scale(10, min: 0.9, max: 1.2);
  double get chipV => _scale(4, min: 0.9, max: 1.2);
  double get buttonHeight => _scale(48, min: 0.95, max: 1.15);
  double get loaderHeight => _scale(40, min: 0.95, max: 1.1);
  double get maxFormWidth => isDesktop ? 560 : (isTablet ? 480 : 420);

  int get statGridCount => isDesktop ? 3 : (isTablet ? 2 : 1);
  double get statAspect => isDesktop ? 2.5 : (isTablet ? 2.2 : 3.0);
  int get videoGridCount => isDesktop ? 3 : (isTablet ? 2 : 1);
  double get videoAspect => isDesktop ? 2.2 : (isTablet ? 2.1 : 2.9);
  double get actionButtonWidth =>
      isMobile ? width - (pagePadding * 2) - 8 : 280;
}

class _StatData {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  const _StatData({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });
}

// ── Goal Row ──────────────────────────────────────────────────────────────

class _GoalRow extends StatelessWidget {
  final GoalModel goal;
  final _ResponsiveUi ui;
  const _GoalRow({required this.goal, required this.ui});

  @override
  Widget build(BuildContext context) {
    final (statusColor, icon) = switch (goal.status) {
      'completed' => (AppColors.mintGreen, Icons.check_circle_outline),
      'active' => (AppColors.primaryBlue, Icons.play_circle_outline),
      'accepted' => (AppColors.mintGreen, Icons.thumb_up_outlined),
      'paused' => (AppColors.warmYellow, Icons.pause_circle_outline),
      _ => (AppColors.textSecondary, Icons.radio_button_unchecked),
    };

    return Padding(
      padding: EdgeInsets.symmetric(vertical: ui.tinyGap + 2),
      child: Wrap(
        spacing: ui.smallGap,
        runSpacing: ui.smallGap,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Icon(icon, size: ui.iconSm + 2, color: statusColor),
          SizedBox(
            width: ui.isMobile ? MediaQuery.sizeOf(context).width * 0.48 : 420,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal.title,
                  style: TextStyle(
                    fontSize: ui.bodySm,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (goal.description != null && goal.description!.isNotEmpty)
                  Text(
                    goal.description!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: ui.caption,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ui.chipH - 2,
              vertical: ui.chipV - 1,
            ),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              goal.statusLabel,
              style: TextStyle(
                fontSize: ui.caption,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Review Row ────────────────────────────────────────────────────────────

class _ReviewRow extends StatelessWidget {
  final ReviewModel review;
  final _ResponsiveUi ui;
  const _ReviewRow({required this.review, required this.ui});

  @override
  Widget build(BuildContext context) {
    final isPublished = review.isPublished;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: ui.tinyGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                review.reviewType == 'quarterly'
                    ? Icons.calendar_today
                    : Icons.calendar_view_month,
                size: ui.iconSm,
                color: AppColors.primaryBlue,
              ),
              SizedBox(width: ui.tinyGap + 2),
              Expanded(
                child: Text(
                  review.typeLabel,
                  style: TextStyle(
                    fontSize: ui.bodySm,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ui.chipH - 2,
                  vertical: ui.chipV - 1,
                ),
                decoration: BoxDecoration(
                  color:
                      (isPublished ? AppColors.mintGreen : AppColors.warmYellow)
                          .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isPublished ? 'Published' : 'Draft',
                  style: TextStyle(
                    fontSize: ui.caption,
                    fontWeight: FontWeight.w600,
                    color: isPublished
                        ? AppColors.mintGreen
                        : AppColors.warmYellow,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ui.tinyGap),
          Text(
            '${review.periodStart.day}/${review.periodStart.month}/${review.periodStart.year}'
            ' → '
            '${review.periodEnd.day}/${review.periodEnd.month}/${review.periodEnd.year}',
            style: TextStyle(
              fontSize: ui.caption,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: ui.tinyGap),
          Text(
            review.textObservations,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: ui.bodyXs,
              color: AppColors.textSecondary,
            ),
          ),
          if (review.adminNotes != null && review.adminNotes!.isNotEmpty) ...[
            SizedBox(height: ui.tinyGap),
            Text(
              'Admin: ${review.adminNotes}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: ui.caption,
                color: AppColors.primaryBlue,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Video Row ─────────────────────────────────────────────────────────────

class _VideoRow extends StatelessWidget {
  final VideoItemModel video;
  final _ResponsiveUi ui;
  const _VideoRow({required this.video, required this.ui});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ui.itemGap),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(ui.radiusMd + 2),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: ui.iconLg + 18,
            height: ui.iconLg + 18,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.play_circle_outline,
              color: AppColors.primaryBlue,
              size: ui.iconLg,
            ),
          ),
          SizedBox(width: ui.smallGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: ui.bodySm,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: ui.tinyGap),
                Text(
                  video.categoryLabel,
                  style: TextStyle(
                    fontSize: ui.caption,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (video.description != null &&
                    video.description!.isNotEmpty) ...[
                  SizedBox(height: ui.tinyGap),
                  Text(
                    video.description!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: ui.caption,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (!video.isParentVisible)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: ui.chipH - 4,
                vertical: ui.chipV - 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.warmYellow.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Internal',
                style: TextStyle(
                  fontSize: ui.caption - 1,
                  fontWeight: FontWeight.w600,
                  color: AppColors.warmYellow,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Stat Chip ─────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final _StatData data;
  final _ResponsiveUi ui;
  const _StatChip({required this.data, required this.ui});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: ui.itemGap,
        horizontal: ui.smallGap,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(ui.radiusLg - 2),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(data.icon, color: data.color, size: ui.iconMd),
          SizedBox(height: ui.tinyGap + 1),
          Text(
            data.value,
            style: TextStyle(
              fontSize: ui.titleLg,
              fontWeight: FontWeight.w800,
              color: data.color,
            ),
          ),
          Text(
            data.label,
            style: TextStyle(
              fontSize: ui.caption,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section Card ──────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final _ResponsiveUi ui;
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    required this.ui,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ui.pagePadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(ui.radiusLg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(ui.smallGap - 1),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(ui.radiusMd + 1),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primaryBlue,
                  size: ui.iconSm + 2,
                ),
              ),
              SizedBox(width: ui.smallGap),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: ui.bodyMd,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ui.itemGap),
          child,
        ],
      ),
    );
  }
}

// ── Session Row ───────────────────────────────────────────────────────────

class _SessionRow extends StatelessWidget {
  final SessionModel session;
  final ChildModel child;
  final WidgetRef ref;
  final _ResponsiveUi ui;
  const _SessionRow({
    required this.session,
    required this.child,
    required this.ref,
    required this.ui,
  });

  @override
  Widget build(BuildContext context) {
    final (statusColor, statusLabel) = switch (session.status) {
      'completed' => (AppColors.mintGreen, 'Completed'),
      'cancelled' => (AppColors.softCoral, 'Cancelled'),
      _ => (AppColors.warmYellow, 'Scheduled'),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: ui.smallGap,
          runSpacing: ui.smallGap,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: ui.isMobile
                  ? MediaQuery.sizeOf(context).width * 0.55
                  : 500,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.typeLabel,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: ui.bodyMd,
                    ),
                  ),
                  SizedBox(height: ui.tinyGap),
                  Text(
                    '${AppDateUtils.formatDate(session.scheduledAt)}  •  ${AppDateUtils.formatTime(session.scheduledAt)}  •  ${session.durationMin} min',
                    style: TextStyle(
                      fontSize: ui.bodyXs,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: ui.chipH,
                vertical: ui.chipV,
              ),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                statusLabel,
                style: TextStyle(
                  fontSize: ui.caption,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
        if (session.status == 'completed' && session.notes != null) ...[
          SizedBox(height: ui.smallGap),
          _NotesPreview(notes: session.notes!, ui: ui),
        ] else if (session.status == 'scheduled') ...[
          SizedBox(height: ui.smallGap),
          TextButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    SessionNotesScreen(session: session, childName: child.name),
              ),
            ),
            icon: Icon(Icons.edit_outlined, size: ui.iconSm),
            label: Text('Add Notes', style: TextStyle(fontSize: ui.bodyXs)),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryBlue,
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ],
    );
  }
}

class _NotesPreview extends StatelessWidget {
  final SessionNotes notes;
  final _ResponsiveUi ui;
  const _NotesPreview({required this.notes, required this.ui});

  @override
  Widget build(BuildContext context) {
    final moodEmoji = switch (notes.mood) {
      'happy' => '😊',
      'calm' => '😌',
      'anxious' => '😰',
      'sad' => '😢',
      'angry' => '😠',
      _ => '😐',
    };

    return Container(
      padding: EdgeInsets.all(ui.smallGap + 2),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(ui.radiusMd + 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: ui.smallGap,
            runSpacing: ui.smallGap,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                '$moodEmoji ${notes.mood}',
                style: TextStyle(fontSize: ui.bodyXs),
              ),
              _Score('Att', notes.attentionScore, AppColors.primaryBlue, ui),
              _Score('Com', notes.communicationScore, AppColors.mintGreen, ui),
              _Score('Mot', notes.motorScore, AppColors.warmYellow, ui),
              _Score('Beh', notes.behaviorScore, AppColors.softCoral, ui),
            ],
          ),
          if (notes.whatWorked != null && notes.whatWorked!.isNotEmpty) ...[
            SizedBox(height: ui.smallGap),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.thumb_up_outlined,
                  size: ui.iconSm - 1,
                  color: AppColors.mintGreen,
                ),
                SizedBox(width: ui.tinyGap + 1),
                Expanded(
                  child: Text(
                    notes.whatWorked!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: ui.caption,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Score extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final _ResponsiveUi ui;
  const _Score(this.label, this.value, this.color, this.ui);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value',
          style: TextStyle(
            fontSize: ui.bodyXs,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: ui.caption - 1,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ── Assessment helpers ────────────────────────────────────────────────────

class _AssessmentTypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final _ResponsiveUi ui;
  const _AssessmentTypeButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.ui,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: ui.itemGap,
          horizontal: ui.itemGap,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(ui.radiusMd),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: ui.iconSm + 2, color: color),
            SizedBox(width: ui.tinyGap + 2),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: ui.bodyXs,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── AI Button ─────────────────────────────────────────────────────────────

class _AiButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final _ResponsiveUi ui;
  const _AiButton({required this.label, required this.onTap, required this.ui});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ui.chipH + 2,
          vertical: ui.chipV + 2,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF6C63FF).withValues(alpha: 0.35),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome,
              size: ui.iconSm - 1,
              color: const Color(0xFF6C63FF),
            ),
            SizedBox(width: ui.tinyGap + 1),
            Text(
              label,
              style: TextStyle(
                fontSize: ui.bodyXs,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6C63FF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── AI Draft Row ──────────────────────────────────────────────────────────

class _AiDraftRow extends StatelessWidget {
  final AiDraftModel draft;
  final VoidCallback onApprove;
  final VoidCallback onView;
  final _ResponsiveUi ui;
  const _AiDraftRow({
    required this.draft,
    required this.onApprove,
    required this.onView,
    required this.ui,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = draft.isApproved
        ? AppColors.mintGreen
        : AppColors.warmYellow;
    return Wrap(
      spacing: ui.smallGap,
      runSpacing: ui.smallGap,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Icon(
          Icons.description_outlined,
          size: ui.iconSm + 2,
          color: AppColors.primaryBlue,
        ),
        SizedBox(
          width: ui.isMobile ? MediaQuery.sizeOf(context).width * 0.45 : 280,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                draft.typeLabel,
                style: TextStyle(
                  fontSize: ui.bodySm,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                draft.isApproved ? 'Approved' : 'Pending review',
                style: TextStyle(fontSize: ui.caption, color: statusColor),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: onView,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primaryBlue,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text('View', style: TextStyle(fontSize: ui.bodyXs)),
        ),
        if (draft.isPending)
          TextButton(
            onPressed: onApprove,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.mintGreen,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text('Approve', style: TextStyle(fontSize: ui.bodyXs)),
          ),
      ],
    );
  }
}

// ── Assessment History Row ────────────────────────────────────────────────

class _AssessmentHistoryRow extends StatelessWidget {
  final dynamic assessment;
  final VoidCallback onTap;
  final _ResponsiveUi ui;
  const _AssessmentHistoryRow({
    required this.assessment,
    required this.onTap,
    required this.ui,
  });

  @override
  Widget build(BuildContext context) {
    final score = (assessment.overallScorePct as double?) ?? 0.0;
    final risk = assessment.riskLevel as String? ?? 'amber';
    final type = assessment.type as String? ?? '';
    final date = assessment.date as DateTime? ?? DateTime.now();

    final riskColor = switch (risk) {
      'green' => AppColors.mintGreen,
      'red' => AppColors.softCoral,
      _ => AppColors.warmYellow,
    };

    final typeLabel = switch (type) {
      'initial' => 'Initial',
      'monthly' => 'Monthly',
      'quarterly' => 'Quarterly',
      _ => type,
    };

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: ui.tinyGap + 2),
        child: Wrap(
          spacing: ui.smallGap,
          runSpacing: ui.smallGap,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Container(
              width: ui.tinyGap + 4,
              height: ui.tinyGap + 4,
              decoration: BoxDecoration(
                color: riskColor,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(
              width: ui.isMobile
                  ? MediaQuery.sizeOf(context).width * 0.24
                  : 160,
              child: Text(
                typeLabel,
                style: TextStyle(
                  fontSize: ui.bodySm,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              '${score.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: ui.bodySm,
                fontWeight: FontWeight.w700,
                color: riskColor,
              ),
            ),
            Text(
              '${date.day}/${date.month}/${date.year}',
              style: TextStyle(
                fontSize: ui.caption,
                color: AppColors.textSecondary,
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: ui.iconSm + 2,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
