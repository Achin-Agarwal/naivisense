import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naivisense/data/models/session.dart';

import '../../../core/utils/responsive.dart';
import 'empty_card.dart';
import 'loading_card.dart';
import 'section_header.dart';
import 'session_history_card.dart';

class SessionHistorySection extends StatelessWidget {
  final AsyncValue<List<SessionModel>> sessions;

  const SessionHistorySection({super.key, required this.sessions});

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    final list = [...(sessions.valueOrNull ?? [])]
      ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Session History (${list.length})',
          icon: Icons.history,
        ),

        r.gapH(12, tablet: 14, desktop: 16),

        sessions.when(
          loading: () => const LoadingCard(),

          error: (e, _) => const EmptyCard(message: 'Could not load sessions'),

          data: (sessions) {
            if (sessions.isEmpty) {
              return const EmptyCard(message: 'No sessions yet');
            }

            final sorted = [...sessions]
              ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sorted.length,
              separatorBuilder: (_, _) => r.gapH(8, tablet: 10, desktop: 12),
              itemBuilder: (_, i) => SessionHistoryCard(session: sorted[i]),
            );
          },
        ),
      ],
    );
  }
}
