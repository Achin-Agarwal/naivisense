import 'package:flutter/material.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/data/models/ai_draft.dart';

class AiDraftRow extends StatelessWidget {
  final AiDraftModel draft;
  final VoidCallback onApprove;
  final VoidCallback onView;

  const AiDraftRow({
    super.key,
    required this.draft,
    required this.onApprove,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    final statusColor = draft.isApproved
        ? AppColors.mintGreen
        : AppColors.warmYellow;

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(responsive.w(8, tablet: 9, desktop: 10)),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.08),
            borderRadius: responsive.borderRadius(10),
          ),
          child: Icon(
            Icons.description_outlined,
            color: AppColors.primaryBlue,
            size: responsive.icon(20, tablet: 22, desktop: 24),
          ),
        ),

        responsive.gapW(12, tablet: 14, desktop: 16),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                draft.typeLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: responsive.sp(14, tablet: 15, desktop: 16),
                  fontWeight: FontWeight.w600,
                ),
              ),

              responsive.gapH(4, tablet: 5, desktop: 6),

              Text(
                draft.isApproved ? 'Approved' : 'Pending Review',
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w500,
                  fontSize: responsive.sp(12, tablet: 13, desktop: 14),
                ),
              ),
            ],
          ),
        ),

        TextButton(onPressed: onView, child: const Text('View')),

        if (draft.isPending)
          FilledButton(
            onPressed: onApprove,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.mintGreen,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: responsive.w(14),
                vertical: responsive.h(10),
              ),
            ),
            child: Text(
              'Approve',
              style: TextStyle(
                fontSize: responsive.sp(12, tablet: 13, desktop: 14),
              ),
            ),
          ),
      ],
    );
  }
}
