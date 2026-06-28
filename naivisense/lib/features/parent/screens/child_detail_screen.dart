import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/alert.dart';
import '../../../data/models/child.dart';
import '../../../data/models/diet_plan.dart';
import '../../../data/models/goal.dart';
import '../../../data/models/home_plan.dart';
import '../../../data/models/review.dart';
import '../../../data/models/video_item.dart';
import '../../../data/models/session.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../providers/parent_provider.dart';
import '../../../features/reports/screens/weekly_report_screen.dart';

class ChildDetailScreen extends ConsumerWidget {
  final ChildModel child;
  const ChildDetailScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(parentSessionsProvider(child.id));
    final plan     = ref.watch(parentActivePlanProvider(child.id));
    final dietPlan = ref.watch(parentDietPlanProvider(child.id));
    final alerts   = ref.watch(parentAlertsProvider(child.id));
    final goals    = ref.watch(parentGoalsProvider(child.id));
    final reviews  = ref.watch(parentReviewsProvider(child.id));
    final videos   = ref.watch(parentVideosProvider(child.id));

    return Scaffold(
      backgroundColor: AppColors.background,
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
          slivers: [
            _buildAppBar(context, child),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildDiagnosisRow(context),
                  const SizedBox(height: 20),
                  _buildProgressSection(context, sessions),
                  const SizedBox(height: 20),
                  _buildNextSession(context, sessions),
                  const SizedBox(height: 20),
                  _buildScheduledSessions(context),
                  const SizedBox(height: 20),
                  _buildHomePlan(context, ref, plan),
                  const SizedBox(height: 20),
                  _buildDietPlan(context, dietPlan),
                  const SizedBox(height: 20),
                  _buildLastSessionNotes(context, sessions),
                  const SizedBox(height: 20),
                  _buildOpenAlerts(context, alerts),
                  const SizedBox(height: 20),
                  _buildAcceptedGoals(context, goals),
                  const SizedBox(height: 20),
                  _buildPublishedReviews(context, reviews),
                  const SizedBox(height: 20),
                  _buildImprovementVideos(context, videos),
                  const SizedBox(height: 20),
                  _buildRaiseAlert(context, ref),
                  const SizedBox(height: 32),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── App bar with child hero ───────────────────────────────────────────────
  SliverAppBar _buildAppBar(BuildContext context, ChildModel child) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: const Color(0xFF2AAD7E),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => context.pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(gradient: AppColors.parentGradient),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 48, 20, 16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                    child: Text(child.name[0].toUpperCase(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(child.name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w700)),
                        Text('${child.ageYears} years old',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        title: Text(child.name,
            style: const TextStyle(color: Colors.white, fontSize: 16)),
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
      ),
    );
  }

  // ── Diagnosis row ─────────────────────────────────────────────────────────
  Widget _buildDiagnosisRow(BuildContext context) {
    final (severityLabel, severityColor) = switch (child.severity) {
      'mild'         => ('Mild', AppColors.mintGreen),
      'moderate'     => ('Moderate', AppColors.warmYellow),
      'severe' => ('Severe', AppColors.softCoral),
      _              => ('—', AppColors.textSecondary),
    };
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...child.diagnosis.map((d) => _chip(d, AppColors.primaryBlue)),
        _chip(severityLabel, severityColor),
      ],
    );
  }

  Widget _chip(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600, color: color)),
      );

  // ── Progress from last session ────────────────────────────────────────────
  Widget _buildProgressSection(
      BuildContext context, AsyncValue<List<SessionModel>> sessions) {
    final completed = sessions.valueOrNull
        ?.where((s) => s.status == 'completed' && s.notes != null)
        .toList()
      ?..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));

    final latest = completed?.isNotEmpty == true ? completed!.first : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Progress (Last Session)', Icons.show_chart_outlined),
        const SizedBox(height: 12),
        if (latest?.notes == null)
          const _EmptyHint(message: 'No session notes yet')
        else
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.7,
            children: [
              _ScoreTile('Attention', latest!.notes!.attentionScore, AppColors.primaryBlue),
              _ScoreTile('Communication', latest.notes!.communicationScore, AppColors.mintGreen),
              _ScoreTile('Motor Skills', latest.notes!.motorScore, AppColors.warmYellow),
              _ScoreTile('Social', latest.notes!.behaviorScore, const Color(0xFFAB7AE0)),
            ],
          ),
        if (latest != null) ...[
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'From session on ${AppDateUtils.formatDate(latest.scheduledAt)}',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12),
            ),
          ),
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
              icon: const Icon(Icons.bar_chart_outlined, size: 14),
              label: const Text('View Full Report'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.mintGreen,
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ── Next session ──────────────────────────────────────────────────────────
  Widget _buildNextSession(
      BuildContext context, AsyncValue<List<SessionModel>> sessions) {
    final upcoming = sessions.valueOrNull
        ?.where((s) => s.status == 'scheduled' && s.scheduledAt.isAfter(DateTime.now()))
        .toList()
      ?..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

    final next = upcoming?.isNotEmpty == true ? upcoming!.first : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Next Session', Icons.event_outlined),
        const SizedBox(height: 12),
        if (next == null)
          const _EmptyHint(message: 'No upcoming sessions scheduled')
        else
          AppCard(
            color: AppColors.primaryBlue.withValues(alpha: 0.04),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.event, color: AppColors.primaryBlue, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(next.typeLabel,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15)),
                      const SizedBox(height: 2),
                      Text(
                        '${AppDateUtils.formatDate(next.scheduledAt)}  •  ${AppDateUtils.formatTime(next.scheduledAt)}',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: next.mode == 'online'
                        ? AppColors.primaryBlue.withValues(alpha: 0.1)
                        : AppColors.mintGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    next.mode == 'online' ? 'Online' : 'In-Person',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: next.mode == 'online'
                          ? AppColors.primaryBlue
                          : AppColors.mintGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ── Scheduled Sessions ────────────────────────────────────────────────────
  Widget _buildScheduledSessions(BuildContext context) {
    const dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    final assignments = child.therapists
        .where((a) => a.schedule != null && a.schedule!.days.isNotEmpty)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Scheduled Sessions', Icons.calendar_month_outlined),
        const SizedBox(height: 12),
        if (assignments.isEmpty)
          const _EmptyHint(message: 'No recurring schedule set yet')
        else
          ...assignments.map((a) {
            final sched = a.schedule!;
            final daysLabel = sched.days.map((d) => dayNames[d]).join(', ');
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppCard(
                color: AppColors.primaryBlue.withValues(alpha: 0.03),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.repeat,
                          color: AppColors.primaryBlue, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(a.therapyType,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 14)),
                          if (a.therapistName != null)
                            Text(a.therapistName!,
                                style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12)),
                          const SizedBox(height: 2),
                          Text(
                            '$daysLabel  •  ${sched.fromTime} – ${sched.toTime}',
                            style: const TextStyle(
                                color: AppColors.primaryBlue, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  // ── Home plan tasks ───────────────────────────────────────────────────────
  Widget _buildHomePlan(BuildContext context, WidgetRef ref,
      AsyncValue<HomePlanModel?> plan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader("This Week's Home Plan", Icons.home_outlined),
        const SizedBox(height: 12),
        plan.when(
          loading: () => const LinearProgressIndicator(),
          error:   (e, _) => const _EmptyHint(message: 'No active home plan'),
          data:    (p) {
            if (p == null) return const _EmptyHint(message: 'No active home plan assigned yet');
            return Column(
              children: [
                if (p.morningTasks.isNotEmpty)
                  _TaskGroup(title: '🌅 Morning', tasks: p.morningTasks, plan: p),
                if (p.afternoonTasks.isNotEmpty)
                  _TaskGroup(title: '☀️ Afternoon', tasks: p.afternoonTasks, plan: p),
                if (p.eveningTasks.isNotEmpty)
                  _TaskGroup(title: '🌙 Evening', tasks: p.eveningTasks, plan: p),
              ],
            );
          },
        ),
      ],
    );
  }

  // ── Last session notes from therapist ────────────────────────────────────
  Widget _buildLastSessionNotes(
      BuildContext context, AsyncValue<List<SessionModel>> sessions) {
    final completed = sessions.valueOrNull
        ?.where((s) => s.status == 'completed' && s.notes != null)
        .toList()
      ?..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));

    final last = completed?.isNotEmpty == true ? completed!.first : null;
    final notes = last?.notes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader("Therapist's Last Notes", Icons.notes_outlined),
        const SizedBox(height: 12),
        if (notes == null)
          const _EmptyHint(message: 'No notes from therapist yet')
        else
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _MoodBadge(mood: notes.mood),
                    const SizedBox(width: 8),
                    Text(
                      last != null ? AppDateUtils.formatDate(last.scheduledAt) : '',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
                if (notes.activities.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: notes.activities
                        .map((a) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(a,
                                  style: const TextStyle(
                                      fontSize: 12, color: AppColors.primaryBlue)),
                            ))
                        .toList(),
                  ),
                ],
                if (notes.whatWorked != null) ...[
                  const SizedBox(height: 12),
                  _NoteRow(
                      icon: Icons.check_circle_outline,
                      color: AppColors.mintGreen,
                      label: 'What Worked',
                      text: notes.whatWorked!),
                ],
                if (notes.whatDidntWork != null) ...[
                  const SizedBox(height: 8),
                  _NoteRow(
                      icon: Icons.cancel_outlined,
                      color: AppColors.softCoral,
                      label: "What Didn't Work",
                      text: notes.whatDidntWork!),
                ],
                if (notes.homework != null) ...[
                  const SizedBox(height: 8),
                  _NoteRow(
                      icon: Icons.home_outlined,
                      color: AppColors.warmYellow,
                      label: 'Homework for You',
                      text: notes.homework!),
                ],
              ],
            ),
          ),
      ],
    );
  }

  // ── Diet chart ────────────────────────────────────────────────────────────
  Widget _buildDietPlan(
      BuildContext context, AsyncValue<DietPlanModel?> dietPlan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader("Diet Chart", Icons.restaurant_outlined),
        const SizedBox(height: 12),
        dietPlan.when(
          loading: () => const LinearProgressIndicator(),
          error:   (_, _) => const _EmptyHint(message: 'No active diet plan'),
          data: (p) {
            if (p == null) {
              return const _EmptyHint(message: 'No diet plan assigned yet');
            }
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.mintGreen.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.mintGreen.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.date_range_outlined,
                          color: AppColors.mintGreen, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        '${AppDateUtils.formatDate(p.startDate)} → ${AppDateUtils.formatDate(p.endDate)}',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.mintGreen),
                      ),
                      const Spacer(),
                      Text('${p.meals.length} meals',
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                ...p.meals.map((m) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.mintGreen.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(m.mealTime.toUpperCase(),
                                style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.mintGreen)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(m.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 13)),
                                if (m.ingredients.isNotEmpty)
                                  Text(m.ingredients.take(3).join(', '),
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textSecondary),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                          Text('${m.caloriesApprox} kcal',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    )),
              ],
            );
          },
        ),
      ],
    );
  }

  // ── Open alerts ───────────────────────────────────────────────────────────
  Widget _buildOpenAlerts(
      BuildContext context, AsyncValue<List<AlertModel>> alerts) {
    final open = alerts.valueOrNull?.where((a) => a.status == 'open').toList() ?? [];
    if (open.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Open Alerts', Icons.warning_amber_outlined,
            color: AppColors.softCoral),
        const SizedBox(height: 12),
        ...open.map((a) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.softCoral.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.softCoral.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: AppColors.softCoral, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(a.typeLabel,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.softCoral,
                                  fontSize: 13)),
                          Text(a.description,
                              style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.softCoral.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(a.severity.toUpperCase(),
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.softCoral)),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  // ── Accepted Goals (read-only) ────────────────────────────────────────────
  Widget _buildAcceptedGoals(BuildContext context,
      AsyncValue<List<GoalModel>> goals) {
    return goals.when(
      loading: () => const SizedBox.shrink(),
      error:   (_, _) => const SizedBox.shrink(),
      data: (list) {
        final accepted = list.where((g) => g.isAccepted || g.isCompleted).toList();
        if (accepted.isEmpty) return const SizedBox.shrink();
        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Therapy Goals',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              ...accepted.map((g) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(
                          g.isCompleted
                              ? Icons.check_circle
                              : Icons.radio_button_checked,
                          size: 14,
                          color: g.isCompleted
                              ? AppColors.mintGreen
                              : AppColors.primaryBlue,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(g.title,
                              style: const TextStyle(fontSize: 13)),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }

  // ── Published Reviews (read-only) ─────────────────────────────────────────
  Widget _buildPublishedReviews(BuildContext context,
      AsyncValue<List<ReviewModel>> reviews) {
    return reviews.when(
      loading: () => const SizedBox.shrink(),
      error:   (_, _) => const SizedBox.shrink(),
      data: (list) {
        final published = list.where((r) => r.isPublished).toList();
        if (published.isEmpty) return const SizedBox.shrink();
        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Progress Reviews',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              ...published.take(3).map((r) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(r.typeLabel,
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w600)),
                            const Spacer(),
                            Text(
                              '${r.periodStart.day}/${r.periodStart.month}/${r.periodStart.year}',
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(r.textObservations,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary)),
                        if (r.adminNotes != null && r.adminNotes!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Text('Note: ${r.adminNotes}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.primaryBlue,
                                    fontStyle: FontStyle.italic)),
                          ),
                        const Divider(height: 16),
                      ],
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }

  // ── Improvement Videos (parent_visible + upload) ─────────────────────────
  Widget _buildImprovementVideos(BuildContext context,
      AsyncValue<List<VideoItemModel>> videos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _sectionHeader('Videos', Icons.videocam_outlined)),
            _VideoUploadButton(childId: child.id),
          ],
        ),
        const SizedBox(height: 12),
        videos.when(
          loading: () => const LinearProgressIndicator(),
          error:   (_, _) => const _EmptyHint(message: 'Could not load videos'),
          data: (list) {
            if (list.isEmpty) {
              return const _EmptyHint(message: 'No videos yet — upload an observation video');
            }
            return Column(
              children: list.take(5).map((v) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Row(
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
                                Text(v.title,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500)),
                                Text(v.categoryLabel,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )).toList(),
            );
          },
        ),
      ],
    );
  }

  // ── Raise alert CTA ───────────────────────────────────────────────────────
  Widget _buildRaiseAlert(BuildContext context, WidgetRef ref) {
    return AppCard(
      color: AppColors.softCoral.withValues(alpha: 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.report_problem_outlined,
                  color: AppColors.softCoral, size: 20),
              SizedBox(width: 8),
              Text('Report a Concern',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: AppColors.softCoral)),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Let your therapist know about fever, regression, behavioral changes, or any health concern.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 14),
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

  Widget _sectionHeader(String title, IconData icon, {Color? color}) {
    final c = color ?? AppColors.primaryBlue;
    return Row(
      children: [
        Icon(icon, color: c, size: 20),
        const SizedBox(width: 8),
        Text(title,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
      ],
    );
  }
}

// ── Score tile ────────────────────────────────────────────────────────────────

class _ScoreTile extends StatelessWidget {
  final String label;
  final int score;
  final Color color;
  const _ScoreTile(this.label, this.score, this.color);

  @override
  Widget build(BuildContext context) {
    final pct = score / 10.0;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 12, color: color, fontWeight: FontWeight.w500)),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: color.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation(color),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text('$score/10',
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700, color: color)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Task group (by time of day) ───────────────────────────────────────────────

class _TaskGroup extends ConsumerStatefulWidget {
  final String title;
  final List<HomePlanTask> tasks;
  final HomePlanModel plan;
  const _TaskGroup({required this.title, required this.tasks, required this.plan});

  @override
  ConsumerState<_TaskGroup> createState() => _TaskGroupState();
}

class _TaskGroupState extends ConsumerState<_TaskGroup> {
  final _logged = <String>{};

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, top: 4),
          child: Text(widget.title,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.textSecondary)),
        ),
        ...widget.tasks.map((t) => _TaskCard(
              task: t,
              planId: widget.plan.id,
              logged: _logged.contains(t.taskId),
              onLogged: () => setState(() => _logged.add(t.taskId)),
            )),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _TaskCard extends ConsumerWidget {
  final HomePlanTask task;
  final String planId;
  final bool logged;
  final VoidCallback onLogged;
  const _TaskCard({required this.task, required this.planId, required this.logged, required this.onLogged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(taskLogProvider);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: logged
            ? AppColors.mintGreen.withValues(alpha: 0.06)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: logged
              ? AppColors.mintGreen.withValues(alpha: 0.3)
              : AppColors.divider,
        ),
      ),
      child: Row(
        children: [
          Text(task.icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title,
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: logged
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                        decoration: logged
                            ? TextDecoration.lineThrough
                            : null)),
                if (task.description.isNotEmpty)
                  Text(task.description,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                Text('${task.durationMin} min  •  ${task.frequency}',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          logged
              ? const Icon(Icons.check_circle, color: AppColors.mintGreen)
              : GestureDetector(
                  onTap: state.loading
                      ? null
                      : () async {
                          final ok = await ref
                              .read(taskLogProvider.notifier)
                              .logTask(planId: planId, taskId: task.taskId);
                          if (ok) onLogged();
                        },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.mintGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppColors.mintGreen.withValues(alpha: 0.4)),
                    ),
                    child: const Text('Done',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.mintGreen)),
                  ),
                ),
        ],
      ),
    );
  }
}

// ── Mood badge ────────────────────────────────────────────────────────────────

class _MoodBadge extends StatelessWidget {
  final String mood;
  const _MoodBadge({required this.mood});

  @override
  Widget build(BuildContext context) {
    final (emoji, color) = switch (mood) {
      'sad'     => ('😢', const Color(0xFF5B8DEF)),
      'calm'    => ('😐', AppColors.mintGreen),
      'happy'   => ('🙂', AppColors.warmYellow),
      'excited' => ('😄', const Color(0xFFFF9F43)),
      _         => ('😐', AppColors.textSecondary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(mood[0].toUpperCase() + mood.substring(1),
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

// ── Note row ──────────────────────────────────────────────────────────────────

class _NoteRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String text;
  const _NoteRow({required this.icon, required this.color, required this.label, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: color)),
              Text(text,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textPrimary)),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Video upload button ───────────────────────────────────────────────────────

class _VideoUploadButton extends ConsumerStatefulWidget {
  final String childId;
  const _VideoUploadButton({required this.childId});

  @override
  ConsumerState<_VideoUploadButton> createState() => _VideoUploadButtonState();
}

class _VideoUploadButtonState extends ConsumerState<_VideoUploadButton> {
  final _picker = ImagePicker();

  Future<void> _upload() async {
    final titleCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Upload Observation Video'),
        content: TextField(
          controller: titleCtrl,
          decoration: const InputDecoration(
            labelText: 'Video title',
            hintText: 'e.g. Morning activity observation',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Choose Video')),
        ],
      ),
    );

    if (confirmed != true || titleCtrl.text.trim().isEmpty) return;

    final picked = await _picker.pickVideo(source: ImageSource.gallery);
    if (picked == null) return;

    final ok = await ref.read(videoUploadProvider.notifier).upload(
      childId:  widget.childId,
      title:    titleCtrl.text.trim(),
      filePath: picked.path,
      mimeType: 'video/mp4',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? 'Video uploaded successfully' : 'Upload failed'),
          backgroundColor: ok ? AppColors.mintGreen : AppColors.softCoral,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(videoUploadProvider);
    return TextButton.icon(
      onPressed: state.loading ? null : _upload,
      icon: state.loading
          ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
          : const Icon(Icons.upload_outlined, size: 16),
      label: const Text('Upload'),
      style: TextButton.styleFrom(foregroundColor: AppColors.primaryBlue),
    );
  }
}

// ── Empty hint ────────────────────────────────────────────────────────────────

class _EmptyHint extends StatelessWidget {
  final String message;
  const _EmptyHint({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Text(message,
          style: const TextStyle(
              color: AppColors.textSecondary, fontSize: 13)),
    );
  }
}
