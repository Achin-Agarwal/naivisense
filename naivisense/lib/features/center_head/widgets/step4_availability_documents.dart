import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:naivisense/features/center_head/widgets/chip_group.dart';
import 'package:naivisense/features/center_head/widgets/form_label.dart';
import 'package:naivisense/features/center_head/widgets/section_title.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/document_upload_tile.dart';

class Step4AvailabilityDocuments extends StatelessWidget {
  final List<String> dayOptions;
  final Set<String> availableDays;
  final ValueChanged<String> onDayTap;

  final List<String> modeOptions;
  final Set<String> sessionModes;
  final ValueChanged<String> onModeTap;

  final double sessionDuration;
  final ValueChanged<double> onDurationChanged;

  final Uint8List? profileBytes;
  final Uint8List? degreeBytes;
  final Uint8List? identityBytes;

  final VoidCallback onProfileTap;
  final VoidCallback onDegreeTap;
  final VoidCallback onIdentityTap;

  final List<String> proofTypeOptions;
  final String identityProofType;
  final ValueChanged<String> onProofTypeChanged;

  const Step4AvailabilityDocuments({
    super.key,
    required this.dayOptions,
    required this.availableDays,
    required this.onDayTap,
    required this.modeOptions,
    required this.sessionModes,
    required this.onModeTap,
    required this.sessionDuration,
    required this.onDurationChanged,
    required this.profileBytes,
    required this.degreeBytes,
    required this.identityBytes,
    required this.onProfileTap,
    required this.onDegreeTap,
    required this.onIdentityTap,
    required this.proofTypeOptions,
    required this.identityProofType,
    required this.onProofTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(text: 'Availability', icon: Icons.schedule_outlined),

        SizedBox(height: r.h(16, tablet: 20, desktop: 24)),

        const FormLabel(text: 'Available Days'),

        SizedBox(height: r.h(8)),

        ChipGroup(
          options: dayOptions,
          selected: availableDays,
          onTap: onDayTap,
        ),

        SizedBox(height: r.h(20)),

        const FormLabel(text: 'Session Modes'),

        SizedBox(height: r.h(8)),

        ChipGroup(
          options: modeOptions,
          selected: sessionModes,
          onTap: onModeTap,
        ),

        SizedBox(height: r.h(20)),

        FormLabel(text: 'Session Duration: ${sessionDuration.round()} minutes'),

        Slider(
          value: sessionDuration,
          min: 15,
          max: 120,
          divisions: 21,
          activeColor: AppColors.primaryBlue,
          onChanged: onDurationChanged,
        ),

        SizedBox(height: r.h(24)),

        const Divider(),

        const SectionTitle(text: 'Documents', icon: Icons.folder_copy_outlined),

        SizedBox(height: r.h(4)),

        Text(
          'All documents are optional. Photos are stored securely.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: r.sp(13)),
        ),

        SizedBox(height: r.h(16)),

        const FormLabel(text: 'Profile Photo'),

        SizedBox(height: r.h(8)),

        DocumentUploadTile(
          label: 'Profile Photo',
          icon: Icons.account_circle_outlined,
          bytes: profileBytes,
          onTap: onProfileTap,
        ),

        SizedBox(height: r.h(14)),

        const FormLabel(text: 'Degree / Certificate'),

        SizedBox(height: r.h(8)),

        DocumentUploadTile(
          label: 'Degree Certificate',
          icon: Icons.workspace_premium_outlined,
          bytes: degreeBytes,
          onTap: onDegreeTap,
        ),

        SizedBox(height: r.h(20)),

        const FormLabel(text: 'Identity Proof Type'),

        SizedBox(height: r.h(8)),

        ChipGroup(
          options: proofTypeOptions,
          selected: {identityProofType},
          single: true,
          onTap: onProofTypeChanged,
          display: (v) => switch (v) {
            'aadhar' => 'Aadhar',
            'pan' => 'PAN Card',
            'passport' => 'Passport',
            'driving_license' => 'Driving Licence',
            _ => v,
          },
        ),

        SizedBox(height: r.h(14)),

        DocumentUploadTile(
          label: 'Identity Proof',
          icon: Icons.credit_card_outlined,
          bytes: identityBytes,
          onTap: onIdentityTap,
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
