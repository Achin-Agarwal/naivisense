import 'package:flutter/material.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/date_utils.dart';
import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/data/models/session.dart';
import 'package:naivisense/shared/widgets/app_card.dart';

class SessionCard extends StatelessWidget {
  final SessionModel session;
  final String childName;
  final VoidCallback onNotes;
  final VoidCallback? onEdit;

  const SessionCard({
    super.key,
    required this.session,
    required this.childName,
    required this.onNotes,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);
    final isCompleted = session.status == 'completed';

    return AppCard(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: r.w(6, tablet: 8, desktop: 10),
          vertical: r.h(10),
        ),
        child: r.isMobile
            ? _mobileLayout(context, r, isCompleted)
            : _desktopLayout(context, r, isCompleted),
      ),
    );
  }

  Widget _desktopLayout(BuildContext context, Responsive r, bool isCompleted) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _leftBar(r),

        r.gapW(12),

        Expanded(child: _sessionInfo(context, r)),

        r.gapW(12),

        if (isCompleted)
          _completedChip()
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text("Edit"),
              ),
              FilledButton.icon(
                onPressed: onNotes,
                icon: const Icon(Icons.note_alt_outlined, size: 18),
                label: const Text("Add Notes"),
              ),
            ],
          ),
      ],
    );
  }

  Widget _mobileLayout(BuildContext context, Responsive r, bool isCompleted) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _leftBar(r),

            r.gapW(12),

            Expanded(child: _sessionInfo(context, r)),
          ],
        ),

        r.gapH(12),

        if (isCompleted)
          Align(alignment: Alignment.centerLeft, child: _completedChip())
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text("Edit"),
              ),
              FilledButton.icon(
                onPressed: onNotes,
                icon: const Icon(Icons.note_alt_outlined, size: 18),
                label: const Text("Add Notes"),
              ),
            ],
          ),
      ],
    );
  }

  Widget _leftBar(Responsive r) {
    return Container(
      width: 5,
      height: r.h(56, tablet: 60, desktop: 64),
      decoration: BoxDecoration(
        color: session.status == 'completed'
            ? AppColors.mintGreen
            : AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _sessionInfo(BuildContext context, Responsive r) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          childName,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: r.sp(15, tablet: 16, desktop: 17),
          ),
        ),

        r.gapH(6),

        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            _InfoChip(icon: Icons.psychology_outlined, text: session.typeLabel),
            _InfoChip(
              icon: Icons.schedule,
              text: AppDateUtils.formatTime(session.scheduledAt),
            ),
            _InfoChip(
              icon: Icons.timelapse,
              text: '${session.durationMin} min',
            ),
          ],
        ),
      ],
    );
  }

  Widget _completedChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.mintGreen.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'Completed',
        style: TextStyle(
          color: AppColors.mintGreen,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: r.w(8, tablet: 10),
        vertical: r.h(5, tablet: 6),
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: r.icon(14, tablet: 15, desktop: 16),
            color: AppColors.primaryBlue,
          ),
          r.gapW(5),
          Text(
            text,
            style: TextStyle(fontSize: r.sp(12, tablet: 13, desktop: 14)),
          ),
        ],
      ),
    );
  }
}
