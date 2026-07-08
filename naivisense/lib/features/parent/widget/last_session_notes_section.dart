import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/date_utils.dart';
import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/data/models/session.dart';
import 'package:naivisense/features/parent/widget/empty_hint.dart';
import 'package:naivisense/features/parent/widget/mood_note.dart';
import 'package:naivisense/features/parent/widget/section_header.dart';
import 'package:naivisense/shared/widgets/app_card.dart';


class LastSessionNotesSection extends StatelessWidget {
  final AsyncValue<List<SessionModel>> sessions;

  const LastSessionNotesSection({
    super.key,
    required this.sessions,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    final completed = sessions.valueOrNull
        ?.where((session) =>
            session.status == 'completed' && session.notes != null)
        .toList()
      ?..sort(
        (a, b) => b.scheduledAt.compareTo(a.scheduledAt),
      );

    final lastSession =
        completed?.isNotEmpty == true ? completed!.first : null;

    final notes = lastSession?.notes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: "Therapist's Last Notes",
          icon: Icons.notes_outlined,
        ),

        r.gapH(16),

        if (notes == null)
          EmptyHint(
            message: 'No notes from therapist yet',
          )
        else
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    MoodBadge(
                      mood: notes.mood,
                      responsive: r,
                    ),

                    r.gapW(8),

                    Text(
                      lastSession != null
                          ? AppDateUtils.formatDate(
                              lastSession.scheduledAt,
                            )
                          : '',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: r.sp(
                          12,
                          tablet: 13,
                          desktop: 14,
                        ),
                      ),
                    ),
                  ],
                ),

                if (notes.activities.isNotEmpty) ...[
                  r.gapH(16),

                  Wrap(
                    spacing: r.w(8),
                    runSpacing: r.h(8),
                    children: notes.activities
                        .map(
                          (activity) => Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: r.w(10),
                              vertical: r.h(6),
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue.withValues(
                                alpha: 0.08,
                              ),
                              borderRadius: r.borderRadius(12),
                            ),
                            child: Text(
                              activity,
                              style: TextStyle(
                                color: AppColors.primaryBlue,
                                fontSize: r.sp(
                                  12,
                                  tablet: 13,
                                  desktop: 14,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],

                if (notes.whatWorked != null) ...[
                  r.gapH(16),

                  NoteRow(
                    icon: Icons.check_circle_outline,
                    color: AppColors.mintGreen,
                    label: 'What Worked',
                    text: notes.whatWorked!,
                    responsive: r,
                  ),
                ],

                if (notes.whatDidntWork != null) ...[
                  r.gapH(10),

                  NoteRow(
                    icon: Icons.cancel_outlined,
                    color: AppColors.softCoral,
                    label: "What Didn't Work",
                    text: notes.whatDidntWork!,
                    responsive: r,
                  ),
                ],

                if (notes.homework != null) ...[
                  r.gapH(10),

                  NoteRow(
                    icon: Icons.home_outlined,
                    color: AppColors.warmYellow,
                    label: 'Homework for You',
                    text: notes.homework!,
                    responsive: r,
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}