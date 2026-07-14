import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import 'summary_chip.dart';

class PaymentsSummary extends StatelessWidget {
  final AsyncValue<Map<String, dynamic>> summary;

  const PaymentsSummary({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return Padding(
      padding: EdgeInsets.all(r.w(16, tablet: 20, desktop: 24)),
      child: summary.when(
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
        data: (s) {
          return Wrap(
            spacing: r.w(12, tablet: 16, desktop: 20),
            runSpacing: r.h(12, tablet: 16, desktop: 20),
            children: [
              SizedBox(
                width: r.isMobile ? double.infinity : 250,
                child: SummaryChip(
                  label: 'Total',
                  value: '${s['total_payments'] ?? 0}',
                  color: AppColors.primaryBlue,
                ),
              ),
              SizedBox(
                width: r.isMobile ? double.infinity : 250,
                child: SummaryChip(
                  label: 'Pending',
                  value: '${s['pending_payments'] ?? 0}',
                  color: AppColors.warmYellow,
                ),
              ),
              SizedBox(
                width: r.isMobile ? double.infinity : 250,
                child: SummaryChip(
                  label: 'Collected',
                  value:
                      '₹${((s['total_collected_paise'] as int? ?? 0) / 100).toStringAsFixed(0)}',
                  color: AppColors.mintGreen,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
