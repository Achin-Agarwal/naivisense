import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naivisense/features/therapist/providers/therapist_provider.dart';
import 'package:naivisense/features/therapist/widgets/child/notes_preview.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../data/models/child.dart';
import '../../../../data/models/session.dart';
import '../../screens/session_notes_screen.dart';

class SessionHistoryRow extends ConsumerWidget {
  final SessionModel session;
  final ChildModel child;

  const SessionHistoryRow({
    super.key,
    required this.session,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responsive = Responsive(context);

    final (statusColor, statusLabel) = switch (session.status) {
      'completed' => (AppColors.mintGreen, 'Completed'),
      'cancelled' => (AppColors.softCoral, 'Cancelled'),
      _ => (AppColors.warmYellow, 'Scheduled'),
    };

    return Padding(
      padding: EdgeInsets.symmetric(vertical: responsive.h(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          responsive.isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _SessionInfo(session: session)),
                    _StatusChip(label: statusLabel, color: statusColor),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SessionInfo(session: session),
                    responsive.gapH(8),
                    _StatusChip(label: statusLabel, color: statusColor),
                  ],
                ),

          if (session.status == 'completed' && session.notes != null) ...[
            responsive.gapH(12),
            NotesPreview(
              notes: session.notes!,
              onEdit: () async {
                final updated = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SessionNotesScreen(
                      session: session,
                      childName: child.name,
                      existingNotes: session.notes,
                    ),
                  ),
                );

                if (updated == true) {
                  ref.invalidate(therapistChildSessionsProvider(child.id));
                }
              },
            ),
          ] else if (session.status == 'scheduled') ...[
            responsive.gapH(8),
            TextButton.icon(
              onPressed: () async {
                final updated = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SessionNotesScreen(
                      session: session,
                      childName: child.name,
                    ),
                  ),
                );

                if (updated == true) {
                  ref.invalidate(therapistChildSessionsProvider(child.id));
                }
              },
              icon: Icon(Icons.edit_outlined, size: responsive.icon(18)),
              label: Text(
                'Add Notes',
                style: TextStyle(fontSize: responsive.sp(13)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SessionInfo extends StatelessWidget {
  final SessionModel session;

  const _SessionInfo({required this.session});

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          session.typeLabel,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: responsive.sp(15),
          ),
        ),
        responsive.gapH(4),
        Text(
          '${AppDateUtils.formatDate(session.scheduledAt)} • '
          '${AppDateUtils.formatTime(session.scheduledAt)} • '
          '${session.durationMin} min',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            fontSize: responsive.sp(13),
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.w(12),
        vertical: responsive.h(6),
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: responsive.sp(12),
        ),
      ),
    );
  }
}
