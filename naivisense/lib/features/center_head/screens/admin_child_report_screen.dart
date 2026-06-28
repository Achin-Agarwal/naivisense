import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/alert.dart';
import '../../../data/models/child.dart';
import '../../../data/models/diet_plan.dart';
import '../../../data/models/home_plan.dart';
import '../../../data/models/session.dart';
import '../../../shared/widgets/trend_chart.dart';
import '../../../features/assessments/providers/assessment_provider.dart';
import '../../../features/assessments/screens/assessment_wizard_screen.dart';
import '../../../features/assessments/screens/assessment_result_screen.dart';
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
    final sessions = ref.watch(adminChildSessionsProvider(child.id));
    final plan = ref.watch(adminChildPlanProvider(child.id));
    final dietPlan = ref.watch(adminChildDietPlanProvider(child.id));
    final alerts = ref.watch(adminChildAlertsProvider(child.id));
    final assessments = ref.watch(childAssessmentsProvider(child.id));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(adminChildSessionsProvider(child.id));
          ref.invalidate(adminChildPlanProvider(child.id));
          ref.invalidate(adminChildDietPlanProvider(child.id));
          ref.invalidate(adminChildAlertsProvider(child.id));
          ref.invalidate(childAssessmentsProvider(child.id));
        },
        child: CustomScrollView(
          slivers: [
            _buildHeroAppBar(context),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 16),
                  _buildDiagnosisRow(context),
                  const SizedBox(height: 20),
                  _buildAssessmentSection(context, assessments),
                  const SizedBox(height: 24),
                  _buildQuickStats(context, sessions, alerts),
                  const SizedBox(height: 24),
                  _buildStaffSection(context, sessions),
                  const SizedBox(height: 24),
                  _buildProgressCharts(context, sessions),
                  const SizedBox(height: 24),
                  _buildActivePlan(context, plan),
                  const SizedBox(height: 24),
                  _buildDietPlan(context, dietPlan),
                  const SizedBox(height: 24),
                  _buildSessionHistory(context, sessions),
                  const SizedBox(height: 24),
                  _buildAlertsSection(context, alerts),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Hero App Bar ───────────────────────────────────────────────────────────

  Widget _buildHeroAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppColors.centerHeadGradient.colors.last,
      leading: const BackButton(color: Colors.white),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Admin View',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(gradient: AppColors.centerHeadGradient),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: Text(
                      child.name.isNotEmpty ? child.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          child.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 22,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${child.ageYears} years old',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
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
    );
  }

  // ── Assessment Section ─────────────────────────────────────────────────────

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
    final list = (assessments.valueOrNull as List?) ?? [];
    final isLoading = assessments.isLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(context, 'Assessments', Icons.assignment_outlined),
        const SizedBox(height: 12),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: _AdminAssessmentButton(
                label: list.isEmpty
                    ? 'Start Initial Assessment'
                    : 'New Monthly Assessment',
                icon: list.isEmpty
                    ? Icons.play_arrow_rounded
                    : Icons.refresh_rounded,
                color: AppColors.primaryBlue,
                onTap: () =>
                    _openWizard(context, list.isEmpty ? 'initial' : 'monthly'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _AdminAssessmentButton(
                label: 'Quarterly Review',
                icon: Icons.bar_chart_rounded,
                color: const Color(0xFF9B59B6),
                onTap: () => _openWizard(context, 'quarterly'),
              ),
            ),
          ],
        ),

        // History
        if (isLoading) ...[
          const SizedBox(height: 12),
          const _LoadingCard(),
        ] else if (list.isEmpty) ...[
          const SizedBox(height: 12),
          _emptyCard(
            'No assessments done yet. Start the initial assessment above.',
          ),
        ] else ...[
          const SizedBox(height: 14),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Diagnosis',
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: child.diagnosis
              .map(
                (d) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.centerHeadGradient.colors.first.withValues(
                      alpha: 0.1,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.centerHeadGradient.colors.first
                          .withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    d,
                    style: TextStyle(
                      fontSize: 12,
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
    final total = sessions.valueOrNull?.length ?? 0;
    final completed =
        sessions.valueOrNull?.where((s) => s.status == 'completed').length ?? 0;
    final openAlerts =
        alerts.valueOrNull?.where((a) => a.status == 'open').length ?? 0;

    return Row(
      children: [
        _QuickStat(
          label: 'Total\nSessions',
          value: '$total',
          color: AppColors.primaryBlue,
          icon: Icons.event_note_outlined,
        ),
        const SizedBox(width: 10),
        _QuickStat(
          label: 'Completed',
          value: '$completed',
          color: AppColors.mintGreen,
          icon: Icons.check_circle_outline,
        ),
        const SizedBox(width: 10),
        _QuickStat(
          label: 'Open\nAlerts',
          value: '$openAlerts',
          color: openAlerts > 0 ? AppColors.softCoral : AppColors.textSecondary,
          icon: Icons.notifications_active_outlined,
        ),
      ],
    );
  }

  // ── Staff Section ──────────────────────────────────────────────────────────

  Widget _buildStaffSection(
    BuildContext context,
    AsyncValue<List<SessionModel>> sessions,
  ) {
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
        const SizedBox(height: 12),
        _InlineStaffCard(
          name: therapistName,
          phone: therapistPhone,
          role: 'Therapist',
          roleColor: AppColors.primaryBlue,
          roleIcon: Icons.medical_services_outlined,
          subtitle: '$completedCount sessions completed',
        ),
        const SizedBox(height: 12),
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
          const SizedBox(height: 12),
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
        const SizedBox(height: 16),
        _ChartCard(
          child: TrendChart(
            title: 'Attention',
            values: attention,
            labels: labels,
            lineColor: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(height: 12),
        _ChartCard(
          child: TrendChart(
            title: 'Communication',
            values: communication,
            labels: labels,
            lineColor: AppColors.mintGreen,
          ),
        ),
        const SizedBox(height: 12),
        _ChartCard(
          child: TrendChart(
            title: 'Motor Skills',
            values: motor,
            labels: labels,
            lineColor: AppColors.warmYellow,
          ),
        ),
        const SizedBox(height: 12),
        _ChartCard(
          child: TrendChart(
            title: 'Behavior',
            values: behavior,
            labels: labels,
            lineColor: AppColors.softCoral,
          ),
        ),
        const SizedBox(height: 12),
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
    double avg(List<double> v) =>
        v.isEmpty ? 0 : v.reduce((a, b) => a + b) / v.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Average Scores',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 14),
          _ScoreBar(
            label: 'Attention',
            value: avg(attention),
            color: AppColors.primaryBlue,
          ),
          const SizedBox(height: 8),
          _ScoreBar(
            label: 'Communication',
            value: avg(communication),
            color: AppColors.mintGreen,
          ),
          const SizedBox(height: 8),
          _ScoreBar(
            label: 'Motor Skills',
            value: avg(motor),
            color: AppColors.warmYellow,
          ),
          const SizedBox(height: 8),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(context, 'Home Plan', Icons.assignment_outlined),
        const SizedBox(height: 12),
        plan.when(
          loading: () => const _LoadingCard(),
          error: (e, _) => _emptyCard('Could not load plan'),
          data: (p) {
            if (p == null) return _emptyCard('No active home plan');
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primaryBlue.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.date_range_outlined,
                        color: AppColors.primaryBlue,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${AppDateUtils.formatDate(p.startDate)} → ${AppDateUtils.formatDate(p.endDate)}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${p.tasks.length} tasks',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (p.morningTasks.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _TaskGroup(title: 'Morning', tasks: p.morningTasks),
                ],
                if (p.afternoonTasks.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _TaskGroup(title: 'Afternoon', tasks: p.afternoonTasks),
                ],
                if (p.eveningTasks.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _TaskGroup(title: 'Evening', tasks: p.eveningTasks),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  // ── Diet Chart ─────────────────────────────────────────────────────────────
  Widget _buildDietPlan(BuildContext context, AsyncValue<DietPlanModel?> plan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(context, 'Diet Chart', Icons.restaurant_outlined),
        const SizedBox(height: 12),
        plan.when(
          loading: () => const _LoadingCard(),
          error: (e, _) => _emptyCard('Could not load diet plan'),
          data: (p) {
            if (p == null) return _emptyCard('No active diet plan');
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${AppDateUtils.formatDate(p.startDate)} → ${AppDateUtils.formatDate(p.endDate)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${p.meals.length} meals',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...p.meals
                      .take(6)
                      .map(
                        (m) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${m.mealTime.toUpperCase()}: ${m.name}',
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                              Text(
                                '${m.caloriesApprox} kcal',
                                style: const TextStyle(
                                  fontSize: 12,
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
                      style: const TextStyle(
                        fontSize: 11,
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
        const SizedBox(height: 12),
        sessions.when(
          loading: () => const _LoadingCard(),
          error: (e, _) => _emptyCard('Could not load sessions'),
          data: (sessions) {
            if (sessions.isEmpty) return _emptyCard('No sessions yet');
            final sorted = [...sessions]
              ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sorted.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(context, 'Alert History', Icons.notifications_outlined),
        const SizedBox(height: 12),
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
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (_, i) => _AlertHistoryCard(alert: sorted[i]),
            );
          },
        ),
      ],
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _sectionHeader(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.centerHeadGradient.colors.first.withValues(
              alpha: 0.1,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: AppColors.centerHeadGradient.colors.first,
            size: 18,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _emptyCard(String msg) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.divider),
    ),
    child: Center(
      child: Text(msg, style: const TextStyle(color: AppColors.textSecondary)),
    ),
  );
}

// ── Quick Stat Chip ────────────────────────────────────────────────────────

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
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Inline Staff Card (uses data populated into ChildModel) ───────────────

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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: roleColor.withValues(alpha: 0.12),
            child: Text(
              initial,
              style: TextStyle(
                color: roleColor,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: roleColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: roleColor.withValues(alpha: 0.25)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(roleIcon, color: roleColor, size: 13),
                const SizedBox(width: 4),
                Text(
                  role,
                  style: TextStyle(
                    fontSize: 11,
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

// ── Chart Card ─────────────────────────────────────────────────────────────

class _ChartCard extends StatelessWidget {
  final Widget child;
  const _ChartCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: child,
    );
  }
}

// ── Score Bar ──────────────────────────────────────────────────────────────

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
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
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
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 36,
          child: Text(
            value.toStringAsFixed(1),
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Task Group ─────────────────────────────────────────────────────────────

class _TaskGroup extends StatelessWidget {
  final String title;
  final List<HomePlanTask> tasks;
  const _TaskGroup({required this.title, required this.tasks});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
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
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          ...tasks.map(
            (t) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text(t.icon, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          '${t.durationMin} min  •  ${t.frequency}  •  ×${t.targetCount}',
                          style: const TextStyle(
                            fontSize: 11,
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

// ── Session History Card ───────────────────────────────────────────────────

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

    return Container(
      padding: const EdgeInsets.all(14),
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
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${AppDateUtils.formatDate(session.scheduledAt)}  •  ${session.durationMin} min  •  ${session.mode}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 11,
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
        Row(
          children: [
            Text(
              '$moodEmoji  Mood: ${notes.mood}',
              style: const TextStyle(fontSize: 12),
            ),
            const Spacer(),
            _MiniScore('Att', notes.attentionScore, AppColors.primaryBlue),
            const SizedBox(width: 6),
            _MiniScore('Com', notes.communicationScore, AppColors.mintGreen),
            const SizedBox(width: 6),
            _MiniScore('Mot', notes.motorScore, AppColors.warmYellow),
            const SizedBox(width: 6),
            _MiniScore('Beh', notes.behaviorScore, AppColors.softCoral),
          ],
        ),
        if (notes.activities.isNotEmpty) ...[
          const SizedBox(height: 6),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: notes.activities
                .take(4)
                .map(
                  (a) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      a,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
        if (notes.whatWorked != null && notes.whatWorked!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.thumb_up_outlined,
                size: 13,
                color: AppColors.mintGreen,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  notes.whatWorked!,
                  style: const TextStyle(
                    fontSize: 12,
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
              const Icon(
                Icons.thumb_down_outlined,
                size: 13,
                color: AppColors.softCoral,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  notes.whatDidntWork!,
                  style: const TextStyle(
                    fontSize: 12,
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
              const Icon(
                Icons.home_outlined,
                size: 13,
                color: AppColors.primaryBlue,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  notes.homework!,
                  style: const TextStyle(
                    fontSize: 12,
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
    return Column(
      children: [
        Text(
          '$value',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
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
      padding: const EdgeInsets.all(14),
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
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: sevColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                alert.typeLabel,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            alert.description,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppDateUtils.formatDate(alert.createdAt),
            style: const TextStyle(
              fontSize: 11,
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
