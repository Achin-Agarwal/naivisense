import 'package:flutter/material.dart';
import 'package:naivisense/features/center_head/widgets/chip_group.dart';
import 'package:naivisense/features/center_head/widgets/form_label.dart';
import 'package:naivisense/features/center_head/widgets/section_title.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';

class Step2ProfessionalQualifications extends StatelessWidget {
  final TextEditingController qualificationController;
  final TextEditingController licenseController;
  final TextEditingController organizationController;
  final TextEditingController certificationController;

  final int yearsExperience;
  final ValueChanged<double> onYearsChanged;

  final List<String> workplaceOptions;
  final String workplaceType;
  final ValueChanged<String> onWorkplaceChanged;

  final List<String> certifications;
  final VoidCallback onAddCertification;
  final ValueChanged<String> onRemoveCertification;

  const Step2ProfessionalQualifications({
    super.key,
    required this.qualificationController,
    required this.licenseController,
    required this.organizationController,
    required this.certificationController,
    required this.yearsExperience,
    required this.onYearsChanged,
    required this.workplaceOptions,
    required this.workplaceType,
    required this.onWorkplaceChanged,
    required this.certifications,
    required this.onAddCertification,
    required this.onRemoveCertification,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(
          text: 'Professional Qualifications',
          icon: Icons.school_outlined,
        ),

        SizedBox(height: r.h(16, tablet: 20, desktop: 24)),

        TextFormField(
          controller: qualificationController,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Highest Degree / Qualification *',
            hintText: 'e.g. M.Sc. Speech-Language Pathology',
            prefixIcon: Icon(Icons.menu_book_outlined),
          ),
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
        ),

        SizedBox(height: r.h(14)),

        TextFormField(
          controller: licenseController,
          decoration: const InputDecoration(
            labelText: 'License / Registration No. (optional)',
            prefixIcon: Icon(Icons.verified_outlined),
          ),
        ),

        SizedBox(height: r.h(20)),

        FormLabel(text: 'Years of Experience: $yearsExperience'),

        Slider(
          value: yearsExperience.toDouble(),
          min: 0,
          max: 30,
          divisions: 30,
          activeColor: AppColors.primaryBlue,
          onChanged: onYearsChanged,
        ),

        SizedBox(height: r.h(12)),

        const FormLabel(text: 'Workplace Type *'),

        SizedBox(height: r.h(8)),

        ChipGroup(
          options: workplaceOptions,
          selected: {workplaceType},
          single: true,
          onTap: onWorkplaceChanged,
          display: (v) => v[0].toUpperCase() + v.substring(1),
        ),

        SizedBox(height: r.h(20)),

        TextFormField(
          controller: organizationController,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Organization / Clinic Name (optional)',
            prefixIcon: Icon(Icons.business_outlined),
          ),
        ),

        SizedBox(height: r.h(20)),

        const FormLabel(text: 'Certifications (add one at a time)'),

        SizedBox(height: r.h(8)),

        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: certificationController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Certified ABA Therapist',
                ),
              ),
            ),

            SizedBox(width: r.w(8)),

            TextButton.icon(
              onPressed: onAddCertification,
              icon: const Icon(Icons.add),
              label: const Text('Add'),
            ),
          ],
        ),

        if (certifications.isNotEmpty) ...[
          SizedBox(height: r.h(8)),

          Wrap(
            spacing: r.w(8),
            runSpacing: r.h(4),
            children: certifications
                .map(
                  (c) => Chip(
                    label: Text(c, style: TextStyle(fontSize: r.sp(12))),
                    deleteIconColor: AppColors.textSecondary,
                    onDeleted: () => onRemoveCertification(c),
                  ),
                )
                .toList(),
          ),
        ],
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
