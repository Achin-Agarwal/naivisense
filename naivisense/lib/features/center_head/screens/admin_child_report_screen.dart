import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/models/alert.dart';
import '../../../data/models/child.dart';
import '../../../data/models/diet_plan.dart';
import '../../../data/models/home_plan.dart';
import '../../../data/models/session.dart';
import '../../../shared/widgets/trend_chart.dart';
import '../../../features/assessments/providers/assessment_provider.dart';
import '../../../features/assessments/screens/assessment_result_screen.dart';
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
                  _buildHeroAppBar(context),

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
                              _buildDiagnosisRow(context),

                              SizedBox(height: r.h(22)),

                              _buildAssessmentSection(context, assessments),

                              SizedBox(height: r.h(26)),

                              _buildQuickStats(context, sessions, alerts),

                              SizedBox(height: r.h(26)),

                              _buildStaffSection(context, sessions),

                              SizedBox(height: r.h(26)),

                              _buildProgressCharts(context, sessions),

                              SizedBox(height: r.h(26)),

                              _buildActivePlan(context, plan),

                              SizedBox(height: r.h(26)),

                              _buildDietPlan(context, dietPlan),

                              SizedBox(height: r.h(26)),

                              _buildSessionHistory(context, sessions),

                              SizedBox(height: r.h(26)),

                              _buildAlertsSection(context, alerts),
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
  // ── Hero App Bar ───────────────────────────────────────────────────────────

  Widget _buildHeroAppBar(BuildContext context) {
    final r = Responsive(context);

    return SliverAppBar(
      expandedHeight: r.h(200),
      pinned: true,
      backgroundColor: AppColors.centerHeadGradient.colors.last,
      leading: const BackButton(color: Colors.white),
      actions: [
        Container(
          margin: EdgeInsets.only(
            right: r.w(16),
            top: r.h(10),
            bottom: r.h(10),
          ),
          padding: EdgeInsets.symmetric(horizontal: r.w(12), vertical: r.h(6)),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(r.radius(20)),
          ),
          child: Text(
            'Admin View',
            style: TextStyle(
              color: Colors.white,
              fontSize: r.sp(12),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(gradient: AppColors.centerHeadGradient),
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: r.isDesktop ? 900 : double.infinity,
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    r.horizontalPadding,
                    r.h(56),
                    r.horizontalPadding,
                    r.h(20),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: r.avatar(32),
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        child: Text(
                          child.name.isNotEmpty
                              ? child.name[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: r.sp(26),
                          ),
                        ),
                      ),

                      SizedBox(width: r.w(16)),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              child.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: r.sp(22),
                              ),
                            ),

                            SizedBox(height: r.h(4)),

                            Text(
                              '${child.ageYears} years old',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: r.sp(14),
                              ),
                            ),

                            SizedBox(height: r.h(8)),

                            _SeverityBadge(severity: child.severity),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  } // ── Assessment Section ─────────────────────────────────────────────────────

  void _openWizard(BuildContext context, String type) {
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
  ) {
    final r = Responsive(context);

    final list = (assessments.valueOrNull as List?) ?? [];
    final isLoading = assessments.isLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(context, 'Assessments', Icons.assignment_outlined),

        SizedBox(height: r.h(12)),

        LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            final spacing = r.w(12);

            final itemWidth = isMobile
                ? constraints.maxWidth
                : (constraints.maxWidth - spacing) / 2;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                SizedBox(
                  width: itemWidth,
                  child: _AdminAssessmentButton(
                    label: list.isEmpty
                        ? 'Start Initial Assessment'
                        : 'New Monthly Assessment',
                    icon: list.isEmpty
                        ? Icons.play_arrow_rounded
                        : Icons.refresh_rounded,
                    color: AppColors.primaryBlue,
                    onTap: () => _openWizard(
                      context,
                      list.isEmpty ? 'initial' : 'monthly',
                    ),
                  ),
                ),

                SizedBox(
                  width: itemWidth,
                  child: _AdminAssessmentButton(
                    label: 'Quarterly Review',
                    icon: Icons.bar_chart_rounded,
                    color: const Color(0xFF9B59B6),
                    onTap: () => _openWizard(context, 'quarterly'),
                  ),
                ),
              ],
            );
          },
        ),

        if (isLoading) ...[
          SizedBox(height: r.h(12)),
          const _LoadingCard(),
        ] else if (list.isEmpty) ...[
          SizedBox(height: r.h(12)),
          _emptyCard(
            'No assessments done yet. Start the initial assessment above.',
          ),
        ] else ...[
          SizedBox(height: r.h(14)),

          ...list
              .take(6)
              .map(
                (a) => _AdminAssessmentRow(
                  assessment: a,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AssessmentResultScreen(assessment: a, child: child),
                    ),
                  ),
                ),
              ),
        ],
      ],
    );
  }
  // ── Diagnosis Row ──────────────────────────────────────────────────────────

  Widget _buildDiagnosisRow(BuildContext context) {
    final r = Responsive(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Diagnosis',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppColors.textSecondary,
            fontSize: r.sp(14),
          ),
        ),

        SizedBox(height: r.h(8)),

        Wrap(
          spacing: r.w(8),
          runSpacing: r.h(6),
          children: child.diagnosis
              .map(
                (d) => Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: r.w(12),
                    vertical: r.h(6),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.centerHeadGradient.colors.first.withValues(
                      alpha: 0.1,
                    ),
                    borderRadius: BorderRadius.circular(r.radius(20)),
                    border: Border.all(
                      color: AppColors.centerHeadGradient.colors.first
                          .withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    d,
                    style: TextStyle(
                      fontSize: r.sp(12),
                      fontWeight: FontWeight.w500,
                      color: AppColors.centerHeadGradient.colors.first,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  // ── Quick Stats ────────────────────────────────────────────────────────────

  Widget _buildQuickStats(
    BuildContext context,
    AsyncValue<List<SessionModel>> sessions,
    AsyncValue<List<AlertModel>> alerts,
  ) {
    final r = Responsive(context);

    final total = sessions.valueOrNull?.length ?? 0;
    final completed =
        sessions.valueOrNull?.where((s) => s.status == 'completed').length ?? 0;

    final openAlerts =
        alerts.valueOrNull?.where((a) => a.status == 'open').length ?? 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return Column(
            children: [
              _QuickStat(
                label: 'Total\nSessions',
                value: '$total',
                color: AppColors.primaryBlue,
                icon: Icons.event_note_outlined,
              ),

              SizedBox(height: r.h(12)),

              _QuickStat(
                label: 'Completed',
                value: '$completed',
                color: AppColors.mintGreen,
                icon: Icons.check_circle_outline,
              ),

              SizedBox(height: r.h(12)),

              _QuickStat(
                label: 'Open\nAlerts',
                value: '$openAlerts',
                color: openAlerts > 0
                    ? AppColors.softCoral
                    : AppColors.textSecondary,
                icon: Icons.notifications_active_outlined,
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: _QuickStat(
                label: 'Total\nSessions',
                value: '$total',
                color: AppColors.primaryBlue,
                icon: Icons.event_note_outlined,
              ),
            ),

            SizedBox(width: r.w(12)),

            Expanded(
              child: _QuickStat(
                label: 'Completed',
                value: '$completed',
                color: AppColors.mintGreen,
                icon: Icons.check_circle_outline,
              ),
            ),

            SizedBox(width: r.w(12)),

            Expanded(
              child: _QuickStat(
                label: 'Open\nAlerts',
                value: '$openAlerts',
                color: openAlerts > 0
                    ? AppColors.softCoral
                    : AppColors.textSecondary,
                icon: Icons.notifications_active_outlined,
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Staff Section ──────────────────────────────────────────────────────────

  Widget _buildStaffSection(
    BuildContext context,
    AsyncValue<List<SessionModel>> sessions,
  ) {
    final r = Responsive(context);

    final completedCount =
        sessions.valueOrNull?.where((s) => s.status == 'completed').length ?? 0;

    final therapistName =
        child.therapistName ??
        _shortIdOrFallback(child.therapistId, 'Not assigned');

    final therapistPhone = child.therapistPhone ?? '—';

    final parentName =
        child.parentName ?? _shortIdOrFallback(child.parentId, 'Not assigned');

    final parentPhone = child.parentPhone ?? '—';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(context, 'Assigned Team', Icons.people_outline),

        SizedBox(height: r.h(12)),

        _InlineStaffCard(
          name: therapistName,
          phone: therapistPhone,
          role: 'Therapist',
          roleColor: AppColors.primaryBlue,
          roleIcon: Icons.medical_services_outlined,
          subtitle: '$completedCount sessions completed',
        ),

        SizedBox(height: r.h(12)),

        _InlineStaffCard(
          name: parentName,
          phone: parentPhone,
          role: 'Parent',
          roleColor: AppColors.mintGreen,
          roleIcon: Icons.family_restroom_outlined,
          subtitle: parentPhone,
        ),
      ],
    );
  }

  // ── Progress Charts ────────────────────────────────────────────────────────

  Widget _buildProgressCharts(
    BuildContext context,
    AsyncValue<List<SessionModel>> sessions,
  ) {
    final r = Responsive(context);

    final completed =
        (sessions.valueOrNull
                  ?.where((s) => s.status == 'completed' && s.notes != null)
                  .toList() ??
              [])
          ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

    if (completed.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(context, 'Progress Charts', Icons.show_chart),

          SizedBox(height: r.h(12)),

          _emptyCard('No completed sessions with notes yet'),
        ],
      );
    }

    final labels = completed
        .map((s) => AppDateUtils.formatShortDate(s.scheduledAt))
        .toList();

    final attention = completed
        .map((s) => s.notes!.attentionScore.toDouble())
        .toList();

    final communication = completed
        .map((s) => s.notes!.communicationScore.toDouble())
        .toList();

    final motor = completed.map((s) => s.notes!.motorScore.toDouble()).toList();

    final behavior = completed
        .map((s) => s.notes!.behaviorScore.toDouble())
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(context, 'Progress Charts', Icons.show_chart),

        SizedBox(height: r.h(16)),

        _ChartCard(
          child: TrendChart(
            title: 'Attention',
            values: attention,
            labels: labels,
            lineColor: AppColors.primaryBlue,
          ),
        ),

        SizedBox(height: r.h(12)),

        _ChartCard(
          child: TrendChart(
            title: 'Communication',
            values: communication,
            labels: labels,
            lineColor: AppColors.mintGreen,
          ),
        ),

        SizedBox(height: r.h(12)),

        _ChartCard(
          child: TrendChart(
            title: 'Motor Skills',
            values: motor,
            labels: labels,
            lineColor: AppColors.warmYellow,
          ),
        ),

        SizedBox(height: r.h(12)),

        _ChartCard(
          child: TrendChart(
            title: 'Behavior',
            values: behavior,
            labels: labels,
            lineColor: AppColors.softCoral,
          ),
        ),

        SizedBox(height: r.h(12)),

        _buildScoreAverages(context, attention, communication, motor, behavior),
      ],
    );
  }

  Widget _buildScoreAverages(
    BuildContext context,
    List<double> attention,
    List<double> communication,
    List<double> motor,
    List<double> behavior,
  ) {
    final r = Responsive(context);

    double avg(List<double> v) =>
        v.isEmpty ? 0 : v.reduce((a, b) => a + b) / v.length;

    return Container(
      padding: EdgeInsets.all(r.w(16)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(r.radius(16)),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Average Scores',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: r.sp(18),
            ),
          ),
          SizedBox(height: r.h(14)),

          _ScoreBar(
            label: 'Attention',
            value: avg(attention),
            color: AppColors.primaryBlue,
          ),

          SizedBox(height: r.h(8)),

          _ScoreBar(
            label: 'Communication',
            value: avg(communication),
            color: AppColors.mintGreen,
          ),

          SizedBox(height: r.h(8)),

          _ScoreBar(
            label: 'Motor Skills',
            value: avg(motor),
            color: AppColors.warmYellow,
          ),

          SizedBox(height: r.h(8)),

          _ScoreBar(
            label: 'Behavior',
            value: avg(behavior),
            color: AppColors.softCoral,
          ),
        ],
      ),
    );
  }
  // ── Active Plan ────────────────────────────────────────────────────────────

  Widget _buildActivePlan(
    BuildContext context,
    AsyncValue<HomePlanModel?> plan,
  ) {
    final r = Responsive(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(context, 'Home Plan', Icons.assignment_outlined),
        SizedBox(height: r.h(12)),
        plan.when(
          loading: () => const _LoadingCard(),
          error: (e, _) => _emptyCard('Could not load plan'),
          data: (p) {
            if (p == null) return _emptyCard('No active home plan');

            return Column(
              children: [
                Container(
                  padding: EdgeInsets.all(r.w(14)),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(r.radius(12)),
                    border: Border.all(
                      color: AppColors.primaryBlue.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.date_range_outlined,
                        color: AppColors.primaryBlue,
                        size: r.icon(18),
                      ),
                      SizedBox(width: r.w(8)),
                      Expanded(
                        child: Text(
                          '${AppDateUtils.formatDate(p.startDate)} → ${AppDateUtils.formatDate(p.endDate)}',
                          style: TextStyle(
                            fontSize: r.sp(13),
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ),
                      SizedBox(width: r.w(8)),
                      Text(
                        '${p.tasks.length} tasks',
                        style: TextStyle(
                          fontSize: r.sp(12),
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                if (p.morningTasks.isNotEmpty) ...[
                  SizedBox(height: r.h(10)),
                  _TaskGroup(title: 'Morning', tasks: p.morningTasks),
                ],

                if (p.afternoonTasks.isNotEmpty) ...[
                  SizedBox(height: r.h(10)),
                  _TaskGroup(title: 'Afternoon', tasks: p.afternoonTasks),
                ],

                if (p.eveningTasks.isNotEmpty) ...[
                  SizedBox(height: r.h(10)),
                  _TaskGroup(title: 'Evening', tasks: p.eveningTasks),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildDietPlan(BuildContext context, AsyncValue<DietPlanModel?> plan) {
    final r = Responsive(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(context, 'Diet Chart', Icons.restaurant_outlined),
        SizedBox(height: r.h(12)),
        plan.when(
          loading: () => const _LoadingCard(),
          error: (e, _) => _emptyCard('Could not load diet plan'),
          data: (p) {
            if (p == null) {
              return _emptyCard('No active diet plan');
            }

            return Container(
              padding: EdgeInsets.all(r.w(14)),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(r.radius(12)),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${AppDateUtils.formatDate(p.startDate)} → ${AppDateUtils.formatDate(p.endDate)}',
                          style: TextStyle(
                            fontSize: r.sp(12),
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      SizedBox(width: r.w(8)),
                      Text(
                        '${p.meals.length} meals',
                        style: TextStyle(
                          fontSize: r.sp(12),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: r.h(10)),

                  ...p.meals
                      .take(6)
                      .map(
                        (m) => Padding(
                          padding: EdgeInsets.only(bottom: r.h(6)),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${m.mealTime.toUpperCase()}: ${m.name}',
                                  style: TextStyle(fontSize: r.sp(13)),
                                ),
                              ),
                              SizedBox(width: r.w(8)),
                              Text(
                                '${m.caloriesApprox} kcal',
                                style: TextStyle(
                                  fontSize: r.sp(12),
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                  if (p.meals.length > 6)
                    Text(
                      '+ ${p.meals.length - 6} more',
                      style: TextStyle(
                        fontSize: r.sp(11),
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
  // ── Session History ────────────────────────────────────────────────────────

  Widget _buildSessionHistory(
    BuildContext context,
    AsyncValue<List<SessionModel>> sessions,
  ) {
    final r = Responsive(context);

    final list = (sessions.valueOrNull ?? [])
      ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          context,
          'Session History (${list.length})',
          Icons.history,
        ),
        SizedBox(height: r.h(12)),
        sessions.when(
          loading: () => const _LoadingCard(),
          error: (e, _) => _emptyCard('Could not load sessions'),
          data: (sessions) {
            if (sessions.isEmpty) {
              return _emptyCard('No sessions yet');
            }

            final sorted = [...sessions]
              ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sorted.length,
              separatorBuilder: (_, _) => SizedBox(height: r.h(8)),
              itemBuilder: (_, i) => _SessionHistoryCard(session: sorted[i]),
            );
          },
        ),
      ],
    );
  }

  // ── Alerts ─────────────────────────────────────────────────────────────────

  Widget _buildAlertsSection(
    BuildContext context,
    AsyncValue<List<AlertModel>> alerts,
  ) {
    final r = Responsive(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(context, 'Alert History', Icons.notifications_outlined),
        SizedBox(height: r.h(12)),
        alerts.when(
          loading: () => const _LoadingCard(),
          error: (e, _) => _emptyCard('Could not load alerts'),
          data: (list) {
            if (list.isEmpty) {
              return _emptyCard('No alerts raised');
            }

            final sorted = [...list]
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sorted.length,
              separatorBuilder: (_, _) => SizedBox(height: r.h(8)),
              itemBuilder: (_, i) => _AlertHistoryCard(alert: sorted[i]),
            );
          },
        ),
      ],
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _sectionHeader(BuildContext context, String title, IconData icon) {
    final r = Responsive(context);

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(r.w(8)),
          decoration: BoxDecoration(
            color: AppColors.centerHeadGradient.colors.first.withValues(
              alpha: 0.1,
            ),
            borderRadius: BorderRadius.circular(r.radius(10)),
          ),
          child: Icon(
            icon,
            color: AppColors.centerHeadGradient.colors.first,
            size: r.icon(18),
          ),
        ),

        SizedBox(width: r.w(10)),

        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: r.sp(20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _emptyCard(String msg) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final r = Responsive(context);

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(r.value(mobile: 20, tablet: 22, desktop: 24)),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(
              r.value(mobile: 14, tablet: 16, desktop: 18),
            ),
            border: Border.all(color: AppColors.divider),
          ),
          child: Center(
            child: Text(
              msg,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: r.font(13, tablet: 14, desktop: 15),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _QuickStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _QuickStat({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final isTablet = width >= 600 && width < 1024;
    final isDesktop = width >= 1024;

    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: isDesktop
              ? 18
              : isTablet
              ? 16
              : 14,
          horizontal: isDesktop ? 16 : 12,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: isDesktop
                  ? 26
                  : isTablet
                  ? 24
                  : 22,
            ),

            const SizedBox(height: 6),

            Text(
              value,
              style: TextStyle(
                fontSize: isDesktop
                    ? 24
                    : isTablet
                    ? 22
                    : 20,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),

            const SizedBox(height: 2),

            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isDesktop ? 12 : 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineStaffCard extends StatelessWidget {
  final String name;
  final String phone;
  final String role;
  final Color roleColor;
  final IconData roleIcon;
  final String subtitle;

  const _InlineStaffCard({
    required this.name,
    required this.phone,
    required this.role,
    required this.roleColor,
    required this.roleIcon,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    final width = MediaQuery.of(context).size.width;

    final isTablet = width >= 600 && width < 1024;
    final isDesktop = width >= 1024;

    return Container(
      padding: EdgeInsets.all(
        isDesktop
            ? 20
            : isTablet
            ? 18
            : 16,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: isDesktop
                ? 28
                : isTablet
                ? 26
                : 24,
            backgroundColor: roleColor.withValues(alpha: 0.12),
            child: Text(
              initial,
              style: TextStyle(
                color: roleColor,
                fontWeight: FontWeight.w700,
                fontSize: isDesktop ? 20 : 18,
              ),
            ),
          ),

          SizedBox(width: isDesktop ? 18 : 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: isDesktop ? 17 : 15,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: isDesktop ? 13 : 12,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 12 : 10,
              vertical: isDesktop ? 6 : 5,
            ),
            decoration: BoxDecoration(
              color: roleColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: roleColor.withValues(alpha: 0.25)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(roleIcon, color: roleColor, size: isDesktop ? 15 : 13),

                const SizedBox(width: 4),

                Text(
                  role,
                  style: TextStyle(
                    fontSize: isDesktop ? 12 : 11,
                    fontWeight: FontWeight.w600,
                    color: roleColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final Widget child;

  const _ChartCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final isTablet = width >= 600 && width < 1024;
    final isDesktop = width >= 1024;

    return Container(
      padding: EdgeInsets.all(
        isDesktop
            ? 20
            : isTablet
            ? 18
            : 16,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: child,
    );
  }
}

class _ScoreBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _ScoreBar({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (value / 10).clamp(0.0, 1.0);

    final width = MediaQuery.of(context).size.width;

    final isTablet = width >= 600 && width < 1024;
    final isDesktop = width >= 1024;

    return Row(
      children: [
        SizedBox(
          width: isDesktop
              ? 140
              : isTablet
              ? 125
              : 100,
          child: Text(
            label,
            style: TextStyle(
              fontSize: isDesktop ? 13 : 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),

        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: color.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: isDesktop ? 10 : 8,
            ),
          ),
        ),

        const SizedBox(width: 8),

        SizedBox(
          width: isDesktop ? 42 : 36,
          child: Text(
            value.toStringAsFixed(1),
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: isDesktop ? 13 : 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

class _TaskGroup extends StatelessWidget {
  final String title;
  final List<HomePlanTask> tasks;

  const _TaskGroup({required this.title, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final isTablet = width >= 600 && width < 1024;
    final isDesktop = width >= 1024;

    return Container(
      padding: EdgeInsets.all(
        isDesktop
            ? 18
            : isTablet
            ? 16
            : 14,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: isDesktop ? 14 : 13,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 8),

          ...tasks.map(
            (t) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text(t.icon, style: TextStyle(fontSize: isDesktop ? 20 : 18)),

                  SizedBox(width: isDesktop ? 12 : 10),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: isDesktop ? 14 : 13,
                          ),
                        ),

                        Text(
                          '${t.durationMin} min  •  ${t.frequency}  •  ×${t.targetCount}',
                          style: TextStyle(
                            fontSize: isDesktop ? 12 : 11,
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
        ],
      ),
    );
  }
}

class _SessionHistoryCard extends StatelessWidget {
  final SessionModel session;

  const _SessionHistoryCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final (statusColor, statusLabel) = switch (session.status) {
      'completed' => (AppColors.mintGreen, 'Completed'),
      'cancelled' => (AppColors.softCoral, 'Cancelled'),
      _ => (AppColors.warmYellow, 'Scheduled'),
    };

    final width = MediaQuery.of(context).size.width;

    final isTablet = width >= 600 && width < 1024;
    final isDesktop = width >= 1024;

    return Container(
      padding: EdgeInsets.all(
        isDesktop
            ? 18
            : isTablet
            ? 16
            : 14,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.typeLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: isDesktop ? 15 : 14,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      '${AppDateUtils.formatDate(session.scheduledAt)}  •  ${session.durationMin} min  •  ${session.mode}',
                      style: TextStyle(
                        fontSize: isDesktop ? 13 : 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 12 : 10,
                  vertical: isDesktop ? 5 : 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: isDesktop ? 12 : 11,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),

          if (session.notes != null) ...[
            const Divider(height: 16),
            _NotesRow(notes: session.notes!),
          ],
        ],
      ),
    );
  }
}

class _NotesRow extends StatelessWidget {
  final SessionNotes notes;

  const _NotesRow({required this.notes});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final isMobile = width < 600;
    final isDesktop = width >= 1024;

    final moodEmoji = switch (notes.mood) {
      'happy' => '😊',
      'calm' => '😌',
      'anxious' => '😰',
      'sad' => '😢',
      'angry' => '😠',
      _ => '😐',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$moodEmoji  Mood: ${notes.mood}',
                    style: TextStyle(fontSize: isDesktop ? 13 : 12),
                  ),

                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _MiniScore(
                        'Att',
                        notes.attentionScore,
                        AppColors.primaryBlue,
                      ),
                      _MiniScore(
                        'Com',
                        notes.communicationScore,
                        AppColors.mintGreen,
                      ),
                      _MiniScore('Mot', notes.motorScore, AppColors.warmYellow),
                      _MiniScore(
                        'Beh',
                        notes.behaviorScore,
                        AppColors.softCoral,
                      ),
                    ],
                  ),
                ],
              )
            : Row(
                children: [
                  Text(
                    '$moodEmoji  Mood: ${notes.mood}',
                    style: TextStyle(fontSize: isDesktop ? 13 : 12),
                  ),

                  const Spacer(),

                  _MiniScore(
                    'Att',
                    notes.attentionScore,
                    AppColors.primaryBlue,
                  ),

                  const SizedBox(width: 6),

                  _MiniScore(
                    'Com',
                    notes.communicationScore,
                    AppColors.mintGreen,
                  ),

                  const SizedBox(width: 6),

                  _MiniScore('Mot', notes.motorScore, AppColors.warmYellow),

                  const SizedBox(width: 6),

                  _MiniScore('Beh', notes.behaviorScore, AppColors.softCoral),
                ],
              ),

        if (notes.activities.isNotEmpty) ...[
          SizedBox(height: isDesktop ? 8 : 6),

          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: notes.activities
                .take(4)
                .map(
                  (a) => Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 10 : 8,
                      vertical: isDesktop ? 4 : 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      a,
                      style: TextStyle(
                        fontSize: isDesktop ? 11 : 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],

        if (notes.whatWorked != null && notes.whatWorked!.isNotEmpty) ...[
          SizedBox(height: isDesktop ? 10 : 8),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.thumb_up_outlined,
                size: isDesktop ? 14 : 13,
                color: AppColors.mintGreen,
              ),

              const SizedBox(width: 6),

              Expanded(
                child: Text(
                  notes.whatWorked!,
                  style: TextStyle(
                    fontSize: isDesktop ? 13 : 12,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],

        if (notes.whatDidntWork != null && notes.whatDidntWork!.isNotEmpty) ...[
          const SizedBox(height: 4),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.thumb_down_outlined,
                size: isDesktop ? 14 : 13,
                color: AppColors.softCoral,
              ),

              const SizedBox(width: 6),

              Expanded(
                child: Text(
                  notes.whatDidntWork!,
                  style: TextStyle(
                    fontSize: isDesktop ? 13 : 12,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],

        if (notes.homework != null && notes.homework!.isNotEmpty) ...[
          const SizedBox(height: 4),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.home_outlined,
                size: isDesktop ? 14 : 13,
                color: AppColors.primaryBlue,
              ),

              const SizedBox(width: 6),

              Expanded(
                child: Text(
                  notes.homework!,
                  style: TextStyle(
                    fontSize: isDesktop ? 13 : 12,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _MiniScore extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _MiniScore(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$value',
          style: TextStyle(
            fontSize: isDesktop ? 14 : 13,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: isDesktop ? 10 : 9,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ── Alert History Card ─────────────────────────────────────────────────────
class _AlertHistoryCard extends StatelessWidget {
  final AlertModel alert;

  const _AlertHistoryCard({required this.alert});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    final (sevColor, _) = switch (alert.severity) {
      'high' => (AppColors.softCoral, 'High'),
      'critical' => (const Color(0xFFB00020), 'Critical'),
      'medium' => (AppColors.warmYellow, 'Medium'),
      _ => (AppColors.mintGreen, 'Low'),
    };

    final (statColor, statLabel) = switch (alert.status) {
      'resolved' => (AppColors.mintGreen, 'Resolved'),
      'seen' => (AppColors.primaryBlue, 'Seen'),
      _ => (AppColors.softCoral, 'Open'),
    };

    return Container(
      padding: EdgeInsets.all(isDesktop ? 18 : 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: alert.status == 'open'
              ? sevColor.withValues(alpha: 0.3)
              : AppColors.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: isDesktop ? 12 : 10,
                height: isDesktop ? 12 : 10,
                decoration: BoxDecoration(
                  color: sevColor,
                  shape: BoxShape.circle,
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  alert.typeLabel,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: isDesktop ? 15 : 14,
                  ),
                ),
              ),

              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 12 : 10,
                  vertical: isDesktop ? 5 : 4,
                ),
                decoration: BoxDecoration(
                  color: statColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statLabel,
                  style: TextStyle(
                    fontSize: isDesktop ? 12 : 11,
                    fontWeight: FontWeight.w600,
                    color: statColor,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: isDesktop ? 10 : 8),

          Text(
            alert.description,
            style: TextStyle(
              fontSize: isDesktop ? 14 : 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),

          SizedBox(height: isDesktop ? 8 : 6),

          Text(
            AppDateUtils.formatDate(alert.createdAt),
            style: TextStyle(
              fontSize: isDesktop ? 12 : 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Severity Badge ─────────────────────────────────────────────────────────

class _SeverityBadge extends StatelessWidget {
  final String severity;
  const _SeverityBadge({required this.severity});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (severity) {
      'mild' => ('Mild', AppColors.mintGreen),
      'moderate' => ('Moderate', AppColors.warmYellow),
      'severe' => ('Severe', AppColors.softCoral),
      _ => ('—', Colors.white70),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ── Assessment helpers ─────────────────────────────────────────────────────

class _AdminAssessmentButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _AdminAssessmentButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
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

class _AdminAssessmentRow extends StatelessWidget {
  final dynamic assessment;
  final VoidCallback onTap;
  const _AdminAssessmentRow({required this.assessment, required this.onTap});

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
      'initial' => 'Initial Assessment',
      'monthly' => 'Monthly Reassessment',
      'quarterly' => 'Quarterly Review',
      _ => type,
    };

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: riskColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    typeLabel,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${date.day}/${date.month}/${date.year}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${score.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: riskColor,
                  ),
                ),
                Text(switch (risk) {
                  'green' => 'Low Risk',
                  'red' => 'High Risk',
                  _ => 'Moderate',
                }, style: TextStyle(fontSize: 10, color: riskColor)),
              ],
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.chevron_right,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Loading Card ───────────────────────────────────────────────────────────

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.primaryBlue,
        ),
      ),
    );
  }
}
