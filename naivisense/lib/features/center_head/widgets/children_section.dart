import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naivisense/data/models/child.dart';

import '../../../core/utils/responsive.dart';
import '../../../../shared/widgets/state_widgets.dart' as sw;
import 'child_admin_card.dart';

class ChildrenSection extends StatelessWidget {
  final AsyncValue<List<ChildModel>> children;

  const ChildrenSection({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'All Children',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontSize: r.sp(24, tablet: 26, desktop: 28),
          ),
        ),

        r.gapH(12, tablet: 16, desktop: 20),

        children.when(
          loading: () => const sw.LoadingWidget(),

          error: (e, _) => sw.ErrorWidget(message: e.toString()),

          data: (list) {
            if (list.isEmpty) {
              return const sw.EmptyWidget(
                message: 'No children enrolled yet',
                icon: Icons.child_care,
              );
            }

            int crossAxisCount;

            if (r.isDesktop) {
              crossAxisCount = 3;
            } else if (r.isTablet) {
              crossAxisCount = 2;
            } else {
              crossAxisCount = 1;
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: r.w(16),
                mainAxisSpacing: r.h(16),

                // Adjust if cards become too tall/short
                childAspectRatio: r.isDesktop
                    ? 1.15
                    : r.isTablet
                    ? 1.0
                    : 1.25,
              ),
              itemBuilder: (context, index) {
                return ChildAdminCard(child: list[index]);
              },
            );
          },
        ),
      ],
    );
  }
}
