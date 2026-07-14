import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/models/payment.dart';
import '../../../data/repositories/payments_repository.dart';
import '../widgets/payment_card.dart';
import '../widgets/payments_summary.dart';

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
    final r = Responsive(context);

    final payments = ref.watch(_paymentsProvider);
    final summary = ref.watch(_summaryProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
            title: Text(
              'Payments',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: r.sp(20, tablet: 22, desktop: 24),
              ),
            ),
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(_paymentsProvider);
              ref.invalidate(_summaryProvider);
            },
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: r.isDesktop ? 900 : r.maxWidth,
                ),
                child: CustomScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  slivers: [
                    SliverToBoxAdapter(
                      child: PaymentsSummary(summary: summary),
                    ),

                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        r.horizontalPadding,
                        0,
                        r.horizontalPadding,
                        r.verticalPadding + 8,
                      ),
                      sliver: payments.when(
                        loading: () => const SliverToBoxAdapter(
                          child: Center(child: CircularProgressIndicator()),
                        ),

                        error: (e, _) => SliverToBoxAdapter(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: Text(
                                'Error: $e',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: r.sp(14, tablet: 15, desktop: 16),
                                ),
                              ),
                            ),
                          ),
                        ),

                        data: (list) {
                          if (list.isEmpty) {
                            return SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.all(
                                  r.w(32, tablet: 36, desktop: 40),
                                ),
                                child: Center(
                                  child: Text(
                                    'No payments yet',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: r.sp(
                                        15,
                                        tablet: 16,
                                        desktop: 17,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }

                          return SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              return PaymentCard(
                                payment: list[index],
                                onMarkPaid: () async {
                                  await ref
                                      .read(paymentsRepositoryProvider)
                                      .updateStatus(list[index].id, 'paid');

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
}
