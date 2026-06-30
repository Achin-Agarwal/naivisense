import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/payment.dart';
import '../../../data/repositories/payments_repository.dart';

final _paymentsProvider = FutureProvider<List<PaymentModel>>(
  (ref) => ref.read(paymentsRepositoryProvider).getPayments(),
);

final _summaryProvider = FutureProvider<Map<String, dynamic>>(
  (ref) => ref.read(paymentsRepositoryProvider).getSummary(),
);

class PaymentsScreen extends ConsumerWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payments = ref.watch(_paymentsProvider);
    final summary = ref.watch(_summaryProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        // ==========================================
        // Responsive Breakpoints
        // ==========================================

        final width = constraints.maxWidth;

        final isMobile = width < 600;
        final isTablet = width >= 600 && width < 1024;
        final isDesktop = width >= 1024;

        final horizontalPadding = isMobile ? 16.0 : 24.0;

        return Scaffold(
          backgroundColor: AppColors.background,

          appBar: AppBar(
            title: Text(
              "Payments",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: isMobile ? 20 : 24,
              ),
            ),
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
          ),

          body: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(_paymentsProvider);
              ref.invalidate(_summaryProvider);
            },

            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),

                child: CustomScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,

                  slivers: [
                    /// Responsive Summary Section
                    SliverToBoxAdapter(
                      child: _buildSummary(
                        summary,
                        isMobile,
                        isTablet,
                        isDesktop,
                      ),
                    ),

                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        0,
                        horizontalPadding,
                        24,
                      ),

                      sliver: payments.when(
                        loading: () => const SliverToBoxAdapter(
                          child: Center(child: CircularProgressIndicator()),
                        ),

                        error: (e, _) => SliverToBoxAdapter(
                          child: Center(child: Text("Error: $e")),
                        ),

                        data: (list) {
                          if (list.isEmpty) {
                            return const SliverToBoxAdapter(
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.all(32),
                                  child: Text(
                                    "No payments yet",
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }

                          return SliverList(
                            delegate: SliverChildBuilderDelegate((_, index) {
                              return _PaymentCard(
                                payment: list[index],

                                onMarkPaid: () async {
                                  await ref
                                      .read(paymentsRepositoryProvider)
                                      .updateStatus(list[index].id, "paid");

                                  ref.invalidate(_paymentsProvider);

                                  ref.invalidate(_summaryProvider);
                                },
                              );
                            }, childCount: list.length),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ===================================================
  // Responsive Summary
  // ===================================================

  Widget _buildSummary(
    AsyncValue<Map<String, dynamic>> summary,
    bool isMobile,
    bool isTablet,
    bool isDesktop,
  ) {
    return Padding(
      padding: EdgeInsets.all(isMobile ? 16 : 24),

      child: summary.when(
        loading: () => const SizedBox.shrink(),

        error: (_, __) => const SizedBox.shrink(),

        data: (s) {
          // Wrap prevents overflow on smaller screens
          return Wrap(
            spacing: 12,
            runSpacing: 12,

            children: [
              SizedBox(
                width: isMobile ? double.infinity : 250,
                child: _SummaryChip(
                  label: "Total",
                  value: "${s['total_payments'] ?? 0}",
                  color: AppColors.primaryBlue,
                ),
              ),

              SizedBox(
                width: isMobile ? double.infinity : 250,
                child: _SummaryChip(
                  label: "Pending",
                  value: "${s['pending_payments'] ?? 0}",
                  color: AppColors.warmYellow,
                ),
              ),

              SizedBox(
                width: isMobile ? double.infinity : 250,
                child: _SummaryChip(
                  label: "Collected",
                  value:
                      "₹${((s['total_collected_paise'] as int? ?? 0) / 100).toStringAsFixed(0)}",
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
// =======================================================
// Responsive Summary Chip
// =======================================================

class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final isMobile = width < 600;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 14 : 18,
        horizontal: isMobile ? 12 : 16,
      ),

      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            textAlign: TextAlign.center,

            style: TextStyle(
              fontSize: isMobile ? 20 : 24,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            label,
            textAlign: TextAlign.center,

            style: TextStyle(
              fontSize: isMobile ? 11 : 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// =======================================================
// Responsive Payment Card
// =======================================================

class _PaymentCard extends StatelessWidget {
  final PaymentModel payment;
  final VoidCallback onMarkPaid;

  const _PaymentCard({required this.payment, required this.onMarkPaid});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final isMobile = width < 600;
    final isTablet = width >= 600 && width < 1024;

    final statusColor = payment.isPaid
        ? AppColors.mintGreen
        : payment.status == 'failed'
        ? AppColors.softCoral
        : AppColors.warmYellow;

    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 12 : 16),

      padding: EdgeInsets.all(isMobile ? 14 : 20),

      decoration: BoxDecoration(
        color: AppColors.surface,

        borderRadius: BorderRadius.circular(isMobile ? 14 : 18),

        border: Border.all(color: AppColors.divider),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==========================================
          // Header
          // ==========================================
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 10,
            spacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,

            children: [
              SizedBox(
                width: isMobile ? width * .55 : 350,

                child: Text(
                  payment.typeLabel,

                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,

                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: isMobile ? 15 : 17,
                  ),
                ),
              ),

              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 8 : 10,
                  vertical: isMobile ? 4 : 6,
                ),

                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: .10),

                  borderRadius: BorderRadius.circular(10),
                ),

                child: Text(
                  payment.statusLabel,

                  style: TextStyle(
                    fontSize: isMobile ? 11 : 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: isMobile ? 10 : 14),

          // ==========================================
          // Amount & Date
          // ==========================================
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 12,
            runSpacing: 8,

            children: [
              Text(
                '₹${payment.amountRupees.toStringAsFixed(2)}',

                style: TextStyle(
                  fontSize: isMobile ? 18 : 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryBlue,
                ),
              ),

              Text(
                AppDateUtils.formatDate(payment.createdAt),

                style: TextStyle(
                  fontSize: isMobile ? 12 : 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          // ==========================================
          // Notes
          // ==========================================
          if (payment.notes != null && payment.notes!.isNotEmpty) ...[
            SizedBox(height: isMobile ? 8 : 10),

            Text(
              payment.notes!,

              maxLines: 4,
              overflow: TextOverflow.ellipsis,

              style: TextStyle(
                fontSize: isMobile ? 12 : 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],

          // ==========================================
          // Button
          // ==========================================
          if (payment.isPending) ...[
            SizedBox(height: isMobile ? 14 : 18),

            SizedBox(
              width: double.infinity,
              height: isMobile ? 46 : 52,

              child: OutlinedButton(
                onPressed: onMarkPaid,

                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.mintGreen,

                  side: const BorderSide(color: AppColors.mintGreen),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                child: Text(
                  "Mark as Paid",

                  style: TextStyle(fontSize: isMobile ? 14 : 15),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
