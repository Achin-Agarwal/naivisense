import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/responsive.dart';
import '../../../../data/models/child.dart';
import 'parent_stat_card.dart';

class ParentStatsSection extends StatelessWidget {
  final AsyncValue<List<ChildModel>> children;

  const ParentStatsSection({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    final childCount = children.valueOrNull?.length ?? 0;

    final cards = [
      ParentStatCard(
        title: 'Children',
        value: childCount.toString(),
        icon: Icons.child_care_rounded, 
        color: Colors.blueAccent,
      ),
      ParentStatCard(
        title: 'Active Plans',
        value: childCount.toString(),
        icon: Icons.assignment_outlined,
        color: Colors.greenAccent,
      ),
    ];

    if (r.isMobile) {
      return Column(children: [cards[0], r.gapH(12), cards[1]]);
    }

    return Row(
      children: [
        Expanded(child: cards[0]),
        r.gapW(16),
        Expanded(child: cards[1]),
      ],
    );
  }
}
