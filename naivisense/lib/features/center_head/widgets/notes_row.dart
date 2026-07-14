import 'package:flutter/material.dart';
import 'package:naivisense/data/models/session.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import 'mini_score.dart';

class NotesRow extends StatelessWidget {
  final SessionNotes notes;

  const NotesRow({super.key, required this.notes});

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    final moodEmoji = switch (notes.mood) {
      'happy' => '😊',
      'calm' => '😌',
      'anxious' => '😰',
      'sad' => '😢',
      'angry' => '😠',
      _ => '😐',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        r.isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$moodEmoji  Mood: ${notes.mood}',
                    style: TextStyle(
                      fontSize: r.sp(12, tablet: 13, desktop: 14),
                    ),
                  ),

                  r.gapH(10, tablet: 12, desktop: 14),

                  Wrap(
                    spacing: r.w(8, tablet: 10, desktop: 12),
                    runSpacing: r.h(8, tablet: 10, desktop: 12),
                    children: [
                      MiniScore(
                        'Att',
                        notes.attentionScore,
                        AppColors.primaryBlue,
                      ),
                      MiniScore(
                        'Com',
                        notes.communicationScore,
                        AppColors.mintGreen,
                      ),
                      MiniScore('Mot', notes.motorScore, AppColors.warmYellow),
                      MiniScore(
                        'Beh',
                        notes.behaviorScore,
                        AppColors.softCoral,
                      ),
                    ],
                  ),
                ],
              )
            : Row(
                children: [
                  Text(
                    '$moodEmoji  Mood: ${notes.mood}',
                    style: TextStyle(
                      fontSize: r.sp(12, tablet: 13, desktop: 14),
                    ),
                  ),

                  const Spacer(),

                  MiniScore('Att', notes.attentionScore, AppColors.primaryBlue),

                  r.gapW(6, tablet: 8, desktop: 10),

                  MiniScore(
                    'Com',
                    notes.communicationScore,
                    AppColors.mintGreen,
                  ),

                  r.gapW(6, tablet: 8, desktop: 10),

                  MiniScore('Mot', notes.motorScore, AppColors.warmYellow),

                  r.gapW(6, tablet: 8, desktop: 10),

                  MiniScore('Beh', notes.behaviorScore, AppColors.softCoral),
                ],
              ),

        if (notes.activities.isNotEmpty) ...[
          r.gapH(6, tablet: 7, desktop: 8),

          Wrap(
            spacing: r.w(4, tablet: 6, desktop: 8),
            runSpacing: r.h(4, tablet: 6, desktop: 8),
            children: notes.activities
                .take(4)
                .map(
                  (a) => Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: r.w(8, tablet: 9, desktop: 10),
                      vertical: r.h(3, tablet: 4, desktop: 5),
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(
                        r.radius(8, tablet: 9, desktop: 10),
                      ),
                    ),
                    child: Text(
                      a,
                      style: TextStyle(
                        fontSize: r.sp(10, tablet: 11, desktop: 12),
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],

        if (notes.whatWorked != null && notes.whatWorked!.isNotEmpty) ...[
          r.gapH(8, tablet: 9, desktop: 10),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.thumb_up_outlined,
                size: r.icon(13, tablet: 14, desktop: 15),
                color: AppColors.mintGreen,
              ),

              r.gapW(6, tablet: 7, desktop: 8),

              Expanded(
                child: Text(
                  notes.whatWorked!,
                  style: TextStyle(
                    fontSize: r.sp(12, tablet: 13, desktop: 14),
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],

        if (notes.whatDidntWork != null && notes.whatDidntWork!.isNotEmpty) ...[
          r.gapH(4, tablet: 5, desktop: 6),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.thumb_down_outlined,
                size: r.icon(13, tablet: 14, desktop: 15),
                color: AppColors.softCoral,
              ),

              r.gapW(6, tablet: 7, desktop: 8),

              Expanded(
                child: Text(
                  notes.whatDidntWork!,
                  style: TextStyle(
                    fontSize: r.sp(12, tablet: 13, desktop: 14),
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],

        if (notes.homework != null && notes.homework!.isNotEmpty) ...[
          r.gapH(4, tablet: 5, desktop: 6),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.home_outlined,
                size: r.icon(13, tablet: 14, desktop: 15),
                color: AppColors.primaryBlue,
              ),

              r.gapW(6, tablet: 7, desktop: 8),

              Expanded(
                child: Text(
                  notes.homework!,
                  style: TextStyle(
                    fontSize: r.sp(12, tablet: 13, desktop: 14),
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
