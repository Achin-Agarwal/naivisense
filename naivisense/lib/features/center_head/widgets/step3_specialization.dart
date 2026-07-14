import 'package:flutter/material.dart';
import 'package:naivisense/features/center_head/widgets/chip_group.dart';
import 'package:naivisense/features/center_head/widgets/form_label.dart';
import 'package:naivisense/features/center_head/widgets/section_title.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';

class Step3Specialization extends StatelessWidget {
  final List<String> therapyMethodOptions;
  final Set<String> therapyMethods;
  final ValueChanged<String> onTherapyMethodTap;

  final List<String> conditionOptions;
  final Set<String> conditionsHandled;
  final ValueChanged<String> onConditionTap;

  final List<String> ageGroupOptions;
  final Set<String> ageGroups;
  final ValueChanged<String> onAgeGroupTap;

  const Step3Specialization({
    super.key,
    required this.therapyMethodOptions,
    required this.therapyMethods,
    required this.onTherapyMethodTap,
    required this.conditionOptions,
    required this.conditionsHandled,
    required this.onConditionTap,
    required this.ageGroupOptions,
    required this.ageGroups,
    required this.onAgeGroupTap,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(
          text: 'Specialization',
          icon: Icons.psychology_outlined,
        ),

        SizedBox(height: r.h(16, tablet: 20, desktop: 24)),

        Text(
          'Define what this therapist treats and who they work with.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: r.sp(13)),
        ),

        SizedBox(height: r.h(20)),

        const FormLabel(text: 'Therapy Methods * (select all that apply)'),

        SizedBox(height: r.h(8)),

        ChipGroup(
          options: therapyMethodOptions,
          selected: therapyMethods,
          onTap: onTherapyMethodTap,
          validator: therapyMethods.isEmpty
              ? 'Select at least one method'
              : null,
        ),

        SizedBox(height: r.h(20)),

        const FormLabel(text: 'Conditions Handled (select all that apply)'),

        SizedBox(height: r.h(8)),

        ChipGroup(
          options: conditionOptions,
          selected: conditionsHandled,
          onTap: onConditionTap,
        ),

        SizedBox(height: r.h(20)),

        const FormLabel(text: 'Age Groups Served'),

        SizedBox(height: r.h(8)),

        ChipGroup(
          options: ageGroupOptions,
          selected: ageGroups,
          onTap: onAgeGroupTap,
        ),
      ],
    );

    if (r.isDesktop) {
      return Center(child: SizedBox(width: 760, child: content));
    }

    if (r.isTablet) {
      return Center(child: SizedBox(width: 620, child: content));
    }

    return content;
  }
}
