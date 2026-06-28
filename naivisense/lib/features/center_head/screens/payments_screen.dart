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
    final summary  = ref.watch(_summaryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Payments', style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(_paymentsProvider);
          ref.invalidate(_summaryProvider);
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildSummary(summary)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: payments.when(
                loading: () => const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator())),
                error: (e, _) => SliverToBoxAdapter(
                    child: Center(child: Text('Error: $e'))),
                data: (list) {
                  if (list.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Center(
                          child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text('No payments yet',
                            style: TextStyle(color: AppColors.textSecondary)),
                      )),
                    );
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _PaymentCard(
                        payment:   list[i],
                        onMarkPaid: () async {
                          await ref
                              .read(paymentsRepositoryProvider)
                              .updateStatus(list[i].id, 'paid');
                          ref.invalidate(_paymentsProvider);
                          ref.invalidate(_summaryProvider);
                        },
                      ),
                      childCount: list.length,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(AsyncValue<Map<String, dynamic>> summary) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: summary.when(
        loading: () => const SizedBox.shrink(),
        error:   (_, _) => const SizedBox.shrink(),
        data:    (s) => Row(
          children: [
            _SummaryChip(
              label: 'Total',
              value: '${s['total_payments'] ?? 0}',
              color: AppColors.primaryBlue,
            ),
            const SizedBox(width: 10),
            _SummaryChip(
              label: 'Pending',
              value: '${s['pending_payments'] ?? 0}',
              color: AppColors.warmYellow,
            ),
            const SizedBox(width: 10),
            _SummaryChip(
              label: 'Collected',
              value: '₹${((s['total_collected_paise'] as int? ?? 0) / 100).toStringAsFixed(0)}',
              color: AppColors.mintGreen,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _SummaryChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
            Text(label,
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final PaymentModel payment;
  final VoidCallback onMarkPaid;
  const _PaymentCard({required this.payment, required this.onMarkPaid});

  @override
  Widget build(BuildContext context) {
    final statusColor = payment.isPaid
        ? AppColors.mintGreen
        : payment.status == 'failed'
            ? AppColors.softCoral
            : AppColors.warmYellow;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(payment.typeLabel,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(payment.statusLabel,
                    style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w600, color: statusColor)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('₹${payment.amountRupees.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primaryBlue)),
              const Spacer(),
              Text(AppDateUtils.formatDate(payment.createdAt),
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
          if (payment.notes != null && payment.notes!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(payment.notes!,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
          if (payment.isPending) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onMarkPaid,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.mintGreen,
                  side: const BorderSide(color: AppColors.mintGreen),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Mark as Paid'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
