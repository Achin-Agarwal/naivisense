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
    final plan = ref.watch(parentActivePlanProvider(child.id));
    final dietPlan = ref.watch(parentDietPlanProvider(child.id));
    final alerts = ref.watch(parentAlertsProvider(child.id));
    final goals = ref.watch(parentGoalsProvider(child.id));
    final reviews = ref.watch(parentReviewsProvider(child.id));
    final videos = ref.watch(parentVideosProvider(child.id));

    // Top-level LayoutBuilder drives all breakpoint-aware sizing.
    return LayoutBuilder(
      builder: (context, constraints) {
        final media = MediaQuery.of(context);
        final ui = _ResponsiveUi.from(constraints.maxWidth, media);

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
                _buildAppBar(context, child, ui),
                SliverPadding(
                  padding: EdgeInsets.all(ui.pagePadding),
                  sliver: SliverToBoxAdapter(
                    child: _buildResponsiveContent(
                      context,
                      ref,
                      ui,
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
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildResponsiveContent(
    BuildContext context,
    WidgetRef ref,
    _ResponsiveUi ui,
    AsyncValue<List<SessionModel>> sessions,
    AsyncValue<HomePlanModel?> plan,
    AsyncValue<DietPlanModel?> dietPlan,
    AsyncValue<List<AlertModel>> alerts,
    AsyncValue<List<GoalModel>> goals,
    AsyncValue<List<ReviewModel>> reviews,
    AsyncValue<List<VideoItemModel>> videos,
  ) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDiagnosisRow(context, ui),
        SizedBox(height: ui.sectionGap),
        _buildProgressSection(context, sessions, ui),
        SizedBox(height: ui.sectionGap),
        _buildNextSession(context, sessions, ui),
        SizedBox(height: ui.sectionGap),
        _buildScheduledSessions(context, ui),
        SizedBox(height: ui.sectionGap),
        _buildHomePlan(context, ref, plan, ui),
        SizedBox(height: ui.sectionGap),
        _buildDietPlan(context, dietPlan, ui),
        SizedBox(height: ui.sectionGap),
        _buildLastSessionNotes(context, sessions, ui),
        SizedBox(height: ui.sectionGap),
        _buildOpenAlerts(context, alerts, ui),
        SizedBox(height: ui.sectionGap),
        _buildAcceptedGoals(context, goals, ui),
        SizedBox(height: ui.sectionGap),
        _buildPublishedReviews(context, reviews, ui),
        SizedBox(height: ui.sectionGap),
        _buildImprovementVideos(context, videos, ui),
        SizedBox(height: ui.sectionGap),
        _buildRaiseAlert(context, ref, ui),
        SizedBox(height: ui.bottomGap),
      ],
    );

    if (ui.isMobile) return content;

    // Keep larger screens readable and centered while preserving visual style.
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: content,
      ),
    );
  }

  // ── App bar with child hero ───────────────────────────────────────────────
  SliverAppBar _buildAppBar(
    BuildContext context,
    ChildModel child,
    _ResponsiveUi ui,
  ) {
    return SliverAppBar(
      expandedHeight: ui.appBarExpandedHeight,
      pinned: true,
      backgroundColor: const Color(0xFF2AAD7E),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white, size: ui.iconMd),
        onPressed: () => context.pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(gradient: AppColors.parentGradient),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                ui.pagePadding + 4,
                ui.pagePadding + 30,
                ui.pagePadding + 4,
                ui.pagePadding,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: ui.avatarRadius,
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                    child: Text(
                      child.name[0].toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: ui.avatarText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(width: ui.itemGap),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          child.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: ui.heroTitle,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${child.ageYears} years old',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: ui.bodySm,
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
        title: Text(
          child.name,
          style: TextStyle(color: Colors.white, fontSize: ui.titleSm),
        ),
        titlePadding: EdgeInsets.only(
          left: ui.pagePadding + 40,
          bottom: ui.pagePadding,
        ),
      ),
    );
  }

  // ── Diagnosis row ─────────────────────────────────────────────────────────
  Widget _buildDiagnosisRow(BuildContext context, _ResponsiveUi ui) {
    final (severityLabel, severityColor) = switch (child.severity) {
      'mild' => ('Mild', AppColors.mintGreen),
      'moderate' => ('Moderate', AppColors.warmYellow),
      'severe' => ('Severe', AppColors.softCoral),
      _ => ('—', AppColors.textSecondary),
    };
    return Wrap(
      spacing: ui.wrapSpacing,
      runSpacing: ui.wrapSpacing,
      children: [
        ...child.diagnosis.map(
          (d) => _chip(context, d, AppColors.primaryBlue, ui),
        ),
        _chip(context, severityLabel, severityColor, ui),
      ],
    );
  }

  Widget _chip(
    BuildContext context,
    String label,
    Color color,
    _ResponsiveUi ui,
  ) => Container(
    padding: EdgeInsets.symmetric(
      horizontal: ui.chipHorizontal,
      vertical: ui.chipVertical,
    ),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      border: Border.all(color: color.withValues(alpha: 0.3)),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontSize: ui.bodyXs,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    ),
  );

  // ── Progress from last session ────────────────────────────────────────────
  Widget _buildProgressSection(
    BuildContext context,
    AsyncValue<List<SessionModel>> sessions,
    _ResponsiveUi ui,
  ) {
    final completed =
        sessions.valueOrNull
            ?.where((s) => s.status == 'completed' && s.notes != null)
            .toList()
          ?..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));

    final latest = completed?.isNotEmpty == true ? completed!.first : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          context,
          'Progress (Last Session)',
          Icons.show_chart_outlined,
          ui,
        ),
        SizedBox(height: ui.itemGap),
        if (latest?.notes == null)
          _EmptyHint(message: 'No session notes yet', ui: ui)
        else
          GridView.count(
            // Responsive card columns prevent clipping on narrow layouts.
            crossAxisCount: ui.scoreGridCount,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: ui.gridGap,
            crossAxisSpacing: ui.gridGap,
            childAspectRatio: ui.scoreTileAspectRatio,
            children: [
              _ScoreTile(
                'Attention',
                latest!.notes!.attentionScore,
                AppColors.primaryBlue,
                ui,
              ),
              _ScoreTile(
                'Communication',
                latest.notes!.communicationScore,
                AppColors.mintGreen,
                ui,
              ),
              _ScoreTile(
                'Motor Skills',
                latest.notes!.motorScore,
                AppColors.warmYellow,
                ui,
              ),
              _ScoreTile(
                'Social',
                latest.notes!.behaviorScore,
                const Color(0xFFAB7AE0),
                ui,
              ),
            ],
          ),
        if (latest != null) ...[
          Padding(
            padding: EdgeInsets.only(top: ui.smallGap),
            child: Text(
              'From session on ${AppDateUtils.formatDate(latest.scheduledAt)}',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: ui.bodyXs,
              ),
            ),
          ),
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
              icon: Icon(Icons.bar_chart_outlined, size: ui.iconSm),
              label: const Text('View Full Report'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.mintGreen,
                textStyle: TextStyle(fontSize: ui.bodySm),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ── Next session ──────────────────────────────────────────────────────────
  Widget _buildNextSession(
    BuildContext context,
    AsyncValue<List<SessionModel>> sessions,
    _ResponsiveUi ui,
  ) {
    final upcoming =
        sessions.valueOrNull
            ?.where(
              (s) =>
                  s.status == 'scheduled' &&
                  s.scheduledAt.isAfter(DateTime.now()),
            )
            .toList()
          ?..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

    final next = upcoming?.isNotEmpty == true ? upcoming!.first : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(context, 'Next Session', Icons.event_outlined, ui),
        SizedBox(height: ui.itemGap),
        if (next == null)
          _EmptyHint(message: 'No upcoming sessions scheduled', ui: ui)
        else
          AppCard(
            color: AppColors.primaryBlue.withValues(alpha: 0.04),
            child: LayoutBuilder(
              builder: (context, c) {
                final compact = c.maxWidth < 360;
                return Wrap(
                  spacing: ui.itemGap,
                  runSpacing: ui.itemGap,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(ui.cardInnerPadding),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(ui.radiusMd),
                      ),
                      child: Icon(
                        Icons.event,
                        color: AppColors.primaryBlue,
                        size: ui.iconLg,
                      ),
                    ),
                    SizedBox(
                      width: compact
                          ? c.maxWidth - (ui.cardInnerPadding * 2)
                          : c.maxWidth * 0.5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            next.typeLabel,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: ui.titleSm,
                            ),
                          ),
                          SizedBox(height: ui.tinyGap),
                          Text(
                            '${AppDateUtils.formatDate(next.scheduledAt)}  •  ${AppDateUtils.formatTime(next.scheduledAt)}',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: ui.bodySm,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ui.chipHorizontal,
                        vertical: ui.chipVertical,
                      ),
                      decoration: BoxDecoration(
                        color: next.mode == 'online'
                            ? AppColors.primaryBlue.withValues(alpha: 0.1)
                            : AppColors.mintGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(ui.radiusMd),
                      ),
                      child: Text(
                        next.mode == 'online' ? 'Online' : 'In-Person',
                        style: TextStyle(
                          fontSize: ui.bodyXs,
                          fontWeight: FontWeight.w600,
                          color: next.mode == 'online'
                              ? AppColors.primaryBlue
                              : AppColors.mintGreen,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
      ],
    );
  }

  // ── Scheduled Sessions ────────────────────────────────────────────────────
  Widget _buildScheduledSessions(BuildContext context, _ResponsiveUi ui) {
    const dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    final assignments = child.therapists
        .where((a) => a.schedule != null && a.schedule!.days.isNotEmpty)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          context,
          'Scheduled Sessions',
          Icons.calendar_month_outlined,
          ui,
        ),
        SizedBox(height: ui.itemGap),
        if (assignments.isEmpty)
          _EmptyHint(message: 'No recurring schedule set yet', ui: ui)
        else
          ...assignments.map((a) {
            final sched = a.schedule!;
            final daysLabel = sched.days.map((d) => dayNames[d]).join(', ');
            return Padding(
              padding: EdgeInsets.only(bottom: ui.smallGap),
              child: AppCard(
                color: AppColors.primaryBlue.withValues(alpha: 0.03),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(ui.cardInnerPadding - 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(ui.radiusSm),
                      ),
                      child: Icon(
                        Icons.repeat,
                        color: AppColors.primaryBlue,
                        size: ui.iconMd,
                      ),
                    ),
                    SizedBox(width: ui.itemGap),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            a.therapyType,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: ui.bodyMd,
                            ),
                          ),
                          if (a.therapistName != null)
                            Text(
                              a.therapistName!,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: ui.bodyXs,
                              ),
                            ),
                          SizedBox(height: ui.tinyGap),
                          Text(
                            '$daysLabel  •  ${sched.fromTime} – ${sched.toTime}',
                            style: TextStyle(
                              color: AppColors.primaryBlue,
                              fontSize: ui.bodyXs,
                            ),
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
  Widget _buildHomePlan(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<HomePlanModel?> plan,
    _ResponsiveUi ui,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          context,
          "This Week's Home Plan",
          Icons.home_outlined,
          ui,
        ),
        SizedBox(height: ui.itemGap),
        plan.when(
          loading: () => const LinearProgressIndicator(),
          error: (e, _) => _EmptyHint(message: 'No active home plan', ui: ui),
          data: (p) {
            if (p == null)
              return _EmptyHint(
                message: 'No active home plan assigned yet',
                ui: ui,
              );
            return Column(
              children: [
                if (p.morningTasks.isNotEmpty)
                  _TaskGroup(
                    title: '🌅 Morning',
                    tasks: p.morningTasks,
                    plan: p,
                    ui: ui,
                  ),
                if (p.afternoonTasks.isNotEmpty)
                  _TaskGroup(
                    title: '☀️ Afternoon',
                    tasks: p.afternoonTasks,
                    plan: p,
                    ui: ui,
                  ),
                if (p.eveningTasks.isNotEmpty)
                  _TaskGroup(
                    title: '🌙 Evening',
                    tasks: p.eveningTasks,
                    plan: p,
                    ui: ui,
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  // ── Last session notes from therapist ────────────────────────────────────
  Widget _buildLastSessionNotes(
    BuildContext context,
    AsyncValue<List<SessionModel>> sessions,
    _ResponsiveUi ui,
  ) {
    final completed =
        sessions.valueOrNull
            ?.where((s) => s.status == 'completed' && s.notes != null)
            .toList()
          ?..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));

    final last = completed?.isNotEmpty == true ? completed!.first : null;
    final notes = last?.notes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          context,
          "Therapist's Last Notes",
          Icons.notes_outlined,
          ui,
        ),
        SizedBox(height: ui.itemGap),
        if (notes == null)
          _EmptyHint(message: 'No notes from therapist yet', ui: ui)
        else
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _MoodBadge(mood: notes.mood, ui: ui),
                    SizedBox(width: ui.smallGap),
                    Text(
                      last != null
                          ? AppDateUtils.formatDate(last.scheduledAt)
                          : '',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: ui.bodyXs,
                      ),
                    ),
                  ],
                ),
                if (notes.activities.isNotEmpty) ...[
                  SizedBox(height: ui.itemGap),
                  Wrap(
                    spacing: ui.wrapSpacing,
                    runSpacing: ui.wrapSpacing,
                    children: notes.activities
                        .map(
                          (a) => Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: ui.chipHorizontal,
                              vertical: ui.chipVertical,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue.withValues(
                                alpha: 0.08,
                              ),
                              borderRadius: BorderRadius.circular(ui.radiusMd),
                            ),
                            child: Text(
                              a,
                              style: TextStyle(
                                fontSize: ui.bodyXs,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
                if (notes.whatWorked != null) ...[
                  SizedBox(height: ui.itemGap),
                  _NoteRow(
                    icon: Icons.check_circle_outline,
                    color: AppColors.mintGreen,
                    label: 'What Worked',
                    text: notes.whatWorked!,
                    ui: ui,
                  ),
                ],
                if (notes.whatDidntWork != null) ...[
                  SizedBox(height: ui.smallGap),
                  _NoteRow(
                    icon: Icons.cancel_outlined,
                    color: AppColors.softCoral,
                    label: "What Didn't Work",
                    text: notes.whatDidntWork!,
                    ui: ui,
                  ),
                ],
                if (notes.homework != null) ...[
                  SizedBox(height: ui.smallGap),
                  _NoteRow(
                    icon: Icons.home_outlined,
                    color: AppColors.warmYellow,
                    label: 'Homework for You',
                    text: notes.homework!,
                    ui: ui,
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }

  // ── Diet chart ────────────────────────────────────────────────────────────
  Widget _buildDietPlan(
    BuildContext context,
    AsyncValue<DietPlanModel?> dietPlan,
    _ResponsiveUi ui,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(context, "Diet Chart", Icons.restaurant_outlined, ui),
        SizedBox(height: ui.itemGap),
        dietPlan.when(
          loading: () => const LinearProgressIndicator(),
          error: (_, _) => _EmptyHint(message: 'No active diet plan', ui: ui),
          data: (p) {
            if (p == null) {
              return _EmptyHint(message: 'No diet plan assigned yet', ui: ui);
            }
            return Column(
              children: [
                Container(
                  padding: EdgeInsets.all(ui.cardInnerPadding),
                  decoration: BoxDecoration(
                    color: AppColors.mintGreen.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(ui.radiusMd),
                    border: Border.all(
                      color: AppColors.mintGreen.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.date_range_outlined,
                        color: AppColors.mintGreen,
                        size: ui.iconSm,
                      ),
                      SizedBox(width: ui.smallGap),
                      Expanded(
                        child: Text(
                          '${AppDateUtils.formatDate(p.startDate)} → ${AppDateUtils.formatDate(p.endDate)}',
                          style: TextStyle(
                            fontSize: ui.bodyXs,
                            color: AppColors.mintGreen,
                          ),
                        ),
                      ),
                      Text(
                        '${p.meals.length} meals',
                        style: TextStyle(
                          fontSize: ui.bodyXs,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: ui.smallGap),
                ...p.meals.map(
                  (m) => Container(
                    margin: EdgeInsets.only(bottom: ui.smallGap),
                    padding: EdgeInsets.symmetric(
                      horizontal: ui.cardInnerPadding + 2,
                      vertical: ui.cardInnerPadding,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(ui.radiusMd),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Wrap(
                      spacing: ui.itemGap,
                      runSpacing: ui.smallGap,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: ui.chipHorizontal - 2,
                            vertical: ui.chipVertical - 1,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.mintGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(ui.radiusSm),
                          ),
                          child: Text(
                            m.mealTime.toUpperCase(),
                            style: TextStyle(
                              fontSize: ui.caption,
                              fontWeight: FontWeight.w700,
                              color: AppColors.mintGreen,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: ui.isMobile
                              ? MediaQuery.sizeOf(context).width * 0.45
                              : 260,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                m.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: ui.bodySm,
                                ),
                              ),
                              if (m.ingredients.isNotEmpty)
                                Text(
                                  m.ingredients.take(3).join(', '),
                                  style: TextStyle(
                                    fontSize: ui.caption,
                                    color: AppColors.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                        Text(
                          '${m.caloriesApprox} kcal',
                          style: TextStyle(
                            fontSize: ui.bodyXs,
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
      ],
    );
  }

  // ── Open alerts ───────────────────────────────────────────────────────────
  Widget _buildOpenAlerts(
    BuildContext context,
    AsyncValue<List<AlertModel>> alerts,
    _ResponsiveUi ui,
  ) {
    final open =
        alerts.valueOrNull?.where((a) => a.status == 'open').toList() ?? [];
    if (open.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          context,
          'Open Alerts',
          Icons.warning_amber_outlined,
          ui,
          color: AppColors.softCoral,
        ),
        SizedBox(height: ui.itemGap),
        ...open.map(
          (a) => Padding(
            padding: EdgeInsets.only(bottom: ui.smallGap),
            child: Container(
              padding: EdgeInsets.all(ui.cardInnerPadding + 2),
              decoration: BoxDecoration(
                color: AppColors.softCoral.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(ui.radiusMd),
                border: Border.all(
                  color: AppColors.softCoral.withValues(alpha: 0.3),
                ),
              ),
              child: Wrap(
                spacing: ui.itemGap,
                runSpacing: ui.smallGap,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.softCoral,
                    size: ui.iconMd,
                  ),
                  SizedBox(
                    width: ui.isMobile
                        ? MediaQuery.sizeOf(context).width * 0.55
                        : 420,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a.typeLabel,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.softCoral,
                            fontSize: ui.bodySm,
                          ),
                        ),
                        Text(
                          a.description,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: ui.bodyXs,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: ui.chipHorizontal - 2,
                      vertical: ui.chipVertical - 1,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.softCoral.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(ui.radiusSm),
                    ),
                    child: Text(
                      a.severity.toUpperCase(),
                      style: TextStyle(
                        fontSize: ui.caption,
                        fontWeight: FontWeight.w700,
                        color: AppColors.softCoral,
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

  // ── Accepted Goals (read-only) ────────────────────────────────────────────
  Widget _buildAcceptedGoals(
    BuildContext context,
    AsyncValue<List<GoalModel>> goals,
    _ResponsiveUi ui,
  ) {
    return goals.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (list) {
        final accepted = list
            .where((g) => g.isAccepted || g.isCompleted)
            .toList();
        if (accepted.isEmpty) return const SizedBox.shrink();
        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Therapy Goals',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: ui.titleSm,
                ),
              ),
              SizedBox(height: ui.itemGap),
              ...accepted.map(
                (g) => Padding(
                  padding: EdgeInsets.symmetric(vertical: ui.tinyGap),
                  child: Row(
                    children: [
                      Icon(
                        g.isCompleted
                            ? Icons.check_circle
                            : Icons.radio_button_checked,
                        size: ui.iconSm,
                        color: g.isCompleted
                            ? AppColors.mintGreen
                            : AppColors.primaryBlue,
                      ),
                      SizedBox(width: ui.smallGap),
                      Expanded(
                        child: Text(
                          g.title,
                          style: TextStyle(fontSize: ui.bodySm),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Published Reviews (read-only) ─────────────────────────────────────────
  Widget _buildPublishedReviews(
    BuildContext context,
    AsyncValue<List<ReviewModel>> reviews,
    _ResponsiveUi ui,
  ) {
    return reviews.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (list) {
        final published = list.where((r) => r.isPublished).toList();
        if (published.isEmpty) return const SizedBox.shrink();
        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Progress Reviews',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: ui.titleSm,
                ),
              ),
              SizedBox(height: ui.itemGap),
              ...published
                  .take(3)
                  .map(
                    (r) => Padding(
                      padding: EdgeInsets.symmetric(vertical: ui.smallGap),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                r.typeLabel,
                                style: TextStyle(
                                  fontSize: ui.bodyXs,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${r.periodStart.day}/${r.periodStart.month}/${r.periodStart.year}',
                                style: TextStyle(
                                  fontSize: ui.caption,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: ui.tinyGap),
                          Text(
                            r.textObservations,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: ui.bodyXs,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (r.adminNotes != null && r.adminNotes!.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.only(top: ui.tinyGap),
                              child: Text(
                                'Note: ${r.adminNotes}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: ui.caption,
                                  color: AppColors.primaryBlue,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          Divider(height: ui.dividerHeight),
                        ],
                      ),
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }

  // ── Improvement Videos (parent_visible + upload) ─────────────────────────
  Widget _buildImprovementVideos(
    BuildContext context,
    AsyncValue<List<VideoItemModel>> videos,
    _ResponsiveUi ui,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _sectionHeader(
                context,
                'Videos',
                Icons.videocam_outlined,
                ui,
              ),
            ),
            _VideoUploadButton(childId: child.id),
          ],
        ),
        SizedBox(height: ui.itemGap),
        videos.when(
          loading: () => const LinearProgressIndicator(),
          error: (_, _) => _EmptyHint(message: 'Could not load videos', ui: ui),
          data: (list) {
            if (list.isEmpty) {
              return _EmptyHint(
                message: 'No videos yet — upload an observation video',
                ui: ui,
              );
            }
            final items = list.take(6).toList();
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: ui.videoGridCount,
                mainAxisSpacing: ui.gridGap,
                crossAxisSpacing: ui.gridGap,
                childAspectRatio: ui.videoTileAspectRatio,
              ),
              itemBuilder: (context, index) {
                final v = items[index];
                return Container(
                  padding: EdgeInsets.all(ui.cardInnerPadding),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(ui.radiusMd),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: ui.videoThumb,
                        height: ui.videoThumb,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(ui.radiusSm),
                        ),
                        child: Icon(
                          Icons.play_circle_outline,
                          color: AppColors.primaryBlue,
                          size: ui.iconLg,
                        ),
                      ),
                      SizedBox(width: ui.itemGap),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              v.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: ui.bodySm,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              v.categoryLabel,
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
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  // ── Raise alert CTA ───────────────────────────────────────────────────────
  Widget _buildRaiseAlert(
    BuildContext context,
    WidgetRef ref,
    _ResponsiveUi ui,
  ) {
    return AppCard(
      color: AppColors.softCoral.withValues(alpha: 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.report_problem_outlined,
                color: AppColors.softCoral,
                size: ui.iconMd,
              ),
              SizedBox(width: ui.smallGap),
              Flexible(
                child: Text(
                  'Report a Concern',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: ui.titleSm,
                    color: AppColors.softCoral,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ui.tinyGap + 2),
          Text(
            'Let your therapist know about fever, regression, behavioral changes, or any health concern.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: ui.bodySm,
            ),
          ),
          SizedBox(height: ui.cardInnerPadding),
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

  Widget _sectionHeader(
    BuildContext context,
    String title,
    IconData icon,
    _ResponsiveUi ui, {
    Color? color,
  }) {
    final c = color ?? AppColors.primaryBlue;
    return Row(
      children: [
        Icon(icon, color: c, size: ui.iconMd),
        SizedBox(width: ui.smallGap),
        Text(
          title,
          style: TextStyle(
            fontSize: ui.titleMd,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

// ── Responsive UI config ──────────────────────────────────────────────────────

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

  double _scale(double value, {double min = 0.88, double max = 1.25}) {
    final t = ((width - 360) / (1280 - 360)).clamp(0.0, 1.0);
    final factor = min + (max - min) * t;
    return value * factor;
  }

  double get pagePadding => _scale(16, min: 0.9, max: 1.35);
  double get sectionGap => _scale(20, min: 0.9, max: 1.15);
  double get gridGap => _scale(10, min: 0.9, max: 1.15);
  double get itemGap => _scale(12, min: 0.9, max: 1.15);
  double get smallGap => _scale(8, min: 0.9, max: 1.15);
  double get tinyGap => _scale(4, min: 0.9, max: 1.15);
  double get bottomGap => _scale(32, min: 0.9, max: 1.15);
  double get cardInnerPadding => _scale(12, min: 0.92, max: 1.2);

  double get titleMd => _scale(16, min: 0.92, max: 1.25);
  double get titleSm => _scale(15, min: 0.9, max: 1.2);
  double get bodyMd => _scale(14, min: 0.92, max: 1.18);
  double get bodySm => _scale(13, min: 0.92, max: 1.18);
  double get bodyXs => _scale(12, min: 0.92, max: 1.15);
  double get caption => _scale(10, min: 0.95, max: 1.12);

  double get iconLg => _scale(22, min: 0.9, max: 1.25);
  double get iconMd => _scale(20, min: 0.9, max: 1.2);
  double get iconSm => _scale(14, min: 0.92, max: 1.15);
  double get avatarRadius => _scale(36, min: 0.8, max: 1.2);
  double get avatarText => _scale(30, min: 0.84, max: 1.2);
  double get heroTitle => _scale(22, min: 0.85, max: 1.2);
  double get appBarExpandedHeight => _scale(180, min: 0.85, max: 1.2);

  double get chipHorizontal => _scale(10, min: 0.9, max: 1.2);
  double get chipVertical => _scale(5, min: 0.9, max: 1.2);
  double get wrapSpacing => _scale(8, min: 0.9, max: 1.2);
  double get radiusSm => _scale(8, min: 0.92, max: 1.15);
  double get radiusMd => _scale(12, min: 0.92, max: 1.15);

  int get scoreGridCount => isDesktop ? 4 : (isTablet ? 2 : 1);
  double get scoreTileAspectRatio => isMobile ? 1.9 : 1.7;
  int get videoGridCount => isDesktop ? 3 : (isTablet ? 2 : 1);
  double get videoTileAspectRatio => isDesktop ? 3.0 : (isTablet ? 2.7 : 3.2);
  double get videoThumb => _scale(40, min: 0.92, max: 1.15);
  double get dividerHeight => _scale(16, min: 0.9, max: 1.1);
  double get maxFormWidth => isDesktop ? 560 : (isTablet ? 480 : 420);
}

// ── Score tile ────────────────────────────────────────────────────────────────

class _ScoreTile extends StatelessWidget {
  final String label;
  final int score;
  final Color color;
  final _ResponsiveUi ui;
  const _ScoreTile(this.label, this.score, this.color, this.ui);

  @override
  Widget build(BuildContext context) {
    final pct = score / 10.0;
    return Container(
      padding: EdgeInsets.all(ui.cardInnerPadding + 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(ui.radiusMd + 2),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: ui.bodyXs,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(ui.tinyGap),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: color.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation(color),
                    minHeight: ui.smallGap - 2,
                  ),
                ),
              ),
              SizedBox(width: ui.smallGap),
              Text(
                '$score/10',
                style: TextStyle(
                  fontSize: ui.bodySm,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Task group (by time of day) ─────────────────────────────────────────────

class _TaskGroup extends ConsumerStatefulWidget {
  final String title;
  final List<HomePlanTask> tasks;
  final HomePlanModel plan;
  final _ResponsiveUi ui;
  const _TaskGroup({
    required this.title,
    required this.tasks,
    required this.plan,
    required this.ui,
  });

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
          padding: EdgeInsets.only(
            bottom: widget.ui.smallGap,
            top: widget.ui.tinyGap,
          ),
          child: Text(
            widget.title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: widget.ui.bodyMd,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        ...widget.tasks.map(
          (t) => _TaskCard(
            task: t,
            planId: widget.plan.id,
            logged: _logged.contains(t.taskId),
            onLogged: () => setState(() => _logged.add(t.taskId)),
            ui: widget.ui,
          ),
        ),
        SizedBox(height: widget.ui.smallGap),
      ],
    );
  }
}

class _TaskCard extends ConsumerWidget {
  final HomePlanTask task;
  final String planId;
  final bool logged;
  final VoidCallback onLogged;
  final _ResponsiveUi ui;
  const _TaskCard({
    required this.task,
    required this.planId,
    required this.logged,
    required this.onLogged,
    required this.ui,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(taskLogProvider);

    return Container(
      margin: EdgeInsets.only(bottom: ui.smallGap),
      padding: EdgeInsets.all(ui.cardInnerPadding + 2),
      decoration: BoxDecoration(
        color: logged
            ? AppColors.mintGreen.withValues(alpha: 0.06)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(ui.radiusMd),
        border: Border.all(
          color: logged
              ? AppColors.mintGreen.withValues(alpha: 0.3)
              : AppColors.divider,
        ),
      ),
      child: Row(
        children: [
          Text(task.icon, style: TextStyle(fontSize: ui.iconLg)),
          SizedBox(width: ui.itemGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: ui.bodyMd,
                    color: logged
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                    decoration: logged ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (task.description.isNotEmpty)
                  Text(
                    task.description,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: ui.bodyXs,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                Text(
                  '${task.durationMin} min  •  ${task.frequency}',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: ui.caption,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: ui.smallGap),
          logged
              ? Icon(
                  Icons.check_circle,
                  color: AppColors.mintGreen,
                  size: ui.iconMd,
                )
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
                    padding: EdgeInsets.symmetric(
                      horizontal: ui.chipHorizontal + 2,
                      vertical: ui.chipVertical,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.mintGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(ui.radiusSm + 2),
                      border: Border.all(
                        color: AppColors.mintGreen.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      'Done',
                      style: TextStyle(
                        fontSize: ui.bodyXs,
                        fontWeight: FontWeight.w600,
                        color: AppColors.mintGreen,
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

// ── Mood badge ───────────────────────────────────────────────────────────────

class _MoodBadge extends StatelessWidget {
  final String mood;
  final _ResponsiveUi ui;
  const _MoodBadge({required this.mood, required this.ui});

  @override
  Widget build(BuildContext context) {
    final (emoji, color) = switch (mood) {
      'sad' => ('😢', const Color(0xFF5B8DEF)),
      'calm' => ('😐', AppColors.mintGreen),
      'happy' => ('🙂', AppColors.warmYellow),
      'excited' => ('😄', const Color(0xFFFF9F43)),
      _ => ('😐', AppColors.textSecondary),
    };
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ui.chipHorizontal,
        vertical: ui.chipVertical - 1,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(ui.radiusMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: TextStyle(fontSize: ui.bodyMd)),
          SizedBox(width: ui.tinyGap),
          Text(
            mood[0].toUpperCase() + mood.substring(1),
            style: TextStyle(
              fontSize: ui.bodyXs,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Note row ─────────────────────────────────────────────────────────────────

class _NoteRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String text;
  final _ResponsiveUi ui;
  const _NoteRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.text,
    required this.ui,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: ui.iconSm + 2),
        SizedBox(width: ui.smallGap),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: ui.bodyXs,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              Text(
                text,
                style: TextStyle(
                  fontSize: ui.bodySm,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Video upload button ──────────────────────────────────────────────────────

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
    final media = MediaQuery.of(context);
    final ui = _ResponsiveUi.from(media.size.width, media);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final viewInsets = MediaQuery.viewInsetsOf(ctx);
        return AnimatedPadding(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(bottom: viewInsets.bottom),
          child: Center(
            // Keep form fields centered and width-limited on larger screens.
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: ui.maxFormWidth),
              child: AlertDialog(
                title: const Text('Upload Observation Video'),
                content: SingleChildScrollView(
                  child: TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Video title',
                      hintText: 'e.g. Morning activity observation',
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Choose Video'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (confirmed != true || titleCtrl.text.trim().isEmpty) return;

    final picked = await _picker.pickVideo(source: ImageSource.gallery);
    if (picked == null) return;

    final ok = await ref
        .read(videoUploadProvider.notifier)
        .upload(
          childId: widget.childId,
          title: titleCtrl.text.trim(),
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
    final media = MediaQuery.of(context);
    final ui = _ResponsiveUi.from(media.size.width, media);
    return TextButton.icon(
      onPressed: state.loading ? null : _upload,
      icon: state.loading
          ? SizedBox(
              width: ui.iconSm,
              height: ui.iconSm,
              child: const CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(Icons.upload_outlined, size: ui.iconMd),
      label: Text('Upload', style: TextStyle(fontSize: ui.bodySm)),
      style: TextButton.styleFrom(foregroundColor: AppColors.primaryBlue),
    );
  }
}

// ── Empty hint ───────────────────────────────────────────────────────────────

class _EmptyHint extends StatelessWidget {
  final String message;
  final _ResponsiveUi ui;
  const _EmptyHint({required this.message, required this.ui});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ui.pagePadding),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(ui.radiusMd),
        border: Border.all(color: AppColors.divider),
      ),
      child: Text(
        message,
        style: TextStyle(color: AppColors.textSecondary, fontSize: ui.bodySm),
      ),
    );
  }
}
