import 'package:flutter/material.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/data/models/session.dart';
import 'package:naivisense/features/therapist/widgets/child/note_tile.dart';
import 'package:naivisense/features/therapist/widgets/child/score_chip.dart';
import 'package:naivisense/features/therapist/widgets/child/section_heading.dart';

class NotesPreview extends StatefulWidget {
  final SessionNotes notes;
  final VoidCallback? onEdit;

  const NotesPreview({super.key, required this.notes, this.onEdit});

  @override
  State<NotesPreview> createState() => _NotesPreviewState();
}

class _NotesPreviewState extends State<NotesPreview> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    final notes = widget.notes;

    final moodEmoji = switch (notes.mood) {
      'happy' => '😊',
      'calm' => '😌',
      'anxious' => '😰',
      'sad' => '😢',
      'angry' => '😠',
      _ => '😐',
    };

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsive.w(16, tablet: 18, desktop: 20)),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(
          responsive.radius(16, tablet: 18, desktop: 20),
        ),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //----------------------------------------------------------
          // Mood
          //----------------------------------------------------------
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(responsive.w(10)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.divider),
                ),
                child: Text(
                  moodEmoji,
                  style: TextStyle(
                    fontSize: responsive.sp(22, tablet: 24, desktop: 26),
                  ),
                ),
              ),

              responsive.gapW(14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Child Mood',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: responsive.sp(12),
                      ),
                    ),

                    SizedBox(height: responsive.h(4)),

                    Text(
                      notes.mood.toUpperCase(),
                      style: TextStyle(
                        fontSize: responsive.sp(16, tablet: 17, desktop: 18),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              IconButton(
                tooltip: "Edit Session Notes",
                icon: const Icon(Icons.edit_outlined),
                onPressed: widget.onEdit,
              ),
            ],
          ),

          responsive.gapH(20),

          const Divider(),

          responsive.gapH(18),

          //----------------------------------------------------------
          // Skill Scores
          //----------------------------------------------------------
          const SectionHeading(title: 'Skill Scores', icon: Icons.bar_chart),

          responsive.gapH(14),

          Wrap(
            spacing: responsive.w(10),
            runSpacing: responsive.h(10),
            children: [
              ScoreChip(
                label: 'Attention',
                value: notes.attentionScore,
                color: AppColors.primaryBlue,
              ),
              ScoreChip(
                label: 'Communication',
                value: notes.communicationScore,
                color: AppColors.mintGreen,
              ),
              ScoreChip(
                label: 'Motor',
                value: notes.motorScore,
                color: AppColors.warmYellow,
              ),
              ScoreChip(
                label: 'Behavior',
                value: notes.behaviorScore,
                color: AppColors.softCoral,
              ),
            ],
          ),
          //----------------------------------------------------------
          // Activities
          //----------------------------------------------------------
          if (notes.activities.isNotEmpty) ...[
            responsive.gapH(24),

            const SectionHeading(
              title: 'Activities Used',
              icon: Icons.extension,
            ),

            responsive.gapH(14),

            Wrap(
              spacing: responsive.w(10),
              runSpacing: responsive.h(10),
              children: notes.activities.map((activity) {
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.w(14),
                    vertical: responsive.h(8),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: AppColors.primaryBlue.withValues(alpha: .18),
                    ),
                  ),
                  child: IntrinsicWidth(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: responsive.icon(15),
                          color: AppColors.primaryBlue,
                        ),
                        responsive.gapW(6),
                        Flexible(
                          child: Text(
                            activity,
                            softWrap: true,
                            overflow: TextOverflow.visible,
                            style: TextStyle(
                              fontSize: responsive.sp(13),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          responsive.gapH(20),

          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                responsive.gapH(24),

                const Divider(),

                responsive.gapH(18),

                //----------------------------------------------------------
                // Notes & Observations
                //----------------------------------------------------------
                const SectionHeading(
                  title: 'Session Notes',
                  icon: Icons.notes_rounded,
                ),

                responsive.gapH(14),

                NoteTile(
                  title: 'What Worked',
                  value: notes.whatWorked,
                  icon: Icons.thumb_up_alt_outlined,
                  color: AppColors.mintGreen,
                ),

                NoteTile(
                  title: "What Didn't Work",
                  value: notes.whatDidntWork,
                  icon: Icons.thumb_down_alt_outlined,
                  color: AppColors.softCoral,
                ),

                NoteTile(
                  title: "Homework",
                  value: notes.homework,
                  icon: Icons.home_work_outlined,
                  color: AppColors.primaryBlue,
                ),

                NoteTile(
                  title: "Observations",
                  value: notes.observations,
                  icon: Icons.visibility_outlined,
                  color: Colors.deepPurple,
                ),

                NoteTile(
                  title: "Progress Log",
                  value: notes.progressLog,
                  icon: Icons.trending_up_outlined,
                  color: Colors.teal,
                ),

                NoteTile(
                  title: "Tantrums Observed",
                  value: notes.tantrums,
                  icon: Icons.warning_amber_rounded,
                  color: Colors.orange,
                ),

                NoteTile(
                  title: "Resolution Notes",
                  value: notes.resolutionNotes,
                  icon: Icons.psychology_outlined,
                  color: Colors.indigo,
                ),

                //----------------------------------------------------------
                // Follow Up
                //----------------------------------------------------------
                responsive.gapH(8),

                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.w(16),
                    vertical: responsive.h(14),
                  ),
                  decoration: BoxDecoration(
                    color: notes.followUpRequired
                        ? AppColors.warmYellow.withValues(alpha: .12)
                        : AppColors.mintGreen.withValues(alpha: .10),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: notes.followUpRequired
                          ? AppColors.warmYellow
                          : AppColors.mintGreen,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        notes.followUpRequired
                            ? Icons.notification_important_outlined
                            : Icons.check_circle_outline,
                        color: notes.followUpRequired
                            ? AppColors.warmYellow
                            : AppColors.mintGreen,
                        size: responsive.icon(22),
                      ),

                      responsive.gapW(12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notes.followUpRequired
                                  ? "Follow-up Required"
                                  : "No Follow-up Required",
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: responsive.sp(14),
                              ),
                            ),

                            SizedBox(height: responsive.h(3)),

                            Text(
                              notes.followUpRequired
                                  ? "This child requires another review or follow-up session."
                                  : "No additional follow-up has been marked for this session.",
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: responsive.sp(12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          responsive.gapH(20),
          Center(
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.w(20),
                  vertical: responsive.h(12),
                ),
                shape: const StadiumBorder(),
              ),
              onPressed: () {
                setState(() {
                  _expanded = !_expanded;
                });
              },
              icon: AnimatedRotation(
                duration: const Duration(milliseconds: 250),
                turns: _expanded ? 0.5 : 0,
                child: const Icon(Icons.keyboard_arrow_down),
              ),
              label: Text(
                _expanded ? "Show Less" : "Show More",
                style: TextStyle(
                  fontSize: responsive.sp(14),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
