import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naivisense/data/models/child.dart';
import 'package:naivisense/data/models/session.dart';
import 'package:naivisense/features/parent/widget/section_header.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import 'inline_staff_card.dart';

class StaffSection extends StatelessWidget {
  final ChildModel child;
  final AsyncValue<List<SessionModel>> sessions;
  final String Function(String id, String fallback) shortIdOrFallback;

  const StaffSection({
    super.key,
    required this.child,
    required this.sessions,
    required this.shortIdOrFallback,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    final completedCount =
        sessions.valueOrNull?.where((s) => s.status == 'completed').length ?? 0;

    final therapistName =
        child.therapistName ??
        shortIdOrFallback(child.therapistId, 'Not assigned');

    final therapistPhone = child.therapistPhone ?? '—';

    final parentName =
        child.parentName ?? shortIdOrFallback(child.parentId, 'Not assigned');

    final parentPhone = child.parentPhone ?? '—';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Assigned Team', icon: Icons.people_outline),

        r.gapH(12, tablet: 14, desktop: 16),

        InlineStaffCard(
          name: therapistName,
          phone: therapistPhone,
          role: 'Therapist',
          roleColor: AppColors.primaryBlue,
          roleIcon: Icons.medical_services_outlined,
          subtitle: '$completedCount sessions completed',
        ),

        r.gapH(12, tablet: 14, desktop: 16),

        InlineStaffCard(
          name: parentName,
          phone: parentPhone,
          role: 'Parent',
          roleColor: AppColors.mintGreen,
          roleIcon: Icons.family_restroom_outlined,
          subtitle: parentPhone,
        ),
      ],
    );
  }
}
