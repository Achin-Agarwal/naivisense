import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/data/models/child.dart';
import 'package:naivisense/data/models/session.dart';
import 'package:naivisense/features/therapist/screens/session_notes_screen.dart';
import 'package:naivisense/features/therapist/widgets/session_card.dart';
import 'package:naivisense/shared/widgets/state_widgets.dart' as sw;

class TodaySessions extends ConsumerWidget {
  final AsyncValue<List<SessionModel>> sessions;
  final AsyncValue<List<ChildModel>> children;

  const TodaySessions({
    super.key,
    required this.sessions,
    required this.children,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responsive = Responsive(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Today's Sessions",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontSize: responsive.sp(20, tablet: 22, desktop: 24),
          ),
        ),

        SizedBox(height: responsive.h(12, tablet: 16, desktop: 20)),

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

              separatorBuilder: (_, __) =>
                  SizedBox(height: responsive.h(8, tablet: 10, desktop: 12)),

              itemBuilder: (_, i) {
                final s = today[i];
                final childName = childMap[s.childId] ?? 'Unknown Child';

                return SessionCard(
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
}
