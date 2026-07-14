import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naivisense/data/models/alert.dart';

import '../../../core/utils/responsive.dart';
import 'alert_history_card.dart';
import 'empty_card.dart';
import 'loading_card.dart';
import 'section_header.dart';

class AlertsSection extends StatelessWidget {
  final AsyncValue<List<AlertModel>> alerts;

  const AlertsSection({super.key, required this.alerts});

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Alert History',
          icon: Icons.notifications_outlined,
        ),

        r.gapH(12, tablet: 14, desktop: 16),

        alerts.when(
          loading: () => const LoadingCard(),

          error: (e, _) => const EmptyCard(message: 'Could not load alerts'),

          data: (list) {
            if (list.isEmpty) {
              return const EmptyCard(message: 'No alerts raised');
            }

            final sorted = [...list]
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sorted.length,
              separatorBuilder: (_, _) => r.gapH(8, tablet: 10, desktop: 12),
              itemBuilder: (_, i) => AlertHistoryCard(alert: sorted[i]),
            );
          },
        ),
      ],
    );
  }
}
