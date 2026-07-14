import 'package:flutter/material.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/date_utils.dart';
import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/data/models/review.dart';

class ReviewRow extends StatelessWidget {
  final ReviewModel review;

  const ReviewRow({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    final isPublished = review.isPublished;

    final statusColor = isPublished
        ? AppColors.mintGreen
        : AppColors.warmYellow;

    return Container(
      padding: EdgeInsets.all(responsive.w(16, tablet: 18, desktop: 20)),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: responsive.borderRadius(16, tablet: 18, desktop: 20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(responsive.w(10)),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: .12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  review.reviewType == 'quarterly'
                      ? Icons.calendar_month_rounded
                      : Icons.calendar_view_week_rounded,
                  color: AppColors.primaryBlue,
                  size: responsive.icon(20, tablet: 22, desktop: 24),
                ),
              ),

              responsive.gapW(12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.typeLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: responsive.sp(15, tablet: 16, desktop: 17),
                      ),
                    ),

                    responsive.gapH(2),

                    Text(
                      '${AppDateUtils.formatDate(review.periodStart)}'
                      ' - '
                      '${AppDateUtils.formatDate(review.periodEnd)}',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: responsive.sp(12, tablet: 13, desktop: 14),
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.w(12),
                  vertical: responsive.h(6),
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: .12),
                  borderRadius: responsive.borderRadius(20),
                ),
                child: Text(
                  isPublished ? 'Published' : 'Draft',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: responsive.sp(11, tablet: 12, desktop: 13),
                  ),
                ),
              ),
            ],
          ),

          responsive.gapH(14),

          Text(
            review.textObservations,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textSecondary,
              height: 1.5,
              fontSize: responsive.sp(13, tablet: 14, desktop: 15),
            ),
          ),

          if (review.adminNotes != null &&
              review.adminNotes!.trim().isNotEmpty) ...[
            responsive.gapH(14),

            Container(
              width: double.infinity,
              padding: EdgeInsets.all(responsive.w(12)),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: .06),
                borderRadius: responsive.borderRadius(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.admin_panel_settings_outlined,
                    color: AppColors.primaryBlue,
                    size: responsive.icon(18),
                  ),

                  responsive.gapW(8),

                  Expanded(
                    child: Text(
                      review.adminNotes!,
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontStyle: FontStyle.italic,
                        fontSize: responsive.sp(12, tablet: 13, desktop: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
