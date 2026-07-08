import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/features/therapist/widgets/build_children_list.dart';
import 'package:naivisense/features/therapist/widgets/build_scheduled_sessions.dart';
import 'package:naivisense/features/therapist/widgets/build_stats.dart';
import 'package:naivisense/features/therapist/widgets/build_today_sessions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../providers/therapist_provider.dart';
import 'create_session_screen.dart';

class TherapistHomeScreen extends ConsumerWidget {
  const TherapistHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).valueOrNull?.user;
    final children = ref.watch(therapistChildrenProvider);
    final sessions = ref.watch(therapistSessionsProvider);

    final pending = ref.watch(therapistPendingVerificationsProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final responsive = Responsive(context);

        final horizontalPadding = responsive.horizontalPadding;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(
              'Hi, ${user?.name.split(' ').first ?? 'Therapist'}',
              style: TextStyle(
                fontSize: responsive.sp(18, tablet: 22, desktop: 24),
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
                constraints: const BoxConstraints(maxWidth: 1100),
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.all(horizontalPadding),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          DashboardStats(
                            children: children,
                            sessions: sessions,
                            pending: pending,
                          ),

                          responsive.gapH(12, tablet: 16, desktop: 20),

                          TodaySessions(sessions: sessions, children: children),

                          responsive.gapH(12, tablet: 16, desktop: 20),

                          ChildrenListSection(children: children),

                          responsive.gapH(12, tablet: 16, desktop: 20),

                          ScheduledSessionsWidget(children: children),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // floatingActionButtonLocation:
          //     FloatingActionButtonLocation.centerFloat,
          floatingActionButton: responsive.isMobile
              ? FloatingActionButton(
                  onPressed: () async {
                    final created = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreateSessionScreen(),
                      ),
                    );

                    if (created == true) {
                      await ref.refresh(therapistSessionsProvider.future);
                    }
                  },
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  child: const Icon(Icons.add),
                )
              : FloatingActionButton.extended(
                  onPressed: () async {
                    final created = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreateSessionScreen(),
                      ),
                    );

                    if (created == true) {
                      await ref.refresh(therapistSessionsProvider.future);
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('New Session'),
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                ),
        );
      },
    );
  }
}
