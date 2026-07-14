import 'package:flutter/material.dart';
import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/features/therapist/widgets/observation_field.dart';
import 'package:naivisense/features/therapist/widgets/session_title.dart';

class SessionObservationsSection extends StatelessWidget {
  const SessionObservationsSection({
    super.key,
    required this.whatWorkedController,
    required this.whatDidntController,
    required this.homeworkController,
  });

  final TextEditingController whatWorkedController;
  final TextEditingController whatDidntController;
  final TextEditingController homeworkController;

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    final fields = [
      ObservationField(
        controller: whatWorkedController,
        label: 'What Worked Today',
        hint: 'Activities or approaches that led to positive responses...',
        icon: Icons.check_circle_outline,
        iconColor: AppColors.mintGreen,
      ),
      ObservationField(
        controller: whatDidntController,
        label: "What Didn't Work",
        hint: 'What caused disengagement, refusal, or meltdowns...',
        icon: Icons.cancel_outlined,
        iconColor: AppColors.softCoral,
      ),
      ObservationField(
        controller: homeworkController,
        label: 'Homework Assigned',
        hint: 'Activities to practice at home before next session...',
        icon: Icons.home_outlined,
        iconColor: AppColors.warmYellow,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(
          title: 'Session Observations',
          icon: Icons.notes_outlined,
        ),

        r.gapH(16),

        if (r.isMobile)
          Column(
            children: [
              for (int i = 0; i < fields.length; i++) ...[
                fields[i],
                if (i != fields.length - 1) r.gapH(16),
              ],
            ],
          )
        else
          Wrap(
            spacing: r.w(20),
            runSpacing: r.h(20),
            children: fields.map((field) {
              return SizedBox(
                width: r.w(300, tablet: 320, desktop: 340),
                child: field,
              );
            }).toList(),
          ),
      ],
    );
  }
}
