import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/features/therapist/widgets/child/section_title.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/child.dart';
import '../../../../data/models/session.dart';
import 'empty_message.dart';
import 'session_history_row.dart';

class SessionHistorySection extends ConsumerStatefulWidget {
  final ChildModel child;
  final AsyncValue<List<SessionModel>> sessions;

  const SessionHistorySection({
    super.key,
    required this.child,
    required this.sessions,
  });

  @override
  ConsumerState<SessionHistorySection> createState() =>
      _SessionHistorySectionState();
}

class _SessionHistorySectionState extends ConsumerState<SessionHistorySection> {
  bool _expanded = false;

  static const int _initialCount = 5;

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return ProfileCard(
      title: 'Session History',
      icon: Icons.history,
      child: widget.sessions.when(
        loading: () => SizedBox(
          height: r.h(14, tablet: 12, desktop: 10),
          child: const Center(
            child: CircularProgressIndicator(color: AppColors.primaryBlue),
          ),
        ),

        error: (_, __) =>
            const EmptyMessage(message: 'Could not load sessions'),

        data: (list) {
          if (list.isEmpty) {
            return const EmptyMessage(message: 'No sessions yet');
          }

          final sorted = [...list]
            ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));

          final visibleSessions = _expanded
              ? sorted
              : sorted.take(_initialCount).toList();

          return Column(
            children: [
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: visibleSessions.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, index) {
                  return SessionHistoryRow(
                    session: visibleSessions[index],
                    child: widget.child,
                  );
                },
              ),

              if (sorted.length > _initialCount) ...[
                SizedBox(height: r.h(12)),

                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _expanded = !_expanded;
                    });
                  },
                  icon: Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                  label: Text(
                    _expanded
                        ? 'Show Less'
                        : 'Show ${sorted.length - _initialCount} More',
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
