import 'package:flutter/material.dart';
import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/features/therapist/widgets/session_title.dart';
import 'package:naivisense/shared/widgets/rating_slider.dart';

class SkillScoresSection extends StatelessWidget {
  const SkillScoresSection({
    super.key,
    required this.attentionScore,
    required this.communicationScore,
    required this.motorScore,
    required this.behaviorScore,
    required this.onAttentionChanged,
    required this.onCommunicationChanged,
    required this.onMotorChanged,
    required this.onBehaviorChanged,
  });

  final int attentionScore;
  final int communicationScore;
  final int motorScore;
  final int behaviorScore;

  final ValueChanged<int> onAttentionChanged;
  final ValueChanged<int> onCommunicationChanged;
  final ValueChanged<int> onMotorChanged;
  final ValueChanged<int> onBehaviorChanged;

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    final sliders = [
      RatingSlider(
        label: 'Attention & Focus',
        value: attentionScore,
        onChanged: onAttentionChanged,
      ),
      RatingSlider(
        label: 'Communication',
        value: communicationScore,
        onChanged: onCommunicationChanged,
      ),
      RatingSlider(
        label: 'Motor Skills',
        value: motorScore,
        onChanged: onMotorChanged,
      ),
      RatingSlider(
        label: 'Social Behavior',
        value: behaviorScore,
        onChanged: onBehaviorChanged,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(
          title: 'Skill Scores',
          icon: Icons.bar_chart_outlined,
        ),

        r.gapH(16),

        if (r.isMobile)
          Column(
            children: [
              sliders[0],
              r.gapH(14),
              sliders[1],
              r.gapH(14),
              sliders[2],
              r.gapH(14),
              sliders[3],
            ],
          )
        else
          Wrap(
            spacing: r.w(20),
            runSpacing: r.h(20),
            children: sliders.map((slider) {
              return SizedBox(
                width: r.w(300, tablet: 320, desktop: 340),
                child: slider,
              );
            }).toList(),
          ),
      ],
    );
  }
}
