import 'package:flutter/material.dart';
import 'package:naivisense/core/utils/date_utils.dart';
import 'package:naivisense/data/models/payment.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';

class PaymentCard extends StatelessWidget {
  final PaymentModel payment;
  final VoidCallback onMarkPaid;

  const PaymentCard({
    super.key,
    required this.payment,
    required this.onMarkPaid,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    final statusColor = payment.isPaid
        ? AppColors.mintGreen
        : payment.status == 'failed'
        ? AppColors.softCoral
        : AppColors.warmYellow;

    return Container(
      margin: EdgeInsets.only(bottom: r.h(12, tablet: 14, desktop: 16)),
      padding: EdgeInsets.all(r.w(14, tablet: 18, desktop: 20)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          r.radius(14, tablet: 16, desktop: 18),
        ),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: r.w(10, tablet: 12, desktop: 14),
            runSpacing: r.h(10, tablet: 12, desktop: 14),
            children: [
              SizedBox(
                width: r.isMobile ? r.screenWidth * .55 : 350,
                child: Text(
                  payment.typeLabel,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: r.sp(15, tablet: 16, desktop: 17),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: r.w(8, tablet: 9, desktop: 10),
                  vertical: r.h(4, tablet: 5, desktop: 6),
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(
                    r.radius(10, tablet: 10, desktop: 12),
                  ),
                ),
                child: Text(
                  payment.statusLabel,
                  style: TextStyle(
                    fontSize: r.sp(11, tablet: 11, desktop: 12),
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),

          r.gapH(10, tablet: 12, desktop: 14),

          // Amount & Date
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: r.w(12, tablet: 14, desktop: 16),
            runSpacing: r.h(8, tablet: 10, desktop: 12),
            children: [
              Text(
                '₹${payment.amountRupees.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: r.sp(18, tablet: 20, desktop: 22),
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryBlue,
                ),
              ),
              Text(
                AppDateUtils.formatDate(payment.createdAt),
                style: TextStyle(
                  fontSize: r.sp(12, tablet: 12, desktop: 13),
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          // Notes
          if (payment.notes != null && payment.notes!.isNotEmpty) ...[
            r.gapH(8, tablet: 9, desktop: 10),
            Text(
              payment.notes!,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: r.sp(12, tablet: 12, desktop: 13),
                color: AppColors.textSecondary,
              ),
            ),
          ],

          // Button
          if (payment.isPending) ...[
            r.gapH(14, tablet: 16, desktop: 18),
            SizedBox(
              width: double.infinity,
              height: r.h(46, tablet: 50, desktop: 52),
              child: OutlinedButton(
                onPressed: onMarkPaid,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.mintGreen,
                  side: const BorderSide(color: AppColors.mintGreen),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      r.radius(10, tablet: 10, desktop: 12),
                    ),
                  ),
                ),
                child: Text(
                  'Mark as Paid',
                  style: TextStyle(fontSize: r.sp(14, tablet: 14, desktop: 15)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
