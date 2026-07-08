import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../data/models/session.dart';
import 'stat_chip.dart';
import 'stat_data.dart';

class QuickStatsSection extends StatelessWidget {
  final AsyncValue<List<SessionModel>> sessions;

  const QuickStatsSection({super.key, required this.sessions});

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    final all = sessions.valueOrNull ?? [];

    final completed = all
        .where((session) => session.status == 'completed')
        .length;

    final upcoming = all.where((session) {
      return session.status == 'scheduled' &&
          session.scheduledAt.isAfter(DateTime.now());
    }).length;

    final stats = [
      StatData(
        label: 'Total Sessions',
        value: all.length.toString(),
        color: AppColors.primaryBlue,
        icon: Icons.event_note_outlined,
      ),
      StatData(
        label: 'Completed',
        value: completed.toString(),
        color: AppColors.mintGreen,
        icon: Icons.check_circle_outline,
      ),
      StatData(
        label: 'Upcoming',
        value: upcoming.toString(),
        color: AppColors.warmYellow,
        icon: Icons.upcoming_outlined,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List.generate(stats.length, (index) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: index == stats.length - 1 ? 0 : responsive.h(12),
          ),
          child: SizedBox(
            width: double.infinity,
            child: StatChip(data: stats[index]),
          ),
        );
      }),
    );
  }
}
