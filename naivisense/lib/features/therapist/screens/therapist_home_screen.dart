import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/child.dart';
import '../../../data/models/session.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/stat_tile.dart';
import '../../../shared/widgets/state_widgets.dart' as sw;
import '../providers/therapist_provider.dart';
import 'session_notes_screen.dart';
import 'create_session_screen.dart';
import 'therapist_child_profile_screen.dart';

class TherapistHomeScreen extends ConsumerWidget {
  const TherapistHomeScreen({super.key});

  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).valueOrNull?.user;
    final children = ref.watch(therapistChildrenProvider);
    final sessions = ref.watch(therapistSessionsProvider);
    final pending = ref.watch(therapistPendingVerificationsProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final isMobile = width < mobileBreakpoint;
        final isTablet = width >= mobileBreakpoint && width < tabletBreakpoint;
        final isDesktop = width >= tabletBreakpoint;

        final horizontalPadding = isMobile
            ? 16.0
            : isTablet
            ? 24.0
            : 32.0;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(
              'Hi, ${user?.name.split(' ').first ?? 'Therapist'}',
              style: TextStyle(
                fontSize: isDesktop
                    ? 24
                    : isTablet
                    ? 22
                    : 18,
              ),
            ),
            backgroundColor: AppColors.surface,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => ref.read(authProvider.notifier).logout(),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(therapistChildrenProvider);
              ref.invalidate(therapistSessionsProvider);
              ref.invalidate(therapistPendingVerificationsProvider);
            },
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.all(horizontalPadding),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _buildStats(
                            context,
                            children,
                            sessions,
                            pending,
                            isMobile,
                            isTablet,
                            isDesktop,
                          ),

                          SizedBox(height: isMobile ? 24 : 32),

                          _buildTodaySessions(context, ref, sessions, children),

                          SizedBox(height: isMobile ? 24 : 32),

                          _buildScheduledSessions(context, ref, children),

                          SizedBox(height: isMobile ? 24 : 32),

                          _buildChildrenList(context, children),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showCreateSession(context, ref),
            icon: const Icon(Icons.add),
            label: Text(isMobile ? 'New' : 'New Session'),
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
          ),
        );
      },
    );
  }

  Widget _buildStats(
    BuildContext context,
    AsyncValue children,
    AsyncValue sessions,
    AsyncValue pending,
    bool isMobile,
    bool isTablet,
    bool isDesktop,
  ) {
    final childCount = children.valueOrNull?.length ?? 0;
    final sessionCount = sessions.valueOrNull?.length ?? 0;
    final pendingCount = pending.valueOrNull?.length ?? 0;

    final crossAxisCount = isDesktop
        ? 3
        : isTablet
        ? 3
        : 1;

    final double childAspectRatio = isDesktop
        ? 1.1
        : isTablet
        ? 1
        : 2.8;

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: childAspectRatio,
      children: [
        StatTile(
          label: 'Children',
          value: '$childCount',
          icon: Icons.child_care,
          iconColor: AppColors.primaryBlue,
        ),

        StatTile(
          label: 'Sessions',
          value: '$sessionCount',
          icon: Icons.event_note,
          iconColor: AppColors.mintGreen,
        ),

        StatTile(
          label: 'Pending',
          value: '$pendingCount',
          icon: Icons.pending_actions,
          iconColor: AppColors.warmYellow,
        ),
      ],
    );
  }

  Widget _buildTodaySessions(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<SessionModel>> sessions,
    AsyncValue<List<ChildModel>> children,
  ) {
    final width = MediaQuery.of(context).size.width;

    final isMobile = width < 600;
    final isTablet = width >= 600 && width < 1024;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Today's Sessions",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontSize: isMobile
                ? 20
                : isTablet
                ? 22
                : 24,
          ),
        ),

        const SizedBox(height: 12),

        sessions.when(
          loading: () => const sw.LoadingWidget(),

          error: (e, _) => sw.ErrorWidget(message: e.toString()),

          data: (list) {
            final today = list.where((s) {
              final d = s.scheduledAt;
              final n = DateTime.now();

              return d.year == n.year && d.month == n.month && d.day == n.day;
            }).toList();

            if (today.isEmpty) {
              return const sw.EmptyWidget(
                message: 'No sessions today',
                icon: Icons.event_available,
              );
            }

            final childMap = {
              for (final c in (children.valueOrNull ?? [])) c.id: c.name,
            };

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: today.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),

              itemBuilder: (_, i) {
                final s = today[i];

                final childName = childMap[s.childId] ?? 'Unknown Child';

                return _SessionCard(
                  session: s,
                  childName: childName,
                  onNotes: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          SessionNotesScreen(session: s, childName: childName),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildScheduledSessions(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<ChildModel>> children,
  ) {
    final width = MediaQuery.of(context).size.width;

    final isMobile = width < 600;
    final isTablet = width >= 600 && width < 1024;

    final user = ref.watch(authProvider).valueOrNull?.user;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Scheduled Sessions',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontSize: isMobile
                ? 20
                : isTablet
                ? 22
                : 24,
          ),
        ),

        const SizedBox(height: 12),

        children.when(
          loading: () => const sw.LoadingWidget(),

          error: (e, _) => sw.ErrorWidget(message: e.toString()),

          data: (list) {
            final slots = <_ScheduleSlotRow>[];

            for (final child in list) {
              for (final assignment in child.therapists) {
                if (assignment.therapistId != user?.id) {
                  continue;
                }

                final sched = assignment.schedule;

                if (sched == null || sched.days.isEmpty) {
                  continue;
                }

                slots.add(
                  _ScheduleSlotRow(
                    childName: child.name,
                    therapyType: assignment.therapyType,
                    schedule: sched,
                  ),
                );
              }
            }

            if (slots.isEmpty) {
              return const sw.EmptyWidget(
                message: 'No recurring schedule set',
                icon: Icons.calendar_month_outlined,
              );
            }

            return Column(
              children: slots
                  .map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: AppCard(
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: isMobile ? 48 : 56,
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),

                            SizedBox(width: isMobile ? 10 : 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    s.childName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),

                                  const SizedBox(height: 2),

                                  Text(
                                    '${s.therapyType} • ${s.schedule.timeLabel}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),

                                  Text(
                                    s.schedule.daysLabel,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.primaryBlue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildChildrenList(
    BuildContext context,
    AsyncValue<List<ChildModel>> children,
  ) {
    final width = MediaQuery.of(context).size.width;

    final isMobile = width < 600;
    final isTablet = width >= 600 && width < 1024;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Children',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontSize: isMobile
                ? 20
                : isTablet
                ? 22
                : 24,
          ),
        ),

        const SizedBox(height: 12),

        children.when(
          loading: () => const sw.LoadingWidget(),

          error: (e, _) => sw.ErrorWidget(message: e.toString()),

          data: (list) {
            if (list.isEmpty) {
              return const sw.EmptyWidget(
                message: 'No children assigned yet',
                icon: Icons.child_care,
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) => _ChildTile(child: list[i]),
            );
          },
        ),
      ],
    );
  }

  void _showCreateSession(BuildContext context, WidgetRef ref) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateSessionScreen()),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final SessionModel session;
  final String childName;
  final VoidCallback onNotes;

  const _SessionCard({
    required this.session,
    required this.childName,
    required this.onNotes,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = session.status == 'completed';

    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;
    final isTablet = width >= 600 && width < 1024;
    final isDesktop = width >= 1024;

    return AppCard(
      child: Row(
        children: [
          Container(
            width: 4,
            height: isMobile ? 52 : 60,
            decoration: BoxDecoration(
              color: isCompleted ? AppColors.mintGreen : AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          SizedBox(width: isMobile ? 10 : 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  childName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: isDesktop
                        ? 17
                        : isTablet
                        ? 16
                        : 14,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  '${session.typeLabel} • '
                  '${AppDateUtils.formatTime(session.scheduledAt)} • '
                  '${session.durationMin} min',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: isDesktop
                        ? 14
                        : isTablet
                        ? 13
                        : 12,
                  ),
                ),
              ],
            ),
          ),

          isCompleted
              ? Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 8 : 10,
                    vertical: isMobile ? 4 : 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.mintGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Done',
                    style: TextStyle(
                      color: AppColors.mintGreen,
                      fontSize: isMobile ? 11 : 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : TextButton(
                  onPressed: onNotes,
                  child: Text(
                    'Add Notes',
                    style: TextStyle(fontSize: isMobile ? 12 : 13),
                  ),
                ),
        ],
      ),
    );
  }
}

class _ScheduleSlotRow {
  final String childName;
  final String therapyType;
  final SessionSchedule schedule;

  const _ScheduleSlotRow({
    required this.childName,
    required this.therapyType,
    required this.schedule,
  });
}

class _ChildTile extends StatelessWidget {
  final ChildModel child;

  const _ChildTile({required this.child});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final isMobile = width < 600;
    final isTablet = width >= 600 && width < 1024;
    final isDesktop = width >= 1024;

    final avatarRadius = isDesktop
        ? 24.0
        : isTablet
        ? 22.0
        : 20.0;

    return AppCard(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TherapistChildProfileScreen(child: child),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: avatarRadius,
            backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.15),
            child: Text(
              child.name[0].toUpperCase(),
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w600,
                fontSize: isDesktop
                    ? 18
                    : isTablet
                    ? 16
                    : 14,
              ),
            ),
          ),

          SizedBox(width: isMobile ? 10 : 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  child.name,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: isDesktop
                        ? 18
                        : isTablet
                        ? 16
                        : 14,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  '${child.ageYears} yrs • ${child.diagnosis}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: isDesktop
                        ? 14
                        : isTablet
                        ? 13
                        : 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),

          Icon(
            Icons.chevron_right,
            color: AppColors.textSecondary,
            size: isDesktop
                ? 24
                : isTablet
                ? 22
                : 20,
          ),
        ],
      ),
    );
  }
}
