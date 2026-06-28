import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    final sessions    = ref.watch(therapistChildSessionsProvider(child.id));
    final nextSession = ref.watch(therapistChildNextSessionProvider(child.id));
    final plan        = ref.watch(therapistChildPlanProvider(child.id));
    final dietPlan    = ref.watch(therapistChildDietPlanProvider(child.id));
    final assessments = ref.watch(childAssessmentsProvider(child.id));
    final goals       = ref.watch(therapistChildGoalsProvider(child.id));
    final reviews     = ref.watch(therapistChildReviewsProvider(child.id));
    final videos      = ref.watch(therapistChildVideosProvider(child.id));
    final aiDrafts    = ref.watch(therapistAiDraftsProvider(child.id));

    return Scaffold(
      backgroundColor: AppColors.background,
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
          slivers: [
            _buildAppBar(context),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 16),
                  _buildDiagnosis(context),
                  const SizedBox(height: 16),
                  _buildNextSession(context, nextSession),
                  const SizedBox(height: 16),
                  _buildQuickStats(sessions),
                  const SizedBox(height: 20),
                  _buildAssessmentSection(context, assessments),
                  const SizedBox(height: 16),
                  _buildAddSessionButton(context),
                  const SizedBox(height: 24),
                  _buildProgressCharts(context, sessions),
                  const SizedBox(height: 24),
                  _buildActivePlan(context, plan),
                  const SizedBox(height: 24),
                  _buildDietPlan(context, dietPlan),
                  const SizedBox(height: 24),
                  _buildGoals(context, ref, goals),
                  const SizedBox(height: 24),
                  _buildReviews(context, reviews),
                  const SizedBox(height: 24),
                  _buildVideos(context, videos),
                  const SizedBox(height: 24),
                  _buildAiDrafts(context, ref, aiDrafts),
                  const SizedBox(height: 24),
                  _buildSessionHistory(context, ref, sessions),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Hero App Bar ─────────────────────────────────────────────────────────

  Widget _buildAppBar(BuildContext context) {
    final (sevLabel, sevColor) = switch (child.severity) {
      'mild'         => ('Mild',         AppColors.mintGreen),
      'moderate'     => ('Moderate',     AppColors.warmYellow),
      'severe' => ('Severe', AppColors.softCoral),
      _              => ('—',            Colors.white70),
    };

    return SliverAppBar(
      expandedHeight: 190,
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
              padding: const EdgeInsets.fromLTRB(20, 52, 20, 20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: Text(
                      child.name[0].toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 26),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(child.name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 20)),
                        const SizedBox(height: 4),
                        Text('${child.ageYears} years old',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.4)),
                          ),
                          child: Text(sevLabel,
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: sevColor)),
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

  Widget _buildNextSession(BuildContext context, AsyncValue<SessionModel?> next) {
    return next.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (session) {
        if (session == null) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                Icon(Icons.event_outlined, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                const Text('No upcoming session scheduled',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          );
        }
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Icon(Icons.event, size: 18, color: AppColors.primaryBlue),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Next Session',
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryBlue)),
                    const SizedBox(height: 2),
                    Text(
                      '${session.typeLabel}  •  '
                      '${AppDateUtils.formatDate(session.scheduledAt)}  '
                      '${AppDateUtils.formatTime(session.scheduledAt)}  '
                      '•  ${session.durationMin} min',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
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

  Widget _buildDiagnosis(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: child.diagnosis
          .map((d) => Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppColors.primaryBlue.withValues(alpha: 0.3)),
                ),
                child: Text(d,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryBlue)),
              ))
          .toList(),
    );
  }

  // ── Quick Stats ──────────────────────────────────────────────────────────

  Widget _buildQuickStats(AsyncValue<List<SessionModel>> sessions) {
    final all       = sessions.valueOrNull ?? [];
    final completed = all.where((s) => s.status == 'completed').length;
    final upcoming  = all.where((s) =>
        s.status == 'scheduled' && s.scheduledAt.isAfter(DateTime.now())).length;

    return Row(
      children: [
        _StatChip(label: 'Total',     value: '${all.length}',  color: AppColors.primaryBlue,   icon: Icons.event_note_outlined),
        const SizedBox(width: 10),
        _StatChip(label: 'Completed', value: '$completed',     color: AppColors.mintGreen,     icon: Icons.check_circle_outline),
        const SizedBox(width: 10),
        _StatChip(label: 'Upcoming',  value: '$upcoming',      color: AppColors.warmYellow,    icon: Icons.upcoming_outlined),
      ],
    );
  }

  // ── Add Session ──────────────────────────────────────────────────────────

  Widget _buildAddSessionButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CreateSessionScreen(preselectedChild: child),
          ),
        ),
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Schedule New Session',
            style: TextStyle(fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
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
        builder: (_) => AssessmentWizardScreen(
          child:          child,
          assessmentType: type,
        ),
      ),
    );
  }

  Widget _buildAssessmentSection(
      BuildContext context, AsyncValue<dynamic> assessments) {
    final list = (assessments.valueOrNull as List?) ?? [];

    return _SectionCard(
      title: 'Assessments',
      icon:  Icons.assignment_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Start assessment buttons
          Row(
            children: [
              Expanded(
                child: _AssessmentTypeButton(
                  label: list.isEmpty ? 'Initial Assessment' : 'Monthly Reassessment',
                  icon:  list.isEmpty ? Icons.play_arrow : Icons.refresh,
                  color: AppColors.primaryBlue,
                  onTap: () => _startAssessment(
                    context,
                    list.isEmpty ? 'initial' : 'monthly',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _AssessmentTypeButton(
                  label: 'Quarterly Review',
                  icon:  Icons.bar_chart_outlined,
                  color: const Color(0xFF9B59B6),
                  onTap: () => _startAssessment(context, 'quarterly'),
                ),
              ),
            ],
          ),
          if (list.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Text('Assessment History',
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            ...list.take(5).map((a) => _AssessmentHistoryRow(
                  assessment: a,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AssessmentResultScreen(
                        assessment: a,
                        child:      child,
                      ),
                    ),
                  ),
                )),
          ],
        ],
      ),
    );
  }

  // ── Progress Charts ──────────────────────────────────────────────────────

  Widget _buildProgressCharts(
      BuildContext context, AsyncValue<List<SessionModel>> sessions) {
    final completed = (sessions.valueOrNull
            ?.where((s) => s.status == 'completed' && s.notes != null)
            .toList() ?? [])
          ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

    if (completed.isEmpty) {
      return _SectionCard(
        title: 'Progress Charts',
        icon: Icons.show_chart,
        child: _emptyMsg('No completed sessions with notes yet'),
      );
    }

    final labels = completed
        .map((s) => AppDateUtils.formatShortDate(s.scheduledAt))
        .toList();

    return _SectionCard(
      title: 'Progress Trends',
      icon: Icons.show_chart,
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
          const SizedBox(height: 16),
          TrendChart(
            title: 'Communication',
            values: completed
                .map((s) => s.notes!.communicationScore.toDouble())
                .toList(),
            labels: labels,
            lineColor: AppColors.mintGreen,
          ),
          const SizedBox(height: 16),
          TrendChart(
            title: 'Motor Skills',
            values: completed
                .map((s) => s.notes!.motorScore.toDouble())
                .toList(),
            labels: labels,
            lineColor: AppColors.warmYellow,
          ),
          const SizedBox(height: 16),
          TrendChart(
            title: 'Behavior',
            values: completed
                .map((s) => s.notes!.behaviorScore.toDouble())
                .toList(),
            labels: labels,
            lineColor: AppColors.softCoral,
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WeeklyReportScreen(
                    childId:   child.id,
                    childName: child.name,
                  ),
                ),
              ),
              icon: const Icon(Icons.open_in_new, size: 14),
              label: const Text('View Full Report'),
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
      BuildContext context, AsyncValue<HomePlanModel?> plan) {
    return _SectionCard(
      title: 'Home Plan',
      icon: Icons.assignment_outlined,
      child: plan.when(
        loading: () => const SizedBox(
            height: 40,
            child: Center(
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.primaryBlue))),
        error: (_, _) => _emptyMsg('Could not load plan'),
        data: (p) {
          if (p == null) return _emptyMsg('No active home plan');
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.date_range_outlined,
                      size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    '${AppDateUtils.formatDate(p.startDate)} → ${AppDateUtils.formatDate(p.endDate)}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const Spacer(),
                  Text('${p.tasks.length} tasks',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryBlue)),
                ],
              ),
              if (p.tasks.isNotEmpty) ...[
                const SizedBox(height: 12),
                ...p.tasks.take(4).map((t) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Text(t.icon,
                              style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(t.title,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500)),
                                Text(
                                  '${t.timeOfDay}  •  ${t.durationMin} min  •  ${t.frequency}',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
                if (p.tasks.length > 4)
                  Text('+ ${p.tasks.length - 4} more tasks',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
              ],
            ],
          );
        },
      ),
    );
  }

  // ── Session History ──────────────────────────────────────────────────────

  Widget _buildSessionHistory(BuildContext context, WidgetRef ref,
      AsyncValue<List<SessionModel>> sessions) {
    return _SectionCard(
      title: 'Session History',
      icon: Icons.history,
      child: sessions.when(
        loading: () => const SizedBox(
            height: 40,
            child: Center(
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.primaryBlue))),
        error: (e, _) => _emptyMsg('Could not load sessions'),
        data: (list) {
          if (list.isEmpty) return _emptyMsg('No sessions yet');
          final sorted = [...list]
            ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sorted.length,
            separatorBuilder: (_, _) => const Divider(height: 16),
            itemBuilder: (_, i) =>
                _SessionRow(session: sorted[i], child: child, ref: ref),
          );
        },
      ),
    );
  }

  // ── Diet Chart ───────────────────────────────────────────────────────────
  Widget _buildDietPlan(
      BuildContext context, AsyncValue<DietPlanModel?> plan) {
    return _SectionCard(
      title: 'Diet Chart',
      icon: Icons.restaurant_outlined,
      child: plan.when(
        loading: () => const SizedBox(
            height: 40,
            child: Center(
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.primaryBlue))),
        error: (_, _) => _emptyMsg('Could not load diet plan'),
        data: (p) {
          if (p == null) return _emptyMsg('No active diet plan');
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.date_range_outlined,
                      size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    '${AppDateUtils.formatDate(p.startDate)} → ${AppDateUtils.formatDate(p.endDate)}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const Spacer(),
                  Text('${p.meals.length} meals',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryBlue)),
                ],
              ),
              const SizedBox(height: 12),
              if (p.notes != null && p.notes!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(p.notes!,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textSecondary)),
                ),
              ...p.meals.map((m) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(m.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 14)),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.mintGreen.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(m.mealTime,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.mintGreen,
                                      fontWeight: FontWeight.w500)),
                            ),
                          ],
                        ),
                        if (m.description != null && m.description!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(m.description!,
                                style: const TextStyle(fontSize: 12)),
                          ),
                        if (m.ingredients.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              'Ingredients: ${m.ingredients.join(", ")}',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary),
                            ),
                          ),
                        Text(
                          '${m.caloriesApprox} kcal • ${m.frequency}',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  )),
            ],
          );
        },
      ),
    );
  }

  // ── Videos ────────────────────────────────────────────────────────────────

  Widget _buildVideos(BuildContext context,
      AsyncValue<List<VideoItemModel>> videos) {
    return _SectionCard(
      title: 'Videos',
      icon:  Icons.videocam_outlined,
      child: videos.when(
        loading: () => const SizedBox(
            height: 40,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryBlue))),
        error: (_, _) => _emptyMsg('Could not load videos'),
        data: (list) {
          if (list.isEmpty) return _emptyMsg('No videos uploaded yet');
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: list.length,
            separatorBuilder: (_, _) => const Divider(height: 16),
            itemBuilder: (_, i) => _VideoRow(video: list[i]),
          );
        },
      ),
    );
  }

  // ── AI Drafts ─────────────────────────────────────────────────────────────

  Widget _buildAiDrafts(BuildContext context, WidgetRef ref,
      AsyncValue<List<AiDraftModel>> aiDrafts) {
    return _SectionCard(
      title: 'AI Plans & Insights',
      icon:  Icons.auto_awesome_outlined,
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
              ),
              _AiButton(
                label: 'Home Plan',
                onTap: () => _generateAi(context, ref, 'home_plan'),
              ),
              _AiButton(
                label: 'Activities',
                onTap: () => _generateAi(context, ref, 'reinforcement_activities'),
              ),
              _AiButton(
                label: 'Insights',
                onTap: () => _generateAi(context, ref, 'insights'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 10),
          aiDrafts.when(
            loading: () => const SizedBox(
                height: 40,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryBlue))),
            error: (_, _) => _emptyMsg('Could not load drafts'),
            data: (list) {
              if (list.isEmpty) return _emptyMsg('No AI drafts yet — tap a button above');
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: list.length > 5 ? 5 : list.length,
                separatorBuilder: (_, _) => const Divider(height: 12),
                itemBuilder: (_, i) => _AiDraftRow(
                  draft: list[i],
                  onApprove: () async {
                    await ref.read(aiRepositoryProvider).approveDraft(list[i].id);
                    ref.invalidate(therapistAiDraftsProvider(child.id));
                  },
                  onView: () => _showDraftContent(context, list[i]),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _generateAi(BuildContext context, WidgetRef ref, String type) async {
    final notifier = ref.read(aiGenerateProvider.notifier);
    await notifier.generate(child.id, type);
    final state = ref.read(aiGenerateProvider);
    if (state.error != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${state.error}'), backgroundColor: AppColors.softCoral),
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
        builder: (_, controller) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(draft.typeLabel,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(
                '${draft.isApproved ? "Approved" : "Pending"} • ${draft.modelUsed}',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const Divider(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  controller: controller,
                  child: Text(draft.content,
                      style: const TextStyle(fontSize: 13, height: 1.6)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyMsg(String msg) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: Text(msg,
              style: const TextStyle(color: AppColors.textSecondary)),
        ),
      );

  // ── Goals ─────────────────────────────────────────────────────────────────

  Widget _buildGoals(BuildContext context, WidgetRef ref,
      AsyncValue<List<GoalModel>> goals) {
    return _SectionCard(
      title: 'Therapy Goals',
      icon:  Icons.flag_outlined,
      child: goals.when(
        loading: () => const SizedBox(
            height: 40,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryBlue))),
        error: (_, _) => _emptyMsg('Could not load goals'),
        data: (list) {
          final active = list.where((g) => g.status != 'completed').toList();
          if (list.isEmpty) return _emptyMsg('No goals set yet');
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...active.take(5).map((g) => _GoalRow(goal: g)),
              if (list.any((g) => g.isCompleted)) ...[
                const SizedBox(height: 8),
                Text('${list.where((g) => g.isCompleted).length} goal(s) completed',
                    style: const TextStyle(fontSize: 12, color: AppColors.mintGreen)),
              ],
            ],
          );
        },
      ),
    );
  }

  // ── Reviews ───────────────────────────────────────────────────────────────

  Widget _buildReviews(BuildContext context,
      AsyncValue<List<ReviewModel>> reviews) {
    return _SectionCard(
      title: 'Reviews',
      icon:  Icons.summarize_outlined,
      child: reviews.when(
        loading: () => const SizedBox(
            height: 40,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryBlue))),
        error: (_, _) => _emptyMsg('Could not load reviews'),
        data: (list) {
          if (list.isEmpty) return _emptyMsg('No reviews yet');
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: list.length,
            separatorBuilder: (_, _) => const Divider(height: 16),
            itemBuilder: (_, i) => _ReviewRow(review: list[i]),
          );
        },
      ),
    );
  }
}

// ── Goal Row ──────────────────────────────────────────────────────────────

class _GoalRow extends StatelessWidget {
  final GoalModel goal;
  const _GoalRow({required this.goal});

  @override
  Widget build(BuildContext context) {
    final (statusColor, icon) = switch (goal.status) {
      'completed' => (AppColors.mintGreen,  Icons.check_circle_outline),
      'active'    => (AppColors.primaryBlue, Icons.play_circle_outline),
      'accepted'  => (AppColors.mintGreen,  Icons.thumb_up_outlined),
      'paused'    => (AppColors.warmYellow,  Icons.pause_circle_outline),
      _           => (AppColors.textSecondary, Icons.radio_button_unchecked),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: statusColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(goal.title,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                if (goal.description != null && goal.description!.isNotEmpty)
                  Text(goal.description!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(goal.statusLabel,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: statusColor)),
          ),
        ],
      ),
    );
  }
}

// ── Review Row ────────────────────────────────────────────────────────────

class _ReviewRow extends StatelessWidget {
  final ReviewModel review;
  const _ReviewRow({required this.review});

  @override
  Widget build(BuildContext context) {
    final isPublished = review.isPublished;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                review.reviewType == 'quarterly'
                    ? Icons.calendar_today
                    : Icons.calendar_view_month,
                size: 14,
                color: AppColors.primaryBlue,
              ),
              const SizedBox(width: 6),
              Text(review.typeLabel,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (isPublished ? AppColors.mintGreen : AppColors.warmYellow)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isPublished ? 'Published' : 'Draft',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isPublished ? AppColors.mintGreen : AppColors.warmYellow),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${review.periodStart.day}/${review.periodStart.month}/${review.periodStart.year}'
            ' → '
            '${review.periodEnd.day}/${review.periodEnd.month}/${review.periodEnd.year}',
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            review.textObservations,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          if (review.adminNotes != null && review.adminNotes!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('Admin: ${review.adminNotes}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.primaryBlue,
                    fontStyle: FontStyle.italic)),
          ],
        ],
      ),
    );
  }
}

// ── Video Row ─────────────────────────────────────────────────────────────

class _VideoRow extends StatelessWidget {
  final VideoItemModel video;
  const _VideoRow({required this.video});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.play_circle_outline,
                color: AppColors.primaryBlue, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(video.title,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(video.categoryLabel,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
                if (video.description != null &&
                    video.description!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(video.description!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textSecondary)),
                ],
              ],
            ),
          ),
          if (!video.isParentVisible)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.warmYellow.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Internal',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: AppColors.warmYellow)),
            ),
        ],
      ),
    );
  }
}

// ── Stat Chip ─────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  const _StatChip(
      {required this.label,
      required this.value,
      required this.color,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 5),
            Text(value,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: color)),
            Text(label,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

// ── Section Card ──────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const _SectionCard(
      {required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: AppColors.primaryBlue, size: 16),
              ),
              const SizedBox(width: 10),
              Text(title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 14),
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
  const _SessionRow(
      {required this.session, required this.child, required this.ref});

  @override
  Widget build(BuildContext context) {
    final (statusColor, statusLabel) = switch (session.status) {
      'completed' => (AppColors.mintGreen, 'Completed'),
      'cancelled' => (AppColors.softCoral, 'Cancelled'),
      _           => (AppColors.warmYellow, 'Scheduled'),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(session.typeLabel,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(
                    '${AppDateUtils.formatDate(session.scheduledAt)}  •  ${AppDateUtils.formatTime(session.scheduledAt)}  •  ${session.durationMin} min',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(statusLabel,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor)),
            ),
          ],
        ),
        if (session.status == 'completed' && session.notes != null) ...[
          const SizedBox(height: 8),
          _NotesPreview(notes: session.notes!),
        ] else if (session.status == 'scheduled') ...[
          const SizedBox(height: 6),
          TextButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SessionNotesScreen(
                  session:   session,
                  childName: child.name,
                ),
              ),
            ),
            icon: const Icon(Icons.edit_outlined, size: 14),
            label: const Text('Add Notes'),
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
  const _NotesPreview({required this.notes});

  @override
  Widget build(BuildContext context) {
    final moodEmoji = switch (notes.mood) {
      'happy'   => '😊',
      'calm'    => '😌',
      'anxious' => '😰',
      'sad'     => '😢',
      'angry'   => '😠',
      _         => '😐',
    };

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('$moodEmoji ${notes.mood}',
                  style: const TextStyle(fontSize: 12)),
              const Spacer(),
              _Score('Att', notes.attentionScore, AppColors.primaryBlue),
              const SizedBox(width: 8),
              _Score('Com', notes.communicationScore, AppColors.mintGreen),
              const SizedBox(width: 8),
              _Score('Mot', notes.motorScore, AppColors.warmYellow),
              const SizedBox(width: 8),
              _Score('Beh', notes.behaviorScore, AppColors.softCoral),
            ],
          ),
          if (notes.whatWorked != null && notes.whatWorked!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.thumb_up_outlined,
                    size: 12, color: AppColors.mintGreen),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(notes.whatWorked!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          height: 1.4)),
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
  const _Score(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$value',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color)),
        Text(label,
            style: const TextStyle(
                fontSize: 9, color: AppColors.textSecondary)),
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
  const _AssessmentTypeButton({
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
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color:        color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border:       Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                    fontSize:   12,
                    fontWeight: FontWeight.w600,
                    color:      color),
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
  const _AiButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF6C63FF).withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome, size: 12, color: Color(0xFF6C63FF)),
            const SizedBox(width: 5),
            Text(label,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6C63FF))),
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
  const _AiDraftRow({required this.draft, required this.onApprove, required this.onView});

  @override
  Widget build(BuildContext context) {
    final statusColor = draft.isApproved ? AppColors.mintGreen : AppColors.warmYellow;
    return Row(
      children: [
        const Icon(Icons.description_outlined, size: 16, color: AppColors.primaryBlue),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(draft.typeLabel,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              Text(
                draft.isApproved ? 'Approved' : 'Pending review',
                style: TextStyle(fontSize: 11, color: statusColor),
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
              tapTargetSize: MaterialTapTargetSize.shrinkWrap),
          child: const Text('View', style: TextStyle(fontSize: 12)),
        ),
        if (draft.isPending) ...[
          const SizedBox(width: 4),
          TextButton(
            onPressed: onApprove,
            style: TextButton.styleFrom(
                foregroundColor: AppColors.mintGreen,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap),
            child: const Text('Approve', style: TextStyle(fontSize: 12)),
          ),
        ],
      ],
    );
  }
}

// ── Assessment History Row ────────────────────────────────────────────────

class _AssessmentHistoryRow extends StatelessWidget {
  final dynamic assessment;
  final VoidCallback onTap;
  const _AssessmentHistoryRow({required this.assessment, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final score     = (assessment.overallScorePct as double?) ?? 0.0;
    final risk      = assessment.riskLevel as String? ?? 'amber';
    final type      = assessment.type as String? ?? '';
    final date      = assessment.date as DateTime? ?? DateTime.now();

    final riskColor = switch (risk) {
      'green' => AppColors.mintGreen,
      'red'   => AppColors.softCoral,
      _       => AppColors.warmYellow,
    };

    final typeLabel = switch (type) {
      'initial'   => 'Initial',
      'monthly'   => 'Monthly',
      'quarterly' => 'Quarterly',
      _           => type,
    };

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              width: 8, height: 8,
              decoration: BoxDecoration(
                  color: riskColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                typeLabel,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
            Text(
              '${score.toStringAsFixed(0)}%',
              style: TextStyle(
                  fontSize:   13,
                  fontWeight: FontWeight.w700,
                  color:      riskColor),
            ),
            const SizedBox(width: 8),
            Text(
              '${date.day}/${date.month}/${date.year}',
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right,
                size: 16, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
